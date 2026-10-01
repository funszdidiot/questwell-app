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
