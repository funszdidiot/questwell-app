# Pumpkin Sprite — Midnight Harvest

Approved pumpkin companion replaces the proposed seasonal fox. Market and inventory use the approved 16-bit icon; the Hearth uses the separately generated detailed 64-bit-style artwork with stronger amber eye glow. Both preserve transparent backgrounds.

- Slug: `pumpkin-sprite`; category: `familiar`; rare; all classes; 180 earned coins.
- Full art: `assets/images/questwell_familiar_pumpkin-sprite_v1.webp`.
- Icon: `assets/images/questwell_icon_pumpkin-sprite_v1.webp`.
- The familiar shares existing gentle idle motion and reduced-motion/offscreen behavior; glow is painted into the asset.
- Feet align to the existing companion baseline using the artwork's visible alpha bounds. The purchase grants permanent ownership; companion equipment uses the existing exclusive familiar slot.
- Catalog migration stages the item inactive until development preview verification. Founder grant is free and unequipped; preserve current equipment and balance.
- Review: `?review=hearth-settings` shows the companion in four furnished settings; `?review=market` includes its icon and purchase/equip flow with sample data.
- QA: existing familiar body/layout coverage includes the pumpkin; icon/scene separation and all 40 shop entries are checked. `tool/qa/pumpkin_sprite_market_check.sql` exercises purchase, retry, equip and removal in a rolled-back fixture.

Art created with the built-in image tool. Final edit preserves the approved pumpkin and increases only the amber light filling both carved eye cavities, with short-range golden bloom and warm rind highlights. Original 16-bit icon is retained separately.

## Verified release — 2026-10-02

Code `c60f15a62af56ac4b21243ef65bafc6d11ad2602` passed Flutter Check `37075296893` and Preview `37075296888`. Visually checked the glowing companion in all four review settings and the separate 16-bit Market icon at 390 px content width. Purchase/retry/equip/unequip SQL QA passed; security advisors returned no findings. Activated the 180-coin listing and verified the founder grant is owned, unequipped, with coin balance unchanged at 847. Development branch only; no public launch or merge.
