# Halloween wrist and hip correction — October 10, 2026

Tanya rejected doubled female cuffs, neutral rectangular cloth below the hands, and wavy/pinched hip facings. Her direction to fix these authorizes this versioned garment-fit correction across both costumes and all three bodies. Earlier RGB-only repairs were delivered but did not establish complete visual acceptance.

The six imagegen edits preserve the outfit designs while smoothing coat panels. The exporter traces connected source garment regions at 4× resolution, removes background fringe before one downsample, and retains the original complete body, identity, trousers/blouse/boots underlay and mask. Original hand components (including dark outlines) put overlapping side cloth behind the body. Cuffs now belong to the coherent front garment; the empty cuff depth pass preserves renderer structure. Neutral obsolete side rectangles are removed from the rear garment. No historical or locked template is overwritten. New fit assets use `_fit_v4`.

Source images, prompts, source-traced masks, final native/enlarged light/dark composites, hashes and independent review are in `tool/art_assets/halloween_wrist_hip_v1/`. Reproduce with `node tool/export_halloween_wrist_hip.cjs` and ImageMagick 6.9.12-98. No runtime transforms or body masks are introduced.

Independent visual review: PASS all six. Initial extraction attempts were rejected for seams, fringe and shoulder clipping; only the final reviewed set is integrated. Export asserts locked input hashes and unobscured original hand components. Existing tests cover all 30 body/class/costume routes, decoding and same-body equip/unequip/reload at narrow/wide widths. Historical RGB-preservation tests continue checking historical assets explicitly.

PR #136 review identified thin neutral rear-side hem fragments missed in the initial visual pass. Full-height cleanup removes them; an independent follow-up passed all eight revised neutral composites with continuous center lining and no new wrist, hip or hem holes. Other four variants remain unchanged.

Development CI and hosted verification are pending; final revision, served hashes and runtime checks belong in the PR delivery comment. No pricing, availability, inventory/account or database changes. No production promotion, physical-device acceptance or new founder art lock is claimed.

Rollback: restore prior `assetPath` version selection; historical assets remain intact.
