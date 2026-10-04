# Neutral robe v8 — drape, cuffs and trim

**Subsequently rejected for hand occlusion.** Tanya liked the widened cuffs, but adjacent main-front side panels obscured both thumbs. The previous visual QA incorrectly passed that assembled overlap. V9 retains the cuff geometry and corrects side-panel depth; see `NEUTRAL_ROBE_V9_CANDIDATE.md`.

Tanya rejected v7's excessive flare, rear gold/brown hem crossing the avatar's left leg, narrow inner cuffs and abruptly ending upper trim. V8 addresses those four garment issues on the exact approved neutral v4 body and everyday v3 clothes. Those five image files remain byte-for-byte fixed.

Built-in image generation rebuilt the complete robe using the previous garment, fixed dressed avatar and accepted female cuff construction as references. The retained source and prompt are under `tool/art_assets/neutral_robe_v8/`. The garment alone is registered to the fixed 240 × 320 canvas. The skirt falls with less spread, the lower sleeves widen toward the torso, and both front bands continue into the neck opening beneath the existing hair.

`node tool/export_neutral_robe_v8.cjs` exports four garment layers. Explicit geometric regions put the complete rear panel and bottom border behind the body, including the dark inner edges previously left over the trousers. The entire hollow cuff underside sits behind the wrist; the connected facing stays in front. Cloth sampling and depth assignment use the same high-resolution source coordinates before downsampling. Adjacent regions on the same depth plane overlap at export boundaries to prevent translucent resampling seams. No RGB threshold chooses the depth of dark cloth.

The stack is rear robe → fixed body → boots → trousers → top → robe front → fixed identity → robe collar → cuff faces. Only the collar cloth is occluded by the existing hair contour; neither the body nor identity is clipped or modified. The collar sits above the identity's inherited shirt/neck pixels so its trim is not cut off by the old row-84 boundary.

The exporter verifies immutable body/everyday hashes and rear-mask membership. That geometric check does not prove the illustrated panel is fully included: actual native and enlarged exports on light and dark backgrounds require independent visual review. Exact reviewed assets and findings are recorded in `visual_review.json`; geometry, alpha hashes and registration are in `fit_reference.json`.

This remains a founder fitting candidate. Do not propagate class variants or declare the neutral robe template approved before Tanya accepts it. Preserve these exact sources and reviewed exports for comparison. Runtime outfits, remote deployment, Market/accounts, merges and launch are outside this change; Flutter tests were not run for this offline art export.
