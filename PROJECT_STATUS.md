# Questwell Project Status

_Last verified: 2026-09-30 (America/Chicago)_

This file is the founder-facing dashboard for the Questwell art overhaul.

## Meeting Mimic arcade entrance — 2026-10-01

Founder approved Inbox Hydra ("Love it") and requested the next boss. Added Meeting Mimic in `07a3d5df0a5fde76034686fff851f44c6b18c871`: detailed burgundy chair monster, higher entrance hop and brief landing wobble, own taunt ("This could have been an email."), equipped-avatar scene and shared health/defeat treatment. Both detailed bosses now selectable in practice preview; real Meeting Mimic encounters use the new renderer. Server task/reward logic unchanged.

Flutter Check 36831038903 and Preview 36831038899 passed. Added Mimic art/taunt/reduced-motion/defeat coverage alongside existing entrance tests. Browser verified warning, slide/landing/typewriter frames, final art/typography, and all three sample attacks producing zero HP and MEETING ADJOURNED. Review: https://funszdidiot.github.io/questwell-app/?review=boss&boss=meeting_mimic&rev=07a3d5d . Founder Mimic visual review pending. Account rewards were not exercised; sample encounter is read-only practice. No merge or launch. Male Wanderer cuffs remain deferred and unapproved.

## Inbox Hydra arcade entrance — 2026-10-01

Implemented the first boss encounter art/entrance pass in `8c6b3b2eab8b9d869a5bf5055dde62993abb157a`: detailed retro-fantasy Inbox Hydra, equipped player appearance, darkened BOSS APPROACHING banner, slide-in/bounce/dust, typewriter taunt, filling health meter, YOUR MOVE cue, and defeat fade. Tap/Skip supported; entrance remembered per encounter, bypassed for existing progress, reduced-motion still state, inactive-route ticker pause. Other bosses and server task/reward logic unchanged.

Flutter Check 36829985533 and Preview 36829985688 succeeded. Tests cover timing, skip, persistence, rebuild, reduced motion, resumed encounters, health changes and defeat. Browser review verified slide/warning, finished dialogue, first attack reducing health, and three practice attacks producing zero HP/VICTORY/sample loot. Review URL: https://funszdidiot.github.io/questwell-app/?review=boss&rev=8c6b3b2 . Practice controls do not write account tasks/rewards. Signed-in real-task reward flow was not exercised. Founder visual review pending; no merge or launch.

Founder-requested Victory Sparkle and Focus Tonic inventory grants were also completed and verified: both owned, unequipped, coin balance and prior equipped items unchanged. Male Wanderer cuffs remain explicitly deferred and unapproved.

## Victory Sparkle and Focus Tonic effects — 2026-10-01

Implemented the authorized effects pass: Victory Sparkle uses two staggered golden star flourishes and drifting flecks with a quiet interval; Focus Tonic uses slow rising sage bubbles and small glints. Shared production renderer covers Adventurer and Hearth. Existing 16-bit icons/catalog rules retained; no account changes. Direct CustomPainter repaint isolates animation from avatar builds; reduced motion uses still art and inactive routes/unequip stop the clock.

Verified `06ce1af7e861fbbe9b47293c4cdfee1c695e9afd`: Flutter Check36828452644 and Preview36828452634 passed, including new motion/face-clearance/rest/still-state/ticker/unequip tests. Live review verified both effects on female with Hearth, male still mode, neutral unequip, and resumed sparkle. Preview `?review=effects&rev=06ce1af`. Founder visual review pending. Male Wanderer cuffs remain deferred and unapproved. No merge or launch.

## Deferred founder follow-up — male Wanderer cuffs — 2026-10-01

Tanya is not fully satisfied with the male Wanderer cuff fit in the current v3 short coat. Keep this as an open visual-polish item, not founder-approved or complete. Explicitly defer further male cuff work until the other builds are done, then revisit the wrist fit and cuff shape with an in-app close-up for founder review. The current version may remain in the development preview in the meantime. This note does not expand approval to any other pending art or authorize launch.

## Wanderer male and neutral cuff fit v3 — 2026-10-01

Founder flagged flared corners and off-center hands on male and gender-neutral v2. Added separately tapered v3 sleeve artwork registered to wrist centers. Female remains v2. Live close-ups checked male and neutral without satchel, plus male satchel overlap; thinner hems now follow wrist angles without the former projecting corners. Flutter Check36827443913 and Preview36827443909 passed for `213b251f1b9f3ab7af787a785d8357af593b81a2`. Preview `?review=wayfarer&rev=213b251`. Awaiting founder review; no account changes.

## Wanderer short-coat cuff revision — 2026-10-01

Founder reported disconnected cuffs. Close-up confirmed the artwork painted empty dark oval sleeve openings across the wrists. New body-specific v2 coat sprites remove those openings and replace double rolled rings with a single thin gold cloth edge. No runtime cuff overlays. Verified female close-up, male with satchel, neutral without satchel, and Hearth rendering. Flutter Check36826583890 and Preview36826584043 passed for `77fa755384d14fa9a17603f2f286b089186e79fb`. Preview `?review=wayfarer&rev=77fa755`. Awaiting founder visual review. No account changes.

## Wanderer short travel coat — 2026-10-01

Founder rejected the runtime cuff overlays as artificial, then requested the newly generated tailored design in a shorter Wanderer version. Added separate detailed 64-bit-style female, male and neutral sprites with rounded upper/mid-thigh hems, warm brown fabric and gold stars/piping. Cuffs are part of each painted sleeve; runtime Wanderer cuff overlays are no longer rendered. Matching rear layers end above the short front hem. Original approved v2 assets and frozen body masks remain unchanged. Provenance: `docs/art/WANDERER_SHORT_COAT.md`.

Verified `c7d70a91efb988a794049df6155d5c8507f34d5d`: Flutter Check 36825682256 and Preview 36825682397 passed. Live review checked all three bodies, female without satchel, satchel overlap, Moss Cloak coverage, and Hearth rendering. Preview `?review=wayfarer&rev=c7d70a9`. Short coat awaits founder visual approval. No inventory or account changes. This supersedes the cuff overlay candidate below.

## Wanderer cuff correction — 2026-10-01

Founder approved the Pathfinder Boots appearance and flagged the same wrist-wrap issue on the Wanderer coat. Added registered Wanderer cuffs for female/male/neutral: curved recessed openings, narrower ends, subdued double gold trim, and brown cloth shading blended into sleeves. Old cuff ends are masked on all garment restoration passes; satchels retain correct arm overlap. New cuffs are hidden under closed cloaks and replacement business suits. Frozen source art and manifest remain unchanged.

