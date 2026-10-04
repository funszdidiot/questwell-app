# Locked Template Registry

This file tells automation what may be reused without reopening design.

| Family | Body | Art/template status | Integration status | Canonical authority | Notes |
|---|---|---|---|---|---|
| Paper doll | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Never alter anatomy for garment fit. |
| Paper doll | Neutral | LOCKED | Runtime audit pending | `tool/neutral_avatar_fit_reference.json` | Exact neutral v4 foundation. Historical v2/v3 are superseded. |
| Paper doll | Male | LOCKED | Exact files ingested; runtime QA pending | `tool/male_avatar_fit_reference.json` + `docs/art/MALE_PAPER_DOLL_NECK_V3.md` | Founder locked v3 on 2026-10-03. All male garments must fit this immutable body. |
| Robe geometry | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Alchemist female v7 geometry; class surfaces inherit exact geometry. |
| Robe geometry | Neutral | LOCKED | Runtime audit pending | `docs/art/NEUTRAL_CLASS_ROBES_V1.md` + `tool/neutral_robe_fit_reference.json` | Neutral v11 shared geometry; class surfaces preserve masks. |
| Robe geometry | Male | NOT ESTABLISHED | QUEUED | Approved male body/everyday references below | A new concrete foundational fit needs independent QA and Tanya's template decision. Its future review does not block approved work. |
| Everyday outfit | Male | LOCKED | Exact files ingested; runtime QA pending | `tool/male_everyday_fit_reference.json` + `docs/art/MALE_EVERYDAY_V2_CANDIDATE.md` | Exact `assets/images/questwell/avatar/everyday_outfit_male_v2.webp`; SHA-256 `f1677830404354248d8fe13c1aec35da059946c7ee902ff21411dcca584b2cee`. One unchanged overlay on male v3. Founder approved “It's good. Next.” Historical candidate naming does not reopen the approval. |
| Everyday outfit | Neutral | LOCKED | Runtime audit pending | `tool/neutral_everyday_fit_reference.json` + `docs/art/NEUTRAL_EVERYDAY_V3_CANDIDATE.md` | Founder locked v3 on 2026-10-03. Preserve existing approved components and order; do not retroactively regenerate them. |
| Woodland Scout outfit | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Unified female v11. |
| Woodland Scout outfit | Neutral | CANDIDATE — NOT LOCKED | Active development; runtime QA pending | neutral Scout v2 assets/review | Existing fitted candidate is unaccepted. Retain and inspect it; do not regenerate merely because runtime wiring is incomplete. Active visual development is not an approval blocker. |
| Grimoire equipment | All supported bodies | LOCKED METHOD | Runtime compatibility checked per supported fit | `docs/art/NEUTRAL_CLASS_ROBES_V1.md` | Belt-mounted; preserve hands. |
| Pathfinder boots | All | RETIRED | Must remain absent from catalog/renderers | equipment policy | Preserve ownership history. Never reintroduce without founder decision. |

## Lock semantics

The art/template status in this registry describes immutable design authority. Production/integration lifecycle is tracked separately in `PRODUCTION_DASHBOARD.md`; a locked asset can still need QA and development deployment. Exact approved-file ingestion does not establish that all legacy class paths use the new foundation or that runtime behavior has passed.

LOCKED means automation may:
- reproduce/export the approved geometry;
- create decorative surface variants within an approved collection brief;
- run QA and integrate the approved asset.

LOCKED means automation may not:
- change silhouette, anatomy, fit anchors, openings, cuff geometry, layer order or registration;
- silently substitute an older candidate;
- declare a new geometry locked without founder approval.

When documentation conflicts, stop and reconcile the registry against the most recent explicit founder decision before producing new variants.
