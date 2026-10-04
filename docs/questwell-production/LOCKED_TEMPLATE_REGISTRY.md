# Locked Template Registry

This file tells automation what may be reused without reopening design.

| Family | Body | Art/template status | Integration status | Canonical authority | Notes |
|---|---|---|---|---|---|
| Paper doll | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Never alter anatomy for garment fit. |
| Paper doll | Neutral | LOCKED | DEV DEPLOYED — approved Everyday/five-class-robe scope (`4cfef7f`) | `tool/neutral_avatar_fit_reference.json` | Exact neutral v4 foundation. Historical v2/v3 are superseded. |
| Paper doll | Male | LOCKED | DEV DEPLOYED — shared app verified (`958aaaf`) | `tool/male_avatar_fit_reference.json` + `docs/art/MALE_PAPER_DOLL_NECK_V3.md` | Founder locked v3 on 2026-10-03. All male garments must fit this immutable body. |
| Robe geometry | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Alchemist female v7 geometry; class surfaces inherit exact geometry. |
| Robe geometry | Neutral | LOCKED | DEV DEPLOYED — approved Everyday/five-class-robe scope (`4cfef7f`) | `docs/art/NEUTRAL_CLASS_ROBES_V1.md` + `tool/neutral_robe_fit_reference.json` | Neutral v11 shared geometry; class surfaces preserve masks. |
| Robe geometry | Male | LOCKED — accepted cuff condition verified | DEV DEPLOYED — shared app verified (`958aaaf`) | `tool/male_robe_fit_reference.json` + `docs/art/MALE_ROBE_V3_CUFF_FINISH.md` | Source `16facaf` records Tanya’s “Make the cuff edges sharper and we’re good”. Preserve historical masks and registration. Newer explicitly requested sleeve/thumb repair is separately versioned below; it does not create a new lock. |
| Class robe surfaces | Male | Historical v3 geometry inherited; foreground surface QA passed | DEV DEPLOYED — five-class review and requested rear repair (`7cc9030`) | `tool/art_assets/male_class_robes_v1/exports.json` + `docs/art/MALE_CLASS_ROBES_V1.md` | Original sixteen layers remain unchanged. 363 Flutter + 8 Node tests, 28 delivered hashes and runtime/independent visual QA passed. No founder surface acceptance or account rollout claimed. |
| Robe rear lining repair | Male | Founder-requested development repair; NOT NEWLY LOCKED | DEV DEPLOYED — independent export and delivered runtime QA passed (`7cc9030`) | `tool/male_robe_thumb_repair_reference.json` + `docs/art/MALE_ROBE_THUMB_REPAIR_V1.md` | Five versioned rear layers close thumb/lower-hand gaps behind intact hands. Historical v3, body, identity, Everyday and all foreground layers preserved. |
| Everyday outfit | Male | LOCKED | DEV DEPLOYED — shared app verified (`958aaaf`) | `tool/male_everyday_fit_reference.json` + `docs/art/MALE_EVERYDAY_V2_CANDIDATE.md` | Exact `assets/images/questwell/avatar/everyday_outfit_male_v2.webp`; SHA-256 `f1677830404354248d8fe13c1aec35da059946c7ee902ff21411dcca584b2cee`. One unchanged overlay on male v3. Founder approved “It's good. Next.” Historical candidate naming does not reopen the approval. |
| Robe sleeve/thumb depth repair | Male | Founder-requested correction; NOT NEWLY LOCKED | DEV DEPLOYED — five shared-app classes verified (`958aaaf`) | `tool/male_robe_edge_repair_reference.json` + `docs/qa/MALE_ROBE_EDGE_REPAIR_V2.md` | New sleeve RGB retains exact front alpha. Garment-only occlusion hides trouser slivers behind intact thumbs. 373 Flutter + 8 Node tests, 23 delivered hashes, all-five appearance and Everyday equip/Hearth/unequip verified. |
| Everyday outfit | Neutral | LOCKED | DEV DEPLOYED — approved Everyday/five-class-robe scope (`4cfef7f`) | `tool/neutral_everyday_fit_reference.json` + `docs/art/NEUTRAL_EVERYDAY_V3_CANDIDATE.md` | Founder locked v3 on 2026-10-03. Preserve existing approved components and order; do not retroactively regenerate them. |
| Woodland Scout outfit | Female | LOCKED | Existing integration; unchanged this session | `docs/art/FEMALE_FIT_STANDARD.md` | Unified female v11. |
| Woodland Scout outfit | Neutral | CANDIDATE — NOT LOCKED | DEV DEPLOYED — explicit v3 review verified (`9934335`); account eligibility remains female-only | `tool/repair_neutral_woodland_v3.cjs` + `docs/qa/NEUTRAL_WOODLAND_V3_DELIVERY.md` | Exactly 17 scoped hand/heel garment pixels repaired; locked v4 body/identity unchanged. Ten delivered hashes, four-stage detail/off/on/reload and Market restriction verified. No new independent v3 visual signoff or founder lock. Active visual development is not an approval blocker. |
| Woodland Scout outfit | Male | CANDIDATE — NOT LOCKED | DEV DEPLOYED — fixed-body review (`0330c3b`); account rollout remains queued | `tool/male_woodland_fit_reference.json` + `docs/art/MALE_WOODLAND_V1.md` | One coherent overlay on immutable v3; 367 Flutter + 8 Node checks, five delivered hashes, browser transitions/reload, grimoire and Market gating verified. Art remains a candidate; no account capability promotion or new template lock. |
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

