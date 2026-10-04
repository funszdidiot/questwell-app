# Neutral robe v9 — hands in front of side panels

Tanya liked v8's wider cuffs but rejected the robe covering the hands. The main front asset—not the cuff asset—placed unembroidered side cloth over both thumbs. Earlier QA checked cuff fragments and missed this separate occlusion: 25 opaque hand pixels on the image-left and 46 on the image-right were hidden by the front panel.

V9 transfers the complete side-cloth regions beside the hands to the rear layer. The split lies between the hands and dressed hips: rows 181–204, x ≤ 88 on the image-left and x ≥ 158 on the image-right. The embroidered facings remain above the trousers. The existing cuff lips remain above the wrists. There is no hand overlay, body cutout, redraw, garment deformation or new art generation.

`node tool/export_neutral_robe_v9.cjs` reproduces the export from the pinned v8 layers. It transfers 281 existing cloth pixels; 157 final composite pixels change, all inside the side regions. No opaque palm pixel remains covered by the front panel. Cuff and collar files are byte-identical to v8, and the approved body, identity, shirt, trousers and boots remain byte-identical to their locks. Native and enlarged light/dark views must compare each complete thumb and hand silhouette directly with the approved foundation; local cuff continuity alone is insufficient. See `visual_review.json` for independent review.

This is a founder-review candidate, not an approved neutral robe template. The narrower drape, rear-band depth, inward cuff width and continuous collar from v8 remain in place. No runtime integration, remote push or deployment occurred.
