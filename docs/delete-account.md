# Account deletion

Adventurer → Delete account → type DELETE → Permanently delete.

## Proposed R03 behavior

The `delete-account` Edge Function verifies the bearer token through Auth and
rejects caller-supplied account IDs. It revokes all refresh sessions, removes
only the verified user's owned Storage objects through the Storage API, then
hard-deletes that Auth user. The service-role key remains server-side.

The service-only `account_deletion_objects(uuid)` RPC reads `owner_id` metadata
across all buckets. It returns at most 100 objects from one bucket, in stable
name order. The handler deletes that page and re-reads the first remaining page
without advancing an offset. A request performs at most ten removal batches
(1,000 objects) with a nine-second shared network budget. A remaining page,
invalid inventory, timeout or backend failure produces an unconfirmed response;
Auth removal is attempted only after an empty inventory is observed.

Objects uploaded through service credentials have no user owner; shared assets
and other users' objects are retained, even when their paths resemble the user's
folder. Ownership comes from Storage metadata, not a filename prefix or a
feedback row. Storage metadata is never deleted through SQL.

The existing beta-feedback screenshot upload/read/delete ownership policies
remain. An additional restrictive policy checks the authenticated caller's
`session_id` against their own `auth.sessions` row. This prevents revoked or
deleted sessions from recreating files with an unexpired access token. The
private helper returns only a boolean and checks `auth.uid()`; Auth tables are
not exposed. Existing valid-session ownership rules still apply. This change
does not claim to revoke stateless JWTs across every other application API.

Existing foreign-key cascades remove profile, tasks (including set-aside quests),
boss battles and steps, cosmetics ownership, beta feedback, reward events and
progression history. Shared cosmetic catalog rows remain. The existing
`private.return_unsupported_trophy` Auth-cascade exception remains unchanged.

## Interrupted requests and recovery

Storage deletion and Auth deletion are separate operations. Removed files cannot
be rolled back if a later operation fails. The confirmation includes feedback
and uploads, and failure copy explicitly warns that some files may already be
deleted. Closing that error never reports successful account deletion.

A failed or timed-out request never claims success; it may have partly or fully
completed on the server. If the account still exists, sign in again and explicitly
retry to process the remaining files. A deleted/invalid account returns 401 on a
repeat request, with no further deletion. The app never retries this mutation
automatically. Local auth, pinned-quest preferences and feedback drafts clear
only after the existing confirmed-success flow.

## Verification and rollout limits

Node tests cover request authorization, cleanup ordering, bounded work, malformed
inventory, another owner's inventory, partial Storage failures, retries, and
revocation/Auth failures. Flutter tests cover confirmation, cancellation,
duplicate clicks and truthful failure handling. The disposable CI harness serves
the actual Edge entry point using the existing `supabase-js@2.57.4` pin and tests
real Auth, REST and Storage with synthetic accounts. A byte-identical historical
handler from `dc9e48c` runs as a negative control before the R03 migration; the
runner must observe the old owned-file failure and stale-token upload before
testing the proposed fix. It also tests multiple
pages/buckets, cascades, old tokens and retry after an injected Auth cascade
failure. CI-only fault triggers and policies are not production migrations.

R03 is a source proposal until its exact PR head passes CI and review. The
migration and Edge Function have not been applied to hosted Supabase. A merge to
`questwell-dev` can deploy the development preview; that preview simulates
account deletion and cannot establish live deletion behavior.

For a separately approved hosted rollout: inventory legacy `owner`-only objects
and service-created user files, confirm the existing Storage/Auth schema and
permissions, and reconcile the incomplete root migration history first. Apply
only the reviewed migration and compatible Edge version under G3; never replay
or reset the unresolved root chain. Any ownership reassignment needs a separate
reviewed decision. Do not test by deleting founder or tester accounts.

If unsafe, pause the deletion endpoint and forward-fix. Reverting code cannot
restore deleted files or accounts. Do not remove the session restriction or
restore a handler that skips cleanup and call that a safe rollback. Recovery
policy, hosted impact review, native/device checks and release gates remain open.

## Official references checked October 5, 2026

- [User management and deletion](https://supabase.com/docs/guides/auth/managing-user-data)
- [Session revocation and access tokens](https://supabase.com/docs/guides/auth/sessions)
- [Storage ownership (`owner_id`; `owner` is deprecated)](https://supabase.com/docs/guides/storage/security/ownership)
- [Deleting object bytes through the API](https://supabase.com/docs/guides/storage/management/delete-objects)
- [Read-only Storage metadata](https://supabase.com/docs/guides/storage/schema/design)
- [Managed-schema restrictions](https://supabase.com/changelog/34270-restricting-access-on-auth-storage-and-realtime-schemas-on-april-21-2025)

The managed-schema restriction notice prohibits custom indexes, despite the
Storage design page's general index recommendation. The pinned local stack
confirmed this restriction. No schema object is added inside managed `auth` or
`storage` beyond the supported Storage RLS policy. Inventory-query performance
at realistic object counts remains a rollout gate; do not alter managed-table
ownership or elevate the migration role to add an index.
The published 2.57.4 package manifest pins Auth JS 2.71.1 and Storage JS
2.12.1. No SDK upgrade, new package, live Auth policy setting or object
reassignment is included.