Final `be1756c07d9318f7e49b981c05c153b21554f163`: Flutter Check 36823891013 and Preview 36823890821 passed. The original body-switching test was updated to select its body clipper explicitly after cuff masks added extra ClipPaths; its anatomy assertions remain intact. Live review checked all three bodies, male close-up, satchel overlap and Moss Cloak concealment. `?review=wayfarer` shows the production rendering change. No account changes. Boots approved visually, inventory grant not yet requested; Wanderer cuffs await founder review.

## Pathfinder Boots detailed art — 2026-10-01

Created detailed 64-bit-style chestnut leather boots with olive cuffs and antique brass buckles using built-in image generation. Matching 16-bit inventory/Market icon uses the existing 32px painter. Replaced the old generic boot shapes with individually registered left/right sprites for female, male and neutral. A conditional base mask removes original shoes; garment and cloak fronts overlap boot shafts. Prompt, asset paths and crop provenance: `docs/art/PATHFINDER_BOOTS.md`.

Verified `758657c890e5923bffdfefa50d7563941df57373`: Flutter Check 36822919793 and Preview 36822919595 passed, including new boot load/unequip/cloak tests and asset integrity verification. Live browser checked all three Scout bodies, both cloaks, Scholar robe overlap, unequip restoration, matching icon and full Hearth scene. Preview `?review=boots`. Existing Scout-only/rare/160-coin catalog rules retained. Boots await founder visual approval; no inventory grant or account change.

Grimoire status: founder requested inventory grant after cuff polish; grant verified as owned, unequipped, with 79 coins unchanged.

## Scholar cuff final polish — 2026-10-01

Founder requested narrower openings and softer gold. Cuffs taper from the sleeve into a narrower wrist opening; thinner muted gold bands and low-contrast cloth folds reduce the separate polished-band look. Grimoire grip/tilt unchanged. Build `761e87ed152275c6182310437130cea59987907a`: Flutter Check 36821727168 and Preview 36821727167 passed. Browser inspected female, male, and neutral portrait/Hearth fits plus male close-up. Awaiting founder visual approval; no inventory or coin changes.

## Grimoire grip refinement and cuff blending — 2026-10-01

Founder authorized a tighter grip, blended cuff seams, and a slight inward tilt. Built-in image edit v3 closes the finger loop and strengthens spine contact. The sprite pivots 0.055 radians at the registered wrist. Cuffs blend into retained sleeve cloth above the original trim; the final mask removes the ghost ornament caught in close-up. Prompt and asset path: `docs/art/ANNOTATED_GRIMOIRE.md`.

Art build `7c1260af190adf7dbe668eb5507c7e0f895e5adb` passed Flutter Check 36820957046 and Preview 36820956990. Browser review covered female, male, neutral, portrait/Hearth, and neutral unequip. Frozen assets verified. No inventory, equip, or coin changes; founder visual approval pending. Later network-handling work is preserved.

## Grimoire handedness and curved Scholar cuffs — 2026-10-01

Founder identified the v2 grip as backward and the Scholar cuffs as flat. The integrated grip is now mirrored to the avatar's left hand, with its thumb inward and the book against the thigh; its wrist remains registered per body. Both Scholar cuff ends now have curved gold trim, recessed lining, and a front lip over the wrist. The old cuff regions are hidden on every robe restoration pass. Frozen base/robe files and their integrity checks are unchanged.

Verified build `e5d87bbea2af917c608376c94ba8ea8c046f821d`: Flutter Check 36819597999 and Preview 36819598111 passed. Browser review covered female, male, and neutral with the grimoire held and removed, including the Hearth composition. The existing cloak conflict tests passed. No inventory grant, equip, or coin changes. Founder visual approval is still pending; grimoire is not yet granted.

## Grimoire spine grip correction — 2026-10-01 America/Chicago

Founder rejected the first fit as unnatural: a relaxed hand had been restored over the cover. Replaced that treatment with an integrated, detailed book-and-gripping-hand sprite. The thumb presses the cover and fingers curl around the spine. A grimoire-only base visibility mask removes the original hand; the class cuff restores above the new wrist. Body-specific wrist registration replaces the old floating-book offsets. Frozen base/class artwork, inventory icon, catalog rules and account state remain unchanged. Updated built-in edit prompt/provenance: `docs/art/ANNOTATED_GRIMOIRE.md`.

Verified build `85a0303ac9de8915bcbbec893c4c49c8d0a558fd`: Flutter Check 36818573291 and Preview 36818573300 passed, including new tests for other-body preservation, no original-hand restoration, all-body grip loading, unequip restoration and stale cloak-loadout suppression. Browser inspected female, male and neutral avatar/Hearth grips and neutral unequip/restoration. Enlarged real browser capture inspected the male thumb, fingers and sleeve join. Proof saved: `grimoire-grip-review.jpg` (in-app frame plus enlarged hand detail). Verified review: `?review=grimoire&rev=85a0303`. Founder visual approval pending; development preview only, no merge or launch.

## Annotated Grimoire equipped-art upgrade — 2026-09-30 America/Chicago

Replaced the handheld canvas placeholder with detailed 64-bit-style plum leather, gold hardware, worn ivory pages and annotation tabs. Three registered body placements restore the existing hand and class cuff over the upper cover edge. Updated the matching 16-bit icon. Shared cloak conflict confirmation and server-side equipment rules remain unchanged. Scholar-only, rare, hands slot, 160 coins. No account changes. Prompt and source: `docs/art/ANNOTATED_GRIMOIRE.md`.

Build `4477ab07a9b51a86ace491130e18196dfba0acc1`: Flutter Check 36817616481 and Preview 36817616421 passed. Browser visually inspected female, male and neutral Scholar grips in avatar/Hearth views. Cancel retained the book; confirmed book-to-cloak and cloak-to-book swaps passed. Final female Hearth view was inspected, but the browser transport disconnected before saving a screenshot artifact. Verified review route: `?review=grimoire&rev=4477ab0`. Founder visual approval pending; Pathfinder Boots next. Development preview only; no merge or launch.

Preceding Wayfarer Satchel was approved and granted to the founder inventory; ownership verified, coin balance and equipped items unchanged.

## Wayfarer Satchel equipped-art upgrade — 2026-09-30 America/Chicago

