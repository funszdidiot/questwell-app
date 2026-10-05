import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const {status, phase = 'regressions'} = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
const request = async (path, owner, method = 'GET', body, headers = {}) => {
  const response = await localRequest(status, path, {
    method,
    headers: {apikey: status.ANON_KEY,
      ...(owner ? {authorization: `Bearer ${owner.token}`} : {}),
      'content-type': 'application/json', Prefer: 'return=representation', ...headers},
    ...(body === undefined ? {} : {body: JSON.stringify(body)}),
  });
  const text = await response.text();
  return {status: response.status, data: text ? JSON.parse(text) : null};
};
const ok = (r, code = 200) => assert.equal(r.status, code,
  `Expected HTTP ${code}, received ${r.status} (${r.data?.code ?? 'no code'})`);
const denied = r => assert.ok([400, 401, 403, 409].includes(r.status),
  `Expected rejection, received HTTP ${r.status}`);
const deniedOrNoRows = r => r.status === 200 ? assert.deepEqual(r.data, []) : denied(r);
const admin = {token: status.SERVICE_ROLE_KEY}; // Disposable fixtures only.
const signup = async () => {
  const r = await request('/auth/v1/signup', null, 'POST', {
    email: `boss-ci-${randomUUID()}@example.test`, password: `Ci-${randomUUID()}-9!`,
  });
  ok(r); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
  return {id: r.data.user.id, token: r.data.access_token};
};
const createRequest = (owner, fields = {}) => request('/rest/v1/rpc/create_boss_battle', owner, 'POST', {
  p_title: 'Synthetic boss', p_steps: ['First step', 'Final step'],
  p_reward_xp: 25, p_reward_coins: 50, p_boss_type: 'inbox_hydra', ...fields,
});
const readBoss = async (owner, id) => {
  const r = await request(`/rest/v1/boss_battles?id=eq.${id}`, owner);
  ok(r); assert.equal(r.data.length, 1); return r.data[0];
};
const steps = async (owner, id) => {
  const r = await request(`/rest/v1/boss_steps?boss_id=eq.${id}&order=position`, owner);
  ok(r); return r.data;
};
const create = async (owner, fields = {}) => {
  const r = await createRequest(owner, fields); ok(r); assert.equal(typeof r.data, 'string');
  return {id: r.data, steps: await steps(owner, r.data)};
};
const complete = (owner, step) => request('/rest/v1/rpc/complete_boss_step', owner, 'POST', {p_step_id: step.id});
const balance = async (owner, xp, coins) => {
  const r = await request('/rest/v1/users?select=total_xp,coin_balance', owner);
  ok(r); assert.deepEqual(r.data, [{total_xp: xp, coin_balance: coins}]);
};
const ledger = async (owner, expected) => {
  const r = await request('/rest/v1/reward_events?event_type=eq.boss_battle_completed&select=xp_amount,coin_amount&order=created_at', owner);
  ok(r); assert.deepEqual(r.data, expected);
};
const finish = async (owner, boss, xp = 25, coins = 50) => {
  for (let i = 0; i < boss.steps.length; i++) {
    const r = await complete(owner, boss.steps[i]); ok(r);
    const last = i === boss.steps.length - 1;
    assert.deepEqual(r.data, [{boss_completed: last, xp_awarded: last ? xp : 0,
      coins_awarded: last ? coins : 0, total_xp: last ? xp : 0, coin_balance: last ? coins : 0}]);
  }
  const row = await readBoss(owner, boss.id);
  assert.equal(row.status, 'completed'); assert.ok(row.completed_at);
  assert.ok((await steps(owner, boss.id)).every(s => s.completed && s.completed_at));
  await balance(owner, xp, coins); await ledger(owner, [{xp_amount: xp, coin_amount: coins}]);
};
let checks = 0, failures = 0;
const check = async (name, action) => {
  try { await action(); checks++; console.log(`PASS bosses: ${name}`); }
  catch (error) { failures++; console.error(`FAIL bosses: ${name}: ${error.message}`); }
};

