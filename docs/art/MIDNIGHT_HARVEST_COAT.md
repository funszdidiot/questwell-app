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

## Release verification

Code release `b06176e6b9a041ee3237e27f6b6ea144834192f0`: Flutter Check `37078024329` and Preview `37078024360` both passed. Live preview was visually reviewed on female, male and neutral bodies, with and without scarf, satchel, hat, glasses and lantern. Purchase/retry/equip/unequip SQL QA passed in rolled-back fixtures; Supabase security advisors reported zero findings.

The 180-earned-coin catalog listing is now active. The founder copy was verified owned, free and unequipped, with the coin balance unchanged at 847. Existing equipment was preserved. Screenshot: `questwell-midnight-harvest-coat.jpg`.

## Open-front correction

Founder-approved preview `exec-be1aa222-477e-464f-975f-0f296f6a49c4.png` removes the two rectangular inner panels that made the lower coat look skirt-like. Built-in ImageGen edited each original garment into an open-front version while retaining the outer tails, copper edging, waistcoat and sleeves. Generation sources are recorded per body in `tool/harvest_coat_fit.json`; v2 masters are in `tool/art_assets/harvest_coat_v2/` and separately registered v2 runtime assets retain the 240×320 canvas.

Female and male source landmarks were remeasured for the edited artwork. All three rendered fits were checked for exposed trousers, clear hands, continuous outer-tail edging and preserved collar placement. The garment regression test now checks transparency through the center opening. Frozen base/class artwork and the existing catalog item, ownership, price and equipment state are unchanged.

Correction release `e13c6104e0370df525b947701baefb0bf1d7e772`: Flutter Check `37079528255` and Preview `37079528230` both succeeded. The live review verified all three open-front fits, with and without hat, glasses, scarf, satchel and lantern. Saved proof: `questwell-harvest-coat-corrected.jpg`.
