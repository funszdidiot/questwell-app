# Locked Template Registry

This file tells automation what may be reused without reopening design.

| Family | Body | Art/template status | Integration status | Canonical authority | Notes |
|---|---|---|---|---|---|
| Paper doll | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Never alter anatomy for garment fit. |
| Paper doll | Neutral | LOCKED | DEV DEPLOYED — approved Everyday/five-class-robe scope (`4cfef7f`) | `tool/neutral_avatar_fit_reference.json` | Exact neutral v4 foundation. Historical v2/v3 are superseded. |
| Paper doll | Male | LOCKED | DEV DEPLOYED — dedicated fixed-body review (`4cfef7f`); account rollout QUEUED | `tool/male_avatar_fit_reference.json` + `docs/art/MALE_PAPER_DOLL_NECK_V3.md` | Founder locked v3 on 2026-10-03. All male garments must fit this immutable body. |
| Robe geometry | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Alchemist female v7 geometry; class surfaces inherit exact geometry. |
| Robe geometry | Neutral | LOCKED | DEV DEPLOYED — approved Everyday/five-class-robe scope (`4cfef7f`) | `docs/art/NEUTRAL_CLASS_ROBES_V1.md` + `tool/neutral_robe_fit_reference.json` | Neutral v11 shared geometry; class surfaces preserve masks. |
| Robe geometry | Male | LOCKED — accepted cuff condition verified | DEV DEPLOYED — exact v3 dedicated review (`31dfebe`); account rollout QUEUED | `tool/male_robe_fit_reference.json` + `docs/art/MALE_ROBE_V3_CUFF_FINISH.md` | Source `16facaf` records Tanya’s “Make the cuff edges sharper and we’re good”. Independent QA confirms the finish; preserve all four masks, registration, hand clearance and layer order. Class surfaces are next; account rollout remains queued. |
| Class robe surfaces | Male | Locked v3 geometry inherited; new surfaces in visual QA | QA — four surfaces and five-class development review | `tool/art_assets/male_class_robes_v1/exports.json` + `docs/art/MALE_CLASS_ROBES_V1.md` | Sixteen layers preserve exact v3 masks. Independent export QA passed; delivered runtime pending. No founder surface acceptance or account rollout claimed. |
| Everyday outfit | Male | LOCKED | DEV DEPLOYED — dedicated fixed-body review (`4cfef7f`); account rollout QUEUED | `tool/male_everyday_fit_reference.json` + `docs/art/MALE_EVERYDAY_V2_CANDIDATE.md` | Exact `assets/images/questwell/avatar/everyday_outfit_male_v2.webp`; SHA-256 `f1677830404354248d8fe13c1aec35da059946c7ee902ff21411dcca584b2cee`. One unchanged overlay on male v3. Founder approved “It's good. Next.” Historical candidate naming does not reopen the approval. |
| Everyday outfit | Neutral | LOCKED | DEV DEPLOYED — approved Everyday/five-class-robe scope (`4cfef7f`) | `tool/neutral_everyday_fit_reference.json` + `docs/art/NEUTRAL_EVERYDAY_V3_CANDIDATE.md` | Founder locked v3 on 2026-10-03. Preserve existing approved components and order; do not retroactively regenerate them. |
| Woodland Scout outfit | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Unified female v11. |
| Woodland Scout outfit | Neutral | CANDIDATE — NOT LOCKED | QA — explicit candidate review only; account eligibility remains female-only | neutral Scout v2 assets/review | Existing fitted candidate is unaccepted. Retain and inspect it in explicit review; do not promote it to account capability. Active visual development is not an approval blocker. |
| Woodland Scout outfit | Male | NOT ESTABLISHED | QUEUED — explicit avatar-production priority | `tool/male_avatar_fit_reference.json` governs the immutable body | No existing male Woodland candidate/provenance or fit lock was found. Build a coherent male-specific overlay without cross-body scaling; no account capability promotion is implied. |
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

## Account integration boundary

Male v3 and everyday v2 remain locked art. Their dedicated review must toggle the outfit over the same body; it must not restore legacy anatomy on removal. Account male Everyday rollout is queued until the remaining accepted fits permit a coherent same-body transition. Approved Everyday account support is female + neutral. Woodland Scout account support remains female-only; neutral Woodland is an unaccepted explicit-review candidate. These boundaries do not alter art locks or authorize catalog/economy changes.

Runtime evidence is recorded in `docs/qa/APPROVED_WARDROBE_INTEGRATION.md`: 351 Flutter tests, 8 Node tests, deployed development browser checks and scoped synthetic public-RPC verification after migration `20261004035017`. Neutral verification covers Everyday and the five class robes; legacy suits, Harvest Coats and closed cloaks remain separately queued. Browser evidence uses in-memory fixtures and does not claim real-user login/refresh persistence. No new art/template lock is established by this delivery.
