# Male Pumpkin Court surface repair

Tanya reported that this orange-and-green Halloween robe alone looked distorted
on the male avatar, and directed a fix. Scope is only male Pumpkin Court. The
male body, every other garment, existing Halloween layers, and inventory policy
remain byte-identical.

## Cause and repair

The original exporter scales each entire row from the generated surface's outer
silhouette. Sleeve-to-skirt width changes consequently distort both embroidered
lapels. A newly authored male surface now registers to continuous lapel landmarks
independent of sleeve widths. Three new files (`front_v2.webp`, `collar_v2.webp`,
`cuffs_v2.webp`) reuse every alpha pixel from the original layers. The renderer
selects them only for male Pumpkin Court; rear lining, mask, blouse, trousers,
boots, full body and original identity retain their existing assets.

The built-in imagegen edit used `male_locked_clothes.png` as the geometry target
and the previous Pumpkin Court male surface as the palette/ornament reference.
The generated PNG is preserved in `tool/art_assets/male_pumpkin_court_fit_v2/`.
Its complete prompt, export hashes, independent review, pinned Python dependency
versions and native/enlarged light/dark composites are in that folder. Smooth
enlargements resize each RGBA layer with bicubic interpolation before composition,
following the runtime layer order; nearest-neighbor views remain for pixel QA.
These deterministic diagnostics approximate the high-quality runtime filtering
behavior without claiming to be a Flutter engine capture.

## Verification

- Ran `python tool/export_male_pumpkin_court_fit_v2.py`: three versioned layers
  exported; all 304 pre-existing avatar assets unchanged; all alpha masks exact.
- Ran Python syntax compilation and Dart format with language version 3.0.
- Independent visual QA passed actual exports and final depth-ordered composite
  at native and enlarged sizes, on light and dark backgrounds. Lapels are more
  even, cuffs join coherently, and full hands/thumbs remain exposed. Existing
  small elbow contour steps and dark shoulder caps are inherited, not new gaps.
- Independent smooth-enlargement QA also passed both per-layer bicubic
  light/dark views: no filtering halos, alpha seams or disconnected collar joins;
  cuffs and lapels remained continuous. Exact reviewed PNG hashes are recorded.
- Added Flutter tests for decoded versioned bundles, exact alpha preservation,
  narrow body/costume selection across all classes, and unchanged male foundation
  across equip/unequip/rebuild. Flutter runtime tests require existing CI; no
  local Flutter execution is claimed. PR #121 CI initially stopped on the
  unnecessary `dart:typed_data` test import; that import is removed. CI 38016102425 at fa3820a passed 1,061 full-suite tests, 22
  decorator tests and 418 Chrome tests, plus Android/iOS and web/staging builds.
  Backend harness 38016102243 and all forward guard checks passed. Combined
  delivery with the room correction is tracked by PR #120; PR #121 preserves
  the scoped review. Hosted delivery remains separately verified.
- Backend contract, RLS and rewards are unchanged; no migration is involved.

Not verified at this record: delivered hosted runtime, physical iPhone, and
founder visual acceptance. Art acceptance remains separate from technical QA.

## Reproduce / roll back

Use the pinned versions in the asset folder's `requirements.txt`; run
`python tool/export_male_pumpkin_court_fit_v2.py`. Generated sources are preserved;
rerunning does not need a paid generation call. Runtime rollback removes the
male Pumpkin Court version suffix selection in `QuestwellHalloweenCostume`;
all original assets remain available.

Official API references checked: Pillow Image module
(https://pillow.readthedocs.io/en/stable/reference/Image.html), SciPy
`map_coordinates` and `distance_transform_edt` reference pages, NumPy `interp`
reference page, and Flutter `Image.toByteData` / `FilterQuality.high` documentation. No app dependency
or Flutter SDK version changed.
