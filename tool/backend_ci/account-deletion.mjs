import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const status = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
const admin = {token: status.SERVICE_ROLE_KEY};
const request = async (path, owner, method = 'GET', body, headers = {}) => {
  const r = await localRequest(status, path, {method,
    headers: {apikey: status.ANON_KEY, ...(owner ? {authorization: `Bearer ${owner.token}`} : {}),
      'content-type': 'application/json', ...headers},
    ...(body === undefined ? {} : {body: typeof body === 'string' ? body : JSON.stringify(body)})});
  const text = await r.text();
  let data; try { data = text ? JSON.parse(text) : null; } catch { data = null; }
  return {status: r.status, data};
};
const ok = (r, code = 200) => assert.equal(r.status, code, `Expected HTTP ${code}, received ${r.status}`);
const denied = r => assert.ok([400, 401, 403, 404].includes(r.status), `Expected denial, received HTTP ${r.status}`);
const signup = async () => {
  const email = `delete-ci-${randomUUID()}@example.test`, password = `Ci-${randomUUID()}-9!`;
  const r = await request('/auth/v1/signup', null, 'POST', {email, password});
  ok(r); assert.ok(r.data.user?.id && r.data.access_token);
  return {id: r.data.user.id, token: r.data.access_token, refresh: r.data.refresh_token, email, password};
};
const upload = (owner, name) => request(`/storage/v1/object/beta-feedback/${owner.id}/${name}`, owner,
  'POST', 'synthetic image bytes', {'content-type': 'image/png'});
const login = async owner => {
  const r = await request('/auth/v1/token?grant_type=password', null, 'POST', {email: owner.email, password: owner.password});
  ok(r); return {...owner, token: r.data.access_token, refresh: r.data.refresh_token};
};
const owned = async owner => {
  const r = await request('/rest/v1/rpc/account_deletion_objects', admin, 'POST', {p_user_id: owner.id});
  ok(r); return r.data;
};
const removeAccount = (owner, body = {confirmation: 'DELETE'}) =>
  request('/functions/v1/delete-account', owner, 'POST', body);
