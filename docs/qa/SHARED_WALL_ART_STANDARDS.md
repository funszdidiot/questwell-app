# Shared wall hangings and two Hearth standards — October 9, 2026

Status: QA. Implementation and regressions prepared; remote checks and visual review pending.

Tanya directed that wall hangings carry between rooms and identified two architectural
standards with screenshots: Original Hearth (open back wall, side fireplace/window)
and Hallowed Hearth (front fireplace/chimney, arched window). All eight square
background variants inherit the Original layout. Hallowed uses its own chimney gallery.
Existing background, furniture, avatar and wall-art assets are unchanged.

The current equipped wall slots are authoritative when changing backgrounds. Saved
room snapshots restore other decorations only; old wall entries are stripped before
the current walls are overlaid, including intentionally empty spots. Save uses the
existing atomic owned-item validation and revision/current comparison. Reopening and
Market placement/removal use the same draft model. Undo restores the previous draft;
closing without saving preserves equipment. No database migration or account write
is part of this implementation. Older cached clients retain their previous behavior.

Rendering and noninteractive decorator outlines resolve the same wall rectangles with
the background cover crop. The former compact-gallery exception is removed. Hallowed
places all three frames above the mantel, away from the arched window; Original places
them on its open wall. This establishes two layout families without replacing artwork.

Regression coverage: carry, replace, remove, undo, reopen with stale saved rooms,
room-specific furniture preservation, marker/frame registration, two-family rendering,
and all nine full scenes with the same three equipped paintings at four sizes.
Narrow wall controls stay below the preview to avoid overlapping touch targets.
The Original center landscape rises above the measured locked-avatar head bounds
in tall views; side portraits keep their size. First CI found the head-clearance
regression, while carry and marker checks passed. Final rerun is pending. Device/account
acceptance remains separate from fixture rendering. Local Flutter bootstrap was blocked
by automatic review for unintended metadata access; CI is the test/render path.
