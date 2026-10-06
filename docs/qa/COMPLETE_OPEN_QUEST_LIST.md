# Complete open quest lists (C10a)

Quest Board and Hearth previously read only 50 open tasks. Board omitted older
quests and pins; Hearth's ascending query omitted newer quests. Both now use
`QuestwellOpenTaskList`, retaining existing filters and campfire selection.

The loader requests 100 rows at a time, ordered by `created_at DESC, id DESC`,
and advances with a strict keyset cursor. It continues until an empty response,
including when the server caps pages below 100. Every page includes owner and
open-status filters. Account identity is checked before requests (including
network retries) and after responses. Invalid ownership, status, cursor data,
duplicates or ordering fail the whole load and use the existing UI retry state.
No partial list is presented as a successful complete read.

The cursor preserves the server timestamp, including microseconds. Ordering
validation also retains sub-millisecond digits on Dart web, where DateTime
precision alone is insufficient. UUIDs are validated before composing filters.

This is a traversal, not a database snapshot. Concurrent inserts above the cursor
appear on refresh; tasks deleted or closed after their page was fetched may stay
visible until refresh. Removing earlier rows does not shift and skip later rows.
The entire returned collection remains in memory, as required by current local
filters; exceptionally large accounts may need a future server-side filter UI.

## Verification

`test/open_task_list_test.dart` uses the pinned PostgREST client's actual HTTP
query construction against synthetic transport fixtures, never hosted accounts.
It covers 135 tasks, an oldest pinned task selected in campfire mode, identical
timestamps, server page caps, changes ahead of the cursor, empty/signed-out
accounts, account switches, malformed/foreign/unordered/duplicate rows, later
page failures and recovery. A specific microsecond/UUID-order case runs in both
VM and Chrome. CI runs the full Flutter suite, targeted Chrome regression and
release web compilation. Validation results are recorded in PR #34 and FIX_PLAN.

Initial draft cb9edb4b014d2402b67cb2d1647e2666d54fdce9 failed because its HTTP
fixture omitted response.request, required by pinned PostgREST. That failure is
not accepted as truncation evidence. The corrected suite retains an explicit
historical-query control: the real limit(50) query returns only 50 of 135 tasks
and omits the oldest pin, while the new loader returns all 135.

No database migrations, dependencies, rewards, art or production changes.
Boss-list pagination and authoritative totals are separate C10/C11 work.
Development delivery does not establish hosted-account or physical-device QA.
