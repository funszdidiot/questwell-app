# Male Woodland Scout v1 integration evidence

Current production stage: **QA**. Art status: **candidate, not founder-locked**.

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

## Delivery checks still pending

Exact CI revision and full Flutter count, development version stamp, delivered asset hashes, live controls/reload, independent delivered screenshot QA and founder dashboard publishing verification must pass before DEV DEPLOYED is recorded.

## October 4 continuation reconciliation

The unfinished Woodland work was recovered unchanged into an isolated worktree. The original worktree remains intact. The exact approved Everyday v2 was already ingested and verified; it was not regenerated. Historical male robe v3 acceptance and all five subsequent development surfaces/repair exports were recovered from the governing registry and preserved. The current priority is Woodland delivery, with no new robe/template lock or account capability inferred.
