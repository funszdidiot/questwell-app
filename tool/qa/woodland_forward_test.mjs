import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {afterState,assertDeploymentContext,assertRequiredChecks,classifyState,
  deployWoodland,deploymentRef,guardedMigration,managementRequest,migrationName,
  migrationPath,project,repository,sha256} from '../deploy/woodland-contract.mjs';

const root = new URL('../../',import.meta.url);
const expected = JSON.parse(readFileSync(new URL('tool/deploy/woodland-approved-state.json',root),'utf8'));
const sourceSql = readFileSync(new URL(migrationPath,root),'utf8');
const catalogSql = readFileSync(new URL('tool/backend_ci/catalog.sql',root),'utf8');
const revision = 'a'.repeat(40);
const ci = {GITHUB_ACTIONS:'true',RUNNER_ENVIRONMENT:'github-hosted',
  GITHUB_REPOSITORY:repository,GITHUB_EVENT_NAME:'push',GITHUB_REF:deploymentRef,
  GITHUB_SHA:revision,GITHUB_TOKEN:'synthetic-check-token',
  QUESTWELL_WOODLAND_MIGRATION_TOKEN:'synthetic-migration-token'};
const before = () => {
  const result = structuredClone(expected);
  delete result.source_sha256; delete result.after_fit_sha256;
  return result;
};
const applied = () => ({...before(),fit_sha256:expected.after_fit_sha256,
  woodland_rows:afterState(expected).woodland_rows,
  records:[{name:migrationName,version:'20261005230000',source_matches:true}]});
const checks = () => ['analyze','Isolated application schema and smoke tests'].map((name,i)=>({
  id:i+1,name,head_sha:revision,status:'completed',conclusion:'success',app:{slug:'github-actions'},
}));

test('live deployment is restricted to the designated hosted branch and repository', () => {
  assert.doesNotThrow(()=>assertDeploymentContext(ci));
  for (const override of [{GITHUB_ACTIONS:'false'},{RUNNER_ENVIRONMENT:'self-hosted'},
    {GITHUB_REPOSITORY:'someone/else'},{GITHUB_EVENT_NAME:'pull_request'},
    {GITHUB_REF:'refs/heads/questwell-dev'},{GITHUB_SHA:'latest'}]) {
    assert.throws(()=>assertDeploymentContext({...ci,...override}));
  }
});

test('missing deployment/check credentials and remote target overrides fail closed', () => {
  for (const key of ['QUESTWELL_WOODLAND_MIGRATION_TOKEN','GITHUB_TOKEN']) {
    assert.throws(()=>assertDeploymentContext({...ci,[key]:''}),/Missing/);
  }
  for (const key of ['SUPABASE_ACCESS_TOKEN','SUPABASE_URL','SUPABASE_PROJECT_ID',
    'SUPABASE_DB_PASSWORD','PGHOST','PGSERVICE','PGPASSWORD','DATABASE_URL']) {
    assert.throws(()=>assertDeploymentContext({...ci,[key]:'do-not-print-me'}),error =>
      error.message.includes(key) && !error.message.includes('do-not-print-me'));
  }
});

test('only successful Actions checks at the exact source revision permit deployment', () => {
  assert.doesNotThrow(()=>assertRequiredChecks(checks(),revision));
  for (const change of [{head_sha:'b'.repeat(40)},{status:'queued'},
    {conclusion:'failure'},{conclusion:'skipped'},{app:{slug:'untrusted'}}]) {
    const runs = checks(); Object.assign(runs[0],change);
    assert.throws(()=>assertRequiredChecks(runs,revision),/Required reviewed-head/);
  }
  assert.throws(()=>assertRequiredChecks(checks().slice(0,1),revision),/Required reviewed-head/);
});

test('later failed or pending check attempts cannot reuse an older success', () => {
  for (const change of [{status:'in_progress',conclusion:null},{conclusion:'failure'}]) {
    const runs = checks(); runs.push({...runs[0],id:3,...change});
    assert.throws(()=>assertRequiredChecks(runs,revision),/Required reviewed-head/);
  }
});

test('source-byte drift is rejected before any metadata read or write', async () => {
  let calls = 0;
  await assert.rejects(deployWoodland({expected,sourceSql:sourceSql+'\n',catalogSql,
    readState:async()=>{calls++;},applyMigration:async()=>{calls++;}}),/migration bytes changed/);
  assert.equal(calls,0);
  assert.equal(sha256(sourceSql),expected.source_sha256);
});

test('the approved state rejects economy and class changes', () => {
  for (const change of [{price:0},{required_archetype:null},{active:false},
    {premium:true},{category:'accessory'},{unlock_method:'free'},{edition_type:'limited'}]) {
    const altered = structuredClone(expected); Object.assign(altered.woodland_rows[0],change);
    assert.throws(()=>guardedMigration(sourceSql,catalogSql,altered));
  }
});

