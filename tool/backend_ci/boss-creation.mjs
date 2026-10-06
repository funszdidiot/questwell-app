import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const {status, phase = 'regressions'} = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
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
const ok = r => assert.equal(r.status, 200, `Expected HTTP 200; received ${r.status} (${r.data?.code ?? 'no code'})`);
const denied = r => assert.ok([400,401,403,409].includes(r.status), `Expected denial; received ${r.status}`);
const signup = async () => {
  const r = await request('/auth/v1/signup', null, 'POST', {
    email: `boss-create-ci-${randomUUID()}@example.test`, password: `Ci-${randomUUID()}-9!`,
  });
  ok(r); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
  return {id:r.data.user.id, token:r.data.access_token};
};
const payload = owner => ({p_request_id:randomUUID(), p_expected_user_id:owner.id,
  p_title:'Synthetic retry boss', p_steps:['First synthetic step','Second synthetic step'], p_boss_type:'inbox_hydra'});
const create = (owner, body) => request('/rest/v1/rpc/create_boss_once', owner, 'POST', body);
const rows = async (owner, table) => { const r = await request(`/rest/v1/${table}`, owner); ok(r); return r.data; };
const legacy = owner => request('/rest/v1/rpc/create_boss_battle', owner, 'POST', {
  p_title:'Legacy retry boss', p_steps:['First','Second'], p_boss_type:'inbox_hydra', p_reward_xp:999, p_reward_coins:999});
let checks = 0;
const check = async (name, action) => { await action(); checks++; console.log(`PASS boss creation: ${name}`); };
if (phase === 'baseline') {
  const owner = await signup(); ok(await legacy(owner)); ok(await legacy(owner));
  const bosses = await rows(owner, 'boss_battles');
  assert.equal(bosses.length, 2, 'Baseline changed; reassess duplicate characterization');
  assert.throws(() => assert.equal(bosses.length, 1), assert.AssertionError);
  console.log('RED boss creation: accepted-write/lost-response retry produced 2 bosses; expected 1.');
} else if (phase === 'rollback') {
  const owner = await signup(); denied(await create(owner, payload(owner)));
  assert.deepEqual(await rows(owner, 'boss_battles'), []);
  assert.deepEqual(await rows(owner, 'boss_steps'), []);
  console.log('PASS boss creation: forced failure leaves no boss or steps');
} else if (phase === 'regressions') {
  await check('lost response returns original boss with unchanged steps and rewards', async () => {
    const owner = await signup(), body = payload(owner); ok(await create(owner, body));
    const retry = await create(owner, body); ok(retry);
    const bosses = await rows(owner, 'boss_battles'), steps = await rows(owner, 'boss_steps');
    assert.equal(bosses.length, 1); assert.equal(bosses[0].id, retry.data);
    assert.equal(bosses[0].reward_xp, 25); assert.equal(bosses[0].reward_coins, 50);
    assert.equal(steps.length, 2); assert.ok(steps.every(s => s.boss_id === retry.data));
  });
  await check('eight concurrent retries return one boss and one set of steps', async () => {
    const owner = await signup(), body = payload(owner);
    const replies = await Promise.all(Array.from({length:8}, () => create(owner, body)));
    replies.forEach(ok); assert.equal(new Set(replies.map(r => r.data)).size, 1);
    assert.equal((await rows(owner, 'boss_battles')).length, 1);
    assert.equal((await rows(owner, 'boss_steps')).length, 2);
  });
  await check('new identities permit intentional identical battles', async () => {
    const owner = await signup(); ok(await create(owner, payload(owner))); ok(await create(owner, payload(owner)));
    assert.equal((await rows(owner, 'boss_battles')).length, 2);
  });
  await check('same identity with altered title, steps or type is rejected', async () => {
    const owner = await signup(), body = payload(owner); ok(await create(owner, body));
    for (const change of [{p_title:'Different'}, {p_steps:['Changed','Second']}, {p_boss_type:'meeting_mimic'}]) {
      denied(await create(owner, {...body,...change}));
    }
    assert.equal((await rows(owner, 'boss_battles')).length, 1);
    assert.equal((await rows(owner, 'boss_steps')).length, 2);
  });
  await check('completed boss replay does not recreate steps or pay again', async () => {
    const owner = await signup(), body = payload(owner), first = await create(owner, body); ok(first);
    for (const step of await rows(owner, 'boss_steps')) ok(await request('/rest/v1/rpc/complete_boss_step', owner, 'POST', {p_step_id:step.id}));
    const retry = await create(owner, body); ok(retry); assert.equal(retry.data, first.data);
    const bosses = await rows(owner, 'boss_battles'); assert.equal(bosses.length, 1); assert.equal(bosses[0].status, 'completed');
    const balance = await request('/rest/v1/users?select=total_xp,coin_balance', owner); ok(balance);
    assert.deepEqual(balance.data, [{total_xp:25,coin_balance:50}]);
  });
  await check('deleted boss is not resurrected by a delayed replay', async () => {
    const owner = await signup(), body = payload(owner), first = await create(owner, body); ok(first);
    ok(await request(`/rest/v1/boss_battles?id=eq.${first.data}`, {token:status.SERVICE_ROLE_KEY}, 'DELETE'));
    const retry = await create(owner, body); ok(retry); assert.equal(retry.data, first.data);
    assert.deepEqual(await rows(owner, 'boss_battles'), []); assert.deepEqual(await rows(owner, 'boss_steps'), []);
  });
  await check('anonymous and switched account calls cannot replay another owner', async () => {
    const owner = await signup(), other = await signup(), body = payload(owner);
    denied(await create(null, body)); denied(await create(other, body)); ok(await create(owner, body));
    denied(await create(other, body));
    ok(await create(other, {...body,p_expected_user_id:other.id}));
    assert.equal((await rows(owner, 'boss_battles')).length, 1);
    assert.equal((await rows(other, 'boss_battles')).length, 1);
  });
  await check('revoked session and deletion fence reject even a known receipt', async () => {
    const owner = await signup(), body = payload(owner); ok(await create(owner, body));
    const logout = await request('/auth/v1/logout?scope=global', owner, 'POST'); assert.ok([200,204].includes(logout.status));
    denied(await create(owner, body));
    const other = await signup(), otherBody = payload(other); ok(await create(other, otherBody));
    const fence = await request('/rest/v1/rpc/begin_account_deletion', {token:status.SERVICE_ROLE_KEY}, 'POST', {p_user_id:other.id});
    assert.ok([200,204].includes(fence.status)); denied(await create(other, otherBody)); denied(await create(other, payload(other)));
  });
  await check('invalid inputs and locked boss roll back identity for valid retry', async () => {
    const owner = await signup(), body = payload(owner);
    for (const bad of [{p_title:''},{p_steps:[]},{p_steps:['one',' ']},{p_boss_type:'update_dragon'},
      {p_boss_type:null},{p_request_id:null},{p_expected_user_id:null}]) denied(await create(owner, {...body,...bad}));
    assert.deepEqual(await rows(owner, 'boss_battles'), []); ok(await create(owner, body));
  });
  await check('legacy creation remains compatible with server rewards', async () => {
    const owner = await signup(); ok(await legacy(owner));
    const bosses = await rows(owner, 'boss_battles'); assert.equal(bosses[0].reward_xp, 25); assert.equal(bosses[0].reward_coins, 50);
  });
  console.log(`Boss creation: ${checks} passed.`);
} else throw new Error('Unknown boss creation phase');
