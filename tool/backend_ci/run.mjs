import {spawn, spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {copyFileSync, cpSync, mkdirSync, mkdtempSync, readFileSync, realpathSync} from 'node:fs';
import {join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {assertDisposableCi, assertLocalStatus} from './guard.mjs';
import {smoke} from './smoke.mjs';
import {assertCatalogMatches} from './catalog.mjs';

assertDisposableCi(process.env);
if (process.argv.includes('--preflight')) {
  console.log('Disposable-runner and absent-remote-credential preflight passed.');
  process.exit(0);
}
if (process.argv.length !== 2) throw new Error('No target or operation overrides are accepted');

const runnerTemp = realpathSync(process.env.RUNNER_TEMP);
const cli = realpathSync(process.env.QUESTWELL_CLI_BIN);
if (!cli.startsWith(runnerTemp + '/')) throw new Error('Expected runner-local pinned CLI');
const source = fileURLToPath(new URL('.', import.meta.url));
const workdir = mkdtempSync(join(runnerTemp, 'questwell-backend-'));
mkdirSync(join(workdir, 'supabase'));
copyFileSync(join(source, 'supabase/config.toml'), join(workdir, 'supabase/config.toml'));
cpSync(resolve(source, '../../supabase/functions/delete-account'), join(workdir, 'supabase/functions/delete-account'), {recursive: true});
cpSync(join(source, 'baseline-delete-account'), join(workdir, 'supabase/functions/delete-account-before-r03'), {recursive: true});
// Never copy root supabase/.temp, environment files, live keys or a linked-project ID.
const env = {...process.env, SUPABASE_TELEMETRY_DISABLED: '1', DO_NOT_TRACK: '1'};
const redact = value => value
  .replace(/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g, '[local JWT redacted]')
  .replace(/sb_(?:secret|publishable)_[A-Za-z0-9_-]+/g, '[local key redacted]');
function run(args, timeout = 120000) {
  const result = spawnSync(cli, [...args, '--workdir', workdir, '--agent', 'no'], {
    env, encoding: 'utf8', timeout, maxBuffer: 16 * 1024 * 1024,
  });
  if (result.status !== 0) {
    console.error(redact((result.stderr || '') + (result.stdout || '')).slice(-14000));
    throw new Error(`Supabase ${args.slice(0, 2).join(' ')} failed: exit ${result.status}, ${result.error?.code || 'command error'}`);
  }
  if (args[0] === 'db' && ['lint', 'advisors'].includes(args[1]) && result.stderr) console.log(redact(result.stderr));
  return result.stdout;
}
const version = run(['--version']).trim();
if (version !== '2.119.0') throw new Error(`Unexpected Supabase CLI version: ${version}`);
console.log(`Supabase CLI ${version}; temporary local fixture stack only.`);
for (const args of [['start', '--help'], ['db', 'reset', '--help'], ['db', 'query', '--help'], ['db', 'lint', '--help'], ['db', 'advisors', '--help'], ['migration', 'up', '--help'], ['migration', 'list', '--help'], ['functions', 'serve', '--help'], ['stop', '--help']]) {
  run(args); // Installed-version help verifies the command surface on the runner.
}

let attemptedStart = false;
let edge;
try {
  attemptedStart = true;
  run(['start'], 15 * 60 * 1000);
  const status = JSON.parse(run(['status', '-o', 'json']));
  assertLocalStatus(status);
  console.log('Verified fixed loopback API/database endpoints; local credentials are not logged.');
  // This resets ONLY the new runner-local harness, not Questwell's incomplete app baseline.
  run(['db', 'reset', '--local', '--no-seed'], 5 * 60 * 1000);
  run(['db', 'query', '--local', `do $$ begin
    if to_regclass('public.users') is not null then
      raise exception 'Expected an empty harness, not an application database';
    end if;
  end $$;`]);
  run(['db', 'query', '--local', '--file', resolve(source, 'fixture.sql')]);
  const executeSql = sql => run(['db', 'query', '--local', `do $ci$ begin
    if not exists (select 1 from ci_guard.marker where name = 'questwell-disposable-ci') then
      raise exception 'Disposable fixture marker is missing';
    end if;
    ${sql}
  end $ci$;`]);
  executeSql(`
    if not (select relrowsecurity from pg_class where oid = 'public.ci_owner_probe'::regclass) then
      raise exception 'Fixture RLS is not enabled';
    end if;
  `);
  console.log('Clean harness reset and fixture RLS catalog check passed.');
  await smoke(status, executeSql);
  // The legacy root chain's failing CI evidence remains documented; it is not deployable.
  // This separately named baseline reproduces an observed schema, not invented prehistory.
  cpSync(resolve(source, 'app/supabase/migrations'), join(workdir, 'supabase/migrations'), {recursive: true});
  run(['db', 'reset', '--local', '--no-seed'], 5 * 60 * 1000);
  const expected = JSON.parse(readFileSync(join(source, 'observed_catalog.json'), 'utf8'));
  const readCatalog = () => {
    const result = JSON.parse(run(['db', 'query', '--local', '-o', 'json', '--file', join(source, 'catalog.sql')]));
    assert.ok(Array.isArray(result) && result.length === 1 && result[0].catalog, 'Expected one catalog result');
    return result[0].catalog;
  };
  assertCatalogMatches(expected, readCatalog());
  console.log('Observed application baseline rebuilt; all recorded catalog sections match.');
  // Inventory inherited source findings; this is a reconstruction, not a lint-clean claim.
  console.log('Observed-source SQL lint inventory (warnings/errors remain release findings):');
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'none']));
  // Real negative control, on the disposable application's table only.
  run(['db', 'query', '--local', 'alter table public.tasks disable row level security;']);
  try {
    assert.throws(() => assertCatalogMatches(expected, readCatalog()), /Catalog mismatch: tables/);
  } finally {
    run(['db', 'query', '--local', 'alter table public.tasks enable row level security;']);
  }
  assertCatalogMatches(expected, readCatalog());
  console.log('Catalog negative control detected disabled application RLS and verified restoration.');
  // Reset restarts the API. Use a fresh HTTP client process, without retrying writes.
  const app = spawnSync(process.execPath, [join(source, 'app-smoke.mjs')], {
    input: JSON.stringify(status), env, encoding: 'utf8', timeout: 120000,
    maxBuffer: 1024 * 1024,
  });
  if (app.stdout) console.log(redact(app.stdout));
  if (app.status !== 0) {
    if (app.stderr) console.error(redact(app.stderr));
    throw new Error(`Application smoke failed: exit ${app.status}, ${app.error?.code || 'test error'}`);
  }
  // Apply exactly the reviewed proposal AFTER proving the observed baseline.
  // Never replay the incomplete root chain or contact a linked/remote project.
  const rewardMigration = '20261005165421_task_reward_authority.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', rewardMigration), join(workdir, 'supabase/migrations', rewardMigration));
  run(['migration', 'up', '--local']);
  run(['db', 'query', '--local', '--file', join(source, 'task-reward-contract.sql')]);
  console.log('Task reward SQL mapping, column privileges and RLS assertions passed.');
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log('Security advisor inventory after R01; inherited findings remain release blockers:');
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  const rewardTests = phase => {
    const rewards = spawnSync(process.execPath, [join(source, 'task-rewards.mjs')], {
      input: JSON.stringify({status, phase}), env, encoding: 'utf8', timeout: 120000,
      maxBuffer: 1024 * 1024,
    });
    if (rewards.stdout) console.log(redact(rewards.stdout));
    if (rewards.stderr) console.error(redact(rewards.stderr));
    if (rewards.status !== 0) throw new Error(`Task reward ${phase} failed`);
  };
  rewardTests('regressions');
  // Each real downstream failure must roll back all three completion writes.
  for (const [table, expression] of [
    ['reward_events', "event_type is distinct from 'task_completed'"],
    ['users', 'total_xp = 0'],
  ]) {
    run(['db', 'query', '--local', `alter table public.${table} add constraint ci_reward_failure check (${expression}) not valid;`]);
    try {
      rewardTests('rollback');
      console.log(`Verified rollback after forced ${table} write failure.`);
    } finally {
      run(['db', 'query', '--local', `alter table public.${table} drop constraint ci_reward_failure;`]);
    }
  }
  const bossMigration = '20261005183917_boss_reward_authority.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', bossMigration), join(workdir, 'supabase/migrations', bossMigration));
  run(['migration', 'up', '--local']);
  console.log(run(['migration', 'list', '--local']));
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log('Security advisor inventory after R02; this is not a live security certification:');
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  const bossTests = phase => {
    const bosses = spawnSync(process.execPath, [join(source, 'boss-rewards.mjs')], {
      input: JSON.stringify({status, phase}), env, encoding: 'utf8', timeout: 120000,
      maxBuffer: 1024 * 1024,
    });
    if (bosses.stdout) console.log(redact(bosses.stdout));
    if (bosses.stderr) console.error(redact(bosses.stderr));
    if (bosses.status !== 0) throw new Error(`Boss reward ${phase} failed`);
  };
  // Run both boundaries so a failing private SQL assertion cannot hide REST evidence.
  let bossFailed = false;
  try {
    run(['db', 'query', '--local', '--file', join(source, 'boss-reward-contract.sql')]);
    console.log('Private boss reward contract, privileges and RLS assertions passed.');
  } catch { bossFailed = true; }
  try { bossTests('regressions'); } catch { bossFailed = true; }
  if (bossFailed) throw new Error('Boss reward contract/regressions failed');
  for (const [table, expression] of [
    ['reward_events', "event_type is distinct from 'boss_battle_completed'"],
    ['users', 'total_xp = 0'],
  ]) {
    run(['db', 'query', '--local', `alter table public.${table} add constraint ci_boss_reward_failure check (${expression}) not valid;`]);
    try {
      bossTests('rollback');
      console.log(`Verified boss rollback after forced ${table} write failure.`);
    } finally {
      run(['db', 'query', '--local', `alter table public.${table} drop constraint ci_boss_reward_failure;`]);
    }
  }
  // Serve both copied functions: the historical negative control and R03.
  // Do not filter to delete-account while probing its baseline sibling.
  edge = spawn(cli, ['functions', 'serve', '--no-verify-jwt', '--workdir', workdir, '--agent', 'no'], {
    env, stdio: ['ignore', 'ignore', 'ignore'],
  });
  // The function verifies Auth itself; no tokens or Edge request payloads are logged.
  const baselineDeletion = spawnSync(process.execPath, [join(source, 'account-deletion-baseline.mjs')], {
    input: JSON.stringify(status), env, encoding: 'utf8', timeout: 120000, maxBuffer: 1024 * 1024,
  });
  if (baselineDeletion.stdout) console.log(redact(baselineDeletion.stdout));
  if (baselineDeletion.stderr) console.error(redact(baselineDeletion.stderr));
  if (baselineDeletion.status !== 0) throw new Error('Account deletion baseline negative control failed');
  const deletionMigration = '20261005192108_account_deletion_storage.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', deletionMigration), join(workdir, 'supabase/migrations', deletionMigration));
  run(['migration', 'up', '--local']);
  run(['db', 'query', '--local', '--file', join(source, 'account-deletion-contract.sql')]);
  console.log('Deletion inventory grants and restrictive Storage session policy assertions passed.');
  console.log(run(['migration', 'list', '--local']));
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  const deletion = spawnSync(process.execPath, [join(source, 'account-deletion.mjs')], {
    input: JSON.stringify(status), env, encoding: 'utf8', timeout: 180000, maxBuffer: 1024 * 1024,
  });
  if (deletion.stdout) console.log(redact(deletion.stdout));
  if (deletion.stderr) console.error(redact(deletion.stderr));
  if (deletion.status !== 0) throw new Error('Account deletion Edge/Auth/Storage regressions failed');
  console.log('LEGACY ROOT MIGRATION CHAIN: STILL BLOCKED. No live baseline/history repair performed.');
} finally {
  edge?.kill();
  if (attemptedStart) {
    // Exact new workdir and explicit local project only; never --all or --linked.
    run(['stop', '--project-id', 'questwell-disposable-ci', '--no-backup'], 120000);
    console.log('Disposed the isolated harness containers/volumes and synthetic accounts/data.');
  }
}
