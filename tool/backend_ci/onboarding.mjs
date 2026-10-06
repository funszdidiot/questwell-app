import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const {status, phase = 'regressions'} = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
const request = async (path, owner, method = 'GET', body) => {
  const response = await localRequest(status, path, {
    method, headers: {apikey:status.ANON_KEY,
      ...(owner ? {authorization:`Bearer ${owner.token}`} : {}),
      'content-type':'application/json', Prefer:'return=representation'},
    ...(body === undefined ? {} : {body:JSON.stringify(body)}),
  });
  const text = await response.text();
  return {status:response.status, data:text ? JSON.parse(text) : null};
};
const ok = (r, code = 200) => assert.equal(r.status, code,
  `Expected HTTP ${code}; received ${r.status} (${r.data?.code ?? 'no code'})`);
const denied = r => assert.ok([400,401,403,409].includes(r.status), `Expected denial; received ${r.status}`);
const signup = async () => {
  const r = await request('/auth/v1/signup', null, 'POST', {
    email:`onboarding-ci-${randomUUID()}@example.test`, password:`Ci-${randomUUID()}-9!`,
  });
  ok(r); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
  return {id:r.data.user.id, token:r.data.access_token};
};
const finish = (owner, key, expected = owner?.id) => request('/rest/v1/rpc/finish_onboarding_once', owner, 'POST', {
  p_expected_user_id:expected, p_starter_key:key,
});
const rows = async (owner, table) => { const r=await request(`/rest/v1/${table}`,owner); ok(r); return r.data; };
const profile = async owner => (await rows(owner,'users'))[0];
const legacyInsert = (owner, title = 'Reply to one email') => request('/rest/v1/tasks',owner,'POST',{
  user_id:owner.id,title,friction_level:1,status:'open',xp_value:10,coin_value:5,
});
const flag = (owner, value) => request(`/rest/v1/users?id=eq.${owner.id}`,owner,'PATCH',{onboarding_completed:value});
const completed = r => { ok(r); assert.equal(r.data.status,'completed'); };
let checks=0;
const check = async (name, action) => { await action(); checks++; console.log(`PASS onboarding: ${name}`); };

