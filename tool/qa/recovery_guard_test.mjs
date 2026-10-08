import assert from 'node:assert/strict';
import test from 'node:test';
import {assertRecoveryEnvironment} from '../backend_ci/recovery.mjs';

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
