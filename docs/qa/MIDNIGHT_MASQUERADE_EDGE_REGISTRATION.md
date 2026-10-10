# Midnight Masquerade surface registration repair

Tanya marked distorted female shoulders, cuffs and hems and explicitly requested
checking/fixing all avatar versions on October 10, 2026. Independent baseline
review found edge RGB spreading and uneven trim in all three versions. The
existing body-specific geometry remains valid and unchanged.

## Implementation

New front/cuffs v2 on female, neutral and male, plus neutral/male collar v2,
repair only scoped garment RGB. The original exporter padded source-edge colors
then warped a whole surface into the fixed masks; this spread near-black colors
into shoulders/cuffs/hems. The separate collar layer also carried shoulder-cap
pixels on neutral/male. The repair colors each relevant layer directly.

`node tool/export_midnight_masquerade_edges.cjs` uses Node built-ins and pinned
ImageMagick 6.9.12-98. Female source is the exact user-selected screenshot;
registration measured against the original is x*1.245+51, y*1.245+22. Neutral
and male sources edit their own actual exported composites. Generated bodies
are never imported. Historical assets remain unchanged.

Every alpha value, silhouette, canvas, registration and layer order remains
exact. Body/identity/hands, underlays, face masks and rear layers are unchanged.
Purple folds and charcoal embroidered panels remain intact outside the selected
edge regions. Pumpkin Court delivery and all account/economy policy are unchanged.

## Verification

- Deterministic export asserts exact alpha, unselected visible RGB and locked
  body/template source hashes. Asset integrity, syntax, formatting and diff
  checks pass.
- Independent reviewer `/root/pumpkin_edge_review`: PASS on all actual native
  and 3x light/dark composites, masks, export records and exporter. Coherent
  thin gold hems/cuffs, repaired shoulders, unchanged identity/hands/geometry,
  no new colored blocks or hand occlusion. Neutral's small rear-panel exposure
  beside the hands is pre-existing and unchanged.
- Dart tests cover the eight changed layers' exact alpha and bounded RGB,
  protected layers, all 30 class/body/costume routes and same-body outfit toggles.
- Local Flutter remains blocked by the earlier safety review and was not rerun.
  CI, merge and delivered-runtime evidence belong to this PR, not inferred here.
  No signed-in account persistence or physical-device acceptance is claimed.

Artwork, prompts, masks and actual composites:
`tool/art_assets/midnight_masquerade_edges_v2/`.

## Rollback

Revert this PR's renderer selection. All original files remain available; no
migration, catalog, inventory, reward or account mutation is involved.
