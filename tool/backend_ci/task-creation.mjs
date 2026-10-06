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
const ok = (r, code = 200) => assert.equal(r.status, code,
  `Expected HTTP ${code}; received ${r.status} (${r.data?.code ?? 'no code'})`);
const denied = r => assert.ok([400,401,403,409].includes(r.status), `Expected denial; received ${r.status}`);
const signup = async () => {
  const r = await request('/auth/v1/signup', null, 'POST', {
    email: `create-ci-${randomUUID()}@example.test`, password: `Ci-${randomUUID()}-9!`,
  });
  ok(r); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
  return {id: r.data.user.id, token: r.data.access_token};
};
const payload = owner => ({p_request_id: randomUUID(), p_expected_user_id: owner.id,
  p_title: 'Synthetic retry quest', p_friction: 2});
const create = (owner, body) => request('/rest/v1/rpc/create_task_once', owner, 'POST', body);
const tasks = async owner => {
  const r = await request('/rest/v1/tasks', owner); ok(r); return r.data;
};
let checks = 0;
const check = async (name, action) => { await action(); checks++; console.log(`PASS creation: ${name}`); };

if (phase === 'baseline') {
  const owner = await signup();
  const body = {user_id: owner.id, title: 'Synthetic lost response', friction_level: 2, status: 'open'};
  // The first accepted response is deliberately discarded by the client.
  ok(await request('/rest/v1/tasks', owner, 'POST', body), 201);
  ok(await request('/rest/v1/tasks', owner, 'POST', body), 201);
  const rows = await tasks(owner);
  assert.equal(rows.length, 2, 'Baseline no longer reproduces the duplicate; reassess the fixture');
  assert.throws(() => assert.equal(rows.length, 1), assert.AssertionError);
  console.log('RED creation characterization: accepted-write/lost-response retry produced 2 quests; expected 1.');
} else if (phase === 'rollback') {
  const owner = await signup(), body = payload(owner);
  denied(await create(owner, body));
  assert.deepEqual(await tasks(owner), []);
  console.log('PASS creation: forced task failure leaves no quest');
  // The parent inspects the private ledger while the forced failure is installed.
} else if (phase === 'regressions') {
  await check('accepted write with discarded response reconciles to one quest', async () => {
    const owner = await signup(), body = payload(owner);
    ok(await create(owner, body)); // Ignore the accepted response.
    const retry = await create(owner, body); ok(retry);
    const rows = await tasks(owner); assert.equal(rows.length, 1);
    assert.equal(retry.data, rows[0].id);
    assert.equal(rows[0].xp_value, 20); assert.equal(rows[0].coin_value, 10);
  });
  await check('eight concurrent submissions serialize to the same server ID', async () => {
    const owner = await signup(), body = payload(owner);
    const replies = await Promise.all(Array.from({length:8}, () => create(owner, body)));
    replies.forEach(r => ok(r)); assert.equal(new Set(replies.map(r => r.data)).size, 1);
    assert.equal((await tasks(owner)).length, 1);
  });
  await check('different request IDs can intentionally create identical quests', async () => {
    const owner = await signup();
    ok(await create(owner, payload(owner))); ok(await create(owner, payload(owner)));
    assert.equal((await tasks(owner)).length, 2);
  });
  await check('changed retry payload is rejected without editing the accepted quest', async () => {
    const owner = await signup(), body = payload(owner); ok(await create(owner, body));
    denied(await create(owner, {...body, p_title:'Different draft'}));
    denied(await create(owner, {...body, p_friction:4}));
    const rows = await tasks(owner); assert.equal(rows.length, 1);
    assert.equal(rows[0].title, body.p_title); assert.equal(rows[0].friction_level, 2);
  });
  await check('retry cannot resurrect a deleted or completed quest or pay again', async () => {
    const owner = await signup(), body = payload(owner), first = await create(owner, body); ok(first);
    ok(await request('/rest/v1/rpc/complete_task', owner, 'POST', {p_task_id:first.data}));
    const retry = await create(owner, body); ok(retry); assert.equal(retry.data, first.data);
    assert.equal((await tasks(owner))[0].status, 'completed');
    ok(await request(`/rest/v1/tasks?id=eq.${first.data}`, owner, 'DELETE'));
    const afterDelete = await create(owner, body); ok(afterDelete); assert.equal(afterDelete.data, first.data);
    assert.deepEqual(await tasks(owner), []);
    const balance = await request('/rest/v1/users?select=total_xp,coin_balance', owner); ok(balance);
    assert.deepEqual(balance.data, [{total_xp:20,coin_balance:10}]);
  });
  await check('anonymous and switched-account requests cannot replay the draft', async () => {
    const owner = await signup(), other = await signup(), body = payload(owner);
    denied(await create(null, body)); denied(await create(other, body));
    ok(await create(owner, body)); denied(await create(other, body));
    assert.equal((await tasks(owner)).length, 1); assert.deepEqual(await tasks(other), []);
  });
  await check('revoked session and account deletion fence reject creation', async () => {
    const owner = await signup();
    const fence = await request('/rest/v1/rpc/begin_account_deletion', {token:status.SERVICE_ROLE_KEY}, 'POST', {p_user_id:owner.id});
    assert.ok([200,204].includes(fence.status)); denied(await create(owner, payload(owner)));
    const other = await signup();
    const logout = await request('/auth/v1/logout?scope=global', other, 'POST');
    assert.ok([200,204].includes(logout.status)); denied(await create(other, payload(other)));
  });
  await check('invalid inputs roll back; the same request can then succeed', async () => {
    const owner = await signup(), body = payload(owner);
    for (const bad of [{p_title:''},{p_title:null},{p_friction:0},{p_friction:null},{p_request_id:null},{p_expected_user_id:null}]) {
      denied(await create(owner, {...body,...bad}));
    }
    assert.deepEqual(await tasks(owner), []); ok(await create(owner, body));
    assert.equal((await tasks(owner)).length, 1);
  });
  await check('legacy direct inserts retain their existing contract', async () => {
    const owner = await signup();
    ok(await request('/rest/v1/tasks', owner, 'POST', {user_id:owner.id,title:'Legacy quest',
      status:'open',friction_level:3,xp_value:999,coin_value:999}), 201);
    const rows = await tasks(owner); assert.equal(rows[0].xp_value, 35); assert.equal(rows[0].coin_value, 18);
  });
  console.log(`Task creation: ${checks} passed.`);
} else throw new Error('Unknown creation test phase');
