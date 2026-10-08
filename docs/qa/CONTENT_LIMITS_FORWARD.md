# Approved content limits: guarded live rollout candidate

Status: exact-scope live beta installation approved on October 8, 2026; execution
and readback are still pending. See the approval receipt below. This is not launch
approval. The approved content policy and migration are unchanged.

Target is the existing beta project `bdzcazkyypopbanbjnud`. Source is exactly
`supabase/migrations/20261008023552_approved_content_limits.sql`, SHA256
`f9898988c1389088c79e6c62bc3cbf4e47753c867b1336ea9a8ec0d73a8c0c9a`.
It adds two private invoker trigger functions, three title/description triggers and
one boss-step-count trigger. It performs no content scan, rewrite, deletion,
history repair, root replay, Auth change, grant expansion or reward change.

The offline renderer accepts no arguments, credentials, alternate targets or
state overrides. It prints SQL only. It cannot apply anything. Its manifest pins
the source and catalog query, the October 8 live application schema and all 52
historical migrations, and the exact installed function/trigger/grant metadata
independently read from staging. The complete unrelated catalog must stay equal;
only the two named helpers, four named triggers and their owner grants may differ.
Any extra overload, changed policy or unexpected privilege fails the hash checks.

The payload arms a 20-second statement timeout before its DO statement, takes a
shared deployment advisory lock and bounded table/history locks, checks the exact
precondition, installs the source unchanged, then checks both the untouched catalog
and the exact new objects. A postcondition mismatch raises in the same transaction.
Repeat application is refused. There is no automatic retry after an unknown result.

The disposable GitHub-hosted harness adapts only the synthetic pre-schema/history;
it retains the staging-derived postcondition. It exercises timeout cancellation,
precondition drift, forced postcondition rollback, exact successful installation
followed by rollback, and repeat refusal in one transaction. The original migration
then runs through the existing Unicode/description/50-step/legacy and Auth/REST
tests. A local Node check alone does not establish these database results.

## Evidence before live execution

1. Require independent review and successful final-candidate Flutter/backend CI.
2. Re-read live metadata; stop on drift. Do not replace expected hashes merely to
   make a failing gate pass. Reconcile every actual intervening change first.
3. Verify current backup readiness and obtain exact-scope live deployment approval
   through the established G3 process. Existing policy approval does not authorize
   a restore, purge, history repair, paid service or production promotion.
4. Use a reviewed migration-recording CI path with the exact project/name/payload.
   Both statements must share its single transaction. No direct SQL-editor edit,
   root `db push`, reset or history repair. This preparation does not add a hosted
   executor activation or reuse another migration's scoped credential.
5. Verify the 52 historical entries unchanged, one new recorded migration, both
   helper bodies/security/ACLs, four enabled triggers and retained RLS. Only then
   run accepted synthetic-account boundary and legacy-completion checks.

Read-only inventory at preparation: 49 quests; maximum title lengths 57 for quests
and 22 for bosses; notes absent; largest boss has three steps. Existing blank
titles must still be preserved. These aggregate facts are not acceptance tests.

Rollback: an execution failure rolls back its transaction. After a successful
installation, do not delete history or silently remove enforcement. Pause the
affected write path and prepare a reviewed forward correction; any intentional
policy reversal requires founder approval. Reverting this preparation PR only
removes the offline tooling and disposable rehearsal.

## Dormant CI runner

`tool/deploy/content-limits.mjs --check` checks the fixed source offline. Running
without arguments is restricted to GitHub-hosted Actions, this repository and
`deploy/content-limits-approved`. No caller can choose another project or payload.
The dedicated workflow runs credential-free guards on PRs and development pushes;
its apply job cannot run from either. Do not create/push the deployment branch or
configure its new token until the exact live action is authorized.

`content-limits-approval.json` records the actual approval below. A pending record
blocks all network access even if someone supplies credentials. The reviewed
approval update references that evidence, the exact
payload SHA256, actual backup completion time, verification time, and a window
expiring within 24 hours of the backup's completion. Rechecking an old backup
does not renew its freshness. This
record is an operator attestation, not an automatic backup inventory or restore
test. Never invent evidence or turn pending into approved to make CI pass.

