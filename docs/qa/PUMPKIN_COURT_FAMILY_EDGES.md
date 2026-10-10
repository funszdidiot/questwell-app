# Female and neutral Pumpkin Court edge cleanup

Tanya reported the same female outline defect and requested a neutral check on
October 10, 2026. Independent baseline review confirmed female shoulder/sleeve,
cuff and hem bands; neutral needs cuff/hem cleanup only. Neutral's fine shoulder
outline and both bodies' dark green rear lining remain unchanged.

## Scope

- New female/neutral `front_v2.webp` and `cuffs_v2.webp` import only selected RGB
  into existing masks. Alpha, silhouette, registration and runtime layer order
  are exact. Every unselected visible RGB pixel is unchanged.
- Bodies, identity, hands, underlay, mask, rear, neutral collar, all old files,
  male v3 delivery and Midnight Masquerade remain unchanged.
- The female imagegen edit used Tanya's exact screenshot. Source registration
  was measured against the original screenshot: x*1.245-58, y*1.245-26.
  Neutral uses its actual original composite as the edit target. Neither full
  generated character is imported into the application.
- Reproduce with `node tool/export_pumpkin_court_family_edges.cjs` using
  ImageMagick 6.9.12-98. No new app/package dependency is required.

## Verification

Deterministic export checks verify exact alpha, protected RGB and locked input
hashes. Actual native/3x light/dark composites, change masks, source prompts and
output hashes are retained in `tool/art_assets/pumpkin_court_edges_v4/`.
Dart tests cover both alpha masks, protected regions including neutral shoulders
and below-hand pixels, unchanged layer paths, all 30 class/body/costume mappings,
and the existing same-body equip/unequip checks.

Local asset integrity, exporter and Dart formatting checks pass. Local Flutter
remains unavailable after the earlier safety-review rejection and was not retried.
CI and delivered runtime results belong in the pull request; neither is assumed.
No account/inventory/economy/database mutation or physical-device acceptance is
included. Founder art acceptance remains separate from technical QA.

## Rollback

Revert this scoped PR to restore original female/neutral front/cuff selection.
All historical artwork remains available. The male v3 correction is independent.
