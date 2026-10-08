import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {guardedPayload, migrationPath} from '../deploy/content-limits-contract.mjs';
const root = new URL('../../', import.meta.url);
const reviewed = JSON.parse(readFileSync(new URL('tool/deploy/content-limits-reviewed-state.json', root), 'utf8'));
const source = readFileSync(new URL(migrationPath, root), 'utf8');
const catalog = readFileSync(new URL('tool/backend_ci/catalog.sql', root), 'utf8');

test('source and catalog drift fail before producing a deployment payload', () => {
  assert.throws(() => guardedPayload(source + '\n', catalog, reviewed), /source changed/);
  assert.throws(() => guardedPayload(source, catalog + '\n', reviewed), /Catalog query changed/);
});
test('foreign targets, unpinned postconditions and existing installations fail closed', () => {
  for (const change of [{project: 'hpjzfytwivlpsdhiupyd'}, {after_limits_sha256: null},
    {migration_name: 'other'}, {migration_path: 'other.sql'}, {after_grant_count: 3}]) {
    assert.throws(() => guardedPayload(source, catalog, {...reviewed, ...change}));
  }
  for (const key of ['function_count','trigger_count','grant_count','rollout_records']) {
    assert.throws(() => guardedPayload(source, catalog, {...reviewed, before: {...reviewed.before, [key]: 1}}));
  }
});
test('renderer rejects operation and target overrides without printing SQL', () => {
  const script = new URL('tool/deploy/render-content-limits.mjs', root);
  for (const flag of ['--apply', '--project=other', '--state=other']) {
    const result = spawnSync(process.execPath, [script.pathname, flag], {encoding: 'utf8'});
    assert.notEqual(result.status, 0);
    assert.equal(result.stdout, '');
  }
});
test('one transaction pins scope and arms timeout before the deployment block', () => {
  const sql = guardedPayload(source, catalog, reviewed);
  assert.ok(sql.includes(source));
  assert.ok(sql.indexOf("set local statement_timeout = '20s';") < sql.indexOf('do $questwell_content$'));
  assert.equal((sql.match(/^do \$questwell_content\$/gm) || []).length, 1);
  assert.equal((sql.match(/^commit;/gm) || []).length, 0);
  assert.ok(sql.includes('supabase_migrations.schema_migrations in share row exclusive mode'));
});
