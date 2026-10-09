import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {join,resolve} from 'node:path';
import {assertDisposableCi} from './guard.mjs';
import {guardedPayload,migrationPath,stateQuery} from '../deploy/decorate-hearth-contract.mjs';
export function exerciseDecorateHearthForward({source,workdir,run,runPayload}) {
  assertDisposableCi(process.env);
  const root=resolve(source,'../..');
  const sql=readFileSync(join(root,migrationPath),'utf8');
  const catalog=readFileSync(join(source,'catalog.sql'),'utf8');
  const reviewed=JSON.parse(readFileSync(join(root,'tool/deploy/decorate-hearth-reviewed-state.json'),'utf8'));
  const stateFile=join(workdir,'hearth-state.sql');
  writeFileSync(stateFile,stateQuery(catalog));
  const readState=()=>JSON.parse(run(['db','query','--local','-o','json','--file',stateFile]))[0].state;
  const before=readState();
  const expected={...reviewed,before};
  const file=join(workdir,'hearth-forward.sql');
  const execute=(text,failure)=>{writeFileSync(file,text);runPayload(file,failure);};
  const payload=guardedPayload(sql,catalog,expected);
  execute(guardedPayload(sql,catalog,{...expected,before:{...before,protected_sha256:'0'.repeat(64)}}),'Hearth deployment precondition drift');
  assert.deepEqual(readState(),before);
  execute(payload.replace("after_state->>'tables' <> '1'", "after_state->>'tables' <> '99'"),'Hearth deployment scope mismatch');
  assert.deepEqual(readState(),before,'Failed postconditions must roll back all candidate objects');
  execute(payload.replace("statement_timeout='20s'","statement_timeout='100ms'")
    .replace('begin\n  perform','begin\n  perform pg_catalog.pg_sleep(1);\n  perform'),'statement timeout');
  assert.deepEqual(readState(),before);
  execute(payload+'\nrollback;');
  assert.deepEqual(readState(),before);
  execute(payload+payload,'Hearth deployment precondition drift');
  assert.deepEqual(readState(),before);
  console.log('Hearth forward: drift, postcondition rollback, timeout, exact scope and repeat refusal passed.');
}
