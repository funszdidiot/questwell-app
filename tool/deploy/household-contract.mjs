import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

export const project='bdzcazkyypopbanbjnud';
export const repository='funszdidiot/questwell-app';
export const deploymentRef='refs/heads/deploy/household-familiars-approved';
export const migrationName='household_familiars_2026';
export const migrationPath='supabase/migrations/20261009180421_household_familiars_catalog.sql';
export const activationPath='docs/releases/household-familiars-2026/activate.sql';
export const manifestPath='docs/releases/household-familiars-2026/manifest.json';
export const sha256=text=>createHash('sha256').update(text).digest('hex');
const quote=value=>`'${value.replaceAll("'","''")}'`;
const slugs=['boston-terrier','hearth-cat'];
const list=slugs.map(quote).join(',');

export function stateQuery(catalogSql,manifest) {
  assert.deepEqual(manifest.items.map(i=>i.slug),slugs);
  const expected=manifest.items.map(i=>({slug:i.slug,name:i.name,category:i.category,rarity:i.rarity,
    description:i.description,price:i.price,premium:i.premium,required_archetype:i.required_archetype,
    unlock_method:i.unlock_method,milestone_level:i.milestone_level,collection_key:manifest.collection_key,
    edition_type:'standard',hearth_profile_key:i.hearth.profile_key,asset_key:i.asset_key,
    availability_end:manifest.availability.ends_at}));
  const render=manifest.items.filter(i=>i.hearth.render).map(i=>({slug:i.slug,...i.hearth.render}));
  return `with source as (${catalogSql.trim().replace(/;$/,'')}),
protected_schema as (select catalog as value from source),
protected_data as (select jsonb_build_object(
  'catalog',(select coalesce(jsonb_agg(to_jsonb(c) order by id),'[]'::jsonb) from public.cosmetics c where slug not in (${list})),
  'renders',(select coalesce(jsonb_agg(to_jsonb(r) order by cosmetic_id),'[]'::jsonb) from public.hearth_render_registry r join public.cosmetics c on c.id=r.cosmetic_id where c.slug not in (${list})),
  'profiles',(select jsonb_agg(to_jsonb(p) order by profile_key) from public.hearth_layout_profiles p),
  'slots',(select jsonb_agg(to_jsonb(p) order by slot_key) from public.hearth_slots p),
  'profile_slots',(select jsonb_agg(to_jsonb(p) order by profile_key,slot_key) from public.hearth_profile_slots p)) as value),
history as (select coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name,'statements',statements) order by version),'[]'::jsonb) as value
  from supabase_migrations.schema_migrations where name is distinct from '${migrationName}'),
new_items as (select (to_jsonb(c)-'id'-'created_at'-'active'-'availability_start'-'availability_end') ||
  jsonb_build_object('availability_end',to_char(c.availability_end at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS"Z"')) as value,c.active,c.availability_start
  from public.cosmetics c where c.slug in (${list})),
expected as (select value from jsonb_array_elements(${quote(JSON.stringify(expected))}::jsonb)),
actual_renders as (select (to_jsonb(r)-'cosmetic_id')||jsonb_build_object('slug',c.slug) as value
  from public.hearth_render_registry r join public.cosmetics c on c.id=r.cosmetic_id where c.slug in (${list})),
expected_renders as (select value from jsonb_array_elements(${quote(JSON.stringify(render))}::jsonb))
select jsonb_build_object(
  'schema_sha256',(select encode(sha256(convert_to(value::text,'UTF8')),'hex') from protected_schema),
  'catalog_sha256',(select encode(sha256(convert_to(value::text,'UTF8')),'hex') from protected_data),
  'history_sha256',(select encode(sha256(convert_to(value::text,'UTF8')),'hex') from history),
  'history_count',(select jsonb_array_length(value) from history),
  'purchase_sha256',encode(sha256(convert_to(pg_get_functiondef('private.purchase_cosmetic(uuid)'::regprocedure),'UTF8')),'hex'),
  'new_count',(select count(*) from new_items),
  'render_count',(select count(*) from actual_renders),
  'live_valid',(select count(*)=2 and coalesce(bool_and(active and availability_start is not null and availability_start<=statement_timestamp()),false) from new_items)
    and not exists((select value from new_items except select value from expected) union all (select value from expected except select value from new_items))
    and not exists((select value from actual_renders except select value from expected_renders) union all (select value from expected_renders except select value from actual_renders)),
  'records',(select coalesce(jsonb_agg(jsonb_build_object('version',version,'statements',statements) order by version),'[]'::jsonb)
    from supabase_migrations.schema_migrations where name='${migrationName}')
) as state;`;
}

