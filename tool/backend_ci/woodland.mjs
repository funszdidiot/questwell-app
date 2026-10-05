import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const status = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
const woodland = '10000000-0000-4000-8000-000000000001';
const everyday = '10000000-0000-4000-8000-000000000002';
const request = async (path, owner, method = 'GET', body) => {
  const response = await localRequest(status, path, {
    method, headers: {apikey: status.ANON_KEY,
      ...(owner ? {authorization: `Bearer ${owner.token}`} : {}),
      'content-type': 'application/json', Prefer: 'return=representation'},
    ...(body === undefined ? {} : {body: JSON.stringify(body)}),
  });
  const text = await response.text();
  return {status: response.status, data: text ? JSON.parse(text) : null};
};
const ok = (r, code = 200) => assert.equal(r.status, code,
  `Expected HTTP ${code}, received ${r.status} (${r.data?.code ?? 'no code'})`);
const denied = r => assert.ok([400,401,403].includes(r.status), `Expected rejection, received HTTP ${r.status}`);
const rpc = (owner, name, fields) => request(`/rest/v1/rpc/${name}`, owner, 'POST', fields);
const voidOk = r => assert.ok([200,204].includes(r.status), `Expected void success, received HTTP ${r.status}`);
const equip = (owner, id = woodland) => rpc(owner, 'equip_cosmetic_loadout', {p_cosmetic_id:id,p_expected_conflict:null});
const purchase = (owner, id = woodland) => rpc(owner, 'purchase_cosmetic', {p_cosmetic_id:id});
const profile = async owner => {
  const r = await request('/rest/v1/users?select=id,coin_balance,avatar_body_type,adventurer_archetype', owner);
  ok(r); assert.equal(r.data.length,1); return r.data[0];
};
const inventory = async owner => {
  const r = await request('/rest/v1/user_cosmetics?select=user_id,cosmetic_id,equipped&order=cosmetic_id',owner);
  ok(r); assert.ok(r.data.every(row=>row.user_id===owner.id)); return r.data;
};
const owned = async (owner, equipped, id = woodland) => {
  const rows = (await inventory(owner)).filter(row=>row.cosmetic_id===id);
  assert.deepEqual(rows,[{user_id:owner.id,cosmetic_id:id,equipped}]);
};
const signup = async (body = 'male', archetype = 'scout', coins = 500) => {
  const credentials = {email:`woodland-ci-${randomUUID()}@example.test`,password:`Ci-${randomUUID()}-9!`};
  const r = await request('/auth/v1/signup',null,'POST',credentials);
  ok(r); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
  const owner = {id:r.data.user.id,token:r.data.access_token,credentials};
  // Only synthetic profiles in the verified local stack receive fixture coins.
  const funding = await request(`/rest/v1/users?id=eq.${owner.id}`,
    {token:status.SERVICE_ROLE_KEY},'PATCH',{coin_balance:coins});
  ok(funding);
  voidOk(await rpc(owner,'set_adventurer_archetype',{p_archetype:archetype}));
  voidOk(await rpc(owner,'set_avatar_body_type',{p_body_type:body}));
  return owner;
};
let checks = 0;
const check = async (name, action) => { await action(); checks++; console.log(`PASS Woodland: ${name}`); };

