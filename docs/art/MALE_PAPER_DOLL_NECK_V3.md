# Male paper doll — wider neck and fragment cleanup

Tanya rejected v2 because the neck remained narrow and fragmented. She explicitly requested a wider neck proportional to the muscular body, fragment removal, and pixel cleanup. V3 replaces the complete local neck connection, including its alpha contour, rather than retaining v2's defective silhouette.

## Reviewed source files

- `tool/art_assets/male_paper_doll_v3/paper_doll_male_candidate_v3.webp`: registered 240 × 320 draft.
- `tool/art_assets/male_paper_doll_v3/paper_doll_male_identity_candidate_v3.webp`: identity foreground derived from the repaired draft, never from the old fragmented join.
- `tool/art_assets/male_paper_doll_v3/male_paper_doll_review_v3.png`: transparent full-figure review.
- `tool/art_assets/male_paper_doll_v3/male_paper_doll_review_v3_light.png`: full-figure review on an opaque light background.
- `tool/art_assets/male_paper_doll_v3/neck_detail_v3.png`: enlarged registered neck.
- `tool/art_assets/male_paper_doll_v3/neck_repair_source.png`: original built-in image-editing output.
- `tool/art_assets/male_paper_doll_v3/prompt.json`: exact prompt and provenance.

Reproduce with `node tool/export_male_neck_v3.cjs`. The generated patch is registered to the existing shoulder height with a tapered local offset of at most two native pixels. It is then antialiased and imported through a coherent shaped mask below the jaw. Premultiplied RGBA blending avoids transparent-color fringes. The original avatar supplies every pixel outside the repair; it is not warped or resized to accommodate the patch.

## Verification

The final export changes 937 visible/alpha pixels within x96–146, y67–91. No visible RGB or alpha changes occur outside the repair rectangle. Fully transparent hidden RGB is not an appearance invariant. The approved female and neutral asset verification passes without modifications. The neck is visibly broader under the jaw and the transition to the ivory collar is continuous. Independent visual review of the full figure and opaque light/dark close-ups found no detached local fragments, doubled shoulder strokes, or obvious neck seam. Enlarged crops remain limited by the native 240 × 320 sprite resolution; this is not a whole-avatar upscale or cleanup.

## Founder approval and immutable lock

Tanya explicitly approved this exact foundation on **2026-10-03 (America/New_York)**: “male foundation is approved”. This approval is separate from the independent visual QA above. V3 is now the locked male foundation; the source filenames retain `candidate` as historical provenance.

The following versioned foundation assets are exact byte copies of the reviewed exports, with no re-encoding or pixel changes:

| Asset | Locked path | SHA-256 |
| --- | --- | --- |
| Complete body | `assets/images/questwell/avatar/base/paper_doll_male_v3.webp` | `9e35a6ebdda22719851fa37f33c81f2b6c1340719453bf50d9ac4acf9156ebda` |
| Original identity | `assets/images/questwell/avatar/base/paper_doll_male_identity_v3.webp` | `efe243c89320352e61f858dd0c5335f99f61ee91788e2b37efdb3ff58b631a1a` |

`tool/male_avatar_fit_reference.json` is the canonical fit reference. Preserve the complete body and identity byte-for-byte, including all anatomy, pose, face/hair, neck, arms, hands, legs, feet and alpha values. The canvas is 240 × 320 with top-left origin, zero offset, unit scale and no rotation. Clothing may normally occlude the intact body; never clip, mask, regenerate, replace, shift or reshape the body to accommodate a garment. Any future body revision requires a separate explicit request and founder approval. The reproduction script records the historical repair process; do not rerun it to overwrite the locked assets during clothing work.

The current requested sequence is male everyday clothing → male robe fit and template acceptance → all male class robe surfaces → male Woodland Scout. Each foundational garment fit needs its own independent visual review and Tanya's acceptance before becoming a template. Neutral Woodland Scout remains unfinished backlog; the latest male request supersedes the prior neutral-first work order.

This lock adds versioned foundation files only. Runtime avatar selection, app code, equipped avatars and account/Market data are unchanged. It does not authorize a merge, launch or publication. Retain v1 and rejected v2 for history.