Execution also requires current successful development checks, matching root and
staging delivery, exact live preconditions, and the dedicated
`QUESTWELL_CONTENT_MIGRATION_TOKEN`. Request only this project's Database read and
Migrations read-write permissions, with separately approved storage and expiry.
The separately approved token was created and stored through the provider and
GitHub interfaces; its value is absent from this repository. The runner rechecks the
development head and approval freshness immediately before its single migration
request. The SQL retains its independent transactional drift checks and locks.

Readback requires exact protected schema/history hashes, both functions, four
triggers, owner grants, one 14-digit migration record and a SHA256 match of the
complete recorded statement sequence to the reviewed payload. A matching source
comment alone is insufficient. Unexpected provider statement rewriting fails
closed and requires read-only reconciliation; never weaken the comparison to
accept additional or different SQL.
Already-applied matching state returns without a write. A timeout, HTTP error or
failed readback is never retried automatically; reconcile read-only first. Server
bodies, SQL, tokens and assertion diffs are suppressed by the CLI.

Validation includes fake-transport failures plus the actual runner metadata query
against pre-install and recorded post-install states in disposable PostgreSQL.
The recorded fixture is rolled back. These tests do not prove hosted installation.

Current API contract checked October8:
[apply migration](https://supabase.com/docs/reference/api/v1-apply-a-migration).
The migration-recording endpoint receives one fixed name/query request. No dependency,
Postgres, Auth, Storage, extension or platform upgrade is part of this change.

References checked October 8: [Supabase migrations](https://supabase.com/docs/guides/deployment/database-migrations)
and the existing reviewed hardening/Halloween transactional deployment patterns.

## October 8 live beta approval

Tanya replied **“Yes”** at 2026-10-08 08:24:56 America/Chicago
(13:24:56 UTC) to the concrete request to apply the agreed content limits to the
existing live beta after postmerge checks, using a new project-only, 24-hour
Supabase token stored in GitHub Actions with **Database Read + Migrations
Read-write**. This approves only project `bdzcazkyypopbanbjnud`, migration name
`approved_content_limits_live` and guarded payload SHA256
`c8ab7ae3f3025f4631bf8d4b7ca85ad72a41e859096d65cf52409d5d1e7b30cf`.
It does not authorize root migration replay/repair, existing-data changes,
restore/purge, production promotion, paid changes or unrelated permissions.

Backup evidence: the authenticated project's scheduled physical backup completed
at **2026-10-08T07:53:34Z**, was verified again at 13:25 UTC, and is preserved as
`questwell-backup-evidence-20261008.jpg` (Library evidence
`libfile_394d774ec2908191b0c30c43f46d7eb4`, version 0). The execution window expires
at **2026-10-09T07:53:34Z**, measured from actual completion. This is database
backup evidence only; it does not establish a Storage object backup or restore.

The token named `Questwell content rollout 2026-10-08` was created with only the
approved project, capabilities and 24-hour expiry, then stored as repository
Actions secret `QUESTWELL_CONTENT_MIGRATION_TOKEN` at approximately 13:35 UTC.
Its value was transferred directly through the browser and was not printed,
written to a local file, committed or placed in a comment. GitHub confirmed
“Repository secret added.” Prior runner PR #85 is merged at
`eb9a8198e03f075db54d16661ff7a2ae24c3a8c2`; postmerge Preview `37782918709`
and Backend `37782917740` both succeeded.

This receipt must receive independent review and successful candidate checks,
then merge into `questwell-dev`. Only after the resulting development revision's
checks and root/staging delivery pass may that exact revision be placed on
`deploy/content-limits-approved`. The runner must still pass every approval,
current-head, delivery, metadata and transactional guard. Record execution and
read-only verification separately; approval and secret presence do not prove
installation or signed-in acceptance. Support automation remains paused.
