# Observed application schema baseline

Date: 2026-10-05 UTC. Scope: B03 / QW-04, disposable CI reconstruction only.

## Decision and source

The repository does not contain a complete historical database bootstrap. We
preserve that evidence and reconstruct the **observed current schema** in the
already approved temporary GitHub-hosted target. This is a characterization
baseline, including existing unsafe permissions and business rules; it does not
fix rewards, deletion, client environment selection or live deployment history.
No live SQL mutation, Auth setting change, user export, account deletion, paid
service or remote migration command was performed.

Read-only source: PostgreSQL catalogs and storage bucket configuration in
Project Momentum (`bdzcazkyypopbanbjnud`), plus
`supabase_migrations.schema_migrations`. No table of user-owned application
rows or Auth users was exported. The bucket record is configuration only;
Storage object rows and bytes are absent. Historical SQL contains its original
DDL/DML but is archived as JSON evidence and never executed by this workflow.

- `tool/backend_ci/catalog.sql`: identical metadata query for source and replay.
  A fixed pg_catalog search path avoids search-path-dependent deparsing.
- `tool/backend_ci/observed_catalog.json`: captured comparison contract.
- `tool/backend_ci/app/supabase/migrations/20261005152140_observed_application_schema.sql`:
  reconstructed DDL and bucket configuration. The filename was created by the
  installed CLI's `migration new observed_application_schema` command.
- `tool/backend_ci/history/remote_history.json`: all 48 stored SQL entries.
- `tool/backend_ci/history/migration_inventory.json`: complete local/remote
  names, versions, SHA-256 fingerprints and exact-byte comparison results.

The baseline contains 13 regular tables, 131 columns, 81 constraints, 23 indexes,
35 functions, 23 policies (20 application + 3 Storage), nine triggers including
the Auth profile trigger, 466 expanded grants, 48 postgres default-privilege
entries, two schema owners, three relevant extension versions and one private
bucket's size/type configuration. No enums, sequences or views were observed
in public/private. Catalog comparison is scoped to the query's recorded fields;
it is not a byte-identical hosted backup or complete platform configuration dump.

## Tests before implementation

The first PR commit ran the unchanged root migration directory on the clean
isolated stack. Run [37331699107](https://github.com/funszdidiot/questwell-app/actions/runs/37331699107),
job 111836131963, head `436e95a9d4958c687a646d95852e2f03c5846a90`:

```text
2026-10-05T15:19:45.8680888Z Backend harness: 10 integration checks passed (fixture only; not Questwell RLS).
2026-10-05T15:19:45.8704182Z Replaying the committed Questwell migrations on the disposable database.
2026-10-05T15:19:58.6598583Z Applying migration 20260930222423_gentle_xp_curve.sql...
2026-10-05T15:19:58.6599536Z ERROR: LOCK TABLE can only be used in transaction blocks (SQLSTATE 25P01)
2026-10-05T15:20:04.5732031Z Disposed the isolated harness containers/volumes and synthetic accounts/data.
```

This proves the original replay fails. It does not claim that execution reached
a missing-table error: the transaction error happened first. Separately, reading
the first root SQL and the earliest remote migration verifies that both assume
already-created application tables. Copying the remote files cannot supply the
missing prehistory, and interleaving both directories would duplicate changes.

Before the catalog comparator existed, its tests failed with ERR_MODULE_NOT_FOUND
(0 pass / 1 fail). After implementation, negative tests prove detection of changed
RLS, column nullability, constraints, indexes, grants, functions, Storage policies,
triggers, default privileges, public buckets and missing/extra sections.

The first reconstruction attempt (run 37333008457, job 111840590169) exposed an
**implementation error in our capture query**, not a live application error:

```text
ERROR: syntax error at or near "to" (SQLSTATE 42601)
grant EXECUTE on function "private"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp in to "authenticated";
```

PostgreSQL's name type truncated the combined function-signature field. A new
regression failed (12 pass / 1 fail); explicit text casts in the UNION capture
fixed it. Re-reading the source changed only grant identity strings; no source
privileges changed. The test now requires every function grant to match a full
observed function signature. The baseline retains the exact intended grants.

The next replay created the schema but detected three constraint-definition
differences (runs 37333731068 / 37334295851). Re-parsing deparsed BETWEEN checks
flattened nested AND groups. The original BETWEEN spelling is available in
the committed beta-feedback migration (build/platform) and recovered remote
20261003182414 (attachment path). Those three original expressions are used in
the reconstruction. No comparison exception or ignored constraint was added.

Run 37335051973 then passed every recorded catalog section and the real RLS
negative control. Its first subsequent signup failed with UND_ERR_SOCKET after
the reset restarted the API: the same Node process retained pre-reset HTTP
connections. The app smoke now runs in a fresh child process with local status
passed through stdin, never arguments/files/logs. No signup/write retry was
added; a remaining failure still fails the job. SQL lint's stderr is retained
so its real diagnostics are visible even when stdout is empty.

## Verification contract

Every relevant PR/push runs the checksum-pinned CLI on a new runner:

1. Existing six isolation guards, thirteen catalog regressions, and ten real
   synthetic fixture Auth/REST checks, including the existing RLS leak control.
2. A second `supabase db reset --local --no-seed` applies the observed baseline
   in an explicit transaction. No root history or remote linkage is copied.
3. Exact recorded catalog comparison. Disabling the reconstructed tasks table's
   RLS must cause that comparison to fail; RLS is restored and compared again.
4. `supabase db lint --local --schema public,private --level warning --fail-on none`
   reports inherited source findings. This is an inventory, **not a strict lint
   gate or a claim of zero errors**; any findings remain release blockers to triage.
5. Real Auth signup creates two synthetic app profiles; actual task REST reads
   isolate owners and anon; cross-owner completion is denied; a legitimate
   completion changes the ledger/balance once and a direct duplicate is denied.
   These four grouped checks do not test hostile reward values or task reopening.
6. Exact local project/container/volume disposal, including all synthetic users.

Consult PR #19's final head and linked run logs for executed results. The contract
above describes what the job enforces; it is not proof before a green run.
The updated development branch's Flutter job tolerates 46 analyzer issues (16
warnings, 30 infos) and excludes the
placeholder widget test. Neither restriction is removed or hidden here.

