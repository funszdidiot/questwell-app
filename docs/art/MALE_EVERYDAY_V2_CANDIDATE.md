# Male everyday v2 — approved and locked unified outfit

Tanya accepted the exact final v2 outfit in the current turn on **2026-10-04 (UTC)**: “It's good. Next”. Founder approval is separate from the independent visual review. `tool/male_everyday_fit_reference.json` is the canonical lock; male robe fitting may now proceed over this unchanged outfit and body.

Tanya rejected v1 because its sleeves did not wrap the upper arms naturally, the boots appeared on the wrong feet and the crotch construction looked wrong. V1's earlier QA result is superseded by that rejection. Male body v3 and its identity remain approved and immutable.

V2 remains **one complete outfit overlay**. It has no shirt, trouser or boot component exports, no anatomy replacement and no runtime component assembly. The actual final composite is the original body → unified outfit → original identity.

## Drawing and fitting

Built-in imagegen supplied a coherent full-outfit redraw with sleeves that follow the upper arms and a clean round collar. Broad redraw attempts drifted from the fixed anatomy at the inner thighs and soles, so those complete connected regions were redrawn at close range against the exact body references. The complete pelvis/inner-thigh drawing replaces the hanging crotch wedge; a continuous antialiased contour registration joins it to the existing leg fall. Both boots were redrawn with correctly oriented toe boxes and shallow, continuous low soles that contain the unchanged feet.

Drawing corrections are incorporated into the single outfit image. They are not modular wardrobe items. The importer uses complete alpha contours and confines color blending to opaque cloth interiors, avoiding crossfades between displaced transparent silhouettes. All sources and reproduction logic remain in `tool/art_assets/male_everyday_v2/` and `tool/export_male_everyday_v2.cjs`.

The full-figure generated study is a fitting reference only. Its face, body, arms and hands are never used in the final export. Original foundation and identity hashes are verified before and after every export.

## Review

Inspect the actual `male_everyday_light.png`, `male_everyday_dark.png` and native composite, plus sleeve, crotch and boot enlargements. Review garment construction and perspective before coverage statistics: sleeves must wrap the arms; fly and inseams must meet near the pelvis and flow into continuous inner-leg contours; paired boots must follow the original feet with coherent heels and soles. A previous stepped inner-thigh transition was corrected before final review.

`fit_reference.json` pins the approved unified outfit, original body, source drawings, repair registrations and layer order. `visual_review.json` preserves the independent findings and records the subsequent founder acceptance separately. Source filenames retain `candidate` as provenance.

The exact approved export is copied without re-encoding to `assets/images/questwell/avatar/everyday_outfit_male_v2.webp`:

| Invariant | SHA-256 |
| --- | --- |
| Outfit file, reviewed source and runtime copy | `f1677830404354248d8fe13c1aec35da059946c7ee902ff21411dcca584b2cee` |
| Outfit alpha plane | `97b18acceae5a7c66698f18f7ca927069c9a478ec4c78800786bd80b7d60c282` |
| Reviewed native composite | `40acdf0a9b67be787f47a41fa51d12446d3e44392375fd15dfd7f53710c1eeef` |

Preserve the entire outfit and its exact alpha values, fit, source registration and body → outfit → identity order. The exported 240 × 320 overlay uses zero runtime offsets and unit scale. Keep the body and identity byte-for-byte fixed while fitting robes; do not split, warp, redraw or reassemble the approved outfit. Structural revisions need explicit new founder review. The exporter now verifies the lock and returns without regenerating files or overwriting approval metadata.

The male robe remains a separate fit requiring independent QA and founder acceptance before class surfaces. Runtime body/outfit selection, account data and live deployment are unchanged by this lock.
