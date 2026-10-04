# Questwell Production Dashboard

Session started **2026-10-03 (America/New_York)**; evidence updated **2026-10-04 UTC**. This is the last recorded work snapshot, not a live background-worker claim. The founder-facing development page is `production-dashboard.html` beside the app. The delivered dedicated `?review=male-everyday` route compares the unchanged male v3 body with its everyday v2 overlay; it is not an account wardrobe rollout.

## Production lifecycle

**QUEUED → BUILDING → QA → DEV DEPLOYING → DEV DEPLOYED → TANYA REVIEW → LOCKED**

Use **BLOCKED** only when the affected work cannot proceed. Active visual development and a separate queued founder decision do not block approved work.

| Priority | Work item | Production status | Art/template lock | Current evidence and next step |
|---|---|---|---|---|
| 1 | Build and regression gate repairs | DEV DEPLOYED | No template change | Runtime `4cfef7f` verified. Run `37174925231` passed asset checks, analyzer, 351 Flutter tests, 8 Node tests, build and deployment; actual delivered behavior inspected. |
| 1 | Exact male v3 body/everyday v2 ingestion and fixed-body development review | DEV DEPLOYED | Both founder-locked | Delivered three asset hashes match. Browser Body Only ↔ Outfit and enlarged review passed on unchanged v3; independent delivered screenshot QA passed. Dedicated review only; male account rollout remains queued. |
| 1 | Male account wardrobe rollout | QUEUED | Foundation/everyday locked; remaining garment fits incomplete | Do not enable male Everyday in live account equipment while unequipping restores a different legacy body. Complete the remaining accepted male fits and coherent same-body transition before account rollout. Existing legacy account paths remain unchanged. |
| 1 | Neutral Everyday and class-robe runtime/persistence audit | DEV DEPLOYED | Body v4, everyday v3 and robe v11 locked | All five robes rendered; 390px Adventurer/Hearth equip/unequip and Market fixture flows passed. Applied migration `20261004035017` passed deployed synthetic public-RPC tests with zero retained fixtures/security findings. Browser fixtures were in-memory; no real-user login/refresh/account writes were tested. Legacy chest migration is separate. |
| 1 | Neutral Woodland Scout candidate review | QA | CANDIDATE — NOT LOCKED | Delivered `?review=neutral-scout` four-stage/off-on/detail-control checks passed on fixed v4. Visual QA remains active; no founder lock or independent delivered screenshot audit. Account eligibility stays female-only. |
| 1 | Male Woodland Scout outfit | QUEUED | No male Woodland fit/template lock established | Explicit avatar priority alongside neutral Woodland. Create one coherent body-specific outfit on immutable male v3; no cross-body scaling. Source audit found no existing male Woodland candidate/provenance. Preserve art/account boundaries; no decision is requested now. |
| 1 | Migrate legacy female/neutral chest foundations coherently | QUEUED | Existing paper-doll bodies stay locked; legacy garment migration incomplete | Business Suit still selects `base_{body}.webp`; Harvest Coat and closed cloaks use `QuestwellCleanBase` with legacy identity/trousers. Separately fit and verify these transitions to the approved paper dolls. Current catalog behavior is unchanged; no new blocker or founder request. |
| 1 | Remaining male garment templates | BUILDING | New robe template not yet locked | Existing unapproved male robe candidates remain in active development, including unfinished cuff work. Continue on the unchanged male v3 body/everyday v2 outfit. Template acceptance requires independent QA and Tanya's decision before class surfaces; no decision is requested now. |
| 2 | Issue #6: Warding Lantern and Emerald Wayfarer Rug | QUEUED | Replacement visuals not approved | Immediately after avatar/template work. Rebuild within the approved briefs and review at game scale. Keep both catalog entries inactive and preserve existing ownership until Tanya approves replacements. |
| 3 | Issue #7: architecture/scalability and replaceable presentation | QUEUED | Existing architecture decisions preserved | Follow #6 before launch. First bounded item: extract inventory/loadout data and duplicated slot mapping from presentation into a shared model, preserving behavior. Architecture protections continue throughout avatar work. |

## Tanya needed now

**No founder decision is currently requested.** The scoped technical batch is deployed. Woodland Scout remains explicit: neutral candidate QA and male outfit QUEUED, alongside the remaining avatar work. Future male template acceptance and #6 replacement approval are concrete later review points, not blockers to current work.

If a task becomes BLOCKED, record its precise reason, evidence, work that can still continue and the smallest required action. Request Tanya only for a genuine founder aesthetic/template decision, required permission/credentials, a paid service, a destructive or irreversible action, a material product/economy change, or an unavoidable manual action.

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

- Verified runtime code: **`4cfef7f277eba89ac65a1ea965cdea7dfb169d1f`**, confirmed through `questwell-version.json`; CI run **`37174925231`** passed **351 Flutter + 8 Node tests**, analyzer, asset checks, build and development deployment. Follow-up **`a4d3b794e5757303a57e41128ffdc581a306b998`** and run **`37175899729`** passed the same complete gate and delivered-version check. The Market body selector now clears unsupported equipment while preserving ownership and sample coins; neutral → male → neutral browser verification passed without silent re-equip. No application code changes follow that verification.
- Exact male artifacts from approved `c1382db` passed local byte/alpha/RGBA/source/composite checks. The delivered three asset hashes also match. Body Only ↔ Outfit and enlarged review preserve the same v3 body/identity; independent delivered screenshot QA passed.
- Scoped neutral runtime: all five actual robes rendered. At 390px, owned Everyday equip → Hearth one worn → Adventurer Equipped → unequip → Hearth zero worn restored the neutral class robe. Re-equipping then choosing male retained 15 owned items, removed the unsupported equipped item and disabled Fit unavailable. Market neutral Scout fixture purchase used 40 sample coins (650 → 610), then preview/equip/In use worked; neutral Woodland remained disabled.
- Browser review used **in-memory fixtures**. No real-user login, page refresh/login restoration or real account writes were exercised. Persistence was independently tested through the deployed public RPCs with synthetic identities whose writes were rolled back.
- Applied migration **`20261004035017`** passed post-deployment checks: female/neutral Everyday, female Scout Woodland, no male support for either, zero retained fixtures, unchanged public wrappers/ACLs, private bodies matching the migration, unchanged prices 40/120 and activation/class metadata, and zero security-advisor findings. Descriptions were corrected to match approved fit support.
- Earlier gates prevented faulty candidates from deploying: `d526da11` 333/4, `fcd9f987` 346/1, `88cda121` 346/1; harness import/scroll/MediaQuery defects were repaired. `99e127b` passed 350 tests but deployment was superseded by the fully verified `4cfef7f` follow-up.
- Full checks, limits and screenshots: [`../qa/APPROVED_WARDROBE_INTEGRATION.md`](../qa/APPROVED_WARDROBE_INTEGRATION.md). This completion is scoped; it does not approve new garment templates, promote neutral Woodland to account eligibility, or complete male/legacy chest wardrobe migration.

## Durable handoff

Continue the active neutral Woodland candidate review and male robe/cuff work; keep male Woodland Scout explicitly queued on the immutable v3 body. Preserve female Woodland's existing lock and female-only account eligibility. Complete the queued male/legacy chest foundation transitions before claiming wardrobe-wide migration. After avatars, continue #6 then #7. No new founder action is needed for this handoff.
