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
    beginDeletion:async(id)=>{calls.push('fence:'+id);},
    revokeSessions:async()=>{calls.push('revoke');},
    listOwnedObjects:async()=>[],
    deleteUser:async(id)=>{calls.push('delete:'+id);},
  });
  const response=await handler(request());
  assert.equal(response.status,200);
  assert.deepEqual(await response.json(),{deleted:true});
  assert.deepEqual(calls,['fence:verified-owner','revoke','delete:verified-owner']);
});
test('failed upload fence stops revocation and deletion',async()=>{
  let mutated=false;
  const response=await createDeleteAccountHandler({
    verifyUser:async()=>({id:'owner'}),
    beginDeletion:async()=>{throw Error('private lock timeout');},
    revokeSessions:async()=>{mutated=true;},deleteUser:async()=>{mutated=true;}
  })(request());
  assert.equal(response.status,503);assert.equal(mutated,false);
  assert.equal((await response.text()).includes('private lock'),false);
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
    beginDeletion:async()=>{},
    deleteUser:async()=>{called=true;}
  })(request());
  assert.equal(response.status,503); assert.equal(called,false);
  assert.equal((await response.text()).includes('private diagnostic'),false);
});

test('cleans owned pages after revocation and before deleting the verified account', async () => {
  const calls=[];
  let pages=0;
  const handler=createDeleteAccountHandler({
    verifyUser:async()=>({id:'owner'}),
    revokeSessions:async()=>{calls.push('revoke');},
    beginDeletion:async()=>{calls.push('fence');},
    listOwnedObjects:async(id)=>{assert.equal(id,'owner'); calls.push('list'); return pages++ < 2 ? [{bucket_id:'bucket',name:`nested/${pages}.png`,owner_id:id}] : [];},
    removeOwnedObjects:async(id,bucket,names)=>{assert.equal(id,'owner'); assert.equal(bucket,'bucket'); calls.push('remove:'+names[0]);},
    deleteUser:async(id)=>{calls.push('delete:'+id);},
  });
  assert.equal((await handler(request())).status,200);
  assert.deepEqual(calls,['fence','revoke','list','remove:nested/1.png','list','remove:nested/2.png','list','delete:owner']);
});
test('partial Storage failure preserves Auth and a fresh retry resumes the first remaining page',async()=>{
  let files=['a.png','b.png'], removed=[], deletes=0, failure=true;
  const handler=createDeleteAccountHandler({
    verifyUser:async()=>({id:'owner'}), beginDeletion:async()=>{}, revokeSessions:async()=>{},
    listOwnedObjects:async()=>files.slice(0,1).map(name=>({bucket_id:'bucket',name,owner_id:'owner'})),
    removeOwnedObjects:async(id,bucket,names)=>{
      if(names[0]==='b.png'&&failure)throw Error('private bucket contents and token');
      removed.push(...names); files=files.filter(name=>!names.includes(name));
    },
    deleteUser:async()=>{deletes++;},
  });
  const first=await handler(request());
  assert.equal(first.status,503); assert.equal(deletes,0); assert.deepEqual(files,['b.png']);
  assert.equal((await first.text()).includes('private bucket'),false);
  failure=false;
  assert.equal((await handler(request())).status,200);
  assert.deepEqual(removed,['a.png','b.png']); assert.equal(deletes,1);
});
test('cleanup is bounded and never deletes Auth when files remain',async()=>{
  let lists=0, removals=0, deletes=0;
  const handler=createDeleteAccountHandler({
    verifyUser:async()=>({id:'owner'}), beginDeletion:async()=>{}, revokeSessions:async()=>{},
    listOwnedObjects:async()=>{lists++;return [{bucket_id:'bucket',name:`${lists}.png`,owner_id:'owner'}];},
    removeOwnedObjects:async()=>{removals++;}, deleteUser:async()=>{deletes++;},
  });
  assert.equal((await handler(request())).status,503);
  assert.ok(removals>0&&removals<=10); assert.ok(lists<=11); assert.equal(deletes,0);
});
test('untrusted inventory or a different owner fails closed before removal',async()=>{
  for(const rows of [null, [{bucket_id:'bucket',name:'victim.png',owner_id:'victim'}],
    [{bucket_id:'bucket',name:'',owner_id:'owner'}], Array.from({length:101},(_,i)=>({bucket_id:'bucket',name:`${i}`,owner_id:'owner'}))]){
    let writes=0;
    const handler=createDeleteAccountHandler({verifyUser:async()=>({id:'owner'}),beginDeletion:async()=>{},revokeSessions:async()=>{},
      listOwnedObjects:async()=>rows,removeOwnedObjects:async()=>{writes++;},deleteUser:async()=>{writes++;}});
    assert.equal((await handler(request())).status,503);assert.equal(writes,0);
  }
});
test('an Auth failure after cleanup remains an unconfirmed deletion',async()=>{
  let count=0;
  const handler=createDeleteAccountHandler({verifyUser:async()=>({id:'owner'}),beginDeletion:async()=>{},revokeSessions:async()=>{},
    listOwnedObjects:async()=>count++ ? [] : [{bucket_id:'bucket',name:'a.png',owner_id:'owner'}],
    removeOwnedObjects:async()=>{},deleteUser:async()=>{throw Error('private Auth diagnostic');}});
  const response=await handler(request()); assert.equal(response.status,503);
  assert.equal((await response.text()).includes('private Auth'),false);
});
