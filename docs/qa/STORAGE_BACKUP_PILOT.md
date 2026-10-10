# Storage backup pilot — verified one-time live copy

## Hosted ten-file byte recovery PASSED — 2026-10-10 04:06 UTC

Workflow https://github.com/funszdidiot/questwell-app/actions/runs/38022827804
at commit 836cdc6f415ad0f753f607f8290add53c48aae9b completed successfully.
Job 114127363139 reports 10 selected / 10 uploaded / 0 pre-existing verified,
all file checksums passed, and one newer archive file excluded.
Destination only: recovery czubumijsibtgjwekdpt / private beta-feedback.

After transfer, independent read-only SQL confirmed:
- Ten private file records, zero missing owners.
- The ordered id/bucket/path/owner digest remains
  4a2a946c035a747501f88af3ad968677, exactly equal to the pre-write baseline.
- Bucket public=false.
- The approved synthetic fixture remains separate; no permanent cleanup occurred.

The earlier zero-write stop is resolved. Missing-byte detection now combines:
exact pinned archive and metadata inventory, the full-access recovery S3 key,
and successful byte-identical reads of the known private synthetic fixture
BEFORE and AFTER checking all ten paths. Under those controls, HTTP 404 is
accepted for the restored metadata-only files. Permission/server errors and
unexpected existing bytes still fail closed. No RLS/policy was relaxed.
Nineteen recovery tests passed locally and in CI, including generic errors,
access denial, failed positive control, corruption, scope and inventory drift.

The one-time restore workflow has been closed (job condition false and approval
gate false). This does not modify the separate seven-day backup schedule.
No source changes, migrations, deletion, new paid service or traffic switch.

This completes the scoped hosted database + ten-file byte recovery checkpoint.
It is NOT full application recovery or overall GO: recovered real-owner login
and positive/cross-owner file API acceptance, Auth configuration/callbacks,
app-flow acceptance and scheduled backup observation remain outstanding.
Synthetic Auth sign-in and fixture readback passed separately; do not substitute
that result for a restored real-account acceptance test.

## Synthetic ownership proof and guarded restore attempt — 2026-10-10 04:00 UTC

Synthetic account and ownership probe:
- Account cced3e06-f196-4b32-a16f-69e661240cda confirmed; no invitation sent.
- Fixture workflow 38022327803 authenticated sign-in/upload/readback passed.
- 69-byte PNG initial SHA256 631d1f7b564a454c4c4a227a016a502b7ba47027c23bd591bfd9529991ddc41a.
- Independent SQL confirmed both owner and owner_id non-null and equal to the synthetic account.
- S3 replacement workflow 38022367840 passed readback; new SHA256
  e0c3e96797cb480f12cec2c1b5304329146a5b4b4dc330407bd39ea2d203fb1c.
- Independent SQL confirmed id a2b203ca-40e4-42a8-8ba7-9c69df831295,
  owner and owner_id unchanged after replacement.
- No direct Storage schema writes, synthetic cleanup, or policy modifications.
- Sixteen focused recovery tests passed locally and in CI.


Approved ten-file restore workflow 38022453745 at commit
16614199d6331e50dc521475b680c27ca12329e7 stopped BEFORE PRIVATE WRITES:
target absence not established. The runner checks all ten files before any
upload; only exact NoSuchKey is currently accepted as absence. No broad error
fallback was used. Independent SQL after the stop confirms ten private records,
zero missing owners, and unchanged id/bucket/path/owner digest
4a2a946c035a747501f88af3ad968677.

Read-only diagnostic 38022556599 classified the selected request as HTTP 404
with a provider-specific error code outside the initial diagnostic allowlist.
A bounded error-enum diagnostic is in progress; private names/messages remain
withheld. Do not classify generic errors as absence or mark restoration complete.

The recovery target now intentionally includes one synthetic Auth user and one
synthetic 69-byte Storage fixture in addition to the restored data. This does not
alter the ten-private-file scope or authorize deleting fixtures. Full application
recovery, recovered real-owner sign-in/API checks and final GO remain open.

## Recovery preflight verified — 2026-10-10 03:50 UTC

