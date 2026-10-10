import assert from 'node:assert/strict';
import {readFileSync, writeFileSync} from 'node:fs';
import {join, resolve} from 'node:path';
import {payload,stateQuery,manifestPath,sha256} from '../deploy/evergreen-contract.mjs';

// This runs only after run.mjs verifies the disposable GitHub runner/container.
export function exerciseEvergreenCandidate({source, workdir, run, runPayload}) {
  const root = resolve(source,'../..');
  const manifest = JSON.parse(readFileSync(join(root,manifestPath),'utf8'));
  const candidate = readFileSync(join(root,manifest.migration_path),'utf8');
  const catalog = readFileSync(join(source,'catalog.sql'),'utf8');
  const queryFile = join(workdir,'evergreen-guard-state.sql');
  writeFileSync(queryFile,stateQuery(catalog,manifest));
  const guardState = () => JSON.parse(run(['db','query','--local','-o','json','--file',queryFile]))[0].state;
  const beforeGuard = guardState();
  const reviewed = {source_sha256:sha256(candidate),catalog_sql_sha256:sha256(catalog),
    manifest_sha256:sha256(JSON.stringify(manifest)),before:beforeGuard};
  const guarded = join(workdir,'evergreen-guarded.sql');
  writeFileSync(guarded,payload(candidate,catalog,manifest,{...reviewed,before:{...beforeGuard,catalog_sha256:'0'.repeat(64)}}).sql);
  runPayload(guarded,'Evergreen precondition drift');
  assert.deepEqual(guardState(),beforeGuard);
  writeFileSync(guarded,payload(candidate,catalog,manifest,reviewed,{activate:false}).sql);
  runPayload(guarded,'Evergreen postcondition mismatch');
  assert.deepEqual(guardState(),beforeGuard);
  writeFileSync(guarded,payload(candidate,catalog,manifest,reviewed).sql+'\nrollback;\n');
  runPayload(guarded);
  assert.deepEqual(guardState(),beforeGuard);
  console.log('Evergreen guarded forward: drift rejection, atomic activation and postcondition rollback passed.');
  const test = readFileSync(join(source, 'evergreen-contract.sql'), 'utf8');
  const snapshot = join(workdir, 'evergreen-snapshot.sql');
  writeFileSync(snapshot, `select jsonb_build_object(
    'items',(select jsonb_agg(to_jsonb(c) order by id) from public.cosmetics c),
    'profiles',(select jsonb_agg(to_jsonb(p) order by profile_key) from public.hearth_layout_profiles p),
    'slots',(select jsonb_agg(to_jsonb(s) order by profile_key,slot_key) from public.hearth_profile_slots s),
    'renders',(select jsonb_agg(to_jsonb(r) order by cosmetic_id) from public.hearth_render_registry r),
    'users',(select jsonb_agg(to_jsonb(u) order by id) from public.users u),
    'ownership',(select jsonb_agg(to_jsonb(o) order by user_id,cosmetic_id) from public.user_cosmetics o),
    'rewards',(select count(*) from public.reward_events),
    'layouts',(select jsonb_agg(to_jsonb(l) order by user_id) from private.hearth_saved_layouts l)
  ) as state;`);
  const readState = () => JSON.parse(run(['db','query','--local','-o','json','--file',snapshot]))[0].state;
  const before = readState();
  const file = join(workdir, 'evergreen-candidate.sql');
  writeFileSync(file, candidate + '\n' + test + '\nrollback;\n');
  runPayload(file);
  assert.deepEqual(readState(), before, 'Evergreen rehearsal must restore all catalog/account state');
  console.log('Evergreen inactive catalog, purchase retries, Guardian eligibility, three wall slots, room recall and rollback passed.');
}
