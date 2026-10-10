import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {preparePrivateExport,SyntheticPrivateDelivery,reviewedRetentionPlan,assertUnchangedRetentionPlan} from '../support/privacy_workflow.mjs';
const owner='10000000-0000-4000-8000-000000000001',other='10000000-0000-4000-8000-000000000002';
const report='10000000-0000-4000-8000-000000000003';
const now='2026-10-10T05:00:00Z',cutoff=new Date(Date.parse(now)-90*86400000).toISOString();
const bytes=Buffer.from('synthetic attachment'),path=owner+'/fixture.png';
const object={bucket:'beta-feedback',path,owner_id:owner,version:'synthetic-v1',size:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};
function fixture(){
 const tables=Object.fromEntries(['users','tasks','boss_battles','boss_steps','user_cosmetics','progression_events','reward_events','beta_feedback'].map(n=>[n,[]]));
 tables.users=[{...Object.fromEntries('id created_at email display_name level total_xp coin_balance current_energy_mode onboarding_completed adventurer_archetype avatar_body_type level_xp_offset'.split(' ').map(n=>[n,null])),id:owner,password:'must-not-export'}];
 tables.beta_feedback=[{...Object.fromEntries('id user_id created_at category goal message expected steps reply_email device screen build platform status attachment_path attachment_paths'.split(' ').map(n=>[n,null])),id:report,user_id:owner,created_at:cutoff,attachment_path:path,attachment_paths:[path],action_summary:'internal-only'}];
 return {snapshot:{verifiedOwnerId:owner,collectedAt:now,tables,complete:Object.fromEntries(Object.keys(tables).map(n=>[n,true]))},objects:[object],inventoryComplete:true,readObject:async()=>({version:object.version,bytes})};
}
function retention(){return {now,reports:fixture().snapshot.tables.beta_feedback,reportsComplete:true,objects:[object],objectsComplete:true,backupDispositionVerified:true};}
test('private delivery round trip includes attachment bytes without secrets',async()=>{
 const bundle=await preparePrivateExport(fixture());assert.equal(bundle.attachmentCount,1);
 const delivery=new SyntheticPrivateDelivery(()=>Date.parse(now));const ticket=delivery.issue(bundle);
 assert.throws(()=>delivery.redeem({token:ticket.token,authenticatedOwnerId:other}),/unavailable/);
 const result=delivery.redeem({token:ticket.token,authenticatedOwnerId:owner});
 const parsed=JSON.parse(result);assert.deepEqual(Buffer.from(parsed.attachments[0].data,'base64'),bytes);
 assert.ok(!result.includes('must-not-export'));assert.ok(!result.includes('internal-only'));
 assert.throws(()=>delivery.redeem({token:ticket.token,authenticatedOwnerId:owner}),/unavailable/);
});
test('delivery expires at exactly fifteen minutes',async()=>{
 let clock=Date.parse(now);const delivery=new SyntheticPrivateDelivery(()=>clock);
 const ticket=delivery.issue(await preparePrivateExport(fixture()));clock+=15*60*1000;
 assert.throws(()=>delivery.redeem({token:ticket.token,authenticatedOwnerId:owner}),/unavailable/);
});
test('cross-owner path and missing inventory reject before attachment read',async()=>{
 const f=fixture();f.readObject=async()=>{assert.fail('read called');};
 f.snapshot.tables.beta_feedback[0].attachment_paths=[other+'/secret.png'];
 await assert.rejects(preparePrivateExport(f),/Cross-owner/);
 const missing=fixture();missing.objects=[];await assert.rejects(preparePrivateExport(missing),/Missing owned/);
});
test('changed attachment version and checksum fail closed',async()=>{
 for(const response of [{version:'v2',bytes},{version:'synthetic-v1',bytes:Buffer.from('corrupt')}]){
 const f=fixture();f.readObject=async()=>response;await assert.rejects(preparePrivateExport(f),/integrity/);}
});
test('incomplete export and retention inventories fail closed',async()=>{
 const f=fixture();f.inventoryComplete=false;await assert.rejects(preparePrivateExport(f),/Complete/);
 assert.throws(()=>reviewedRetentionPlan({...retention(),reportsComplete:false}),/Complete/);
});
test('90 day boundary excludes newer reports and requires backup disposition',()=>{
 const input=retention();input.reports.push({...input.reports[0],id:other,created_at:new Date(Date.parse(cutoff)+1).toISOString(),attachment_path:null,attachment_paths:[]});
 const plan=reviewedRetentionPlan({...input,backupDispositionVerified:false});assert.equal(plan.candidates.length,1);
 assert.deepEqual(plan.candidates[0].blocks,['backup-disposition-unverified']);assert.equal(plan.deletionAuthorized,false);
});
test('shared retained references block deletion and inventory drift requires review',()=>{
 const input=retention();const reviewed=reviewedRetentionPlan(input);
 input.reports.push({...input.reports[0],id:other,created_at:now});
 const current=reviewedRetentionPlan(input);assert.ok(current.candidates[0].blocks.includes('referenced-by-retained-report'));
 assert.throws(()=>assertUnchangedRetentionPlan(reviewed,current),/changed/);
 assert.equal(assertUnchangedRetentionPlan(reviewed,reviewed).deletionAuthorized,false);
});
test('mismatched object ownership blocks and unresolved references reject',()=>{
 const input=retention();input.objects=[];assert.ok(reviewedRetentionPlan(input).candidates[0].blocks.includes('missing-or-mismatched-object'));
 delete input.reports[0].attachment_paths;assert.throws(()=>reviewedRetentionPlan(input),/Complete attachment/);
});
