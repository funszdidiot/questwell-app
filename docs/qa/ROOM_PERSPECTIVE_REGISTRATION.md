# Room perspective registration — October 9, 2026

Status: QA. Tanya authorized fixing room-space placement/aspect ratios, window
alignment and separately the male Pumpkin Court surface. This change concerns
room rendering only, with no database, ownership, slot or catalog changes.

Cause: rear furniture anchors multiplied viewport dimensions, while the room
plate used a cover crop. A wide Hallowed source was also grouped with square
Midnight Harvest. Rear contacts therefore drifted from the wall in portrait
previews. Furniture now uses source-space contacts through the same cover
transform as windows/backgrounds. Cropped side contacts clamp horizontally to
the visible wall zone. Rear families use a room-relative envelope with a common 82% depth factor;
foreground seating/table retain their scale and use
the visible floor. Artwork aspect ratios and visible contact rows remain intact.

The Hallowed glass tracing now includes the continuous central pane, curved
arches and tracery lights; it removes the invented middle divider and protects
the actual wood. Both rain and autumn reuse the corrected glass mask.

Tests include independently measured glass/frame sample points, source-space
wall contact across three ratios, family consistency, and 135 actual scene
renders (nine rooms, five arrangements, three viewport sizes). Existing
animation/confinement and saved-loadout tests remain required. No Flutter local
result is claimed: automatic approval review rejected Flutter startup after an
instance-metadata request; use existing GitHub CI. Standalone Dart formatting
is available and does not start Flutter.

Rollback: revert this room-only commit. No migrations or saved data conversion.
Visual and delivered-device results will be recorded after CI, not inferred.


## Rendered review correction

CI 38014997335 passed tests and native builds, but its portrait fixtures revealed
that the Hallowed left wall is cropped away. Clamping its bookshelf visibly
blocked the fireplace. The followup caps room height at its source aspect ratio
so narrow views keep the authored room width (square standard or 3:2 Hallowed).
It changes the scene's height, with no letterbox bars, body/asset distortion or
saved-slot rewrite. The decorator's marker canvas uses the same effective
height. Explicit `setting` previews now pass the resolved setting to furniture
and dependent surfaces, addressing the PR review's override mismatch. Actual
updated CI scenes and regression checks are required before delivery.


## Combined release verification

Room CI 38016131935 rendered the revised framing and window overlays, but the
full suite reported 1,062 passing tests and one obsolete cross-room avatar Rect
equality assertion. Different source aspect ratios now deliberately produce
different frame heights. The replacement verifies 3:4 avatar proportions,
horizontal centering, complete containment and shared boot/shadow contact for
every body and room; square-room anchor equality remains enforced. The gated
decorator stage did not run in that failed build, so those furniture images
are not placement acceptance evidence. Independent review passed framing and
sampled window registration only.

PR #120 incorporates the exact reviewed robe repair from PR #121 and current
development base 13230d5. This allows required checks to cover the single
combined release. Both review findings are implemented: resolved room settings
feed all placement paths, and robe QA includes per-layer smooth enlargements.
Final feature-enabled renders, combined CI and hosted delivery remain gates.


## Independent feature-enabled review — PASS

Run 38016686201, head 48af378, merge-test 5c800b9, artifact 11655923932
completed both the full regression suite and the feature-enabled decorator
tests. Independent review inspected all 135 actual fixtures and native detail
views. The Hallowed bookshelf clears the entire fire opening, rear furnishings
meet the wall/floor, chairs and tables form side groupings, and autumn scenery
stays inside the glass without covering mullions. No blocking scale, placement
or window defect remained. Portrait fixture whitespace is outside the shortened
room's widget, not letterboxing inside the room.

Evidence SHA256: Hallowed display 600x416
`c41bb15c3cf92c02d558a59333fc5a76192c20d508689000718d2d11abc9766b`;
Hallowed reading-right 284x342
`299a562526e42a7eaefe6d1b159efee918d476866a6ace9d320735488282a33f`.

The concurrently merged magic release 1b79008 is preserved in the final
integration. Only the dashboard addition conflicted; both entries remain.
Its familiar/effect changes are preserved. Fresh combined checks and delivered
revision verification are required; no physical iPhone acceptance is inferred.
