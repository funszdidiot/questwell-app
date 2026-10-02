# Pumpkin Sprite — Midnight Harvest

Approved pumpkin companion replaces the proposed seasonal fox. Market and inventory use a code-native 32-pixel icon matching the other familiar icons; the Hearth uses the separately generated detailed 64-bit-style artwork with stronger amber eye glow. Both preserve transparent backgrounds.

- Slug: `pumpkin-sprite`; category: `familiar`; rare; all classes; 180 earned coins.
- Full art: `assets/images/questwell_familiar_pumpkin-sprite_v1.webp`.
- Icon: `QuestwellItemIconPainter`, on the shared 32×32 grid with chunky outlines and limited shading. The earlier generated icon asset is superseded.
- The familiar shares existing gentle idle motion and reduced-motion/offscreen behavior; glow is painted into the asset.
- Feet align to the existing companion baseline using the artwork's visible alpha bounds. The purchase grants permanent ownership; companion equipment uses the existing exclusive familiar slot.
- Catalog migration stages the item inactive until development preview verification. Founder grant is free and unequipped; preserve current equipment and balance.
- Review: `?review=hearth-settings` shows the companion in four furnished settings; `?review=market` includes its icon and purchase/equip flow with sample data.
- QA: existing familiar body/layout coverage includes the pumpkin; all 40 shop icons are checked through the shared painter. `tool/qa/pumpkin_sprite_market_check.sql` exercises purchase, retry, equip and removal in a rolled-back fixture.

Art created with the built-in image tool. Final edit preserves the approved pumpkin and increases only the amber light filling both carved eye cavities, with short-range golden bloom and warm rind highlights. Original 16-bit icon is retained separately.

## Verified release — 2026-10-02

Code `c60f15a62af56ac4b21243ef65bafc6d11ad2602` passed Flutter Check `37075296893` and Preview `37075296888`. Visually checked the glowing companion in all four review settings and the separate 16-bit Market icon at 390 px content width. Purchase/retry/equip/unequip SQL QA passed; security advisors returned no findings. Activated the 180-coin listing and verified the founder grant is owned, unequipped, with coin balance unchanged at 847. Development branch only; no public launch or merge.

## Icon consistency correction

Founder screenshot showed the generated thumbnail was too detailed beside Mushroom Familiar and Tiny Owl. Replaced the bitmap exception with a simplified pumpkin in the shared catalog painter: block eyes, amber highlights, broad orange shading, green leaf and short root feet. Detailed Hearth art and ownership are unchanged. All 40 catalog entries now use the same icon test path.
