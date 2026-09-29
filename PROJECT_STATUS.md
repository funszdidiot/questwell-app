# Questwell Project Status

_Last verified: 2026-09-28_

This file is the founder-facing dashboard for the Questwell art overhaul.

## Current state

**Active workstream:** Epic 2 — Hearth Visual Overhaul (manual iPhone Safari visual acceptance gate)  
**Development branch:** `questwell-dev`  
**Promoted/app branch:** `flutterflow`  
**Last promoted milestone:** Epic 1 — Modular Avatar Foundation  
**Last promoted commit:** `b7635f870a1aad39a4a687fe19d5ea8a61659bb8`

## Epic tracker

| Epic | Scope | Status |
|---|---|---|
| 1 | Modular Avatar Foundation | ✅ Promoted |
| 2 | Hearth Visual Overhaul | 🧪 Testing |
| 3 | Quest Board Redesign | ⚪ Not Started |
| 4 | Adventurer / Inventory Overhaul | ⚪ Not Started |
| 5 | Market Overhaul | ⚪ Not Started |
| 6 | Boss Battles Overhaul | ⚪ Not Started |
| 7 | Chronicle / Achievement Overhaul | ⚪ Not Started |
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

**Status:** ⛔ Manual visual acceptance required before promotion

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