Tanya directed “Push the male robes and every day outfit to the app” on 2026-10-04, then selected the non-restrictive legacy migration: replace the legacy male foundation with locked v3 and preserve existing outfit availability. All five male class defaults and Everyday equip/unequip/restoration must use the same full v3 body and identity. Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle remain available and owned; fit garments to v3 without clipping or substituting the primary body. Everyday account support is female + neutral + male; Woodland remains female-only. Migration `20261004164110` supersedes the temporary restriction applied before the concurrent decision was reconciled. No new art lock or production promotion is inferred.

Runtime evidence is recorded in `docs/qa/APPROVED_WARDROBE_INTEGRATION.md`: 351 Flutter tests, 8 Node tests, deployed development browser checks and scoped synthetic public-RPC verification after migration `20261004035017`. Neutral verification covers Everyday and the five class robes; legacy suits, Harvest Coats and closed cloaks remain separately queued. Browser evidence uses in-memory fixtures and does not claim real-user login/refresh persistence. No new art/template lock is established by this delivery.


## 2026-10-04 app-integration correction

Tanya reported “The robes weren’t pushed to the app.” Confirmed: earlier delivery records covered dedicated art-review routes only. The normal shared avatar renderer requires a v3-backed migration. Tanya then directed: **replace the legacy body with the new v3 male body**. That decision supersedes the temporary-restriction proposal in PR #9. The active implementation preserves the four legacy chest items as garments while making locked male v3 the underlying foundation in every male render state. Do not claim DEV DEPLOYED until delivered runtime verification passes.


Current delivery evidence: `docs/qa/MALE_ROBE_EVERYDAY_APP_INTEGRATION.md` and `docs/qa/MALE_ROBE_EDGE_REPAIR_V2.md`. Male Everyday backend support and retained legacy availability pass deployed public-RPC checks. Shared app delivery and newer repair are verified at `958aaaf`; browser evidence uses sample inventory, not a private account login. Historical review-only records above are not the current rollout status.


## Latest male sleeve and thumb repair (2026-10-04)

Tanya additionally reported dark outer sleeves and persistent thumb-adjacent holes. This newer instruction supersedes the earlier rear-only scope: `tool/male_robe_edge_repair_reference.json` permits new foreground RGB surfaces inside the existing alpha masks and a garment-only occlusion contour. The Everyday file stays one byte-identical overlay; only when a robe is worn, the renderer clips its hidden trouser pixels beside the thumbs. Never wrap or clip the body with that contour. The whole original body and hands remain visible at their original registration, with the existing repaired rear lining behind them. Collar, cuffs, rear, all historical files and every front alpha remain unchanged. This scoped correction does not establish a new founder lock.

Lesson: alpha-only thumb checks can pass while an opaque trouser layer still covers the lining. Inspect final composite color and actual renderer depth, not just rear opacity. Check all class colors, garment-only clipping, equip/unequip and the complete hand silhouette.
