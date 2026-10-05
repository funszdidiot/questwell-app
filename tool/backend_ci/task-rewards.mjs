import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const {status, phase = 'regressions'} = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
const request = async (path, owner, method = 'GET', body) => {
  const response = await localRequest(status, path, {
    method,
    headers: {apikey: status.ANON_KEY, ...(owner ? {authorization: `Bearer ${owner.token}`} : {}),
      'content-type': 'application/json', Prefer: 'return=representation'},
    ...(body === undefined ? {} : {body: JSON.stringify(body)}),
  });
  const text = await response.text();
  return {status: response.status, data: text ? JSON.parse(text) : null};
};
const ok = (r, code = 200) => assert.equal(r.status, code, `Expected HTTP ${code}, received ${r.status} (${r.data?.code ?? 'no code'})`);
const denied = r => assert.ok([400,401,403].includes(r.status), `Expected rejection, received HTTP ${r.status}`);
const signup = async () => {
  const r = await request('/auth/v1/signup', null, 'POST', {
    email: `rewards-ci-${randomUUID()}@example.test`, password: `Ci-${randomUUID()}-9!`,
  });
  ok(r); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
  return {id: r.data.user.id, token: r.data.access_token};
};
const create = async (owner, fields = {}) => {
  const r = await request('/rest/v1/tasks', owner, 'POST', {
    user_id: owner.id, title: 'Synthetic reward quest', status: 'open',
    friction_level: 1, xp_value: 10, coin_value: 5, ...fields,
  });
  ok(r, 201); assert.equal(r.data.length, 1); return r.data[0];
};
const patch = (owner, task, fields) => request(`/rest/v1/tasks?id=eq.${task.id}`, owner, 'PATCH', fields);
const complete = (owner, task) => request('/rest/v1/rpc/complete_task', owner, 'POST', {p_task_id: task.id});
const readTask = async (owner, task) => {
  const r = await request(`/rest/v1/tasks?id=eq.${task.id}`, owner); ok(r); return r.data[0];
};
const balance = async (owner, xp, coins) => {
  const r = await request('/rest/v1/users?select=total_xp,coin_balance', owner);
  ok(r); assert.deepEqual(r.data, [{total_xp: xp, coin_balance: coins}]);
};
const ledger = async (owner, task, expected) => {
  const r = await request(`/rest/v1/reward_events?task_id=eq.${task.id}&select=xp_amount,coin_amount`, owner);
  ok(r); assert.deepEqual(r.data, expected);
};
let checks = 0, failures = 0;
const check = async (name, action) => {
  try { await action(); checks++; console.log(`PASS rewards: ${name}`); }
  catch (error) { failures++; console.error(`FAIL rewards: ${name}: ${error.message}`); }
};