Founder authorized the remaining gear pass, starting with the Wayfarer Satchel, and reconfirmed detailed 64-bit-style equipped art. Replaced its canvas placeholder with transparent illustrated olive canvas, leather trim, brass buckle/rings and rolled map. Registered a separate shoulder strap to the upper-right ring and body-specific bag placements. Shared cloak-aware forearm restoration preserves natural hand overlap in open outfits and keeps hands hidden beneath closed cloaks. Updated its shared 16-bit Market/Inventory icon to match the olive/leather/map palette. Wanderer restriction, 160-coin price, back slot, ownership and equipped state are unchanged. Built-in generation prompt and source details: `docs/art/WAYFARER_SATCHEL.md`.

Verified code build `f12473e122536fac67499d943fa8165a662ec76a`: Flutter Check 36816403718 and Preview 36816403711 passed. Locked asset verification passed. Browser inspected male, female and neutral in open Wanderer outfits and Moss Cloaks; bag/strap removal and restoration passed. Visual QA used normal pointer interaction; accessibility-enabled browser automation was unreliable and was not counted as a verified accessibility test. Review `?review=wayfarer&rev=f12473e`; proof `wayfarer-satchel-fit.jpg`. Founder design review pending. Annotated Grimoire and Pathfinder Boots remain next. Development preview only; no merge or launch.

## Moss Moth golden particles — 2026-09-30 America/Chicago

Added fourteen staggered gold motes and stepped star sparkles around the equipped Moss Moth. Wing-dust drifts outward/downward and fades, sharing the existing hover clock and reduced-motion/offscreen pause. Sprite and inventory icon assets are unchanged.

Verified build `a8dec4b5b4dd70eeaeb1ffda13d1f1f6338bea99`: Flutter Check 36815650283 and Preview 36815650276 passed. Browser inspected moving particles beside the full Wanderer outfit in avatar and Hearth views at normal size. Captured multiple live phases and proof `moth-golden-magic.jpg`. The previous build's update notice appeared; its Refresh Questwell button correctly loaded the new revision. Development preview only; no merge or launch.

## Full outfit and stale preview correction — 2026-09-30 America/Chicago

Founder approved the Moss v2 collar and requested both cloaks in inventory; both grants completed with ownership and coins preserved. A subsequent phone screenshot showed the pre-closed-cloak sleeves and collar. Current Home and Adventurer share the same renderer; the screenshot is consistent with an older loaded app build, not a separate Hearth renderer.

Emerald Scarf now draws beneath an equipped closed cloak so it cannot cover the leaf clasp. Added a full Wanderer/scarf/satchel/brooch/moth fixture at `?review=cloaks&outfit=wanderer&rev=914d2db`. No account equipment changes were made for this fix. Approved art and base/class assets remain unchanged.

The preview now publishes a revision manifest and checks for updates at startup, on returning to the app, and every minute while visible. A newer deployment offers an explicit refresh; it never interrupts unsaved work automatically. Refresh preserves the current route. Only this app's legacy Flutter service worker registration is retired; account storage is untouched. An old tab must open the current build once to receive this update-checking code.

Verified build `914d2db47e2fbbf9951796262c0d9b5d0ca17709`: Flutter Check 36815097513 and Preview 36815097522 passed. Four update-handler tests cover explicit refresh, preserved routes, scoped worker retirement, dismissal, offline/invalid manifests, and visibility changes. Full-outfit layering regression checks run on all three bodies. Browser inspected male, female, and neutral Wanderer with the full accessory set and the male Hearth scene; clasp clear, hands covered, satchel retained. Main app's deployed revision was verified at `?rev=914d2db`; browser is signed out, so outfit QA used the shared-renderer fixture. Proof: `wanderer-cloak-fixed.jpg`. No merge to flutterflow or launch.

## Moss Cloak collar redraw — 2026-09-30 America/Chicago

Founder reported the Moss collar still looked wrong after the closed-drape change. The original bitmap had horizontal folds across its neck opening; clipping could not resolve that art defect. Used built-in image-generation edit mode to redraw the neckline as a clean V meeting a single leaf clasp, with a short joined wool section below it. New versioned asset: `assets/images/questwell_moss_cloak_v2.webp`. Equipped hand-coverage/swap rules and Hearthguard remain unchanged. Full prompt and provenance are in `docs/art/CLOAK_ART.md`.

Verified development build `3d166a2c38d032c0e28d2c912e89196bc7fbbf6f`: Flutter Check 36813840313 and Preview 36813840360 passed. Browser inspected the Moss collar on female, male, and neutral in avatar/Hearth views, plus enlarged female neckline proof. The shirt collar is visible within the V as a continuous underlayer; the old crossing green bars are gone. Review: `?review=cloaks&rev=3d166a2`. Founder visual approval pending; no merge or launch.

## Closed cloaks and handheld equipment rule — 2026-09-30 America/Chicago

Founder authorized cloaks covering the hands with no simultaneous carried item. Both cloak renders now keep arms and hands beneath continuous cloth; a body mask preserves approved head/hair/neck and legs. Satchel overlap uses the same class mask, so bags cannot restore an exposed arm. Stale conflicting render maps suppress held art while a cloak is present. Artwork files and 16-bit icons remain unchanged.

Market and Inventory load fresh equipment before a named swap confirmation. Cancel keeps the loadout. The new authenticated `equip_cosmetic_loadout` RPC checks the expected conflicting item under the profile row lock, then atomically equips the requested item and removes incompatible cloak/hand gear. The existing equip RPC also enforces incompatibility for older clients. Other categories, ownership, and coins are preserved. No existing conflicting loadouts were found; no founder equipment was changed.

Idempotent database change: `tool/qa/closed_cloak_loadout.sql` (applied). Synthetic authenticated verification: `tool/qa/closed_cloak_loadout_check.sql` passed before and after applying, testing both cloaks, both directions, unconfirmed/stale swaps, legacy enforcement, unrelated equipment, and unchanged balances/ownership. All fixture writes rolled back. Advisor check found no new function/security findings; existing leaked-password-protection warning remains outside this change.

Verified development build `98bceba948cc631596e7b9eb4c6a91b367538ba4`: Flutter Check 36812933068 and Preview 36812933124 passed, including closed-hand masks, stale held-art suppression with satchel, conflict policy, dialog cancel/confirm, and supported cloak/class/body render coverage. Browser inspected both garments across all three bodies in avatar/Hearth views. Preview cancel, cloak-to-lantern, and lantern-to-cloak confirmation flows passed. Review: `?review=cloaks&rev=98bceba`, with Try holding a lantern. Founder visual approval pending; no merge, external beta, or launch.

