# Brass lantern — candidate fit, 2026-09-30

Founder approved the brass/amber/teal concept and requested the detailed
64-bit retro-fantasy direction for equipped art; inventory stays simpler retro.

Built-in image generation produced a transparent asset from the approved
concept. Prompt: preserve the brass loop, teal jewel, amber panes and candle;
remove exterior halo and backdrop including handle opening; simplify surface
noise into crisp richly shaded retro-fantasy illustration. No avatar edits.

Candidate: assets/images/questwell/avatar/lantern_brass_illustrated_v1.png.
Body-specific positioning uses the frozen 240 x 320 canvas, with original hand
and cuff layers restored above the handle. Opposite side from the satchel.

Review routes: `?review=lantern` and `?review=lantern-matrix`.
Founder approved the corrected grip. Inventory integration uses `brass-lantern`
in the existing `hands` slot, with a matching 16-unit brass/amber/teal icon.
Catalog price: 60 earned coins, non-premium, universal (no class restriction).
Existing room item `warding-lantern` remains unchanged. No founder grant,
account equipment change, or coin spend is performed by this integration.

Tests exercise all five classes and three bodies with lantern on/off while
preserving the satchel. UI tests cover ownership, busy state, class locks,
equip/unequip actions. Transaction-rollback RPC checks cover Hands replacement,
all class changes, ownership retention, unrelated gear and account isolation.

Development preview only. Keep unmerged and unlaunched.

Handle revision: founder flagged the initial grip. Lowered the loop crown
to the fingers (female +6, male +5, neutral +6 canvas pixels) and centered
the male/neutral loop under the hand (-4/-2 horizontal pixels). Artwork,
scale, and original hand occlusion remain unchanged. Recheck all body styles.
