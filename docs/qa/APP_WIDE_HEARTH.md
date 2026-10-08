# App-wide Hearth delivery

Status: QA, development only. PR #77 tracks exact checks and delivered review.

The shared presentation contract is
`../questwell-production/APP_VISUAL_STANDARD.md`. Locked art, account behavior,
economy and eligibility remain outside this presentation change. Concurrent
approved development changes through `973f496` are preserved.

## Coverage collector isolation

At presentation revision `75fa1a7`, 945 Flutter tests, 397 Chrome tests,
analyzer/format checks, Android/iOS builds and backend checks passed. The critical
coverage process crashed after successful adapter tests, then stalled. One
unchanged retry reproduced the failure; successful test messages were not
accepted as successful coverage.

Diagnostic runs `37722624588` and `37722858550` established that the auth adapter
file exits cleanly alone, while a multi-file collection failed after either auth
or feedback tests. The exact native cause is unproven. Diagnostic `37723360579`
then ran all 12 original files in separate CLI invocations with the same pinned
Flutter 3.44.6, isolated-test environment and branch/line coverage flags. Every
invocation and the unchanged aggregate reporter passed.

The required workflow now isolates collection per file, requires each command
and nonempty report to succeed, and combines only those expected reports. The
existing parser merges repeated source coordinates without inflating totals.
The original files, coverage scope, reporter, dependency locks and ten-minute
step timeout are unchanged. No retry, exclusion or partial-report acceptance is
introduced. Final combined-revision CI remains required.

## Delivered review

Pending development integration and independent review of main destinations,
enlarged text, representative forms and overlays. Account-free fixtures do not
establish signed-in persistence, physical-device acceptance or long-term use.