for (const body of ['female','neutral','male']) {
  await check(`${body} Scout buys once, equips, reloads and unequips without losing ownership`,async()=>{
    const owner = await signup(body);
    const bought = await purchase(owner); ok(bought);
    assert.deepEqual(bought.data,[{cosmetic_id:woodland,remaining_coins:380,already_owned:false}]);
    const again = await purchase(owner); ok(again);
    assert.deepEqual(again.data,[{cosmetic_id:woodland,remaining_coins:380,already_owned:true}]);
    voidOk(await equip(owner)); await owned(owner,true);
    const login = await request('/auth/v1/token?grant_type=password',null,'POST',owner.credentials);
    ok(login); assert.equal(login.data.user.id,owner.id); assert.ok(login.data.access_token);
    const restored = {...owner,token:login.data.access_token};
    await owned(restored,true);
    assert.equal((await profile(restored)).avatar_body_type,body);
    assert.equal((await profile(restored)).coin_balance,380);
    voidOk(await rpc(restored,'unequip_cosmetic',{p_cosmetic_id:woodland}));
    await owned(restored,false);
    voidOk(await equip(restored)); await owned(restored,true);
  });
}
await check('simultaneous purchase retries create one ownership and one 120-coin debit',async()=>{
  const owner = await signup();
  const results = await Promise.all(Array.from({length:8},()=>purchase(owner)));
  results.forEach(r=>ok(r));
  assert.equal(results.filter(r=>!r.data[0].already_owned).length,1);
  assert.ok(results.every(r=>r.data[0].remaining_coins===380));
  await owned(owner,false);
  const ledger = await request('/rest/v1/reward_events?event_type=eq.cosmetic_purchase&select=coin_amount,xp_amount',owner);
  ok(ledger); assert.deepEqual(ledger.data,[{coin_amount:-120,xp_amount:0}]);
});
await check('body changes retain Woodland; class changes return it to owned inventory',async()=>{
  const owner = await signup(); ok(await purchase(owner)); voidOk(await equip(owner));
  for (const body of ['female','neutral','male']) {
    voidOk(await rpc(owner,'set_avatar_body_type',{p_body_type:body}));
    await owned(owner,true); assert.equal((await profile(owner)).avatar_body_type,body);
  }
  for (const archetype of ['scholar','alchemist','guardian','wanderer']) {
    voidOk(await rpc(owner,'set_adventurer_archetype',{p_archetype:archetype}));
    await owned(owner,false); denied(await equip(owner)); denied(await purchase(owner));
    assert.equal((await profile(owner)).coin_balance,380);
    assert.equal((await profile(owner)).avatar_body_type,'male');
    voidOk(await rpc(owner,'set_adventurer_archetype',{p_archetype:'scout'}));
    voidOk(await equip(owner)); await owned(owner,true);
  }
  for (const body of [null,'invalid']) denied(await rpc(owner,'set_avatar_body_type',{p_body_type:body}));
  await owned(owner,true); assert.equal((await profile(owner)).avatar_body_type,'male');
});
await check('Everyday and Woodland are mutually exclusive in the chest slot',async()=>{
  const owner = await signup(); ok(await purchase(owner)); ok(await purchase(owner,everyday));
  voidOk(await equip(owner,everyday)); await owned(owner,false); await owned(owner,true,everyday);
  voidOk(await equip(owner)); await owned(owner,true); await owned(owner,false,everyday);
  voidOk(await rpc(owner,'equip_cosmetic',{p_cosmetic_id:everyday}));
  await owned(owner,false); await owned(owner,true,everyday);
  assert.equal((await profile(owner)).coin_balance,340);
});
await check('non-Scout, insufficient funds, unowned and anonymous requests fail without writes',async()=>{
  const nonScout = await signup('male','scholar');
  const poor = await signup('male','scout',119);
  for (const owner of [nonScout,poor]) {
    denied(await purchase(owner)); denied(await equip(owner));
    denied(await rpc(owner,'equip_cosmetic',{p_cosmetic_id:woodland}));
    assert.deepEqual(await inventory(owner),[]);
  }
  assert.equal((await profile(nonScout)).coin_balance,500);
  assert.equal((await profile(poor)).coin_balance,119);
  denied(await purchase(null)); denied(await equip(null));
});
await check('RLS isolates ownership and direct forged inventory writes are denied',async()=>{
  const a = await signup(), b = await signup(); ok(await purchase(a)); voidOk(await equip(a));
  const foreign = await request(`/rest/v1/user_cosmetics?user_id=eq.${a.id}`,b);
  ok(foreign); assert.deepEqual(foreign.data,[]);
  for (const user_id of [a.id,b.id]) {
    denied(await request('/rest/v1/user_cosmetics',b,'POST',{user_id,cosmetic_id:woodland,equipped:true}));
  }
  denied(await request(`/rest/v1/user_cosmetics?user_id=eq.${a.id}`,b,'PATCH',{equipped:false}));
  denied(await rpc(b,'unequip_cosmetic',{p_cosmetic_id:woodland}));
  await owned(a,true); assert.deepEqual(await inventory(b),[]);
});
console.log(`Woodland rollout: ${checks} Auth/RPC/persistence integration checks passed; no live accounts touched.`);