## Cloak contour correction — 2026-09-30 America/Chicago

Founder requested correction of the harsh neck band, cut-out sleeve transitions, and competing inner hem. Replaced the horizontal neck cutoff with a skin-following curved opening. Upper sleeves now remain below the capelet; only lower forearms restore above the cloth. Removed the synthetic shoulder fade/shadow. The inner class coat now ends within a curved knee/calf silhouette, hiding its outer gold corners near the boots.

Verified development build `2c77a41a504595f7a852203cea7863d7d5b85bbc`: Flutter Check 36811842575 and Preview 36811842602 passed. Mask checks cover restored neck skin, excluded shirt collar, upper sleeve depth, preserved cuffs, and tucked hem. Browser inspected both cloaks on all three bodies in avatar/Hearth views, plus an enlarged neckline capture. Review: `?review=cloaks&rev=2c77a41`. Founder visual approval pending; no merge or launch.

## Cloak underlayer and neckline correction — 2026-09-30 America/Chicago

Founder identified class shoulder trim protruding beside the cloaks and a stray band directly below the neck. Added an equipped-cloak-only class underlayer mask that suppresses original lapels/epaulettes on front and rear class layers while retaining torso and sleeves. Reduced the restored head region to stop the original shirt collar painting across the outer cloak collar. Moss retains its own folded hood; Hearthguard retains its standing collar.

Verified build `9c75bd16527501f3b99e4ea700149cb87f6565af`: Flutter Check 36811239939 and Preview 36811239886 passed. New mask checks cover both shoulder tips, competing collar, visible torso/cuffs, and the removed shirt strip; existing 18 cloak/class/body combinations and removal remain covered. Browser inspected both cloaks on all three bodies in avatar and Hearth views, confirming hidden shoulder trim and clear outer collars. Review: `?review=cloaks&rev=9c75bd1`. Founder visual approval remains pending; no merge or launch.

## Cloak shoulder and hem polish — 2026-09-30 America/Chicago

Founder approved a refinement pass on the corrected fit. Softened sleeve emergence with a short alpha blend and subtle contact shadows. Tapered the hem by 7% with a 1.2-pixel lateral drape, keeping neckline registration, full embroidery, and boot clearance. Artwork and icons are unchanged.

Verified development build `433f8228e16e7e4dd5213aa1a2ec97c54edb8ae0`: Flutter Check 36810444631 and Preview 36810444494 passed, including frozen asset integrity and existing cloak render/removal coverage. Browser inspected both garments on all three bodies in avatar and Hearth views. Review: `?review=cloaks&rev=433f822`. Founder visual approval pending; no merge or launch.

## Cloak wrapping correction — 2026-10-01 UTC

Founder rejected the first cloak fit: garments did not wrap or sit correctly. Replaced the disconnected front shoulder treatment with continuous front drapes, restored the original head/forearms/class sleeves above the fabric, and narrowed/centered registration for each body. Existing handheld accessories draw above the new garment layers.

**Development build:** `f0b91a805aff2860f69233043766f56b1e04a7f3`. Flutter Check `36809650001` and Preview `36809649944` passed, including the cloak render/removal and foreground-mask checks. Browser inspected both garments on female, male, and neutral in avatar and Hearth views. Shoulder-to-hem fabric continuity, exposed hands, centered neckline, and boot clearance verified. Review: `?review=cloaks&rev=f0b91a8`. Founder visual approval remains pending. No merge or launch.

## Moss Cloak and Hearthguard Mantle fit review — 2026-09-30

Replaced the two basic vector cloaks with detailed illustrated retro fantasy garment layers: moss wool with leaf embroidery/brass clasp, and burgundy Hearthguard with shield/hearth motifs. Long drapes sit behind the unchanged class outfit; front capelets follow the shoulder hems. Body-specific registration supports female, male, and neutral. Market/Inventory icons, prices, class restrictions, ownership, and approved avatar assets remain unchanged.

**Development build:** `1f8d86445982bc4ade44d58d9ee995fa37a101fb`. Flutter Check `36808923953` and Preview `36808923990` passed. Frozen avatar integrity verifier passed. New render coverage checks all 18 supported cloak/class/body combinations and removal. Browser checked all six garment/body fits and their Hearth rendering. Transparent central openings, visible hands, and boot clearance verified.

Review: `?review=cloaks&rev=1f8d864`. Founder visual approval pending; no merge or launch. Generation prompts and registration notes: `docs/art/CLOAK_ART.md`. Next remaining gear: Wayfarer Satchel, Annotated Grimoire, Pathfinder Boots.

## Market Home arrow — 2026-09-30

Added a persistent gold left arrow with a Home label above the Market. It navigates directly to HomePage through GoRouter, including direct Market entry, and remains available during scrolling, loading, and errors. Uses a 48-pixel touch target and Go home tooltip. Shared button is also shown in the sample Market, where it opens the sample Home.

**Development build:** `6d3f27ce90656d25570a144322a434761a82ccda`. Flutter Check `36808124753` and Preview `36808124824` passed. Browser confirmed the visible arrow and sample Home navigation. Authenticated production-route destination verified in code; no account interaction required. No merge or launch.

## Dragon smoke and animated Rainy Window — 2026-09-30

Added a small three-puff smoke exhale at the dragon's nose, with upward drift, expansion, fading, and a pause between bursts. Smoke follows the existing breathing transform. Rainy Window now animates falling streaks and slower sliding beads within the registered glass panes. Wooden mullions and room artwork stay still. Reduced motion hides smoke and retains static rainy glass; hidden routes stop both timers.

**Development build:** `e977695c942263cdcd930513ef92b6c618be7162`. Flutter Check `36807592855` and Preview `36807592810` passed, including raster movement/mask checks and reduced-motion/inactive/unequip behavior. Browser verified nose placement, visible smoke, and rain confined to the glass. Captured a 6.5-second animated review. `?review=companions&rev=e977695` shows both effects with toggles.

Founder also requested Rainy Window in her inventory. Idempotent founder grant confirmed owned, not automatically placed, with 79 coins unchanged. Place via Inventory → Room → Rainy Window → Window alcove. No merge or launch.

## All familiars in Market and founder inventory — 2026-09-30

Founder requested all seven familiars in the Market with 16-bit icons and in her inventory. The six existing shop entries remain active. Emerald Dragon is now an epic all-class familiar at 320 coins, with a dedicated 32-pixel icon shared by Market and Inventory and detailed equipped artwork. Granted all seven missing ownership records as founder grants, preserving equipment and coins (79). Existing class-specific equip rules remain in force.

