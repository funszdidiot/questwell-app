# Locked Template Registry

This file tells automation what may be reused without reopening design.

| Family | Body | Status | Canonical authority | Notes |
|---|---|---|---|---|
| Paper doll | Female | LOCKED | `docs/art/FEMALE_FIT_STANDARD.md` | Never alter anatomy for garment fit. |
| Paper doll | Neutral | LOCKED | latest canonical neutral foundation referenced by `lib/widgets/questwell_neutral_paper_doll.dart` and its fit JSON | Historical v2 is superseded. |
| Paper doll | Male | LOCKED | `docs/art/MALE_PAPER_DOLL_NECK_V3.md` | Founder locked v3 on 2026-10-03. Fit all male garments to this immutable body. |
| Robe geometry | Female | LOCKED | `docs/art/FEMALE_FIT_STANDARD.md` | Alchemist female v7 geometry; class surfaces inherit exact geometry. |
| Robe geometry | Neutral | LOCKED | `docs/art/NEUTRAL_CLASS_ROBES_V1.md` + `tool/neutral_robe_fit_reference.json` | Neutral v11 shared geometry; approved class surfaces preserve masks. |
| Everyday outfit | Male | LOCKED / AWAITING REPO INGEST | approved `male_everyday_v2` from 2026-10-03 production review | Unified single overlay on locked male v3; sleeves, crotch/inner-leg contours and both boot fits corrected. Founder approved with “It’s good. Next.” Do not regenerate; ingest exact approved artifact when available in repo. |
| Everyday outfit | Neutral | REVIEW/INTEGRATION | neutral everyday v3 docs/assets | Existing fitted asset; do not redesign unless founder rejects it. |
| Woodland Scout outfit | Female | LOCKED | `docs/art/FEMALE_FIT_STANDARD.md` | unified female v11. |
| Woodland Scout outfit | Neutral | REVIEW/INTEGRATION | neutral Scout v2 assets/review | Existing fitted asset; do not regenerate merely because runtime wiring is incomplete. |
| Grimoire equipment | All supported bodies | LOCKED METHOD | `docs/art/NEUTRAL_CLASS_ROBES_V1.md` | Belt-mounted; preserve hands. |
| Pathfinder boots | All | RETIRED | equipment policy | Never reintroduce without founder decision. |

## Lock semantics

LOCKED means automation may:
- reproduce/export the approved geometry;
- create decorative surface variants within an approved collection brief;
- run QA and integrate the approved asset.

LOCKED means automation may not:
- change silhouette, anatomy, fit anchors, openings, cuff geometry, layer order or registration;
- silently substitute an older candidate;
- declare a new geometry locked without founder approval.

When documentation conflicts, stop and reconcile the registry against the most recent explicit founder decision before producing new variants.
