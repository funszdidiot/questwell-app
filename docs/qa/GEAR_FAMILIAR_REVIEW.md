# Gear and familiar review — 2026-10-01 UTC

User direction: detailed 64-bit retro fantasy equipped art; existing compact Market/Inventory icons remain 16-bit. Review small sets in the app. No external beta or flutterflow merge.

## Market and founder inventory update — 2026-09-30

Founder requested all seven familiars in the Market with 16-bit icons and in her inventory. The six existing entries were already active shop items. Added Emerald Dragon as an epic, all-class companion at 320 coins; repeatable catalog seed is `tool/catalog/emerald_dragon.sql`. Added a native 32-pixel dragon icon using the existing 16-bit icon renderer shared by Market and Inventory. Equipped artwork remains detailed retro fantasy.

Granted seven missing familiar ownership records to the verified founder account with `source=founder_grant`, preserving existing ownership and equipment via conflict-do-nothing. No coins charged; balance remained 79. Account identifiers are not stored in this document. Read-back confirmed all seven owned and active in the shop. Existing class restrictions remain intact. Dragon equip/unequip through the authenticated public RPCs passed in a rolled-back transaction, including the one-familiar slot check.

The paragraph below records the earlier art-review state; the dragon is now a Market item.

## First set: companions

Six existing familiars now have dedicated transparent equipped artwork, separate from inventory icons: mushroom, tiny owl, archive owl, glass slime, signal fox, moss moth. Added Emerald Dragon candidate requested by user. Dragon is available in the account-free development review (`?review=companions`), not yet a priced live catalog item. No ownership, prices, class locks, or database changes.

Ground companions share the avatar boot baseline. Moss moth hovers beside the shoulder. Idle breathing, slime squash, and moth hover respect reduced motion and inactive screens. All existing equipped companions use the new renderer in the app.

Visual approval still pending. The dragon is the default review selection. Body selection covers female, male, neutral. Class-specific existing companions preview with the appropriate class. The Hearth renders the same equipment layer.

## Remaining gear

- Moss Green Cloak (chest)
- Hearthguard Mantle (guardian chest)
- Wayfarer Satchel (wanderer back)
- Annotated Grimoire (scholar hands)
- Pathfinder Boots (scout feet)

These five still need the next detailed art/fit pass. Approved robes, existing detailed accessories, room furnishings, trophies, and Market remain frozen. Victory Sparkle and Focus Tonic can receive a later effects pass.

## Art provenance

Built-in image generation; transparent originals converted to individual WebP sprites without painting over the artwork. Versioned files: `assets/images/questwell_familiar_*_v1.webp`.

Dragon prompt: Production game familiar sprite for Questwell, cozy dark-academia fantasy RPG. Exactly one full-body small dragon familiar on a genuinely transparent background. Polished detailed 64-bit era retro fantasy sprite illustration, fine deliberate pixel clusters and rich jewel-tone shading, crisp readable silhouette, consistent with detailed fantasy RPG avatar companions. Emerald forest-green scales, warm brass-gold horns and small dorsal spines, pale sage belly, amber eyes, modest batlike wings held partly open, friendly intelligent expression. Sitting in three-quarter view facing slightly left toward its human companion, complete paws visible, tail curls neatly alongside body, compact silhouette. Entire dragon centered with generous transparent padding, no cropping. Readable as a small creature beside a human avatar. No other characters, scenery, lettering, platforms, separate props, fire, watermark or ground shadow. Square canvas.

Six-familiar atlas prompt: Exact 3-column by 2-row transparent atlas; detailed retro fantasy illustration with fine pixel clusters. Top row: russet spotted mushroom with ivory body, green scarf and satchel; tawny owl with amber eyes and brass moon pendant; navy-and-cream archive owl with brass spectacles and burgundy book. Bottom row: mint-teal glass slime with gold flecks and bubbles; seated copper fox with cream chest, green bandana and brass compass; emerald/sage moss moth with gold eyespots and ivory body. Complete isolated silhouettes, consistent scale, no labels, scenery, or platforms.

