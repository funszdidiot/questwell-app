import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {join,resolve} from 'node:path';
import {assertDisposableCi} from './guard.mjs';
import {assertSqlEffect,guardedMigration,migrationPath,stateQuery} from '../deploy/woodland-contract.mjs';

// Runs only inside run.mjs's newly created, unlinked, synthetic CI database.
// Use the exact production payload generator against the current pre-R01 schema.
export function exerciseWoodlandForward({source,workdir,run,expectSqlFailure,runAccountChecks}) {
  assertDisposableCi(process.env);
  const root = resolve(source,'../..');
  const approved = JSON.parse(readFileSync(join(root,'tool/deploy/woodland-approved-state.json'),'utf8'));
  const sourceSql = readFileSync(join(root,migrationPath),'utf8');
  const catalogSql = readFileSync(join(source,'catalog.sql'),'utf8');
  run(['db','query','--local','--file',join(source,'woodland-fixture.sql')]);
  const stateFile = join(workdir,'woodland-state.sql');
  writeFileSync(stateFile,stateQuery(catalogSql,approved.source_sha256));
  const readState = () => {
    const rows = JSON.parse(run(['db','query','--local','-o','json','--file',stateFile]));
    assert.ok(Array.isArray(rows) && rows.length===1 && rows[0].state);
    return rows[0].state;
  };
  const initial = readState();
  assert.equal(initial.protected_schema_sha256,approved.protected_schema_sha256,
    'Disposable schema differs from the approved live precondition');
  assert.equal(initial.fit_sha256,approved.fit_sha256,'Disposable fit differs from the live precondition');
  assert.deepEqual(initial.records,[]);
  // Catalog IDs/timestamps and migration history belong to this synthetic stack.
  // The live manifest itself is never changed by the test.
  const expected = {...approved,...initial};
  const migrationFile = join(workdir,'woodland-guarded.sql');
  const writeMigration = contract => writeFileSync(migrationFile,guardedMigration(sourceSql,catalogSql,contract));

  writeMigration({...expected,protected_schema_sha256:'0'.repeat(64)});
  expectSqlFailure(migrationFile,'Woodland deployment precondition drift');
  assert.deepEqual(readState(),initial,'Precondition failure must make no database change');
  console.log('Woodland precondition negative control refused a drifted database without changes.');

  // The migration runs, then a deliberately wrong postcondition raises inside
  // the same DO statement. Verify its function and catalog writes both rolled back.
  writeMigration({...expected,after_fit_sha256:'0'.repeat(64)});
  expectSqlFailure(migrationFile,'Woodland deployment postcondition failed');
  assert.deepEqual(readState(),initial,'Postcondition failure must roll back every SQL change');
  console.log('Woodland postcondition negative control rolled back both the fit and catalog writes.');

  writeMigration(expected);
  run(['db','query','--local','--file',migrationFile]);
  const final = readState();
  assertSqlEffect(expected,final);
  assert.deepEqual(final.records,[],'Direct local SQL does not simulate Management API history registration');
  expectSqlFailure(migrationFile,'Woodland deployment precondition drift');
  assert.deepEqual(readState(),final,'A repeated SQL payload must not make another change');
  run(['db','query','--local','--file',join(source,'woodland-contract.sql')]);
  console.log('Exact guarded Woodland SQL passed on the pre-R01 baseline; repeated SQL was refused.');
  runAccountChecks();
}