Tanya approved the dedicated recovery Storage key and scoped ten-file restore
at 03:25 UTC. Both recovery secrets were verified present in questwell-backups
after her 03:48 UTC confirmation. Earlier copies also appeared in ios-testflight;
no secret values were read or copied and no secrets were deleted.

Read-only workflow run 38021945266, commit
4ebfe3df5b6dfc58c1af4058fc9770c6e583337f:
- Six synthetic preflight tests passed locally and in CI: exact subset,
  corrupt archive, unverified marker, extra target entry, changed metadata,
  and wrong target path. Fake clients expose no upload/delete methods.
- Job 114124688284 PASSED at 03:50:43 UTC.
- Pinned B2 archive SHA/size, manifest and every member checksum passed.
- All ten recovery metadata paths match archive size and ETag.
- The one newer archive file was excluded.
- Safe result explicitly reports file_restore_executed=false and
  ownership_upload_behavior_verified=false.

Only B2 read credentials and recovery Storage credentials were supplied to
the read-only step. No source Storage credential, database credential or Auth
service-role key was supplied. No artifact containing private files was exported.
Workflow only runs on an edit to its own file on the dedicated operations branch;
it does not schedule or execute restoration.

Remaining file-restore blocker: no authenticated synthetic owner fixture exists
in the recovery project. A privileged S3-created object with null owner would
not prove preservation of existing non-null ownership. Do not test a real
private file first or directly modify storage schema metadata to fabricate proof.
Proposed next scope: one recovery-only synthetic Auth account and one tiny
owned fixture under its own folder, followed by S3 replacement and independent
owner/hash checks. Use ordinary authenticated Storage access and no broader
Auth administrator credential; account/credential creation needs the applicable
user approval and handoff. No outbound invitation/email or cleanup deletion.
The ten-file restoration itself is already approved; do not request it again.
Hosted recovery and full GO remain incomplete.

## Recovery isolation and file-transfer decision — 2026-10-10 03:24 UTC

Read-only SQL role simulation PASSED in the recovery target. For each of all
five restored Auth users, transaction-local JWT claims and authenticated role
could not see other owners' rows in users, tasks, boss_battles, user_cosmetics,
or beta_feedback. Storage SELECT returned zero without a session claim.
All session settings rolled back. No credentials, account data, or session
tokens were returned. This is SQL/RLS simulation, not actual Auth sign-in,
owner-positive API access or complete grant/security audit.

All ten restored file records have a single non-null owner; folder prefix
matches owner_id in every case. Actual source bytes are not yet recovered.

Prepared transfer scope for founder decision:
- Read only the verified B2 snapshot 20261010T024417Z-9129f3e518c846bbb307b3588b94c56b.
- Destination only czubumijsibtgjwekdpt / private beta-feedback.
- Reconcile exactly ten pre-backup metadata paths against the archive, with
  size and checksum checks; exclude the one post-backup file.
- Before private-file writes, validate privileged upsert ownership behavior on
  a separate synthetic probe in this recovery project. Current upstream
  supabase/storage src/storage/database/pg.ts writeCurrentVersion omits
  undefined owner fields from update clauses; this is not proof of the deployed
  version. Stop on owner/version ambiguity; do not SQL-edit Storage metadata.
- Recheck target metadata, require missing file bytes, preserve owner IDs and
  paths, upload via supported Storage API, read back and hash every restored
  file, then independently verify ownership/policies.
- New dedicated recovery-project S3 key pair would grant full Storage access
  to that target (not read-only). Proposed GitHub environment secret names:
  SUPABASE_RECOVERY_STORAGE_ACCESS_KEY_ID and
  SUPABASE_RECOVERY_STORAGE_SECRET_ACCESS_KEY in questwell-backups.
  No source key expansion or database/Auth service-role key is proposed.
- Runner implementation/validation and exact reviewed execution approval must
  precede any real-file upload. No runnable restore job or target key has been
  created at this checkpoint. B2 copy destination is a new private-data scope
  relative to the earlier backup approval.
- No permanent cleanup/deletion, source writes, migration replay, public access,
  or production traffic switch. Auth sign-in and owner/cross-user API acceptance
  remain separate work after byte restoration.

