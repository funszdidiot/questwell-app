import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

export const project = 'bdzcazkyypopbanbjnud';
export const migrationName = 'evergreen_hearth_approved_rollout';
export const manifestPath = 'docs/releases/evergreen-hearth/catalog.json';
export const sha256 = value => createHash('sha256').update(value).digest('hex');
const quote = value => `'${value.replaceAll("'", "''")}'`;
const slugs = ['hearthwoven-macrame','woodland-path-tapestry','guardians-oath-tapestry','mad-alchemists-lab','guardians-keep'];
const list = slugs.map(quote).join(',');

export function stateQuery(catalogSql, manifest) {
  assert.deepEqual(manifest.items.map(i => i.catalog.slug), slugs);
  const expected = manifest.items.map(i => i.catalog);
  const renders = manifest.items.filter(i => i.catalog.category === 'wall_art').map(i => ({
    slug:i.catalog.slug, render_kind:'wall_art_sprite', asset_source:'bundle',
    asset_path:i.asset, canvas_width:i.size[0], canvas_height:i.size[1],
    visible_base:1, shadow_profile:'none', effect_profile:null, filter_mode:'smooth',
    asset_revision:1, min_client_build:null,
  }));
  const profiles = [{profile_key:'wall_textile',family_key:'wall_art',display_name:'Wall textile',layout_version:1}];
  const slots = ['wall_left','wall_center','wall_right'].map((slot_key,i) => ({
    profile_key:'wall_textile',slot_key,placement_label:['Left wall','Center / Hearth','Right wall'][i],
    sort_order:(i+1)*10,required_equipped_slug:null,
  }));
  const exact = (table, values) => `not exists((select value from ${table} except select value from jsonb_array_elements(${quote(JSON.stringify(values))}::jsonb)) union all (select value from jsonb_array_elements(${quote(JSON.stringify(values))}::jsonb) except select value from ${table}))`;
  return `with source as (${catalogSql.trim().replace(/;$/,'')}),
protected_data as (select jsonb_build_object(
  'catalog',(select coalesce(jsonb_agg(to_jsonb(c) order by id),'[]'::jsonb) from public.cosmetics c where slug not in (${list})),
  'renders',(select coalesce(jsonb_agg(to_jsonb(r) order by cosmetic_id),'[]'::jsonb) from public.hearth_render_registry r join public.cosmetics c on c.id=r.cosmetic_id where c.slug not in (${list})),
  'profiles',(select jsonb_agg(to_jsonb(p) order by profile_key) from public.hearth_layout_profiles p where profile_key<>'wall_textile'),
  'slots',(select jsonb_agg(to_jsonb(s) order by slot_key) from public.hearth_slots s),
  'profile_slots',(select jsonb_agg(to_jsonb(s) order by profile_key,slot_key) from public.hearth_profile_slots s where profile_key<>'wall_textile')) as value),
history as (select coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name,'statements',statements) order by version),'[]'::jsonb) as value
  from supabase_migrations.schema_migrations where name is distinct from '${migrationName}'),
new_items as (select to_jsonb(c)-'id'-'created_at' as value from public.cosmetics c where slug in (${list})),
new_renders as (select (to_jsonb(r)-'cosmetic_id')||jsonb_build_object('slug',c.slug) as value from public.hearth_render_registry r join public.cosmetics c on c.id=r.cosmetic_id where c.slug in (${list})),
new_profiles as (select to_jsonb(p) as value from public.hearth_layout_profiles p where profile_key='wall_textile'),
new_slots as (select to_jsonb(s) as value from public.hearth_profile_slots s where profile_key='wall_textile')
select jsonb_build_object(
  'schema_sha256',(select encode(sha256(convert_to(catalog::text,'UTF8')),'hex') from source),
  'catalog_sha256',(select encode(sha256(convert_to(value::text,'UTF8')),'hex') from protected_data),
  'history_sha256',(select encode(sha256(convert_to(value::text,'UTF8')),'hex') from history),
  'history_count',(select jsonb_array_length(value) from history),
  'new_count',(select count(*) from new_items),
  'render_count',(select count(*) from new_renders),
  'profile_count',(select count(*) from new_profiles),
  'slot_count',(select count(*) from new_slots),
  'live_valid',${exact('new_items',expected)} and ${exact('new_renders',renders)} and ${exact('new_profiles',profiles)} and ${exact('new_slots',slots)},
  'records',(select coalesce(jsonb_agg(jsonb_build_object('version',version,'statements',statements) order by version),'[]'::jsonb) from supabase_migrations.schema_migrations where name='${migrationName}')
) as state;`;
}

export function payload(source, catalogSql, manifest, reviewed, {activate = true} = {}) {
  assert.equal(sha256(source), reviewed.source_sha256, 'Migration bytes changed');
  assert.equal(sha256(catalogSql), reviewed.catalog_sql_sha256, 'Schema query changed');
  assert.equal(sha256(JSON.stringify(manifest)), reviewed.manifest_sha256, 'Approved manifest changed');
  const before = reviewed.before;
  for (const key of ['schema_sha256','catalog_sha256','history_sha256']) assert.match(before[key], /^[a-f0-9]{64}$/);
  for (const key of ['new_count','render_count','profile_count','slot_count']) assert.equal(before[key], 0);
  assert.equal(before.live_valid, false); assert.deepEqual(before.records, []);
  const after = {...before,new_count:5,render_count:3,profile_count:1,slot_count:3,live_valid:true};
  const query = stateQuery(catalogSql, manifest);
  const digest = sha256(source + JSON.stringify(manifest));
  return {after, query, digest, sql:`-- questwell-evergreen-source-sha256:${digest}
do $evergreen_forward$
declare observed jsonb;
begin
  perform set_config('lock_timeout','5s',true);
  perform set_config('statement_timeout','20s',true);
  perform pg_advisory_xact_lock(784310102026::bigint);
  lock table public.cosmetics,public.hearth_render_registry,public.hearth_layout_profiles,
    public.hearth_profile_slots,public.hearth_slots,supabase_migrations.schema_migrations
    in share row exclusive mode;
  execute $evergreen_state$${query}$evergreen_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(before))}::jsonb then raise exception 'Evergreen precondition drift'; end if;
${source}
${activate ? `update public.cosmetics set active=true where slug in (${list});` : '-- Deliberately omitted only by isolated negative test.'}
  execute $evergreen_state$${query}$evergreen_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(after))}::jsonb then raise exception 'Evergreen postcondition mismatch'; end if;
end;
$evergreen_forward$;\n`};
}

export function verifyApplied(actual, plan) {
  const {records,...state} = actual;
  const {records:ignored,...expected} = plan.after;
  assert.deepEqual(state, expected, 'Evergreen delivered state differs');
  assert.equal(records.length, 1, 'Expected exactly one forward record');
  assert.match(String(records[0].version), /^\d{14}$/);
  assert.ok(records[0].statements.join('\n').includes(`questwell-evergreen-source-sha256:${plan.digest}`));
}
