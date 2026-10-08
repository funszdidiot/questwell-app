// Metadata-only contract for the single approved content-limit migration.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

export const project = 'bdzcazkyypopbanbjnud';
export const migrationName = 'approved_content_limits_live';
export const migrationPath = 'supabase/migrations/20261008023552_approved_content_limits.sql';
export const sha256 = value => createHash('sha256').update(value).digest('hex');
const digest = /^[a-f0-9]{64}$/;
const quote = value => `'${value.replaceAll("'", "''")}'`;
const functions = "item->>'schema'='private' and item->>'name' in ('enforce_content_limits','enforce_boss_step_limit')";
const triggers = "item->>'schema'='public' and item->>'name' in ('content_limits_tasks','content_limits_bosses','content_limits_steps','content_limits_step_count')";
const grants = "item->>'kind'='function' and item->>'schema'='private' and item->>'name' in ('enforce_content_limits()','enforce_boss_step_limit()')";
const scoped = {functions, triggers, grants};

export function stateQuery(catalogSql) {
  const arrays = (key, include) => `(select coalesce(jsonb_agg(item order by ordinal),'[]'::jsonb)
    from jsonb_array_elements(catalog->'${key}') with ordinality as a(item,ordinal)
    where ${include ? '' : 'not '}(${scoped[key]}))`;
  return `with source_catalog as (${catalogSql.trim().replace(/;$/, '')}),
  separated as (select
    catalog || jsonb_build_object(${Object.keys(scoped).map(k => `'${k}',${arrays(k, false)}`).join(',')}) as protected,
    jsonb_build_object(${Object.keys(scoped).map(k => `'${k}',${arrays(k, true)}`).join(',')}) as limits
    from source_catalog),
  history as (select coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name,
    'statements',statements) order by version),'[]'::jsonb) as entries
    from supabase_migrations.schema_migrations where name is distinct from '${migrationName}')
  select jsonb_build_object(
    'protected_schema_sha256',(select encode(sha256(convert_to(protected::text,'UTF8')),'hex') from separated),
    'limits_sha256',(select encode(sha256(convert_to(limits::text,'UTF8')),'hex') from separated),
    'function_count',(select jsonb_array_length(limits->'functions') from separated),
    'trigger_count',(select jsonb_array_length(limits->'triggers') from separated),
    'grant_count',(select jsonb_array_length(limits->'grants') from separated),
    'history_sha256',(select encode(sha256(convert_to(entries::text,'UTF8')),'hex') from history),
    'history_count',(select jsonb_array_length(entries) from history),
    'rollout_records',(select count(*) from supabase_migrations.schema_migrations where name='${migrationName}')
  ) as state;`;
}

export function guardedPayload(sourceSql, catalogSql, expected) {
  assert.equal(expected.project, project, 'Unexpected deployment target');
  assert.equal(expected.migration_name, migrationName);
  assert.equal(expected.migration_path, migrationPath);
  assert.equal(sha256(sourceSql), expected.source_sha256, 'Approved source changed');
  assert.equal(sha256(catalogSql), expected.catalog_sql_sha256, 'Catalog query changed');
  assert.match(expected.after_limits_sha256, digest);
  assert.ok(expected.before && Object.keys(expected.before).length === 8);
  for (const key of ['protected_schema_sha256','limits_sha256','history_sha256']) assert.match(expected.before[key], digest);
  for (const key of ['function_count','trigger_count','grant_count','rollout_records']) assert.equal(expected.before[key], 0);
  assert.ok(Number.isSafeInteger(expected.before.history_count) && expected.before.history_count > 0);
  assert.notEqual(expected.after_limits_sha256, expected.before.limits_sha256);
  assert.ok(!sourceSql.includes('$questwell_content$') && !catalogSql.includes('$content_state$'));
  const after = {...expected.before, limits_sha256: expected.after_limits_sha256,
    function_count: 2, trigger_count: 4, grant_count: expected.after_grant_count};
  assert.equal(expected.after_grant_count, 2, 'Only owner EXECUTE grants are expected');
  const query = stateQuery(catalogSql);
  return `-- questwell-content-source-sha256:${expected.source_sha256}
-- Fixed target ${project}; migration-recording transaction required.
set local statement_timeout = '20s';
do $questwell_content$
declare observed jsonb;
begin
  perform pg_catalog.set_config('lock_timeout','3s',true);
  perform pg_catalog.pg_advisory_xact_lock(784310052027::bigint);
  lock table public.tasks, public.boss_battles, public.boss_steps,
    supabase_migrations.schema_migrations in share row exclusive mode;
  execute $content_state$${query}$content_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(expected.before))}::jsonb then
    raise exception 'Content deployment precondition drift; no change applied';
  end if;
${sourceSql}
  execute $content_state$${query}$content_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(after))}::jsonb then
    raise exception 'Content deployment postcondition mismatch; transaction rolled back';
  end if;
  perform pg_catalog.pg_notify('pgrst','reload schema');
end $questwell_content$;\n`;
}
