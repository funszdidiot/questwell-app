import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {migrationPath, sha256} from '../deploy/content-limits-contract.mjs';
import {deploymentContext, deploymentRef, repository, requiredChecks, makePlan,
  runDeployment, verifyApproval, verifyApplied} from '../deploy/content-limits-runner.mjs';

const read = path => readFileSync(new URL('../../' + path, import.meta.url), 'utf8');
const input = {source: read(migrationPath), catalog: read('tool/backend_ci/catalog.sql'),
  expected: JSON.parse(read('tool/deploy/content-limits-reviewed-state.json'))};
const plan = makePlan(input.source, input.catalog, input.expected);
const revision = 'a'.repeat(40);
const now = Date.parse('2026-10-08T12:00:00Z');
const env = {GITHUB_ACTIONS: 'true', RUNNER_ENVIRONMENT: 'github-hosted', GITHUB_REPOSITORY: repository,
  GITHUB_EVENT_NAME: 'push', GITHUB_REF: deploymentRef, GITHUB_SHA: revision,
  GITHUB_TOKEN: 'synthetic-github', QUESTWELL_CONTENT_MIGRATION_TOKEN: 'synthetic-content'};
const approval = {status: 'approved', project: input.expected.project,
  migration_name: input.expected.migration_name, payload_sha256: sha256(plan.sql),
  approval_ref: 'synthetic approval only', backup_evidence_ref: 'synthetic backup only',
  backup_completed_at: '2026-10-08T10:00:00Z',
  backup_verified_at: '2026-10-08T11:00:00Z', valid_until: '2026-10-08T13:00:00Z'};
const applied = () => ({...plan.after, records: [{version: '20261008120000', statements: [plan.sql]}]});

function fixture(patch = {}) {
  const requests = [];
  let stateReads = 0, heads = 0;
  const transport = async (url, options) => {
    requests.push({url, options});
    assert.equal(options.redirect, 'error');
    assert.ok(options.signal instanceof AbortSignal);
    let data;
    if (url.endsWith('/branches/questwell-dev')) {
      data = {commit: {sha: ++heads === 2 && patch.advanced ? 'b'.repeat(40) : revision}};
    } else if (url.includes('/check-runs?')) {
      data = {total_count: requiredChecks.length, check_runs: requiredChecks.map((name, i) => ({name,
        id: i + 1, head_sha: revision, app: {slug: 'github-actions'}, status: 'completed', conclusion: 'success'}))};
      if (patch.check) patch.check(data);
    } else if (url.endsWith('/staging/questwell-version.json')) {
      data = {revision, environment: 'staging', project: 'hpjzfytwivlpsdhiupyd', ...patch.staging};
    } else if (url.endsWith('/questwell-version.json')) {
      data = {revision: patch.served ?? revision};
    } else if (url.endsWith('/database/query')) {
      assert.equal(options.headers.Authorization, 'Bearer synthetic-content');
      const body = JSON.parse(options.body);
      assert.equal(body.read_only, true);
      assert.equal(body.query, plan.query);
      data = [{state: ++stateReads === 1 ? (patch.before ?? plan.before) : (patch.after ?? applied())}];
    } else if (url.endsWith('/database/migrations')) {
      assert.equal(url, `https://api.supabase.com/v1/projects/${input.expected.project}/database/migrations`);
      assert.deepEqual(JSON.parse(options.body), {name: input.expected.migration_name, query: plan.sql});
      if (patch.writeError) throw Error('synthetic timeout with private body');
      data = {};
    } else throw Error('Unexpected endpoint');
    return {ok: true, json: async () => data};
  };
  return {requests, writes: () => requests.filter(r => r.url.endsWith('/database/migrations')).length,
    run: (changes = {}) => runDeployment({...input, env, approval, clock: () => now, transport, ...changes})};
}

test('pending approval stops before any network, while offline check needs no secret', async () => {
  const f = fixture();
  await assert.rejects(f.run({approval: JSON.parse(read('tool/deploy/content-limits-approval.json'))}));
  assert.equal(f.requests.length, 0);
  const cli = new URL('../deploy/content-limits.mjs', import.meta.url).pathname;
  const result = spawnSync(process.execPath, [cli, '--check'], {encoding: 'utf8', env: {}});
  assert.equal(result.status, 0);
  for (const flag of ['--apply', '--project=other', '--approval=other']) {
    const refused = spawnSync(process.execPath, [cli, flag], {encoding: 'utf8', env: {}});
    assert.notEqual(refused.status, 0);
    assert.equal(refused.stdout, '');
    assert.doesNotMatch(refused.stderr, /AssertionError|query|synthetic-content/);
  }
});