**Development build:** `4b9b553169c44bfcf95864f4a22214cb5a00daa5`. Flutter Check `36806853312` and Preview `36806853289` passed. Catalog coverage checks all 30 shop items, including seven familiars, with unique nonempty icons and equipment routes. Database read-back confirmed seven owned familiars; authenticated dragon equip/unequip and slot checks passed with rollback. Browser verified the dragon Market listing and 16-bit icon. An earlier preview-catalog comma error was fixed before deployment.

Repeatable catalog seed: `tool/catalog/emerald_dragon.sql`. Inventory account identifiers stay out of repository documentation. Development preview only; no merge or launch. Remaining five gear designs are the next art set.

## Detailed familiars and Emerald Dragon review — 2026-09-30

Founder approved the stronger Market motion and requested the remaining equippable gear/familiar art before Boss Battles, in detailed 64-bit retro fantasy style. Six existing familiars now render dedicated transparent equipped sprites while their Market/Inventory icons remain 16-bit. Added the requested Emerald Dragon as the default companion review candidate.

Development preview: `?review=companions&rev=3923e33`. All seven can be tried on with female, male, and neutral bodies and viewed in the Hearth. Ground companions have a fixed boot baseline; moss moth hovers. Idle motion respects reduced motion and inactive screens. Dragon is a design preview, not yet a priced Market item. No database, class-lock, price, ownership, approved avatar, or room-art changes.

**Development build:** `3923e33b2b87197d42b5cd9313ee954e7962f8f3`.
Flutter Check `36806039882` and Preview `36806039936` succeeded. Automated coverage checks all seven familiars across three body types and reduced-motion/route muting. Browser review confirmed dragon and glass-slime transparency, body switching, avatar and Hearth placement.

Visual approval pending. Next art set: Moss Green Cloak, Hearthguard Mantle, Wayfarer Satchel, Annotated Grimoire, Pathfinder Boots. See `docs/qa/GEAR_FAMILIAR_REVIEW.md`. Development preview only; no merge, external beta or launch.

## Stronger Market motion and simpler balance — 2026-09-30

Founder requested less-subtle animation and removal of the #/# collected count.
The header now shows only the centered coin balance. Lanterns have a stronger,
slowly expanding warm glow and taller swaying pixel flames. Both potions have
two staggered rising bubbles and a more visible shimmer. Reduced-motion support,
steady storefront/sign, and confirmed purchase behavior remain intact.

**Development build:** `eb85ef876f36db36311560f77731f377517dadda`.
Flutter Check `36804660529` and Preview `36804660563` passed. Browser
review confirmed stronger light/flame and potion motion, centered coins, and
no collected count in the header. Animated browser capture saved for review.
Development preview only; no merge, external beta or launch.

## Market motion visibility correction — 2026-09-30

Founder could not perceive the initial ambient animation. Increased the slow
lantern glow range, added a small moving flame inside each lamp, and replaced
the sparse glint with alternating potion bubbles every three seconds. The
sign and storefront remain fixed. Reduced-motion and route muting still apply.

**Development build:** `ff5d073ffe40cd5b215d9b46ffecd9465a2a04ed`.
Flutter Check `36804012653` and Preview `36804012675` passed. Browser review
confirmed stronger glow/flame changes and a visible rising potion bubble.
A short animated browser capture accompanies the review. Reduced motion
remains respected. No merge, external beta or launch.

## Market animation pass — 2026-09-30

Founder approved the cleaned-up Market controls at 8:52 p.m. America/Chicago,
then approved gentle lantern flicker, occasional potion glints, and purchase
feedback. The storefront/sign remain still. Ambient paint accents stop for
reduced-motion settings and muted routes. Confirmed ownership transitions
trigger a short gold card glow; balance updates ease to their confirmed value
without announcing intermediate values to assistive technology. Reduced motion
shows final values immediately and removes decorative motion. Purchase success
messages say the item was added to inventory.

**Development build:** `959f0ace5171fd430c67b8094b7b15469d50fbe5`.
Flutter Check `36803484709` and Preview `36803484849` passed. New tests verify
ambient stop/resume, muted routes, intermediate/final coin values, confirmed
ownership glow, no glow without ownership changes, and reduced-motion behavior.
Browser frames confirmed localized lighting changes; sample purchase moved
650 to 560 coins and two to three owned items. No founder account was changed.
Development preview only; no merge, external beta or launch.

## Market browsing controls — 2026-09-30

Founder-approved shopfront retained. Search and filters now share one compact
forest-green panel. Categories occupy a horizontally scrolling text-tab row
with a gold selection underline. The three availability/ownership filters use
explicit green/gold styles and 44 px minimum touch targets; they wrap when
large text requires it. Added clear search. Existing category, class, price,
ownership and purchase logic is unchanged.

**Development build:** `eaf249a2f94d92cb2df07508227006c7c4be5052`.
Flutter Check `36802775839` and Preview `36802775787` passed. The 320 px /
160% text test now verifies reaching Effects, returning to All, and purchasing
a searched item. Browser review passed at 320 and 390 px. Development only;
no merge, external beta or launch.

## Market shopfront balance — 2026-09-30

Founder rejected the primitive storefront, then requested a middle ground
after seeing the ornate illustrated direction. The new v3 uses a compact
2:1 pixel-art façade with a draped green awning, warm lanterns, a simple brass
and walnut sign, and a few potions, books, and crystals. The real MARKET label
is fitted to the sign; tagline, coins, filters, and equipment stay unchanged.
Founder approved this shopfront at 8:45 p.m. America/Chicago on September 30,
2026 ("I like it") and requested cleanup of the controls beneath it.

**Development build:** `4491a21975cd16aca2aa885ea73cbd85f7383f07`.
Flutter Check `36802061217` and Preview `36802061193` passed. Existing
320 px enlarged-text layout coverage passed; browser review confirmed the
illustration loaded and the live title fits the sign. No merge or launch.
Art provenance and prompt: `docs/art/MARKET_SHOPFRONT_V3.md`.

## Fantasy Market shopfront — 2026-09-30

Founder requested a shopfront header in the fantasy / retro style. Replaced the
plain header with a responsive native pixel-art façade: forest-green and
parchment awning, timber framing, lit display windows, brass lanterns, and a
hanging walnut MARKET sign. The title remains real accessible text; the
original tagline, coin balance, and collected count remain below the façade.

