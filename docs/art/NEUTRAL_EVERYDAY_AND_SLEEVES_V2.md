# Neutral everyday wardrobe and Woodland sleeves — 2026-10-03

Tanya requested the neutral body's own everyday clothes beneath robes, matching the female wardrobe construction, and a correction to the Woodland Scout sleeves. The approved neutral frame and identity remain byte-for-byte unchanged. Female artwork, the neutral robe and other class fits are untouched.

## New garments

All runtime sprites use the fixed 240 × 320 canvas with bottom-center alignment and no runtime transforms:

- `assets/images/questwell/avatar/everyday_top_neutral_v1.webp`: ivory short-sleeved linen top.
- `assets/images/questwell/avatar/everyday_trousers_neutral_v1.webp`: plain brown travel trousers with a small belt, no boots or knee patches.
- `assets/images/questwell/avatar/everyday_boots_neutral_v1.webp`: independent brown ankle boots, including complete toe/heel/sole coverage.
- `assets/images/questwell/avatar/everyday_top_robe_under_neutral_v1.webp`: the same top pixels with only its concealed shoulder/sleeve cloth occluded beneath the enclosing robe. This is garment-only occlusion; the body is never clipped or replaced.
- `assets/images/questwell/avatar/woodland_scout_unified_neutral_v2.webp`: corrected rolled sleeves with attached, rounder openings and paired tabs. Every pixel outside the two short-sleeve edit regions is identical to v1; no other outfit piece is regenerated in the runtime asset.

The robe now combines with the everyday pieces, not the Woodland vest, reinforced trousers and tall boots. Woodland is a separate complete outfit; selecting a robe suppresses Woodland and uses whichever everyday layers are selected.

## Source and reproducibility

Built-in image generation/editing produced the three retained source drawings in `tool/art_assets/neutral_scout_v2/`: `everyday_source.png`, `boots_fitted_source.png`, and `sleeves_fitted_source.png`. The complete prompts are in `prompts.json`. Direction: fit plain ivory linen, straight brown trousers and compact ankle boots to the locked neutral frame; cover the exposed foot edges; correct only the rolled Woodland sleeves, preserving paired tabs and all other design details. Generated character anatomy is never imported.

Run `node tool/neutral_fit_reference.cjs`, `node tool/export_neutral_everyday.cjs`, and `node tool/export_neutral_sleeves.cjs` to reproduce references and assets. The everyday exporter registers the drawing, separates top/trousers/boots at their seams and imports only the corrected footwear. The sleeve exporter selects the corrected linen and blends it into the existing shoulder art. Source and runtime hashes are recorded in `tool/avatar_assets.json`.

## Review and validation

The development-only `?review=neutral-scout` page now shows four equal-scale stages: fixed base, everyday clothes, Woodland Scout and Scout robe. Top, trousers, boots, robe and Woodland have independent controls; fit details show upper sleeves and wrists. Narrow screens scroll the comparison horizontally.

Local coverage checks found zero uncovered opaque leg/foot pixels with the full everyday set. Regression tests cover all 32 control combinations, unchanged body geometry, exact cloth order, independent footwear, untouched non-sleeve pixels, garment-only top occlusion and 320/390/1200-pixel review layouts. Flutter validation runs in CI because the local workspace has no Flutter SDK.

Visual acceptance is still pending Tanya's review. This is a development fitting update, not a Market/account change, merge to `flutterflow`, class-template approval or launch.
