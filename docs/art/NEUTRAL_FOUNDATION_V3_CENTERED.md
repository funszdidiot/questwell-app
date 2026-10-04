# Neutral foundation v3 — centered head

**Rejected after founder visual review; superseded by v4.** The head alignment improved, but v3 retained pasted under-jaw shading and lower-hair fragments. Its earlier visual-completion claim below was incorrect. Do not reuse v3 as the fitting reference. See `NEUTRAL_FOUNDATION_V4_JOIN.md`.

Tanya identified that the repaired head was not centered on the neck. The v2 seam repair had preserved a chin center around x118.5 on a neck base centered around x123. The v3 correction translates the original head four native pixels to the right. It does not scale, rotate, mirror or redraw the original face. The resulting chin center is x122.5, within half a native pixel of the fixed neck-base center.

## Exact edit source and implementation

The exact image Tanya selected was used as the built-in imagegen edit source, preserved as `tool/art_assets/neutral_paper_doll_v3/selected_edit_source.png`. Its generated alignment correction supplies only the small under-jaw/lower-hair transition. The full avatar's original head artwork above y74 is translated directly from v2, with zero changed source pixels after accounting for that translation. No generated face is used.

`node tool/export_neutral_alignment_v3.cjs` writes the registered 240 × 320 base, matching head/neck foreground, full-body preview and enlarged detail. Pixel comparison confirms zero visible or alpha changes from y84 downward: collar base, shoulders, torso, undergarments, arms, hands, hips, legs and feet remain fixed. The new foreground includes the complete corrected head/neck region so an old cut-line cannot be restored.

## Lock and review

The canonical paths and hashes are in `tool/neutral_avatar_fit_reference.json` and `tool/avatar_assets.json`. V3 supersedes v2. Its head anchor is fixed for future headwear/accessory fitting; it must not shift to fit a garment. Full-figure and neck-detail review confirmed the centered connection. The existing face-preservation regression expectation now accounts for the explicitly authorized four-pixel translation; Flutter tests were not run in this local environment.

This continues Tanya's directive to correct and lock the foundation before clothing. It does not approve any everyday, robe or Woodland Scout fitting. No clothes were changed, and no remote push or live deployment occurred; the earlier repository publication approval remains outstanding.
