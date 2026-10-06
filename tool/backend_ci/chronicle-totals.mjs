import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';
assertDisposableCi(process.env);
const {status} = JSON.parse(readFileSync(0,'utf8'));
assertLocalStatus(status);
const request = async (path, owner, method='GET', body, headers={}) => {
  const response = await localRequest(status,path,{method,headers:{apikey:status.ANON_KEY,
    ...(owner ? {authorization:`Bearer ${owner.token}`} : {}),
    'content-type':'application/json',Prefer:'return=representation',...headers},
    ...(body===undefined ? {} : {body:JSON.stringify(body)})});
  const text=await response.text();
  return {status:response.status,data:text ? JSON.parse(text) : null};
};
const ok=(r,code=200)=>assert.equal(r.status,code,`Expected ${code}; received ${r.status} (${r.data?.code ?? 'no code'})`);
const denied=r=>assert.ok([400,401,403,404].includes(r.status),`Expected denial; received ${r.status}`);
const signup=async()=>{
  const r=await request('/auth/v1/signup',null,'POST',{
    email:`chronicle-ci-${randomUUID()}@example.test`,password:`Ci-${randomUUID()}-9!`});
  ok(r); assert.ok(r.data.user?.id); assert.ok(r.data.access_token);
  return {id:r.data.user.id,token:r.data.access_token};
};
const admin={token:status.SERVICE_ROLE_KEY}; // Guarded disposable local fixture only.
const week='2026-10-05T05:00:00.000Z'; // Monday midnight at UTC-05.
const rpc=(owner,boundary=week,extra={})=>request('/rest/v1/rpc/chronicle_totals',owner,'POST',{p_week_start:boundary,...extra});
const expect=async(owner,xp,coins,wins,bosses,boundary=week)=>{
  const r=await rpc(owner,boundary); ok(r);
  assert.deepEqual(Object.keys(r.data).sort(),['bosses_defeated','owner_id','total_coins_earned','total_xp_earned','week_start','week_wins']);
  assert.equal(r.data.owner_id,owner.id);
  assert.equal(Date.parse(r.data.week_start),Date.parse(boundary));
  assert.deepEqual([r.data.total_xp_earned,r.data.total_coins_earned,r.data.week_wins,r.data.bosses_defeated],
    [xp,coins,wins,bosses].map(String));
};
let checks=0;
const check=async(name,fn)=>{await fn(); checks++; console.log(`PASS Chronicle totals: ${name}`);};
const a=await signup(),b=await signup();
await check('empty authenticated history is zero',()=>expect(a,0,0,0,0));
await check('anonymous, service-role and missing/invalid boundary denied',async()=>{
  denied(await rpc(null)); denied(await rpc(admin));
  for(const boundary of [null,'infinity','-infinity','not-a-date']) denied(await rpc(a,boundary));
  denied(await request('/rest/v1/rpc/chronicle_totals',a,'POST',{}));
  denied(await rpc(a,week,{p_user_id:b.id}));
});
const tasks=Array.from({length:1205},(_,i)=>({id:randomUUID(),user_id:a.id,title:'Synthetic historical quest',
  status:'completed',friction_level:1,xp_value:17,coin_value:9,
  completed_at:i===0 ? '2026-10-05T04:59:59.999999Z' : week}));
const bosses=Array.from({length:1107},()=>({id:randomUUID(),user_id:a.id,title:'Synthetic historical boss',
  status:'completed',reward_xp:31,reward_coins:47,completed_at:week,boss_type:'inbox_hydra'}));
await check('full aggregate exceeds REST row cap and preserves historical rewards',async()=>{
  ok(await request('/rest/v1/tasks',admin,'POST',tasks, {Prefer:'return=minimal'}),201);
  ok(await request('/rest/v1/boss_battles',admin,'POST',bosses,{Prefer:'return=minimal'}),201);
  const capped=await request('/rest/v1/tasks?select=id&status=eq.completed',a); ok(capped);
  assert.ok(capped.data.length < tasks.length,'Negative control must actually hit REST cap');
  await expect(a,54802,62874,2311,1107);
});
await check('other owner cannot see populated history',async()=>{
  await expect(b,0,0,0,0);
  ok(await request('/rest/v1/tasks',admin,'POST',[{...tasks[0],id:randomUUID(),user_id:b.id,xp_value:999,coin_value:777,completed_at:week}],{Prefer:'return=minimal'}),201);
  await expect(b,999,777,1,0); await expect(a,54802,62874,2311,1107);
});
await check('open and set-aside quests and open bosses are excluded',async()=>{
  ok(await request('/rest/v1/tasks',admin,'POST',['open','set_aside'].map(status=>({...tasks[0],id:randomUUID(),status,xp_value:100000,coin_value:100000})),{Prefer:'return=minimal'}),201);
  ok(await request('/rest/v1/boss_battles',admin,'POST',[{...bosses[0],id:randomUUID(),status:'open',reward_xp:100000}],{Prefer:'return=minimal'}),201);
  await expect(a,54802,62874,2311,1107);
});
await check('week boundary is inclusive and preserves absolute timezone offset',async()=>{
  await expect(a,54802,62874,2312,1107,'2026-10-05T04:59:59.999Z');
  await expect(a,54802,62874,0,1107,'2026-10-05T05:00:00.001Z');
  await expect(a,54802,62874,2311,1107,'2026-10-05T00:00:00-05:00');
});
await check('deleting retained history updates totals without counting ledger balances',async()=>{
  ok(await request(`/rest/v1/tasks?id=eq.${tasks[0].id}`,a,'DELETE'));
  ok(await request(`/rest/v1/boss_battles?id=eq.${bosses[0].id}`,admin,'DELETE'));
  await expect(a,54754,62818,2310,1106);
});
await check('malformed completed dates fail without partial plausible totals',async()=>{
  ok(await request(`/rest/v1/tasks?id=eq.${tasks[1].id}`,admin,'PATCH',{completed_at:null}));
  denied(await rpc(a)); await expect(b,999,777,1,0);
  ok(await request(`/rest/v1/tasks?id=eq.${tasks[1].id}`,admin,'PATCH',{completed_at:week}));
  await expect(a,54754,62818,2310,1106);
});
console.log(`Chronicle totals: ${checks} real Auth/REST scenarios passed.`);
