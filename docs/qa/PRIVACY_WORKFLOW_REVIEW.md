# Private export and feedback retention — review package

Status: synthetic rehearsal complete; live adapters and activation pending.
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

- Audit the existing export allowlist against the current schema. It currently
  contains eight record groups; newer Hearth configuration tables are not yet
  included. Do not call it a complete account export until reconciled.
- Implement a server-side consistent/paginated owner-scoped collector and
  conditional attachment reads; derive requester identity from a verified
  server session, never a supplied owner ID or email address.
- Implement durable private encrypted delivery storage and atomic redemption,
  authenticated download, expiry cleanup, and audit records without payloads
  or ticket values. Test recovery, concurrent redemption and delivery failure.
- Test a hosted synthetic request through collection, package creation,
  authenticated delivery and expiry before delivering any real user's data.
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

Run: `node --test tool/qa/data_policy_test.mjs tool/qa/privacy_workflow_test.mjs`
