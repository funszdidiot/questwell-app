# Male Pumpkin Court edge cleanup

Scope approved by Tanya on October 10, 2026: remove excessive dark shoulder,
outer-sleeve and hem bands. This is a color-only repair, not a new body or fit.

## Implementation

The v2 exporter extended source edge colors into the locked garment mask.
The generated full-character preview is NOT a replacement avatar. Its edge
colors are imported only into bounded front garment regions and rear hem,
through `tool/export_pumpkin_court_edges.cjs`. Existing alpha values are exact;
body, identity, blouse, trousers, boots, mask, cuffs, collar and all old assets
are untouched. The renderer selects `front_v3.webp` and `rear_v3.webp` only for
male Pumpkin Court. Collar/cuffs retain v2. Other bodies/costumes are unchanged.

Reproduction uses Node built-ins and ImageMagick **6.9.12-98**, checked by the
export script. No Flutter, npm or application dependency changed. The preserved
imagegen edit source, change masks, hashes and actual layer composites are in
`tool/art_assets/pumpkin_court_edges_v3/`.

## Verification

- Deterministic export assertions pass: exact alpha and unchanged visible RGB
  outside each selected mask; locked male source hashes match.
- `python3 tool/verify_avatar_assets.py`: PASS, registered locked assets intact.
- Dart formatting and `git diff --check`: PASS.
- Independent reviewer `/root/pumpkin_edge_review`: PASS on actual exported
  native and 3x composites, both light/dark. Heavy bands removed; embroidery,
  gold trim, back panel, exposed hands and fixed identity remain coherent.
  Minor nonblocking note: isolated dark edge pixels at 3x, no broad native band.
- Flutter tests extended for all four garment alphas, bounded RGB changes,
  shoulder/hem color regressions, version selection for all class/body pairs,
  and same-body equip/unequip/rebuild behavior.

Local Flutter execution was blocked by the safety reviewer after unexpected
cloud metadata endpoint access. It was not retried. CI must run Flutter checks.
No local Flutter pass, hosted runtime, signed-in persistence or physical-device
acceptance is claimed. Backend/RLS/rewards are unchanged and need no migration.

## Rollback

Revert this scoped PR. All previous assets remain available and unchanged;
restore the previous renderer selection (front/collar/cuffs v2, original rear).
No account, inventory, economy or schema mutation is involved.

Official tool references checked:
- https://imagemagick.org/command-line-options/
- https://imagemagick.org/webp/

Founder art acceptance, technical QA, merge and hosted delivery remain separate.
