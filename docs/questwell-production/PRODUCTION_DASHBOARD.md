# Questwell Production Dashboard

Continued **2026-10-04 (America/Chicago)**. Tanya directed “Push the male robes and every day outfit to the app”, then chose keeping the legacy outfits available on locked male v3. The combined rollout is **QA / DEV DEPLOYING**: same-body shared rendering, male Everyday support and preserved legacy availability. Backend migration and public-RPC verification pass; actual app deployment remains to be verified. This is a recorded snapshot, not a background-worker claim.

## Production lifecycle

**QUEUED → BUILDING → QA → DEV DEPLOYING → DEV DEPLOYED → TANYA REVIEW → LOCKED**

Use **BLOCKED** only when the affected work cannot proceed. Active visual development and a separate queued founder decision do not block approved work.

| Priority | Work item | Production status | Art/template lock | Current evidence and next step |
|---|---|---|---|---|
| 1 | Build and regression gate repairs | DEV DEPLOYED | No template change | Runtime `4cfef7f` verified. Run `37174925231` passed asset checks, analyzer, 351 Flutter tests, 8 Node tests, build and deployment; actual delivered behavior inspected. |
| 1 | Exact male v3 body/everyday v2 ingestion and fixed-body development review | DEV DEPLOYED | Both founder-locked | Delivered three asset hashes match. Browser Body Only ↔ Outfit and enlarged review passed on unchanged v3; independent delivered screenshot QA passed. Dedicated review only; male account rollout remains queued. |
| 1 | Male robes in the actual app / coherent male wardrobe rollout | DEV DEPLOYED | Body v3, Everyday v2 and historical robe v3 remain locked | Non-restrictive migration is deployed: all male defaults and legacy chest states retain locked v3; Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle remain available. Workflow `37218307696` passed asset verification, analyzer, full Flutter regressions, preview build and deployment. Supabase migration `20261004164110` preserves legacy availability and male Everyday support with no price, balance, class-rule or ownership change. |
| 1 | Neutral Everyday and class-robe runtime/persistence audit | DEV DEPLOYED | Body v4, everyday v3 and robe v11 locked | All five robes rendered; 390px Adventurer/Hearth equip/unequip and Market fixture flows passed. Applied migration `20261004035017` passed deployed synthetic public-RPC tests with zero retained fixtures/security findings. Browser fixtures were in-memory; no real-user login/refresh/account writes were tested. Legacy chest migration is separate. |
| 1 | Neutral Woodland Scout candidate review | QA | CANDIDATE — NOT LOCKED | Deterministic v3 garment repair generated from v2 on 2026-10-04. It removes only the audited right-hand intrusion and completes the two inner-heel contours; locked neutral v4 body/identity remain untouched. Runtime now references v3 and exact-pixel regressions are committed. Full Questwell Preview workflow `37221656554` is running; do not claim DEV DEPLOYED until build/deploy and delivered runtime verification pass. Account eligibility stays female-only. |
| 1 | Male Woodland Scout outfit | DEV DEPLOYED | CANDIDATE — NOT LOCKED | Verified runtime `0330c3b`, workflow `37213357594`: 367 Flutter + 8 Node tests, asset/analyzer/build/deploy gates, five delivered hashes and actual light/dark/enlarged controls, grimoire and reload passed. Male Market purchase/equip remains disabled under the existing account boundary. Art remains a candidate. |
| 1 | Migrate legacy female/neutral chest foundations coherently | QUEUED | Existing paper-doll bodies stay locked; legacy garment migration incomplete | Business Suit still selects `base_{body}.webp`; Harvest Coat and closed cloaks use `QuestwellCleanBase` with legacy identity/trousers. Separately fit and verify these transitions to the approved paper dolls. Current catalog behavior is unchanged; no new blocker or founder request. |
| 1 | Accepted male robe v3 fixed-body review integration | DEV DEPLOYED | Robe v3 LOCKED — accepted cuff finish verified | Recovered exact `16facaf` handoff and independent source QA. Body, everyday, identity and all four robe masks preserved. Delivered `31dfebe`, workflow `37177492039`: 355 Flutter + 8 Node tests, analysis/assets/build/deploy passed. All seven delivered hashes, clothing transitions, enlargement, reload and independent delivered-image QA passed. |
| 1 | Male class robe surfaces and thumb-gap repair (art-review routes only) | DEV DEPLOYED | Historical v3/foreground locked; requested rear repair is not a new lock | Repaired `7cc9030`, run `37181630492`: 363 Flutter + 8 Node tests, assets/analyzer/build/deploy, 28 delivered hashes, actual all-five gallery/controls/class switch/reload and independent delivered visual QA passed. Bodies, hands, foreground and class designs unchanged. Male Woodland is now DEV DEPLOYED as a separate outfit candidate (`0330c3b`). |
| 2 | Issue #6: Warding Lantern and Emerald Wayfarer Rug | QUEUED | Replacement visuals not approved | Immediately after avatar/template work. Rebuild within the approved briefs and review at game scale. Keep both catalog entries inactive and preserve existing ownership until Tanya approves replacements. |
| 3 | Issue #7: architecture/scalability and replaceable presentation | QUEUED | Existing architecture decisions preserved | Follow #6 before launch. First bounded item: extract inventory/loadout data and duplicated slot mapping from presentation into a shared model, preserving behavior. Architecture protections continue throughout avatar work. |

## Tanya needed now

