# Scholar — locked female robe geometry

Tanya requested Scholar next on 3 October 2026, following the locked female Alchemist and Scout fitting. Scholar v3 uses the exact Alchemist v7 front, foreground cuff and rear alpha masks on the shared 240 × 320 canvas. Both widened inner cuff lips, sleeve outer edges, waist, opening and hem are preserved pixel for pixel. The frozen female body, head/hair and Everyday underclothes are unchanged.

The built-in image tool adapted the Scholar's existing navy, violet and gold palette to the approved robe construction. The surface has gold diamond embroidery, gold borders, smooth chest panels and narrow lower welt pockets. The existing Scholar rear fabric supplies its navy lining texture. Original art, prompt and RGB registration landmarks are saved under `tool/art_assets/scholar_female_v3/`.

`bash tool/export_scholar_female_v3.sh` reproduces the exports. Registration applies only to surface pixels; the three immutable Alchemist alpha masks determine the final geometry. No runtime scaling or offsets are added. The geometry equality test compares every alpha pixel of Scholar and Scout with the corresponding locked Alchemist layer.

The shared renderer now selects this female Scholar default and restores it after other outfits are removed. The preview is `?review=scholar-wardrobe&compare=none&detail=cuffs`; the optional three-stage comparison uses the same frozen body in every stage. Legacy Scholar body clipping and drawn cuff replacements are bypassed for this fixed-body female robe. Male and neutral Scholar assets retain their prior behavior.

The underlying fit is approved. The new Scholar surface is a founder design preview, not a newly claimed visual approval. Automated and live deployment evidence is recorded in `PROJECT_STATUS.md`. No merge to `flutterflow` or launch.
