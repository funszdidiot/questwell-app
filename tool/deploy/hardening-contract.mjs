import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

export const project = 'bdzcazkyypopbanbjnud';
export const migrationName = 'release_hardening_r01_c04';
export const sha256 = text => createHash('sha256').update(text).digest('hex');
const digest = /^[a-f0-9]{64}$/;
const quote = value => `'${value.replaceAll("'", "''")}'`;

// Application schema/configuration and migration metadata only; no user rows.
export function stateQuery(catalogSql) {
  return `with source_catalog as (${catalogSql.trim().replace(/;$/, '')}),
  history as (select coalesce(jsonb_agg(jsonb_build_object('version',version,
    'name',name,'statements',statements) order by version),'[]'::jsonb) as entries
    from supabase_migrations.schema_migrations where name is distinct from '${migrationName}')
  select jsonb_build_object(
    'schema_sha256',(select encode(sha256(convert_to(catalog::text,'UTF8')),'hex') from source_catalog),
    'history_sha256',(select encode(sha256(convert_to(entries::text,'UTF8')),'hex') from history),
    'history_count',(select jsonb_array_length(entries) from history),
    'rollout_records',(select count(*) from supabase_migrations.schema_migrations where name='${migrationName}')
  ) as state;`;
}

export function guardedPayload(sources, catalogSql, expected) {
  for (const k of ['schema_sha256','history_sha256','after_schema_sha256']) assert.match(expected[k],digest);
  assert.ok(Number.isInteger(expected.history_count) && expected.history_count > 0);
  assert.equal(expected.rollout_records,0);
  assert.equal(sha256(catalogSql),expected.catalog_sql_sha256,'Catalog query changed');
  assert.equal(sources.length,7);
  assert.deepEqual(sources.map(s=>s.path),expected.migrations.map(s=>s.path));
  const bodies = sources.map((s,i)=>{
    assert.equal(sha256(s.sql),expected.migrations[i].sha256,`Source changed: ${s.path}`);
    const first=s.sql.indexOf('begin;'), last=s.sql.lastIndexOf('commit;');
    assert.ok(first>=0 && last>first && s.sql.slice(last).trim()==='commit;');
    return `-- ${s.path}\n${s.sql.slice(first+6,last)}`;
  }).join('\n');
  assert.ok(!bodies.includes('$questwell_hardening$'));
  const query=stateQuery(catalogSql);
  assert.ok(!query.includes('$hardening_state$'));
  const before={schema_sha256:expected.schema_sha256,history_sha256:expected.history_sha256,
    history_count:expected.history_count,rollout_records:0};
  const after={...before,schema_sha256:expected.after_schema_sha256};
  const sourceDigest=sha256(JSON.stringify(expected.migrations));
  return `-- questwell-hardening-source-sha256:${sourceDigest}
-- Exactly seven reviewed forward changes. No history replay/reset/repair.
do $questwell_hardening$
declare observed jsonb;
begin
  perform pg_catalog.set_config('lock_timeout','3s',true);
  perform pg_catalog.set_config('statement_timeout','20s',true);
  perform pg_catalog.pg_advisory_xact_lock(784310052027::bigint);
  lock table public.tasks, public.boss_battles, public.boss_steps,
    public.users, public.reward_events, storage.objects in share row exclusive mode;
  execute $hardening_state$${query}$hardening_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(before))}::jsonb then
    raise exception 'Hardening precondition drift; no change applied';
  end if;
${bodies}
  execute $hardening_state$${query}$hardening_state$ into observed;
  if observed is distinct from ${quote(JSON.stringify(after))}::jsonb then
    raise exception 'Hardening postcondition failed; transaction rolled back';
  end if;
  perform pg_catalog.pg_notify('pgrst','reload schema');
end $questwell_hardening$;\n`;
}
