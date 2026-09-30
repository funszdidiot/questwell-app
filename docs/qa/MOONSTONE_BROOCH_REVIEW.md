# Moonstone Brooch — fit review

Founder approved the illustrated concept on 2026-09-30. The original PNG is
preserved at assets/images/questwell/avatar/brooch_moonstone_illustrated_v1.png.
Built-in image generation prompt: compact frontal oval icy-blue moonstone,
antique-gold bezel and leaf flourishes, richly shaded retro-fantasy equipment,
transparent background, no external glow, no chains, no avatar or text.

The candidate sits on the viewer-left upper robe, outside the scarf and
opposite the satchel strap. It uses the frozen 240x320 canvas with body-specific
anchors. Approved avatar, scarf, satchel, and lantern assets are unchanged.
Inventory uses a 16-unit code-painted icon in the existing square treatment.

Review routes: ?review=brooch and ?review=brooch-matrix. All five classes and
three body styles are available, with independent accessory toggles and Hearth
preview. Tests check all 15 combinations on/off without removing other gear.
Founder approved fit; account equipment now uses `moonstone-brooch` in the
existing `accessory` slot. Universal, non-premium, 60 earned coins. No founder
grant or purchase. Existing scarf, lantern, and satchel slots remain independent.
UI tests cover equip/unequip, ownership retention, saving and class locks.

Keep unmerged and unlaunched.

Fit correction: the first anchor sat at the armhole. Move the pin higher and
inward onto the upper lapel, and reduce the square bounds from 18 to 14 units
so it fits the narrow lapel beside the scarf. Check scarf on/off for each body.

Readability polish: increased bounds to 16 units around the same corrected
lapel centers, added a restrained contrast filter preserving alpha, and a
subpixel alpha-shaped contact shadow. Original PNG and inventory icon unchanged.
No external glow. Regression test locks the corrected centers.
