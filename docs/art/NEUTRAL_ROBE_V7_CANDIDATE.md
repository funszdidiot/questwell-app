# Neutral robe v7 — complete cuff depth correction

**Subsequently rejected by Tanya.** The original QA below missed excessive skirt flare, narrow inner cuffs, a rear hem drawn across the avatar's left leg and upper trim cut off by the identity overlay. The claim of fully correct rear placement was inaccurate: the inherited RGB split retained part of the horizontal rear band in the front asset. V7 is historical evidence, not an accepted template. See `NEUTRAL_ROBE_V8_CANDIDATE.md` for the replacement fitting.

After Tanya approved everyday v3, robe fitting resumed on the locked neutral v4 body and those exact everyday garments. All five approved files remain byte-for-byte unchanged. This candidate retains the rustic olive robe, flax embroidery, brown binding, lower pockets, open front and continuous rear skirt panel.

## Cause and correction

The v6 exporter misclassified the cuff's dark edge shading as cloth behind the wrist based on RGB values. That split an intact curved cuff into fragments and exposed irregular skin between them. Inspection of the registered source showed that the artwork already described a continuous facing hem: its dark edge belongs with the foreground cuff.

`node tool/export_neutral_robe_v7.cjs` restores those existing pixels to their complete cuff. It uses two explicit cuff regions containing no rear lining and transfers only existing nontransparent pixels: 75 per side. It performs no painting, body edits, garment deformation or anatomy masking. The front file is copied unchanged; the combined cloth RGB and alpha are identical before and after. The central back-panel texture, silhouette and behind-body placement remain unchanged. Keeping the whole cuff together resolves the original defect without piecemeal art repairs or regeneration.

The exact stack is rear robe → complete body → boots → trousers → top → robe front → identity → cuff fronts. Trouser hems remain above boot shafts. The entire everyday shirt remains underneath the robe.

## Validation and review

The exporter checks immutable body/identity/everyday hashes, disjoint cloth layer membership, zero artwork RGBA changes, zero depth changes outside the cuff regions, unchanged central rear lining, and zero uncovered opaque arm pixels in the tested long-sleeve region. The repository asset manifest verifier passed.

An independent reviewer recomposited the exported WebPs and obtained a native preview identical to the exporter's preview. Native/enlarged views on light and dark backgrounds show connected wrists and hands, complete cuff hems, coherent collar/shoulders, and a continuous panel behind the legs without an extra inner flap. The final presentation spacing was corrected after review. Exact QA evidence is in `tool/art_assets/neutral_robe_v7/visual_review.json`.

**Founder robe fitting acceptance remains pending.** `fit_reference.json` records the three layer alpha hashes and full registration. Once accepted, those masks become the neutral class-robe geometry template for color, pattern and flourish variants. Woodland Scout remains next in the neutral sequence, and male outfits remain deferred. No runtime wardrobe change, remote push, deployment, Market/account write, merge or launch occurred. Flutter tests were not run; this is an offline export correction and fitting review.
