# Questwell Project Status

_Last verified: 2026-09-30 (America/Chicago)_

This file is the founder-facing dashboard for the Questwell art overhaul.

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