if (phase === 'rollback') {
  await check('failed downstream write rolls back task, ledger and balance together', async () => {
    const owner = await signup(), task = await create(owner);
    denied(await complete(owner, task));
    const after = await readTask(owner, task);
    assert.equal(after.status, 'open'); assert.equal(after.completed_at, null);
    await ledger(owner, task, []); await balance(owner, 0, 0);
  });
} else if (phase === 'regressions') {
  for (const [friction, xp, coins] of [[1,10,5],[2,20,10],[3,35,18],[4,60,30]]) {
    await check(`approved tier ${friction} pays ${xp} XP / ${coins} coins once`, async () => {
      const owner = await signup(), task = await create(owner, {friction_level: friction, xp_value: xp, coin_value: coins});
      ok(await complete(owner, task)); denied(await complete(owner, task));
      await balance(owner, xp, coins); await ledger(owner, task, [{xp_amount: xp, coin_amount: coins}]);
    });
  }
  await check('insert cannot choose inflated, negative, null or zero rewards', async () => {
    const owner = await signup();
    for (const value of [2147483647, -900, null, 0]) {
      const task = await create(owner, {xp_value: value, coin_value: value});
      assert.equal(task.xp_value, 10); assert.equal(task.coin_value, 5);
      ok(await complete(owner, task));
      await ledger(owner, task, [{xp_amount: 10, coin_amount: 5}]);
    }
    await balance(owner, 40, 20);
  });
  await check('edit uses the approved difficulty mapping and ignores forged rewards', async () => {
    const owner = await signup(), task = await create(owner);
    ok(await patch(owner, task, {title: 'Edited synthetic quest', friction_level: 3, xp_value: 999999, coin_value: -20}));
    const edited = await readTask(owner, task);
    assert.equal(edited.title, 'Edited synthetic quest'); assert.equal(edited.xp_value, 35); assert.equal(edited.coin_value, 18);
    ok(await complete(owner, task)); await balance(owner, 35, 18);
  });
  await check('older forged reward columns cannot control the completion payout', async () => {
    const owner = await signup();
    // Only the disposable stack's server key seeds a pre-fix compromised row.
    const task = await create({id:owner.id,token:status.SERVICE_ROLE_KEY},
      {friction_level:2,xp_value:999999,coin_value:999999});
    assert.equal(task.xp_value,999999);
    ok(await complete(owner,task)); await balance(owner,20,10);
    await ledger(owner,task,[{xp_amount:20,coin_amount:10}]);
  });
  await check('a historical paid quest reopened before hardening cannot pay again', async () => {
    const owner = await signup(), task = await create(owner); ok(await complete(owner,task));
    ok(await patch({id:owner.id,token:status.SERVICE_ROLE_KEY},task,{status:'open'}));
    denied(await complete(owner,task)); await balance(owner,10,5);
    await ledger(owner,task,[{xp_amount:10,coin_amount:5}]);
  });
  await check('invalid difficulty cannot be inserted or edited', async () => {
    const owner = await signup(), task = await create(owner);
    for (const friction of [null,0,-1,5]) {
      denied(await request('/rest/v1/tasks', owner, 'POST', {user_id: owner.id, status: 'open', friction_level: friction}));
      denied(await patch(owner, task, {friction_level: friction}));
    }
    assert.equal((await readTask(owner, task)).friction_level, 1); await balance(owner, 0, 0);
  });
  await check('direct completion, forged completion time and invalid states are denied', async () => {
    const owner = await signup(), task = await create(owner);
    for (const state of ['completed','anything',null]) {
      denied(await request('/rest/v1/tasks', owner, 'POST', {user_id: owner.id, status: state, friction_level: 1}));
      denied(await patch(owner, task, {status: state}));
    }
    denied(await patch(owner, task, {completed_at: new Date().toISOString()}));
    assert.equal((await readTask(owner, task)).status, 'open'); await balance(owner, 0, 0);
  });
  await check('completed quests cannot reopen or mutate payout history', async () => {
    const owner = await signup(), task = await create(owner); ok(await complete(owner, task));
    for (const fields of [{status:'open'}, {status:'set_aside'}, {friction_level:4}, {xp_value:900}, {title:'Forged history'}]) {
      denied(await patch(owner, task, fields));
    }
    denied(await complete(owner, task)); await balance(owner, 10, 5);
    await ledger(owner, task, [{xp_amount:10,coin_amount:5}]);
  });
  await check('set-aside, restore and pin preserve legitimate quest behavior', async () => {
    const owner = await signup(), task = await create(owner);
    const pinned = await request('/rest/v1/rpc/set_pinned_quest', owner, 'POST', {p_task_id:task.id});
    assert.ok([200,204].includes(pinned.status));
    ok(await patch(owner, task, {status:'set_aside'})); denied(await complete(owner, task));
    ok(await patch(owner, task, {status:'open'})); ok(await complete(owner, task)); await balance(owner,10,5);
  });
  await check('Chronicle repeat creates a fresh open quest without an immediate payout', async () => {
    const owner = await signup(), task = await create(owner); ok(await complete(owner,task));
    const original = await readTask(owner,task);
    const copy = await create(owner,{title:original.title,friction_level:original.friction_level,xp_value:original.xp_value,coin_value:original.coin_value});
    assert.notEqual(copy.id,task.id); assert.equal(copy.status,'open'); await balance(owner,10,5);
    ok(await complete(owner,copy)); await balance(owner,20,10);
  });
  await check('simultaneous and repeated completion requests award exactly once', async () => {
    const owner = await signup(), task = await create(owner);
    const responses = await Promise.all(Array.from({length:8},()=>complete(owner,task)));
    assert.equal(responses.filter(r=>r.status===200).length,1);
    responses.filter(r=>r.status!==200).forEach(denied);
    await balance(owner,10,5); await ledger(owner,task,[{xp_amount:10,coin_amount:5}]);
  });
  await check('simultaneous different quests preserve both balance increments', async () => {
    const owner = await signup(), a = await create(owner), b = await create(owner);
    (await Promise.all([complete(owner,a),complete(owner,b)])).forEach(r=>ok(r));
    await balance(owner,20,10);
  });
  await check('delete then ID reuse and identity changes cannot repeat a payout', async () => {
    const owner = await signup(), task = await create(owner); ok(await complete(owner,task));
    ok(await request(`/rest/v1/tasks?id=eq.${task.id}`,owner,'DELETE'));
    denied(await request('/rest/v1/tasks',owner,'POST',{id:task.id,user_id:owner.id,status:'open',friction_level:1}));
    const other = await create(owner); denied(await patch(owner,other,{id:task.id}));
    await balance(owner,10,5);
  });
  await check('anonymous and other-owner writes cannot affect a quest or balance', async () => {
    const owner = await signup(), other = await signup(), task = await create(owner);
    denied(await complete(null,task)); denied(await complete(other,task));
    denied(await request('/rest/v1/tasks',null,'POST',{user_id:owner.id,status:'open',friction_level:1}));
    denied(await request('/rest/v1/tasks',other,'POST',{user_id:owner.id,status:'open',friction_level:1}));
    const edit = await patch(other,task,{status:'set_aside'}); ok(edit); assert.deepEqual(edit.data,[]);
    const remove = await request(`/rest/v1/tasks?id=eq.${task.id}`,other,'DELETE'); ok(remove); assert.deepEqual(remove.data,[]);
    assert.equal((await readTask(owner,task)).status,'open'); await balance(owner,0,0); await balance(other,0,0);
  });
  await check('direct reward-ledger writes cannot forge or erase a reward', async () => {
    const owner = await signup(), task = await create(owner); ok(await complete(owner,task));
    denied(await request('/rest/v1/reward_events',owner,'POST',{user_id:owner.id,task_id:task.id,event_type:'task_completed',xp_amount:999,coin_amount:999}));
    for (const method of ['PATCH','DELETE']) {
      const r = await request(`/rest/v1/reward_events?task_id=eq.${task.id}`,owner,method,method==='PATCH'?{xp_amount:999}:undefined);
      if (r.status===200) assert.deepEqual(r.data,[]); else denied(r);
    }
    await ledger(owner,task,[{xp_amount:10,coin_amount:5}]); await balance(owner,10,5);
  });
} else { throw new Error('Unknown reward test phase'); }
console.log(`Task rewards: ${checks} passed; ${failures} failed (${phase}).`);
if (failures) process.exitCode = 1;
