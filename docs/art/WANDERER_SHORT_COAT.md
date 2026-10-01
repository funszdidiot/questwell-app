# Wanderer short travel coat

Review candidate, requested October 1, 2026. Keeps the warm brown cloth, antique gold piping, shoulder stars and hem stars while shortening the coat to the upper/mid thigh. Each body has a separately generated fit. Cuffs are painted into the garment; the prior runtime cuff overlay is no longer rendered.

## Sources and preparation

ImageGen with transparent background, detailed 64-bit retro fantasy garment art. Female reference was the newly generated tailored cuff design, `exec-bf5c2ab3-d76a-47f3-8c66-2186b39be84f.png`; male and neutral also used their original body-specific v2 coat as fit references.

- Female source: `exec-693a32f2-53a6-4fe8-9c75-2cd9863b4f24.png`; resize to 177×254, offset (31,44) on 240×320.
- Male source: `exec-19695340-8c33-46ad-85b2-4c3165687082.png`; resize to 191×260, offset (24,23).
- Neutral source: `exec-d4c59bfa-a98a-49c6-b8b1-163001583607.png`; resize to 151×205, offset (44,47).

Outputs: `assets/images/questwell/avatar/classes/wanderer/wanderer_coat_{body}_short_v1.webp`, lossless RGBA. Matching rear layers use the existing cloth above row 195, with the obsolete lower tails removed by cropping. Original approved v2 files and frozen underlayer geometry remain unchanged. The existing underlayer exposes the full trousers below rows 196–200, so no new body mask is needed.

## Generation directions

Female: Edit this exact garment into a shorter Wanderer travel coat. Keep the same canvas 1086x1448, same shoulder position, collar, fitted torso and waist, sleeve shape and length, slim rounded cloth cuffs, warm brown fabric, aged gold piping and shoulder stars. Change the lower coat only: bring the hem up to MID THIGH, around y980 on this canvas, shorten all front and rear tails, with gently angled rounded hem corners rather than long pointed tails. Relocate the small gold hem stars above the new hem. Hem sits about 210 pixels below the cuffs. Keep front open and clear transparent gap between panels. The bottom third of canvas should now be entirely transparent. Preserve exact upper body placement and size. Detailed 64-bit retro fantasy RPG equipment sprite with painterly cloth texture and crisp edges matching this reference. Garment only, no body, hands, mannequin or backdrop. True transparent background.

Male: Create the MALE body fit of this short Wanderer travel coat. Image 1 is strict body-fit and canvas registration reference, image 2 is the new SHORT COAT design to reproduce. Keep canvas960x1280 and Image1 original collar around y300, original sleeve ends around y710, hands absent. Match original male shoulder width, relaxed arm angles and wider torso exactly. Replace long tails with mid-thigh hem at y875, following Image2 gently rounded angled bottom corners, warm brown textured fabric, antique gold edging, small gold shoulder and hem stars, tailored full sleeves and naturally curved slim cloth cuffs. No long points or rear tails extending below y890. Detailed 64-bit retro fantasy RPG equipment sprite, carefully painted fabric folds, no vector cuff overlays. Transparent space inside open collar and between front panels. No character, hands, pants, background or other objects. Preserve placement in full transparent canvas.

Neutral: Create the ANDROGYNOUS NEUTRAL body fit of this short Wanderer travel coat. Image1 is body-fit reference, Image2 new short design. Match Image1 original relaxed arm angles, shoulders and gently straight torso. Short MID-THIGH travel coat with soft rounded angled hem corners, gold hem stars relocated just above hem, warm brown cloth, antique gold piping, shoulder stars, fitted full sleeves, slim naturally rounded cloth cuff openings. No long robe tails. Cuffs end 75% of way from collar to hem. Detailed 64-bit retro fantasy game equipment sprite, painted fabric folds matching Image2 exactly in material and style. Garment only with open front, transparent neck and front gap, no mannequin, hands, body or backdrop. True transparency. Centered full garment on portrait transparent canvas.

## Verification

Asset lock verification preserves all previously approved assets. Regression tests cover matching body assets, sleeve ends, clear lower legs, removal of cuff overlays, satchel restoration, replacement outfits, and short rear layering. Visual review uses the live Wayfarer review screen before founder approval.

## Cuff revision v2 — October 1, 2026

Founder reported disconnected cuffs. Close-up showed painted dark oval openings across the wrist; these were removed using built-in ImageGen edits with each registered v1 sprite as reference. Sleeve fabric now ends in a single thin gold edge. No runtime cuff overlay is added.

Female source: `exec-0afb1967-0e48-400e-b21a-0261af3781b9.png`, resized to240×320. Male: `exec-0abce699-03be-4270-83ba-5d8330661f49.png`, resized218×308, offset12,2. Neutral: `exec-52ed6186-e7a4-4b73-bbd2-949de0385a87.png`, resized218×306, offset12,0. Lossless assets end in `short_v2.webp`.

Female prompt:
Use case: precise-object-edit. Edit only both CUFF ENDS of this exact short brown Wanderer coat. This garment will be layered over a character's hands. Existing cuffs are wrong: large black oval empty holes facing the viewer make wrists look disconnected. REPLACE the visible dark oval faces with continuous brown sleeve fabric and a thin aged-gold hem at the bottom. Front cloth edge should curve gently DOWN in its middle, wrapping snugly over a wrist, no visible hollow oval, no black cap, no thick rolled ring, no separate band. Narrow subtly toward wrists. Leave hands absent and transparent beyond sleeve edge. Keep sleeve end positions fixed at roughly y680, same arms/pose, short hem, collar, gold stars, buttons, pockets, torso, brown painterly cloth and 64-bit retro fantasy style. Preserve exact original placement on 960x1280 transparent canvas, collar y285 and hem y825. Change nothing except final 40 pixels of both sleeves. Transparent background.

Male and neutral edits used their own v1 fit references plus corrected female cuff style: replace dark hollow oval cuffs and thick double rings with continuous brown cloth and a single thin gold hem at the wrist, transparent immediately beyond edge, no hands or body; retain original body proportions, short hem and64-bit painterly style. Requested original sleeve end positions male y700 and neutral y685 on960×1280. Registered results to the source240×320 body canvas after generation.