## Verification

Development build `3923e33b2b87197d42b5cd9313ee954e7962f8f3`: Flutter Check 36806039882 and Preview 36806039936 passed. Seven companions × three body types and reduced-motion/TickerMode tests passed. Browser inspected dragon female and neutral fit, avatar/Hearth placement, and glass slime transparent sprite/class selection. Founder visual review remains pending.

Market/inventory follow-up verified on build `4b9b553169c44bfcf95864f4a22214cb5a00daa5`: Flutter Check 36806853312 and Preview 36806853289 passed. Browser verified the 16-bit dragon icon and 320-coin Market listing. All seven remain owned with 79 coins and no familiar automatically equipped.

## Dragon smoke and rainy glass — 2026-09-30

Founder requested a small animated nose exhale and an animated Rainy Window. Three shaded smoke puffs now emerge from the dragon's registered nostril, drift upward/left, expand, and fade, followed by a pause. Smoke shares the existing breathing transform and timer. The window's rain streaks and slower sliding beads animate behind its registered pane mask, keeping the wooden frame and room still. Only the overlay repaints.

Reduced motion hides the smoke and preserves static rainy glass. Both controllers stop when their route's TickerMode is inactive and dispose on removal. The account-free companion review now shows an optional Rainy Window alongside the dragon; the Animations switch controls both. Actual in-app effects follow equipped items. No equipment, inventory, price, or database changes.

Added raster checks for changing rain/smoke frames, smoke ascent/rest intervals, and no paint on the window's mullions or adjacent wall, plus reduced-motion/inactive/unequip checks.

Verified build `e977695c942263cdcd930513ef92b6c618be7162`: Flutter Check 36807592855 and Preview 36807592810 passed. Browser confirmed smoke placement and moving glass, with a 6.5-second capture. Founder-requested Rainy Window inventory grant confirmed owned and unplaced with balance unchanged at 79.

## Cloak first-set review

Build `1f8d86445982bc4ade44d58d9ee995fa37a101fb` adds detailed Moss Cloak and Hearthguard Mantle layers and `?review=cloaks`. Flutter Check 36808923953 and Preview 36808923990 passed, including 18 supported class/body/garment combinations and removal. Browser checked all six garment/body fits. Founder visual approval pending. Remaining next set: Wayfarer Satchel, Annotated Grimoire, Pathfinder Boots. No inventory grants or database changes in this pass. Art prompts are in `docs/art/CLOAK_ART.md`.

## Cloak fit correction

Founder rejected the first fit because the cloaks did not wrap or sit correctly. Build `f0b91a805aff2860f69233043766f56b1e04a7f3` replaces the short front capelet clip with continuous front panels and restores original forearms/hands/class sleeves above the fabric. Registration is narrower and centered per body. Flutter Check 36809650001 and Preview 36809649944 passed. Browser inspected both garments across all three bodies in avatar/Hearth views; no disconnected panels or hidden hands observed. Review `?review=cloaks&rev=f0b91a8`. Visual approval remains pending; no merge or launch.

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


## Moss Cloak collar redraw — 2026-09-30 America/Chicago

Founder reported the Moss collar still looked wrong after the closed-drape change. The original bitmap had horizontal folds across its neck opening; clipping could not resolve that art defect. Used built-in image-generation edit mode to redraw the neckline as a clean V meeting a single leaf clasp, with a short joined wool section below it. New versioned asset: `assets/images/questwell_moss_cloak_v2.webp`. Equipped hand-coverage/swap rules and Hearthguard remain unchanged. Full prompt and provenance are in `docs/art/CLOAK_ART.md`.

Verified development build `3d166a2c38d032c0e28d2c912e89196bc7fbbf6f`: Flutter Check 36813840313 and Preview 36813840360 passed. Browser inspected the Moss collar on female, male, and neutral in avatar/Hearth views, plus enlarged female neckline proof. The shirt collar is visible within the V as a continuous underlayer; the old crossing green bars are gone. Review: `?review=cloaks&rev=3d166a2`. Founder visual approval pending; no merge or launch.



