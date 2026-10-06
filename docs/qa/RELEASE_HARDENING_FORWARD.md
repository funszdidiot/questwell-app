# R01–C04 guarded live-beta rollout — preparation only

Status: NOT AUTHORIZED / NOT READY TO EXECUTE. The first CI rehearsal must supply
the post-schema fingerprint; the offline renderer refuses an incomplete manifest.
No live DDL, Edge deployment, user write or migration-history change has occurred.

Read-only inspection on October 6, 2026 found the current client calls
`create_task_once`, `finish_onboarding_once` and `create_boss_once`, but none is
present in the live beta public schema. This is an active client/server mismatch,
not just missing release evidence. Do not mark those flows verified from fixture
or build tests. Existing account deletion remains Edge version 1 with JWT checks.

## Exact proposed scope

Target: existing beta project `bdzcazkyypopbanbjnud`, not a new environment.
`tool/deploy/hardening-reviewed-state.json` pins seven source migrations by SHA256:
R01 task reward authority; R02 fixed new-boss rewards; R03 deletion fencing and
Storage session protection; C01 retry-safe quests; C02 atomic onboarding;
C03 retry-safe bosses; C04 serialized final boss steps. Existing reward amounts,
saved historical boss rewards and all eight level gates remain unchanged.
The already-applied male Woodland change is excluded. No root-chain replay,
history repair, user-data rewrite, historical balance correction or stranded-boss
repair is included. Existing 49 migration rows must remain unchanged.

The proposal also pins `delete-account/index.ts` and `handler.mjs`, retaining
`verify_jwt=true` and the handler's own Auth verification. This deployment does
not itself delete any account or object. Later user-requested deletions use the
reviewed bounded Storage cleanup, session revocation and final Auth deletion.

## Guard and rehearsal

`render-hardening.mjs` is offline only and accepts no target/state overrides.
It verifies Edge/source/catalog-query bytes and emits a transaction-local timeout
configuration followed by one atomic DO statement. A migration-recording API
must execute them in the same transaction; there are no embedded commits.
The timeout is armed before DO starts, with a real cancellation test in CI.
The pinned CLI `db query` deliberately rejects multi-statement input; this
payload's disposable rehearsal uses `psql -X --single-transaction` inside the
fixed guarded local database container, with `ON_ERROR_STOP=1`. There is no
remote connection or credential. Metadata-only single queries still use the CLI.
The statement obtains a deployment advisory lock and bounded table locks,
including migration history to exclude concurrent history writers, then checks
the entire observed application schema/configuration fingerprint and exact
historical migration digest/count, then applies the seven unchanged SQL bodies.
A wrong post-schema fingerprint raises and rolls back every change. Schema cache
reload is notified only after the postcondition passes. Repeat application is
refused. There is no automatic mutation retry after an uncertain outcome.

The approved disposable GitHub Actions harness first runs the existing individual
migration tests, removes named synthetic failure helpers and the empty test-only
Storage bucket before taking the final schema fingerprint, then retains only
the reconstructed baseline and the already-
live Woodland migration, resets synthetic data, and requires exact live-schema
parity. It exercises a bad precondition, forced postcondition rollback, the full
bundle, full catalog equivalence with the individually tested schema, unchanged
fixture history and repeat refusal. Real Auth/REST creation, onboarding and boss
regressions and actual Edge/Auth/Storage deletion tests run against the resulting
bundle. An Edge-first test before R03 verifies HTTP 503 while the account, exact
object bytes and refreshable original session survive. The harness does not register a
fake Management API migration row or claim hosted deployment evidence.

## Execution order after separate approval

1. Confirm final commit checks and AI review; record exact payload/Edge hashes.
2. Re-read metadata; stop if schema, migration history, endpoint absence or Edge
   version differs. Record current backup/recovery evidence before live changes.
3. Deploy the reviewed deletion handler first, retaining JWT verification. It
   fails closed at missing `begin_account_deletion` before revoking sessions or
   deleting anything. A brief deletion-unavailable interval is expected.
4. Apply only the rendered forward payload through a migration-recording API
   under name `release_hardening_r01_c04`. Never use root CLI push/reset/repair.
5. Verify exact post-schema, all prior history entries, one new history record,
   required RPC signatures/grants and the deployed Edge version/source.
6. Verify allowed signed-in beta flows on designated test accounts; destructive
   deletion QA requires a specifically disposable account, never a tester's real
   account. Record mobile/browser acceptance separately.

Failure policy: stop on drift/lock timeout/unknown outcome and inspect metadata
before any explicit retry. If Edge succeeds and SQL fails, leave deletion failing
closed until the SQL precondition is resolved; do not restore unsafe cleanup.
Do not remove receipt tables, reopen reward-forging privileges or restore the
proven completion race. Pause affected writes or forward-fix a verified regression.
A code rollback cannot restore deleted accounts or Storage bytes.

Founder approval must name this beta project, these seven changes and the Edge
replacement. It is separate from routine development merge approval in FIX_PLAN.
Production promotion, native distribution, external beta expansion, data repair
and launch remain excluded. This package alone cannot establish GO.
