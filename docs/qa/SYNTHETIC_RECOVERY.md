# Synthetic recovery rehearsal

Executed results are recorded in the backend workflow's final `synthetic recovery`
record and the release FIX_PLAN. This procedure alone is not recovery evidence;
the complete workflow and final recovery scenario must pass.

`tool/backend_ci/recovery.mjs` runs only at the end of the existing GitHub-hosted
disposable backend harness. It accepts no target override. It rejects hosted
credentials, remote Docker settings and non-hosted runners. Its only API is the
fixed loopback fixture; Docker operations name only the existing fixture stack.
No hosted project, existing QA account, DNS, art or production code is changed.

The scenario creates two synthetic accounts, separate quests, one completion and
reward, a two-step boss, feedback and an actual PNG. It downloads the bytes and
takes a full logical database archive, including Auth and Storage metadata. The
archive stays in memory and is never uploaded or printed. The source database is
retained under another name; restore is into a separately created empty database.
Identical disposable platform roles/extensions and retained Auth/Storage service
configuration/signing keys are prerequisites, not restored infrastructure. A
generated marker and absent target-name checks guard switching.

Before switching services, it compares schema/functions/RLS/grants and content
hashes/counts for public/private tables, Auth users/identities and Storage
objects/buckets. PostgreSQL reparses source CHECK constraints on empty temporary
LIKE tables inside rolled-back transactions before comparison: logical restore
flattens nested AND nodes. No parentheses are stripped and no constraint is
excluded; source tables and historical catalog gates remain unchanged.
A real target-side negative control replaces one CHECK with `CHECK (true)` inside
a rolled-back transaction, requires comparison to reject it, then verifies normal
catalog parity again.
Fresh password sign-ins then verify both owners, isolated quests,
balances, reward consistency, boss steps and feedback. Exactly the newly created
image is removed through Storage's API to simulate lost bytes. The restored
metadata must NOT make that image downloadable. Restoring the saved bytes must
produce the same byte length/SHA-256, with other-owner and anonymous access denied.
The freshly authenticated owner recreates only this synthetic path through
Storage DELETE/POST; no SQL metadata edit, token minting, permission change or
service-role upsert is used. Its owner ID and account-deletion inventory must
match afterward. Internal object ID/version/timestamps are recreated; stable
path, ownership, feedback reference and file bytes are the restored guarantees.
This matters because [Storage ownership follows the caller's JWT subject](https://supabase.com/docs/guides/storage/security/ownership).

Timing starts before file retrieval/database export and ends after acceptance.
Sanitized CI output records the conservative database recovery-point lower bound,
end time, elapsed seconds, checked-table count and archive/file hashes. The check
compares this small fixture to the approved 24-hour RPO and 8-hour RTO objectives.
It does not prove scheduled backup freshness, production scale, provider recovery,
all Storage files, infrastructure/secrets reconstruction, external Auth mail or
hosted disaster recovery. These remain release gates. The runner disposes only its
new local stack at the end, including on failure; no hosted cleanup is authorized.

Supabase documents that [database backups exclude Storage file bytes](https://supabase.com/docs/guides/platform/backups).
This same-image local logical restore is a CI drill, not the provider's hosted
backup-restore process or a command to run against a live project.
