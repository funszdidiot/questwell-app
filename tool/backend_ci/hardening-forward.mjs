import assert from 'node:assert/strict';
import {readFileSync,writeFileSync,rmSync} from 'node:fs';
import {join,resolve,basename} from 'node:path';
import {guardedPayload,stateQuery} from '../deploy/hardening-contract.mjs';
import {assertCatalogMatches} from './catalog.mjs';

export function exerciseHardeningForward({source,workdir,run,runPayload,readCatalog}) {
  const approved=JSON.parse(readFileSync(resolve(source,'../deploy/hardening-reviewed-state.json'),'utf8'));
  const catalogSql=readFileSync(join(source,'catalog.sql'),'utf8');
  const sources=approved.migrations.map(f=>({...f,sql:readFileSync(resolve(source,'../..',f.path),'utf8')}));
  const stateFile=join(workdir,'hardening-state.sql');
  writeFileSync(stateFile,stateQuery(catalogSql));
  const readState=()=>{
    const rows=JSON.parse(run(['db','query','--local','-o','json','--file',stateFile]));
    assert.equal(rows.length,1); assert.ok(rows[0].state); return rows[0].state;
  };
  const sequentialCatalog=readCatalog();
  const afterHash=readState().schema_sha256;
  if(approved.after_schema_sha256!==null) assert.equal(afterHash,approved.after_schema_sha256,'Reviewed postcondition changed');
  console.log(`Hardening rehearsal post-schema SHA256: ${afterHash}`);
  // Retain the observed baseline and already-live Woodland change only.
  // The workdir was created by the GitHub-hosted disposable guard, not a linked project.
  for(const f of approved.migrations) rmSync(join(workdir,'supabase/migrations',basename(f.path)));
  run(['db','reset','--local','--no-seed'],5*60*1000);
  const before=readState();
  assert.equal(before.schema_sha256,approved.schema_sha256,'Rehearsal schema must match the live reviewed precondition');
  assert.equal(before.rollout_records,0);
  // Only synthetic history differs. Never change the live manifest from this test.
  const expected={...approved,...before,after_schema_sha256:afterHash};
  const payloadFile=join(workdir,'hardening-guarded.sql');
  const writePayload=m=>writeFileSync(payloadFile,guardedPayload(sources,catalogSql,m));
  // Prove the timer is armed before DO starts, rather than setting it inside DO.
  writeFileSync(payloadFile,guardedPayload(sources,catalogSql,expected)
    .replace("set local statement_timeout = '20s';","set local statement_timeout = '100ms';")
    .replace('declare observed jsonb;\nbegin','declare observed jsonb;\nbegin\n  perform pg_catalog.pg_sleep(1);'));
  runPayload(payloadFile,'statement timeout');
  assert.deepEqual(readState(),before,'Timeout must leave no effects');
  writePayload({...expected,schema_sha256:'0'.repeat(64)});
  runPayload(payloadFile,'Hardening precondition drift');
  assert.deepEqual(readState(),before,'Drift must leave no effects');
  writePayload({...expected,after_schema_sha256:'0'.repeat(64)});
  runPayload(payloadFile,'Hardening postcondition failed');
  assert.deepEqual(readState(),before,'All seven changes must roll back together');
  writePayload(expected);
  try {
    runPayload(payloadFile);
  } catch (error) {
    // Fixture-only diagnosis preserves the failing postcondition and rollback.
    // Report differing schema entries, never synthetic user rows or credentials.
    const literal=JSON.stringify(sequentialCatalog).replaceAll("'","''");
    const diagnostic=guardedPayload(sources,catalogSql,expected).replace(
      "raise exception 'Hardening postcondition failed; transaction rolled back';",
      ()=>`declare actual jsonb; differences jsonb; begin
        execute $diagnostic_catalog$${catalogSql}$diagnostic_catalog$ into actual;
        select jsonb_object_agg(e.key,jsonb_build_object(
          'expected_only',(select jsonb_agg(v) from (select value v from jsonb_array_elements(e.value) except select value from jsonb_array_elements(actual->e.key)) d),
          'actual_only',(select jsonb_agg(v) from (select value v from jsonb_array_elements(actual->e.key) except select value from jsonb_array_elements(e.value)) d)))
        into differences from jsonb_each('${literal}'::jsonb) e where e.value is distinct from actual->e.key;
        raise exception 'Hardening fixture schema difference: %',differences;
      end;`);
    writeFileSync(payloadFile,diagnostic);
    try { runPayload(payloadFile); } catch {}
    assert.deepEqual(readState(),before,'Failed diagnostic must roll back');
    throw error;
  }
  const after=readState();
  assert.deepEqual(after,{...before,schema_sha256:afterHash},'Existing migration history must be unchanged');
  assertCatalogMatches(sequentialCatalog,readCatalog());
  runPayload(payloadFile,'Hardening precondition drift');
  assert.deepEqual(readState(),after,'Repeated application must not modify the database');
  console.log('Hardening bundle: live-schema parity, drift rejection, atomic rollback, exact sequential-schema match and repeat refusal passed.');
}
