# Neutral class robes v1

Tanya approved neutral robe v11 as the shared template and authorized development integration and push. Scout uses the approved files byte for byte. Scholar, Alchemist, Guardian and Wanderer change the surface colors and details while preserving every alpha value of all four layers. Their surfaces have passed independent visual QA; this is separate from founder acceptance of each surface.

The full body v4, matching identity and everyday v3 remain byte for byte unchanged. Runtime order is rear robe, full body, everyday boots, trousers, top, front robe, identity, collar and cuff foreground. Nothing clips or reshapes the approved anatomy to accommodate these robes.

| Class | Surface |
| --- | --- |
| Scout | Olive, flax embroidery, brown trim |
| Scholar | Navy, gold trim and linked diamonds |
| Alchemist | Royal blue, silver trim and linked yellow rings |
| Guardian | Burgundy, gold trim, shield crest and chevrons |
| Wanderer | Brown, warm metal trim and compass stars |

`tool/neutral_robe_fit_reference.json` is canonical. Runtime images are under `assets/images/questwell/avatar/classes/{class}/*_neutral_v1.webp`. Generation sources, registration metadata, native and enlarged composites, and independent QA are under `tool/art_assets/neutral_class_robes_v1/`. Each class has a reproducible exporter under `tool/`.

Run `node tool/verify_neutral_class_robes.cjs` with Sharp available to check all twenty decoded alpha planes and all fixed inputs, then rebuild the lineup from the actual runtime images. `python3 tool/verify_avatar_assets.py` checks pinned artifact hashes. Flutter regression tests verify shared renderer order, garment subsets, class restoration and exact mask parity.

The development review route is `?review=neutral-robes`. Existing class wardrobe reviews also support `&body=neutral`.

Tanya subsequently requested removal of Pathfinder boots and a grimoire attachment that preserves the avatar methodology. Pathfinder has been removed from the app's catalog views, inventory presentation, preview catalog and renderer; its runtime images and anatomy clipper are deleted. Historical ownership data is untouched. The grimoire now hangs from a small belt loop using unchanged book-only artwork and body-specific accessory anchors. Replacement-hand artwork and hand-masking hooks are deleted. See `?review=grimoire` and `tool/art_assets/grimoire_belt_v1/` for the attachment review. The neutral hat and glasses shift four native pixels right to match the locked head anchor; the body remains unchanged.
