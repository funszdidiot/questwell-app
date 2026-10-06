import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

// Characterizes a narrow real-app path; does not certify all app authorization.
async function appSmoke(status) {
  const request = async (path, token, method = 'GET', body) => {
    const response = await localRequest(status, path, {
      method,
      headers: {apikey: status.ANON_KEY, ...(token ? {authorization: `Bearer ${token}`} : {}),
        'content-type': 'application/json', Prefer: 'return=representation'},
      ...(body === undefined ? {} : {body: JSON.stringify(body)}),
    });
    return {status: response.status, data: await response.json()};
  };
  const ok = (r, code) => assert.equal(r.status, code, `Expected HTTP ${code}, received ${r.status}`);
  const signup = async () => {
    const r = await request('/auth/v1/signup', null, 'POST', {
      email: `app-ci-${randomUUID()}@example.test`, password: `Ci-${randomUUID()}-9!`,
    });
    ok(r, 200); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
    return {id: r.data.user.id, token: r.data.access_token};
  };
  let checks = 0;
  const check = async (name, action) => { await action(); checks++; console.log(`PASS app: ${name}`); };
  const a = await signup(), b = await signup();
  let taskA, taskB;
  await check('Auth trigger creates isolated profiles with zero balances', async () => {
    for (const owner of [a,b]) {
      const r = await request('/rest/v1/users?select=id,total_xp,coin_balance', owner.token);
      ok(r, 200); assert.deepEqual(r.data, [{id: owner.id, total_xp: 0, coin_balance: 0}]);
    }
  });
  await check('two owners create actual tasks and cannot read each other', async () => {
    for (const owner of [a,b]) {
      const r = await request('/rest/v1/tasks', owner.token, 'POST', {
        user_id: owner.id, title: 'Synthetic baseline quest', status: 'open', friction_level: 1, xp_value: 10, coin_value: 5,
      });
      ok(r, 201); assert.equal(r.data.length, 1);
      if (owner === a) taskA = r.data[0].id; else taskB = r.data[0].id;
      const read = await request('/rest/v1/tasks?select=id,user_id', owner.token);
      ok(read, 200); assert.deepEqual(read.data, [{id: r.data[0].id, user_id: owner.id}]);
    }
    const anon = await request('/rest/v1/tasks?select=id', null);
    ok(anon, 200); assert.deepEqual(anon.data, []);
  });
  await check('cross-owner completion is denied and leaves the task open', async () => {
    const r = await request('/rest/v1/rpc/complete_task', b.token, 'POST', {p_task_id: taskA});
    assert.ok([400,403].includes(r.status)); assert.equal(r.data.code, 'P0001');
    const read = await request(`/rest/v1/tasks?id=eq.${taskA}&select=status`, a.token);
    ok(read, 200); assert.deepEqual(read.data, [{status: 'open'}]);
  });
  await check('legitimate completion records exactly one reward and balance change', async () => {
    const r = await request('/rest/v1/rpc/complete_task', a.token, 'POST', {p_task_id: taskA});
    ok(r, 200); assert.deepEqual(r.data, [{task_id: taskA, xp_awarded: 10, coins_awarded: 5, total_xp: 10, coin_balance: 5}]);
    const again = await request('/rest/v1/rpc/complete_task', a.token, 'POST', {p_task_id: taskA});
    assert.ok([400,403].includes(again.status)); assert.equal(again.data.code, 'P0001');
    const ledger = await request(`/rest/v1/reward_events?task_id=eq.${taskA}&select=xp_amount,coin_amount`, a.token);
    ok(ledger, 200); assert.deepEqual(ledger.data, [{xp_amount: 10, coin_amount: 5}]);
    const other = await request(`/rest/v1/tasks?id=eq.${taskB}&select=status`, b.token);
    ok(other, 200); assert.deepEqual(other.data, [{status: 'open'}]);
    const balance = await request('/rest/v1/users?select=total_xp,coin_balance', a.token);
    ok(balance, 200); assert.deepEqual(balance.data, [{total_xp: 10, coin_balance: 5}]);
  });
  console.log(`Application baseline: ${checks} integration checks passed; reward-tampering/deletion/Storage coverage remains open.`);
}

// A fresh process cannot reuse HTTP sockets from before the database/API reset.
// Local credentials arrive only through stdin, never argv, files or CI logs.
assertDisposableCi(process.env);
const status = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
await appSmoke(status);
