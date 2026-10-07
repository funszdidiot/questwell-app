# Feedback attachment recovery

Scope: C14 flow 9, continuing PR #51 from development `762280eb`.
No live schema, grants, reports, objects, Auth settings or signed releases change.

## Reproduction

Tests-only PR #53 head `a95233213b33acd8dfd8b8e406a8a08309723fc6`, Flutter
run `37568424012`, focused job `112621363238`: **292 passed / six failed**.
The unchanged source could not recover identical uploaded bytes after collision
or lost response, did not verify colliding content, and accepted a duplicate
report ID even when message or attachment selection differed. The owner-switch
verification regression also failed because no verification read existed.
Synthetic HTTP and sessions only; this is not a report of exposed tester content.

## Recovery contract

- Save ordered screenshot names, MIME types, byte lengths and SHA-256 fingerprints
  with the original account's draft before network work. Do not persist image bytes.
  A failed required save prevents sending.
- An unchanged attempted report first reads its exact owner/ID receipt. Every
  immutable server payload field, including ordered attachment paths, must match.
  Matching receipts finish locally without upload/insert. Failed lookup is not absence.
- If no receipt exists, keep the same request ID. Upload once with `upsert:false`.
  After a conflict or unconfirmed response, read and compare the private object's
  bytes; never overwrite an object or infer success from conflict alone.
- Reopened screenshots without in-memory bytes may be reused only after verifying
  the saved fingerprint/length. Missing or different objects block submission;
  the form explains removal/reselection. Never silently send text-only instead.
- Editing text or adding/removing screenshots after an attempt starts a new report
  ID. Restored screenshots under a newly edited ID may need explicit reselection;
  we do not copy, delete or repurpose an earlier report's remote objects.
- Old attempted drafts without manifests may recover a matching original receipt.
  An absent receipt requires an explicit edit/reselection, not invented attachment intent.
- Owner checks guard reads/writes and their completions. A late file-picker result
  cannot mutate a sending or sent request. Independent review found this race;
  pending-save and after-success regression cases cover the correction.
- Cleanup remains limited to known fresh uploads before any insert starts. Files
  from prior attempts and confirmed/uncertain inserts remain untouched.
- The database payload has an explicit field allowlist; local manifest fields are
  never sent as columns. Server RLS and existing insert uniqueness remain unchanged.

## Verification and limits

The existing test file runs in Flutter, Chrome and critical coverage. New cases
cover collision/lost-response verification, content mismatch, owner changes,
complete receipt identity, manifest serialization and ID rotation, local payload
exclusion, reopened receipt/object recovery, missing/corrupt objects, failed local
save/read, legacy draft behavior, and delayed picker races. Existing isolation,
disposal and uncertain-insert cases remain. Final CI/review/deployment results are
recorded in PR #53 and FIX_PLAN; the tests-only failure is not a green result.

`crypto` 3.0.7 is promoted from the existing locked transitive package to a direct
dependency; version, checksum and resolved package graph are unchanged. CI verifies
the lockfile with an empty cache. No local dependency resolution was retried after
the earlier security-review denial. The touched draft is now formatted; its single
legacy formatting allowance is removed, with no diagnostic baseline relaxation.

Supabase changelog and current Dart upload/download docs checked October 7, 2026.
The pinned storage SDK remains 2.4.0 and Flutter SDK 2.9.0; no new API or grant.
Private downloads require the existing owner SELECT policy. References:
https://supabase.com/changelog and
https://supabase.com/docs/reference/dart/storage-from-download .

Hosted signed-in flow 9 and signed physical-device acceptance remain separate.
An interrupted upload may still leave an unreferenced private object; this patch
does not run hosted orphan cleanup or claim a retention policy.