## Full outfit and stale preview correction — 2026-09-30 America/Chicago

Founder approved the Moss v2 collar and requested both cloaks in inventory; both grants completed with ownership and coins preserved. A subsequent phone screenshot showed the pre-closed-cloak sleeves and collar. Current Home and Adventurer share the same renderer; the screenshot is consistent with an older loaded app build, not a separate Hearth renderer.

Emerald Scarf now draws beneath an equipped closed cloak so it cannot cover the leaf clasp. Added a full Wanderer/scarf/satchel/brooch/moth fixture at `?review=cloaks&outfit=wanderer&rev=914d2db`. No account equipment changes were made for this fix. Approved art and base/class assets remain unchanged.

The preview now publishes a revision manifest and checks for updates at startup, on returning to the app, and every minute while visible. A newer deployment offers an explicit refresh; it never interrupts unsaved work automatically. Refresh preserves the current route. Only this app's legacy Flutter service worker registration is retired; account storage is untouched. An old tab must open the current build once to receive this update-checking code.

Verified build `914d2db47e2fbbf9951796262c0d9b5d0ca17709`: Flutter Check 36815097513 and Preview 36815097522 passed. Four update-handler tests cover explicit refresh, preserved routes, scoped worker retirement, dismissal, offline/invalid manifests, and visibility changes. Full-outfit layering regression checks run on all three bodies. Browser inspected male, female, and neutral Wanderer with the full accessory set and the male Hearth scene; clasp clear, hands covered, satchel retained. Main app's deployed revision was verified at `?rev=914d2db`; browser is signed out, so outfit QA used the shared-renderer fixture. Proof: `wanderer-cloak-fixed.jpg`. No merge to flutterflow or launch.


## Moss Moth golden particles — 2026-09-30 America/Chicago

Added fourteen staggered gold motes and stepped star sparkles around the equipped Moss Moth. Wing-dust drifts outward/downward and fades, sharing the existing hover clock and reduced-motion/offscreen pause. Sprite and inventory icon assets are unchanged.

Verified build `a8dec4b5b4dd70eeaeb1ffda13d1f1f6338bea99`: Flutter Check 36815650283 and Preview 36815650276 passed. Browser inspected moving particles beside the full Wanderer outfit in avatar and Hearth views at normal size. Captured multiple live phases and proof `moth-golden-magic.jpg`. The previous build's update notice appeared; its Refresh Questwell button correctly loaded the new revision. Development preview only; no merge or launch.


## Wayfarer Satchel equipped-art upgrade — 2026-09-30 America/Chicago

Founder authorized the remaining gear pass, starting with the Wayfarer Satchel, and reconfirmed detailed 64-bit-style equipped art. Replaced its canvas placeholder with transparent illustrated olive canvas, leather trim, brass buckle/rings and rolled map. Registered a separate shoulder strap to the upper-right ring and body-specific bag placements. Shared cloak-aware forearm restoration preserves natural hand overlap in open outfits and keeps hands hidden beneath closed cloaks. Updated its shared 16-bit Market/Inventory icon to match the olive/leather/map palette. Wanderer restriction, 160-coin price, back slot, ownership and equipped state are unchanged. Built-in generation prompt and source details: `docs/art/WAYFARER_SATCHEL.md`.

Verified code build `f12473e122536fac67499d943fa8165a662ec76a`: Flutter Check 36816403718 and Preview 36816403711 passed. Locked asset verification passed. Browser inspected male, female and neutral in open Wanderer outfits and Moss Cloaks; bag/strap removal and restoration passed. Visual QA used normal pointer interaction; accessibility-enabled browser automation was unreliable and was not counted as a verified accessibility test. Review `?review=wayfarer&rev=f12473e`; proof `wayfarer-satchel-fit.jpg`. Founder design review pending. Annotated Grimoire and Pathfinder Boots remain next. Development preview only; no merge or launch.