let checks = 0, failures = 0;
const check = async (name, action) => {
  try { await action(); checks++; console.log(`PASS deletion: ${name}`); }
  catch (error) { failures++; console.error(`FAIL deletion: ${name}: ${error.message}`); }
};
// Read-only readiness probe; never retry a destructive request automatically.
for (let attempt = 0; ; attempt++) {
  try { if ((await request('/functions/v1/delete-account', null, 'OPTIONS')).status === 204) break; } catch {}
  if (attempt >= 29) throw new Error('Local deletion Edge Function did not become ready');
  await new Promise(resolve => setTimeout(resolve, 1000));
}
await check('actual Edge Function denies unauthenticated, invalid and wrong-target requests', async () => {
  const a = await signup(), b = await signup();
  ok(await removeAccount(null), 401);
  ok(await removeAccount({token: 'invalid-token'}), 401);
  ok(await removeAccount(a, {confirmation: 'DELETE', user_id: b.id}), 400);
  ok(await request(`/auth/v1/admin/users/${b.id}`, admin));
});
await check('only the service role can enumerate owned Storage metadata', async () => {
  const a = await signup();
  for (const caller of [null, a]) denied(await request('/rest/v1/rpc/account_deletion_objects', caller, 'POST', {p_user_id: a.id}));
  for (const caller of [null, a]) denied(await request('/rest/v1/rpc/begin_account_deletion', caller, 'POST', {p_user_id: a.id}));
  assert.deepEqual(await owned(a), []);
});
await check('account without files deletes and repeated requests cannot claim success', async () => {
  const a = await signup();
  ok(await request('/rest/v1/tasks', a, 'POST', {user_id: a.id, title: 'Synthetic deletion task', friction_level: 1}), 201);
  const r = await removeAccount(a); ok(r); assert.deepEqual(r.data, {deleted: true});
  denied(await request(`/auth/v1/admin/users/${a.id}`, admin));
  for (const [table, field] of [['users','id'], ['tasks','user_id']]) {
    const rows = await request(`/rest/v1/${table}?${field}=eq.${a.id}&select=*`, admin);
    ok(rows); assert.deepEqual(rows.data, []);
  }
  ok(await removeAccount(a), 401);
});
await check('more than one page of nested owned files is removed and another owner survives', async () => {
  const a = await signup(), b = await signup();
  ok(await upload(b, 'keep.png'));
  for (let start = 0; start < 101; start += 10) {
    const results = await Promise.all(Array.from({length: Math.min(10, 101 - start)}, (_, i) =>
      upload(a, `nested/${String(start + i).padStart(3, '0')}.png`)));
    for (const r of results) ok(r);
  }
  ok(await request('/storage/v1/bucket', admin, 'POST', {id: 'ci-deletion-secondary', name: 'ci-deletion-secondary', public: false}));
  const path = `unrelated/${randomUUID()}/owned.png`;
  ok(await request(`/storage/v1/object/ci-deletion-secondary/${path}`, a, 'POST', 'synthetic bytes', {'content-type':'image/png'}));
  ok(await request(`/storage/v1/object/beta-feedback/${a.id}/shared.png`, admin, 'POST', 'shared bytes', {'content-type':'image/png'}));
  const page = await owned(a); assert.equal(page.length, 100); assert.ok(page.every(o=>o.owner_id===a.id));
  // Seed each existing account cascade using actual application endpoints.
  const task = await request('/rest/v1/tasks', a, 'POST', {user_id:a.id,title:'Cascade task',friction_level:1}, {Prefer:'return=representation'});
  ok(task,201); ok(await request('/rest/v1/rpc/complete_task', a, 'POST', {p_task_id:task.data[0].id}));
  ok(await request('/rest/v1/rpc/create_boss_battle', a, 'POST', {p_title:'Cascade boss',p_steps:['One','Two']}));
  ok(await request('/rest/v1/beta_feedback', a, 'POST', {id:randomUUID(),user_id:a.id,category:'bug',goal:'Synthetic',message:'Synthetic deletion check',screen:'Other',build:'ci',platform:'web'}),201);
  ok(await request('/rest/v1/progression_events', admin, 'POST', {user_id:a.id,kind:'level_up',event_key:'ci',title:'Synthetic level',level:2,source:'ci'}),201);
  const cosmetic = randomUUID();
  ok(await request('/rest/v1/cosmetics',admin,'POST',{id:cosmetic,slug:`ci-${cosmetic}`,name:'Synthetic cosmetic',category:'outfit',rarity:'common',price:0}),201);
  ok(await request('/rest/v1/user_cosmetics',admin,'POST',{user_id:a.id,cosmetic_id:cosmetic,source:'starter',equipped:false}),201);
  for (const table of ['tasks','boss_battles','boss_steps','beta_feedback','progression_events','reward_events','user_cosmetics']) {
    const rows=await request(`/rest/v1/${table}?user_id=eq.${a.id}&select=*`,admin);ok(rows);assert.ok(rows.data.length>0,`Missing ${table} cascade fixture`);
  }
  const r = await removeAccount(a); ok(r); assert.deepEqual(r.data, {deleted: true});
  denied(await request(`/auth/v1/admin/users/${a.id}`, admin));
  assert.deepEqual(await owned(a),[]);
  for (const [table,field] of [['users','id'],...['tasks','boss_battles','boss_steps','beta_feedback','progression_events','reward_events','user_cosmetics'].map(t=>[t,'user_id'])]) {
    const rows=await request(`/rest/v1/${table}?${field}=eq.${a.id}&select=*`,admin);ok(rows);assert.deepEqual(rows.data,[],`${table} did not cascade`);
  }
  ok(await request(`/rest/v1/cosmetics?id=eq.${cosmetic}&select=id`,admin));
  ok(await request(`/storage/v1/object/authenticated/beta-feedback/${a.id}/shared.png`,admin));
  denied(await request(`/storage/v1/object/authenticated/ci-deletion-secondary/${path}`,admin));
  denied(await request('/auth/v1/token?grant_type=refresh_token',null,'POST',{refresh_token:a.refresh}));
  const list = await request('/storage/v1/object/list/beta-feedback', admin, 'POST', {prefix: `${a.id}/nested`, limit: 1000});
  ok(list); assert.deepEqual(list.data, []);
  ok(await request(`/storage/v1/object/authenticated/beta-feedback/${b.id}/keep.png`, b));
  denied(await upload(a, 'after-delete.png'));
});
await check('a revoked session cannot upload new files with its still-unexpired access token', async () => {
  const a = await signup();
  ok(await upload(a, 'before.png'));
  ok(await request('/auth/v1/logout?scope=global', a, 'POST'), 204);
  denied(await upload(a, 'after-revoke.png'));
});
await check('real Auth cascade failure after file removal can be retried without claiming success', async () => {
  let a = await signup();
  ok(await upload(a,'retry.png'));
  ok(await request(`/rest/v1/users?id=eq.${a.id}`,admin,'PATCH',{total_xp:987654}),204);
  const first=await removeAccount(a);ok(first,503);
  assert.equal(first.data.deleted,undefined);assert.equal(JSON.stringify(first.data).includes('Synthetic Auth'),false);
  assert.deepEqual(await owned(a),[]);
  ok(await request(`/auth/v1/admin/users/${a.id}`,admin));
  denied(await upload(a,'revoked.png'));
  denied(await request('/auth/v1/token?grant_type=refresh_token',null,'POST',{refresh_token:a.refresh}));
  ok(await request(`/rest/v1/users?id=eq.${a.id}`,admin,'PATCH',{total_xp:0}),204);
  a=await login(a);
  denied(await upload(a,'fresh-session-after-partial-delete.png'));
  ok(await removeAccount(a));
  denied(await request(`/auth/v1/admin/users/${a.id}`,admin));
});
await check('concurrent deletion requests converge on complete cleanup and preserve a bystander', async () => {
  const a=await signup(),b=await signup();
  ok(await upload(a,'concurrent.png'));ok(await upload(b,'concurrent-keep.png'));
  const results=await Promise.all([removeAccount(a),removeAccount(a)]);
  // Both requests can verify Auth before either deletion commits. A successful
  // response confirms the final state; it is not an exclusive-winner receipt.
  assert.ok(results.some(r=>r.status===200));
  for (const r of results.filter(r=>r.status===200)) assert.deepEqual(r.data,{deleted:true});
  assert.ok(results.every(r=>[200,401,503].includes(r.status)));
  denied(await request(`/auth/v1/admin/users/${a.id}`,admin));
  assert.deepEqual(await owned(a),[]);
  denied(await request(`/storage/v1/object/authenticated/beta-feedback/${a.id}/concurrent.png`,admin));
  denied(await upload(a,'after-concurrent.png'));
  ok(await removeAccount(a),401);
  ok(await request(`/auth/v1/admin/users/${b.id}`,admin));
  ok(await request(`/storage/v1/object/authenticated/beta-feedback/${b.id}/concurrent-keep.png`,b));
});
for (const phase of ['probe', 'commit']) {
await check(`deletion coordinates the in-flight Storage ${phase} before removing Auth`, async () => {
  const a = await signup();
  const name = `race-inflight-${phase}.png`;
  const uploading = upload(a, name);
  const paused = async () => {
    const r = await request('/rest/v1/rpc/ci_storage_upload_paused', admin, 'POST', {});
    ok(r); return r.data === true;
  };
  let observed = false;
  for (let attempt = 0; attempt < 50; attempt++) {
    if (await paused()) { observed = true; break; }
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  assert.ok(observed, 'Real Storage upload never reached the held transaction');
  let settled = false;
  const deleting = removeAccount(a).then(r => { settled = true; return r; });
  await new Promise(resolve => setTimeout(resolve, 250));
  assert.equal(await paused(), true, 'Upload must still be held while deletion waits');
  assert.equal(settled, false, 'Deletion returned before the in-flight transaction drained');
  const [uploaded, deleted] = await Promise.all([uploading, deleting]);
  // Storage may roll back a permission-probe transaction and reject its later
  // write after revocation. Either committed cleanup or denied upload is safe.
  assert.ok([200, 400, 401, 403].includes(uploaded.status), `Unexpected upload status ${uploaded.status}`);
  ok(deleted); assert.deepEqual(deleted.data, {deleted: true});
  denied(await request(`/auth/v1/admin/users/${a.id}`, admin));
  assert.deepEqual(await owned(a), []);
  denied(await request(`/storage/v1/object/authenticated/beta-feedback/${a.id}/${name}`, admin));
  denied(await upload(a, 'after-race.png'));
});
}
console.log(`Account deletion: ${checks} passed; ${failures} failed (real Edge/Auth/Storage).`);
if (failures) process.exitCode = 1;
