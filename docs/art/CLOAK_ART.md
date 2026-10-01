# Moss Cloak and Hearthguard Mantle — review v1

Generated with the built-in image-generation tool for the founder-requested detailed 64-bit retro fantasy equipped-art style. Compact Market and Inventory icons remain unchanged 16-bit artwork. This is a visual review candidate, not founder approval.

## Assets and fit

- `assets/images/questwell_moss_cloak_v1.webp`
- `assets/images/questwell_guardian_mantle_v1.webp`
- Runtime registration: `lib/widgets/questwell_cloak.dart`
- Review route: `?review=cloaks`

Transparent source artwork was cropped to its garment bounds and converted to WebP. Both assets have a genuinely transparent open center. Continuous front drapes wrap over the class outfit. A body-specific foreground mask restores the original head, forearms, hands, and class sleeves above the fabric. The first clipped-capelet fit was rejected by the founder and superseded by this correction. Female, male, and neutral registrations vary the shoulder width and hem length. Original avatar and class assets were not modified; their integrity verifier passed.

## Moss-Green Cloak prompt

Use case: stylized-concept. Production equippable garment sprite for Questwell detailed 64-bit era retro fantasy RPG. ONE isolated moss-green cloak viewed straight from the front, draped on an invisible upright human body, no person or mannequin visible. Rich deep moss and forest green wool, sage lining visible at open inner edges, narrow antique brass-gold piping, restrained tiny embroidered fern and oak leaf details around shoulders and hem, small oval brass leaf clasp connecting the collar ends. Soft folded hood DOWN behind the neck, no hood enclosing the head. The cloak has rounded fitted shoulders, a short shoulder capelet, and long slender folds extending to mid-calf. It opens widely down the entire center so a full outfit and both arms can remain visible; preserve a large genuinely TRANSPARENT open central region from just below the collar to the bottom, absolutely no shirt or torso or lining panel filling that opening. The garment is taller than wide, restrained natural silhouette, front symmetrical, tails gently flare outward at the bottom. Full garment isolated centered on genuine transparent background, complete hem, generous padding. Polished detailed fantasy sprite illustration with fine deliberate pixel clusters, rich material shading and crisp silhouette, matching high-detail retro anime fantasy avatar clothing. No head, hair, skin, arms, hands, legs, boots, body, stand, hanger, floor, extra props, text or watermark.

## Hearthguard Mantle prompt

Use case: stylized-concept. Production equippable garment sprite for Questwell detailed 64-bit era retro fantasy RPG. ONE isolated Hearthguard mantle viewed straight from the front, draped on an invisible upright human body, no person or mannequin visible. Rich oxblood burgundy wool with deep wine velvet lining, narrow antique brass-gold binding, tailored compact shoulder capelet with understated layered scalloped edges, tiny embroidered gold shield and hearth-flame motifs around shoulders and hem, small round bronze shield clasp connecting collar ends. A short standing collar, no hood, no armor spikes, no fur. Rounded fitted shoulders and long slender folds extending to mid-calf; opens WIDELY down entire center so a full outfit and both arms can remain visible; preserve a large genuinely TRANSPARENT open central region from just below collar to bottom, absolutely no shirt or torso or lining panel filling that opening. Taller than wide, restrained natural silhouette, front symmetrical, tails gently flare outward at bottom. Full garment isolated centered on genuine transparent background, complete hem, generous padding. Polished detailed fantasy sprite illustration with fine deliberate pixel clusters, rich material shading and crisp silhouette, matching high-detail retro anime fantasy avatar clothing. No head, hair, skin, arms, hands, legs, boots, body, stand, hanger, floor, extra props, text or watermark.

## Wrapping correction verification

Build `f0b91a805aff2860f69233043766f56b1e04a7f3` narrows and centers both garments per body and preserves continuous shoulder-to-hem panels. Flutter Check 36809650001 and Preview 36809649944 passed. Both garments were inspected in the browser on all three bodies, including Hearth rendering. Founder visual approval pending.

## Cloak shoulder and hem polish — 2026-09-30 America/Chicago

Founder approved a refinement pass on the corrected fit. Softened sleeve emergence with a short alpha blend and subtle contact shadows. Tapered the hem by 7% with a 1.2-pixel lateral drape, keeping neckline registration, full embroidery, and boot clearance. Artwork and icons are unchanged.

Verified development build `433f8228e16e7e4dd5213aa1a2ec97c54edb8ae0`: Flutter Check 36810444631 and Preview 36810444494 passed, including frozen asset integrity and existing cloak render/removal coverage. Browser inspected both garments on all three bodies in avatar and Hearth views. Review: `?review=cloaks&rev=433f822`. Founder visual approval pending; no merge or launch.


## Cloak underlayer and neckline correction — 2026-09-30 America/Chicago

Founder identified class shoulder trim protruding beside the cloaks and a stray band directly below the neck. Added an equipped-cloak-only class underlayer mask that suppresses original lapels/epaulettes on front and rear class layers while retaining torso and sleeves. Reduced the restored head region to stop the original shirt collar painting across the outer cloak collar. Moss retains its own folded hood; Hearthguard retains its standing collar.

Verified build `9c75bd16527501f3b99e4ea700149cb87f6565af`: Flutter Check 36811239939 and Preview 36811239886 passed. New mask checks cover both shoulder tips, competing collar, visible torso/cuffs, and the removed shirt strip; existing 18 cloak/class/body combinations and removal remain covered. Browser inspected both cloaks on all three bodies in avatar and Hearth views, confirming hidden shoulder trim and clear outer collars. Review: `?review=cloaks&rev=9c75bd1`. Founder visual approval remains pending; no merge or launch.


## Cloak contour correction — 2026-09-30 America/Chicago

