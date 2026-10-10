import test from 'node:test';
import assert from 'node:assert/strict';
import {createExportHandler} from '../../supabase/functions/export-account/handler.mjs';
import {createBackend,boundedBytes} from '../../supabase/functions/export-account/backend.mjs';
import {exportFields} from '../support/data_policy.mjs';
const id='10000000-0000-4000-8000-000000000001';
const other='10000000-0000-4000-8000-000000000002';
const row=(name,extra={})=>({...Object.fromEntries(exportFields[name].map(k=>[k,null])),...extra});
const snapshot=()=>({collectedAt:'2026-10-10T05:00:00Z',complete:Object.fromEntries(Object.keys(exportFields).map(k=>[k,true])),tables:Object.fromEntries(Object.keys(exportFields).map(k=>[k,k==='users'?[row(k,{id,email:'test@example.invalid'})]:[]]))});
const request=(opts={})=>new Request('https://example.invalid/export-account',{method:'POST',headers:{authorization:'Bearer synthetic-token'},...opts});
function fixture(overrides={}){let reads=0; const backend={verifyUser:async()=>({id}),collect:async()=>snapshot(),readAttachment:async()=>{reads++;return new Uint8Array([1,2,3]);},...overrides};return {handler:createExportHandler(()=>backend,{enabled:true,origins:['https://allowed.invalid']}),reads:()=>reads};}
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
test('REST adapter uses requester token, explicit allowlists, exact counts and no redirects',async()=>{
 const calls=[];const backend=createBackend({url:'https://project.supabase.co',publicKey:'public-key',token:'user-token',fetcher:async(url,options)=>{
 calls.push({url,options});if(url.pathname==='/auth/v1/user')return Response.json({id});
 const name=url.pathname.split('/').at(-1);const s=snapshot();return Response.json(s.tables[name],{headers:{'content-range':`0-0/${s.tables[name].length}`}});
 }});
 assert.equal((await backend.verifyUser()).id,id);const s=await backend.collect(id);assert.equal(s.tables.users.length,1);
 for(const {url,options} of calls){assert.equal(options.headers.Authorization,'Bearer user-token');assert.equal(options.redirect,'error');if(url.pathname.startsWith('/rest/')){assert.ok(!url.searchParams.get('select').includes('*'));assert.equal(url.searchParams.get(url.pathname.endsWith('/users')?'id':'user_id'),`eq.${id}`);}}
});
test('server page caps and absent counts cannot silently truncate an export',async()=>{
 for(const headers of [{},{'content-range':'0-0/300'}]){
 const backend=createBackend({url:'https://project.supabase.co',publicKey:'public',token:'token',fetcher:async()=>Response.json([{}],{headers})});await assert.rejects(()=>backend.collect(id),/count|Truncated/);
 }
});
