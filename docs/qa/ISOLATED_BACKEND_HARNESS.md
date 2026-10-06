# Isolated backend test foundation

Scope: the approved temporary GitHub Actions test target (G2), now extended
with the observed application schema and a narrow task-completion smoke test.
See [APPLICATION_SCHEMA_BASELINE.md](APPLICATION_SCHEMA_BASELINE.md) for B03's
source capture, comparison, failed legacy replay and remaining deployment gate.
This is **not a complete authorization, deletion or release-readiness attestation**.

## Safety boundary

- Runs only on a fresh GitHub-hosted runner. No self-hosted runner support.
- Workflow token has contents:read only; checkout does not retain credentials.
- No repository secrets, Supabase login/link, hosted project creation or remote
  migration command. Unexpected Supabase/Postgres target/credential environment
  variables cause a preflight failure without printing their values.
- A new runner-temporary workdir first receives only the reviewed harness config.
  After fixture checks, it receives the isolated observed-schema migration from
  tool/backend_ci/app. The root legacy chain, live linkage and environment files
  are never copied. API/database endpoints must match fixed numeric loopback URLs.
- HTTP redirects are forbidden; requests have a ten-second timeout.
- Tests use random synthetic @example.test accounts. Email confirmation is
  disabled only in this disposable configuration; no real SMTP/OAuth is used.
- SQL fixture writes are local-only and later fixture writes require its marker.
  The subsequent reset replaces the fixture with the observed application schema;
  its migration refuses a database containing public.users or Auth users. Schema
  comparison precedes synthetic application writes and the app RLS negative control.
  Cleanup targets only questwell-disposable-ci with its exact workdir.
  Normal completion/failure disposes its containers and volumes. A cancelled
  runner is discarded by GitHub; do not reuse its state.

The local development stack has development credentials and no production TLS
hardening. It must never be published, tunneled or used for real users. These
guards prevent accidental targeting; they are not a sandbox for malicious PR
code. No production credentials are made available to the job.

## Toolchain and verified interfaces

- Supabase CLI 2.119.0, official 2026-09-30 release; standalone Linux amd64 archive.
- Archive SHA-256 (checked against the official release metadata):
  `bf1c3ae93be98533eb8a3105dbf4564bd0b2d9dc24690d8a920f980ef975c1b4`.
- New workflow checkout is pinned to actions/checkout v4.2.2 commit
  `11bd71901bbe5b1630ceea73d27597364c9af683`.
- Config fields come from that CLI's actual `init` output. Installed help was
  inspected for start, status, db query, db reset and stop; the runner repeats
  help checks. Postgres major version is 17; exact service image versions are
  selected by the pinned CLI, not asserted identical to the hosted project.
- Node built-ins only; no new npm/Dart dependency or client-library version.
  Flutter's committed lockfile remains unchanged.

Official references reviewed 2026-10-05:

- https://github.com/supabase/cli/releases/tag/v2.119.0
- https://supabase.com/docs/guides/local-development/cli/getting-started
- https://supabase.com/docs/guides/local-development/testing/overview
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://github.com/supabase/auth/blob/master/openapi.yaml
- https://docs.postgrest.org/en/stable/references/api/tables_views.html

The changelog review included current Postgres, API grants and gateway changes.
The fixture uses explicit grants and RLS, no implicit table exposure. No hosted
upgrade or gateway reconfiguration is part of this work.

## Original PR #18 evidence and current limits

First red test (before the guard existed):

    Error [ERR_MODULE_NOT_FOUND]: Cannot find module '.../tool/backend_ci/guard.mjs'
    tests 1
    pass 0
    fail 1

After implementation, all six guard tests passed locally; the combined existing
Node suite plus guard tests passed 18/18. Tests cover runner identity, credential
rejection without leakage, exact URL validation, missing credentials, zero
network calls on unsafe input, forbidden redirects and bounded requests.

The integration job is designed to run real Auth signup/login/session checks,
REST owner/anon/non-owner reads and writes, ownership-transfer rejection and
legitimate owner update/delete against public.ci_owner_probe. Its negative
control disables RLS on **that synthetic fixture only**, proves that the same
isolation assertion detects the leak, restores RLS, then repeats the check.
Consult the PR's exact-head CI run for executed results; design is not proof.

First integration attempt, run 37325367335 at head 8846afc828b23c0f2bb175290390ee0a69a40e81:
CLI startup, loopback validation and local reset succeeded, but fixture loading
failed before Auth/REST tests:

    failed to execute query: error: cannot insert multiple commands into a prepared statement

CLI 2.119.0 prepares one SQL statement even with --file. The fixture and guarded
mutations now each use a single transactional DO block; no SQL splitter or
ignored error is used. The failed run's finally cleanup completed. This failure
is not an app defect or passing integration evidence.

The hosted runner also warned that checkout v4 targets the deprecated Node 20
action runtime and is being executed under Node 24. Existing workflow action
upgrades remain the separate C08 concern; this PR does not silently bump them.

The original PR #18 rebuilt only the fixture. PR #19 adds a second local reset
from the separately identified observed application baseline, exact recorded
catalog comparison, a real catalog negative control and limited actual-app checks.
The legacy root chain still fails, and no production history repair is performed.
QW-04 therefore remains partially open. Storage operations, hostile reward inputs,
deletion, Edge Functions, native/devices and full hosted parity are not certified.

Do not mark QW-01, QW-02 or QW-03 fixed by these checks. They preserve the observed
application behavior, including known defects, to enable focused regressions next.
Client environment selection (B02) remains separate and unchanged.

## Risk and rollback

The new job can fail due to upstream image/network availability; it never
deploys. No app code, art, economy, live authorization or applied migrations
change. Roll back with a reviewed revert of this test-foundation PR; that loses
its safety net but requires no user-data restoration. Merge requires Tanya's
separate approval. A green harness job is not permission to expand testing.
