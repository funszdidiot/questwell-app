# Wanderer — shared locked female robe geometry

Tanya requested Wanderer next on 3 October 2026 after the Scout, Alchemist, Scholar and Guardian fitting pass. This female robe variant reuses the exact Alchemist v7 front, foreground cuff and rear alpha masks, including both inward-widened cuff lips. It uses the unchanged female paper doll, identity, Everyday top, trousers and boots on the shared 240 × 320 canvas.

The Wanderer surface retains tobacco-brown travel cloth, aged copper-gold edging, four-point compass-star embroidery on upper sleeves and lower hems, four brass fasteners and practical lower pockets. The front opening meets the gold borders without added inner flaps. The lining uses the muted ochre cloth from `wanderer_rear_female_wrap_v2.webp`; the initial blue rear texture is not used.

The new female default follows this shared full-length class-robe template. The previous short travel coat is preserved as historical art and remains the legacy layer beneath replacement chest equipment; male and neutral Wanderer defaults retain their existing short coats and fitting behavior. The new source is a design preview, not a claim of new founder visual acceptance.

Built-in imagegen supplied the garment source and class styling, saved under `tool/art_assets/wanderer_female_v3/` with its prompt and surface-registration landmarks. `bash tool/export_wanderer_female_v3.sh` reproduces the exports: normalize the surface to 240 × 336 at (0, 2), register RGB to the locked shape, then copy the immutable alpha masks. No body edits or runtime garment transforms are introduced.

The shared renderer restores the new female Wanderer after other outfits are removed. The dedicated review is `?review=wanderer-wardrobe&compare=none&detail=cuffs`; three-stage mode uses the same body and scale. Tests cover exact alpha equality, every clothing subset, front/rear/cuff depth, legacy versus fixed-body rendering, satchel and replacement outfits, and phone review layouts. Deployment evidence is recorded in `PROJECT_STATUS.md`. No merge to `flutterflow` or launch.
