// Synthetic, disposable CI only. This is NOT a hosted backup/restore command.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash, randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';
import {assertCatalogMatches} from './catalog.mjs';

const dbContainer = 'supabase_db_questwell-disposable-ci';
const services = ['auth', 'rest', 'storage'].map(s => `supabase_${s}_questwell-disposable-ci`);
const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');

export function assertMissingRecoveryFile(response, absentOnDisk) {
  // Storage hides filesystem error details. Absence must be independently
  // proven at the exact pre-loss, hash-verified path; HTTP 500 alone is no proof.
  assert.equal(absentOnDisk, true, 'Exact synthetic file absence must be verified');
  assert.ok((response.status === 500 && response.data?.code === 'InternalError') ||
    ([400,404].includes(response.status) && response.data?.code === 'NoSuchKey'),
    `Expected missing-file response with disk evidence; received HTTP ${response.status}`);
}

// Deliberately return fixed labels, never fragments of SQL, COPY rows or secrets.
export function recoveryFailureCategories(stderr) {
  const patterns = {
    extension_database_restriction: /can only (?:create extension|be installed) in database/i,
    already_exists: /already exists/i,
    permission_denied: /permission denied/i,
    must_be_owner: /must be owner|must be member|must be superuser/i,
    missing_role: /role .+ does not exist/i,
    missing_schema: /schema .+ does not exist/i,
    missing_relation: /relation .+ does not exist/i,
    missing_function: /function .+ does not exist/i,
    missing_extension: /extension .+ is not available/i,
    configuration_parameter: /unrecognized configuration parameter|cannot change parameter/i,
    duplicate_key: /duplicate key/i,
    foreign_key: /foreign key constraint/i,
    check_constraint: /check constraint/i,
    invalid_input: /invalid input syntax/i,
    archive_version: /unsupported version|not a valid archive/i,
    connection: /could not connect|connection.+failed|connection.+closed/i,
  };
  return Object.entries(patterns).filter(([,pattern]) => pattern.test(String(stderr))).map(([name]) => name);
}

export function assertRecoveryEnvironment(env, status) {
  assertDisposableCi(env);
  assertLocalStatus(status);
  assert.ok(!env.DOCKER_HOST && !env.DOCKER_CONTEXT && !env.DOCKER_CONFIG, 'Docker target/config overrides are forbidden');
}