## Hosted database recovery checkpoint — 2026-10-10 03:20 UTC

Tanya approved the displayed additional $9.68/month recovery project and the
copy of database/account data into the same Momentum Labs organization and
us-east-2 region. She completed the required new database-password step and
reported creation. Target: Questwell Recovery 20261010
(`czubumijsibtgjwekdpt`), created 03:12:51 UTC. Provider status progressed
COMING_UP -> RESTORING -> ACTIVE_HEALTHY. Source remains
`bdzcazkyypopbanbjnud`; existing synthetic-only staging is untouched.

Selected provider physical backup: 2026-10-09 07:57:57 UTC.
Read-only post-restore checks:
- 5 Auth users and 5 identities; sorted account-ID digest matches live.
  This does not verify password sign-in or session behavior.
- All 13 public application tables present, all with RLS enabled.
- 24 public/Storage policies; policy-definition digest matches live.
- Public function-definition digest matches live.
- One private bucket; 10 restored Storage metadata records, zero orphaned owners.
- All 10 pre-backup file metadata entries match live by ordered
  id/bucket/path/owner digest. Live has one additional post-backup file.
- Target has 56 migrations; live has 59. The three additional live versions
  (20261009161902 autumn_hearth_2026, 20261009190534 household_familiars_2026,
  20261010023800 avatar_magic_2026) postdate the selected backup.
  Do not replay them automatically or test a newer client as though this target
  represented the latest live state.
- Neither target nor source has pg_cron, pg_net, wrappers or http extensions
  installed at inspection. This is a narrow inventory, not comprehensive
  outbound-network isolation verification.

This establishes hosted database restoration and selected catalog/ownership
checks only. File bytes have NOT been restored into the target; metadata is
not byte recovery. Auth configuration, fresh sign-ins, authenticated owner and
cross-owner file access, app flows, full data integrity and RTO remain open.
No account credentials, private content, or password hashes were returned.
No target credential was created by the agent. No source changes, migration
replay, file transfer, deletion, deployment or production traffic switch occurred.

Next file-recovery preparation must reconcile the newer B2 snapshot (11 files)
with this older database backup (10 metadata records), preflight the exact
existing target, verify missing bytes, preserve ownership, and obtain scoped
authorization for private-file transfer/new credentials if required. Never
silently invent the missing post-backup application records or mutate source.
The new project's recurring cost remains active until explicitly managed.

### Superseding schedule status

PR124 is merged as bd24484fd304f89940c0a639c215b3fd44d4c8ae.
The seven-day Oct10-16 pilot is enabled at 07:23 UTC; first scheduled transfer
has not yet occurred as of this checkpoint. Four existing secrets remain in
questwell-backups; branch access now includes flutterflow and the original
pilot branch. Manual approval variable remains false; scheduled approval true.
See docs/qa/STORAGE_SEVEN_DAY_PILOT.md on flutterflow. Earlier statements below
that no schedule is configured are historical. No retention deletion enabled.

## Verified pilot result

Tanya explicitly approved the dedicated Storage source credential, its GitHub
secret storage, and one copy of the private feedback files into the existing
B2 bucket. She confirmed both source secrets saved. Environment deployment
access is restricted to branch `questwell-b2-connection-check-20261010`.

GitHub run 38016744265, attempt 2, job 114112568614 passed at
2026-10-10 02:44:17 UTC (October 9, 10:44 PM EDT), executing commit
`ecf013f0b503ba691f28bb5452312051eb8ea0ca`.
All 15 synthetic tests passed, and the actual live transfer step passed.

- Files: 11
- Source bytes: 11,188,632
- Archive bytes: 9,881,367
- Source before/after listing stable: true
- Full archive readback and per-file hashes: passed
- Snapshot: `20261010T024417Z-9129f3e518c846bbb307b3588b94c56b`
- Archive SHA-256: `5eaf712e79f55b4c44c2ad6268d2a00bc7ca9fdd0504d6417e962519815a2f3b`
- Destination: private B2 bucket `questwell-backups-20261009`,
  prefix `questwell/file-backups/live/`; SSE-B2 AES256 requested and checked.
