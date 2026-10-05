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
  const r = await removeAccount(a); ok(r); assert.deepEqual(r.data, {deleted: true});
  denied(await request(`/auth/v1/admin/users/${a.id}`, admin));
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
console.log(`Account deletion: ${checks} passed; ${failures} failed (real Edge/Auth/Storage).`);
if (failures) process.exitCode = 1;
