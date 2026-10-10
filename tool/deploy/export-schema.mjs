import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {pathToFileURL} from 'node:url';
export const project='bdzcazkyypopbanbjnud', repository='funszdidiot/questwell-app';
export const migrationName='reviewed_account_export_schema';
export const paths=['supabase/migrations/20261010052031_account_export_guard.sql','supabase/migrations/20261010052354_account_export_snapshot.sql'];
export const hash=s=>createHash('sha256').update(s).digest('hex');
const definitions={
 'public.claim_account_export':'e4dbc8848633b69b98fe6df7014c29c3',
 'private.claim_account_export':'da2c4c1186d5ee2d7594437393ca15a4',
 'private.export_session_allowed':'569001e0b145d89b7cec8ef3ec23b586',
 'public.account_export_snapshot':'7a45f99232acf9041147b4e514dc5934',
 'public.account_export_session_allowed':'109519522a118766d0042fbe48794656'};
const names=Object.keys(definitions).map(s=>"'"+s+"'").join(',');
export const stateQuery=`select jsonb_build_object(
 'fence',to_regclass('private.account_deletion_fences') is not null,
 'limits',to_regclass('private.account_export_limits') is not null,
 'rls',coalesce((select relrowsecurity from pg_class where oid=to_regclass('private.account_export_limits')),false),
 'definitions',(select coalesce(jsonb_object_agg(n.nspname||'.'||p.proname,md5(pg_get_functiondef(p.oid))),'{}'::jsonb) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname||'.'||p.proname in (${names})),
 'records',(select coalesce(jsonb_agg(jsonb_build_object('name',name,'statements',statements)),'[]'::jsonb) from supabase_migrations.schema_migrations where name='${migrationName}')
) as state;`;
export const before={fence:true,limits:false,rls:false,definitions:{},records:[]};
export function plan(sources,manifest){
 assert.equal(manifest.project,project);assert.equal(sources.length,2);
 assert.deepEqual(manifest.sources,paths.map((path,i)=>({path,sha256:hash(sources[i])})));
 const chunks=sources.map(s=>{assert.match(s,/^begin;\s[\s\S]*commit;\s*$/);return s.replace(/^begin;\s*/,'').replace(/commit;\s*$/,'');});
 const expected=JSON.stringify({...before,limits:true,rls:true,definitions});
 const sql=`set local statement_timeout='20s';
do $export_guard$
declare observed jsonb;
begin
 perform pg_catalog.set_config('lock_timeout','3s',true);
 perform pg_catalog.pg_advisory_xact_lock(784310100520::bigint);
 execute $export_state$${stateQuery}$export_state$ into observed;
 if observed is distinct from '${JSON.stringify(before)}'::jsonb then raise exception 'Export precondition drift'; end if;
${chunks.join('\n')}
 execute $export_state$${stateQuery}$export_state$ into observed;
 if observed is distinct from '${expected}'::jsonb then raise exception 'Export postcondition mismatch'; end if;
 perform pg_catalog.pg_notify('pgrst','reload schema');
end $export_guard$;`;
 return {sql,digest:hash(sql)};
}
export function approve(manifest,p,env,now){
 assert.equal(env.GITHUB_ACTIONS,'true');assert.equal(env.RUNNER_ENVIRONMENT,'github-hosted');
 assert.equal(env.GITHUB_REPOSITORY,repository);assert.equal(env.GITHUB_EVENT_NAME,'push');
 assert.equal(env.GITHUB_REF,'refs/heads/deploy/export-schema-approved');
 assert.match(env.GITHUB_SHA??'',/^[a-f0-9]{40}$/);
 assert.equal(manifest.status,'approved');assert.equal(manifest.payload_sha256,p.digest);
 assert.ok(manifest.approval_ref&&manifest.backup_evidence_ref);
 const expiry=Date.parse(manifest.valid_until),backup=Date.parse(manifest.backup_verified_at);
 assert.ok(Number.isFinite(expiry)&&Number.isFinite(backup)&&backup<=now&&now<expiry&&expiry<=backup+86400000);
 assert.ok(env.GITHUB_TOKEN&&env.QUESTWELL_EXPORT_MIGRATION_TOKEN);
 for(const key of Object.keys(env))if(env[key]&&(key.startsWith('PG')||key.startsWith('SUPABASE_')||key==='DATABASE_URL'))throw Error('Unexpected target override');
}
export function verifyState(state,p){
 const {records,...rest}=state;
 assert.deepEqual(rest,{fence:true,limits:true,rls:true,definitions});
 assert.equal(records.length,1);assert.equal(records[0].name,migrationName);
 assert.ok(Array.isArray(records[0].statements));
 assert.equal(hash(records[0].statements.join('\n')),p.digest);
}
export async function run({sources,manifest,env,transport=fetch,clock=Date.now}){
 const p=plan(sources,manifest);approve(manifest,p,env,clock());
 const req=async(url,options={})=>{
   const r=await transport(url,{...options,redirect:'error',signal:AbortSignal.timeout(60000)});
   assert.ok(r.ok,'Request failed; reconcile before retry');
   const text=await r.text();return text?JSON.parse(text):null;
 };
 const gh=path=>req('https://api.github.com/repos/'+repository+'/'+path,{headers:{Authorization:'Bearer '+env.GITHUB_TOKEN,Accept:'application/vnd.github+json'}});
 const current=async()=>assert.equal((await gh('branches/questwell-dev')).commit.sha,env.GITHUB_SHA);
 await current();
 const checks=await gh('commits/'+env.GITHUB_SHA+'/check-runs?filter=latest&per_page=100');
 assert.ok(Array.isArray(checks.check_runs)&&checks.total_count<=100);
 for(const name of ['Export rollout guards','Isolated application schema and smoke tests','quality / analyze']){
  const c=checks.check_runs.filter(c=>c.name===name&&c.head_sha===env.GITHUB_SHA&&c.app?.slug==='github-actions').sort((a,b)=>b.id-a.id)[0];
  assert.ok(c?.status==='completed'&&c.conclusion==='success');
 }
 const api=(endpoint,body)=>req('https://api.supabase.com/v1/projects/'+project+'/database/'+endpoint,{method:'POST',headers:{Authorization:'Bearer '+env.QUESTWELL_EXPORT_MIGRATION_TOKEN,'Content-Type':'application/json',...(endpoint==='migrations'?{'Idempotency-Key':'questwell-export-'+p.digest}:{})},body:JSON.stringify(body)});
 const state=async()=>{const rows=await api('query',{query:stateQuery,read_only:true});assert.equal(rows?.length,1);return rows[0].state;};
 const observed=await state();
 if(observed.records.length){verifyState(observed,p);return 'already applied and verified';}
 assert.deepEqual(observed,before);
 await current();approve(manifest,p,env,clock());
 // One migration-recording request. Never automatically retry an ambiguous write.
 await api('migrations',{name:migrationName,query:p.sql});
 verifyState(await state(),p);
 return 'schema applied and verified; export endpoint remains disabled';
}
if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href){
 try{
  const read=p=>readFileSync(new URL('../../'+p,import.meta.url),'utf8');
  const sources=paths.map(read),manifest=JSON.parse(read('tool/deploy/export-schema-approval.json'));
  assert.ok(process.argv.length===2||(process.argv.length===3&&process.argv[2]==='--check'));
  if(process.argv[2]==='--check'){plan(sources,manifest);console.log('PASS: pinned export schema payload; no deployment authorization implied.');}
  else console.log(await run({sources,manifest,env:process.env}));
 }catch{console.error('Export schema rollout stopped; reconcile approval, checks and state. No private diagnostics logged.');process.exitCode=1;}
}