- No source deletion, scheduled backup, or full application recovery performed.

Cleanup completed: after GitHub Mobile verification, the environment variable
`QUESTWELL_LIVE_BACKUP_APPROVED=false` was visibly verified on October 9,
2026 at 10:49 PM EDT. Further live transfers are disabled. No schedule is
configured; no additional live backup is authorized.

Evidence: https://github.com/funszdidiot/questwell-app/actions/runs/38016744265

## Verified destination and source inventory

B2 synthetic round trip passed in run 38015718496 retry job 114107451875 on
2026-10-10 02:17 UTC. Source aggregate inventory later showed one private bucket,
`beta-feedback`, with 11 objects totaling 11,188,632 bytes. Project Momentum
(`bdzcazkyypopbanbjnud`) is the established live-beta project, region us-east-2.
Counts are a point-in-time observation, not a freeze.

## Prepared behavior

The pilot lists the source bucket completely with pagination, downloads each
object with If-Match, verifies size/ETag, checks the listing again, and packs
bytes plus source paths and S3 metadata into a private archive. Archive entry
names are hashes; source paths appear only inside the encrypted archive.
It uploads to `questwell/file-backups/live/` in the existing B2 bucket, downloads
the entire archive, compares bytes, verifies each member hash, then writes a
verified completion marker. Source access uses list/get only. No source writes,
source deletions, database queries, Auth exports or automatic restores exist.

Limits: 1,000 source objects; 16 MiB per object; 128 MiB total source bytes;
512 MiB total visible B2 data under `questwell/`, including the proposed archive
and a marker allowance. These bound this pilot's transfer, not the provider's
bill or other clients' concurrent writes. Previously hidden B2 versions are not
counted by S3 ListObjectsV2; pilot object names are unique and it never hides or
overwrites objects. No retention deletion or schedule is configured.

Before/after matching catches observed mutations but is not a transactional
point-in-time snapshot. Supabase S3 does not support object versioning. This
pilot protects file bytes only; database, Auth and Storage ownership/RLS metadata
must be included in the separate full recovery design. No full application
recovery or RPO/RTO guarantee follows from this pilot.

## Exact source-access decision

Supabase's dedicated S3 key pair grants full Storage access to all buckets and
bypasses RLS. Although this code only reads, the credential is not read-only.
Do not substitute a service-role database/Auth key. A new dedicated S3 key and
its GitHub storage require Tanya's explicit approval. Keep secret values out of
chat, repository content, artifacts and logs.

If approved, create a dedicated `questwell-file-backup` S3 credential in the
live-beta project and enter these environment secrets in `questwell-backups`:

- `SUPABASE_STORAGE_ACCESS_KEY_ID`: Supabase S3 Access Key ID
- `SUPABASE_STORAGE_SECRET_ACCESS_KEY`: its matching S3 Secret Access Key

Endpoint and region are fixed in code to the verified source project. Existing
B2 secrets remain unchanged. Before live execution, restrict the environment's
deployment branches to the reviewed backup branch and inspect its exact head.
Only after explicit approval to copy the private feedback files into the named
B2 bucket, set environment variable `QUESTWELL_LIVE_BACKUP_APPROVED=true`, rerun
this workflow, and verify the actual transfer output. Code/test success with
the transfer step skipped is not backup success.

The branch push trigger validates prepared code now. There is no cron. Once the
manual pilot passes, approve retention and cost controls, complete review/merge,
then separately enable and observe scheduled execution. Do not retain the
temporary branch trigger as an unrestricted production scheduler.

References verified before implementation:
- https://supabase.com/docs/guides/storage/s3/authentication
- https://supabase.com/docs/guides/storage/s3/compatibility
- https://supabase.com/changelog.md

## Next rollout decision — bounded daily pilot (prepared, not enabled)

Recommended first recurring stage: one backup daily at 07:23 UTC (03:23 EDT /
02:23 EST), for seven scheduled dates only. Set the exact first and last UTC
dates when enabled; reject executions outside that window, including manual
reruns. Do not interpret this proposal as approval to copy again.