## Migration reconciliation

There are 58 distinct names across 23 local and 48 remote entries. By exact name:
35 remote-only, 10 local-only, 11 byte-identical pairs, one pair differing only in
surrounding whitespace, and one pair with changed header comments. The last was
verified with `diff -u`: `male_robe_everyday_app_rollout` differs only in its first
three comments explaining the later founder decision; subsequent SQL is identical.
The inventory retains the raw byte difference instead of pretending equal hashes.

Dispositions: remote-only SQL is recovered in the archive, not inserted into an
invented order; local-only files remain unchanged and are not assumed applied;
matching SQL with different version identifiers requires deliberate live history
reconciliation. **No `migration repair`, `db pull`, `db push` or remote reset.**
Current-schema parity does not establish how or when unrecorded changes occurred.

| Migration name | Local version | Remote version | Verified source comparison |
|---|---|---|---|
| actionable_beta_feedback_queue | — | 20261003183034 | remote only |
| activate_class_mastery_hearth_relics | — | 20261001204532 | remote only |
| add_avatar_body_type | — | 20260928215944 | remote only |
| add_set_avatar_body_type_rpc | — | 20260928225130 | remote only |
| add_unequip_cosmetic_rpc | — | 20260927161508 | remote only |
| allow_auth_account_deletion_without_trophy_relayout | — | 20261002004352 | remote only |
| allow_class_relic_front_left_pedestal | — | 20261001205351 | remote only |
| approved_wardrobe_body_support | 20261004035017 | 20261004035017 | byte-identical |
| autumn_ember_lantern_market | 20261003004307 | — | local only |
| beta_feedback_multiple_screenshots | — | 20261003182944 | remote only |
| beta_feedback_screenshot_attachments | — | 20261003182414 | remote only |
| boss_battles_foundation | — | 20260927163816 | remote only |
| class_locked_cosmetics | — | 20260927171533 | remote only |
| class_mastery_rewards | — | 20260927172022 | remote only |
| copper_potion_workbench_market | 20261002221545 | — | local only |
| cosmetic_collections_and_editions | — | 20261003213709 | remote only |
| emerald_wayfarer_rug | 20261002130617 | 20261002131724 | byte-identical |
| enchanted_library_market | 20261002203554 | — | local only |
| enforce_boss_victory_cap_and_level_unlocks | — | 20261001223118 | remote only |
| expand_avatar_equipment_slots_v2 | — | 20260928164032 | remote only |
| female_paper_doll_wardrobe | 20261003061842 | 20261003061842 | byte-identical |
| first_journey_milestone | 20260930224627 | 20260930224627 | byte-identical |
| four_hearth_settings | 20261002205209 | — | local only |
| generic_wall_art_registry | — | 20261005010743 | remote only |
| gentle_xp_curve | 20260930222423 | 20260930222423 | byte-identical |
| harden_boss_step_completion | — | 20260927174256 | remote only |
| harvest_apothecary_display_market | 20261003000637 | — | local only |
| hearth_layout_contract | 20261004235800 | 20261005000645 | byte-identical |
| hearth_reading_table_side_spot | — | 20260930201950 | remote only |
| hearth_render_registry | 20261005003100 | 20261005003452 | byte-identical |
| hearth_settings_market | 20261002195043 | — | local only |
| hearth_side_wall_art | — | 20260930211710 | remote only |
| hearth_three_saved_spots | — | 20260930162131 | remote only |
| hearth_wall_art_category | — | 20260930204233 | remote only |
| hold_warding_lantern_wayfarer_rug_for_art_rebuild | — | 20261003221322 | remote only |
| isolate_privileged_gameplay_rpcs | — | 20260928230206 | remote only |
| lock_down_auth_trigger_function | — | 20260927040111 | remote only |
| male_robe_everyday_app_rollout | 20261004163513 | 20261004163513 | Header comments differ; SQL identical |
| male_wardrobe_keep_legacy_availability | 20261004164110 | 20261004164110 | byte-identical |
| market_equipment_window | 20261001004459 | 20261001004539 | only surrounding whitespace differs |
| midnight_harvest_coat_market | 20261002232430 | — | local only |
| milestone_roadmap_chronicle | 20260930231037 | 20260930231037 | byte-identical |
| neutral_woodland_approved_rollout | 20261004212323 | 20261004212445 | byte-identical |
| office_themed_boss_archetypes | — | 20260927163912 | remote only |
| persistent_pinned_quest | — | 20261003212827 | remote only |
| profile_sync_and_atomic_task_completion | — | 20260927040055 | remote only |
| pumpkin_sprite_market | 20261002224627 | — | local only |
| questwell_adventurer_archetype | — | 20260927170440 | remote only |
| questwell_beta_feedback | 20261002033649 | — | local only |
| questwell_business_suit_starter_outfit | — | 20260927132648 | remote only |
| questwell_onboarding_state | — | 20260927170042 | remote only |
| questwell_secure_economy_foundation | — | 20260927044951 | remote only |
| remove_legacy_boss_creation_rpc | — | 20260927171804 | remote only |
| restrict_gameplay_rpc_anonymous_access | — | 20260928230125 | remote only |
| return_all_unsupported_hearth_collectibles | — | 20261001211351 | remote only |
| serialize_cosmetic_purchase | 20261002105548 | — | local only |
| starlit_orrery_milestone | 20260930233919 | 20260930233919 | byte-identical |
| woodland_scout_collection_scout_only | — | 20261003220623 | remote only |

