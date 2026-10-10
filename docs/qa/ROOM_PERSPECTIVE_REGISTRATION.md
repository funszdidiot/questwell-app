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