test('schema, history, fit and catalog drift each prevent the write', async () => {
  const mutations = [
    state=>{state.protected_schema_sha256='1'.repeat(64);},
    state=>{state.prior_history_sha256='2'.repeat(64);},
    state=>{state.prior_history_count++;},
    state=>{state.fit_sha256='3'.repeat(64);},
    state=>{state.woodland_rows[0].price=0;},
    state=>{state.woodland_rows[0].required_archetype=null;},
    state=>{state.woodland_rows=[];},
    state=>{state.woodland_rows.push({...state.woodland_rows[0]});},
  ];
  for (const mutate of mutations) {
    const state = before(); mutate(state); let writes = 0;
    await assert.rejects(deployWoodland({expected,sourceSql,catalogSql,
      readState:async()=>state,applyMigration:async()=>{writes++;}}));
    assert.equal(writes,0);
  }
});

test('missing, conflicting or duplicate migration provenance prevents a rerun', () => {
  for (const mutate of [state=>{state.records=[];},state=>{state.records[0].source_matches=false;},
    state=>{state.records[0].version='latest';},state=>{state.records[0].name='unrelated';},
    state=>{state.records.push({...state.records[0]});}]) {
    const state = applied(); mutate(state);
    assert.throws(()=>classifyState(expected,state));
  }
});

test('a matching completed migration is an idempotent no-write result', async () => {
  let writes = 0;
  const result = await deployWoodland({expected,sourceSql,catalogSql,
    readState:async()=>applied(),applyMigration:async()=>{writes++;}});
  assert.equal(result.status,'already_applied'); assert.equal(writes,0);
});

test('exact preflight applies one named payload then verifies its recorded result', async () => {
  const calls = []; let reads = 0;
  const result = await deployWoodland({expected,sourceSql,catalogSql,
    readState:async()=>{calls.push('read'); return reads++ ? applied() : before();},
    applyMigration:async(body,key)=>{
      calls.push('apply'); assert.equal(body.name,migrationName);
      assert.equal(body.query,guardedMigration(sourceSql,catalogSql,expected));
      assert.equal(key,`questwell-woodland-${expected.source_sha256}`);
      assert.deepEqual(Object.keys(body).sort(),['name','query']);
    }});
  assert.deepEqual(calls,['read','apply','read']); assert.equal(result.status,'applied');
  assert.equal(result.version,'20261005230000');
});

test('a timeout never retries the write; a later explicit run reconciles a completed record', async () => {
  let writes = 0;
  await assert.rejects(deployWoodland({expected,sourceSql,catalogSql,readState:async()=>before(),
    applyMigration:async()=>{writes++; throw new Error('timeout');}}),/timeout/);
  assert.equal(writes,1);
  await deployWoodland({expected,sourceSql,catalogSql,readState:async()=>applied(),
    applyMigration:async()=>{writes++;}});
  assert.equal(writes,1);
});

test('a response without the expected recorded state never reports success', async () => {
  let reads = 0; let writes = 0;
  const unrecorded = applied(); unrecorded.records=[];
  await assert.rejects(deployWoodland({expected,sourceSql,catalogSql,
    readState:async()=>reads++ ? unrecorded : before(),applyMigration:async()=>{writes++;}}));
  assert.equal(writes,1);
});

test('Management API requests use the fixed project, reject redirects and bound time', async () => {
  let captured;
  await managementRequest('synthetic-token','migrations',{name:migrationName,query:'synthetic'},
    'synthetic-idempotency-key',async(url,options)=>{captured={url,options}; return new Response('{}');});
  assert.equal(captured.url,`https://api.supabase.com/v1/projects/${project}/database/migrations`);
  assert.equal(captured.options.method,'POST'); assert.equal(captured.options.redirect,'error');
  assert.ok(captured.options.signal instanceof AbortSignal);
  assert.equal(captured.options.headers['Idempotency-Key'],'synthetic-idempotency-key');
});

test('unapproved API paths or queries without read_only make zero HTTP calls', () => {
  let calls = 0; const transport = ()=>{calls++;};
  for (const endpoint of ['https://remote.invalid','../query','migrations/repair']) {
    assert.throws(()=>managementRequest('synthetic-token',endpoint,{},null,transport),/Unapproved/);
  }
  for (const body of [{query:'select 1'},{query:'select 1',read_only:false}]) {
    assert.throws(()=>managementRequest('synthetic-token','query',body,null,transport),/read-only/);
  }
  assert.equal(calls,0);
});

test('offline CLI validates without credentials; normal invocation stops at the credential gate', () => {
  const script = fileURLToPath(new URL('tool/deploy/male-woodland.mjs',root));
  const offline = spawnSync(process.execPath,[script,'--check'],{env:{},encoding:'utf8'});
  assert.equal(offline.status,0,offline.stderr);
  const missing = spawnSync(process.execPath,[script],{env:{...ci,QUESTWELL_WOODLAND_MIGRATION_TOKEN:''},encoding:'utf8'});
  assert.equal(missing.status,1);
  assert.match(missing.stderr,/Missing QUESTWELL_WOODLAND_MIGRATION_TOKEN/);
  assert.ok(!missing.stderr.includes('synthetic-check-token'));
  const override = spawnSync(process.execPath,[script,'--project','elsewhere'],{env:{},encoding:'utf8'});
  assert.equal(override.status,1); assert.match(override.stderr,/no live target\/SQL overrides/);
});
