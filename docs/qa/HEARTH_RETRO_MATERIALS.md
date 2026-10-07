# Hearth retro materials — October 7, 2026

## Scope and authorization

Tanya requested polished avatars within an intentional 90s 64-bit-era world and
approved implementation with “Let’s work on it.” First phase is a presentation-only
Hearth material pass, based on `6e0a8a54b16214180cc992b9abcfe13d8362dc0f`.

Plan: reuse shared account/review widgets; give panels a restrained timber rail
and brass corners; coordinate primary/secondary actions and Campfire colors;
verify layout, interaction and disabled behavior; obtain independent review and
required CI before development delivery.

Files: `lib/widgets/questwell_hearth_material.dart`, `questwell_home_overview.dart`,
`questwell_home_sections.dart`, `test/hearth_material_test.dart`, production visual
bible/dashboard, this QA note and its mirrored web dashboard.

No asset, avatar, room-coordinate, schema, authentication, navigation contract,
economy or dependency changes. No new backend writes: existing caller callbacks
remain responsible for state. RLS/Edge Function changes are not applicable.
The concept image is not used as a runtime asset and does not replace a lock.

## API verification

Existing CI pins Flutter **3.44.6** and the unchanged `pubspec.lock`.
Verified CustomPaint/painter ordering, Switch colors/disabled callback behavior,
and FilledButton.styleFrom against official API documentation and the local
3.44.6 Flutter source. No package was added.

- https://api.flutter.dev/flutter/widgets/CustomPaint-class.html
- https://api.flutter.dev/flutter/material/Switch-class.html
- https://api.flutter.dev/flutter/material/FilledButton/styleFrom.html

## Verification status

- Local Dart 3.12.2 formatter with package language version 3.0: passed.
- `git diff --check`: passed.
- Added 320/390px, 1x/2x text interaction tests and pending-account-change disabled
  switch regression; required CI execution pending.
- Existing home layout, wordmark and overview regression coverage retained.
- Local Flutter startup was blocked by automatic approval review after an
  unexpected cloud metadata request. No workaround or approval bypass attempted;
  compile/test verification uses the existing GitHub Actions workflow.
- Independent code review, CI compilation/tests and delivered screenshot review:
  pending. Do not report deployment or final visual approval from source alone.

## Rollback and remaining work

Revert this scoped client change through a reviewed PR. No database rollback.
The broader world-art treatment, Market/Adventurer unification and activity/reward
experience remain separate passes. No physical-device or signed-in acceptance
has been established by the account-free review.
