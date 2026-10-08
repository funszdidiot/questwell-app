import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {payload,verifyApplied,deploymentContext,migrationPath,activationPath,manifestPath,deploymentRef,repository} from '../deploy/hallowed-contract.mjs';
const read=p=>readFileSync(new URL('../../'+p,import.meta.url),'utf8');
const source=read(migrationPath),activation=read(activationPath),catalog=read('tool/backend_ci/catalog.sql');
const manifest=JSON.parse(read(manifestPath)),expected=JSON.parse(read('tool/deploy/hallowed-reviewed-state.json'));
const make=(s=source,a=activation,c=catalog,m=manifest,e=expected)=>payload(s,a,c,m,e);
test('exact approved sources generate one guarded atomic forward payload',()=>{
  const plan=make();
  assert.match(plan.sql,/Halloween precondition drift/);
  assert.match(plan.sql,/Halloween postcondition mismatch/);
  assert.match(plan.sql,/availability_end/);
  assert.equal(plan.after.new_count,6);assert.equal(plan.after.render_count,5);
  assert.equal(plan.after.catalog_sha256,expected.before.catalog_sha256);
  assert.equal(plan.after.history_sha256,expected.before.history_sha256);
});
test('source, activation, manifest and query drift stop before any write',()=>{
  assert.throws(()=>make(source+'\n'));
  assert.throws(()=>make(source,activation+'\n'));
  assert.throws(()=>make(source,activation,catalog+'\n'));
  assert.throws(()=>make(source,activation,catalog,{...manifest,display_name:'Changed'}));
});
test('only the dedicated hosted Actions branch may deploy',()=>{
  const env={GITHUB_ACTIONS:'true',RUNNER_ENVIRONMENT:'github-hosted',GITHUB_REPOSITORY:repository,
    GITHUB_EVENT_NAME:'push',GITHUB_REF:deploymentRef,GITHUB_SHA:'a'.repeat(40),
    QUESTWELL_HALLOWED_MIGRATION_TOKEN:'synthetic',GITHUB_TOKEN:'synthetic'};
  deploymentContext(env);
  for(const patch of [{GITHUB_REF:'refs/heads/questwell-dev'},{GITHUB_EVENT_NAME:'pull_request'},
    {GITHUB_REPOSITORY:'other/repo'},{QUESTWELL_HALLOWED_MIGRATION_TOKEN:''},{DATABASE_URL:'unexpected'}]) {
    assert.throws(()=>deploymentContext({...env,...patch}));
  }
});
test('recorded success requires exact state and a single matching digest',()=>{
  const plan=make();
  const done={...plan.after,records:[{version:'20261008023000',statements:[plan.sql]}]};
  verifyApplied(done,plan.after,plan.sourceDigest);
  assert.throws(()=>verifyApplied({...done,new_count:5},plan.after,plan.sourceDigest));
  assert.throws(()=>verifyApplied({...done,records:[]},plan.after,plan.sourceDigest));
  assert.throws(()=>verifyApplied({...done,records:[...done.records,...done.records]},plan.after,plan.sourceDigest));
  assert.throws(()=>verifyApplied({...done,records:[{version:'20261008023000',statements:['wrong']}]},plan.after,plan.sourceDigest));
});
