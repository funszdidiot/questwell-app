import test from 'node:test';
import assert from 'node:assert/strict';
import {accountExport,feedbackRetentionPlan} from '../support/data_policy.mjs';
const owner='10000000-0000-4000-8000-000000000001';
const other='10000000-0000-4000-8000-000000000002';
const time='2026-10-08T02:00:00Z';
const columns={
 users:'id created_at email display_name level total_xp coin_balance current_energy_mode onboarding_completed adventurer_archetype avatar_body_type level_xp_offset',
 tasks:'id user_id created_at title notes status due_date xp_value coin_value completed_at friction_level pinned_at',
 boss_battles:'id user_id title status reward_xp reward_coins created_at completed_at boss_type',
 boss_steps:'id user_id boss_id title position completed completed_at created_at',
 user_cosmetics:'user_id cosmetic_id unlocked_at source equipped room_slot',
 progression_events:'id user_id kind event_key title level cosmetic_slug source occurred_at',
 reward_events:'id user_id task_id event_type xp_amount coin_amount created_at',
 beta_feedback:'id user_id created_at category goal message expected steps reply_email device screen build platform status attachment_path attachment_paths',
};
const row=(table,values={})=>({...Object.fromEntries(columns[table].split(' ').map(key=>[key,null])),id:other,user_id:owner,...values});
function snapshot(){const names=Object.keys(columns);return {verifiedOwnerId:owner,collectedAt:time,tables:Object.fromEntries(names.map(n=>[n,n==='users'?[row('users',{id:owner,email:'synthetic@example.test',access_token:'must not export'})]:[]])),complete:Object.fromEntries(names.map(n=>[n,true]))};}
test('export preserves user content and strips secrets and internal notes',()=>{
 const s=snapshot();s.tables.tasks=[row('tasks',{title:'<script>text</script>',notes:'private user content',password:'secret'})];s.tables.beta_feedback=[row('beta_feedback',{message:'my report',action_summary:'internal only'})];
 const r=accountExport(s);assert.equal(r.tables.tasks[0].notes,'private user content');assert.equal(r.tables.tasks[0].title,'<script>text</script>');assert.equal(Object.hasOwn(r.tables.tasks[0],'password'),false);assert.equal(Object.hasOwn(r.tables.users[0],'access_token'),false);assert.ok(!JSON.stringify(r).includes('must not export'));assert.ok(!JSON.stringify(r).includes('internal only'));
});
test('cross-owner, incomplete, and broken relation exports fail closed',()=>{
 let s=snapshot();s.tables.tasks=[row('tasks',{user_id:other})];assert.throws(()=>accountExport(s),/Cross-account/);
 s=snapshot();s.complete.tasks=false;assert.throws(()=>accountExport(s),/Complete/);
 s=snapshot();s.tables.boss_steps=[row('boss_steps',{boss_id:other})];assert.throws(()=>accountExport(s),/Incomplete boss/);
 s=snapshot();s.tables.reward_events=[row('reward_events',{task_id:other})];assert.throws(()=>accountExport(s),/Incomplete reward/);
 s.tables.reward_events[0].task_id=null;assert.equal(accountExport(s).tables.reward_events.length,1);
});
test('missing columns, duplicate records and nested secret carriers fail closed',()=>{
 let s=snapshot();delete s.tables.users[0].email;assert.throws(()=>accountExport(s),/Missing export field/);
 s=snapshot();s.tables.tasks=[row('tasks'),row('tasks')];assert.throws(()=>accountExport(s),/Duplicate/);
 for(const value of [{access_token:'SYNTHETIC_TOKEN'},['SYNTHETIC_TOKEN'],42]){s=snapshot();s.tables.users[0].display_name=value;assert.throws(()=>accountExport(s),/field type/);}
 s=snapshot();s.tables.beta_feedback=[row('beta_feedback',{attachment_paths:[{token:'SYNTHETIC_TOKEN'}]})];assert.throws(()=>accountExport(s),/field type/);
 s=snapshot();s.tables.users[0].total_xp=9007199254740992;assert.throws(()=>accountExport(s),/number/);
 s=snapshot();s.tables.users[0].onboarding_completed='true';assert.throws(()=>accountExport(s),/boolean/);
});
test('90-day boundary is explicit and never authorizes deletion',()=>{
 const cutoff=Date.parse(time)-90*86400000;const reports=[{id:owner,user_id:owner,created_at:new Date(cutoff).toISOString()},{id:other,user_id:owner,created_at:new Date(cutoff+1).toISOString()}];const plan=feedbackRetentionPlan({now:time,reports});assert.deepEqual(plan.due,[{report_id:owner,owner_id:owner}]);assert.equal(plan.dry_run,true);assert.equal(plan.deletion_authorized,false);assert.equal(plan.attachments_resolved,false);
});
test('ambiguous or impossible timestamps and duplicate inventory are rejected',()=>{
 assert.throws(()=>feedbackRetentionPlan({now:'2026-10-08',reports:[]}),/Timezone/);
 for(const now of ['2026-02-30T00:00:00Z','2026-02-29T00:00:00Z','2026-10-08T24:00:00Z','2026-10-08T00:00:00+24:00'])assert.throws(()=>feedbackRetentionPlan({now,reports:[]}),/Invalid timestamp/);
 assert.equal(feedbackRetentionPlan({now:'2024-02-29T00:00:00+01:00',reports:[]}).dry_run,true);
 const item={id:owner,user_id:owner,created_at:time};assert.throws(()=>feedbackRetentionPlan({now:time,reports:[item,item]}),/Invalid report/);
});