## Remaining limits, risks and rollback

QW-04 is **partially addressed**, not closed: CI can exercise the observed schema
once verified, while the legacy root chain and production history remain blocked.
An approved deployment strategy must reconcile identifiers and unrecorded changes,
handle the initial bootstrap explicitly, and pass a separate forward-migration
check before any live application. Do not use the test baseline as a remote upgrade.

This snapshot deliberately preserves known defects and questionable defaults,
including the extra literal quotes observed in tasks.status and users.current_energy_mode.
The smoke test supplies the client-equivalent explicit open status; it does not
silently correct that observed default. Reward exploits, all-table access-control
matrices, file ownership/deletion, Edge Functions, restore drills, catalog inventory,
SMTP/OAuth, exposed-schema configuration, native devices and client selection remain
unverified. No existing P0 is closed by this work.

The local Auth configuration still disables email confirmation for synthetic
accounts. Its Storage global limit is the earlier harness's 1 MiB, while the
recorded bucket configuration is 5 MiB; Storage operations are not tested here.
Platform-owned schemas, roles/memberships/defaults of other creators, extension
internals, publications/Realtime, schedules, views outside public/private,
collation behavior, comments/statistics and dashboard settings are outside the
comparison. Hosted and local Postgres minor versions may differ.

Risk: this metadata reconstruction can miss a platform dependency; real replay,
exact scoped comparison and application smoke checks bound that risk without
claiming full restoration. It adds no production credentials or deploy job.
Rollback is a reviewed revert of PR #19; synthetic state is disposable. No live
user-data restoration is required. Reverting removes this safety net and leaves
QW-04 open. A separate user merge approval is required; merging to questwell-dev
can invoke the existing development preview deployment.

Official interfaces checked: [Supabase migration workflow](https://supabase.com/docs/guides/deployment/database-migrations),
[CLI 2.119.0 query JSON implementation](https://github.com/supabase/cli/blob/v2.119.0/apps/cli/src/commands/db/query/query.format.ts),
[PostgreSQL 17 deparsing/ACL functions](https://www.postgresql.org/docs/17/functions-info.html),
[default privileges](https://www.postgresql.org/docs/17/sql-alterdefaultprivileges.html).
Installed help was inspected for migration new, db reset/query/lint and stop.
