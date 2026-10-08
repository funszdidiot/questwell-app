# Illustrated destination entrances — 2026-10-08

## Scope and authority

Continuation of Tanya's approved app-wide arrival redesign in PR #91. Market is
the benchmark: Quests, Boss Battles, Adventurer, Chronicle, Expedition, and Market
share Hearth navigation, illustrated scenery, live semantic title signs, and
welcome copy. The five new scenery assets remain development candidates. This
review does not create an artwork lock or authorize production promotion.

## Review corrections

- Keep Market and Chronicle arrivals visible during loading and error states.
- Keep Adventurer settings available and use the preview's inner Navigator context.
- Remove obsolete Market imports that failed the original CI analyzer check.
- Preserve upstream boss animation, placement, and completion fixes by integrating
  development revision `2be956a` before review.
- Reveal the selected/new boss encounter instead of the page entrance. Resolve
  its lazy anchor at narrow widths and enlarged text before revealing an attack.
  Preserve current-selection, busy-state, and current-step validation.
- Remove unused Inter font requests from the Expedition timer's overridden text
  styles. Preserve its Roboto family, sizing, color, weight, and tracking.
- Bundle Roboto Medium for offline rendering. Source: pinned `google_fonts` 6.3.3
  Roboto descriptor; SHA-256
  `ec3a64e46e2ee5f546845582e1d5409107780cef55bc43b052ee962f9807aee6`,
  82,628 bytes. Its embedded Apache 2.0 license is preserved separately in
  `assets/fonts/Roboto-Medium-LICENSE.txt`.
- Update scroll-dependent tests to reveal lazy controls before interaction;
  preserve viewport, hit-testing, and state assertions.

## Verification

Flutter 3.44.6 / Dart 3.12.2, with the existing exact package lock. No dependency
version, schema, reward, ownership, authentication, or locked-avatar change.

- Final complete local suite: **980 passed** after the small-screen correction.
- Targeted final battle suite: 21 passed, including the newly reproduced
  320×568, 200% text case with production navigation, existing creation/selection,
  deep attack visibility, and server-refresh animation tests.
- All-six destination heading tests cover 320/390/430/960 widths and 100/200% text.
- Independent reviewer accepted source corrections and all 12 rendered integrated
  preview captures: six destinations at 390/100% and 320/200%. Titles do not clip;
  multiword signs wrap at word boundaries. Captures are generated under
  `build/hallowed-review/entrances/` by `destination_visual_review_test.dart`.
- Analyzer/format gate passed: no new diagnostics; 45 pre-existing findings remain
  explicitly visible. Formatting exemptions were removed for corrected files.
- Release web build passed (`lib/main_monitored_preview.dart`, live-beta target).
  The compiler also completed its Wasm dry run; no Wasm deployment is claimed.

The capture test intentionally renders the real shared page integrations. Its
sample-data controls and Adventurer delete-account footer are preview-only UI;
these images are not claimed as exact signed-in production screenshots.

## Remaining verification and risks

Updated remote CI and deployed-runtime checks have not been verified. Physical
mobile devices, signed-in settings, and a rendered desktop page remain unverified;
desktop heading constraints were tested automatically. Both remote push attempts were blocked by automatic approval review. After
verifying the repository and earlier development authorization, the second review
still required explicit trusted-user approval for this exact public branch and
payload. Changes remain committed locally; PR #91 has not received these fixes.
Requested action: push this reviewed work to `codex/destination-entrances` in
`funszdidiot/questwell-app` for PR #91 CI. No merge or deployment is claimed.

## Rollback

Revert the destination-entrance PR on `questwell-dev` through a reviewed PR. It
changes presentation and local navigation only; no data migration or inventory
rollback is needed. Do not revert unrelated upstream beta fixes.
