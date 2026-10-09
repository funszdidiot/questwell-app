// One scoped additive rollout. This module never connects to a database.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
export const project = 'bdzcazkyypopbanbjnud';
export const migrationPath = 'supabase/migrations/20261009044431_decorate_hearth_layouts.sql';
export const sha256 = value => createHash('sha256').update(value).digest('hex');
const table = "item->>'schema'='private' and item->>'name'='hearth_saved_layouts'";
const member = "item->>'schema'='private' and item->>'table_name'='hearth_saved_layouts'";
const functions = "item->>'schema' in ('public','private') and item->>'name' in ('read_hearth_layouts','save_hearth_layout')";
const grants = `(${table}) or (item->>'kind'='function' and item->>'schema' in ('public','private') and (item->>'name' like 'read_hearth_layouts(%' or item->>'name' like 'save_hearth_layout(%'))`;
const scopes = {tables:table, columns:member, constraints:member, indexes:member, functions, grants};
const quote = value => `'${value.replaceAll("'", "''")}'`;
export function stateQuery(catalogSql) {
  const filtered = (key, negate) => `(select coalesce(jsonb_agg(item order by ordinal),'[]'::jsonb) from jsonb_array_elements(catalog->'${key}') with ordinality as a(item,ordinal) where ${negate ? 'not' : ''} (${scopes[key]}))`;
  return `with source_catalog as (${catalogSql.trim().replace(/;$/, '')}), separated as (
    select catalog || jsonb_build_object(${Object.keys(scopes).map(k=>`'${k}',${filtered(k,true)}`).join(',')}) as protected,
    jsonb_build_object(${Object.keys(scopes).map(k=>`'${k}',${filtered(k,false)}`).join(',')}) as scoped from source_catalog),
    history as (select coalesce(jsonb_agg(to_jsonb(m) order by version),'[]'::jsonb) as entries from supabase_migrations.schema_migrations m)
    select jsonb_build_object('protected_sha256',(select encode(sha256(convert_to(protected::text,'UTF8')),'hex') from separated),
    'scoped_sha256',(select encode(sha256(convert_to(scoped::text,'UTF8')),'hex') from separated),
    'tables',(select jsonb_array_length(scoped->'tables') from separated),
    'functions',(select jsonb_array_length(scoped->'functions') from separated),
    'history_sha256',(select encode(sha256(convert_to(entries::text,'UTF8')),'hex') from history),
    'history_count',(select jsonb_array_length(entries) from history)) as state;`;
}
export function guardedPayload(sql, catalog, reviewed) {
  assert.equal(reviewed.project,project);
  assert.equal(reviewed.source_sha256,sha256(sql),'Reviewed source changed');
  assert.equal(reviewed.catalog_sha256,sha256(catalog),'Catalog query changed');
  assert.equal(reviewed.before.tables,0); assert.equal(reviewed.before.functions,0);
  for (const key of ['protected_sha256','scoped_sha256','history_sha256']) assert.match(reviewed.before[key],/^[a-f0-9]{64}$/);
  assert.ok(Number.isSafeInteger(reviewed.before.history_count) && reviewed.before.history_count > 0);
  const query=stateQuery(catalog);
  return `-- Decorate Hearth source SHA256: ${reviewed.source_sha256}
-- Target ${project}. Submit once using a migration-recording transaction after scoped approval.
set local statement_timeout='20s';
set local lock_timeout='3s';
do $hearth_rollout$
declare before_state jsonb; after_state jsonb;
begin
  perform pg_catalog.pg_advisory_xact_lock(784310052028::bigint);
  lock table public.users, public.user_cosmetics, public.cosmetics,
    public.hearth_profile_slots, supabase_migrations.schema_migrations in share row exclusive mode;
  execute $hearth_query$${query}$hearth_query$ into before_state;
  if before_state is distinct from ${quote(JSON.stringify(reviewed.before))}::jsonb then
    raise exception 'Hearth deployment precondition drift';
  end if;
${sql}
  execute $hearth_query$${query}$hearth_query$ into after_state;
  if (after_state - 'tables' - 'functions' - 'scoped_sha256') is distinct from
    (before_state - 'tables' - 'functions' - 'scoped_sha256')
    or after_state->>'tables' <> '1' or after_state->>'functions' <> '4' then
    raise exception 'Hearth deployment scope mismatch';
  end if;
  if exists(select 1 from private.hearth_saved_layouts) then raise exception 'Unexpected saved layouts'; end if;
  if has_function_privilege('anon','public.read_hearth_layouts()','execute')
    or has_function_privilege('anon','public.save_hearth_layout(jsonb,bigint,jsonb)','execute')
    or has_table_privilege('authenticated','private.hearth_saved_layouts','select,insert,update,delete')
    or not (select relrowsecurity from pg_class where oid='private.hearth_saved_layouts'::regclass) then
    raise exception 'Hearth deployment permissions mismatch';
  end if;
  perform pg_catalog.pg_notify('pgrst','reload schema');
end $hearth_rollout$;\n`;
}
