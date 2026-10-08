import assert from 'node:assert/strict';
import {readFileSync, writeFileSync} from 'node:fs';
import {join, resolve} from 'node:path';
import {assertDisposableCi} from './guard.mjs';
import {guardedPayload, migrationPath, stateQuery} from '../deploy/content-limits-contract.mjs';
import {makePlan} from '../deploy/content-limits-runner.mjs';

export function exerciseContentLimitsForward({source, workdir, run, runPayload}) {
  assertDisposableCi(process.env);
  const root = resolve(source, '../..');
  const sql = readFileSync(join(root, migrationPath), 'utf8');
  const catalog = readFileSync(join(source, 'catalog.sql'), 'utf8');
  const reviewed = JSON.parse(readFileSync(join(root, 'tool/deploy/content-limits-reviewed-state.json'), 'utf8'));
  const stateFile = join(workdir, 'content-forward-state.sql');
  writeFileSync(stateFile, stateQuery(catalog));
  const readState = () => {
    const rows = JSON.parse(run(['db', 'query', '--local', '-o', 'json', '--file', stateFile]));
    assert.equal(rows.length, 1); assert.ok(rows[0].state); return rows[0].state;
  };
  const before = readState();
  assert.equal(before.limits_sha256, reviewed.before.limits_sha256);
  // Fixture-only history/schema can differ; never rewrite the live manifest.
  // The postcondition remains the exact two functions, four triggers and grants
  // independently read from the previously accepted staging installation.
  const expected = {...reviewed, before};
  const file = join(workdir, 'content-forward.sql');
  const execute = (text, failure) => { writeFileSync(file, text); runPayload(file, failure); };
  const positive = guardedPayload(sql, catalog, expected);
  execute(positive.replace("set local statement_timeout = '20s';", "set local statement_timeout = '100ms';")
    .replace('declare observed jsonb;\nbegin', 'declare observed jsonb;\nbegin\n  perform pg_catalog.pg_sleep(1);'), 'statement timeout');
  assert.deepEqual(readState(), before, 'Cancellation must leave no effects');
  execute(guardedPayload(sql, catalog, {...expected, before: {...before, protected_schema_sha256: '0'.repeat(64)}}),
    'Content deployment precondition drift');
  assert.deepEqual(readState(), before, 'Precondition drift must leave no effects');
  execute(guardedPayload(sql, catalog, {...expected, after_limits_sha256: '0'.repeat(64)}),
    'Content deployment postcondition mismatch');
  assert.deepEqual(readState(), before, 'Every function, grant and trigger must roll back');
  // Prove a successful exact payload, then roll back only this disposable trial.
  // The unchanged source migration and authenticated boundary cases run next.
  execute(positive + '\nrollback;\n');
  assert.deepEqual(readState(), before, 'Positive rehearsal must preserve fixture history');
  // Exercise the runner's real catalog/history query against a recorded fixture,
  // including both the pre-install and post-install shapes. Never retain it.
  const plan = makePlan(sql, catalog, expected);
  writeFileSync(stateFile, plan.query);
  assert.deepEqual(readState(), plan.before);
  const quote = value => `'${value.replaceAll("'", "''")}'`;
  execute(positive + `\ninsert into supabase_migrations.schema_migrations(version,name,statements)
    values('20990101000000','approved_content_limits_live',array[${quote(positive)}]);
    do $runner_record$
    declare actual jsonb;
    begin
      execute $runner_query$${plan.query}$runner_query$ into actual;
      if actual - 'records' is distinct from ${quote(JSON.stringify(plan.after))}::jsonb
        or jsonb_array_length(actual->'records') <> 1
        or actual->'records'->0->>'version' <> '20990101000000'
        or actual->'records'->0->'statements'->>0 is distinct from ${quote(positive)} then
        raise exception 'Runner recorded metadata mismatch';
      end if;
    end $runner_record$;
    rollback;\n`);
  assert.deepEqual(readState(), plan.before, 'Recorded fixture must roll back');
  writeFileSync(stateFile, stateQuery(catalog));
  execute(positive + positive, 'Content deployment precondition drift');
  assert.deepEqual(readState(), before, 'Repeat refusal must roll back the outer transaction');
  console.log('Content forward: timeout, drift, rollback, exact objects, runner recorded metadata and repeat refusal passed.');
}
