# Storage backup pilot — prepared, source access not approved

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
