# Private export and feedback retention — review package

Status: synthetic rehearsal and authenticated HTTP adapter implemented; hosted verification and activation pending.
No live data exported, delivered, deleted or scheduled by this change.

## What is implemented

`tool/support/privacy_workflow.mjs` extends the existing account export allowlist
with verified attachment bytes. It validates the complete attachment reference
set before reading any bytes, binds each object to its owner and immutable
version, checks size/SHA256, and caps exports at 100 files / 25 MiB.
The package is JSON with base64 attachments and a package checksum.

The synthetic private delivery model binds a cryptographically random ticket
to the authenticated requester, expires it after 15 minutes and consumes it
once. It preserves literal user content as JSON, never executable HTML.
It has no public URL, email sender, credential access or external storage.
The in-memory model is intentionally not a production delivery endpoint.

The retention planner resolves report attachment references against a complete
Storage inventory, blocks shared files referenced by retained reports, flags
missing/mismatched owners and unverified backup disposition, and hashes the
reviewed plan. Inventory drift requires a new review. It never authorizes or
performs deletion, even when a plan has no blockers.

## Proposed rules for founder review

1. Live feedback reports become eligible at exactly 90 elapsed days after
   creation, measured in UTC. A report created one millisecond later stays.
2. Only feedback records and exclusively associated feedback attachments are
   in scope. Account profiles, quests, bosses, rewards and cosmetics stay.
3. Attachment ownership, immutable version and all report references must be
   checked again immediately before any operation. Shared references block
   that report's complete deletion pending manual review.
4. Remove approved attachment bytes through the supported Storage API, then
   confirm absence, then delete the unchanged report. Preserve the report on
   an attachment failure. Journal partial progress without private content so
   retries can resume rather than claim atomicity across two services.
5. Live 90-day deletion and backup expiry must be described separately.
   Proposed backup window: at most seven additional days after live removal,
   giving a maximum of 97 days for recoverable feedback. This is NOT approved.
   Backups must not be allowed to silently reintroduce expired feedback during
   recovery; reapply the reviewed retention policy before opening a restore.
6. Existing B2 Keep all versions conflicts with bounded retention. Inventory
   every version and any recovery copies before choosing lifecycle/deletion
   settings. Database backups also require their own verified expiry policy.
   Do not equate a configured expiration date with verified removal.
7. Final activation needs approval of the actual deletion candidates, backup
   policy and operational permissions. This package grants none of these.

## Remaining deployment work

- Read-only live schema audit on 2026-10-10 reconciled all 13 public tables:
  eight account-owned groups are covered. The five remaining tables are shared
  cosmetics/Hearth definitions, not missing user-owned record groups. Auth
  records, orphaned uploads and device-local settings remain outside this scope.
- The new `supabase/functions/export-account` adapter verifies identity via
  Auth `/auth/v1/user`, reads only allowlisted fields under the caller's JWT/RLS,
  collects a single database snapshot, bounds streamed responses, and returns JSON directly
  to that requester with no-store/attachment headers. It never uses service-role
  credentials, emails data, writes files or creates a public download URL.
- Direct authenticated response is the candidate delivery approach; the earlier
  15-minute ticket model remains a separate synthetic experiment. This endpoint
  does not claim single-use ticket redemption or store a copy requiring expiry.
- Deployment defaults OFF (`QUESTWELL_EXPORT_ENABLED`). Explicit exact origins
  are configured through `QUESTWELL_EXPORT_ORIGINS`; requests without Origin
  still require a valid bearer token. Staging-only deployment described below; no production deployment or secret change performed.
- Session/deletion-fence checks and a database-backed 60-second per-account
  start limit are implemented. The session must exist, belong to the JWT subject,
  be within its not_after deadline, and not belong to an anonymous/deleting user.
  Check immediately before collection and immediately before delivery. The final
  check does not cancel bytes already sent after a later logout.
- Migration `20261010052031_account_export_guard.sql` applied ONLY to synthetic
  staging `hpjzfytwivlpsdhiupyd`. Production and recovery databases unchanged.
  The atomic upsert serializes claims; failed exports still consume the interval.
  No service-role token is used by the endpoint. Private definer functions expose
  only booleans; public wrappers are invokers; anonymous execute is revoked.
- Hosted SQL tests passed with the authenticated role: active session accepted,
  first claim accepted/second denied, nonexistent session denied, anonymous denied,
  deletion fence denied. All test writes rolled back; no user files were read.
  This is database integration evidence, not an end-to-end HTTP export test.