**Development build:** `0b38dcb72783d8f7d9e30fecc65181d68957769f`.
Flutter Check `36801258007` and Preview `36801258048` passed, including the
320 px / 160% text Market test. Browser review confirmed the façade and text
at 320 and 390 px. Artwork is ready for founder review. Development preview
only; no merge, external beta or launch.

## Market title refinement — 2026-09-30

Founder requested one pixel-style “MARKET” heading with the original tagline
directly underneath. Removed the stacked emporium label and repeated title;
kept the header card, coins, filters, and item layout. The page app bar keeps
back navigation without repeating the heading.

**Development build:** `f5bc79683193243c7bc9d2f87063b0b131c02d0e`.
Flutter Check `36800340600` and Preview `36800340603` passed. Browser
review confirmed the single heading and preserved tagline. Development only;
no merge, external beta or launch.

## Typography review — 2026-09-30

**Development build:** `04c1c0b5be19488afce9055b61cfb75df9b39d18`.
Market, Adventurer / Inventory, and Chronicle now share a Roboto body style.
Pixel section headings remain. Market item titles use 17 px bold text,
descriptions use 14 px text with 1.4 line height, and controls use explicit
Roboto styles. Chronicle event labels and timestamps are now 12 px; filters
use 14 px. The restored Market tagline and approved design remain.

**Verified:** Flutter Check `36799787259` and Preview `36799787267` passed.
Existing Market, Inventory, and Chronicle layout tests cover 320 px screens
with 160% text scaling. Browser review confirmed Market at 320 and 390 px,
Chronicle, and Inventory cards. No layout overflow observed.

**App:** https://funszdidiot.github.io/questwell-app/?rev=04c1c0b

Development preview only; no merge to `flutterflow`, external beta or launch.

## Market equipment and icons — 2026-09-30, 8:02 p.m. America/Chicago

**Development build:** `25a0f104fbc6d4c0466d602338d55d9ae189948d`.
All 29 active Market items have equip/place renderers. Shared 16-bit-style
icons now appear in Market and Inventory. The shop has search, category and
ownership filters, try-on previews, purchase confirmation, equip and placement.
The founder likes the new design and requested the former tagline; restored
“Rare finds, class gear, and questionable fashion choices.”

**Verified:** Flutter Check `36798907024` passed all 123 tests and analysis;
Preview `36798907027` deployed successfully. 105 database purchase/equip/unequip
cases passed across five synthetic class accounts in a rolled-back transaction.
All locked avatar asset checksums pass. Browser review confirmed new icons,
companion purchase and equip, cloak fit, rain aligned to the existing window,
and the restored tagline. No founder
coins, ownership or equipment were changed by these checks.

**App:** https://funszdidiot.github.io/questwell-app/?rev=25a0f10

**Sample shop:** https://funszdidiot.github.io/questwell-app/?review=market&rev=25a0f10

See `docs/qa/MARKET_EQUIPMENT_REVIEW.md`. New item artwork is available for
founder review; the design feedback is not blanket approval of every new fit.
No merge to `flutterflow`, external beta or launch.

## Founder acceptance and Chronicle work — 2026-09-30

At 7:17 p.m. America/Chicago, the founder confirmed “Everything is good to go”
after the milestone flow and mantel review. Treat the prior device/session gates
as founder-confirmed; this is not an additional automated Safari test.
The accepted First Journey mantel perspective is implemented at `d75930e`.
The Orrery is active in the development catalog and the founder account has a
`founder_testing_grant` copy, with level and coins unchanged.

**Current work:** Chronicle visual overhaul. A compact leather-style summary,
local-date journal pages, actual trophy artwork, event-specific labels and
filters replace the old oversized decorative scene. “Show earlier pages” keeps
history beyond 30 entries accessible. Loading and error states retain a way back
to the Hearth. Review fixture: `?review=chronicle` (synthetic history).

**Verified implementation:** `917a8329c0c556b5d40d4db41c6f037432f73f13`.
Flutter Check `36795837785` and Preview `36795837810` succeeded. The journal tests
cover 320 px enlarged text, filtering, and access to history after 30 entries.
Browser review passed at 320 and 390 px with the actual Chronicle widget using
sample history: all entries, milestone filter, and empty journal.
**Review state:** Founder approved the Chronicle design at 7:29 p.m.
America/Chicago on 2026-09-30 (“It’s good”). Visual review is complete;
no merge, external beta or launch is authorized.
**Hold:** Development preview only. No merge, external beta or launch authorized.

## Continuation checkpoint — 2026-09-30

**Current task:** Level-10 Starlit Orrery milestone verification, following the
level-5 First Journey reward and simplified Hearth. Implementation commit:
`16b01c781d682229d3c605b56f373013cb184061` on `questwell-dev`.

**Verified:**
- Questwell Flutter Check run `36792304091`: success.
- Questwell Preview run `36792304186`: success.
- Migration `20260930233919_starlit_orrery_milestone` is applied.
- `tool/qa/starlit_orrery_check.sql` passed against the connected project using
  synthetic accounts in a rolled-back transaction: task and boss level-10
  unlocks; no trophy coin charge; ownership and Chronicle timestamp; duplicate
  protection; confirmed replacement; bookcase support, move, removal and deletion;
  mantel independence; client level-change and early-equip restrictions.
- Browser visual review: Orrery renders on the bookcase and mantel; the level-10
  celebration shows artwork, reward totals, Keep in inventory and Place in Hearth.
- Existing Flutter checks include 320/390 px trophy placement, a 320 px dialog
  with enlarged text, skipped milestone crossings, and both trophies in one room.

**Preview:** https://funszdidiot.github.io/questwell-app/?review=starlit-orrery&rev=16b01c7

**Remaining:** Founder iPhone Safari review and signed-in browser validation of
complete quest → XP → unlock → place → refresh. Database tests and an account-free
visual fixture do not substitute for that full device/session check.

**Release hold:** No merge to `flutterflow`, external beta or launch is authorized.
The existing development preview is available for review. Prior founder-check
history also records unresolved leaked-password protection on the Free plan;
this turn did not change or re-audit that setting.

The sections below retain historical art checkpoints. Their older active-task
and “Not Started” labels are superseded by this checkpoint for milestone,
collection and Chronicle work; they do not imply current promotion approval.

## Current state

**Hearth visuals:** Founder approved the cleaner room, woven rug, boot shadows,
and warmer lighting on 2026-09-29 (“It’s good”), at `51f7f9b`.
Saved-avatar account persistence remains an unverified manual gate.

