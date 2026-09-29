# Scholar detail polish — 29 September 2026

Scope: polish the accepted-fit candidate, not redesign the avatar. All frozen
base sprites remain unchanged. No other class is advanced and no production
merge or launch is authorized.

## Artwork

- [x] Three body-specific overlays edited independently with the built-in image tool.
- [x] Waist pendants have distinct diamond forms and visible attachments.
- [x] Front gold borders are continuous; cuff bands are simplified.
- [x] Outer hem flares are shaded as fabric folds.
- [x] Female shoulder piping is simplified at the hair overlap.
- [x] Exports are lossless transparent WebP on the shared 240 × 320 canvas.
- [x] Exactly two connected visible garment panels at alpha >= 16; no detached specks.
- [x] Inspected composites at 2× and the portrait/card review sizes.
- [x] Hands remain visible; collar exposes shirt/tie; hems clear boots.
- [ ] Founder approval of v2 in the actual iPhone app.

The versioned polish_v2 assets are the authoritative runtime exports. The older
fit script reproduces clean_v1 only and does not overwrite v2. The edit retained
normalized placement, but generative contours are not pixel-identical to v1:
visible bounds differ by up to five pixels on the 240 × 320 canvas. Judge fit
on the composites, not a claim of exact silhouette identity.

## Prompt specification

Mode: built-in image generation, precise-object-edit, one call per body.
Input: that body's fitted clean_v1 transparent robe.
Edit only ornamental details: crisp vertically aligned diamond pendants with
slender attachments; clean even cuff bands; continuous gold front borders;
uncluttered lower points; connected shaded fabric flares. For female, simplify
shoulder piping at the hair overlap. Preserve placement, canvas, neck opening,
shoulders, sleeve path, wrists, waist, hem, navy/gold/purple palette and style.
No anatomy, shirt, tie, belt, pants or boots. Transparent background and center.
Exports were resized to 240 × 320 without cropping or runtime transforms.

## Interface

- Body-selection description explains the current class outfit preview.
- Unselected cards say the class name plus PREVIEW, not BUSINESS SUIT BASE.
- Success uses the selected border/label, with no artwork-obscuring toast.
- Save-failure feedback and rollback remain intact.

## Gate

Scholar remains pending founder visual approval. Do not create the other
class robes from this candidate until approved.