- Security advisor reported only informational private-table RLS-without-policy
  findings. The new limits table intentionally has no caller grants or policies;
  access is through the narrowly scoped private function.
  Reference: https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy
- Before enabling: hosted two-account HTTP export, real sign-out with the old JWT,
  concurrent claim/load tests, and snapshot/file consistency tests remain.
- Migration `20261010052354_account_export_snapshot.sql` applied only to staging.
  The STABLE, SECURITY INVOKER function reads all eight allowlisted record groups
  plus caller-owned beta-feedback object ID/version/ETag/size at the calling SQL
  query snapshot. It accepts no user ID. Hosted authenticated-role verification
  confirmed all eight groups and owner scoping without returning account content.
- The HTTP adapter compares downloaded ETag and byte length to that snapshot and
  rechecks record/file metadata before delivery. Changed versions, missing ETags,
  changed sizes or changed records fail closed. SHA256 of delivered bytes remains
  in the package. Actual hosted Storage ETag behavior still needs end-to-end testing;
  synthetic tests alone do not prove the provider's consistency guarantees.
- Limits: 10,000 rows/group, 8 MiB database/HTTP snapshot, 100 owned file metadata
  entries, 100 referenced attachments, 5 MiB/file, 25 MiB total attachment bytes,
  25-second upstream deadline. Larger exports fail without returning partial data.
- Shared catalog labels may improve readability of cosmetic IDs later; neither
  passwords/tokens nor internal feedback triage notes belong in this export.
- Build the reviewed retention executor with a durable journal and conditional
  rechecks; rehearse failures and retries on disposable synthetic fixtures.
- Apply no live purge, credential expansion, lifecycle policy or schedule until
  the proposed rules and concrete operation are approved.

## Validation

Eight tests cover a nonempty attachment export/delivery round trip, secret
exclusion, wrong requester, replay, expiration, cross-owner paths, missing and
incomplete inventories, changed bytes/version, 90-day boundary, backup blocking,
shared retained references, changed plan and unresolved attachment references.
The existing data-policy tests remain unchanged and run alongside these in CI.

The HTTP adapter tests cover identity injection, disabled mode, anonymous users,
origin rejection, private attachment round trips, cross-owner references, changed
records/authentication, streaming caps, user-scoped REST requests and exact-count
pagination failures. These use synthetic transports, not live credentials.

Run: `node --test tool/qa/data_policy_test.mjs tool/qa/privacy_workflow_test.mjs tool/qa/export_endpoint_test.mjs`

## Hosted HTTP test readiness — 2026-10-10

- `export-account` deployed to synthetic staging with JWT gateway verification.
  `staging.ts` enables only the exact staging project URL; all browser origins
  are denied. Production `index.ts` remains opt-in and was not deployed.
- Hosted missing-token and invalid-token requests both returned HTTP 401.
- `tool/qa/hosted_export_test.py` and the hosted staging export workflow exercise
  sign-in, owner scoping, nonempty attachment SHA256 validation, no-store,
  repeat-request throttling and old-token denial after local test-session logout.
  The response stays in memory; no export/token artifact or payload logging.
- Positive hosted testing requires the existing synthetic staging account email
  and password in repository Actions secrets `STAGING_EXPORT_TEST_EMAIL` and
  `STAGING_EXPORT_TEST_PASSWORD`. The fixture must have a feedback attachment.
  No production password, service-role key or recovery credential is requested.
  Missing secrets are reported as BLOCKED, never a passing test.


## Replacement-account hosted attempt — 2026-10-10 05:59 UTC

- Verified the approved replacement synthetic account exists, is confirmed, and
  has its public profile. Created one synthetic feedback record referencing the
  fixed test PNG path; no production records were changed.
- Runner commit `2548f0e4624b9914010af16a6aeff192f400c273` restricts fixture upload
  to that account, never overwrites an existing object, and requires the expected
  attachment SHA256 in the exported response.
- Hosted run https://github.com/funszdidiot/questwell-app/actions/runs/38029351167
  failed at sign-in: HTTP 400, `invalid_credentials`. Both secret variables were
  nonempty, but the saved pair did not authenticate. No attachment upload or
  export occurred in this run; download, throttling and logout checks remain open.
