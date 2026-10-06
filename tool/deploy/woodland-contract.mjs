import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

export const project = 'bdzcazkyypopbanbjnud';
export const repository = 'funszdidiot/questwell-app';
export const deploymentRef = 'refs/heads/deploy/male-woodland-approved';
export const migrationName = 'male_woodland_approved_rollout';
export const migrationPath = 'supabase/migrations/20261005175137_male_woodland_approved_rollout.sql';
export const description = 'Moss leather, an ivory rolled-sleeve shirt, reinforced trousers and travel boots. Available for female, neutral and male Scout avatars.';
export const sha256 = text => createHash('sha256').update(text).digest('hex');
const digest = /^[a-f0-9]{64}$/;
const sqlQuote = value => `'${value.replaceAll("'", "''")}'`;

// Metadata/catalog only. No user-owned row, task, balance or credential is read.
// Omit only this predicate's definition from the protected schema fingerprint;
// its owner, signature, ACL and all other recorded objects remain protected.
export function stateQuery(catalogSql, sourceHash) {
  assert.match(sourceHash, digest);
  return `with source_catalog as (${catalogSql.trim().replace(/;$/, '')}),
protected as (select jsonb_set(catalog, '{functions}',
  (select jsonb_agg(case when f->>'schema'='private' and f->>'name'='cosmetic_supports_body'
    then f-'definition' else f end order by ordinal)
  from jsonb_array_elements(catalog->'functions') with ordinality as fn(f,ordinal))) as catalog
  from source_catalog),
history as (select coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name,
  'statements',statements) order by version),'[]'::jsonb) as entries
  from supabase_migrations.schema_migrations where name is distinct from '${migrationName}')
select jsonb_build_object(
  'protected_schema_sha256',(select encode(sha256(convert_to(catalog::text,'UTF8')),'hex') from protected),
  'prior_history_sha256',(select encode(sha256(convert_to(entries::text,'UTF8')),'hex') from history),
  'prior_history_count',(select jsonb_array_length(entries) from history),
  'fit_sha256',encode(sha256(convert_to(pg_get_functiondef('private.cosmetic_supports_body(text,text)'::regprocedure),'UTF8')),'hex'),
  'woodland_rows',(select coalesce(jsonb_agg(to_jsonb(c) order by id),'[]'::jsonb)
    from public.cosmetics c where slug='woodland-scout-outfit'),
  'records',(select coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name,
    'source_matches',position('questwell-source-sha256:${sourceHash}' in array_to_string(statements,E'\\n'))>0)
    order by version),'[]'::jsonb) from supabase_migrations.schema_migrations where name='${migrationName}')
) as state;`;
}

export function validateBefore(expected) {
  for (const key of ['protected_schema_sha256','prior_history_sha256','fit_sha256','after_fit_sha256','source_sha256']) {
    assert.match(expected[key],digest,`Invalid ${key}`);
  }
  assert.ok(Number.isInteger(expected.prior_history_count) && expected.prior_history_count>0);
  assert.equal(expected.woodland_rows.length,1);
  const c = expected.woodland_rows[0];
  assert.equal(c.slug,'woodland-scout-outfit'); assert.equal(c.category,'chest');
  assert.equal(c.price,120); assert.equal(c.required_archetype,'scout');
  assert.equal(c.collection_key,'woodland-scout'); assert.equal(c.unlock_method,'shop');
  assert.equal(c.edition_type,'standard'); assert.equal(c.active,true); assert.equal(c.premium,false);
  assert.deepEqual(expected.records,[]);
}

export function afterState(expected) {
  validateBefore(expected);
  return {...expected,fit_sha256:expected.after_fit_sha256,
    woodland_rows:[{...expected.woodland_rows[0],description}]};
}

function sameProtectedState(expected, actual) {
  for (const key of ['protected_schema_sha256','prior_history_sha256','prior_history_count']) {
    assert.deepEqual(actual[key],expected[key],`Database drift: ${key}`);
  }
}

export function assertSqlEffect(expected, actual) {
  sameProtectedState(expected,actual);
  const after = afterState(expected);
  assert.equal(actual.fit_sha256,after.fit_sha256,'Post-migration fit differs');
  assert.deepEqual(actual.woodland_rows,after.woodland_rows,'Post-migration catalog differs');
}

export function classifyState(expected, actual) {
  validateBefore(expected); sameProtectedState(expected,actual);
  assert.ok(Array.isArray(actual.records),'Missing migration history result');
  if (actual.records.length) {
    assert.equal(actual.records.length,1,'Duplicate migration records');
    assert.match(actual.records[0].version,/^\d{14}$/);
    assert.equal(actual.records[0].name,migrationName);
    assert.equal(actual.records[0].source_matches,true,'Applied migration provenance differs');
    assertSqlEffect(expected,actual);
    return 'applied';
  }
  assert.equal(actual.fit_sha256,expected.fit_sha256,'Fit changed without the reviewed migration record');
  assert.deepEqual(actual.woodland_rows,expected.woodland_rows,'Woodland catalog drift');
  return 'before';
}

