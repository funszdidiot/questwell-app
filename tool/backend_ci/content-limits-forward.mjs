import assert from 'node:assert/strict';
import {readFileSync, writeFileSync} from 'node:fs';
import {join, resolve} from 'node:path';
import {assertDisposableCi} from './guard.mjs';
import {guardedPayload, migrationPath, stateQuery} from '../deploy/content-limits-contract.mjs';

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
  execute(positive + positive, 'Content deployment precondition drift');
  assert.deepEqual(readState(), before, 'Repeat refusal must roll back the outer transaction');
  console.log('Content forward: timeout, schema drift, atomic rollback, exact staging objects and repeat refusal passed.');
}