- The user must save the replacement account email and its matching password in
  the two repository secrets. No password values were retrieved or logged.
- Local Python compilation passed; the available local privacy/endpoint suites
  reported 18 passing tests. This is not a hosted-success claim.
- Rollback: revert the runner commit on this branch. The synthetic staging report
  remains for the next approved retry; no live export or retention activation.


## Hosted replacement-account verification PASSED — 2026-10-10 06:03 UTC

The corrected repository credentials resolved the previous sign-in blocker.
Run https://github.com/funszdidiot/questwell-app/actions/runs/38029351167,
latest attempt, job `114147598856`, passed on runner commit
`2548f0e4624b9914010af16a6aeff192f400c273`.

Verified through the hosted staging HTTP endpoint:
- Password sign-in and authenticated export succeeded.
- All eight account-data groups were present and returned rows belonged to the requester.
- The expected nonempty synthetic attachment passed byte-length and SHA256 checks.
- Response included Cache-Control no-store.
- An immediate repeated export returned HTTP 429.
- Local test-session logout succeeded; reuse of its token returned HTTP 401/403.
- Independent database read confirmed the 68-byte fixture's owner and private bucket.

No export payloads, passwords or session tokens were printed or saved as artifacts.
Production export and retention deletion remain disabled. This proves one synthetic
account's hosted golden path; hosted two-account negative tests, concurrent-load
and mutation-during-export tests remain before production acceptance. The staging
fixture remains available for repeat tests. No production data changed.


## Hosted isolation and concurrency PASSED — 2026-10-10

Run https://github.com/funszdidiot/questwell-app/actions/runs/38029714512
on commit `28b30cb14d64210a6b223c8009efd39773edbaa2` passed.
The synthetic requester received no rows when explicitly selecting the second
QA account's profile and feedback. Its request for the second account's known
private file was denied, and an export body injecting that account's ID returned
HTTP 400. Independent database reads confirmed those target rows/object actually
exist and belong to the existing QA account; this was not an absent-data test.
Four barrier-synchronized export requests produced exactly one HTTP 200 and three
HTTP 429 responses. The successful response passed owner, attachment checksum
and no-store checks; immediate repeat denial and post-logout denial also passed.

This is one-direction cross-account testing with a real signed-in requester and
four-way concurrency, not broad load/stress certification. Deterministic hosted
mutation-during-collection testing remains open. No production deployment,
retention deletion, auth-policy change or additional account creation occurred.
Rollback: revert runner commit `28b30cb14d64210a6b223c8009efd39773edbaa2`.


## Deterministic live-data mutation integration PASSED — 2026-10-10

Run https://github.com/funszdidiot/questwell-app/actions/runs/38029978905
on commit `9993427d2d58701f8e7f8fca26ea33f5cb8ef72f` passed both hosted
HTTP tests and the new `hosted_export_mutation_test.mjs` integration.

The integration runs the unchanged handler in Node against the real hosted
staging backend with the synthetic user's JWT. Instrumentation pauses after the
first snapshot, changes only that user's display_name using the normal RLS-scoped
REST API, and resumes. An actual attachment read completes; the second database
snapshot observes the changed field. The handler returns exactly the generic
HTTP 503 error and no export payload. Cleanup restores the original value via
a conditional update, rereads it and logs out. A separate MCP database fingerprint
comparison independently confirmed that the original profile value was restored.

This is a deterministic handler/backend integration with hosted services, NOT a
race injected into the deployed Edge Function's HTTP request. No deployed test
hook or production code change was introduced. The deployed HTTP golden path,
isolation, four-way concurrency and logout tests passed separately in the same
run. Actual hosted file replacement during reads and broader load tests remain
unverified; synthetic ETag/version/size rejection tests cover those logic paths.
Production activation and retention deletion remain disabled.

Rollback: revert `9993427d2d58701f8e7f8fca26ea33f5cb8ef72f` to remove the test
and workflow step. No schema or auth-policy rollback is needed; the synthetic
profile was restored.


## Production rollout scope for founder approval — 2026-10-10

Production preflight (read-only) verified eight required application tables and
`private.account_deletion_fences`. Export limits/snapshot and `export-account`
are not installed in production. Production has not been changed.

Reviewed implementation scope:
- `supabase/migrations/20261010052031_account_export_guard.sql`: additive private
  rate-limit table, session/deletion checks and caller-only wrappers.