if (phase === 'baseline') {
  const owner=await signup();
  ok(await legacyInsert(owner),201); // Crash before the separate profile write.
  assert.equal((await profile(owner)).onboarding_completed,false);
  ok(await legacyInsert(owner),201); ok(await flag(owner,true));
  const tasks=await rows(owner,'tasks');
  assert.equal(tasks.length,2);
  assert.throws(()=>assert.equal(tasks.length,1),assert.AssertionError);
  console.log('RED onboarding characterization: crash between quest and flag, then retry, created 2 quests; expected 1.');
} else if (phase === 'rollback') {
  const owner=await signup(); denied(await finish(owner,'email'));
  assert.deepEqual(await rows(owner,'tasks'),[]);
  assert.equal((await profile(owner)).onboarding_completed,false);
  console.log('PASS onboarding: forced downstream failure leaves no quest and onboarding incomplete');
} else if (phase === 'regressions') {
  for(const [key,title,friction,xp,coins] of [
    ['email','Reply to one email',1,10,5],['files','Clear five desktop files',1,10,5],
    ['avoided','Do the thing I keep avoiding',3,35,18],
  ]) await check(`approved ${key} starter and profile commit together`,async()=>{
    const owner=await signup(), result=await finish(owner,key); completed(result);
    const tasks=await rows(owner,'tasks'); assert.equal(tasks.length,1);
    assert.equal(tasks[0].id,result.data.task_id);
    assert.deepEqual([tasks[0].title,tasks[0].friction_level,tasks[0].xp_value,tasks[0].coin_value], [title,friction,xp,coins]);
    const p=await profile(owner); assert.equal(p.onboarding_completed,true);
    assert.equal(p.total_xp,0); assert.equal(p.coin_balance,0);
  });
  await check('lost accepted response and retries after remount return the original quest',async()=>{
    const owner=await signup(); completed(await finish(owner,'email'));
    const first=(await rows(owner,'tasks'))[0];
    const retry=await finish(owner,'files'); completed(retry); assert.equal(retry.data.task_id,first.id);
    assert.equal((await rows(owner,'tasks')).length,1);
  });
  await check('concurrent different starters and skip produce one durable outcome',async()=>{
    for(const choices of [['email','files','avoided','email'],[null,'email',null,'files']]) {
      const owner=await signup(); const results=await Promise.all(choices.map(key=>finish(owner,key)));
      results.forEach(completed); assert.equal(new Set(results.map(r=>r.data.task_id)).size,1);
      assert.equal((await rows(owner,'tasks')).length,results[0].data.task_id ? 1 : 0);
      assert.equal((await profile(owner)).onboarding_completed,true);
    }
  });
  await check('skip and an already-completed legacy profile never gain a starter on retry',async()=>{
    for(const legacy of [false,true]) {
      const owner=await signup();
      if(legacy) ok(await flag(owner,true)); else completed(await finish(owner,null));
      const result=await finish(owner,'email'); completed(result); assert.equal(result.data.task_id,null);
      assert.deepEqual(await rows(owner,'tasks'),[]);
    }
  });
  await check('partial legacy setup requires explicit completion without modifying existing quests',async()=>{
    const owner=await signup(); ok(await legacyInsert(owner),201); ok(await legacyInsert(owner,'A personal quest'),201);
    const before=await rows(owner,'tasks');
    const attempt=await finish(owner,'email'); ok(attempt); assert.equal(attempt.data.status,'needs_confirmation');
    assert.equal((await profile(owner)).onboarding_completed,false);
    assert.deepEqual(await rows(owner,'tasks'),before);
    completed(await finish(owner,null)); completed(await finish(owner,'files'));
    assert.deepEqual(await rows(owner,'tasks'),before);
  });
  await check('completed/deleted starters and reset flags cannot recreate onboarding rewards',async()=>{
    const owner=await signup(), result=await finish(owner,'avoided'); completed(result);
    ok(await request('/rest/v1/rpc/complete_task',owner,'POST',{p_task_id:result.data.task_id}));
    ok(await request(`/rest/v1/tasks?id=eq.${result.data.task_id}`,owner,'DELETE'));
    ok(await flag(owner,false));
    const retry=await finish(owner,'email'); completed(retry); assert.equal(retry.data.task_id,result.data.task_id);
    assert.deepEqual(await rows(owner,'tasks'),[]);
    const p=await profile(owner); assert.equal(p.onboarding_completed,true); assert.equal(p.total_xp,35); assert.equal(p.coin_balance,18);
  });
  await check('legacy reward history without a remaining quest also requires confirmation',async()=>{
    const owner=await signup(), insert=await legacyInsert(owner); ok(insert,201);
    ok(await request('/rest/v1/rpc/complete_task',owner,'POST',{p_task_id:insert.data[0].id}));
    ok(await request(`/rest/v1/tasks?id=eq.${insert.data[0].id}`,owner,'DELETE'));
    const result=await finish(owner,'email'); ok(result); assert.equal(result.data.status,'needs_confirmation');
    assert.deepEqual(await rows(owner,'tasks'),[]); completed(await finish(owner,null));
  });
  await check('anonymous, switched, revoked and fenced accounts are rejected',async()=>{
    const owner=await signup(), other=await signup();
    denied(await finish(null,'email',owner.id)); denied(await finish(other,'email',owner.id));
    assert.equal((await profile(owner)).onboarding_completed,false); assert.deepEqual(await rows(other,'tasks'),[]);
    const logout=await request('/auth/v1/logout?scope=global',owner,'POST'); assert.ok([200,204].includes(logout.status));
    denied(await finish(owner,'email'));
    const fence=await request('/rest/v1/rpc/begin_account_deletion',{token:status.SERVICE_ROLE_KEY},'POST',{p_user_id:other.id});
    assert.ok([200,204].includes(fence.status)); denied(await finish(other,'email'));
  });
  await check('invalid choice rolls back and a legitimate retry succeeds',async()=>{
    const owner=await signup(); denied(await finish(owner,'forged'));
    assert.deepEqual(await rows(owner,'tasks'),[]); assert.equal((await profile(owner)).onboarding_completed,false);
    completed(await finish(owner,'email'));
  });
  console.log(`Onboarding: ${checks} passed.`);
} else throw new Error('Unknown onboarding phase');
