# Database history is not yet deployable

The 23 files in `migrations/` are an incomplete historical record. A real clean
replay with pinned Supabase CLI 2.119.0 fails at the first migration:

```text
Applying migration 20260930222423_gentle_xp_curve.sql...
ERROR: LOCK TABLE can only be used in transaction blocks (SQLSTATE 25P01)
```

It also lacks the initial `public.users` / `public.tasks` definitions. The 48
remote history entries do not contain that original bootstrap either. Do not
run a remote reset, repair history, concatenate the two histories, or push these
files to production to try to resolve the discrepancy.

For the approved disposable CI target, `tool/backend_ci/app/supabase/migrations/`
contains a separately identified **observed current-schema baseline**. It is
tested through `tool/backend_ci/run.mjs` on a fresh GitHub-hosted runner only.
It contains no real users or catalog inventory and is not a production migration.

See [the baseline evidence and reconciliation inventory](../docs/qa/APPLICATION_SCHEMA_BASELINE.md).
Live history reconciliation, a deployable forward migration strategy and any
production operation still require their separately reviewed G3 scope.

## Scoped male Woodland continuation — 2026-10-05

Tanya's “Next”, in response to the request to take on the blocked database
deployment step, authorizes preparation and execution of this one forward change.
It does not authorize replay/history repair, other pending migrations, R01 task
reward deployment, new credentials, production promotion or merge to `flutterflow`.

The reviewed path is `.github/workflows/questwell-woodland-forward.yml` and
`tool/deploy/male-woodland.mjs`. It submits only the hash-locked male Woodland SQL
to the fixed project's Management API, after same-revision Flutter/backend checks
and exact state guards. It never invokes a remote CLI push/reset/repair. The 48
existing migration rows must remain identical; the API adds its own new version
for `male_woodland_approved_rollout` with the source hash recorded in its SQL.
Do not assume that server-assigned version equals the source filename timestamp.

See [the scoped deployment runbook](../docs/qa/MALE_WOODLAND_FORWARD_DEPLOYMENT.md)
for the tested payload, credential gate, drift/timeout handling and client gate.
This single-change path does **not** make the incomplete root chain deployable.

## Verified male Woodland database deployment — 2026-10-05

Tanya separately approved the scoped 24-hour deployment token and its GitHub
Actions storage. Workflow `37360094077` retry job `111981993154` applied the
unchanged tested `76e2242` payload at 21:20:48 UTC as remote migration
`20261005212048`. All guarded postconditions passed; independent read-only checks
confirm male support, 49 total history entries and exactly one Woodland record.
The earlier credential blocker is resolved. Other live migrations and history
repair remain gated. Preserve the tested deployment branch. PR #22 still needs
fresh combined-revision checks, its own founder merge approval under FIX_PLAN.md
and delivered runtime verification. No `flutterflow` promotion is authorized.

## Male Woodland development delivery — 2026-10-05

Tanya approved PR #22's merge. Development revision `fad7777` is deployed and
verified: 390 Flutter tests, combined backend checks, served revision, four locked
asset hashes, and sample Market buy/equip/unequip passed. The live fit migration
was already verified. Earlier draft/client-gated statements are historical.
Signed-in hosted-account and physical iPhone/Safari acceptance remain pending;
no result has been reported. Do not treat “Next” as a passed manual test.
See `docs/qa/MALE_WOODLAND_ACCOUNT_ROLLOUT.md`. No production promotion or other
live migration/history repair is included.