**Quest Board:** Pinned-paper design approved by the founder on 2026-09-29 (“I love it”), at `4960b14`. Signed-in validation is now in progress.
First pass prioritizes daily task access, readable cards, pinned priorities,
server-confirmed completion rewards, and an account-free `?review=quests` fixture.
No merge to flutterflow or launch authorized.

**Robe construction:** ✅ Founder accepted `robe-wrap-v1` on 2026-09-29
and directed “Ok! Let’s do wanderer.” Guardian, Scholar, Scout and Alchemist
retain their accepted three-layer construction across all three bodies.
**Wanderer:** ✅ Founder approved and frozen as `wanderer-approved-v1` (artwork `wanderer-v2`) — tobacco-brown/copper-gold travel
coats with compass stitching, three independent fits and continuous ochre rear lining.
See `docs/qa/WANDERER_FIT_REVIEW.md` and `wanderer-fit-review.html`.
All five class robe sets are accepted across all three body types. Founder approval: “Perfect.”
No production promotion or launch.

**Scholar visual template:** ✅ Founder approved and frozen, 2026-09-29.
All three body variants use `scholar-approved-v1`, anchored to source commit
`71f6f5d38315155222ce6832ea6fc6ee12b13be0`. Asset and fit-input checksums guard
the accepted reference.
This supersedes the historical Scholar candidate/pending notes below; it does
not promote Epic 2 or authorize merging to flutterflow or launching.

**Scout fit:** ✅ Founder approved and frozen as `scout-approved-v1`, 2026-09-29.
Three independently fitted forest-green/gold coats now use the shared 240 × 320
canvas, compact cuffs, clean piping and Scout-specific jacket coverage. Portrait
and card composites have been inspected; founder accepted the current three-body
set after app delivery.
See `docs/qa/SCOUT_FIT_REVIEW.md` and `scout-fit-review.html` in the preview.

**Alchemist fit:** ✅ Founder approved and frozen as `alchemist-approved-v1`, 2026-09-29.
Approved artwork: `alchemist-lab-v4`, source commit
`0198dc8710ac11a44c5527bd06e293a68a7b652b`. Approval covers all three body variants.
Founder rejected revision 2's fit. Revision 3 repairs the continuous hip/thigh
contours and adds an actual-image test for exposed outer trouser edges.
Revision 4 follows the requested consistency pass: matching snaps, pockets and
chemistry embroidery; smoother waist piping; slimmer cuffs and silver edging.
The three independent body fits retain the corrected trouser coverage.
Three sapphire-blue/silver laboratory coats with neon-green accents follow the founder’s request
for a stronger science/chemistry identity and color distinction from Scout.
The beaker/flask emblems are removed. Body-specific fitting, jacket coverage
and portrait/card rendering are wired.
Founder accepted the set with “Good to go.” See `docs/qa/ALCHEMIST_FIT_REVIEW.md`.

**Guardian fit:** ✅ Accepted 2026-09-29 with the rear-wrap review and founder direction to proceed to Wanderer. Female uses `guardian-v3`; male and neutral retain `guardian-v2`.
Founder flagged the female viewer-right arm and hip after revision 2. Revision 3
smooths the elbow/forearm and waist-to-hip contours through a female-only local
fit. It preserves wrist contact, front piping, the base avatar and the male and
neutral revision-2 garments. Actual-image checks now cover abrupt side-contour
steps as well as trouser coverage and waist piping.
Founder rejected v1’s uneven gold lines. Revision 2 removes branching borders,
uses one isolated chevron per lower panel and locally fits the piping to smooth
waist paths with consistent gold width. Three independent body fits retain
compact cuffs, continuous thigh coverage and Guardian-specific jacket occlusion.
Actual-image tests check waist clearance and line width. All frozen templates
are preserved.
See `docs/qa/GUARDIAN_FIT_REVIEW.md` and `guardian-fit-review.html`.
Guardian is frozen; Wanderer is the current class workstream.

**Active workstream:** Epic 7 — Chronicle / Achievement visual overhaul  
**Development branch:** `questwell-dev`  
**Promoted/app branch:** `flutterflow`  
**Last promoted milestone:** Epic 1 — Modular Avatar Foundation  
**Last promoted commit:** `b7635f870a1aad39a4a687fe19d5ea8a61659bb8`

## Epic tracker

| Epic | Scope | Status |
|---|---|---|
| 1 | Modular Avatar Foundation | ✅ Promoted |
| 2 | Hearth Visual Overhaul | 🧪 Testing |
| 3 | Quest Board Redesign | 🧪 Development review |
| 4 | Adventurer / Inventory Overhaul | ⚪ Not Started |
| 5 | Market Overhaul | ⚪ Not Started |
| 6 | Boss Battles Overhaul | ⚪ Not Started |
| 7 | Chronicle / Achievement Overhaul | ✅ Visual design approved; unmerged |
| 8 | Campfire / Expedition / Secondary Modes | ⚪ Not Started |
| 9 | Global UI / FX Polish | ⚪ Not Started |
| 10 | Cross-Platform Validation | 🟡 Ongoing |

## Epic 1 — Modular Avatar Foundation

**Status:** ✅ Promoted

Completed:
- Web-safe Adventurer asset pipeline
- Dark round glasses layer
- Emerald scarf layer
- Leather satchel layer
- Shared live avatar rendering across Hearth and Adventurer / Inventory
- Market cosmetic previews upgraded
- Character-free Hearth preserved
- Flutter Check passed
- Questwell Preview passed
- Merged through PR #3

## Epic 2 — Hearth Visual Overhaul

**Status:** Visuals accepted; saved-avatar persistence verification pending

Target:
- Keep the Hearth environment character-free
- Keep the live Adventurer as the only primary character focal point
- Improve avatar scale and placement
- Improve floor contact and grounding
- Improve scene lighting integration
- Improve environmental depth and prop balance
- Refine HUD integration
- Improve mobile framing
- Validate visual cohesion against the founder-approved 64-bit benchmark

**Current implementation checkpoint:**
- Hearth environment moved onto the web-safe Flutter asset pipeline
- Avatar enlarged and lowered for stronger room integration
- Ground contact/shadow moved behind the Adventurer
- Warm environmental light, depth motes, floor glints, and edge vignette added
- Hearth location plaque integrated into the scene
- Mobile scene proportions adjusted independently from desktop
- Hearth page background now transitions from cool upper-room tones into warm lower-room tones
- Adventurer focal scale increased with stronger floor-light and grounding treatment
- Compact in-scene archetype/loadout HUD added without competing with the character focal point
- Foreground silhouette layers added to increase room depth and parallax
- Perspective Hearth rug and class-accent floor ornaments added to ground the scene
- Ember clusters and low foreground furniture shapes added for environmental storytelling