if (phase === 'rollback') {
  await check('failed victory write rolls back final step, battle, ledger and balance', async () => {
    const owner = await signup(), boss = await create(owner);
    ok(await complete(owner, boss.steps[0]));
    denied(await complete(owner, boss.steps[1]));
    const row = await readBoss(owner, boss.id), after = await steps(owner, boss.id);
    assert.equal(row.status, 'open'); assert.equal(row.completed_at, null);
    assert.equal(after[0].completed, true);
    assert.equal(after[1].completed, false); assert.equal(after[1].completed_at, null);
    await balance(owner, 0, 0); await ledger(owner, []);
  });
} else if (phase === 'regressions') {
  for (const count of [2, 5, 20]) {
    await check(`${count} steps pay the existing caller 25 XP / 50 coins exactly once`, async () => {
      const owner = await signup(), boss = await create(owner, {
        p_steps: Array.from({length: count}, (_, i) => `Synthetic step ${i}`),
      });
      const row = await readBoss(owner, boss.id);
      assert.equal(row.reward_xp, 25); assert.equal(row.reward_coins, 50);
      assert.equal(boss.steps.length, count);
      await finish(owner, boss); denied(await complete(owner, boss.steps.at(-1)));
      await balance(owner, 25, 50); await ledger(owner, [{xp_amount: 25, coin_amount: 50}]);
    });
  }
  for (const [name, value] of [['omitted', undefined], ['null', null],
    ['inflated', 2147483647], ['negative', -100], ['zero', 0], ['smaller', 10]]) {
    await check(`${name} caller rewards still create and pay the fixed server reward`, async () => {
      const owner = await signup(), boss = await create(owner, {p_reward_xp: value, p_reward_coins: value});
      const row = await readBoss(owner, boss.id);
      assert.equal(row.reward_xp, 25); assert.equal(row.reward_coins, 50);
      await finish(owner, boss);
    });
  }
  await check('partial progress and retried nonfinal steps do not pay a reward', async () => {
    const owner = await signup(), boss = await create(owner);
    ok(await complete(owner, boss.steps[0])); denied(await complete(owner, boss.steps[0]));
    assert.equal((await readBoss(owner, boss.id)).status, 'open');
    await balance(owner, 0, 0); await ledger(owner, []);
    ok(await complete(owner, boss.steps[1])); await balance(owner, 25, 50);
  });
  await check('all eight level gates and existing boss types are preserved', async () => {
    const owner = await signup();
    for (const [type, level] of [['inbox_hydra',1], ['meeting_mimic',3],
      ['spreadsheet_slime',5], ['calendar_kraken',7], ['printer_poltergeist',10],
      ['notification_swarm',13], ['ticket_troll',16], ['update_dragon',20]]) {
      if (level > 1) {
        ok(await request(`/rest/v1/users?id=eq.${owner.id}`, admin, 'PATCH', {level: level - 1}));
        denied(await createRequest(owner, {p_boss_type: type}));
      }
      ok(await request(`/rest/v1/users?id=eq.${owner.id}`, admin, 'PATCH', {level}));
      const boss = await create(owner, {p_boss_type: type});
      assert.equal((await readBoss(owner, boss.id)).boss_type, type);
    }
    await balance(owner, 0, 0); await ledger(owner, []);
  });
  await check('invalid creation rolls back without leaving a battle or steps', async () => {
    const owner = await signup();
    for (const fields of [{p_title: null}, {p_title: '  '}, {p_steps: null},
      {p_steps: []}, {p_steps: ['One']}, {p_steps: [' ', null]}, {p_boss_type: 'unknown'}]) {
      denied(await createRequest(owner, fields));
    }
    for (const table of ['boss_battles', 'boss_steps']) {
      const r = await request(`/rest/v1/${table}`, owner); ok(r); assert.deepEqual(r.data, []);
    }
    await balance(owner, 0, 0); await ledger(owner, []);
  });
  await check('another owner cannot read or complete a battle', async () => {
    const owner = await signup(), other = await signup(), boss = await create(owner);
    for (const table of ['boss_battles', 'boss_steps']) {
      const r = await request(`/rest/v1/${table}`, other); ok(r); assert.deepEqual(r.data, []);
    }
    denied(await complete(other, boss.steps[0]));
    assert.ok((await steps(owner, boss.id)).every(s => !s.completed));
    await balance(owner, 0, 0); await balance(other, 0, 0);
  });
  await check('direct REST cannot forge rewards, ownership, completion or ledger entries', async () => {
    const owner = await signup(), boss = await create(owner);
    for (const caller of [owner, null]) {
      denied(await request('/rest/v1/boss_battles', caller, 'POST', {
        user_id: owner.id, title: 'Forged', reward_xp: 999999, reward_coins: 999999,
      }));
      deniedOrNoRows(await request(`/rest/v1/boss_battles?id=eq.${boss.id}`, caller, 'PATCH',
        {reward_coins: 999999, status: 'completed', user_id: randomUUID()}));
      deniedOrNoRows(await request(`/rest/v1/boss_steps?id=eq.${boss.steps[0].id}`, caller, 'PATCH', {completed: true}));
      denied(await request('/rest/v1/reward_events', caller, 'POST', {
        user_id: owner.id, event_type: 'boss_battle_completed', xp_amount: 999999, coin_amount: 999999,
      }));
    }
    const row = await readBoss(owner, boss.id);
    assert.equal(row.status, 'open'); assert.equal(row.reward_coins, 50); assert.equal(row.user_id, owner.id);
    assert.ok((await steps(owner, boss.id)).every(s => !s.completed));
    await balance(owner, 0, 0); await ledger(owner, []);
  });
  await check('anonymous RPCs fail and the private schema is not exposed over REST', async () => {
    const owner = await signup(), boss = await create(owner);
    denied(await createRequest(null)); denied(await complete(null, boss.steps[0]));
    const r = await request('/rest/v1/rpc/create_boss_battle', owner, 'POST',
      {p_title: 'Private attempt', p_steps: ['One', 'Two'], p_reward_coins: 999999},
      {'Content-Profile': 'private'});
    assert.equal(r.status, 406); assert.equal(r.data.code, 'PGRST106');
    await balance(owner, 0, 0); await ledger(owner, []);
  });
  await check('eight concurrent requests for the same final step pay exactly once', async () => {
    const owner = await signup(), boss = await create(owner); ok(await complete(owner, boss.steps[0]));
    const responses = await Promise.all(Array.from({length: 8}, () => complete(owner, boss.steps[1])));
    assert.equal(responses.filter(r => r.status === 200).length, 1);
    responses.filter(r => r.status !== 200).forEach(denied);
    await balance(owner, 25, 50); await ledger(owner, [{xp_amount: 25, coin_amount: 50}]);
  });
  await check('concurrent victories on different battles preserve both balance increments', async () => {
    const owner = await signup(), a = await create(owner), b = await create(owner);
    ok(await complete(owner, a.steps[0])); ok(await complete(owner, b.steps[0]));
    (await Promise.all([complete(owner, a.steps[1]), complete(owner, b.steps[1])])).forEach(r => ok(r));
    await balance(owner, 50, 100);
    await ledger(owner, [{xp_amount: 25, coin_amount: 50}, {xp_amount: 25, coin_amount: 50}]);
  });
  await check('an older saved battle retains its approved historical reward and remains playable', async () => {
    const owner = await signup(), boss = await create(owner);
    // Synthetic pre-cap state only. Existing saved rewards were explicitly grandfathered.
    ok(await request(`/rest/v1/boss_battles?id=eq.${boss.id}`, admin, 'PATCH', {reward_xp: 100}));
    await finish(owner, boss, 100, 50);
    assert.equal((await readBoss(owner, boss.id)).reward_xp, 100);
  });
  await check('a missing profile cannot commit a victory or ledger without its balance', async () => {
    const owner = await signup(), boss = await create(owner); ok(await complete(owner, boss.steps[0]));
    ok(await request(`/rest/v1/users?id=eq.${owner.id}`, admin, 'DELETE'));
    denied(await complete(owner, boss.steps[1]));
    assert.equal((await readBoss(owner, boss.id)).status, 'open');
    assert.equal((await steps(owner, boss.id))[1].completed, false); await ledger(owner, []);
  });
} else { throw new Error('Unknown boss test phase'); }
console.log(`Boss rewards: ${checks} passed; ${failures} failed (${phase}).`);
if (failures) process.exitCode = 1;
