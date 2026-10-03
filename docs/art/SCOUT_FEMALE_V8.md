# Scout — exact locked Alchemist geometry, no breast pockets

On 3 October 2026 Tanya accepted the current Alchemist v7 fit and requested Scout be redone with those exact specifications. Her follow-up explicitly prohibited Scout breast/chest pockets. The Alchemist remains unchanged; the briefly proposed additional right-cuff widening was not performed.

Scout v8 uses pixel-identical alpha masks from all three locked Alchemist v7 cloth assets: front, foreground cuffs and rear. This guarantees the same shoulders, waist, hem, sleeve contours, inward-widened cuff lips and equipment depth boundaries. The fixed female body, head/hair, everyday top, trousers and boots are reused unchanged. Geometry equality is checked in the Flutter wardrobe test as well as during export verification.

Built-in imagegen created the rustic olive woven fabric, flax fern embroidery and brown leather trim. A second imagegen edit removed both breast pockets and their buttons from a close chest crop. The small lower pockets remain. Source images and both prompts are preserved under `tool/art_assets/scout_female_v8/`.

`bash tool/export_scout_female_v8.sh` registers only the RGB surface art to the locked shape, using the saved texture landmarks and boundary-color padding. It then copies the locked front, cuff and rear alpha masks unchanged. This is an offline surface-art operation; the app does not stretch garment pieces or alter anatomy. The rear retains the olive Scout texture while adopting the exact locked rear mask.

The canonical reference is `tool/female_avatar_fit_reference.json`. The geometry is approved; the corrected Scout surface is available for founder review in `?review=scout-wardrobe&body=female`. Deployment evidence is recorded in `PROJECT_STATUS.md`. No other bodies are refitted, and no merge or launch is authorized.
