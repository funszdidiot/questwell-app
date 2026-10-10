# Seven-day Storage backup pilot

Tanya approved seven daily verified copies, automatic cutoff, no deletion and
the existing limits on October 9, 2026 (America/New_York). This operations-only
change contains no app, database, Auth, economy or artwork changes.

## Execution contract

- Source: live-beta Project Momentum bdzcazkyypopbanbjnud, private beta-feedback.
- Destination: private B2 questwell-backups-20261009, questwell/file-backups/live/.
- Dates: October 10 through October 16, 2026 inclusive, at 07:23 UTC / 03:23 EDT.
- Only original schedule events on funszdidiot/questwell-app flutterflow copy.
  Manual dispatch, PR, push and rerun events only validate or fail closed.
- Both a pre-secret job check and the transfer entry point enforce the exact
  dates, branch, repository and attempt. An enable variable is also required.
- Stable daily archive names plus serialized jobs prevent this workflow from
  copying twice for one UTC date; existing partial archives fail for review.
  This is not a distributed lock against unrelated clients with bucket access.
- No catch-up, deletion, restore or source mutation. No recurring copies after
  October 16; the annually matching cron becomes a validation-only no-op.
- Same 1,000-file, 16 MiB/file, 128 MiB/source and 512 MiB/visible-prefix limits.
  Hidden B2 versions are not counted; this is not a billing limit.
- Full archive download, byte comparison and all member hashes precede the
  verified marker. Private file names remain inside the SSE-B2 archive.

## Activation and evidence

GitHub's default branch was verified as flutterflow. Its existing preview
workflow deploys on questwell-dev pushes or explicit manual dispatch, not a
flutterflow push. Existing Flutter Check runs on PRs and cannot deploy.
Only this operations diff is proposed for flutterflow; do not merge the
development branch or PR #122 to achieve scheduling.

Environment questwell-backups must permit flutterflow and retain its existing
four encrypted secrets. Set QUESTWELL_SCHEDULED_BACKUP_APPROVED=true only for
this approved pilot. QUESTWELL_LIVE_BACKUP_APPROVED remains false.
Future workflows on an allowed branch can reference environment secrets;
environment branch restriction is not a per-workflow permission boundary.

Synthetic checks are not a scheduled-copy success. Record actual daily run IDs,
snapshot identifiers and verification output after execution. A separate
read-only daily check in ChatGPT must flag failed, missing or unverified runs;
GitHub may delay scheduled events, so no guaranteed RPO is claimed.

The earlier one-time copy was verified at 2026-10-10 02:44:17 UTC: 11 files,
11,188,632 source bytes, 9,881,367 archive bytes, workflow 38016744265 attempt 2.
Seven equal-size new archives plus that archive total about 75.4 MiB before
markers. No paid upgrade or storage price guarantee is included.

## Recovery and retention

All copies remain retained. Proposed 30-day pruning needs separate review and
explicit permanent-deletion approval; preserve the newest good copies even if
scheduling fails. Never restore live private files or Auth data into the
existing synthetic-only staging project. Full recovery requires an approved
isolated destination, database/Auth/ownership/RLS coverage and app acceptance.
This pilot proves Storage copying only.