- `supabase/migrations/20261010052354_account_export_snapshot.sql`: additive,
  caller-scoped snapshot RPC, using existing RLS rather than bypassing it.
- `supabase/functions/export-account/{index.ts,handler.mjs,backend.mjs}` and
  `supabase/functions/_shared/data_policy.mjs`: authenticated bounded download.
- The production rollout workflow/runner must be prepared on this branch and
  reviewed/tested before applying the versioned migrations through CI. Do not
  substitute untracked dashboard/SQL edits. No such production runner exists yet.

Rollout sequence after explicit approval of the authentication-sensitive change:
1. Prepare narrowly scoped CI runner, pinned payload/checks, and rollback gate.
2. Pass the PR checks and merge through the reviewed branch workflow.
3. Apply only the two versioned migrations through CI; verify grants and RLS.
4. Deploy production entrypoint with JWT verification and export disabled first.
5. Verify unauthorized denial and configuration, then enable authenticated API
   delivery. Browser origin allowlist must use verified app origins; no wildcard.
6. Verify a consenting production requester's download, limits and logout denial.
   Activation alone is not a completed production acceptance check.

Immediate rollback: set `QUESTWELL_EXPORT_ENABLED=false`; retain the additive
schema for investigation. No data deletion or auth-policy weakening is required.
The app's user-facing download entry and platform save behavior still require
integration/acceptance before calling self-service export fully delivered.

Limits: this endpoint exports allowlisted application data and referenced
feedback attachments; it excludes Auth records and orphaned uploads. It is not
a claim of comprehensive legal subject-access coverage. Four-way concurrency
is verified, not broad load certification. Administrative file replacement and
delete/recreate races remain outside the hosted tests; synthetic version checks
are evidence of logic behavior, not proof of every provider race.

Retention stays a dry-run planner; neither the 97-day proposal nor any live
purge, backup lifecycle change or cleanup of recovery copies is authorized here.


## Hosted overwrite restriction PASSED — 2026-10-10

Run https://github.com/funszdidiot/questwell-app/actions/runs/38030386584
on `a31df8ecd14dc125bd19cbedc84dc72e2cf63c46` passed. An authenticated
same-path upsert of the synthetic file was denied under existing Storage RLS.
The following export verified its original bytes by SHA256. The upsert used the
same fixture bytes so unexpected permission changes would not corrupt data.
Independent policy inspection found no permissive UPDATE policy; the session
policy is restrictive, not an alternate grant. No policies were changed to make
a replacement test possible. Hosted isolation/concurrency/logout checks and the
live-profile mutation/cleanup integration also passed in that run.


## Schema rollout runner prepared — 2026-10-10

`tool/deploy/export-schema.mjs`, `export-schema-approval.json`,
`tool/qa/export_schema_runner_test.mjs` and
`.github/workflows/questwell-export-schema.yml` now implement the schema-only CI
rollout that was missing above. Approval remains pending; no live request ran.
Nine local and GitHub guard tests passed:
https://github.com/funszdidiot/questwell-app/actions/runs/38030736552

The workflow executes live only on `deploy/export-schema-approved`, at the
current questwell-dev revision, with required checks passing, a matching payload
hash, recorded approval/backup evidence and expiry within 24 hours of backup
verification. It requires a dedicated `QUESTWELL_EXPORT_MIGRATION_TOKEN` secret;
its presence/permissions have not been verified. No existing content-rollout
credential was reused or expanded.

Two pinned versioned SQL sources are bundled into one migration-recording API
request named `reviewed_account_export_schema`. The bundle strips the standalone
BEGIN/COMMIT wrappers, uses a single guarded DO block, checks absence beforehand
and compares all five function-definition fingerprints plus limits-table RLS
afterwards. A stable idempotency key and exact recorded-payload verification
allow a verified no-write rerun. Ambiguous writes stop without automatic retry.
The Management API route/body/idempotency header were checked against its current
OpenAPI specification. No new package dependency or CLI was introduced.

Validation limits: guard tests use mocked transports; the new bundled SQL wrapper
has not been applied to production or rehearsed in a fresh disposable database.
The underlying migrations were applied and tested in hosted staging earlier.
Before executing live, complete the disposable bundle rehearsal and refresh the
backup evidence. Production Edge deployment and client download remain separate.
Schema-only authorization must not be represented as consent to retention purge
or to enable the endpoint. Keep approval pending until founder confirmation.
