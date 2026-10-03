# Male paper doll — wider neck and fragment cleanup

Tanya rejected v2 because the neck remained narrow and fragmented. She explicitly requested a wider neck proportional to the muscular body, fragment removal, and pixel cleanup. V3 replaces the complete local neck connection, including its alpha contour, rather than retaining v2's defective silhouette.

## Draft files

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

This remains an **unapproved male foundation**, not a locked body or a runtime-avatar replacement. No male outfits, app code, equipped avatars, account/Market data, merge, or launch changed. Complete neutral everyday clothing, robes and Woodland Scout before any male outfits, as specified in `PAPER_DOLL_STANDARD.md`. Retain v1 and rejected v2 for history.