// One atomic SQL statement, generated from the hash-locked versioned migration.
// No replay/reset/repair, and no implicit catch-up of other pending migrations.
// The Management API records a new server-assigned version after applying it.
export function guardedMigration(sourceSql, catalogSql, expected) {
  validateBefore(expected);
  assert.equal(sha256(sourceSql),expected.source_sha256,'Reviewed migration bytes changed');
  const begin = sourceSql.indexOf('\nbegin;\n'), end = sourceSql.lastIndexOf('\ncommit;');
  assert.ok(begin>=0 && end>begin && sourceSql.slice(end).trim()==='commit;');
  const body = sourceSql.slice(begin+8,end);
  const query = stateQuery(catalogSql,expected.source_sha256);
  assert.ok(!query.includes('$woodland_state$') && !body.includes('$questwell_woodland$'));
  const before = sqlQuote(JSON.stringify({
    protected_schema_sha256:expected.protected_schema_sha256,
    prior_history_sha256:expected.prior_history_sha256,
    prior_history_count:expected.prior_history_count,
    fit_sha256:expected.fit_sha256,woodland_rows:expected.woodland_rows,records:[],
  }));
  const after = sqlQuote(JSON.stringify({
    protected_schema_sha256:expected.protected_schema_sha256,
    prior_history_sha256:expected.prior_history_sha256,
    prior_history_count:expected.prior_history_count,
    fit_sha256:expected.after_fit_sha256,
    woodland_rows:afterState(expected).woodland_rows,records:[],
  }));
  return `-- questwell-source-sha256:${expected.source_sha256}
-- Source: ${migrationPath}; preserved historical migration rows, no catch-up.
do $questwell_woodland$
declare observed jsonb;
begin
  perform pg_catalog.set_config('lock_timeout','5s',true);
  perform pg_catalog.pg_advisory_xact_lock(784310052026::bigint);
  perform 1 from public.cosmetics where slug='woodland-scout-outfit' for update;
  execute $woodland_state$${query}$woodland_state$ into observed;
  if observed is distinct from ${before}::jsonb then
    raise exception 'Woodland deployment precondition drift; no change applied';
  end if;
${body}
  execute $woodland_state$${query}$woodland_state$ into observed;
  if observed is distinct from ${after}::jsonb then
    raise exception 'Woodland deployment postcondition failed; transaction rolled back';
  end if;
end;
$questwell_woodland$;\n`;
}

export function assertDeploymentContext(env) {
  assert.equal(env.GITHUB_ACTIONS,'true','Deployment requires GitHub Actions');
  assert.equal(env.RUNNER_ENVIRONMENT,'github-hosted','Deployment requires a disposable hosted runner');
  assert.equal(env.GITHUB_REPOSITORY,repository,'Wrong repository');
  assert.equal(env.GITHUB_EVENT_NAME,'push','Deployment requires the reviewed branch push');
  assert.equal(env.GITHUB_REF,deploymentRef,'Wrong deployment branch');
  assert.match(env.GITHUB_SHA??'',/^[a-f0-9]{40}$/,'Invalid source revision');
  for (const [key,value] of Object.entries(env)) {
    if (value && (key.startsWith('PG') || key==='DATABASE_URL' || key.startsWith('SUPABASE_'))) {
      throw new Error(`Unexpected database target/credential override: ${key}`);
    }
  }
  assert.ok(env.QUESTWELL_WOODLAND_MIGRATION_TOKEN,'Missing QUESTWELL_WOODLAND_MIGRATION_TOKEN repository Actions secret');
  assert.ok(env.GITHUB_TOKEN,'Missing Actions check-read token');
}

export function assertRequiredChecks(checks, revision) {
  assert.ok(Array.isArray(checks),'Missing reviewed-head checks');
  for (const name of ['analyze','Isolated application schema and smoke tests']) {
    // A previous green attempt must not hide a later failed or incomplete rerun.
    const latest = checks.filter(c=>c.name===name && c.head_sha===revision && c.app?.slug==='github-actions')
      .sort((a,b)=>b.id-a.id)[0];
    assert.ok(latest && Number.isSafeInteger(latest.id) && latest.status==='completed'
      && latest.conclusion==='success',`Required reviewed-head check missing: ${name}`);
  }
}

export function managementRequest(token, endpoint, body, idempotencyKey, transport=fetch) {
  assert.ok(['query','migrations'].includes(endpoint),'Unapproved Management API endpoint');
  if (endpoint==='query') assert.equal(body.read_only,true,'Metadata queries must be read-only');
  return transport(`https://api.supabase.com/v1/projects/${project}/database/${endpoint}`,{
    method:'POST',redirect:'error',signal:AbortSignal.timeout(60000),
    headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json',
      ...(idempotencyKey?{'Idempotency-Key':idempotencyKey}:{})},body:JSON.stringify(body),
  });
}

export async function deployWoodland({expected,sourceSql,catalogSql,readState,applyMigration}) {
  // Validate the complete payload before any live read or write.
  const query = guardedMigration(sourceSql,catalogSql,expected);
  const initial = await readState();
  if (classifyState(expected,initial)==='applied') return {status:'already_applied',version:initial.records[0].version};
  // Deliberately no retry: a timeout may follow a committed migration.
  // A later explicit rerun first reconciles state and its history record.
  await applyMigration({name:migrationName,query},`questwell-woodland-${expected.source_sha256}`);
  const final = await readState();
  assert.equal(classifyState(expected,final),'applied','Migration record missing after application');
  return {status:'applied',version:final.records[0].version};
}
