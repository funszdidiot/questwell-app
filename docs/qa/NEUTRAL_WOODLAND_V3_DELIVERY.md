# Neutral Woodland Scout v3: delivered candidate QA

Status: **DEV DEPLOYED — explicit development review only**. Art remains **CANDIDATE / NOT LOCKED**. No founder decision is requested by this technical check.

## Verified delivery

On 2026-10-04, revision `993433552a012d7497d08da36a2a32dce4b470ae` served the exact v3 outfit on locked neutral v4. Workflow `37231008707` passed asset integrity, analysis, all 373 Flutter regressions, 8 Node tests, web build and deployment. `tool/qa/verify_neutral_woodland_delivery.py` fetched and matched all ten assets used by the four-stage review: body, identity, Woodland, three Everyday layers and four Scout robe layers.

Review URL: https://funszdidiot.github.io/questwell-app/?review=neutral-scout

## Scoped export checks

The existing `tool/repair_neutral_woodland_v3.cjs` implements the two findings in the independent v2 audit at `tool/qa/neutral_woodland_audit_20261004/review.json`. This continuation does not regenerate or edit the outfit.

`node tool/verify_neutral_woodland_v3.cjs --render-qa` passes:

- exactly 17 changed garment pixels compared with v2, and none elsewhere;
- 12 audited right-hand-edge pixels are transparent, exposing the original hand;
- five audited inner-heel pixels are fully opaque;
- exact 240×320 canvas and original body → single outfit → identity composition;
- locked body SHA-256 `bad2b39c90793b937308eff3de32550fd9ecf06c90140e1233902442fcc7fc24`;
- locked identity SHA-256 `29c6d9fe613fe76c4b924bcb4d8c155ec89ffd55de1e41e56fd999eb9f3b0f78`;
- candidate outfit SHA-256 `57adcddeb64047799e536ec221dd826beb2036ef3a7611e1b45d5a3e915f69f9`.

Reproducible native/light/dark/enlarged composites and the machine-readable result are in `tool/qa/neutral_woodland_v3/`. Visual inspection found connected sleeves, coherent waist/crotch/inner legs, complete hands and correctly oriented boots without the audited heel leaks. No new foundation or garment geometry was created in this continuation.

## Actual runtime checks

- Four-stage review rendered the same locked foundation in Fixed base, Everyday, Woodland and Scout robe.
- Fit details showed complete sleeve joins and wrists; Woodland no longer obscured the audited hand edge.
- Woodland off exposed the same foundation as Fixed base; on restored one complete outfit.
- Reload rebuilt the same four-stage renderer and candidate, with no body substitution.
- The 390px Market fixture showed neutral / Scout and a disabled **Fit unavailable** action for Woodland, with female-body explanatory text and unchanged 120-coin price. No purchase or account write was attempted.
- Existing Flutter regressions cover all 32 layer subsets, unchanged body bounds, no body ClipPath, exact layer order, all 17 repaired pixels and responsive review at 320/390/1200px. These passed in the delivered full gate.

Evidence: `neutral-woodland-v3-live.jpg`, `neutral-woodland-v3-live-details.jpg`, `neutral-woodland-v3-market-gate.jpg`.

## Limits and next work

This verifies delivery of a development candidate, not account wardrobe rollout or founder acceptance. Woodland account support remains female-only. Neutral inventory persistence is intentionally not enabled or claimed. No prices, ownership, economy, equipment policy, grimoire attachment, retired boots or locked artwork changed. Browser checks used public in-memory fixtures, not a private signed-in account. No Safari/device testing or new independent v3 visual signoff is claimed; the prior independent v2 audit remains historical and separate from this technical repair verification.

Continue detailed legacy garment fit QA on the locked foundations. Do not convert this candidate into a decorative geometry template or expand account capability without the applicable founder decision. Active candidate visual development remains allowed and is not an approval blocker.
