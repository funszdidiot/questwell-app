import {spawn, spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {copyFileSync, cpSync, mkdirSync, mkdtempSync, readFileSync, realpathSync} from 'node:fs';
import {join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {assertDisposableCi, assertLocalStatus} from './guard.mjs';
import {smoke} from './smoke.mjs';
import {assertCatalogMatches} from './catalog.mjs';
import {exerciseWoodlandForward} from './woodland-forward.mjs';
import {exerciseHardeningForward} from './hardening-forward.mjs';
import {exerciseHallowedForward} from './hallowed-forward.mjs';

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
function expectSqlFailure(file, expectedMessage) {
  const result = spawnSync(cli,['db','query','--local','--file',file,'--workdir',workdir,'--agent','no'],{
    env,encoding:'utf8',timeout:120000,maxBuffer:1024*1024,
  });
  assert.ok(result.status!==null && result.status!==0,'Negative SQL control unexpectedly succeeded or timed out');
  assert.ok(((result.stderr||'')+(result.stdout||'')).includes(expectedMessage),
    `Negative SQL control did not reach the expected assertion: ${expectedMessage}`);
}
// The pinned CLI's db query intentionally accepts one extended-protocol statement.
// Rehearse the multi-statement timeout + DO payload using psql inside ONLY the
// already-guarded disposable container, in one transaction, without remote credentials.
function runHardeningPayload(file, expectedMessage) {
  assertDisposableCi(process.env);
  assert.ok(!env.DOCKER_HOST && !env.DOCKER_CONTEXT,'Remote Docker targets are forbidden');
  const result=spawnSync('docker',['exec','-i','supabase_db_questwell-disposable-ci',
    'psql','--host=/var/run/postgresql','--username=postgres','--dbname=postgres',
    '--no-password','-X','--single-transaction',
    '--set=ON_ERROR_STOP=1','--file=-'],{
    input:readFileSync(file,'utf8'),env,encoding:'utf8',timeout:120000,maxBuffer:1024*1024,
  });
  const output=redact((result.stderr||'')+(result.stdout||''));
  if(expectedMessage!==undefined){
    assert.ok(result.status!==null && result.status!==0,'Payload negative control unexpectedly succeeded or timed out');
    if(!output.includes(expectedMessage))console.error(output.slice(-14000));
    assert.ok(output.includes(expectedMessage),`Payload negative control did not reach ${expectedMessage}`);
  }else if(result.status!==0){
    console.error(output.slice(-14000));
    throw new Error('Disposable hardening transaction failed');
  }
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
  const runWoodlandAccounts = () => {
    const accounts = spawnSync(process.execPath,[join(source,'woodland.mjs')],{
      input:JSON.stringify(status),env,encoding:'utf8',timeout:120000,maxBuffer:1024*1024,
    });
    if (accounts.stdout) console.log(redact(accounts.stdout));
    if (accounts.stderr) console.error(redact(accounts.stderr));
    if (accounts.status!==0) throw new Error('Woodland account integration failed');
  };
  // This live rollout cannot depend on the separately gated, unapplied R01 fix.
  exerciseWoodlandForward({source,workdir,run,expectSqlFailure,runAccountChecks:runWoodlandAccounts});
  // Reset only this new runner-local stack to test the other independent path.
  // The workdir currently contains just the observed baseline migration.
  run(['db','reset','--local','--no-seed'],5*60*1000);
  assertCatalogMatches(expected,readCatalog());
  console.log('Disposed forward-migration fixtures and restored the isolated observed baseline.');
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
  // Male Woodland uses the same RPCs; prove that only its private fit definition
  // changes, with every other function, policy, grant and table left intact.
  run(['db', 'query', '--local', '--file', join(source, 'woodland-fixture.sql')]);
  const woodlandBefore = readCatalog();
  const woodlandMigration = '20261005175137_male_woodland_approved_rollout.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', woodlandMigration), join(workdir, 'supabase/migrations', woodlandMigration));
  run(['migration', 'up', '--local']);
  const predicate = woodlandBefore.functions.find(f => f.schema === 'private' && f.name === 'cosmetic_supports_body');
  assert.ok(predicate);
  const previousDefinition = predicate.definition;
  predicate.definition = previousDefinition.replace(
    "when p_slug='woodland-scout-outfit' then coalesce(p_body_type in ('female','neutral'),false)",
    "when p_slug='woodland-scout-outfit' then coalesce(p_body_type in ('female','neutral','male'),false)");
  assert.notEqual(predicate.definition, previousDefinition);
  assertCatalogMatches(woodlandBefore, readCatalog());
  run(['db', 'query', '--local', '--file', join(source, 'woodland-contract.sql')]);
  console.log('Woodland fit contract passed; all other schema/ACL/RLS/API definitions unchanged.');
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  runWoodlandAccounts();
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
  const edgeFirst=spawnSync(process.execPath,[join(source,'account-deletion-edge-first.mjs')],{
    input:JSON.stringify(status),env,encoding:'utf8',timeout:120000,maxBuffer:1024*1024,
  });
  if(edgeFirst.stdout)console.log(redact(edgeFirst.stdout));
  if(edgeFirst.stderr)console.error(redact(edgeFirst.stderr));
  if(edgeFirst.status!==0)throw new Error('Edge-first fail-closed rollout rehearsal failed');
  const deletionMigration = '20261005192108_account_deletion_storage.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', deletionMigration), join(workdir, 'supabase/migrations', deletionMigration));
  run(['migration', 'up', '--local']);
  run(['db', 'query', '--local', '--file', join(source, 'account-deletion-contract.sql')]);
  console.log('Deletion inventory grants and restrictive Storage session policy assertions passed.');
  console.log(run(['migration', 'list', '--local']));
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  const deletionTests = () => {
    const deletion = spawnSync(process.execPath, [join(source, 'account-deletion.mjs')], {
      input: JSON.stringify(status), env, encoding: 'utf8', timeout: 180000, maxBuffer: 1024 * 1024,
    });
    if (deletion.stdout) console.log(redact(deletion.stdout));
    if (deletion.stderr) console.error(redact(deletion.stderr));
    if (deletion.status !== 0) throw new Error('Account deletion Edge/Auth/Storage regressions failed');
  };
  deletionTests();
  run(['db','query','--local', `do $$ begin
    drop trigger ci_account_delete_failure on public.users;
    drop trigger ci_pause_storage_upload on storage.objects;
    drop policy ci_secondary_upload on storage.objects;
    drop function public.ci_account_delete_failure();
    drop function public.ci_pause_storage_upload();
    drop function public.ci_storage_upload_paused();
  end $$;`]);
  const creationTests = phase => {
    const result = spawnSync(process.execPath, [join(source, 'task-creation.mjs')], {
      input: JSON.stringify({status, phase}), env, encoding: 'utf8', timeout: 120000,
      maxBuffer: 1024 * 1024,
    });
    if (result.stdout) console.log(redact(result.stdout));
    if (result.stderr) console.error(redact(result.stderr));
    if (result.status !== 0) throw new Error(`Task creation ${phase} failed`);
  };
  // Characterize the existing REST insert before installing the new boundary.
  creationTests('baseline');
  const creationMigration = '20261006005610_retry_safe_task_creation.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', creationMigration), join(workdir, 'supabase/migrations', creationMigration));
  run(['migration', 'up', '--local']);
  run(['db', 'query', '--local', '--file', join(source, 'task-creation-contract.sql')]);
  console.log(run(['migration', 'list', '--local']));
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  // A failure after receipt insertion must roll back that receipt too.
  run(['db', 'query', '--local', "alter table public.tasks add constraint ci_creation_failure check (title <> 'Synthetic retry quest') not valid;"]);
  try {
    creationTests('rollback');
    run(['db', 'query', '--local', `do $$ begin
      if exists (select 1 from private.task_creation_requests) then
        raise exception 'Failed task creation left a receipt';
      end if;
    end $$;`]);
    console.log('PASS creation: downstream failure rolls back its private receipt');
  } finally {
    run(['db', 'query', '--local', 'alter table public.tasks drop constraint ci_creation_failure;']);
  }
  creationTests('regressions');
  const onboardingTests = phase => {
    const result = spawnSync(process.execPath, [join(source, 'onboarding.mjs')], {
      input: JSON.stringify({status, phase}), env, encoding: 'utf8', timeout: 120000,
      maxBuffer: 1024 * 1024,
    });
    if (result.stdout) console.log(redact(result.stdout));
    if (result.stderr) console.error(redact(result.stderr));
    if (result.status !== 0) throw new Error(`Onboarding ${phase} failed`);
  };
  onboardingTests('baseline');
  const onboardingMigration = '20261006013437_atomic_starter_onboarding.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', onboardingMigration), join(workdir, 'supabase/migrations', onboardingMigration));
  run(['migration', 'up', '--local']);
  run(['db', 'query', '--local', '--file', join(source, 'onboarding-contract.sql')]);
  console.log(run(['migration', 'list', '--local']));
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  // Exercise failure before and after task insertion; neither may strand setup.
  for (const [table, expression] of [
    ['tasks', "title <> 'Reply to one email'"],
    ['users', 'not onboarding_completed'],
  ]) {
    run(['db', 'query', '--local', `alter table public.${table} add constraint ci_onboarding_failure check (${expression}) not valid;`]);
    try {
      onboardingTests('rollback');
      run(['db', 'query', '--local', `do $$ begin
        if exists (select 1 from private.onboarding_results) then
          raise exception 'Failed onboarding left a private receipt';
        end if;
      end $$;`]);
      console.log(`PASS onboarding: ${table} failure rolls back task, receipt and profile together`);
    } finally {
      run(['db', 'query', '--local', `alter table public.${table} drop constraint ci_onboarding_failure;`]);
    }
  }
  onboardingTests('regressions');
  const bossCreationTests = phase => {
    const result = spawnSync(process.execPath, [join(source, 'boss-creation.mjs')], {
      input: JSON.stringify({status, phase}), env, encoding: 'utf8', timeout: 120000,
      maxBuffer: 1024 * 1024,
    });
    if (result.stdout) console.log(redact(result.stdout));
    if (result.stderr) console.error(redact(result.stderr));
    if (result.status !== 0) throw new Error(`Boss creation ${phase} failed`);
  };
  bossCreationTests('baseline');
  const bossCreationMigration = '20261006022803_retry_safe_boss_creation.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', bossCreationMigration), join(workdir, 'supabase/migrations', bossCreationMigration));
  run(['migration', 'up', '--local']);
  run(['db', 'query', '--local', '--file', join(source, 'boss-creation-contract.sql')]);
  console.log(run(['migration', 'list', '--local']));
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  for (const [table, expression] of [
    ['boss_battles', "title <> 'Synthetic retry boss'"],
    ['boss_steps', "title <> 'Second synthetic step'"],
  ]) {
    run(['db', 'query', '--local', `alter table public.${table} add constraint ci_boss_creation_failure check (${expression}) not valid;`]);
    try {
      bossCreationTests('rollback');
      run(['db', 'query', '--local', `do $$ begin
        if exists (select 1 from private.boss_creation_requests) then
          raise exception 'Failed boss creation left a private receipt';
        end if;
      end $$;`]);
      console.log(`PASS boss creation: ${table} failure rolls back boss, steps and receipt`);
    } finally {
      run(['db', 'query', '--local', `alter table public.${table} drop constraint ci_boss_creation_failure;`]);
    }
  }
  bossCreationTests('regressions');
  run(['db', 'query', '--local', '--file', join(source, 'boss-concurrency-fixture.sql')]);
  const concurrencyTests = phase => {
    const result = spawnSync(process.execPath, [join(source, 'boss-concurrency.mjs')], {
      input: JSON.stringify({status, phase}), env, encoding: 'utf8',
      timeout: 120000, maxBuffer: 1024 * 1024,
    });
    if (result.stdout) console.log(redact(result.stdout));
    if (result.stderr) console.error(redact(result.stderr));
    if (result.status !== 0) throw new Error(`Boss final-step ${phase} failed`);
  };
  concurrencyTests('baseline');
  const completionBefore = readCatalog();
  const completionMigration = '20261006025302_serialize_boss_final_steps.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', completionMigration), join(workdir, 'supabase/migrations', completionMigration));
  run(['migration', 'up', '--local']);
  const completionAfter = readCatalog();
  const previousCompletion = completionBefore.functions.find(f => f.schema === 'private' && f.name === 'complete_boss_step');
  const nextCompletion = completionAfter.functions.find(f => f.schema === 'private' && f.name === 'complete_boss_step');
  assert.ok(previousCompletion && nextCompletion);
  assert.notEqual(previousCompletion.definition, nextCompletion.definition);
  previousCompletion.definition = nextCompletion.definition;
  assertCatalogMatches(completionBefore, completionAfter);
  console.log('C04 changes only the private completion definition; signatures, grants, RLS and other schema objects match.');
  concurrencyTests('regressions');
  // Recheck actual authorization, legacy saved rewards, same-step concurrency,
  // different-battle balance increments and atomic failures against the fix.
  bossTests('regressions');
  for (const [table, expression] of [
    ['reward_events', "event_type is distinct from 'boss_battle_completed'"],
    ['users', 'total_xp = 0'],
  ]) {
    run(['db', 'query', '--local', `alter table public.${table} add constraint ci_boss_reward_failure check (${expression}) not valid;`]);
    try { bossTests('rollback'); }
    finally { run(['db', 'query', '--local', `alter table public.${table} drop constraint ci_boss_reward_failure;`]); }
  }
  run(['db', 'query', '--local', 'do $$ begin drop function public.ci_complete_boss_step_held(uuid,integer); drop function public.ci_boss_completion_activity(); end $$;']);
  console.log(run(['migration', 'list', '--local']));
  console.log(run(['db', 'lint', '--local', '--schema', 'public,private', '--level', 'warning', '--fail-on', 'error']));
  console.log(run(['db', 'advisors', '--local', '--type', 'security', '--level', 'warn', '--fail-on', 'none']));
  exerciseHardeningForward({source,workdir,run,runPayload:runHardeningPayload,readCatalog});
  for (const contract of ['task-reward-contract.sql','boss-reward-contract.sql',
    'account-deletion-contract.sql','task-creation-contract.sql',
    'onboarding-contract.sql','boss-creation-contract.sql']) {
    run(['db','query','--local','--file',join(source,contract)]);
  }
  creationTests('regressions');
  onboardingTests('regressions');
  bossCreationTests('regressions');
  bossTests('regressions');
  deletionTests();
  // C11b is deliberately after the pinned seven-change forward rehearsal.
  // Never change its historical schema hashes to accommodate a new proposal.
  const chronicleBefore = readCatalog();
  const chronicleMigration = '20261006054430_chronicle_server_totals.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', chronicleMigration), join(workdir, 'supabase/migrations', chronicleMigration));
  run(['migration', 'up', '--local']);
  const chronicleAfter = readCatalog();
  const addedChronicle = chronicleAfter.functions.filter(f => f.schema === 'public' && f.name === 'chronicle_totals');
  assert.equal(addedChronicle.length, 1);
  assert.equal(chronicleBefore.functions.filter(f => f.schema === 'public' && f.name === 'chronicle_totals').length, 0);
  chronicleAfter.functions = chronicleAfter.functions.filter(f => !(f.schema === 'public' && f.name === 'chronicle_totals'));
  chronicleAfter.grants = chronicleAfter.grants.filter(g => !(g.schema === 'public' && g.name.startsWith('chronicle_totals(')));
  for (const name of ['tasks_chronicle_owner_idx','bosses_chronicle_owner_idx']) {
    assert.equal(chronicleBefore.indexes.filter(i => i.name === name).length, 0);
    assert.equal(chronicleAfter.indexes.filter(i => i.schema === 'public' && i.name === name && i.valid && i.ready).length, 1);
    chronicleAfter.indexes = chronicleAfter.indexes.filter(i => !(i.schema === 'public' && i.name === name));
  }
  assertCatalogMatches(chronicleBefore, chronicleAfter);
  run(['db','query','--local','--file',join(source,'chronicle-totals-contract.sql')]);
  const chronicleResult = spawnSync(process.execPath, [join(source, 'chronicle-totals.mjs')], {
    input: JSON.stringify({status}), env, encoding:'utf8', timeout:120000, maxBuffer:1024*1024,
  });
  if (chronicleResult.stdout) console.log(redact(chronicleResult.stdout));
  if (chronicleResult.stderr) console.error(redact(chronicleResult.stderr));
  assert.equal(chronicleResult.status, 0, 'Chronicle Auth/REST scenarios failed');
  console.log(run(['db','lint','--local','--schema','public,private','--level','warning','--fail-on','error']));
  // Halloween is tested after historical hardening hashes are verified.
  run(['db','query','--local','--file',join(source,'hallowed-fixture.sql')]);
  exerciseHallowedForward({source,workdir,run,runPayload:runHardeningPayload});
  const hallowedBefore = readCatalog();
  const hallowedMigration = '20261008015627_hallowed_hearth_catalog.sql';
  copyFileSync(resolve(source, '../../supabase/migrations', hallowedMigration), join(workdir, 'supabase/migrations', hallowedMigration));
  run(['migration','up','--local']);
  const hallowedAfter = readCatalog();
  const beforePurchase = hallowedBefore.functions.find(f => f.schema === 'private' && f.name === 'purchase_cosmetic');
  const afterPurchase = hallowedAfter.functions.find(f => f.schema === 'private' && f.name === 'purchase_cosmetic');
  assert.ok(beforePurchase && afterPurchase);
  assert.notEqual(beforePurchase.definition, afterPurchase.definition);
  beforePurchase.definition = afterPurchase.definition;
  assertCatalogMatches(hallowedBefore, hallowedAfter);
  run(['db','query','--local','--file',join(source,'hallowed-contract.sql')]);
  console.log('Halloween prices, hidden staging, purchase boundaries, retry and permanent placement passed.');
  console.log('LEGACY ROOT MIGRATION CHAIN: STILL BLOCKED. No live baseline/history repair performed.');
} finally {
  edge?.kill();
  if (attemptedStart) {
    // Exact new workdir and explicit local project only; never --all or --linked.
    run(['stop', '--project-id', 'questwell-disposable-ci', '--no-backup'], 120000);
    console.log('Disposed the isolated harness containers/volumes and synthetic accounts/data.');
  }
}
