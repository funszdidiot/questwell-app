import assert from 'node:assert/strict';
import {guardedPayload, stateQuery, project, migrationName, sha256} from './content-limits-contract.mjs';

export const repository = 'funszdidiot/questwell-app';
export const deploymentRef = 'refs/heads/deploy/content-limits-approved';
export const requiredChecks = ['quality / analyze', 'quality / Critical client coverage',
  'quality / android / signing', 'quality / iOS unsigned release compile',
  'Isolated application schema and smoke tests', 'Content rollout runner guards'];
const day = 24 * 60 * 60 * 1000;

export function deploymentContext(env) {
  assert.equal(env.GITHUB_ACTIONS, 'true', 'GitHub Actions required');
  assert.equal(env.RUNNER_ENVIRONMENT, 'github-hosted', 'Hosted runner required');
  assert.equal(env.GITHUB_REPOSITORY, repository, 'Wrong repository');
  assert.equal(env.GITHUB_EVENT_NAME, 'push', 'Push event required');
  assert.equal(env.GITHUB_REF, deploymentRef, 'Dedicated deployment branch required');
  assert.match(env.GITHUB_SHA ?? '', /^[a-f0-9]{40}$/, 'Invalid revision');
  assert.ok(env.GITHUB_TOKEN, 'Missing GitHub read token');
  assert.ok(env.QUESTWELL_CONTENT_MIGRATION_TOKEN, 'Missing scoped content token');
  for (const [key, value] of Object.entries(env)) {
    if (value && (key.startsWith('PG') || key.startsWith('SUPABASE_') || key === 'DATABASE_URL')) {
      throw Error('Unexpected database override');
    }
  }
}

export function verifyApproval(approval, sql, now) {
  assert.equal(approval.status, 'approved', 'Exact live deployment approval is pending');
  assert.equal(approval.project, project, 'Approval target differs');
  assert.equal(approval.migration_name, migrationName, 'Approval scope differs');
  assert.equal(approval.payload_sha256, sha256(sql), 'Approval payload differs');
  for (const key of ['approval_ref', 'backup_evidence_ref']) {
    assert.ok(typeof approval[key] === 'string' && approval[key].trim().length > 0, 'Approval evidence missing');
  }
  const backup = Date.parse(approval.backup_completed_at);
  const verified = Date.parse(approval.backup_verified_at);
  const expiry = Date.parse(approval.valid_until);
  assert.ok([now, backup, verified, expiry].every(Number.isFinite), 'Invalid approval times');
  assert.ok(backup <= verified && verified <= now && now - backup <= day, 'Backup is stale or future-dated');
  assert.ok(now < expiry && expiry <= backup + day, 'Deployment approval expired or too long');
}

export function makePlan(source, catalog, expected) {
  const sql = guardedPayload(source, catalog, expected);
  const query = `with metadata as (${stateQuery(catalog).trim().replace(/;$/, '')})
select state || jsonb_build_object('records',
  (select coalesce(jsonb_agg(jsonb_build_object('version',version,'statements',statements) order by version),'[]'::jsonb)
   from supabase_migrations.schema_migrations where name='${migrationName}')) as state from metadata;`;
  const after = {...expected.before, limits_sha256: expected.after_limits_sha256,
    function_count: 2, trigger_count: 4, grant_count: 2, rollout_records: 1};
  return {sql, query, before: {...expected.before, records: []}, after,
    sourceDigest: expected.source_sha256};
}

export function verifyApplied(actual, plan) {
  const {records, ...state} = actual;
  assert.deepEqual(state, plan.after, 'Applied metadata differs');
  assert.ok(Array.isArray(records) && records.length === 1, 'One recorded migration required');
  assert.match(records[0].version, /^\d{14}$/, 'Invalid migration version');
  assert.ok(Array.isArray(records[0].statements) && records[0].statements.length > 0 &&
    records[0].statements.every(s => typeof s === 'string'), 'Invalid recorded statements');
  assert.equal(sha256(records[0].statements.join('\n')), sha256(plan.sql),
    'Complete recorded payload differs');
}

// The injected transport exists for network-free failure testing. The CLI uses fetch.
export async function runDeployment({env, source, catalog, expected, approval,
  transport = fetch, clock = Date.now}) {
  const plan = makePlan(source, catalog, expected);
  deploymentContext(env);
  verifyApproval(approval, plan.sql, clock());
  const request = async (url, options = {}) => {
    const response = await transport(url, {...options, redirect: 'error', signal: AbortSignal.timeout(60000)});
    assert.ok(response.ok, 'HTTP operation failed; reconcile before retry');
    return response.json();
  };
  const github = path => request(`https://api.github.com/repos/${repository}/${path}`, {
    headers: {Authorization: `Bearer ${env.GITHUB_TOKEN}`, Accept: 'application/vnd.github+json'},
  });
  const requireCurrent = async () => assert.equal((await github('branches/questwell-dev')).commit.sha,
    env.GITHUB_SHA, 'Development advanced; reconcile first');
  await requireCurrent();
  const checks = await github(`commits/${env.GITHUB_SHA}/check-runs?filter=latest&per_page=100`);
  assert.ok(Array.isArray(checks.check_runs) && checks.total_count <= 100, 'Incomplete check inventory');
  for (const name of requiredChecks) {
    const latest = checks.check_runs.filter(c => c.name === name && c.head_sha === env.GITHUB_SHA &&
      c.app?.slug === 'github-actions').sort((a, b) => b.id - a.id)[0];
    assert.ok(latest?.status === 'completed' && latest.conclusion === 'success', 'Required check is not successful');
  }
  const base = 'https://funszdidiot.github.io/questwell-app/';
  const served = await request(base + 'questwell-version.json');
  const staging = await request(base + 'staging/questwell-version.json');
  assert.equal(served.revision, env.GITHUB_SHA, 'Development revision is not served');
  assert.equal(staging.revision, env.GITHUB_SHA, 'Staging revision is not served');
  assert.equal(staging.environment, 'staging', 'Wrong staging environment');
  assert.equal(staging.project, 'hpjzfytwivlpsdhiupyd', 'Wrong staging project');
  const management = (endpoint, body) => request(`https://api.supabase.com/v1/projects/${project}/database/${endpoint}`, {
    method: 'POST', headers: {Authorization: `Bearer ${env.QUESTWELL_CONTENT_MIGRATION_TOKEN}`,
      'Content-Type': 'application/json'}, body: JSON.stringify(body),
  });
  const state = async () => {
    const rows = await management('query', {query: plan.query, read_only: true});
    assert.ok(Array.isArray(rows) && rows.length === 1 && rows[0].state, 'Unexpected metadata response');
    return rows[0].state;
  };
  const before = await state();
  if (before.rollout_records !== 0) {
    verifyApplied(before, plan);
    return {revision: env.GITHUB_SHA, result: 'already applied; verified without a write'};
  }
  assert.deepEqual(before, plan.before, 'Live metadata drift; no change applied');
  await requireCurrent();
  verifyApproval(approval, plan.sql, clock());
  // Exactly one migration-recording request, with no retries, including on timeout.
  await management('migrations', {name: migrationName, query: plan.sql});
  verifyApplied(await state(), plan);
  return {revision: env.GITHUB_SHA, result: 'content limits applied and recorded'};
}