export async function rehearseRecovery(status) {
  assertRecoveryEnvironment(process.env, status);
  const docker = (args, input, binary = false) => {
    assertRecoveryEnvironment(process.env, status);
    // Override persisted currentContext as well as rejecting env target overrides.
    const result = spawnSync('docker', ['--host=unix:///var/run/docker.sock', ...args], {
      input, encoding: binary ? undefined : 'utf8', timeout: 120000,
      maxBuffer: 64 * 1024 * 1024,
    });
    // Dump/SQL errors can contain Auth data. Never print stdout/stderr on failure.
    if (result.status !== 0) console.error(JSON.stringify({recovery_command_failed: args[0],
      categories: recoveryFailureCategories(result.stderr)}));
    assert.equal(result.status, 0, `Disposable recovery command ${args[0]} failed (${result.error?.code ?? 'nonzero exit'}); output withheld`);
    return result.stdout;
  };
  const sql = (statement, database = 'postgres') => {
    assert.ok(['postgres', 'template1', 'questwell_restore_ci'].includes(database));
    return docker(['exec', '-i', dbContainer, 'psql', '--host=/var/run/postgresql',
      '--username=supabase_admin', `--dbname=${database}`, '--no-password', '-X',
      '--quiet', '--tuples-only', '--no-align', '--set=ON_ERROR_STOP=1', '--file=-'], statement).trim();
  };
  const request = async (path, owner, method = 'GET', body, headers = {}) => {
    const r = await localRequest(status, path, {method,
      headers: {apikey: status.ANON_KEY, ...(owner ? {authorization: `Bearer ${owner.token}`} : {}),
        'content-type': 'application/json', Prefer: 'return=representation', ...headers},
      ...(body === undefined ? {} : {body: Buffer.isBuffer(body) ? body : JSON.stringify(body)})});
    const bytes = Buffer.from(await r.arrayBuffer());
    let data; try { data = JSON.parse(bytes.toString()); } catch { data = null; }
    return {status: r.status, data, bytes};
  };
  const ok = (r, expected = 200) => assert.equal(r.status, expected, `Recovery HTTP expected ${expected}; received ${r.status}`);
  const denied = r => assert.ok([400,401,403,404].includes(r.status), `Recovery denial expected; received ${r.status}`);
  const signup = async () => {
    const email = `recovery-ci-${randomUUID()}@example.test`, password = `Ci-${randomUUID()}-9!`;
    const r = await request('/auth/v1/signup', null, 'POST', {email, password});
    ok(r); assert.ok(r.data.user?.id && r.data.access_token);
    return {id: r.data.user.id, token: r.data.access_token, email, password};
  };
  const a = await signup(), b = await signup();
  for (const owner of [a, b]) {
    ok(await request('/rest/v1/rpc/create_task_once', owner, 'POST', {
      p_request_id: randomUUID(), p_expected_user_id: owner.id,
      p_title: 'Synthetic recovery quest', p_friction: 1,
    }));
    const r = await request('/rest/v1/tasks?select=id', owner); ok(r);
    assert.equal(r.data.length, 1); owner.task = r.data[0].id;
  }
  ok(await request('/rest/v1/rpc/complete_task', a, 'POST', {p_task_id: a.task}));
  ok(await request('/rest/v1/rpc/create_boss_once', a, 'POST', {
    p_request_id: randomUUID(), p_expected_user_id: a.id,
    p_title: 'Synthetic recovery boss', p_steps: ['First', 'Second'], p_boss_type: 'inbox_hydra',
  }));
  const objectPath = `${a.id}/recovery.png`;
  // Actual small PNG bytes, not a metadata-only or text placeholder.
  // Generated with Pillow and verified including PNG chunk CRCs before review.
  const originalBytes = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGPwqEwAAAIuASK5cz6PAAAAAElFTkSuQmCC', 'base64');
  ok(await request(`/storage/v1/object/beta-feedback/${objectPath}`, a, 'POST', originalBytes, {'content-type': 'image/png'}));
  const objectVersion = JSON.parse(sql(`select to_jsonb(version) from storage.objects where bucket_id='beta-feedback' and name='${objectPath}';`));
  assert.ok(objectVersion === null || /^[0-9a-f-]{36}$/.test(objectVersion));
  // Match the pinned adapter's actual configuration; print no other environment.
  const fileVersionSeparator = docker(['exec', 'supabase_storage_questwell-disposable-ci', 'node', '-e',
    "process.stdout.write(process.env.TUS_USE_FILE_VERSION_SEPARATOR === 'true' ? '-$v-' : '/')"]);
  assert.ok(['/', '-$v-'].includes(fileVersionSeparator));
  const probeScript = readFileSync(new URL('./recovery-file-probe.mjs', import.meta.url), 'utf8');
  const fileProbe = input => {
    const result = JSON.parse(docker(['exec', '-i', 'supabase_storage_questwell-disposable-ci',
      'node', '--input-type=module', '-e', probeScript], JSON.stringify(input)));
    assert.ok(!result.error, `Synthetic file probe failed: ${result.error}/${result.reason}`);
    return result;
  };
  const feedbackId = randomUUID();
  ok(await request('/rest/v1/beta_feedback', a, 'POST', {
    id: feedbackId, user_id: a.id, category: 'bug', goal: 'Synthetic recovery',
    message: 'Disposable recovery fixture', screen: 'Other', build: 'ci', platform: 'web',
    attachment_paths: [objectPath],
  }), 201);
  assert.equal(sql("select count(*) from pg_database where datname in ('questwell_restore_ci','questwell_source_ci');"), '0');
  assert.equal(sql("select to_regclass('private.recovery_ci_marker') is null;"), 't');
  const marker = randomUUID();
  sql(`create table private.recovery_ci_marker (id uuid primary key); insert into private.recovery_ci_marker values ('${marker}');`);
  const requireMarker = (database = 'postgres') => assert.equal(sql('select id from private.recovery_ci_marker;', database), marker,
    'This operation requires the newly generated disposable fixture marker');
  requireMarker();

  const start = new Date(), startClock = performance.now();
  const downloadPath = `/storage/v1/object/authenticated/beta-feedback/${objectPath}`;
  const backupFile = await request(downloadPath, a); ok(backupFile);
  assert.equal(sha256(backupFile.bytes), sha256(originalBytes));
  const sourceFile = fileProbe({mode: 'discover', objectPath, version: objectVersion, separator: fileVersionSeparator});
  assert.equal(sourceFile.bytes, backupFile.bytes.length);
  assert.equal(sourceFile.sha256, sha256(backupFile.bytes));
  const requireAbsentFile = () => assert.deepEqual(fileProbe({mode: 'absent', relativePath: sourceFile.relativePath}), {absent: true});
  const catalogSql = readFileSync(new URL('./catalog.sql', import.meta.url), 'utf8');
  const expectedCatalog = JSON.parse(sql(catalogSql));
  // Logical restore reparses CHECK expressions and flattens nested AND nodes.
  // Have PostgreSQL reparse each source CHECK on an empty temporary LIKE table;
  // never strip parentheses in JavaScript or skip constraint comparisons.
  // ROLLBACK discards every temporary DDL change; source tables are untouched.
  const quoteIdent = value => `"${value.replaceAll('"', '""')}"`;
  const checkGroups = new Map();
  for (const constraint of expectedCatalog.constraints.filter(c => c.type === 'c')) {
    const table = `${quoteIdent(constraint.schema)}.${quoteIdent(constraint.table_name)}`;
    if (!checkGroups.has(table)) checkGroups.set(table, []);
    checkGroups.get(table).push(constraint);
  }
  for (const [table, constraints] of checkGroups) {
    const canonical = JSON.parse(sql(`begin; set local search_path=pg_catalog;
      create temporary table recovery_check_parser (like ${table});
      ${constraints.map(c => `alter table pg_temp.recovery_check_parser add constraint ${quoteIdent(c.name)} ${c.definition};`).join('\n')}
      select jsonb_object_agg(conname,pg_get_constraintdef(oid,false)) from pg_constraint
        where conrelid='pg_temp.recovery_check_parser'::regclass and contype='c';
      rollback;`));
    assert.equal(Object.keys(canonical).length, constraints.length);
    for (const c of constraints) {
      assert.equal(typeof canonical[c.name], 'string');
      c.definition = canonical[c.name];
    }
  }
  const tables = JSON.parse(sql(`select jsonb_agg(format('%I.%I', schemaname, tablename) order by schemaname, tablename)
    from pg_tables where schemaname in ('public','private')
    or (schemaname='auth' and tablename in ('users','identities'))
    or (schemaname='storage' and tablename in ('objects','buckets'));`));
  const fingerprint = database => tables.map(table => {
    // Table identifiers come from PostgreSQL format(%I), never external input.
    const result = JSON.parse(sql(`select jsonb_build_object('count',count(*),
      'hash',md5(coalesce(jsonb_agg(to_jsonb(t) order by to_jsonb(t)::text)::text,'[]'))) from ${table} t;`, database));
    return {table, ...result};
  });
  const expectedRows = fingerprint('postgres');
  const recoveryPointLowerBound = new Date();
  // Full logical database backup keeps original ownership, grants, Auth and Storage
  // schemas. Roles/extensions come from the identical disposable platform image.
  // The archive stays in memory: no secrets, dumps or rows become CI artifacts.
  const archive = docker(['exec', dbContainer, 'pg_dump', '--host=/var/run/postgresql',
    '--username=supabase_admin', '--dbname=postgres', '--no-password', '--format=custom'], undefined, true);
  assert.ok(archive.length > 1000 && archive.subarray(0,5).toString() === 'PGDMP', 'Expected custom logical backup');
  const archiveHash = sha256(archive);
  requireMarker();
  sql('create database questwell_restore_ci template template0;', 'template1');
  assert.equal(sql("select to_regclass('public.users') is null;", 'questwell_restore_ci'), 't');
  // PostgreSQL 17 dumps expect initdb's public schema to exist. Keep that
  // empty template0 schema; pg_restore restores its ownership and privileges.
  assert.equal(sql("select to_regnamespace('public') is not null;", 'questwell_restore_ci'), 't');
  docker(['exec', '-i', dbContainer, 'pg_restore', '--host=/var/run/postgresql',
    '--username=supabase_admin', '--dbname=questwell_restore_ci', '--no-password',
    '--exit-on-error', '--single-transaction'], archive);
  requireMarker('questwell_restore_ci');
  assertCatalogMatches(expectedCatalog, JSON.parse(sql(catalogSql, 'questwell_restore_ci')));
  // Real negative control: a weakened restored CHECK must still fail parity.
  // Capture its catalog inside a transaction, then undo it before proceeding.
  const weakenedCatalog = JSON.parse(sql(`begin;
    alter table public.beta_feedback drop constraint beta_feedback_build_check;
    alter table public.beta_feedback add constraint beta_feedback_build_check check (true);
    ${catalogSql}
    rollback;`, 'questwell_restore_ci'));
  assert.throws(() => assertCatalogMatches(expectedCatalog, weakenedCatalog), /Catalog mismatch: constraints/);
  assertCatalogMatches(expectedCatalog, JSON.parse(sql(catalogSql, 'questwell_restore_ci')));
  assert.deepEqual(fingerprint('questwell_restore_ci'), expectedRows, 'Restored row counts/content differ');
  console.log(`Recovery: separate empty database restored; ${tables.length} table counts/content hashes and application schema/grants/RLS match.`);

  // Model loss of exactly our new synthetic image using the Storage API. Never
  // delete metadata with SQL. Existing hosted accounts/objects are unreachable.
  ok(await request('/storage/v1/object/beta-feedback', a, 'DELETE', {prefixes: [objectPath]}));
  denied(await request(downloadPath, a));
  requireAbsentFile();
  requireMarker();
  docker(['stop', ...services]);
  // Redirect the fixed local services to the restored DB, retaining the source
  // under a different name with connections disabled. Nothing is restored over it.
  sql('alter database postgres allow_connections false;', 'template1');
  sql("select pg_terminate_backend(pid) from pg_stat_activity where datname='postgres';", 'template1');
  sql('alter database postgres rename to questwell_source_ci;', 'template1');
  sql('alter database questwell_restore_ci rename to postgres;', 'template1');
  requireMarker();
  docker(['start', ...services]);
  for (let attempt = 0; ; attempt++) {
    try {
      const storage = await request('/storage/v1/bucket/beta-feedback', {token: status.SERVICE_ROLE_KEY});
      if ((await request('/auth/v1/health', null)).status === 200 &&
        (await request('/rest/v1/', null)).status === 200 && storage.status === 200 &&
        storage.data?.id === 'beta-feedback' && storage.data.public === false) break;
    } catch {}
    assert.ok(attempt < 59, 'Restored local APIs did not become ready');
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  for (const owner of [a, b]) {
    const r = await request('/auth/v1/token?grant_type=password', null, 'POST', {email: owner.email, password: owner.password});
    ok(r); assert.equal(r.data.user.id, owner.id); assert.ok(r.data.access_token);
    owner.token = r.data.access_token; // Fresh sign-in, not a surviving token.
    const own = await request('/rest/v1/tasks?select=id,user_id,status', owner); ok(own);
    assert.deepEqual(own.data, [{id: owner.task, user_id: owner.id, status: owner === a ? 'completed' : 'open'}]);
    const profile = await request('/rest/v1/users?select=id,total_xp,coin_balance', owner); ok(profile);
    assert.deepEqual(profile.data, [{id: owner.id, total_xp: owner === a ? 10 : 0, coin_balance: owner === a ? 5 : 0}]);
  }
  denied(await request('/rest/v1/rpc/complete_task', b, 'POST', {p_task_id: a.task}));
  const rewards = await request('/rest/v1/reward_events?select=task_id,xp_amount,coin_amount', a); ok(rewards);
  assert.deepEqual(rewards.data, [{task_id: a.task, xp_amount: 10, coin_amount: 5}]);
  const feedback = await request('/rest/v1/beta_feedback?select=id,attachment_paths', a); ok(feedback);
  assert.deepEqual(feedback.data, [{id: feedbackId, attachment_paths: [objectPath]}]);
  const otherFeedback = await request('/rest/v1/beta_feedback?select=id', b); ok(otherFeedback); assert.deepEqual(otherFeedback.data, []);
  const bosses = await request('/rest/v1/boss_battles?select=id', a); ok(bosses); assert.equal(bosses.data.length, 1);
  const steps = await request('/rest/v1/boss_steps?select=id', a); ok(steps); assert.equal(steps.data.length, 2);
  // Database metadata is present, but bytes must still be missing after restore.
  assert.equal(sql(`select count(*) from storage.objects where bucket_id='beta-feedback' and name='${objectPath}';`), '1');
  requireAbsentFile();
  assertMissingRecoveryFile(await request(downloadPath, a), true);
  // Use the real owner API, not a service-role upsert that can lose owner_id.
  // Existing policies deliberately grant no UPDATE. Recreate exactly this new
  // synthetic object; feedback references its stable path, not its internal ID.
  ok(await request('/storage/v1/object/beta-feedback', a, 'DELETE', {prefixes: [objectPath]}));
  assert.equal(sql(`select count(*) from storage.objects where bucket_id='beta-feedback' and name='${objectPath}';`), '0');
  ok(await request(`/storage/v1/object/beta-feedback/${objectPath}`, a, 'POST',
    backupFile.bytes, {'content-type': 'image/png'}));
  assert.equal(sql(`select owner_id from storage.objects where bucket_id='beta-feedback' and name='${objectPath}';`), a.id);
  const ownedFiles = await request('/rest/v1/rpc/account_deletion_objects', {token: status.SERVICE_ROLE_KEY},
    'POST', {p_user_id: a.id}); ok(ownedFiles);
  assert.deepEqual(ownedFiles.data, [{bucket_id: 'beta-feedback', name: objectPath, owner_id: a.id}]);
  const recoveredFile = await request(downloadPath, a); ok(recoveredFile);
  assert.equal(recoveredFile.bytes.length, originalBytes.length);
  assert.equal(sha256(recoveredFile.bytes), sha256(originalBytes));
  denied(await request(downloadPath, b));
  denied(await request(downloadPath, null));
  const elapsedSeconds = Math.ceil((performance.now() - startClock) / 1000), end = new Date();
  const recoveryPointAgeSeconds = Math.ceil((end - recoveryPointLowerBound) / 1000);
  assert.ok(elapsedSeconds <= 8 * 3600 && recoveryPointAgeSeconds <= 24 * 3600);
  console.log(JSON.stringify({check: 'synthetic recovery', result: 'passed',
    started_at: start.toISOString(), recovery_point_not_before: recoveryPointLowerBound.toISOString(),
    completed_at: end.toISOString(), elapsed_seconds: elapsedSeconds,
    recovery_point_age_seconds: recoveryPointAgeSeconds, checked_tables: tables.length,
    archive_sha256: archiveHash, restored_file_bytes: recoveredFile.bytes.length,
    restored_file_sha256: sha256(recoveredFile.bytes), fresh_signins: 2,
    source: 'disposable CI only', scope: 'same platform roles/image; full logical database and one actual file',
    production_recovery_verified: false, scheduled_backup_verified: false}));
}
