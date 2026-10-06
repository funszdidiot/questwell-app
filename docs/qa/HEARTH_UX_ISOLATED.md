# Hearth action hierarchy — isolated UX candidate

Status: QA; not merged, deployed, visually accepted or part of the current rollout.

## Authorization and release boundary

On October 5, 2026 (America/Chicago), Tanya approved the visual/UX pass with
“do not disturb the current roll out.” Keep this candidate on
`ux/hearth-action-hierarchy`; retain a draft PR, no auto-merge, no deployment,
no workflow dispatch and no changes to rollout branches, workflows, dependencies,
authentication, database, rewards, asset bytes or equipment contracts.

## Scope and files

- `lib/pages/home_page/home_page_widget.dart`: present the first selected quest
  ahead of character statistics; preserve the existing selection policy and all
  other quests after the overview. Show the title before effort metadata and
  identify a featured pinned quest. Use a growing completion control with the
  existing callback and pending guard.
- `lib/widgets/questwell_home_sections.dart`: reusable presentation layout;
  emphasize Add quest only for the confirmed empty state in the account page.
  Retain navigation while loading or on error without implying an empty board.
- `test/hearth_quest_details_test.dart`, `test/home_sections_test.dart`: retain
  notes/reward/navigation checks; exercise order, 320px layouts, 2x text, both
  completion variants and disabled pending actions.
- This handoff records isolation and remaining acceptance.

There is no new Begin/Continue state: current quest contracts do not establish
one. Completion still delegates to the existing server-backed flow. No reward,
query-selection or Campfire policy change is included. A long list must not push
customization below all quests. The same one task request per build feeds the
section; there is no second query to determine action styling.

## Verification

Validated with the independent account-settings candidate in a local review
worktree. Flutter 3.44.6, engine 83675ed276, Dart 3.12.2; locked dependency restore
succeeded and both dependency input files are unchanged. BOT/CI mode skips
Flutter's cloud environment detector, and analytics are disabled. No endpoint
access exception was used.

Actual results:

```text
Focused Flutter suite: 00:04 +18: All tests passed!
Complete Flutter suite: 01:07 +486: All tests passed!
Node checks: tests 19 / pass 19 / fail 0
Analyzer: 46 issues found (existing baseline; no added findings)
Locked asset verifier: passed
Git whitespace and protected-file diffs: passed
```

The 2x text regression initially caught overflow in reward chips. Their labels
now wrap inside the available width; the same regression passes. An unused
import introduced by replacing the fixed-height button was removed, restoring
the analyzer to its inherited baseline. Existing quest completion implementation
and the server selection/reward contracts are unchanged.

Current official Flutter API references verified the existing SDK's
FilledButton / OutlinedButton constructors and styleFrom:
https://api.flutter.dev/flutter/material/FilledButton-class.html
https://api.flutter.dev/flutter/material/OutlinedButton-class.html

Local release web build passed (`isolated_test`, `lib/main_preview.dart`):
`Compiling ... 49.9s` and `✓ Built build/web`. It was not uploaded or served. Hosted backend regression
CI and AI review have not run for this unpublished candidate. Screenshot review,
signed-in runtime, screen reader/keyboard behavior and physical iOS/Android
acceptance remain unverified. Passing widget tests are not founder visual approval.

Automatic approval review rejected GitHub publication because source-export
authorization was not explicit enough. No alternate transport was used. Neither
UX branch exists on the remote; no PR, merge or deployment occurred. Ask only
for permission to publish the two exact branches as draft PRs, retaining the
rollout hold. The combined local review worktree is not a deployment branch.

## Rollback and integration

While isolated, close the draft to omit this candidate; no live rollback is
needed. After the current rollout completes, rebase onto the actual development
head, rerun required checks and AI review, then integrate as its own concern.
A later merge remains subject to Tanya's rollout-protection instruction.
Do not activate auto-merge or infer the rollout has ended from passing checks.

Next separate concerns: account-control placement (explicit founder feedback),
dressing-room experience and Quest Board readability. Do not fold their code
into this PR.
