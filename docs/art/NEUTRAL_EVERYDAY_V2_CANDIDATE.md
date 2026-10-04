# Neutral everyday outfit — female-design fitting revision

After the male neck correction, Tanya directed the next step and confirmed “let's do it”: the neutral everyday outfit must be the female everyday design fitted to the already-approved neutral paper doll. This revision is a **review candidate**, not a runtime wardrobe replacement or founder-approved fit.

## Design and fit

Retain the plain ivory crewneck short-sleeved top, straight brown trousers, brown belt/brass buckle and compact brown ankle boots. The top has closer sleeves and a quieter neck binding. The boots use the female version's understated leather and low-sole treatment, without laces or added decoration.

The fitting check found that the previous trousers exposed the charcoal undergarment at the hips and inner legs. The existing trouser drawing is therefore refitted locally at the waist, hips and crotch; its style, pockets, belt and palette are retained. This changes clothing only. New boots are registered to cover the existing feet, with the trouser hems rendered above their shafts. No generated anatomy is used.

## Reproduction and files

1. `node tool/neutral_everyday_v2_reference.cjs` assembles the exact neutral garment edit target and female garment style reference.
2. `tool/art_assets/neutral_everyday_v2/garments_source.png` is the retained built-in image-editing source; `prompt.json` records the exact prompt and input roles.
3. `node tool/export_neutral_everyday_v2.cjs` registers only clothes to the locked 240 × 320 canvas and writes the three independent candidate layers: `everyday_top_neutral_candidate_v2.webp`, `everyday_trousers_neutral_candidate_v2.webp`, and `everyday_boots_neutral_candidate_v2.webp`.
4. Full review renders: `neutral_everyday_review_v2.png` (transparent) and `neutral_everyday_review_v2_light.png` (opaque light background). Details: `sleeve_fit_detail_v2.png` and `boot_fit_detail_v2.png`.

All candidates and review files are under `tool/art_assets/neutral_everyday_v2/`. Existing runtime garment files and the approved female wardrobe are unchanged. Source-reference PNGs are reproducible from the reference script.

## Validation

- Neutral base and identity SHA-256 values still match `tool/neutral_avatar_fit_reference.json` exactly.
- Opaque lower-body coverage check: zero exposed underwear/leg/foot pixels in the tested lower-body region, excluding hands.
- Right upper-shoulder coverage check: zero opaque body pixels outside the top in x145–168, y88–102.
- Detached low-alpha garment fragments are removed; each independent exported piece remains on the full registered canvas.
- Independent visual review of the full figure, sleeve details and boots found a coherent female-style outfit on the unchanged neutral body. Earlier forearm stray-line and shoulder-sliver defects were fixed and rechecked.
- Existing locked-avatar asset verification passes. No Flutter/runtime code changes are included; no new live-app behavior is claimed.

Founder visual acceptance remains pending. Next: neutral robe fitting and Woodland Scout sleeves/outfit, then male outfits only after the neutral wardrobe is finished. No Market/account writes, merge to `flutterflow`, or launch.
