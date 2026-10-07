# Questwell Production Dashboard

## Hearth visual polish — October 7, 2026

**QA checkpoint; delivery status is tracked in [PR #67](https://github.com/funszdidiot/questwell-app/pull/67).** Bounded page/room framing, adaptive
quest/overview columns, a shared subdued panel treatment, and corrected review
ordering. Existing artwork, room geometry and account behavior are unchanged.
Eight new viewport/text-scale/composition regressions and the corrected legacy scroll checks passed in CI. The current-base
combined revision is awaiting its final required checks. Local Flutter startup
was blocked by automatic approval review after a metadata-endpoint attempt;
no retry or bypass. Runtime visual/device acceptance remains pending.
See `../qa/HEARTH_VISUAL_POLISH.md`. No new art lock or release GO.

## Male Woodland account integration — 2026-10-05

**DEV DEPLOYED; signed-in account/iPhone acceptance pending.**
PR #22 merged with Tanya's approval as `fad7777`. Preview workflow `37376148332`
and backend workflow `37376148039` passed. The served revision and four locked
asset hashes match. Sample Market purchase (650 → 530 coins), equip and unequip
passed. All 390 Flutter tests and isolated Woodland account/persistence checks
passed. The database migration `20261005212048` is verified. Price, Scout-only
eligibility, ownership and locked artwork remain unchanged.
The sample is in-memory; no signed-in hosted account or physical iPhone test has
been reported. See `../qa/MALE_WOODLAND_ACCOUNT_ROLLOUT.md`. Broader release and
G3 history holds remain separate.

## Male Woodland sleeve and size correction — 2026-10-05

**DEV DEPLOYED / technically verified.** Version 2 replaces the rejected v1 fit
in the male Woodland development review on immutable male v3. Delivered revision
`ae72f23`, workflow `37342883393`: 387 Flutter tests, 12 preview Node checks,
asset/dependency/analyzer/build/deploy gates passed; backend workflow `37342882902`
passed 19 additional Node guards and 14 isolated fixture/application assertions.
Five delivered hashes match. Actual Body/Everyday/robe/Woodland transitions,
light/dark/enlarged review, belt grimoire and route reload passed, followed by
independent delivered visual QA. One continuous outfit overlay; original body and
hands retained. Tanya approved “It’s good” on 2026-10-05: art/template is now LOCKED. The later account-integration delivery is recorded above.
Physical iOS/Safari and real-user persistence were not tested. No founder blocker.
Evidence: `../qa/MALE_WOODLAND_V2.md` and `../../tool/qa/male_woodland_v2_delivery.json`.

## Male neckline renderer — 2026-10-05

**DEV DEPLOYED / technically verified.** Shared original-head sampling now
removes the rectangular neckline from male Everyday and all five robe states,
matching the verified legacy renderer. Full primary body remains unclipped;
all asset bytes, eligibility and equipment policy are unchanged. Runtime
`9da7205`, workflow `37334631348`: 387 Flutter + 12 Node tests and mandatory
asset/analyzer/dependency/build/deploy gates passed. All 23 delivered male hashes
match. Actual native/enlarged/light/dark, class/equipment transitions, sample
Market purchase/equip/unequip and independent visual QA passed. No founder
blocker or new art lock. See `../qa/MALE_IDENTITY_SAMPLING.md`.

Tanya's October 5 “Better!” is recorded as positive fit feedback; the existing
body/garment locks remain authoritative.

## Active garment correction — 2026-10-05 America/Chicago

**Coats: DEV DEPLOYED / repair technically verified.** All three Harvest Coat v8
inner sleeves cover the locked arms without exposed skin/undershirt or broad
compensating cloth. Female cuffs wrap the fixed wrists with curved hems and rear
depth. Accepted cloak/mantle art and all locked body/identity/Everyday bytes are
unchanged. A scoped male legacy head-layer correction also removed the existing
rectangular neckline artifact using pixel-identical original head pixels.
Runtime `4b6be2b`, workflow `37331784954`: 387 Flutter + 12 Node checks, asset,
analysis, locked-dependency, build/deploy gates and 31 delivered hashes passed.
Actual native/enlarged/Hearth independent visual QA, wear/remove/restoration,
belt grimoire and sample Market purchase/equip/unequip verified. No new founder
lock or founder blocker. See `../qa/COAT_UNDERARM_REBUILD.md`.

**Coat cuffs: DEV DEPLOYED — founder correction.** Tanya accepted cloak/mantle v4 and
reported disconnected wrist joins on all three coats. Preserve accepted cloth.
Corrected original-hand foreground depth at the cuff openings; no body or art
bytes changed. Runtime `dc3e464`, workflow `37314935274`: 386 Flutter + 8 Node
tests and full build/deploy passed; 31 delivered hashes match. Actual three-body
avatar/Hearth, wear/remove/restoration and independent delivered visual QA passed.
Earlier all-nine QA is superseded for coat wrists. No founder blocker or new lock.

**DEV DEPLOYED.** Tanya requested narrower male coat elbows, wrapping wider cuffs,
no cloak/mantle inner flaps, proper rear layers and natural shoulder drape. She
then rejected excessive cloak/mantle flare. All six were redrawn to hang
mostly downward; the standing natural-drape rule is recorded for future cloaks,
capes, robes and mantles. Runtime `e46a42b`, workflow `37312732888`: 386 Flutter
and 8 Node tests, analysis/assets/build/deploy passed. All 31 delivered hashes
match. All nine actual renderer fits passed independent delivered visual QA;
all three bodies restore class robes on unequip. Male sample Market coat
preview/purchase/equip/unequip verified. See `../qa/CLOAK_MANTLE_INNER_FLAPS.md`.
The previous DEV DEPLOYED row
below records the historical baseline, not acceptance of the latest correction.
No locked body/Everyday/robe asset changes and no founder blocker.

Continued **2026-10-04 (America/Chicago)**. Approved neutral outfits are **DEV DEPLOYED / LOCKED** at `9ce9b92`: full gate, account eligibility, live Market purchase/equip/unequip and ten delivered hashes verified. See `../qa/NEUTRAL_OUTFIT_ROLLOUT.md`. The shared male robe/Everyday integration and newer sleeve/thumb correction are **DEV DEPLOYED** at `958aaaf`: workflow `37229645601`, 373 Flutter + 8 Node tests, analysis/assets/build/deploy and all 23 delivered asset hashes passed. All five classes were visually checked in the shared Adventurer renderer; Everyday inventory equip → Hearth → unequip → restored robe and sample Market purchase/equip passed. No founder action is needed. Locked body, identity and Everyday bytes remain unchanged. This is a recorded snapshot, not a background-worker claim.

## Production lifecycle

**QUEUED → BUILDING → QA → DEV DEPLOYING → DEV DEPLOYED → TANYA REVIEW → LOCKED**

Use **BLOCKED** only when the affected work cannot proceed. Active visual development and a separate queued founder decision do not block approved work.

| Priority | Work item | Production status | Art/template lock | Current evidence and next step |
|---|---|---|---|---|
| 1 | Build and regression gate repairs | DEV DEPLOYED | No template change | Runtime `4cfef7f` verified. Run `37174925231` passed asset checks, analyzer, 351 Flutter tests, 8 Node tests, build and deployment; actual delivered behavior inspected. |
| 1 | Exact male v3 body/everyday v2 ingestion and fixed-body development review | DEV DEPLOYED | Both founder-locked | Delivered three asset hashes match. Browser Body Only ↔ Outfit and enlarged review passed on unchanged v3; independent delivered screenshot QA passed. Dedicated review only; male account rollout remains queued. |
| 1 | Male robes in the actual app / coherent male wardrobe rollout | DEV DEPLOYED | Body v3, Everyday v2 and historical robe v3 remain locked | Non-restrictive migration is deployed: all male defaults and legacy chest states retain locked v3; Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle remain available. Workflow `37218307696` passed asset verification, analyzer, full Flutter regressions, preview build and deployment. Supabase migration `20261004164110` preserves legacy availability and male Everyday support with no price, balance, class-rule or ownership change. |
| 1 | Neutral Everyday and class-robe runtime/persistence audit | DEV DEPLOYED | Body v4, everyday v3 and robe v11 locked | All five robes rendered; 390px Adventurer/Hearth equip/unequip and Market fixture flows passed. Applied migration `20261004035017` passed deployed synthetic public-RPC tests with zero retained fixtures/security findings. Browser fixtures were in-memory; no real-user login/refresh/account writes were tested. Legacy chest migration is separate. |
| 1 | Approved neutral outfits rollout | DEV DEPLOYED | LOCKED | Verified `9ce9b92`: full gate, ten delivered hashes, live neutral purchase/equip/unequip and rolled-back account RPCs. Price 120 and Scout rule preserved. |
| 1 | Male Woodland Scout outfit v2 | DEV DEPLOYED; hosted-account/iPhone acceptance pending | LOCKED — founder approved 2026-10-05 | PR #22 merge `fad7777`; verified build, locked assets, sample buy/equip/unequip and isolated account persistence. Live migration `20261005212048` verified. |
| 1 | Harvest Coat, Moss-Green Cloak and Hearthguard Mantle — individual body refits | DEV DEPLOYED | Nine scoped candidates; no new lock | Founder-rejected widened fits superseded by nine independently drawn fits. Native/enlarged light/dark independent QA passed. Complete bodies preserved; cloak/mantle conceal arms/hands, coat restores exact original hands above side panels. Verified `0546cb4`, workflow `37266712857`: 385 Flutter + 8 Node tests, build/deploy, 15 delivered hashes, independent runtime visual QA and sample Market equip/unequip passed. No founder blocker. See `../qa/LEGACY_INDIVIDUAL_REFIT.md`. |
| 1 | Accepted male robe v3 fixed-body review integration | DEV DEPLOYED | Robe v3 LOCKED — accepted cuff finish verified | Recovered exact `16facaf` handoff and independent source QA. Body, everyday, identity and all four robe masks preserved. Delivered `31dfebe`, workflow `37177492039`: 355 Flutter + 8 Node tests, analysis/assets/build/deploy passed. All seven delivered hashes, clothing transitions, enlargement, reload and independent delivered-image QA passed. |
| 1 | Male class robe surfaces and thumb-gap repair (art-review routes only) | DEV DEPLOYED | Historical v3/foreground locked; requested rear repair is not a new lock | Repaired `7cc9030`, run `37181630492`: 363 Flutter + 8 Node tests, assets/analyzer/build/deploy, 28 delivered hashes, actual all-five gallery/controls/class switch/reload and independent delivered visual QA passed. Bodies, hands, foreground and class designs unchanged. Male Woodland is now DEV DEPLOYED as a separate outfit candidate (`0330c3b`). |
| 2 | Issue #6: Warding Lantern and Emerald Wayfarer Rug | QA / DEV DEPLOYING | v1/v2 rejected; v3 64-bit candidates NOT LOCKED | Founder rejected the earlier code-painted/vector-like passes and reaffirmed the locked 64-bit Questwell vision. New v3 assets `warding_lantern_v3_64bit.webp` and `emerald_wayfarer_rug_v3_64bit.webp` are authored as crisp pixel/sprite art with richer brass/wood/glass and woven texture, wired with nearest-neighbor runtime filtering and the approved rug floor footprint. Full gate `37243648578` is running. Keep both catalog entries inactive and preserve ownership/economy until founder visual approval. |
| 3 | Issue #7: architecture/scalability and replaceable presentation | BUILDING / QA | Existing architecture decisions preserved; Hearth slot/family behavior now governed by a full-stack contract | Shared loadout semantics are extracted. Supabase migration `hearth_layout_contract` is applied: 27 current Hearth/wall-art cosmetics are profile-backed, room slots are data-driven, and placement RPC validation is profile→slot instead of slug-specific. Flutter now has canonical family envelopes and the Market/Adventurer picker consumes backend placement choices. Full combined CI/deployment verification is in progress. See `HEARTH_SYSTEM.md`. |

## Historical neutral Woodland v3 review check (superseded by approval below)

The existing hand/heel repair is **DEV DEPLOYED in explicit review only** at `9934335`. Native/enlarged light/dark composite checks, delivered hashes and actual on/off/reload behavior passed. The production dashboard no longer treats old run `37221656554` as still running. No asset was edited during this verification and no account capability was promoted. Detailed legacy garment fit QA remains the next approved avatar task; no Tanya action is required now.

## Male sleeve/thumb correction

**DEV DEPLOYED — `958aaaf`.** New front surfaces retain the historical exact alpha. A garment-only clip hides trouser pixels beside the thumbs only while wearing a robe, leaving the complete body and hands untouched. Local color/depth, immutable-file, shared-alpha, full CI, delivered hashes and actual five-class visual checks pass. See `../qa/MALE_ROBE_EDGE_REPAIR_V2.md` and `tool/qa/male_robe_edge_repair_v2_delivery.json`. No catalog, economy, account or grimoire changes. Earlier rear-only repair evidence is historical and superseded; no new founder lock is inferred.

## Tanya needed now

**None for this rollout.** Tanya directed “Push the male robes and every day outfit to the app” on 2026-10-04, then selected the non-restrictive legacy migration: replace the legacy male foundation with locked v3 and preserve existing outfit availability. All five male class defaults and Everyday equip/unequip/restoration must use the same full v3 body and identity. Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle remain available and owned; fit garments to v3 without clipping or substituting the primary body. Everyday account support is female + neutral + male. Newer neutral approval below expands Woodland to female + neutral Scouts. Migration `20261004164110` supersedes the temporary restriction applied before the concurrent decision was reconciled. No new art lock or production promotion is inferred.

Request Tanya only for the genuine decisions and unavoidable actions in `AGENT_OPERATING_RULES.md`; do not reopen resolved decisions or block approved delivery for active visual development.

## Completion evidence

For each integrated item, record:

- exact asset/fit reference and immutable template verification;
- the same locked body/identity across equip, unequip, class change and reload;
- renderer/depth order, inventory/catalog visibility, explicit body/class eligibility and equipment policy;
- persistence and restoration behavior without anatomy substitution;
- automated checks, analyzer, web build and independent visual QA;
- delivered development revision, URL and actual runtime checks;
- Tanya's explicit decision only when genuinely required.

DEV DEPLOYED requires verification of the delivered development revision and actual runtime. An upload, commit or successful build alone does not qualify. Technical completion and art approval are separate facts. A fixed-body development review is not evidence that an account wardrobe migration is complete. Hashes prove file preservation; they do not prove that different equipment states select the same body.

## Evidence log

- Verified runtime code: **`4cfef7f277eba89ac65a1ea965cdea7dfb169d1f`**, confirmed through `questwell-version.json`; CI run **`37174925231`** passed **351 Flutter + 8 Node tests**, analyzer, asset checks, build and development deployment. Follow-up **`a4d3b794e5757303a57e41128ffdc581a306b998`** and run **`37175899729`** passed the same complete gate and delivered-version check. The Market body selector now clears unsupported equipment while preserving ownership and sample coins; neutral → male → neutral browser verification passed without silent re-equip. That evidence covers the earlier wardrobe batch; the newer male robe integration is recorded below.
- Exact male artifacts from approved `c1382db` passed local byte/alpha/RGBA/source/composite checks. The delivered three asset hashes also match. Body Only ↔ Outfit and enlarged review preserve the same v3 body/identity; independent delivered screenshot QA passed.
- Scoped neutral runtime: all five actual robes rendered. At 390px, owned Everyday equip → Hearth one worn → Adventurer Equipped → unequip → Hearth zero worn restored the neutral class robe. Re-equipping then choosing male retained 15 owned items, removed the unsupported equipped item and disabled Fit unavailable. Market neutral Scout fixture purchase used 40 sample coins (650 → 610), then preview/equip/In use worked; neutral Woodland remained disabled.
- Browser review used **in-memory fixtures**. No real-user login, page refresh/login restoration or real account writes were exercised. Persistence was independently tested through the deployed public RPCs with synthetic identities whose writes were rolled back.
- Applied migration **`20261004035017`** passed post-deployment checks: female/neutral Everyday, female Scout Woodland, no male support for either, zero retained fixtures, unchanged public wrappers/ACLs, private bodies matching the migration, unchanged prices 40/120 and activation/class metadata, and zero security-advisor findings. Descriptions were corrected to match approved fit support.
- Earlier gates prevented faulty candidates from deploying: `d526da11` 333/4, `fcd9f987` 346/1, `88cda121` 346/1; harness import/scroll/MediaQuery defects were repaired. `99e127b` passed 350 tests but deployment was superseded by the fully verified `4cfef7f` follow-up.
- Full checks, limits and screenshots: [`../qa/APPROVED_WARDROBE_INTEGRATION.md`](../qa/APPROVED_WARDROBE_INTEGRATION.md). This completion is scoped; it does not approve new garment templates, promote neutral Woodland to account eligibility, or complete male/legacy chest wardrobe migration.

## Durable handoff

Male Woodland is DEV DEPLOYED in explicit review; account rollout remains separately queued. Male robes and Everyday are integrated into the shared app renderer; the newer sleeve/thumb correction is delivered and verified at `958aaaf`. Historical male robe files remain immutable; new front RGB surfaces preserve exact alpha and robe-only Everyday occlusion fixes depth without touching the primary body. Neutral Woodland is now approved for female and neutral Scouts; finish its authorized rollout. Continue male Woodland on its immutable body without promoting its account eligibility. Complete detailed legacy garment fit review before claiming wardrobe-wide visual acceptance. After avatars, continue #6 then #7. No new founder action is needed for this handoff.

## Current male robe integration

The previous unfinished-cuff status was stale relative to source commit `16facaf3b688b2d2f96e47bf2bd4a215685d0e6e`. Its accepted fit reference, sharp-cuff verification and independent visual review are now preserved in this repository. This reconciles an existing founder decision; it does not create a new approval. Current integration status: **DEV DEPLOYED** at `31dfebe7e8907daf434de9cb95372bf9cce0706d`. Workflow `37177492039` passed 355 Flutter + 8 Node tests, analyzer, asset integrity, build and deploy. Actual body/outfit/robe transitions, enlargement and reload passed; seven delivered hashes matched and independent delivered-image QA passed. See [`../qa/MALE_ROBE_V3_INTEGRATION.md`](../qa/MALE_ROBE_V3_INTEGRATION.md). No account or database behavior changed.

## Current male class and thumb repair

The five-class baseline `b62e4ae0a69de7f47d14ecd8b8593e0b4a05a5ad`, run `37179075947`, passed 362 Flutter + 8 Node tests, assets/analyzer/build/deploy and all 23 delivered hashes. Tanya's later thumb-gap finding supersedes the earlier detail QA PASS. Repaired runtime `7cc90309c1b97be5ea9ccd6f8f02044014795e35`, workflow `37181630492`, passed 363 Flutter + 8 Node tests and the complete gate. All 28 delivered hashes match. Actual all-five gallery, class switch, Body only/Outfit/Robe placement, enlargement and URL reload passed on the same foundation, with independent delivered-image QA. `tool/male_robe_thumb_repair_reference.json` records the scoped rear repair; historical locks and account/catalog/equipment/persistence behavior remain unchanged. Full evidence: [`../qa/MALE_CLASS_ROBES_THUMB_REPAIR_INTEGRATION.md`](../qa/MALE_CLASS_ROBES_THUMB_REPAIR_INTEGRATION.md).

## Current male Woodland delivery

Development revision **`0330c3b57cf1d26e0979a072999c060af444b694`**, workflow **`37213357594`**, passed **367 Flutter + 8 Node tests**, asset integrity, analyzer, release build and deployment. Five fetched asset hashes and the delivered version stamp match. Actual Body only/Everyday/Scout robe/Scholar robe/Woodland controls, native and enlarged light/dark appearance, unchanged belt grimoire and URL reload passed. The sample Market correctly disables male Woodland and labels its existing female fit preview. No account writes, economy changes or capability promotion occurred. The review is reachable at `?review=male-woodland`; full evidence and limitations are in [`../qa/MALE_WOODLAND_V1_INTEGRATION.md`](../qa/MALE_WOODLAND_V1_INTEGRATION.md).

The exact approved male Everyday and accepted historical robe v3 were already present; they were preserved, not regenerated. The existing all-five robe gallery passed a current runtime regression. No new robe template or surface approval is inferred. Continue authorized avatar work without creating a routine founder blocker; no final Woodland/template lock has been requested or recorded.


## Historical correction: review-only delivery was insufficient

Tanya's 2026-10-04 report superseded earlier broad delivery wording: the dedicated robe review routes alone did not prove shared Hearth/Adventurer/Market integration. The subsequent shared-renderer migration was delivered at `20489ad`; the newer scoped visual correction is verified at `958aaaf` above. Tanya's non-restrictive migration decision preserves four legacy chest items while replacing their old male foundation with locked v3. Technical same-body migration and final visual acceptance of each legacy garment remain distinct.

## Current male robe and Everyday integration

All five male robe defaults and approved Everyday now use the actual shared app renderer, preserving full v3 anatomy. The concurrent legacy garment component is integrated without clipping or substituting the primary male body. Applied migration `20261004164110` preserves the four legacy items' availability and male Everyday support, superseding `20261004163513` after the newer founder decision was recovered. No owned male legacy item was equipped when the earlier migration ran; ownership/balances are unchanged. Synthetic public-RPC tests cover purchase, retries, equip/unequip, all body/class changes, RLS and retained ownership. Workflow `37218307696` passed asset verification, analyzer, the full Flutter regression gate, build and development deployment on 2026-10-04. Founder visual acceptance of individual legacy garment fit remains separate from this technical same-body migration. Current evidence is `../qa/MALE_ROBE_EVERYDAY_APP_INTEGRATION.md`.


## Latest neutral approval and rollout — 2026-10-04

Tanya: **“The neutral outfits are good- push them.”** Neutral Woodland v3 is now founder-approved and LOCKED at `tool/neutral_woodland_fit_reference.json`. This newer instruction explicitly authorizes its development app and account eligibility rollout for female and neutral Scouts; male Woodland remains unavailable. Earlier female-only and neutral-candidate statements are historical and superseded for this scope. Existing neutral Everyday and all five class robes remain locked. Exact artwork and bodies are unchanged. Rollout status: **DEV DEPLOYED / LOCKED**, verified at `9ce9b92` (workflow `37236299144`, 373 Flutter + 8 Node tests, ten delivered asset hashes, live neutral Market purchase/equip/unequip). Evidence: `docs/qa/NEUTRAL_OUTFIT_ROLLOUT.md`.


## Legacy wardrobe visual audit — 2026-10-04 America/Chicago

Audit DEV DEPLOYED at `7533e3b`: `?review=legacy-wardrobe` provides, an account-free comparison of the actual shared renderer for all three locked bodies, every class, and the four retained legacy chest garments. Native/enlarged, light/dark and equipment-removal controls expose fit and restoration issues without changing assets or account policy. This is a QA surface, not a new garment approval. Delivered runtime inspection follows the full development gate.


## Legacy fits — all three bodies, repair QA

Tanya explicitly expanded scope to female and neutral. **DEV DEPLOYED** at `339cc495`: new coherent Business Suit v1 and Harvest Coat v3 overlays are integrated into the shared renderer for all three bodies. Independent light/dark export QA passed after resolving shoulder, underarm, forearm, cuff, leg and footwear gaps. Cloak/mantle registration now covers complete arms with cloth rather than clipping anatomy; the actual runtime exposed an old generic jaw crop, corrected with complete original identity and body-specific foreground neck contours. Workflow `37260882702` passed 387 Flutter + 8 Node tests, full analysis/build/deployment; delivered version, 21 asset hashes, actual appearance and independent runtime QA passed. These are scoped repair candidates, not new founder locks. No blocker or new founder decision is required.

Suit rendering no longer samples historical full-body Business Suit images. Harvest occlusion clips only hidden Everyday garment pixels; the locked body stays an unclipped sibling. Catalog, prices, ownership, eligibility, persistence, class policy and belt grimoire are unchanged. Provenance and exact export hashes: `tool/art_assets/legacy_refit_v1/provenance.json`.


Legacy repair delivery evidence: [LEGACY_FIT_REPAIR.md](../qa/LEGACY_FIT_REPAIR.md). The same shared renderer is used by Hearth, Adventurer, inventory and Market. Browser tests used in-memory sample inventory; no real account writes or new real-user refresh persistence test were performed. Existing persistence code and account policy are unchanged and prior RPC evidence remains scoped to its recorded migration. Development fit verification is complete; founder visual acceptance remains separate and is not requested as a routine blocker.


Neck-overlap regression follow-up (PR #13): preserve the delivered `339cc49` body-specific contours and original identity restoration while explicitly unioning the head/neck foreground region. **DEV DEPLOYED** at `9d47ee6`, workflow `37261924230`: 388 Flutter + 8 Node tests, configured analysis/asset checks, build/deploy, matching version and browser bundle, all-three-body appearance, enlarged neckline, light/dark and neutral Guardian equip/unequip restoration passed. No artwork or account behavior changes. Existing independent legacy-fit completion evidence above remains valid; current screenshots and limitations are in `../qa/LEGACY_FIT_REPAIR.md`.

## Superseding individual fits — 2026-10-05

Tanya rejected the earlier widened coat/cloak/mantle shapes. The historical legacy/neckline delivery records above establish technical delivery only, not current visual acceptance. Nine separately authored individual fits are now **DEV DEPLOYED** at `0546cb4`; no new founder lock. Cloak/mantle cover complete arms/hands with cloth; coat preserves the exact original hands in front. Complete locked bodies and existing catalog/equipment rules are unchanged. Full technical and independent delivered visual QA passed. See `../qa/LEGACY_INDIVIDUAL_REFIT.md`. No founder decision blocks this completed development integration.
