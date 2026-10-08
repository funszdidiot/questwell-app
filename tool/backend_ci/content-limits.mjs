import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const {status} = JSON.parse(readFileSync(0, 'utf8'));
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
const owner = await signup();
const quest = title => request('/rest/v1/rpc/create_task_once', owner, 'POST', {
  p_request_id:randomUUID(),p_expected_user_id:owner.id,p_title:title,p_friction:1});
ok(await quest('🧭'.repeat(120)));
for (const title of ['x'.repeat(121),'🧭'.repeat(121),'\u00a0\ufeff']) denied(await quest(title));
const boss = (title,steps) => request('/rest/v1/rpc/create_boss_once', owner, 'POST', {
  p_request_id:randomUUID(),p_expected_user_id:owner.id,p_title:title,p_steps:steps,p_boss_type:'inbox_hydra'});
ok(await boss('x'.repeat(120),Array.from({length:50},(_,i)=>`Step ${i}`)));
denied(await boss('x'.repeat(121),['a','b']));
denied(await boss('Oversized steps',Array(51).fill('Step')));
denied(await boss('Oversized step title',['a','🧭'.repeat(121)]));
const bosses=await request('/rest/v1/boss_battles',owner);ok(bosses);assert.equal(bosses.data.length,1);
const steps=await request('/rest/v1/boss_steps',owner);ok(steps);assert.equal(steps.data.length,50);
const tasks=await request('/rest/v1/tasks',owner);ok(tasks);assert.equal(tasks.data.length,1);
console.log('Content limits: authenticated Unicode boundaries, 50/51 steps and atomic rejection passed.');
