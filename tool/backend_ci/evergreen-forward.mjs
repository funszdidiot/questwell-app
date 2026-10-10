import assert from 'node:assert/strict';
import {readFileSync, writeFileSync} from 'node:fs';
import {join, resolve} from 'node:path';

// This runs only after run.mjs verifies the disposable GitHub runner/container.
// There is deliberately no live deployment entry point.
export function exerciseEvergreenCandidate({source, workdir, run, runPayload}) {
  const candidate = readFileSync(resolve(source, '../../docs/releases/evergreen-hearth/catalog-candidate.sql'), 'utf8');
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