test('approval binds payload, target and evidence with bounded backup age', () => {
  verifyApproval(approval, plan.sql, now);
  for (const patch of [{status: 'pending'}, {project: 'other'}, {migration_name: 'other'},
    {payload_sha256: '0'.repeat(64)}, {approval_ref: ''}, {backup_evidence_ref: null},
    {backup_verified_at: '2026-10-07T10:00:00Z'}, {backup_verified_at: '2026-10-08T12:01:00Z'},
    {backup_completed_at: '2026-10-07T10:00:00Z'}, {backup_completed_at: '2026-10-08T11:01:00Z'},
    {backup_completed_at: null},
    {valid_until: '2026-10-08T12:00:00Z'}, {valid_until: '2026-10-10T00:00:00Z'},
    {backup_verified_at: 'bad'}]) assert.throws(() => verifyApproval({...approval, ...patch}, plan.sql, now));
});

test('foreign contexts or credentials cannot reach network', async () => {
  deploymentContext(env);
  for (const patch of [{GITHUB_ACTIONS: 'false'}, {RUNNER_ENVIRONMENT: 'self-hosted'},
    {GITHUB_REF: 'refs/heads/questwell-dev'}, {GITHUB_EVENT_NAME: 'pull_request'},
    {GITHUB_REPOSITORY: 'other/repo'}, {QUESTWELL_CONTENT_MIGRATION_TOKEN: ''},
    {GITHUB_TOKEN: ''}, {GITHUB_SHA: 'bad'}, {DATABASE_URL: 'unexpected'}, {PGHOST: 'other'},
    {SUPABASE_ACCESS_TOKEN: 'other'}]) {
    const f = fixture();
    await assert.rejects(f.run({env: {...env, ...patch}}));
    assert.equal(f.requests.length, 0);
  }
});

test('failed, foreign, missing and incomplete checks stop before database access', async () => {
  for (const check of [d => { d.check_runs[0].conclusion = 'failure'; },
    d => { d.check_runs[0].head_sha = 'b'.repeat(40); }, d => { d.check_runs[0].app.slug = 'other'; },
    d => { d.check_runs.pop(); }, d => { d.total_count = 101; },
    d => { d.check_runs.push({...d.check_runs[0], id: 99, conclusion: null, status: 'in_progress'}); }]) {
    const f = fixture({check});
    await assert.rejects(f.run());
    assert.ok(!f.requests.some(r => r.url.includes('api.supabase.com')));
  }
});

test('delivery, schema and head drift refuse the mutation', async () => {
  for (const patch of [{served: 'old'}, {staging: {revision: 'old'}},
    {staging: {project: 'other'}}, {before: {...plan.before, history_count: 99}}, {advanced: true}]) {
    const f = fixture(patch);
    await assert.rejects(f.run());
    assert.equal(f.writes(), 0);
  }
  const f = fixture();
  let clocks = 0;
  await assert.rejects(f.run({clock: () => ++clocks === 1 ? now : now + 7200000}));
  assert.equal(f.writes(), 0);
});

test('successful rollout makes exactly one migration request and verifies its record', async () => {
  const f = fixture();
  assert.equal((await f.run()).result, 'content limits applied and recorded');
  assert.equal(f.writes(), 1);
});

test('unknown write outcome or failed postcondition is never retried', async () => {
  for (const patch of [{writeError: true}, {after: {...applied(), trigger_count: 3}}]) {
    const f = fixture(patch);
    await assert.rejects(f.run());
    assert.equal(f.writes(), 1);
  }
});

test('already applied state is verified without writing; fake or duplicate records fail', async () => {
  const f = fixture({before: applied()});
  assert.match((await f.run()).result, /without a write/);
  assert.equal(f.writes(), 0);
  for (const records of [[], [...applied().records, ...applied().records],
    [{version: 'bad', statements: [plan.sql]}], [{version: '20261008120000', statements: ['wrong']}],
    [{version: '20261008120000', statements: [plan.sql, 'delete from public.tasks;']}],
    [{version: '20261008120000', statements: [`-- questwell-content-source-sha256:${plan.sourceDigest}\nselect 1;`]}],
    [{version: '20261008120000', statements: [null]}]]) {
    assert.throws(() => verifyApplied({...applied(), records}, plan));
    const broken = fixture({before: {...applied(), records}});
    await assert.rejects(broken.run());
    assert.equal(broken.writes(), 0);
  }
});
