# C10b — Complete boss battles and steps

The former service made one request per collection. Server row caps could hide
later battles independently of steps, or leave visible battles with incomplete
step lists. The retained historical-query control uses 135 battles and 2,700
steps with caps of 100 and 1,000 to demonstrate the missing tail.

`QuestwellBossList` now reads each owner-filtered collection with immutable UUID
keysets, an explicit limit and an empty terminal page. Short pages do not imply
completion. It rejects wrong-owner rows, invalid IDs and nonprogressing pages;
owner checks run before requests/retries and after responses. No partial result
is returned after either collection fails. The service acknowledges pending
creation recovery only after the whole load succeeds.

Presentation remains chronological by creation timestamp, with UUID ties;
server microseconds survive Dart web precision. Steps remain ordered by position
with UUID ties. Existing models, UI, rewards, economy and completion RPCs are
unchanged. No SQL or live account writes are part of this change.

Tests exercise the historical single-page query, all 135 battles and 2,700 steps
under independently capped pages, equal timestamps, web microseconds, deletion
behind the cursor, signed-out/empty accounts, account changes in either
collection, invalid/duplicate/nonprogressing rows and later-page failure/retry.
CI runs the complete Flutter suite and both quest/boss list suites in Chrome.

Paging is not a transactional snapshot. New rows behind an already-read UUID
cursor appear on refresh; concurrent changes across the two collections can
require refresh. This client-only fix does not claim snapshot consistency or
solve C11 authoritative totals. Memory remains proportional to account size.

Validation status: source formatted with Flutter 3.44.6's Dart formatter;
`git diff --check` passes and dependency inputs are unchanged. Local test execution
is blocked by missing cached dependencies and unavailable package resolution;
cloud CI and exact-head AI review remain required before development merge.
Signed-in hosted/mobile acceptance remains unverified.

Official API references checked October 6, 2026:
- https://supabase.com/docs/reference/dart/using-filters-gt
- https://supabase.com/docs/reference/dart/using-modifiers-limit
- https://supabase.com/changelog.md

Rollback: revert this client change if it regresses, while keeping the known
single-page completeness limitation explicit. No database rollback is needed.
Development delivery requires successful post-merge checks and served revision
verification. Production promotion and launch remain excluded.
