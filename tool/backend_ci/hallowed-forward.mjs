import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {join,resolve} from 'node:path';
import {payload,stateQuery,migrationPath,activationPath,manifestPath} from '../deploy/hallowed-contract.mjs';

export function exerciseHallowedForward({source,workdir,run,runPayload}) {
  const root=resolve(source,'../..');
  const sql=readFileSync(join(root,migrationPath),'utf8');
  const activation=readFileSync(join(root,activationPath),'utf8');
  const catalog=readFileSync(join(source,'catalog.sql'),'utf8');
  const manifest=JSON.parse(readFileSync(join(root,manifestPath),'utf8'));
  const reviewed=JSON.parse(readFileSync(join(root,'tool/deploy/hallowed-reviewed-state.json'),'utf8'));
  const queryFile=join(workdir,'hallowed-state.sql');
  writeFileSync(queryFile,stateQuery(catalog,manifest));
  const readState=()=>JSON.parse(run(['db','query','--local','-o','json','--file',queryFile]))[0].state;
  const before=readState();
  const clockFile=join(workdir,'hallowed-clock.sql');
  writeFileSync(clockFile,"select statement_timestamp() < timestamptz '2026-11-09T06:00:00Z' as window_open;");
  const windowOpen=JSON.parse(run(['db','query','--local','-o','json','--file',clockFile]))[0].window_open;
  const closedMessage='Halloween purchase window has already closed';
  // Only the fixture's known schema/data/history snapshot differs from live.
  const expected={...reviewed,before};
  const file=join(workdir,'hallowed-forward.sql');
  writeFileSync(file,payload(sql,activation,catalog,manifest,{...expected,before:{...before,catalog_sha256:'0'.repeat(64)}}).sql);
  runPayload(file,'Halloween precondition drift');
  assert.deepEqual(readState(),before);
  writeFileSync(file,payload(sql,activation,catalog,manifest,{...expected,after_purchase_sha256:'0'.repeat(64)}).sql);
  runPayload(file,windowOpen?'Halloween postcondition mismatch':closedMessage);
  assert.deepEqual(readState(),before,'Catalog, function and activation must roll back atomically');
  // Positive payload proves all postconditions, then restores the isolated fixture
  // so the separately staged migration and account scenarios can run unchanged.
  writeFileSync(file,payload(sql,activation,catalog,manifest,expected).sql+'\nrollback;\n');
  runPayload(file,windowOpen?undefined:closedMessage);
  assert.deepEqual(readState(),before);
  console.log(`Halloween atomic forward payload, precondition drift and full rollback passed (${windowOpen?'activation open':'expired activation rejected'}).`);
}