Scope remains the live-beta project's private beta-feedback files into
questwell-backups-20261009. Preserve per-file and complete archive readback,
before/after source inventory comparison, unique snapshot names, and existing
1,000-object / 16 MiB per-file / 128 MiB source / 512 MiB visible-destination
limits. Any guard failure must fail the job rather than claim a backup.

Seven archives at the measured pilot size equal 69,169,569 bytes; with the
retained pilot archive, 79,050,936 bytes (about 75.4 MiB), plus markers and the
small synthetic connection check. This is an unchanged-data estimate, not a
price quotation or bill limit. Source growth, hidden versions, requests and
other clients must be considered separately. Do not purchase or upgrade a plan.
No retention deletion during this first recurring stage.

### Concrete GitHub deployment boundary

Repository metadata verified October 10 UTC: default branch is flutterflow.
GitHub schedule events execute from the default branch; adding cron only to
the development or pilot branch cannot enable scheduled operation.

Prepare a separate operations-only PR based on the current flutterflow head.
Include only the reviewed backup scripts, hash lock, tests, documentation and
the scheduled workflow. Do not merge the entire development branch or the
existing PR #122 into flutterflow. Inspect all push/deployment workflows before
creating or merging that PR so a backup commit cannot silently promote the app.
If branch policies or deployment triggers prevent that separation, stop and
present the concrete alternative before changing them.

The scheduled workflow must:
- remove the branch-push transfer trigger;
- use an explicit schedule plus manual validation, with live copying allowed
  only for schedule events during the seven-date approval window;
- pin all actions and dependencies and use contents:read;
- serialize jobs, use a 15-minute timeout and keep tests free of credentials;
- require a separate scheduled-copy enable variable (the completed manual-pilot
  enable variable remains false);
- restrict environment access to the reviewed workflow's branch; any widened
  credential access must be reviewed as part of the activation decision;
- fail visibly on missing secrets, unsupported source inventory, cap exhaustion
  or failed readback;
- include file count, size, hash and snapshot ID in the summary, never private
  file paths, content or secrets;
- make failure notifications and missed-run detection concrete before activation.
  GitHub schedules can be delayed; merely waiting for failure email does not
  detect a schedule that never starts. Do not claim an RPO guarantee.

Observe a real scheduled execution before marking scheduling verified.
The seven-date cutoff must prevent ongoing copies without a subsequent decision.

### Retention proposal for the later steady-state phase

Thirty days of daily snapshots is a proposed policy, not an enabled rule.
Do not configure B2 age-based deletion now: an age-only rule can remove the
last good backup after a prolonged outage. The later retention implementation
must dry-run the exact candidates, preserve at least the newest two verified
snapshots regardless of age, refuse pruning if the newest verified snapshot is
older than 48 hours, and pair each archive with its verification marker.
Permanent deletion needs Tanya's explicit approval under
docs/questwell-production/AGENT_OPERATING_RULES.md. Bucket-wide or empty-prefix
rules are prohibited for this proposal. Retention must address hidden versions
and legal/privacy deletion requirements before being called complete.

### Full recovery proof remains separate

1. Inventory the current database backup coverage and access, Auth recovery
   coverage, migrations, roles/grants, RLS, Storage bucket/ownership metadata,
   functions/configuration and deployed app revision without exporting secrets.
2. Prepare an isolated recovery target and document exactly which private data
   would be copied there. Existing staging is synthetic-only; never restore
   live feedback or Auth data into it by inference.
3. Obtain any necessary destination/private-data and credential authorization.
4. Restore database/Auth and file bytes with ownership metadata; keep application
   traffic and outbound email disabled in the recovery target.
5. Verify counts/checksums, owner-only access and cross-user denial, sign-in,
   quests/rewards, inventory/equipment and feedback attachment access using
   approved test identities; measure elapsed recovery time.
6. Record actual tested coverage, gaps and recovery-point age. A tar archive
   round trip alone does not establish full recovery.

Official references checked October 10, 2026 UTC:
- https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows
- https://www.backblaze.com/docs/cloud-storage-lifecycle-rules
