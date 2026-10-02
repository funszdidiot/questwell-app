# Midnight Harvest Coat

Seasonal chest cosmetic, rare, class-neutral, 180 earned coins. Approved design: burgundy wool, moss-green lapels, ivory shirt, olive waistcoat, copper oak-leaf clasps and fine copper edging. It replaces the class garment while equipped and restores it on removal. Hands remain available for held items.

## Artwork and registration

Built-in ImageGen produced three independent body-specific garments using the frozen Wanderer short coats as geometry references and the approved full-avatar concept `exec-4b500168-7499-4ff3-80bb-63898dec2be2.png` as design reference. A second edit replaced hollow black cuff faces with continuous burgundy cloth and a single thin copper stitch. No avatar anatomy is baked into the assets; the shirt and waistcoat are parts of this full seasonal outfit.

Final sources: female `exec-cdf44080-a89e-461e-b63e-a43d304ed36c.png`; male `exec-9eaf4f75-dbd3-4152-9b8c-b7f0066544c2.png`; neutral `exec-a4be1d11-051b-49fc-94da-281a72a8d236.png`. Masters are preserved in `tool/art_assets/harvest_coat_v1/`.

`tool/fit_harvest_coat.py` exports three transparent 240×320 runtime assets from measured `tool/harvest_coat_fit.json` landmarks. It uses the established inverse thin-plate fitting method, premultiplied sampling and fold rejection. Dependencies: Python, Pillow, NumPy, SciPy. Existing frozen avatar and class art is unchanged.

The shared renderer suppresses class garment/rear layers and Scholar-specific cuff replacements while this outfit is equipped. Existing hand, satchel, scarf, face and head accessory rendering remains available. A separately drawn 32×32 Market/inventory icon follows the familiar catalog's limited palette and chunky edges.

## Review and checks

Development review: `?review=harvest-coat`; all three bodies show portrait and Midnight Harvest Hearth, with class, outfit, accessories and handheld controls. `test/harvest_coat_test.dart` checks canvas registration, exposed hands and legs, class replacement/removal, and held-item/satchel rendering across all bodies and classes. The shared catalog suite includes all 41 shop items. `tool/qa/harvest_coat_market_check.sql` checks purchase, retry debit safety, exclusive chest equipment and removal in rolled-back fixtures.

Catalog is staged inactive until preview checks pass. Founder copy is granted free and unequipped; no coin debit or change to existing equipment. Development branch only; no public launch or merge.