**None for this rollout.** Tanya directed “Push the male robes and every day outfit to the app” on 2026-10-04, then selected the non-restrictive legacy migration: replace the legacy male foundation with locked v3 and preserve existing outfit availability. All five male class defaults and Everyday equip/unequip/restoration must use the same full v3 body and identity. Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle remain available and owned; fit garments to v3 without clipping or substituting the primary body. Everyday account support is female + neutral + male; Woodland remains female-only. Migration `20261004164110` supersedes the temporary restriction applied before the concurrent decision was reconciled. No new art lock or production promotion is inferred.

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

Male Woodland is DEV DEPLOYED in explicit review; account rollout remains separately queued. Male class surfaces and the requested thumb-gap repair are DEV DEPLOYED and verified. Historical male robe v3 geometry remains preserved; the newer repair changes connected rear lining only, not the body or foreground design. Continue neutral Woodland candidate review and male Woodland Scout on the immutable v3 body. Preserve female Woodland's existing lock and female-only account eligibility. Complete the queued male/legacy chest foundation transitions before claiming wardrobe-wide migration. After avatars, continue #6 then #7. No new founder action is needed for this handoff.

## Current male robe integration

The previous unfinished-cuff status was stale relative to source commit `16facaf3b688b2d2f96e47bf2bd4a215685d0e6e`. Its accepted fit reference, sharp-cuff verification and independent visual review are now preserved in this repository. This reconciles an existing founder decision; it does not create a new approval. Current integration status: **DEV DEPLOYED** at `31dfebe7e8907daf434de9cb95372bf9cce0706d`. Workflow `37177492039` passed 355 Flutter + 8 Node tests, analyzer, asset integrity, build and deploy. Actual body/outfit/robe transitions, enlargement and reload passed; seven delivered hashes matched and independent delivered-image QA passed. See [`../qa/MALE_ROBE_V3_INTEGRATION.md`](../qa/MALE_ROBE_V3_INTEGRATION.md). No account or database behavior changed.

## Current male class and thumb repair

The five-class baseline `b62e4ae0a69de7f47d14ecd8b8593e0b4a05a5ad`, run `37179075947`, passed 362 Flutter + 8 Node tests, assets/analyzer/build/deploy and all 23 delivered hashes. Tanya's later thumb-gap finding supersedes the earlier detail QA PASS. Repaired runtime `7cc90309c1b97be5ea9ccd6f8f02044014795e35`, workflow `37181630492`, passed 363 Flutter + 8 Node tests and the complete gate. All 28 delivered hashes match. Actual all-five gallery, class switch, Body only/Outfit/Robe placement, enlargement and URL reload passed on the same foundation, with independent delivered-image QA. `tool/male_robe_thumb_repair_reference.json` records the scoped rear repair; historical locks and account/catalog/equipment/persistence behavior remain unchanged. Full evidence: [`../qa/MALE_CLASS_ROBES_THUMB_REPAIR_INTEGRATION.md`](../qa/MALE_CLASS_ROBES_THUMB_REPAIR_INTEGRATION.md).

## Current male Woodland delivery

Development revision **`0330c3b57cf1d26e0979a072999c060af444b694`**, workflow **`37213357594`**, passed **367 Flutter + 8 Node tests**, asset integrity, analyzer, release build and deployment. Five fetched asset hashes and the delivered version stamp match. Actual Body only/Everyday/Scout robe/Scholar robe/Woodland controls, native and enlarged light/dark appearance, unchanged belt grimoire and URL reload passed. The sample Market correctly disables male Woodland and labels its existing female fit preview. No account writes, economy changes or capability promotion occurred. The review is reachable at `?review=male-woodland`; full evidence and limitations are in [`../qa/MALE_WOODLAND_V1_INTEGRATION.md`](../qa/MALE_WOODLAND_V1_INTEGRATION.md).

The exact approved male Everyday and accepted historical robe v3 were already present; they were preserved, not regenerated. The existing all-five robe gallery passed a current runtime regression. No new robe template or surface approval is inferred. Continue authorized avatar work without creating a routine founder blocker; no final Woodland/template lock has been requested or recorded.


## Correction: robe app integration is not yet verified delivered

Tanya's 2026-10-04 report supersedes the earlier broad delivery wording. `?review=male-robe` and `?review=male-robes` correctly render the new layers, but normal Hearth/Adventurer/Market delivery still requires verification. Tanya rejected the temporary-restriction route in favor of preserving the four legacy chest items while replacing their old male foundation with locked v3. The new shared-renderer migration is now the active path. Do not mark it DEV DEPLOYED until CI, deployment and actual delivered screens verify same-body transitions for default robes plus Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle.

## Current male robe and Everyday integration

All five male robe defaults and approved Everyday now use the actual shared app renderer, preserving full v3 anatomy. The concurrent legacy garment component is integrated without clipping or substituting the primary male body. Applied migration `20261004164110` preserves the four legacy items' availability and male Everyday support, superseding `20261004163513` after the newer founder decision was recovered. No owned male legacy item was equipped when the earlier migration ran; ownership/balances are unchanged. Synthetic public-RPC tests cover purchase, retries, equip/unequip, all body/class changes, RLS and retained ownership. Workflow `37218307696` passed asset verification, analyzer, the full Flutter regression gate, build and development deployment on 2026-10-04. Founder visual acceptance of individual legacy garment fit remains separate from this technical same-body migration. Current evidence is `../qa/MALE_ROBE_EVERYDAY_APP_INTEGRATION.md`.
