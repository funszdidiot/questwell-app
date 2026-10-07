# C12a — Completion response validation

## Problem and contract

The task and boss-step service adapters previously defaulted missing/null numeric
fields to zero, truncated fractions, and accepted the first of multiple rows.
Task identifiers were string-coerced and non-boolean boss flags became false.
These are reproducible parser defects, not evidence of malformed live replies.

Both existing RPCs return one row with PostgreSQL `integer` reward/totals fields.
The client now requires one JSON object row, finite whole nonnegative numbers
within that existing SQL type's range, and all required fields. Task completion
requires a nonblank string ID matching the requested task; boss completion
requires a boolean. Valid zero rewards, false boss flags, whole-number JSON
values and additive unknown fields remain supported. The bound is the existing
SQL transport type, not a new gameplay cap or change to reward calculations.

Validation stays in the service layer with a small shared parser, included in
the Rewards coverage group. Caller APIs, RPC parameters, server authority,
account guards and single-attempt writes remain unchanged. A rejected response
is unconfirmed: the error instructs refresh before retry and does not claim
server rollback. No live database, auth, catalog, package or visual change.

## Regression evidence

- Base: `ae0fb7dd8d560c0b0350667fb1aa497e840ba5af`.
- Before implementation: 74 new regression failures, 64 passing adapter tests.
- After implementation: 801 full Flutter tests passed, including 89 added cases
  (141 tests in the service-adapter file after three non-finite factory cases).
- Cases exercise the actual pinned SDK/services with synthetic Auth and mocked
  HTTP: missing/null/wrong types, fractional/negative/out-of-range numbers,
  malformed/multiple rows, identity/boolean errors, supported boundaries,
  additive fields and replies arriving after logout/account switch.
- Every rejected HTTP reply is checked for one request only. Existing network,
  authorization, zero-award and valid-result tests remain in place.
- Quality gate passed: 45 inherited diagnostics, 276 tracked Dart files,
  214 unchanged legacy formatting allowances; no new debt or baseline edits.
- Dependency inputs and `git diff --check` are unchanged/clean.
- Local Chrome could not launch because the configured executable is unavailable;
  web execution must pass the existing required CI Chrome suite before merge.

## Delivery limits and rollback

PR review, final CI, postmerge preview and served-revision evidence belong in
the current FIX_PLAN. Local tests alone are not development delivery or hosted
tester/device acceptance. C12 content limits and legacy blank-title data are
separate work; this patch does not invent limits or rewrite those rows.

If necessary, revert only this client validation change in a reviewed development
PR. Preserve server reward authority, receipt handling and release holds. Such a
revert reopens this response-validation defect; it does not restore a database.
