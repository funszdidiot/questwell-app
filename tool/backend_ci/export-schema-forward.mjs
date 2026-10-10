import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {resolve,join} from 'node:path';
import {plan,paths,stateQuery,before} from '../deploy/export-schema.mjs';

// Called only by the existing guarded disposable CI harness, after its baseline.
export function exerciseExportSchema({source,workdir,run,runPayload}) {
 const root=resolve(source,'../..');
 const sources=paths.map(p=>readFileSync(resolve(root,p),'utf8'));
 const manifest=JSON.parse(readFileSync(resolve(root,'tool/deploy/export-schema-approval.json'),'utf8'));
 const payload=plan(sources,manifest).sql;
 const state=()=>JSON.parse(run(['db','query','--local','-o','json',stateQuery]))[0].state;
 assert.deepEqual(state(),before);
 // Force the final assertion to fail: every preceding schema write must roll back.
 const negative=join(workdir,'export-schema-negative.sql');
 const postcondition="raise exception 'Export postcondition mismatch'; end if;";
 assert.equal(payload.split(postcondition).length,2);
 writeFileSync(negative,payload.replace(postcondition,postcondition+" raise exception 'Forced export rollback';"));
 runPayload(negative,'Forced export rollback');
 assert.deepEqual(state(),before,'Failed rollout left schema behind');
 const positive=join(workdir,'export-schema-positive.sql');writeFileSync(positive,payload);
 runPayload(positive);
 const after=state();assert.equal(after.limits,true);assert.equal(after.rls,true);
 assert.equal(Object.keys(after.definitions).length,5);
 const grants=join(workdir,'export-schema-grants.sql');
 writeFileSync(grants,`do $$ begin
 if has_table_privilege('authenticated','private.account_export_limits','SELECT,INSERT,UPDATE,DELETE')
 or has_table_privilege('anon','private.account_export_limits','SELECT,INSERT,UPDATE,DELETE') then
 raise exception 'Export limits table is exposed'; end if;
 if has_function_privilege('anon','public.account_export_snapshot()','EXECUTE')
 or has_function_privilege('anon','public.claim_account_export()','EXECUTE')
 or has_function_privilege('anon','public.account_export_session_allowed()','EXECUTE') then
 raise exception 'Anonymous export execute is exposed'; end if;
 if not has_function_privilege('authenticated','public.account_export_snapshot()','EXECUTE')
 or not has_function_privilege('authenticated','public.claim_account_export()','EXECUTE') then
 raise exception 'Authenticated export grant missing'; end if;
 if public.account_export_session_allowed() or public.claim_account_export() then
 raise exception 'Sessionless export was allowed'; end if;
 end $$;`);
 runPayload(grants);
 runPayload(positive,'Export precondition drift');
 assert.deepEqual(state(),after,'Repeat rejection changed schema');
 console.log('PASS export schema: exact bundle applied; forced failure rolled back all objects; RLS/grants/session denial passed; repeat rejected without changes.');
}
