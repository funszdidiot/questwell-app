# Synthetic recovery rehearsal

Status: implementation awaiting independent review and execution. No recovery
result is claimed until the backend workflow passes the final recovery scenario.

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
Identical disposable platform roles/extensions are prerequisites, not restored
infrastructure. A generated marker and absent target-name checks guard switching.

Before switching services, it compares schema/functions/RLS/grants and content
hashes/counts for public/private tables, Auth users/identities and Storage
objects/buckets. Fresh password sign-ins then verify both owners, isolated quests,
balances, reward consistency, boss steps and feedback. Exactly the newly created
image is removed through Storage's API to simulate lost bytes. The restored
metadata must NOT make that image downloadable. Restoring the saved bytes must
produce the same byte length/SHA-256, with other-owner and anonymous access denied.

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
