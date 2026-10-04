# Male Woodland Scout v1 integration evidence

Current production stage: **DEV DEPLOYED** at `0330c3b57cf1d26e0979a072999c060af444b694` (workflow `37213357594`). Art status: **candidate, not founder-locked**.

## Verified before deployment

- Locked male v3 body and identity and approved Everyday v2 hashes are unchanged.
- One coherent generated outfit is registered and rendered as a single overlay; the complete body remains underneath.
- Independent export QA passed on the exact delivered-candidate hash, recorded in `tool/qa/male_woodland_v1_export_review.json`.
- `node tool/verify_male_woodland_v1.cjs` passed source/export/composite preservation, 6,111 garment coverage pixels and 872 hand-clearance samples. Independent visual QA additionally isolates both complete opaque hand silhouettes (965 pixels) and checks 6,383 covered body pixels.
- The full existing asset manifest and all 8 Node checks passed locally. No local Flutter SDK is available; the mandatory development workflow remains the analyzer/Flutter/build gate.
- New regressions cover actual shorts/crotch/calf/heel/buckle defects, all four wardrobe transitions, belt grimoire on/off and route recreation at 320, 390 and 1363 pixels.

## Scope and unchanged boundaries

The candidate is reachable through `?review=male-woodland` and the existing male wardrobe review. Body only, approved Everyday, robes and Woodland use the exact same foundation. One stage enum keeps the candidate from combining with robe or Everyday layers. Light/dark views and native/enlarged controls exercise the actual renderer.

The route uses local review state and no account, catalog, persistence or authentication writes. Account Woodland support remains female Scout only; no male/neutral eligibility or class expansion is introduced. Existing inventory/catalog/equipment regression tests remain mandatory. Reload must restore the route's Woodland state on the same foundation; it must not alter saved equipment.

Neutral v2 received an independent source/export audit under `tool/qa/neutral_woodland_audit_20261004/`. It remains QA with small right-hand intrusion and inner-heel opacity repairs outstanding. No neutral asset was changed or accepted in this delivery.

## Delivered verification

Workflow `37213357594` passed all **367 Flutter tests, 8 Node tests**, the asset-integrity gate, analyzer, release web build and development deployment. The delivered `questwell-version.json` identifies `0330c3b57cf1d26e0979a072999c060af444b694`. All five fetched runtime assets (body, identity, Everyday, Woodland and belt book) match repository SHA-256 values.

Actual browser controls passed Body only → Everyday → Scout robe → Scholar robe → Woodland, grimoire on/off, enlarged light/dark views and route reload. Native and enlarged screenshots were inspected by the continuation reviewer against the unchanged independently reviewed export. Shoulders, rolled sleeves, exposed hands, waist/hips, crotch, inner legs, trouser seams and correct boot/heel/sole coverage show no blocking defect. The original independent export PASS remains attached to the exact unchanged candidate hash. This is technical/visual QA, not Tanya's approval.

The delivered 390px sample Market shows the Woodland card and explicitly labelled **Female fit preview**, both with **Fit unavailable** for a male Scout. The full regression suite verifies inventory/catalog routes, Scout-only collection metadata, female-only account support, retirement of Pathfinder boots, retained ownership and protected unsupported-equipment behavior. No catalog, backend policy, economy, saved loadout or account writes changed. This proves the candidate/account boundary; it does not complete the queued male account wardrobe migration.

The existing all-five male robe gallery also rendered correctly. Historical v3, sixteen class layers and all five requested thumb repairs pass their preservation checks. No robe was regenerated, no historical lock was reopened, and no repair was promoted to a newly locked template.

Evidence: `tool/qa/male_woodland_v1_delivery.json` and the five `docs/qa/*0330c3b.jpg` captures. Review: https://funszdidiot.github.io/questwell-app/?review=male-woodland&rev=0330c3b . Phone-width evidence is from widget tests at 320 and 390 pixels; this is not physical iOS/Safari validation. Real-user saved-loadout restoration was not exercised because male account rollout remains queued.

## October 4 continuation reconciliation

The unfinished Woodland work was recovered unchanged into an isolated worktree. The original worktree remains intact. The exact approved Everyday v2 was already ingested and verified; it was not regenerated. Historical male robe v3 acceptance and all five subsequent development surfaces/repair exports were recovered from the governing registry and preserved. The current priority is Woodland delivery, with no new robe/template lock or account capability inferred.
