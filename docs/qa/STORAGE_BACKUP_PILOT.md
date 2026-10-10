# Storage backup pilot — verified one-time live copy

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
