# Autumn Hearth development preview

Latest: Tanya approved the usual-room result and authorized pricing/catalog rollout on October 9. See `AUTUMN_HEARTH_RELEASE.md` for the current delivery record. The no-activation statements below describe the historical preview scope.

## October 9 correction: usual Hearth first

Tanya identified spiders/webs from the incorrect Halloween default. Both the
scene and review app now default to the usual Hearth; Halloween is explicitly
optional. The usual-room review uses the original square aspect ratio so the
far-right window is not cropped away. Room artwork, pane masks, canonical
furniture positions, avatars and all five autumn assets are unchanged.
Regression coverage checks both defaults, square framing at four widths and
opting into/out of Halloween. CI and delivered correction verification pending.

Historical PR #99 delivery: merged/deployed `644ac8f`, workflow `37878567919`.
Hosted revision, all five art hashes, rendering and leaf pause/resume verified.
Earlier publication-only and hosted-pending notes below describe that earlier
handoff, not current authorization. No pricing/catalog/account activation.

Date: 2026-10-08 America/Chicago. Status: QA, not deployed or catalog-active.

Founder approved the Autumn Hearth concept and requested completion of cleanup,
falling leaves, scale and placement checks. This change is one isolated visual
preview; it does not activate a release, price items, grant inventory or change
gameplay. Base development revision: 7617bcb.

## Implementation

- Preview-only route: `?review=autumn-hearth` in `lib/main_preview.dart`.
- Amberfall scenery plus deterministic 18-second leaf loop. Two depth speeds,
  soft lateral drift, pixel-authored leaf stencil; wrapping outside the glass.
- Reuses the existing exact standard/Hallowed rain glass polygons. Shared path
  extraction preserves the rain painter. No room frame or avatar changes.
- Only leaves repaint. Reduced motion, hidden TickerMode and background lifecycle
  pause the controller; disposal removes its lifecycle observer.
- Typed account-free fixtures use existing floor_rug, plant, pedestal_light and
  seating geometry/shadows. No client ownership/reward decisions.
- Source art: built-in image generation from the founder-approved concept board.
  The final cushion export fixes the colored background halo and restores complete
  outer edges. Other earlier cushion candidates were rejected, not integrated.
- Canvas dimensions and visible contact rows are recorded in the fixture. Alpha
  >=128 bounds measured with Pillow: mushroom bottom 1150, lantern bottom 1183,
  cushion bottom 1036, all on 1254 px canvases. No per-item scale overrides.

## Verification

Flutter 3.44.6 / Dart 3.12.2, matching pinned repository CI. Offline locked
dependencies; no dependency edits.

`flutter test --no-pub test/amberfall_window_test.dart test/autumn_hearth_review_test.dart test/hallowed_hearth_test.dart test/hearth_generic_registry_test.dart test/hearth_layout_contract_test.dart test/hearth_integration_test.dart`

Result: **24 tests passed**. New coverage checks exact loop closure, changing
frames, glass-only clipping, reduced-motion/hidden/background pauses, disposal,
tap pass-through and actual renderer captures at 320/390/430/960 px in both rooms.
Existing rain, geometry and Hearth integration regressions remain green.

Targeted analyzer for the four new Dart/test files: **No issues found**.
Release web build with the preview entry point and `--no-pub`: **passed**,
including the SDK's Wasm dry run. This is a local compiled build, not a hosted
deployment or physical-device acceptance test. Dependency inputs unchanged.
The existing preview entry point has an unrelated unused adventurer-review import;
the existing rain widget has a pre-existing TickerMode.of deprecation.

Captures: `build/autumn-review/`. Visually checked mobile and desktop Hallowed
composites and standard mobile. No cushion halo in the final room composite.

## Known limits / remaining gates

- Standard room's existing cover crop hides most/all of its far-right window
  at 320 px and some aspect ratios. This change deliberately does not move the room
  or its authored glass. The Hallowed room is the main visible-window review.
- Mushroom/lantern/seating family assignments are development candidates, not new
  founder geometry locks. The front cushion naturally overlaps other left décor.
- Other room settings do not yet have approved window masks; not exposed here.
- No signed-in equip/purchase/persistence, device Safari, hosted deployment, market
  icons, catalog/RLS/Edge Function changes or independent reviewer pass is claimed.
  RLS/Edge tests are not newly applicable to this no-backend preview.
- Pricing, availability dates, catalog activation and production promotion remain
  separate founder decisions. Existing Halloween release terms are not inferred.

## API verification

Used installed pinned Flutter source and official API documentation:
https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
https://api.flutter.dev/flutter/rendering/CustomClipper-class.html
https://api.flutter.dev/flutter/dart-ui/Path/transform.html
https://api.flutter.dev/flutter/animation/AnimationController-class.html

## Rollback

The initial branch upload was blocked by automatic safety review. Tanya then
explicitly approved publishing these source/assets/QA files to the public
`funszdidiot/questwell-app` repository and opening a review PR on October 8.
That approval does not authorize a merge, catalog activation or deployment.
The Git CLI has no login; the configured GitHub integration handles publication.

Revert this isolated preview commit/PR. There are no migrations, ownership writes
or catalog entries to unwind. Existing production entry point remains unchanged.
