# Rustic Scout: separate body-fit review

The founder rejected the v3 fitting: it still bulged at the hips and the cuffs looked unnatural. Its passing technical checks did not establish visual acceptance. V3 is **not** an approved template.

## Corrected fitting process

Female, male and gender-neutral bodies now have separate waist, hip, side-seam, front-opening, hem and wrist registration. The selected rustic source design remains unchanged. The previous lower-body points were partly inside the actual side contours and were shared across bodies. The warp consequently pulled the side panels outward around the thighs. V4 maps the actual source side contours at eight heights to individually specified body contours. The front openings are independently controlled to avoid bowed inner edges. Lower right panels accommodate the female and neutral stances without adding hip volume.

The cuff error was a layering error: the far/lower edge of the opening had been placed in front of the wrist, creating a detached bracelet appearance. V4 puts that far edge and recessed interior behind the wrist. The visible front edge remains connected to the sleeve fabric and overlaps the wrist from above. No separate band is drawn across the skin. The continuous back panel remains behind the clothed avatar.

All three passes of a given body share that body's exact transform. `tool/rustic_scout_v4_fit.json` contains the independent fits and corrected cuff masks. Reproduce with `OPENBLAS_NUM_THREADS=1 python3 tool/fit_scout_wardrobe.py tool/rustic_scout_v4_fit.json`. It reuses the exact selected source master at `tool/art_assets/rustic_scout_v3/master.webp`. Runtime assets use the `_v4.webp` suffix; v3 assets remain untouched for reference.

## Approval and templates

Each body's fit must be reviewed and accepted individually. Only then does that body's fitted robe become its template for all other classes. Future class variants change colors and surface patterns; they reuse that body's accepted geometry, masks and registration. A single generic body fit is not acceptable. No v4 fit is declared accepted merely because it exports or passes tests.

The development review provides All three fits / Female fit / Male fit / Gender-neutral fit, with larger portraits and centered wrist closeups for the individual views. Use `?review=scout-wardrobe&body=female&detail=cuffs` (or `male` / `neutral`). This remains development-only and does not replace other class robes or alter inventory.

Local review: all nine fitted passes passed the non-folding check. Side-by-side composites show the bowed hip panels and separate wrist bands removed. Founder visual acceptance remains pending.

Validation: development commit `4b5a6aed24f31c033c44c1b9ce2073c34c762d85`; Questwell Preview run `37094606910` and Flutter Check run `37094606896` both succeeded. The live preview was inspected with all three bodies, enlarged female fitting, and grimoire and lantern grips. These checks establish rendering and interaction behavior, not founder acceptance of the silhouettes.
