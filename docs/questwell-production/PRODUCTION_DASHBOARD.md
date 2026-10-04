# Questwell Production Dashboard

Session started **2026-10-03 (America/New_York)**; evidence updated **2026-10-04 UTC**. This is the last recorded work snapshot, not a live background-worker claim. The founder-facing development page is `production-dashboard.html` beside the app. The dedicated `?review=male-everyday` route is being corrected to compare the unchanged male v3 body with its everyday v2 overlay; it is not an account wardrobe rollout.

## Production lifecycle

**QUEUED → BUILDING → QA → DEV DEPLOYING → DEV DEPLOYED → TANYA REVIEW → LOCKED**

Use **BLOCKED** only when the affected work cannot proceed. Active visual development and a separate queued founder decision do not block approved work.

| Priority | Work item | Production status | Art/template lock | Current evidence and next step |
|---|---|---|---|---|
| 1 | Build and regression gate repairs | QA | No template change | Initial compile repair is in place. Full CI exposed test-harness import/viewport defects; fixes preserve real taps and assertions. The latest semantic corrections require a fresh full CI run and runtime verification. |
| 1 | Exact male v3 body/everyday v2 ingestion and fixed-body development review | QA | Both founder-locked | Exact bytes, alpha/RGBA, source correspondence and reviewed composite pass local checks. Dedicated review must retain the same v3 body when clothing is shown or hidden. CI and deployed-route verification remain pending. |
| 1 | Male account wardrobe rollout | QUEUED | Foundation/everyday locked; remaining garment fits incomplete | Do not enable male Everyday in live account equipment while unequipping restores a different legacy body. Complete the remaining accepted male fits and coherent same-body transition before account rollout. Existing legacy account paths remain unchanged. |
| 1 | Neutral Everyday and class-robe runtime/persistence audit | QA | Body v4, everyday v3 and robe v11 locked | Audit approved neutral rendering and female/neutral Everyday eligibility, equip/unequip, restoration and persistence. Corrected scoped server rollback QA passed; CI, any required durable server verification and actual delivered-runtime checks remain pending. |
| 1 | Neutral Woodland Scout candidate review | QA | CANDIDATE — NOT LOCKED | Keep the unaccepted neutral fit in explicit development review. Account eligibility remains female-only for Woodland Scout; candidate visibility does not authorize account capability promotion. |
| 1 | Remaining male garment templates | BUILDING | New robe template not yet locked | Existing unapproved male robe candidates remain in active development, including unfinished cuff work. Continue on the unchanged male v3 body/everyday v2 outfit. Template acceptance requires independent QA and Tanya's decision before class surfaces; no decision is requested now. |
| 2 | Issue #6: Warding Lantern and Emerald Wayfarer Rug | QUEUED | Replacement visuals not approved | Immediately after avatar/template work. Rebuild within the approved briefs and review at game scale. Keep both catalog entries inactive and preserve existing ownership until Tanya approves replacements. |
| 3 | Issue #7: architecture/scalability and replaceable presentation | QUEUED | Existing architecture decisions preserved | Follow #6 before launch. First bounded item: extract inventory/loadout data and duplicated slot mapping from presentation into a shared model, preserving behavior. Architecture protections continue throughout avatar work. |

## Tanya needed now

**No founder decision is currently requested.** Approved development and technical corrections continue. Future male template acceptance and #6 replacement approval are concrete later review points, not blockers to current work.

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

- Exact male source files and canonical references were recovered from approved `c1382db` work. Local file/alpha/RGBA preservation, source correspondence, composite pixels and independent visual QA passed; the art remains locked.
- Semantic QA found that the proposed male Everyday account path selected v3 while its unequipped legacy path selected different anatomy. That approach is rejected. Male account capability is being withheld; the dedicated review keeps v3 fixed while toggling only the clothing layer.
- Neutral Woodland is unaccepted. Its explicit review remains available for development; account support is not broadened beyond the existing female fit. Approved Everyday account support is female + neutral.
- CI `d526da11`: analyzer passed; 333 tests passed, 4 harness failures. CI `fcd9f987`: 346 passed, 1 Market modal harness failure. CI `88cda121`: 346 passed, the same remaining harness failure. A test-only `MediaQueryData` override had zeroed the viewport; its correction preserves actual view dimensions. These failed gates prevented deployment.
- The next full gate must include the corrected harness and same-body/account-eligibility safeguards. No passing deployment or runtime verification is claimed for those newer changes.
- Earlier broader server rollback QA is superseded. Revised rollback QA passed for female/neutral Everyday, female-only Woodland and no male support for either. Original functions were restored exactly, the helper is absent and zero fixtures remain. Prices, class restrictions, ownership, catalog activation and progression are preserved. No durable migration or male/neutral-Woodland account rollout is claimed.

- Served development baseline remains `7537b962e2d04033813131c0e410876b1a0e4e73`, verified through `questwell-version.json`. Third run `37174209362` failed; no candidate from this batch has been claimed as deployed.