**Typography checkpoint:**
- Questwell wordmark remains unchanged
- Supporting copy, descriptions, helper text, and subheaders standardized on Roboto across core screens
- Section headers standardized on Press Start 2P, a commercially usable pixel font under the SIL Open Font License 1.1

**Founder checkpoint #1 (iPhone Safari): NEEDS POLISH**
- Technical rendering is stable, but the visible Hearth scene was too dark in the lower half
- Several visible Hearth section/status titles were still using Roboto rather than the pixel header standard
- Follow-up pass reduces overlay/vignette darkness and completes visible Hearth header typography before reinspection

**Avatar root-fix checkpoint:** IN PROGRESS
- Added profile-level base avatar choice: Male, Female, or Gender Neutral
- Added three richer transparent business-suit base avatars on a shared 240×320 production canvas
- Business suit remains the pre-class base outfit
- Hearth and Adventurer now consume the same selected base-avatar state
- Legacy low-fidelity equipment overlays are intentionally withheld from the live rich avatar until they are rebuilt against the new shared canvas
- Existing ownership/equip state is preserved; this pass changes rendering, not user inventory
- Acceptance gate: all three bases must render cleanly on iPhone Safari, switch persistently, share scale/baseline, and show no gray boxes or transparency artifacts

- Founder iPhone check confirmed rich base assets now load on Safari. Cleared three stale legacy equipped states, tied the active-gear count to rendered rich layers, blocked invisible legacy equips until rebuilt, and increased the main Adventurer portrait scale by 18%.

- Scholar starter class layer: founder-approved navy/gold robe art is now wired for Male, Female, and Gender Neutral base avatars. The robe renders automatically for the Scholar archetype over the business-suit base and does not consume a gear slot. Accessories remain intentionally disabled pending later progression work. iPhone Safari alignment review is required before this class layer is marked visually complete.

- Scout starter class layer: founder-approved forest-green/gold robe-only overlays are wired for Male, Female, and Gender Neutral bases. Scout keeps the business-suit base underneath and starts with 0 accessory gear slots active. Live mobile alignment review is required before Scout is marked visually complete.

- Class coat sizing standard: class clothing overlays now use the same fitted production envelope on a 240×320 avatar canvas (approximately 132×210 visual bounds, centered over the business-suit base). Scholar Male/Female/Gender Neutral have been rebuilt to this standard. Scout will use this same envelope so class changes do not alter apparent body scale.

- Avatar clothing-fit correction: measured shoulder spans and hand positions from each approved base avatar and moved class clothing to a body-specific fit transform. Head/hair and hands now render back above class clothing, so collars sit behind the character and cuffs terminate at the hands instead of swallowing them. This fit system is shared by Scholar, Scout, and all future class clothing.

- Scholar measured-fit pass: robe geometry was rebuilt against measured base-avatar landmarks rather than scaled as one costume image. Male/Female/Gender Neutral now use shoulder, elbow, wrist, waist, and hem anchors taken from the approved business-suit bodies. Live mobile review is required before this fit becomes the class-wide template.

**Exact validation checkpoint (2026-09-29):**
- `questwell-dev` head: `68ae3fdb984194c403c95808ee3471eb93b63fbb`
- Questwell Flutter Check: passed on exact head
- Questwell Preview: passed and deployed on exact head
- Remaining gate is visual, not technical: the measured Scholar robe fit and overall Hearth composition require founder review on iPhone Safari before Epic 2 can be promoted.
- No promotion to `flutterflow` will occur solely from green CI.

- Scholar anatomy-fit implementation: replaced the prior robe assets with body-constrained overlays that follow the approved base-avatar shoulder and arm silhouettes. Exposed hands are preserved, cuff width is constrained to wrist geometry, and upper-body garment pixels are limited to the measured body envelope. This pass is governed by docs/AVATAR_CLASS_FIT_SPEC.md and requires live mobile approval before becoming the reusable class standard.

**Benchmark rule:** CI success alone does not mark this epic complete.

**Scholar clean-art candidate (2026-09-29):** Founder confirmed fit improved but rejected ragged overlay quality. Added separate cleaned Scholar garments for all three body types, fitted offline to the frozen bases and exported as versioned lossless WebPs. App and review page now use the clean-art candidates. Source art and measured export geometry are preserved for reuse after visual acceptance.

**Scholar build-source fix (2026-09-29):** Found that both workflows replaced the committed body-fitted Scholar WebPs with older staged base64 art. Replaced this destructive build preparation with dimension, transparency, and checksum validation. The latest fitted assets are now the build source of truth. Local regression checks confirm preparation preserves all six base/robe files and rejects stale robe substitutions. Added a Scholar-only review page with all three body types, portrait/card sizes, and a base/robe toggle. Scholar visual acceptance remains the gate before fitting other classes.

## Release gate

Questwell is not graphics-complete until the full core experience reaches the approved high-detail 64-bit fantasy benchmark across:
- Hearth
- Quest Board
- Adventurer / Inventory
- Market
- Boss Battles
- Chronicle
- Campfire / Expedition
- mobile / Safari / web consistency

## How to track development

- `questwell-dev` = active coding
- GitHub Actions = build / preview health
- Pull requests = promotion candidates
- `flutterflow` = promoted app branch
- This file = milestone-level founder status

The dashboard should be updated whenever an epic starts, reaches testing, is blocked, or is promoted.
# Scholar detail polish candidate — 2026-09-29

Final presentation pass: main Adventurer art fills 96% of the existing portrait
frame height (was 88%); selection cards show a checkmark and expose selected
semantics. Female hairline/curl visibility restored at the clipping boundary.
Mobile layout checks cover 320, 390 and 430 px widths. Scholar art and all base
files remain unchanged. Candidate is frozen for founder review before other
class work, merge or launch.

Follow-up: founder identified suit-jacket bleed after v2. Added Scholar-only
underlayer occlusion paths for all three bodies, preserving original base and
robe bytes. The review page has an original-jacket comparison toggle. Added
targeted clip coverage/alignment tests. Founder visual acceptance still pending.

Development-only v2 polishes pendants, cuff bands, front trim and folded hem tips
for all three bodies. Selection cards now explain class previews and successful
body selection no longer obscures the art with a toast. Frozen bases unchanged.
Checklist and provenance: `docs/qa/SCHOLAR_POLISH_V2.md`. Founder review pending;
do not advance other class robes, merge to flutterflow, or launch.
