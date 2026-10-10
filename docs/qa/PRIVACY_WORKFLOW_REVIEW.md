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
  requires exact page counts, bounds streamed responses, and returns JSON directly
  to that requester with no-store/attachment headers. It never uses service-role
  credentials, emails data, writes files or creates a public download URL.
- Direct authenticated response is the candidate delivery approach; the earlier
  15-minute ticket model remains a separate synthetic experiment. This endpoint
  does not claim single-use ticket redemption or store a copy requiring expiry.
- Deployment defaults OFF (`QUESTWELL_EXPORT_ENABLED`). Explicit exact origins
  are configured through `QUESTWELL_EXPORT_ORIGINS`; requests without Origin
  still require a valid bearer token. No deployment or secret change performed.
- Before enabling: add verified active-session/deletion-fence enforcement,
  durable request rate limits, and hosted two-account/revoked-session/load tests.
  Auth user verification alone is not evidence of immediate logout revocation.
- Re-reading all record groups detects visible drift but is NOT a transactional
  database snapshot. Referenced attachments are fetched under Storage RLS and
  hashed on receipt; the adapter does NOT yet prove immutable-version consistency.
  Establish that guarantee before treating it as a complete point-in-time export.
- Limits: 10,000 rows/group, 250-row exact-count pages, 2 MiB/page, 8 MiB serialized
  record characters, 100 referenced attachments, 5 MiB/file and 25 MiB total
  attachment bytes, 25-second upstream request deadline. Over-limit requests fail
  without returning a partial export; larger-account handling remains pending.
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
