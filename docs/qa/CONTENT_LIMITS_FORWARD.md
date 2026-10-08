# Approved content limits: guarded live rollout candidate

Status: guarded runner preparation and disposable rehearsal only. No live installation or launch
is authorized by this file. The approved content policy and migration are unchanged.

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

`content-limits-approval.json` deliberately remains **pending**. It blocks all
network access even if someone supplies credentials. After actual G3 approval and
backup verification, a reviewed update must reference that evidence, the exact
payload SHA256, and a window expiring within24 hours of backup verification. This
record is an operator attestation, not an automatic backup inventory or restore
test. Never invent evidence or turn pending into approved to make CI pass.

Execution also requires current successful development checks, matching root and
staging delivery, exact live preconditions, and the dedicated
`QUESTWELL_CONTENT_MIGRATION_TOKEN`. Request only this project's Database read and
Migrations read-write permissions, with separately approved storage and expiry.
No token is created, reused or exposed by this change. The runner rechecks the
development head and approval freshness immediately before its single migration
request. The SQL retains its independent transactional drift checks and locks.

Readback requires exact protected schema/history hashes, both functions, four
triggers, owner grants, one14-digit migration record and its source digest marker.
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
