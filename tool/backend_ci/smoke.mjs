import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {localRequest} from './guard.mjs';

// Real Auth and REST requests against the harness fixture, never app tables.
export async function smoke(status, executeSql) {
  const request = async (path, token, method = 'GET', body) => {
    const response = await localRequest(status, path, {
      method,
      headers: {
        apikey: status.ANON_KEY,
        ...(token ? {authorization: `Bearer ${token}`} : {}),
        'content-type': 'application/json',
        Prefer: 'return=representation',
      },
      ...(body === undefined ? {} : {body: JSON.stringify(body)}),
    });
    // Never print tokens, passwords or response bodies in failure diagnostics.
    const data = await response.json();
    return {status: response.status, data};
  };
  const ok = (r, expected) => assert.equal(r.status, expected, `Expected HTTP ${expected}, received ${r.status}`);
  let count = 0;
  const check = async (name, action) => {
    await action(); count++;
    console.log(`PASS ${name}`);
  };
  const createAccount = async () => {
    const email = `ci-${randomUUID()}@example.test`;
    const password = `Ci-${randomUUID()}-9!`;
    const signup = await request('/auth/v1/signup', null, 'POST', {email, password});
    ok(signup, 200);
    assert.ok(signup.data.user?.id, 'Signup must return a synthetic user ID');
    const login = await request('/auth/v1/token?grant_type=password', null, 'POST', {email, password});
    ok(login, 200);
    assert.equal(login.data.user?.id, signup.data.user.id);
    assert.equal(typeof login.data.access_token, 'string');
    return {id: login.data.user.id, token: login.data.access_token};
  };
  let a, b, rowA;
  const path = '/rest/v1/ci_owner_probe';
  await check('two synthetic accounts sign up and sign in through real Auth', async () => {
    a = await createAccount(); b = await createAccount();
    assert.notEqual(a.id, b.id);
  });
  await check('Auth verifies each session and rejects unauthenticated access', async () => {
    for (const owner of [a, b]) {
      const r = await request('/auth/v1/user', owner.token); ok(r, 200);
      assert.equal(r.data.id, owner.id);
    }
    ok(await request('/auth/v1/user', null), 401);
  });
  await check('each owner can insert its own fixture row', async () => {
    for (const owner of [a, b]) {
      const r = await request(path, owner.token, 'POST', {owner_id: owner.id, value: 7});
      ok(r, 201); assert.equal(r.data.length, 1); assert.equal(r.data[0].owner_id, owner.id);
      if (owner === a) rowA = r.data[0].id;
    }
  });
  const assertOwnerIsolation = async () => {
    for (const owner of [a, b]) {
      const r = await request(`${path}?select=id,owner_id,value`, owner.token); ok(r, 200);
      assert.equal(r.data.length, 1, 'Owner must see exactly its own fixture row');
      assert.equal(r.data[0].owner_id, owner.id);
    }
  };
  await check('owners cannot read each other\'s rows', assertOwnerIsolation);
  await check('anonymous reads return no rows and writes are denied', async () => {
    const read = await request(path, null); ok(read, 200); assert.deepEqual(read.data, []);
    const write = await request(path, null, 'POST', {owner_id: a.id, value: 99});
    assert.ok([401, 403].includes(write.status), 'Anonymous write must be denied');
    assert.equal(write.data.code, '42501');
  });
  await check('forged ownership on insert is rejected by RLS', async () => {
    const r = await request(path, a.token, 'POST', {owner_id: b.id, value: 99});
    ok(r, 403); assert.equal(r.data.code, '42501');
  });
  await check('ownership cannot be reassigned during update', async () => {
    const r = await request(`${path}?id=eq.${rowA}`, a.token, 'PATCH', {owner_id: b.id});
    ok(r, 403); assert.equal(r.data.code, '42501');
  });
  await check('cross-user update and delete affect zero rows', async () => {
    for (const method of ['PATCH', 'DELETE']) {
      const r = await request(`${path}?id=eq.${rowA}`, b.token, method, method === 'PATCH' ? {value: 99} : undefined);
      ok(r, 200); assert.deepEqual(r.data, []);
    }
    const r = await request(`${path}?id=eq.${rowA}`, a.token); ok(r, 200);
    assert.equal(r.data.length, 1); assert.equal(r.data[0].value, 7);
  });
  await check('negative control: the isolation assertion detects disabled fixture RLS', async () => {
    executeSql('alter table public.ci_owner_probe disable row level security;');
    try {
      await assert.rejects(assertOwnerIsolation(), /Owner must see exactly its own fixture row/);
    } finally {
      executeSql('alter table public.ci_owner_probe enable row level security;');
    }
    await assertOwnerIsolation();
  });
  await check('legitimate owner update and delete remain usable', async () => {
    const updated = await request(`${path}?id=eq.${rowA}`, a.token, 'PATCH', {value: 8});
    ok(updated, 200); assert.equal(updated.data[0].value, 8);
    const deleted = await request(`${path}?id=eq.${rowA}`, a.token, 'DELETE');
    ok(deleted, 200); assert.equal(deleted.data.length, 1);
    const remaining = await request(path, b.token); ok(remaining, 200);
    assert.equal(remaining.data.length, 1); assert.equal(remaining.data[0].owner_id, b.id);
  });
  console.log(`Backend harness: ${count} integration checks passed (fixture only; not Questwell RLS).`);
}
