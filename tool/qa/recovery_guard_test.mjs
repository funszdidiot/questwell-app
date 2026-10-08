import assert from 'node:assert/strict';
import test from 'node:test';
import {assertRecoveryEnvironment, recoveryFailureCategories, assertMissingRecoveryFile} from '../backend_ci/recovery.mjs';

const env = {GITHUB_ACTIONS: 'true', RUNNER_ENVIRONMENT: 'github-hosted'};
const local = {API_URL: 'http://127.0.0.1:54321',
  DB_URL: 'postgresql://postgres:postgres@127.0.0.1:54322/postgres',
  ANON_KEY: 'synthetic', SERVICE_ROLE_KEY: 'synthetic'};
test('recovery rejects hosted credentials, remote Docker and non-disposable runners', () => {
  assert.doesNotThrow(() => assertRecoveryEnvironment(env, local));
  for (const override of [{GITHUB_ACTIONS: 'false'}, {RUNNER_ENVIRONMENT: 'self-hosted'},
    {DOCKER_HOST: 'tcp://remote:2375'}, {DOCKER_CONTEXT: 'remote'}, {DOCKER_CONFIG: '/tmp/remote'},
    {SUPABASE_ACCESS_TOKEN: 'secret'}, {PGHOST: 'remote'}, {DATABASE_URL: 'remote'}]) {
    assert.throws(() => assertRecoveryEnvironment({...env, ...override}, local));
  }
  for (const override of [{API_URL: 'https://example.supabase.co'},
    {DB_URL: 'postgresql://postgres:secret@example.com/postgres'}]) {
    assert.throws(() => assertRecoveryEnvironment(env, {...local, ...override}));
  }
});
test('recovery error diagnostics never return server text or row values', () => {
  const secrets = 'private@example.test eyJsecret.payload.signature password-hash';
  assert.deepEqual(recoveryFailureCategories(`ERROR: can only create extension in database postgres\n${secrets}`),
    ['extension_database_restriction']);
  assert.deepEqual(recoveryFailureCategories(`ERROR: schema secret already exists\n${secrets}`), ['already_exists']);
  assert.deepEqual(recoveryFailureCategories(secrets), []);
});
test('missing bytes require a specific object error, never a generic outage or denial', () => {
  const path = 'synthetic-owner/recovery.png';
  const missing = {status: 500, data: {code: 'InternalError', message: `ENOENT: no such file or directory, stat '/storage/beta-feedback/${path}-$v-version'`}};
  assert.doesNotThrow(() => assertMissingRecoveryFile(missing, path, 'version'));
  assert.doesNotThrow(() => assertMissingRecoveryFile({status: 404, data: {code: 'NoSuchKey'}}, path));
  for (const r of [{status: 200}, {status: 502}, {status: 403}, {status: 500},
    {...missing, data: {...missing.data, message: 'Database unavailable'}},
    {...missing, data: {...missing.data, message: `ENOENT: no such file or directory, stat '/storage/beta-feedback/${path}.unrelated-$v-version'`}},
    {...missing, data: {...missing.data, message: `ENOENT: no such file or directory, stat '/storage/beta-feedback/${path}-$v-other'`}},
    {...missing, data: {...missing.data, message: 'ENOENT: stat other-owner/recovery.png'}}]) {
    assert.throws(() => assertMissingRecoveryFile(r, path, 'version'));
  }
});
