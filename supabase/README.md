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
