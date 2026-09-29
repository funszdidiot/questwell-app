# Alchemist lab-coat review — 29 September 2026

**Founder approved on 29 September 2026: `alchemist-approved-v1`.**

Approved artwork: `alchemist-lab-v4`, source commit
`0198dc8710ac11a44c5527bd06e293a68a7b652b`. After deployment and review, the
founder said “Good to go.” Approval covers Male, Female and Gender Neutral.
Artwork, masters, export settings and visibility definitions are now frozen.
This approval does not promote Epic 2, merge to `flutterflow`, or launch.

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

## Fit rejection and correction

On 29 September, the founder rejected `alchemist-lab-v2` after the
iPhone card review. The previous developer inspection missed the inward side
contours between individual anchors. The female panels narrowed inside the
thighs; the male and neutral right panels also exposed outer trouser edges.
The earlier developer pass did not establish acceptable fit.

Revision 3 corrects the continuous side contours using the frozen bodies and
the approved Scholar silhouette. The existing blue/silver/neon source artwork,
plain chest pockets, collar, sleeves, cuffs and final hem endpoints are retained.
The front placket is held fixed while the outer fabric covers the legs.

| Body | Outer trouser pixels beyond coat, rows 196–240: v2 | Revision 3 |
| --- | ---: | ---: |
| Male | 51 | 0 |
| Female | 147 | 0 |
| Gender Neutral | 71 | 0 |

These are native-canvas pixel checks at alpha 128 or greater, not a substitute
for founder acceptance. The same check now decodes the actual runtime WebPs in
the Flutter test suite. Revision 3's upper-body pixels above row 170 matched
revision 2; revision 4 below deliberately refines that artwork.

## Developer checklist

### Revision 4 consistency and finish pass

The founder authorized this pass after the revision 3 delivery and accepted
the completed revision 4 set after its app deployment, as recorded above.

| Shared detail | Male | Female | Gender Neutral |
| --- | --- | --- | --- |
| Silver snaps | Four, two pairs | Four, two pairs | Four, two pairs |
| Pockets | Plain right chest welt; two hip welts | Same layout, independently fitted | Same layout, independently fitted |
| Neon embroidery | Three linked rings on left sleeve and both lower panels | Same motif and placement | Same motif and placement |
| Cuffs | Compact end, narrow green inlay, fine silver edge | Same finish at female wrist positions | Same finish at neutral wrist positions |
| Outer trouser pixels beyond coat, rows 196–240 | 0 | 0 | 0 |

Left/right here are the viewer's perspective. The artwork retains sapphire and
cobalt cloth, silver edging and neon-green accents. No beaker or flask remains.

- [x] Standardize snaps, pocket layout and three-ring embroidery across bodies.
- [x] Smooth the waist/front placket without reintroducing notches during fitting.
- [x] Refine silver line weight and lower-panel corners.
- [x] Reduce cuff bulk while preserving wrist endpoints and readable hands.
- [x] Recheck the actual composite at enlarged portrait and 176 px card sizes.
- [x] Reject folded mappings; retain two solid garment halves and clear head/boot regions.

### Fit and implementation checks

- [x] Preserve all frozen base, Scholar and Scout art and fit definitions.
- [x] Author three separate garments with body-specific anatomy and fit anchors.
- [x] Export transparent 240 × 320 overlays; no anatomy or base clothes baked in.
- [x] Fit shoulder slope, armpit, elbow, waist, wrist and hem to each base.
- [x] Check continuous hip/thigh contours between anchors against the actual base.
- [x] Verify that no outer trouser pixels escape the coat between rows 196 and 240.
- [x] Keep compact cuffs at the wrists and both hands and boots readable.
- [x] Keep front seams continuous and molecular embroidery clear.
- [x] Inspect the three composites at enlarged portrait and 176 px card sizes.
- [x] Add Alchemist-specific jacket occlusion while preserving head/hair,
  shirt/tie, belt, hands, trousers and shoes.
- [x] Stack class art and base at the same origin and scale in the shared app renderer.
- [x] Keep the coat a starter class garment, separate from the five accessory slots.
- [x] Founder accepted the current three-body set after app delivery and review.
- [x] Freeze Alchemist after acceptance; Guardian follows.

| Body | Fit and visual check | Acceptance |
| --- | --- | --- |
| Male | Smooth waist piping, compact cuffs, consistent details and covered thighs | Founder approved current set |
| Female | Independent narrower fit, smooth placket, visible long hair and hands | Founder approved current set |
| Gender Neutral | Independent balanced fit, matching details, smooth seams and clear wrists | Founder approved current set |

The public comparison is a review surface, not evidence that we independently
operated a signed-in iPhone Safari session. Build success does not confer visual
approval, promote Epic 2, or authorize a production merge/launch.

## Asset sources and reproduction

Runtime assets are the three `alchemist_coat_*_lab_v4.webp` files in
`assets/images/questwell/avatar/classes/alchemist/`.
The built-in image-generation tool produced the garment masters, chemistry
details, seam refinement, selected blue treatment, neon-green accents and flask
removal. Sources and prompts are retained in
`tool/art_assets/alchemist_lab_v4/`. Its `prompts.json` records the selected
source images and complete built-in image-generation prompts for this pass.

`tool/alchemist_fit_anchors.json` records measured source/base coordinates and
separate body landmarks and continuous side-contour constraints.
`node tool/fit_alchemist_coat.cjs` reproduces the lossless WebPs using Node and
ImageMagick. Revision 4 solves a smooth inverse thin-plate mapping through each
body's measured landmarks. This avoids the sharp placket bends introduced by
the first trial's triangle boundaries. The exporter rejects folded garment
regions, then maps the corrected side contours back to the original master,
preserving front piping and avoiding a second color-texture resampling.
This is an offline texture bake; there is no
garment-only runtime scaling or offset.

`python3 tool/generate_alchemist_underlayer.py` generates Flutter and browser
coverage from `tool/alchemist_underlayer_visibility.json`. The asset verifier
checks all approved locks and the approved Alchemist source/fit checksums.
`test/alchemist_underlayer_clip_test.dart` covers anatomy/hair retention, jacket
occlusion, contain alignment, correct body/asset/clip pairing and app portrait/card
layout at 320, 390 and 430 px widths.

Next class: Guardian. Carry forward the fit, continuous contour, uniform-detail,
trim and cuff checks using its own source artwork and visibility definitions.
