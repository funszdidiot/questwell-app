import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {paths,plan,run,before,approve,project} from '../deploy/export-schema.mjs';
const sources=paths.map(p=>readFileSync(new URL('../../'+p,import.meta.url),'utf8'));
const original=JSON.parse(readFileSync(new URL('../deploy/export-schema-approval.json',import.meta.url),'utf8'));
const now=Date.parse('2026-10-10T07:00:00Z'),sha='a'.repeat(40);
const env={GITHUB_ACTIONS:'true',RUNNER_ENVIRONMENT:'github-hosted',GITHUB_REPOSITORY:'funszdidiot/questwell-app',GITHUB_EVENT_NAME:'push',GITHUB_REF:'refs/heads/deploy/export-schema-approved',GITHUB_SHA:sha,GITHUB_TOKEN:'synthetic',QUESTWELL_EXPORT_MIGRATION_TOKEN:'synthetic'};
const approved=()=>({...original,status:'approved',approval_ref:'synthetic approval',backup_evidence_ref:'synthetic backup',backup_verified_at:'2026-10-10T06:00:00Z',valid_until:'2026-10-10T08:00:00Z'});
const checks={total_count:3,check_runs:['Export rollout guards','Isolated application schema and smoke tests','quality / analyze'].map((name,id)=>({name,id,head_sha:sha,app:{slug:'github-actions'},status:'completed',conclusion:'success'}))};
function transport({state=before,checkData=checks,writeFailure=false}={}){
 let writes=0,calls=0;
 const fn=async(url,options)=>{calls++;
  if(url.includes('/branches/'))return new Response(JSON.stringify({commit:{sha}}));
  if(url.includes('/check-runs'))return new Response(JSON.stringify(checkData));
  if(url.endsWith('/query'))return new Response(JSON.stringify([{state}]));
  if(url.endsWith('/migrations')){writes++;assert.equal(options.headers['Idempotency-Key'],'questwell-export-'+original.payload_sha256);if(writeFailure)throw Error('ambiguous write');throw Error('post-state fixture required');}
  throw Error('unexpected request');
 };
 return {fn,writes:()=>writes,calls:()=>calls};
}
test('pending approval cannot make any network call',async()=>{const t=transport();await assert.rejects(run({sources,manifest:{...original,status:'pending'},env,transport:t.fn,clock:()=>now}));assert.equal(t.calls(),0);});
test('changed source or target rejects before network',async()=>{for(const options of [{sources:[sources[0]+'\n',sources[1]],manifest:approved()},{sources,manifest:{...approved(),project:'other'}}]){const t=transport();await assert.rejects(run({...options,env,transport:t.fn,clock:()=>now}));assert.equal(t.calls(),0);}});
test('wrong ref, absent credentials, expiry and target overrides reject',()=>{const p=plan(sources,approved());for(const e of [{...env,GITHUB_REF:'refs/heads/questwell-dev'},{...env,QUESTWELL_EXPORT_MIGRATION_TOKEN:''},{...env,SUPABASE_URL:'other'}])assert.throws(()=>approve(approved(),p,e,now));assert.throws(()=>approve({...approved(),valid_until:'2026-10-10T06:30:00Z'},p,env,now));});
test('failed checks block database requests',async()=>{const t=transport({checkData:{...checks,check_runs:[]}});await assert.rejects(run({sources,manifest:approved(),env,transport:t.fn,clock:()=>now}));assert.equal(t.calls(),2);assert.equal(t.writes(),0);});
test('schema drift blocks migration',async()=>{const t=transport({state:{...before,limits:true}});await assert.rejects(run({sources,manifest:approved(),env,transport:t.fn,clock:()=>now}));assert.equal(t.writes(),0);});
test('ambiguous write gets one attempt with idempotency key',async()=>{const t=transport({writeFailure:true});await assert.rejects(run({sources,manifest:approved(),env,transport:t.fn,clock:()=>now}));assert.equal(t.writes(),1);});
test('already-recorded but mismatched state never rewrites',async()=>{const t=transport({state:{...before,records:[{name:'wrong',statements:[]}]}});await assert.rejects(run({sources,manifest:approved(),env,transport:t.fn,clock:()=>now}));assert.equal(t.writes(),0);});
test('payload pins both files and keeps pre/post checks in one DO statement',()=>{const p=plan(sources,original);assert.equal(p.digest,original.payload_sha256);assert.ok(p.sql.includes('Export precondition drift'));assert.ok(p.sql.includes('Export postcondition mismatch'));assert.equal((p.sql.match(/do \$export_guard\$/g)||[]).length,1);assert.ok(!/^begin;|^commit;/m.test(p.sql));});
test('successful write verifies exact recorded payload; rerun is read-only',async()=>{
 const p=plan(sources,approved());
 const expected=JSON.parse(p.sql.match(/if observed is distinct from '(\{"fence":true,"limits":true[^']+)'::jsonb/)[1]);
 const after={...expected,records:[{name:'reviewed_account_export_schema',statements:[p.sql]}]};
 let applied=false,writes=0;
 const fn=async(url,options)=>{
  if(url.includes('/branches/'))return new Response(JSON.stringify({commit:{sha}}));
  if(url.includes('/check-runs'))return new Response(JSON.stringify(checks));
  if(url.endsWith('/query'))return new Response(JSON.stringify([{state:applied?after:before}]));
  if(url.endsWith('/migrations')){writes++;assert.equal(JSON.parse(options.body).query,p.sql);applied=true;return new Response('');}
  throw Error('unexpected request');
 };
 assert.match(await run({sources,manifest:approved(),env,transport:fn,clock:()=>now}),/applied and verified/);
 assert.match(await run({sources,manifest:approved(),env,transport:fn,clock:()=>now}),/already applied/);
 assert.equal(writes,1);
});
