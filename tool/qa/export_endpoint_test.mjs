import test from 'node:test';
import assert from 'node:assert/strict';
import {createExportHandler} from '../../supabase/functions/export-account/handler.mjs';
import {createBackend,boundedBytes} from '../../supabase/functions/export-account/backend.mjs';
import {exportFields} from '../support/data_policy.mjs';
const id='10000000-0000-4000-8000-000000000001';
const other='10000000-0000-4000-8000-000000000002';
const row=(name,extra={})=>({...Object.fromEntries(exportFields[name].map(k=>[k,null])),...extra});
const snapshot=()=>({objects:[],collectedAt:'2026-10-10T05:00:00Z',complete:Object.fromEntries(Object.keys(exportFields).map(k=>[k,true])),tables:Object.fromEntries(Object.keys(exportFields).map(k=>[k,k==='users'?[row(k,{id,email:'test@example.invalid'})]:[]]))});
const request=(opts={})=>new Request('https://example.invalid/export-account',{method:'POST',headers:{authorization:'Bearer synthetic-token'},...opts});
function fixture(overrides={}){let reads=0; const backend={verifyUser:async()=>({id}),sessionAllowed:async()=>true,claimExport:async()=>true,collect:async()=>snapshot(),readAttachment:async()=>{reads++;return new Uint8Array([1,2,3]);},...overrides};return {handler:createExportHandler(()=>backend,{enabled:true,origins:['https://allowed.invalid']}),reads:()=>reads};}
test('authenticated direct download excludes secrets and has no-store attachment headers',async()=>{
 const {handler}=fixture();const res=await handler(request());assert.equal(res.status,200);assert.match(res.headers.get('cache-control'),/no-store/);assert.match(res.headers.get('content-disposition'),/attachment/);assert.equal((await res.json()).tables.users[0].id,id);
});
test('disabled, unauthenticated, anonymous and caller-controlled identity requests are denied',async()=>{
 assert.equal((await createExportHandler(()=>{throw Error('must not call');})(request())).status,503);
 assert.equal((await fixture().handler(request({headers:{}}))).status,401);
 assert.equal((await fixture({verifyUser:async()=>({id,is_anonymous:true})}).handler(request())).status,401);
 assert.equal((await fixture().handler(request({body:JSON.stringify({user_id:other})}))).status,400);
 assert.equal((await fixture().handler(request({headers:{authorization:'Bearer x',origin:'https://evil.invalid'}}))).status,403);
});
test('attachments round trip; all paths checked before any download',async()=>{
 const s=snapshot();s.tables.beta_feedback=[row('beta_feedback',{id:other,user_id:id,attachment_path:id+'/test.png',attachment_paths:[]})];
 s.objects=[{id:other,path:id+'/test.png',owner_id:id,version:'v1',etag:'tag1',size:3}];
 let f=fixture({collect:async()=>s});let res=await f.handler(request());assert.equal(res.status,200);assert.equal((await res.json()).attachments[0].data,'AQID');
 s.tables.beta_feedback[0].attachment_paths=[other+'/private.png'];f=fixture({collect:async()=>s});res=await f.handler(request());assert.equal(res.status,503);assert.equal(f.reads(),0);
});
test('changed records, authentication loss and upstream errors never deliver partial export',async()=>{
 let calls=0;let f=fixture({collect:async()=>{const s=snapshot();if(calls++)s.tables.users[0].display_name='changed';return s;}});assert.equal((await f.handler(request())).status,503);
 calls=0;f=fixture({verifyUser:async()=>calls++?null:{id}});assert.equal((await f.handler(request())).status,503);
 f=fixture({collect:async()=>{throw Error('private SQL secret');}});const res=await f.handler(request());assert.equal(res.status,503);assert.ok(!(await res.text()).includes('private SQL secret'));
});
test('bounded streaming rejects oversized announced and unannounced data',async()=>{
 await assert.rejects(()=>boundedBytes(new Response('12345'),4),/limit/);
 await assert.rejects(()=>boundedBytes(new Response('x',{headers:{'content-length':'9000'}}),4),/limit/);
 await assert.rejects(()=>boundedBytes(new Response('private',{status:403}),100),/failed/);
 assert.equal((await boundedBytes(new Response('1234'),4)).length,4);
});
test('snapshot RPC uses requester token, no owner parameter and rejects missing groups',async()=>{
 const calls=[];const backend=createBackend({url:'https://project.supabase.co',publicKey:'public',token:'caller',fetcher:async(url,options)=>{calls.push({url,options});return Response.json(snapshot());}});
 const s=await backend.collect(id);assert.equal(s.tables.users[0].id,id);
 assert.equal(calls.length,1);assert.equal(calls[0].url.pathname,'/rest/v1/rpc/account_export_snapshot');assert.equal(calls[0].options.body,'{}');assert.equal(calls[0].options.headers.Authorization,'Bearer caller');
 const missing=snapshot();delete missing.tables.tasks;
 const invalid=createBackend({url:'https://project.supabase.co',publicKey:'public',token:'caller',fetcher:async()=>Response.json(missing)});
 await assert.rejects(()=>invalid.collect(id),/Incomplete/);
});
test('download rejects changed ETag or size and accepts matching content',async()=>{
 for(const [etag,size,pass] of [['tag',3,true],['other',3,false],['tag',4,false]]){
 const backend=createBackend({url:'https://project.supabase.co',publicKey:'public',token:'caller',fetcher:async()=>new Response('abc',{headers:{etag}})});
 const operation=()=>backend.readAttachment(id+'/file.png',10,{etag:'tag',size});
 if(pass)assert.equal((await operation()).length,3);else await assert.rejects(operation,/changed/);
 }
});
test('revoked sessions and rate denial prevent collection; revocation during export prevents delivery',async()=>{
 let collected=0;
 for(const [overrides,status] of [[{sessionAllowed:async()=>false},401],[{claimExport:async()=>false},429]]){
 const f=fixture({...overrides,collect:async()=>{collected++;return snapshot();}});
 assert.equal((await f.handler(request())).status,status);
 }
 assert.equal(collected,0);
 let checks=0;const f=fixture({sessionAllowed:async()=>++checks===1});
 assert.equal((await f.handler(request())).status,503);assert.equal(checks,2);
});
test('guard RPCs use caller identity and deny non-boolean/error responses',async()=>{
 const calls=[];const backend=createBackend({url:'https://project.supabase.co',publicKey:'public',token:'caller',fetcher:async(url,options)=>{calls.push({url,options});return Response.json(true);}});
 assert.equal(await backend.sessionAllowed(),true);assert.equal(await backend.claimExport(),true);
 for(const {url,options} of calls){assert.match(url.pathname,/\/rest\/v1\/rpc\//);assert.equal(options.method,'POST');assert.equal(options.body,'{}');assert.equal(options.headers.Authorization,'Bearer caller');}
 const invalid=createBackend({url:'https://project.supabase.co',publicKey:'public',token:'caller',fetcher:async()=>Response.json('true')});assert.equal(await invalid.claimExport(),false);
});

test('Storage generation change during export prevents delivery',async()=>{
 let calls=0;const f=fixture({collect:async()=>{const s=snapshot();s.objects=[{id:other,path:id+'/file',owner_id:id,version:String(calls++),etag:'tag',size:3}];return s;}});
 assert.equal((await f.handler(request())).status,503);
});
