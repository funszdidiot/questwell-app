import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {join,resolve} from 'node:path';
import {payload,stateQuery,migrationPath,activationPath,manifestPath,sha256} from '../deploy/autumn-contract.mjs';

export function exerciseAutumnForward({source,workdir,run,runPayload}) {
  const root=resolve(source,'../..');
  const sql=readFileSync(join(root,migrationPath),'utf8');
  const activation=readFileSync(join(root,activationPath),'utf8');
  const catalog=readFileSync(join(source,'catalog.sql'),'utf8');
  const manifest=JSON.parse(readFileSync(join(root,manifestPath),'utf8'));
  const reviewed=JSON.parse(readFileSync(join(root,'tool/deploy/autumn-reviewed-state.json'),'utf8'));
  const queryFile=join(workdir,'autumn-state.sql');
  writeFileSync(queryFile,stateQuery(catalog,manifest));
  const readState=()=>JSON.parse(run(['db','query','--local','-o','json','--file',queryFile]))[0].state;
  const before=readState();
  // Only the fixture's known schema/data/history snapshot differs from live.
  const expected={...reviewed,before};
  const file=join(workdir,'autumn-forward.sql');
  writeFileSync(file,payload(sql,activation,catalog,manifest,{...expected,before:{...before,catalog_sha256:'0'.repeat(64)}}).sql);
  runPayload(file,'Autumn Hearth precondition drift');
  assert.deepEqual(readState(),before);
  const noActivation='-- Deliberately omitted in disposable failure scenario.';
  writeFileSync(file,payload(sql,noActivation,catalog,manifest,{...expected,activation_sha256:sha256(noActivation)}).sql);
  runPayload(file,'Autumn Hearth postcondition mismatch');
  assert.deepEqual(readState(),before,'Catalog, function and activation must roll back atomically');
  // Positive payload proves all postconditions, then restores the isolated fixture
  // so the separately staged migration and account scenarios can run unchanged.
  writeFileSync(file,payload(sql,activation,catalog,manifest,expected).sql+'\nrollback;\n');
  runPayload(file);
  assert.deepEqual(readState(),before);
  // Exercise actual purchase, placement and persistence in the same disposable DB.
  writeFileSync(file,payload(sql,activation,catalog,manifest,expected).sql+'\n'+readFileSync(join(source,'autumn-contract.sql'),'utf8')+'\nrollback;\n');
  runPayload(file);
  assert.deepEqual(readState(),before);
  console.log('Autumn Hearth guarded activation, rollback, purchase and placement passed.');
}