Founder requested correction of the harsh neck band, cut-out sleeve transitions, and competing inner hem. Replaced the horizontal neck cutoff with a skin-following curved opening. Upper sleeves now remain below the capelet; only lower forearms restore above the cloth. Removed the synthetic shoulder fade/shadow. The inner class coat now ends within a curved knee/calf silhouette, hiding its outer gold corners near the boots.

Verified development build `2c77a41a504595f7a852203cea7863d7d5b85bbc`: Flutter Check 36811842575 and Preview 36811842602 passed. Mask checks cover restored neck skin, excluded shirt collar, upper sleeve depth, preserved cuffs, and tucked hem. Browser inspected both cloaks on all three bodies in avatar/Hearth views, plus an enlarged neckline capture. Review: `?review=cloaks&rev=2c77a41`. Founder visual approval pending; no merge or launch.


## Closed cloaks and handheld equipment rule — 2026-09-30 America/Chicago

Founder authorized cloaks covering the hands with no simultaneous carried item. Both cloak renders now keep arms and hands beneath continuous cloth; a body mask preserves approved head/hair/neck and legs. Satchel overlap uses the same class mask, so bags cannot restore an exposed arm. Stale conflicting render maps suppress held art while a cloak is present. Artwork files and 16-bit icons remain unchanged.

Market and Inventory load fresh equipment before a named swap confirmation. Cancel keeps the loadout. The new authenticated `equip_cosmetic_loadout` RPC checks the expected conflicting item under the profile row lock, then atomically equips the requested item and removes incompatible cloak/hand gear. The existing equip RPC also enforces incompatibility for older clients. Other categories, ownership, and coins are preserved. No existing conflicting loadouts were found; no founder equipment was changed.

Idempotent database change: `tool/qa/closed_cloak_loadout.sql` (applied). Synthetic authenticated verification: `tool/qa/closed_cloak_loadout_check.sql` passed before and after applying, testing both cloaks, both directions, unconfirmed/stale swaps, legacy enforcement, unrelated equipment, and unchanged balances/ownership. All fixture writes rolled back. Advisor check found no new function/security findings; existing leaked-password-protection warning remains outside this change.

Verified development build `98bceba948cc631596e7b9eb4c6a91b367538ba4`: Flutter Check 36812933068 and Preview 36812933124 passed, including closed-hand masks, stale held-art suppression with satchel, conflict policy, dialog cancel/confirm, and supported cloak/class/body render coverage. Browser inspected both garments across all three bodies in avatar/Hearth views. Preview cancel, cloak-to-lantern, and lantern-to-cloak confirmation flows passed. Review: `?review=cloaks&rev=98bceba`, with Try holding a lantern. Founder visual approval pending; no merge, external beta, or launch.


## Moss collar artwork v2

Built-in image generation, precise-object-edit mode. Edit target: original Moss Cloak source `exec-5d33cc33-46c5-4ce1-8e1f-1d2efca1f937.png`. Output `exec-09feff43-f843-486b-b3fb-526c11de7cc6.png`, converted without painting over the artwork to `assets/images/questwell_moss_cloak_v2.webp` (crop 974x1362+26+90, resize 481x680, WebP quality 92). Alpha inspection confirmed genuine transparent neck and central opening. The versioned file preserves the first asset for comparison.

Prompt:

> Use case: precise-object-edit. Edit target: attached Questwell moss-green cloak garment sprite. Fix ONLY the neckline and upper collar area; preserve the existing long closed-over-arms drape, exact shoulder/hem silhouette, leaf embroidery, gold piping, moss wool colors, sage lining, detailed retro fantasy style and front-facing placement. The old collar has ugly horizontal green bars spanning the neck opening. REMOVE those horizontal bars and the tall collar entirely. Replace with a simple low, softly curved V-shaped neckline that would sit naturally at the base of a human neck. Bring the ONE small brass leaf clasp UP to just below the neck opening, approximately 145 pixels from the top of this 1536-high canvas. Fill the short area directly below that clasp with matching green wool down to the top of the chest (about y=250), forming a clean joined collar with no holes for a shirt/tie to peek through above or below the clasp. Below that short join the cloak opens in the existing long central gap. Keep hood folds only on the OUTER shoulders/behind the neck opening; NO horizontal rear collar bar, no tube collar, no inner bands, no stacked rings, no scarf, no double clasp. The central neck opening itself must be genuinely transparent, continuously open to the transparent exterior above it. Entire garment isolated on genuine transparent background, central long opening transparent; no character, mannequin, skin, shirt, tie, body, scene, glow, floor or watermark. Match original whole-canvas position and garment size closely. Do not change the capelet embroidery or anything below its shoulder section.

## Moss Cloak collar redraw — 2026-09-30 America/Chicago

Founder reported the Moss collar still looked wrong after the closed-drape change. The original bitmap had horizontal folds across its neck opening; clipping could not resolve that art defect. Used built-in image-generation edit mode to redraw the neckline as a clean V meeting a single leaf clasp, with a short joined wool section below it. New versioned asset: `assets/images/questwell_moss_cloak_v2.webp`. Equipped hand-coverage/swap rules and Hearthguard remain unchanged. Full prompt and provenance are in `docs/art/CLOAK_ART.md`.

Verified development build `3d166a2c38d032c0e28d2c912e89196bc7fbbf6f`: Flutter Check 36813840313 and Preview 36813840360 passed. Browser inspected the Moss collar on female, male, and neutral in avatar/Hearth views, plus enlarged female neckline proof. The shirt collar is visible within the V as a continuous underlayer; the old crossing green bars are gone. Review: `?review=cloaks&rev=3d166a2`. Founder visual approval pending; no merge or launch.

