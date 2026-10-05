import test from 'node:test';
import assert from 'node:assert/strict';
import {assertDisposableCi, assertLocalStatus, localRequest} from '../backend_ci/guard.mjs';

const ci = {GITHUB_ACTIONS: 'true', RUNNER_ENVIRONMENT: 'github-hosted'};
const status = {
  API_URL: 'http://127.0.0.1:54321',
  DB_URL: 'postgresql://postgres:postgres@127.0.0.1:54322/postgres',
  ANON_KEY: 'synthetic-anon', SERVICE_ROLE_KEY: 'synthetic-service',
};

test('backend writes require a disposable GitHub-hosted runner', () => {
  assert.doesNotThrow(() => assertDisposableCi(ci));
  for (const env of [{}, {...ci, GITHUB_ACTIONS: 'false'}, {...ci, RUNNER_ENVIRONMENT: 'self-hosted'}]) {
    assert.throws(() => assertDisposableCi(env), /GitHub-hosted/);
  }
});

test('remote credentials and target overrides are rejected without printing their values', () => {
  for (const key of ['SUPABASE_ACCESS_TOKEN', 'SUPABASE_URL', 'SUPABASE_DB_PASSWORD',
    'SUPABASE_SERVICE_ROLE_KEY', 'SUPABASE_PROJECT_ID', 'DATABASE_URL', 'PGHOST', 'PGSERVICE', 'PGPASSWORD']) {
    assert.throws(() => assertDisposableCi({...ci, [key]: 'do-not-print-me'}), error =>
      error.message.includes(key) && !error.message.includes('do-not-print-me'));
  }
});

test('only the fixed loopback API and database endpoints are accepted', () => {
  assert.doesNotThrow(() => assertLocalStatus(status));
  for (const API_URL of ['https://project.supabase.co', 'http://127.0.0.1:54322',
    'http://127.0.0.1.evil.invalid:54321', 'http://user@127.0.0.1:54321',
    'http://127.0.0.1:54321?target=remote', 'http://localhost:54321']) {
    assert.throws(() => assertLocalStatus({...status, API_URL}), /local API/);
  }
  for (const DB_URL of ['postgresql://postgres:secret@remote.invalid:5432/postgres',
    'postgresql://postgres:postgres@127.0.0.1:54322/production',
    'postgresql://postgres:postgres@127.0.0.1:54322/postgres?host=remote.invalid']) {
    assert.throws(() => assertLocalStatus({...status, DB_URL}), /local database/);
  }
});

test('missing CLI credentials fail closed', () => {
  for (const key of ['ANON_KEY', 'SERVICE_ROLE_KEY']) {
    assert.throws(() => assertLocalStatus({...status, [key]: ''}), /local credentials/);
  }
});

test('unsafe endpoints and escaping request paths make no network call', async () => {
  let calls = 0;
  const transport = async () => { calls++; return new Response('{}'); };
  for (const path of ['https://remote.invalid', '//remote.invalid', '/\\remote.invalid']) {
    await assert.rejects(localRequest(status, path, {}, transport), /local path/);
  }
  await assert.rejects(localRequest({...status, API_URL: 'https://remote.invalid'}, '/auth/v1/user', {}, transport), /local API/);
  assert.equal(calls, 0);
});

test('requests prohibit redirects and retain a bounded timeout', async () => {
  let captured;
  await localRequest(status, '/auth/v1/user', {redirect: 'follow'}, async (url, options) => {
    captured = {url, options};
    return new Response('{}');
  });
  assert.equal(captured.url, 'http://127.0.0.1:54321/auth/v1/user');
  assert.equal(captured.options.redirect, 'error');
  assert.ok(captured.options.signal instanceof AbortSignal);
});
