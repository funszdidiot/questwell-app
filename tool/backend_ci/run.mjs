import {spawnSync} from 'node:child_process';
import {copyFileSync, mkdirSync, mkdtempSync, realpathSync} from 'node:fs';
import {join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {assertDisposableCi, assertLocalStatus} from './guard.mjs';
import {smoke} from './smoke.mjs';

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
  return result.stdout;
}
const version = run(['--version']).trim();
if (version !== '2.119.0') throw new Error(`Unexpected Supabase CLI version: ${version}`);
console.log(`Supabase CLI ${version}; temporary local fixture stack only.`);
for (const args of [['start', '--help'], ['db', 'reset', '--help'], ['db', 'query', '--help'], ['stop', '--help']]) {
  run(args); // Installed-version help verifies the command surface on the runner.
}

let attemptedStart = false;
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
  console.log('APP MIGRATION REPLAY: NOT RUN. QW-04 remains open; this is not an app-schema release gate.');
} finally {
  if (attemptedStart) {
    // Exact new workdir and explicit local project only; never --all or --linked.
    run(['stop', '--project-id', 'questwell-disposable-ci', '--no-backup'], 120000);
    console.log('Disposed the isolated harness containers/volumes and synthetic accounts/data.');
  }
}
