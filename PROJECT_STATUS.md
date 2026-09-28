# Questwell Project Status

_Last verified: 2026-09-28_

This file is the founder-facing dashboard for the Questwell art overhaul.

## Current state

**Active workstream:** Epic 2 — Hearth Visual Overhaul  
**Development branch:** `questwell-dev`  
**Promoted/app branch:** `flutterflow`  
**Last promoted milestone:** Epic 1 — Modular Avatar Foundation  
**Last promoted commit:** `b7635f870a1aad39a4a687fe19d5ea8a61659bb8`

## Epic tracker

| Epic | Scope | Status |
|---|---|---|
| 1 | Modular Avatar Foundation | ✅ Promoted |
| 2 | Hearth Visual Overhaul | 🟡 In Progress |
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

**Status:** 🟡 In Progress

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
