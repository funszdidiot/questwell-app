import test from 'node:test';
import assert from 'node:assert/strict';
import {createDeleteAccountHandler} from '../../supabase/functions/delete-account/handler.mjs';
const request = (body = {confirmation:'DELETE'}, token = 'fixture-token', method = 'POST') =>
  new Request('https://example.invalid/delete-account', {method,
    headers: token ? {authorization:'Bearer '+token, 'Content-Type':'application/json'} : {},
    body: method === 'POST' ? JSON.stringify(body) : undefined});
test('requires POST, authentication, exact confirmation, and rejects a target ID', async () => {
  let called = 0;
  const handler = createDeleteAccountHandler({verifyUser: async()=>{ called++; return {id:'owner'}; }});
  assert.equal((await handler(request({}, '', 'POST'))).status,401);
  assert.equal((await handler(request({}, 'fixture-token', 'GET'))).status,405);
  assert.equal((await handler(request({confirmation:'delete'}))).status,400);
  assert.equal((await handler(request({confirmation:'DELETE',user_id:'victim'}))).status,400);
  assert.equal(called,0);
});
test('only verified owner can be deleted; sessions revoke first', async () => {
  const calls=[];
  const handler=createDeleteAccountHandler({
    verifyUser:async(token)=>{assert.equal(token,'fixture-token'); return {id:'verified-owner'};},
    revokeSessions:async()=>{calls.push('revoke');},
    deleteUser:async(id)=>{calls.push('delete:'+id);},
  });
  const response=await handler(request());
  assert.equal(response.status,200);
  assert.deepEqual(await response.json(),{deleted:true});
  assert.deepEqual(calls,['revoke','delete:verified-owner']);
});
test('invalid or deleted user never reaches deletion',async()=>{
  let called=false;
  const response=await createDeleteAccountHandler({
    verifyUser:async()=>null, deleteUser:async()=>{called=true;}
  })(request());
  assert.equal(response.status,401); assert.equal(called,false);
});
test('revocation failure stops deletion and server failures never claim success',async()=>{
  let called=false;
  const response=await createDeleteAccountHandler({
    verifyUser:async()=>({id:'owner'}),
    revokeSessions:async()=>{throw Error('private diagnostic');},
    deleteUser:async()=>{called=true;}
  })(request());
  assert.equal(response.status,503); assert.equal(called,false);
  assert.equal((await response.text()).includes('private diagnostic'),false);
});
