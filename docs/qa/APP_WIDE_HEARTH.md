# App-wide Hearth delivery

Status: development deployed; main-screen independent review completed.
PR #77 records the shared rollout; PR #82 records the delivered polish corrections.

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

PR #77 merged as `b01aa00a5dfe673d12e1b984b730f47c6fedb728`, tree
`19cb008d5a5496e0a8d49d11534c271193688065`. Preview `37724181383` and backend
`37724180968` passed. The exact pre-merge tree passed 946 Flutter and 397 Chrome
tests, coverage, analyzer/format checks, web packaging and Android/iOS builds.
Deployment repeated the required quality gate and published successfully.

The delivered 390px/100% Hearth visibly retains the accepted room, framed progress,
parchment quest and emerald action. Independent delivered observations:

| Surface | Observed result |
| --- | --- |
| Quests / New quest | Materials, forms and navigation coherent at 390px/100% and 320px/200%; lower actions reachable by scrolling |
| Market | Cards, avatar try-on and detail action readable at 390px/100%; detail title retained an inconsistent sans-serif override; Business Suit split inside a word beside its icon at 320px/200% |
| Adventurer | Title, avatar and reflowing controls intact at 390px/100% and 320px/200% |
| Chronicle | Cohesive readable history at 390px/100%; heading orphaned its final letter at 320px/200% |
| Expedition | Attractive coherent scene; start, countdown, pause, leave confirmation and return verified; Begin/Resume Expedition orphaned a final letter at 320px/200% |
| Explore | Destinations readable and reachable at normal and enlarged text |
| Boss Battles | Materials and controls readable at both sizes; preview attack advanced 0/3 to 1/3 and health 100% to 67% |
| Deletion dialog | Warning, typed confirmation, disabled action and cancellation verified; long destructive action label split at 320px/200% |
| Sign-in | Actual unauthenticated desktop landing has coherent room, parchment/brass panel and emerald action; no credentials or submission |

The follow-up uses shared serif Market titles/sheet surface and stacks card
artwork above item names when scaled text needs the width. It shortens Expedition
actions to Begin/Resume, lets the whole Chronicle heading wrap below Back, and
labels the destructive action Delete forever. Permanent-loss wording, typed
DELETE confirmation, warning color and disabled behavior remain intact.
Bundled-font geometry regressions cover all four wrapping defects while
preserving text scaling. No purchase, equipment, deletion, timer or navigation
behavior changes are involved.

## Final delivered polish review

PR #82 merged as `0a49ecf66f5699dda26029ec5dda4eb256333551`, tree
`30cc91e7203e16a48f67973e10d72945b036aef8`. Preview `37729581654` and backend
`37729581211` succeeded. The final pre-merge tree passed 950 Flutter and 398 Chrome
tests, coverage, analyzer/format, web/staging packaging and Android/iOS builds.

Independent delivered recheck passed Market whole-word titles at 320px/200%,
shared serif detail headings at 390px, Chronicle's intact heading, Expedition
Begin/Resume with timer start/pause/reset, and the deletion warning label and
cancellation. Successful quest creation and Edit were also verified at enlarged
text. A preview-only Easy-to-Annoying mapping mismatch was corrected and tested;
creation, reopening and saving now retain Easy and +10 XP/+5 coins.

That final inspection found one further narrow-layout defect: the Quest Board
completion icon squeezed the word Complete into two lines. The scoped follow-up
lets the icon wrap above its label, preserving the full text scale, button style,
busy state and callback. A real-font 320px/200% geometry check also taps the
button and confirms the corresponding quest disappears. The follow-up delivery
PR records its final CI and live recheck.

Browser control initially stalled; sequential review with full screenshots
recovered. Real account settings were inaccessible without signing in and remain
outside the delivered visual evidence. Their shared presentation and behavior
have source/widget coverage; that is not a substitute for signed-in inspection.
Account-free fixtures do not establish hosted-account persistence, physical-device
acceptance or long-term engagement.
