import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const {status, phase = 'characterization'} = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
const request = async (path, owner, method = 'GET', body) => {
  const r = await localRequest(status, path, {method, headers: {
    apikey: status.ANON_KEY, ...(owner ? {authorization: `Bearer ${owner.token}`} : {}),
    'content-type': 'application/json', Prefer: 'return=representation',
  }, ...(body === undefined ? {} : {body: JSON.stringify(body)})});
  const text = await r.text();
  return {status: r.status, data: text ? JSON.parse(text) : null};
};
const ok = r => assert.equal(r.status, 200, `HTTP ${r.status} (${r.data?.code ?? 'no code'})`);
const admin = {token: status.SERVICE_ROLE_KEY};
const activity = async () => {
  const r = await request('/rest/v1/rpc/ci_boss_completion_activity', admin, 'POST', {});
  ok(r); return r.data;
};
const until = async predicate => {
  for (let n=0; n<40; n++) {
    if (predicate(await activity())) return;
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  assert.fail('The required overlapping transaction state was not observed');
};
const signup = async () => {
  const r = await request('/auth/v1/signup', null, 'POST', {
    email: `boss-final-ci-${randomUUID()}@example.test`, password: `Ci-${randomUUID()}-9!`,
  });
  ok(r); assert.ok(r.data.user?.id && r.data.access_token);
  return {id: r.data.user.id, token: r.data.access_token};
};
const complete = (owner, id) => request('/rest/v1/rpc/complete_boss_step', owner, 'POST', {p_step_id:id});
const held = (owner, id, marker) => request('/rest/v1/rpc/ci_complete_boss_step_held', owner, 'POST', {p_step_id:id,p_marker:marker});

for (const count of phase === 'regressions' ? [2,5,20] : [2]) {
  const owner = await signup();
  const created = await request('/rest/v1/rpc/create_boss_battle', owner, 'POST', {
    p_title:'Concurrent final steps',p_steps:Array.from({length:count},(_,i)=>`Step ${i}`),
    p_reward_xp:25,p_reward_coins:50,p_boss_type:'inbox_hydra',
  });
  ok(created); const bossId=created.data;
  const before = await request(`/rest/v1/boss_steps?boss_id=eq.${bossId}&order=position`,owner);
  ok(before); assert.equal(before.data.length,count);
  for (const step of before.data.slice(0,-2)) ok(await complete(owner,step.id));
  const finalSteps=before.data.slice(-2);
  const a=held(owner,finalSteps[0].id,1);
  // Observe the first real RPC's uncommitted result before starting the second.
  await until(s=>s.returned===1);
  const b=held(owner,finalSteps[1].id,2);
  let overlapError;
  try {
    await until(s=>phase==='regressions'
      ? s.returned===1 && s.waiting===1
      : s.returned===2);
  } catch (error) { overlapError=error; }
  const responses=await Promise.all([a,b]); responses.forEach(ok);
  if(overlapError) throw overlapError;
  const steps=await request(`/rest/v1/boss_steps?boss_id=eq.${bossId}`,owner);ok(steps);
  assert.ok(steps.data.every(s=>s.completed && s.completed_at));
  const battle=await request(`/rest/v1/boss_battles?id=eq.${bossId}`,owner);ok(battle);
  const balance=await request('/rest/v1/users?select=total_xp,coin_balance',owner);ok(balance);
  const ledger=await request('/rest/v1/reward_events?event_type=eq.boss_battle_completed&select=xp_amount,coin_amount',owner);ok(ledger);
  if(phase==='baseline') {
    assert.equal(battle.data[0].status,'open');
    assert.deepEqual(balance.data,[{total_xp:0,coin_balance:0}]);
    assert.deepEqual(ledger.data,[]);
    for(const step of finalSteps) assert.notEqual((await complete(owner,step.id)).status,200);
    console.log('REPRODUCED C04: two committed final steps leave an open battle, zero payout, and both retries rejected.');
  } else {
    assert.equal(battle.data[0].status,'completed','Both final steps committed but the battle was stranded open');
    assert.ok(battle.data[0].completed_at);
    assert.deepEqual(balance.data,[{total_xp:25,coin_balance:50}]);
    assert.deepEqual(ledger.data,[{xp_amount:25,coin_amount:50}]);
    assert.equal(responses.reduce((sum,r)=>sum+r.data[0].xp_awarded,0),25);
    assert.equal(responses.reduce((sum,r)=>sum+r.data[0].coins_awarded,0),50);
    for(const step of finalSteps) assert.notEqual((await complete(owner,step.id)).status,200);
    const after=await request('/rest/v1/users?select=total_xp,coin_balance',owner);ok(after);
    assert.deepEqual(after.data,balance.data);
    console.log(`PASS C04: ${count}-step battle serializes different final steps, commits one victory/payout, and rejects repeat completion.`);
  }
}