export function payload(source,activation,catalogSql,manifest,expected) {
  assert.equal(sha256(source),expected.source_sha256,'Migration bytes changed');
  assert.equal(sha256(activation),expected.activation_sha256,'Activation bytes changed');
  assert.equal(sha256(catalogSql),expected.catalog_sql_sha256,'Catalog query changed');
  assert.equal(sha256(JSON.stringify(manifest)),expected.manifest_sha256,'Manifest changed');
  const first=source.indexOf('\nbegin;\n'),last=source.lastIndexOf('\ncommit;');
  assert.ok(first>=0&&last>first&&source.slice(last).trim()==='commit;');
  const body=source.slice(first+8,last);
  const query=stateQuery(catalogSql,manifest);
  const before=expected.before;
  for(const key of ['schema_sha256','catalog_sha256','history_sha256','purchase_sha256']) assert.match(before[key],/^[a-f0-9]{64}$/);
  assert.equal(before.new_count,0);assert.equal(before.render_count,0);assert.equal(before.live_valid,false);assert.deepEqual(before.records,[]);
  const after={...before,new_count:2,render_count:0,live_valid:true};
  const sourceDigest=sha256(source+activation);
  return {after,sourceDigest,query,sql:`-- questwell-household-source-sha256:${sourceDigest}
do $household_forward$
declare observed jsonb;
begin
  perform set_config('lock_timeout','5s',true);
  perform set_config('statement_timeout','20s',true);
  perform pg_advisory_xact_lock(784310092027::bigint);
  lock table public.cosmetics,public.hearth_render_registry,supabase_migrations.schema_migrations in share row exclusive mode;
  execute $household_state$${query}$household_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(before))}::jsonb then raise exception 'Household familiars precondition drift'; end if;
${body}
${activation}
  execute $household_state$${query}$household_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(after))}::jsonb then raise exception 'Household familiars postcondition mismatch'; end if;
end;
$household_forward$;\n`};
}

export function verifyApplied(actual,after,digest) {
  const {records,...state}=actual;
  const {records:ignored,...expected}=after;
  assert.deepEqual(state,expected,'Household familiars state differs');
  assert.equal(records.length,1,'Expected one forward migration record');
  assert.match(String(records[0].version),/^\d{14}$/);
  assert.ok(records[0].statements.join('\n').includes(`questwell-household-source-sha256:${digest}`),'Migration digest missing');
}

export function deploymentContext(env) {
  assert.equal(env.GITHUB_ACTIONS,'true');assert.equal(env.RUNNER_ENVIRONMENT,'github-hosted');
  assert.equal(env.GITHUB_REPOSITORY,repository);assert.equal(env.GITHUB_EVENT_NAME,'push');assert.equal(env.GITHUB_REF,deploymentRef);
  assert.match(env.GITHUB_SHA??'',/^[a-f0-9]{40}$/);
  assert.ok(env.QUESTWELL_HOUSEHOLD_MIGRATION_TOKEN,'Missing QUESTWELL_HOUSEHOLD_MIGRATION_TOKEN');
  assert.ok(env.GITHUB_TOKEN,'Missing GitHub check-read token');
  for(const [k,v] of Object.entries(env)) if(v&&(k.startsWith('PG')||k==='DATABASE_URL'||k.startsWith('SUPABASE_'))) throw Error('Unexpected database credential override');
}
