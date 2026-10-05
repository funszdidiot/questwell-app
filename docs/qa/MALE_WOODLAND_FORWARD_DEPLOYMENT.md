# Male Woodland: reviewed forward deployment

Status: **QA complete; execution BLOCKED by a missing repository Actions secret.**
No live write performed. Workflow `37360094077` stopped at the credential check,
before any GitHub check-API or Supabase request.
Authorization: Tanya's “Next” on 2026-10-05 continues the explicitly proposed
database deployment step for the approved male Woodland inventory/equip rollout.
The artwork stays LOCKED and byte-identical. PR #22 keeps the enabled client
unmerged until the database step succeeds and is verified.

## Executed evidence and exact next action

Tested source revision: `76e2242bcc749feb667db05f9888029fda2b8285`, tree
`e4e20a5c3979781b7e7c91ba389ce412af2f665b`. The deployment branch points to this
exact revision; documentation-only follow-ups do not change that tested payload.

- [Flutter/build 37359506496](https://github.com/funszdidiot/questwell-app/actions/runs/37359506496),
  job `111930263227`: **SUCCESS**, 390 Flutter tests, 12 Node checks, locked assets
  and dependencies, existing analyzer gate (46 inherited warnings/infos), release
  web build. No artwork, dependency or client code changed in this database step.
- [Backend 37359506568](https://github.com/funszdidiot/questwell-app/actions/runs/37359506568),
  job `111930266573`: **SUCCESS**, actual precondition refusal and full rollback
  after forced postcondition failure, exact SQL success and repeated-SQL refusal.
  All eight Woodland Auth/RPC/persistence checks pass on the pre-R01 baseline and
  again after R01. Existing fixture/app smoke, 19 Node guards, 20 reward and two
  forced reward rollback checks pass. Other schema/ACL/RLS/API definitions match;
  post-change SQL lint reports no errors. The local stack/data were disposed.
- [Deployment guards 37359506621](https://github.com/funszdidiot/questwell-app/actions/runs/37359506621):
  **SUCCESS**, all 15 failure-path tests and offline source/payload verification.
- [Deployment attempt 37360094077](https://github.com/funszdidiot/questwell-app/actions/runs/37360094077):
  guard job `111932243752` **SUCCESS**; apply job `111932390198` stopped with
  `Missing QUESTWELL_WOODLAND_MIGRATION_TOKEN repository Actions secret`.
  The failure occurs before the first HTTP call; there is no remote version or
  successful database deployment to report.
- Read-only predeployment recheck matched the entire approved manifest: 48
  unchanged historical rows, original fit definition, unchanged catalog row and
  no male rollout history record.

**Required setup:** add a suitable Supabase Management API token as
`QUESTWELL_WOODLAND_MIGRATION_TOKEN` directly in
[repository Actions secrets](https://github.com/funszdidiot/questwell-app/settings/secrets/actions).
The connected GitHub tools cannot manage repository secrets. Do not substitute a
manual SQL/MCP migration for the required CI path. After setup, explicitly rerun
the failed apply job of `37360094077` at the existing tested revision. It will
reconcile current state before any write. No new art approval or repeat database
scope approval is needed. Keep PR #22 draft until its database result is verified.

## Exact scope

| Field | Reviewed value |
| --- | --- |
| Repository | `funszdidiot/questwell-app` |
| Target project | `bdzcazkyypopbanbjnud` (the existing Questwell backend) |
| CI trigger | Push the tested revision to `deploy/male-woodland-approved` |
| Source | `supabase/migrations/20261005175137_male_woodland_approved_rollout.sql` |
| Source SHA-256 | `55f21d28dd1ad427de09ab87327d96e61e767be53bd727b7ffdc9ab5c9c249cb` |
| API migration name | `male_woodland_approved_rollout` |
| Database effects | Add male to the private Woodland fit predicate; describe all three supported bodies |
| Preserved | 120-coin price, Scout class, activation, edition/unlock, IDs, ownership, public APIs, ACLs, RLS, all other recorded schema objects |

This is a forward change against the observed live schema. It does not reconcile
or replay the incomplete historical chain. The separately gated R01 migration
remains unapplied live and is not a dependency or implicit catch-up. There are no
dependency changes, real-user fixtures, client API/type changes or credential
creation in this scope. Production promotion and `flutterflow` remain gated.

## Precondition and transaction safeguards

`tool/deploy/woodland-approved-state.json` captures a read-only 2026-10-05 state:
48 existing migration records, their full version/name/statements fingerprint,
the schema/configuration fingerprint with only this function definition omitted,
the original fit definition hash and the single complete Woodland catalog row.
The manifest contains no account data or credentials. An unrelated schema or
history change invalidates it; investigate and review the difference before
updating a manifest. Never automatically refresh the expected state to pass.

The production CLI accepts only the fixed configuration. `--check` is offline;
there is no arbitrary SQL, target, project or migration override. Live execution
requires the designated push event, repository, branch and a hosted Actions
runner. `PG*`, `SUPABASE_*` and `DATABASE_URL` overrides are refused. Required
`analyze` and backend Actions checks must be successful at the exact revision;
a newer failed or incomplete attempt cannot reuse an older success.

The generated payload is one atomic `DO` statement containing the exact reviewed
migration body. It acquires a scoped advisory lock and the Woodland row lock,
sets a five-second lock timeout, verifies state again inside the transaction,
applies the two changes, then asserts the complete expected postcondition before
commit. A failed SQL assertion rolls back the whole statement. No ownership rows
are read or written by the deployment. The Management API records the migration
with a new server-assigned timestamp and source-hash marker; existing history
is neither updated nor repaired. The source timestamp and recorded version are
different identities and must both be retained in deployment evidence.

## CI and credentials

Pull requests run deployment guard tests with no credentials. The apply job runs
only on `deploy/male-woodland-approved`, after its guard job, and independently
checks the complete source revision's successful Flutter/backend checks. The
existing backend harness remains isolated and receives no live credentials.

The apply job needs the repository Actions secret
`QUESTWELL_WOODLAND_MIGRATION_TOKEN`: a Supabase Management API token authorized
for database metadata reads and migration writes on this project (fine-grained
permissions `database_read` and `database_migrations_write`, where supported).
Use the narrowest project/resource scope available. A public anon key, service
role JWT or database password is not this token. Configure it in GitHub Actions
secrets; never place a token in source, logs or chat. GitHub's built-in job token
needs only `contents: read` and `checks: read`. No secret-management operation is
part of this change.

Both API operations are fixed to `https://api.supabase.com` and the project above.
Metadata requests explicitly set `read_only: true`; migration submission uses
`POST /v1/projects/{ref}/database/migrations` with the reviewed name/query and a
source-hash-based `Idempotency-Key`. Redirects are rejected and requests time out
after 60 seconds. No HTTP write retry is automatic. Logs contain only bounded
failure reasons or the source revision/hash and resulting remote version.

## Verification and operation sequence

1. Pass the 15 offline guard/failure-path tests and source-hash check. These cover
   wrong context, absent credentials, drift, untrusted/stale check results,
   duplicate/missing provenance, idempotency, timeout reconciliation and HTTP
   target/redirect/read-only enforcement.
2. In the existing disposable GitHub-hosted harness, rebuild the observed schema
   and seed synthetic Woodland catalog/ownership. Prove its protected schema and
   fit match the live precondition. Run the actual generated SQL with a wrong
   precondition, then with a wrong postcondition; both must preserve the original
   state. Apply the correct payload, reject a repeated SQL payload and run all
   eight Auth/purchase/equip/persistence checks **before R01**. Reset only this
   temporary local stack and preserve the existing R01 + Woodland regressions.
3. After Flutter/backend/deployment guards are green, create the deployment branch
   at that exact tested source revision. Its apply job fails before any network
   call if the named migration secret is unavailable.
4. On success, retain the workflow URL, source SHA, source hash, server-assigned
   migration version and read-only postcondition result. Verify the live fit and
   metadata independently before the checked development client merge/deploy.
   Complete delivered runtime checks before claiming account integration live.

If the request times out, keep the client blocked and read/reconcile the state.
An explicit rerun first checks history and the full expected postcondition:
exactly one matching record returns `already_applied` without a write. Missing,
conflicting or duplicated provenance stops the run. Any other unexpected state
also stops; do not retry blindly, delete history, run a down migration or disable
an approved fit beneath already equipped users. A correction requires a separate
reviewed forward change. Keep the currently delivered client while investigating.

## API references checked 2026-10-05

- [Supabase Management API: apply a migration](https://supabase.com/docs/reference/api/v1-apply-a-migration)
- [Supabase Management API: query](https://supabase.com/docs/reference/api/v1-run-a-query)
- [Supabase published API schema](https://api.supabase.com/api/v1-json)
- [GitHub check runs](https://docs.github.com/en/rest/checks/runs)
- [GitHub Actions secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
