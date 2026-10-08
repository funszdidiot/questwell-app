# Approved data policies — October 7, 2026

Founder approved these defaults at 21:31 America/Chicago. They supersede earlier
proposal-only entries. Policy approval is separate from verified deployment,
actual recovery performance, deletion authority and launch approval.

| Policy | Approved definition | Implementation / evidence |
|---|---|---|
| Recovery | At most 24 hours data loss; recovery within 8 hours | Objectives only. Timed isolated Auth/schema/data and Storage-byte restoration still required. |
| Content | Titles: 1–120 trimmed Unicode scalar values; descriptions: 4,000 scalar values; bosses: at most 50 steps | Proposed client validation and forward triggers; disposable CI required before target-specific deployment. Existing two-step minimum is retained. Task notes are the current description field. |
| Legacy content | Preserve existing records, show a fallback for blank titles, request valid titles when edited | No truncation, bulk rewrite or validation scan. Status/completion updates bypass content-edit triggers; changing notes does not silently shorten old notes. New copies of invalid legacy quests require a valid new title. |
| Account retention | Keep account content until user deletion | No timer-driven account purge. Existing separately authorized deletion flow remains. |
| Feedback | Feedback and screenshots: 90 days from submission | Offline dry-run planner identifies due reports. No deletion worker/schedule enabled. Ownership, attachment sharing, backup expiry and explicit purge authority must be resolved before enforcement/public promise. |
| Export | Owner-requested, support-assisted JSON | Offline allowlisted application-record assembler with owner checks and complete-page assertions. Verified requester, actual retrieval, confidential delivery and attachment download remain operational prerequisites. It is not a backup or a self-service endpoint. |

## Content migration safety

`20261008023552_approved_content_limits.sql` is a forward proposal, not permission
to replay the root migration chain. Apply only after independent review,
disposable backend CI, exact target/schema inventory and a separately reviewed
deployment path. No production operation is included in this change.

Titles count scalar values, so a supplementary emoji counts as one and a letter
plus a combining mark counts as two. Client and database share Unicode whitespace
trimming. Descriptions count all characters without trimming. User-entered text
is rejected with feedback, never shortened by an input formatter.

Server triggers cover both RPC and direct table writes without widening grants.
Step additions serialize by boss ID; existing oversized bosses can still complete
or edit a step but cannot add more steps. RLS/identity and reward authority remain
unchanged. Legacy records are not copied into public evidence.

Read-only staging inventory before enforcement: three quests (longest title 43,
no notes), one boss (title 28), two steps (longest title 21); no blank titles.
This is not a live-data inventory. Recheck aggregate live lengths/counts before
any approved live forward rollout.

## Support export procedure

1. Verify the requester through the authenticated account/support process. An
   email body supplying a UUID is not proof of ownership.
2. Read only that owner's application profile and all pages from the eight
   allowlisted tables in `tool/support/data_policy.mjs`. Mark a table complete
   only after successful exhaustion. Use a consistent snapshot or explicitly
   disclose concurrent changes; never turn a failed fetch into an empty array.
3. Assemble JSON with `accountExport`. Any cross-owner row, incomplete table or
   missing projected column, invalid field type, duplicate primary key or missing boss/reward relation aborts. Completion flags attest caller pagination; they do not independently verify retrieval. Auth passwords, tokens, identities, sessions,
   private operation ledgers and internal support notes are not export inputs.
4. Attachment paths are references only. If files are requested, separately
   verify each object's owner and obtain bytes through authorized Storage APIs.
   Never follow paths supplied by untrusted email as authority.
5. Keep raw data and the result private; do not put either in Git, CI artifacts,
   a public URL or chat logs. Deliver only to the verified requester through a
   confirmed confidential channel. Record delivery without storing the content
   in public tracking. No real export has been performed by this change.

## Retention operation safety

`feedbackRetentionPlan` is deliberately read-only and has no network or delete
capability. It returns report/owner IDs due at the 90-day UTC boundary; it does not
resolve or trust attachment paths. Before a separately authorized purge, reconcile
actual Storage ownership, all report references, retries/partial failures, backup
expiry and legal/account exceptions. Do not delete Storage metadata through SQL.
No overdue-report promise should be published until this operation is delivered.

## Recovery drill acceptance

- Production source/restore target and any cost must be explicitly identified
  before a real export/restore. Never restore over the live beta or existing QA
  accounts. Policy approval alone does not authorize those actions.
- First rehearse with synthetic fixtures on an isolated target. Include Auth,
  schema/RLS/functions, application rows, ownership, and actual Storage bytes;
  database backups alone do not establish file recovery.
- Start timing before export/retrieval. Record the source recovery point, restore
  end and the elapsed time, comparing them to 24h/8h objectives.
- Prove sign-in, owner separation, quest/reward consistency and feedback-file
  downloads after recovery. Compare row counts and SHA-256 for downloaded files.
- Record failures honestly. A successful build, metadata-only object comparison,
  or unexecuted runbook is not a completed recovery drill. Keep this gate open
  until the timed evidence exists. No destructive cleanup is included here.
