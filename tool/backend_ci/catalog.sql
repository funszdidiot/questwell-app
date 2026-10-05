-- Read-only, schema/configuration metadata only. Never reads user-owned rows.
-- Used unchanged for the observed source and reconstructed disposable database.
with settings as materialized (select set_config('search_path', 'pg_catalog', true))
select jsonb_build_object(
  'schemas', coalesce((select jsonb_agg(to_jsonb(x) order by name) from (
    select nspname as name, nspowner::regrole::text as owner
    from pg_namespace where nspname in ('public', 'private')
  ) x), '[]'::jsonb),
  'tables', coalesce((select jsonb_agg(to_jsonb(x) order by schema, name) from (
    select n.nspname as schema, c.relname as name, c.relowner::regrole::text as owner,
      c.relkind::text as kind, c.relrowsecurity as rls, c.relforcerowsecurity as force_rls,
      c.relreplident::text as replica_identity, c.reloptions as options
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public', 'private') and c.relkind in ('r','p','v','m','S','f')
  ) x), '[]'::jsonb),
  'columns', coalesce((select jsonb_agg(to_jsonb(x) order by schema, table_name, position) from (
    select n.nspname as schema, c.relname as table_name,
      row_number() over (partition by c.oid order by a.attnum) as position,
      a.attname as name, format_type(a.atttypid, a.atttypmod) as type,
      a.attnotnull as not_null, pg_get_expr(d.adbin, d.adrelid, false) as default_expression,
      a.attidentity::text as identity, a.attgenerated::text as generated,
      case when a.attcollation <> t.typcollation then a.attcollation::regcollation::text end as collation
    from pg_attribute a join pg_class c on c.oid = a.attrelid
    join pg_namespace n on n.oid = c.relnamespace join pg_type t on t.oid = a.atttypid
    left join pg_attrdef d on d.adrelid = a.attrelid and d.adnum = a.attnum
    where n.nspname in ('public', 'private') and c.relkind in ('r','p') and a.attnum > 0 and not a.attisdropped
  ) x), '[]'::jsonb),
  'constraints', coalesce((select jsonb_agg(to_jsonb(x) order by schema, table_name, name) from (
    select n.nspname as schema, c.relname as table_name, con.conname as name,
      con.contype::text as type, con.convalidated as validated,
      pg_get_constraintdef(con.oid, false) as definition
    from pg_constraint con join pg_class c on c.oid = con.conrelid
    join pg_namespace n on n.oid = c.relnamespace where n.nspname in ('public','private')
  ) x), '[]'::jsonb),
  'indexes', coalesce((select jsonb_agg(to_jsonb(x) order by schema, table_name, name) from (
    select n.nspname as schema, c.relname as table_name, ic.relname as name,
      pg_get_indexdef(i.indexrelid, 0, false) as definition,
      i.indisvalid as valid, i.indisready as ready,
      exists (select 1 from pg_constraint con where con.conindid = i.indexrelid and con.contype in ('p','u','x')) as constraint_backed
    from pg_index i join pg_class c on c.oid = i.indrelid
    join pg_class ic on ic.oid = i.indexrelid join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public','private')
  ) x), '[]'::jsonb),
  'functions', coalesce((select jsonb_agg(to_jsonb(x) order by schema, name, identity_arguments) from (
    select n.nspname as schema, p.proname as name, p.proowner::regrole::text as owner,
      p.prokind::text as kind, pg_get_function_identity_arguments(p.oid) as identity_arguments,
      pg_get_functiondef(p.oid) as definition
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public','private') and p.prokind in ('f','p')
  ) x), '[]'::jsonb),
  'policies', coalesce((select jsonb_agg(to_jsonb(x) order by schema, table_name, name) from (
    select schemaname as schema, tablename as table_name, policyname as name,
      permissive, roles, cmd, qual, with_check
    from pg_policies where schemaname in ('public','private','storage')
  ) x), '[]'::jsonb),
  'triggers', coalesce((select jsonb_agg(to_jsonb(x) order by schema, table_name, name) from (
    select n.nspname as schema, c.relname as table_name, t.tgname as name,
      t.tgenabled::text as enabled, pg_get_triggerdef(t.oid, false) as definition
    from pg_trigger t join pg_class c on c.oid = t.tgrelid
    join pg_namespace n on n.oid = c.relnamespace join pg_proc p on p.oid = t.tgfoid
    join pg_namespace pn on pn.oid = p.pronamespace
    where not t.tgisinternal and (n.nspname in ('public','private') or pn.nspname in ('public','private'))
  ) x), '[]'::jsonb),
  'grants', coalesce((select jsonb_agg(to_jsonb(x) order by kind, schema, name, column_name, grantee, privilege) from (
    select 'schema' as kind, n.nspname as schema, n.nspname as name, null::text as column_name,
      case when a.grantee=0 then 'PUBLIC' else a.grantee::regrole::text end as grantee,
      a.grantor::regrole::text as grantor, a.privilege_type as privilege, a.is_grantable
    from pg_namespace n cross join lateral aclexplode(coalesce(n.nspacl, acldefault('n', n.nspowner))) a
    where n.nspname in ('public','private')
    union all
    select 'table', n.nspname, c.relname, null,
      case when a.grantee=0 then 'PUBLIC' else a.grantee::regrole::text end,
      a.grantor::regrole::text, a.privilege_type, a.is_grantable
    from pg_class c join pg_namespace n on n.oid=c.relnamespace
    cross join lateral aclexplode(coalesce(c.relacl, acldefault('r', c.relowner))) a
    where n.nspname in ('public','private') and c.relkind in ('r','p')
    union all
    select 'column', n.nspname, c.relname, at.attname,
      case when a.grantee=0 then 'PUBLIC' else a.grantee::regrole::text end,
      a.grantor::regrole::text, a.privilege_type, a.is_grantable
    from pg_class c join pg_namespace n on n.oid=c.relnamespace
    join pg_attribute at on at.attrelid=c.oid cross join lateral aclexplode(at.attacl) a
    where n.nspname in ('public','private') and at.attnum>0 and not at.attisdropped
    union all
    select 'function', n.nspname, p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')', null,
      case when a.grantee=0 then 'PUBLIC' else a.grantee::regrole::text end,
      a.grantor::regrole::text, a.privilege_type, a.is_grantable
    from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    cross join lateral aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
    where n.nspname in ('public','private') and p.prokind in ('f','p')
  ) x), '[]'::jsonb),
  'default_privileges', coalesce((select jsonb_agg(to_jsonb(x) order by owner, schema, kind, grantee, privilege) from (
    select d.defaclrole::regrole::text as owner, coalesce(n.nspname,'') as schema,
      d.defaclobjtype::text as kind,
      case when a.grantee=0 then 'PUBLIC' else a.grantee::regrole::text end as grantee,
      a.privilege_type as privilege, a.is_grantable
    from pg_default_acl d left join pg_namespace n on n.oid=d.defaclnamespace
    cross join lateral aclexplode(d.defaclacl) a
    where d.defaclrole = 'postgres'::regrole and (d.defaclnamespace=0 or n.nspname in ('public','private'))
  ) x), '[]'::jsonb),
  'types', coalesce((select jsonb_agg(to_jsonb(x) order by schema, name) from (
    select n.nspname as schema, t.typname as name, t.typtype::text as kind,
      (select jsonb_agg(e.enumlabel order by e.enumsortorder) from pg_enum e where e.enumtypid=t.oid) as labels
    from pg_type t join pg_namespace n on n.oid=t.typnamespace
    where n.nspname in ('public','private') and t.typtype in ('e','d','r')
  ) x), '[]'::jsonb),
  'extensions', coalesce((select jsonb_agg(to_jsonb(x) order by name) from (
    select e.extname as name, n.nspname as schema, e.extversion as version
    from pg_extension e join pg_namespace n on n.oid=e.extnamespace
    where e.extname in ('pgcrypto','uuid-ossp','plpgsql')
  ) x), '[]'::jsonb),
  'buckets', coalesce((select jsonb_agg(to_jsonb(x) order by id) from (
    select id, name, public, file_size_limit, allowed_mime_types from storage.buckets
  ) x), '[]'::jsonb)
) as catalog from settings;
