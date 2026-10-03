# Rustic Scout robe: approved design, fitting candidate

The founder approved the slim, nearly straight robe silhouette and rustic Scout treatment: weathered moss/olive cloth, brown edging and muted fern stitching. The exact selected source was `image-edit-target-1b559866393ab79b.png`, exported without design changes to `tool/art_assets/rustic_scout_v3/master.webp`.

## Required construction

One continuous back panel goes behind the avatar, top and trousers. The two front panels and sleeves go over the clothing. Recessed cuff openings sit behind the wrists, while the near cuff rims overlap the wrists. There must be no floating inner green flaps, broad hip flare, or flat wrist cutoffs. Original avatar faces, hair and hands are retained.

The selected artwork was already generated with the built-in image generation tool. This implementation partitions that artwork with source-coordinate alpha masks and registers it to each body, without regenerating or redrawing it. All three passes share each body's exact transform, so the seams and rims remain registered. The rear layer includes the continuous back panel and recessed cuff openings; the front layer excludes those regions; the foreground layer contains only the near cuff rims. Foreground rims are restored after bag and held-item grip layers. Hair is restored separately so a rectangular hand restoration cannot erase the cuff wrapping.

`tool/rustic_scout_v3_fit.json` records the complete per-body landmarks and masks. Reproduce with `OPENBLAS_NUM_THREADS=1 python3 tool/fit_scout_wardrobe.py tool/rustic_scout_v3_fit.json` (Pillow, NumPy, SciPy). Runtime assets are `scout_robe_{body}_v3.webp`, `scout_robe_rear_{body}_v3.webp` and `scout_robe_cuff_front_{body}_v3.webp`. All nine passes passed the non-folding registration check. Local composites and wrist closeups prompted narrower cuff openings before publication.

## Shared shape requirement

Once this fit is accepted, every class robe must use the **same exact shape for each body type**, including the same silhouette, back panel, opening, sleeve shape, cuff geometry, fold layout and hem. Only colors and surface patterns differ. Do not generate independent class silhouettes. Preserve these masks and registration across classes. Other classes remain unchanged while this fitted candidate is reviewed.

The development-only `?review=scout-wardrobe` route uses this candidate; no inventory, economy, class default, authentication or production-branch changes are part of this work. Tops and trousers retain their approved v1 assets. The intermediate green v2 candidate was never deployed and is superseded.
