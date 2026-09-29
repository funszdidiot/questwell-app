# Alchemist lab-coat review — 29 September 2026

**Development candidate: `alchemist-lab-v2`. Founder visual approval pending.**

This class follows the approved Scholar fit checklist. Scout was approved after
its app delivery; its `scout-approved-v1` artwork and fit inputs are frozen.

## Founder design direction

The founder requested colors more distinct from Scout, then a more recognizable
science/chemistry aesthetic, then selected the second blue color treatment.
The selected direction is a sapphire-blue laboratory coat with cobalt lining,
neon-green molecule embroidery and cuff bands, cool silver edging/snaps,
and plain chest pockets. The founder requested green accents, then explicitly
removed the beaker/flask emblem from all three variants. The white laboratory-coat
study supplied the chemistry details;
the founder's preferred all-blue study supplied the final palette and finish.
The earlier teal/gold, ceremonial and white studies are not runtime assets.
Mystical sigils, jeweled lapels and hanging ornaments were removed. Molecular
motifs are decorative embroidery, not instructional chemistry diagrams.

## Required review surfaces

- App: https://funszdidiot.github.io/questwell-app/ — Adventurer → Your Archetype
  → Alchemist, then review all three body options.
- Direct review: https://funszdidiot.github.io/questwell-app/alchemist-fit-review.html
  — the exact runtime coat/base files and generated visibility paths, with app
  portrait fill and 176 px selection cards. Coat/jacket toggles expose coverage.

## Developer checklist

- [x] Preserve all frozen base, Scholar and Scout art and fit definitions.
- [x] Author three separate garments with body-specific anatomy and fit anchors.
- [x] Export transparent 240 × 320 overlays; no anatomy or base clothes baked in.
- [x] Fit shoulder slope, armpit, elbow, waist, wrist and hem to each base.
- [x] Keep compact cuffs at the wrists and both hands and boots readable.
- [x] Keep front seams continuous and molecular embroidery clear.
- [x] Inspect the three composites at enlarged portrait and 176 px card sizes.
- [x] Add Alchemist-specific jacket occlusion while preserving head/hair,
  shirt/tie, belt, hands, trousers and shoes.
- [x] Stack class art and base at the same origin and scale in the shared app renderer.
- [x] Keep the coat a starter class garment, separate from the five accessory slots.
- [ ] Founder visual acceptance of all three variants in the signed-in app.
- [ ] Freeze Alchemist only after that acceptance; Guardian follows.

| Body | Fit and visual check | Acceptance |
| --- | --- | --- |
| Male | Structured shoulders, measured arm paths, visible wrists/hands, clear stance | Developer composite passed; founder pending |
| Female | Narrower shoulders/waist, high wrists, intact long hair, smoothed front piping | Developer composite passed; founder pending |
| Gender Neutral | Independent balanced body fit, compact cuffs, smooth front seams, clear boots | Developer composite passed; founder pending |

The public comparison is a review surface, not evidence that we independently
operated a signed-in iPhone Safari session. Build success does not confer visual
approval, promote Epic 2, or authorize a production merge/launch.

## Asset sources and reproduction

Runtime assets are the three `alchemist_coat_*_lab_v2.webp` files in
`assets/images/questwell/avatar/classes/alchemist/`.
The built-in image-generation tool produced the garment masters, chemistry
details, seam refinement, selected blue treatment, neon-green accents and flask
removal. Sources and prompts are retained in
`tool/art_assets/alchemist_lab_v2/`.

`tool/alchemist_fit_anchors.json` records measured source/base coordinates and
the nonfolding mesh. `node tool/fit_alchemist_coat.cjs` reproduces the lossless
WebPs using Node and ImageMagick. Wrist corrections account for the rounded
cuff openings. This is an offline texture bake; there is no garment-only runtime
scaling or offset.

`python3 tool/generate_alchemist_underlayer.py` generates Flutter and browser
coverage from `tool/alchemist_underlayer_visibility.json`. The asset verifier
checks all approved locks and the Alchemist candidate source/fit checksums.
`test/alchemist_underlayer_clip_test.dart` covers anatomy/hair retention, jacket
occlusion, contain alignment, correct body/asset/clip pairing and app portrait/card
layout at 320, 390 and 430 px widths.
