# Male robes: sleeve edges and thumb-area depth

Status: **QA / DEV DEPLOYING**. Founder-requested scoped repair; no new art/template lock.

Tanya reported persistent holes beside the thumbs and dark outer sleeve outlines on 2026-10-04. The earlier rear repair closed transparent gaps, but Everyday trouser pixels still rendered above the rear lining. The foreground surfaces also contained broad dark sleeve contours. This supersedes the earlier detail visual PASS.

The shared renderer and dedicated review now use new front surfaces (Scout v4; Scholar, Alchemist, Guardian and Wanderer v2) with the exact historical front alpha. Built-in image editing supplied continuous sleeve shading; the exporter imports only RGB inside the recorded outer-sleeve region, matching the existing class color and retaining insignia. All other pixels and geometry are preserved. Source, prompt, export code and hashes are versioned.

`QuestwellMaleEverydayGarment` renders the original single Everyday v2 file. Only under a robe, `MaleRobeUnderlayClipper` hides its trouser pixels under the existing connected rear lining. The primary body is never clipped, shifted, recolored, replaced or duplicated. No hand replacement image is used. The original rear → body → Everyday → front → identity → collar → cuffs order remains intact. The clip disappears when Everyday is equipped alone.

## Export verification

`node tool/verify_male_robe_edge_repair.cjs` passes: all five foreground alpha hashes exactly match historical v3; all body/identity/Everyday/rear/collar/cuff and historical files retain their hashes; surface edits are restricted to the recorded region. Each class checks 41 fully opaque original hand pixels and final thumb color against body-over-lining composition. The former opaque brown trouser witness at (156,190) now resolves to each class's lining. These checks supplement visual review; alpha=255 alone was insufficient.

Native full figures, enlarged shoulders/sleeves/thumbs and light/dark backgrounds were inspected across all five classes. Guardian before/after shows removal of the brown sliver and broad black sleeve bands. Cuffs, fingers, class motifs and natural underarm space remain. `tool/art_assets/male_robe_edge_repair_v2/verification.json` records the read-only results.

Local asset manifest verification and 8 Node tests pass. The Flutter regressions additionally cover all class masks, robe-only occlusion at multiple canvas sizes, shared-renderer equip/unequip, unchanged body ancestry and one unified Everyday overlay. Full CI and deployed revision/asset/runtime checks are pending.

The mandatory gate correctly prevented deployment of `f3447dd` (missing import in the concurrent legacy tests) and `d0a975c` (351 passed / 22 failed). Nine older tests incorrectly prohibited the new garment-only clip; their replacements explicitly allow only that garment image and assert zero body-clipping ancestors. Concurrent legacy migration exposed ten female/neutral body-clipping failures, corrected by recognizing their locked foundations in legacy states. Three legacy-art expectations were updated to assert the new locked foundations and absence of old class coats. No test was skipped or gate bypassed. The six new male repair regressions already passed in the failed full run.

## Scope and limits

No database, eligibility, prices, ownership, economy or equipment policy changes. Male Everyday remains enabled, Woodland female-only; legacy male availability and belt-only grimoire remain intact. Persistence was verified through deployed public RPCs in the preceding integration using rolled-back synthetic identities. Browser checks use in-memory app fixtures; no real-user sign-in or private account refresh is claimed. No production promotion or merge to flutterflow.
