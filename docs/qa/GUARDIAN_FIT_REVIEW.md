# Acceptance — 2026-09-29

Founder accepted Guardian v3 female / v2 male and neutral with robe-wrap-v1 and directed “Ok! Let’s do wanderer.” This supersedes pending notes below. No production promotion or launch.

# Guardian garment review — 29 September 2026

**Development candidate: `guardian-v3`. Founder visual acceptance is pending.**

## Revision 3: female sleeve and hip correction

Founder reported that the female avatar's right arm and hip looked distorted.
The correction addresses the viewer-right side: the sleeve made an exaggerated
bend through the elbow, and the coat side stepped outward below the waist.
The prior coverage and gold-trim checks did not detect these contour defects.

The female-only local fit now follows a continuous elbow/forearm outline and
a smoother waist-to-hip line. It maps the retained source texture through
measured, monotone horizontal intervals. Front piping, the opposite half and
cuff endpoints stay pinned. No base anatomy, source painting, male/neutral
garment or approved class asset was changed.

- [x] Inspect female portrait and 176 px card against revision 2.
- [x] Retain zero exposed outer-trouser pixels and the existing waist-trim checks.
- [x] Add a regression check for abrupt native-pixel sleeve/hip edge steps.
- [x] Preserve the original wrist contact, visible hands and frozen base.
- [ ] Founder accepts the revised female fit in the app/iPhone Safari.

Comparison: [female sleeve and hip](guardian-female-v3-comparison.png).
Runtime uses female `v3`, male `v2` and neutral `v2`. The revision-2 source
masters/prompts remain authoritative; this revision changes fitting code and
coordinates only. Reproduce with `node tool/fit_guardian_coat.cjs`.

Alchemist was approved after its revision 4 app delivery with “Good to go.”
Its three-body set and fitting inputs are frozen as `alchemist-approved-v1`.
Guardian is next in the agreed class sequence; Wanderer waits for Guardian
acceptance. This does not promote Epic 2, merge to `flutterflow`, or launch.

## Design

The candidate uses Guardian's existing burgundy/red and gold palette from
`QuestwellPixelPalette`, with structured cloth, a flat stitched shoulder yoke,
gold piping, four brass fasteners in two pairs, one plain viewer-right chest
welt and two hip welts. A small shield-outline crest on the viewer-left sleeve
and one isolated chevron on each lower front panel are embroidery only.
There is no held shield, armor, weapon, glove, bag, or other equipment.

The built-in image-generation tool authored three garment-only sources. The
male source supplies the common design; each body uses its own tailoring
reference and independently measured geometry. The Alchemist references are
unchanged and contribute only fitting/rendering guidance, not class identity.

## Revision 2: linework correction

The founder rejected revision 1's uneven lines. Its fit coverage checks passed,
but the visual inspection missed the pinched waist piping, inconsistent gold
width and crowded branching hem decoration. Revision 1 is not approved.

Revision 2 removes the inset branching borders and replaces the three stacked
chevrons with one small chevron per lower panel. New source art has clearer
gold edges and more space around the embroidery. A targeted female source edit
also separates the two front halves, preserving actual alpha through the opening.

Fitting now includes a local front-piping map after the body-landmark fit.
Measured gold edges follow smooth waist paths, with the outer torso and sleeves
pinned outside that adjustment. The gold fill is held at 1.85 native pixels
through the central section and blended into the original lapels and lower
turns. This corrects the fitting distortion as well as the source design.
Coordinates are mapped back to the original texture; no trim is painted over
the image and no base anatomy is removed to disguise an art defect.

| Actual exported waist measurement, rows 130–160 | Male v1 → v2 | Female v1 → v2 | Neutral v1 → v2 |
| --- | --- | --- | --- |
| Minimum pixels between gold edges | 8 → 11 | 5 → 12 | 8 → 12 |
| Gold fill width range | 1–2 → 1–2 | 1–6 → 1–2 | 1–3 → 1–2 |

Gold measurements use RGBA thresholds documented in the Flutter regression
test. They catch this pinched-opening/thick-wedge failure, but visual review
remains necessary for the shape, joins and embroidery.

## Review surfaces

- Previous portrait/card comparison: [Guardian revision 2](guardian-v2-portraits-and-cards.png).
  Inspected against the exported revision 2 assets at enlarged and 176 px sizes.
- App: https://funszdidiot.github.io/questwell-app/ — Adventurer → Your Archetype
  → Guardian. Check Male, Female and Gender Neutral.
- Direct comparison: https://funszdidiot.github.io/questwell-app/guardian-fit-review.html
  — exact runtime bases, coats and matching generated visibility paths, with
  the same portrait fill and 176 px card art. Coat/jacket toggles aid inspection.

## Developer checklist

- [x] Preserve approved bases, Scholar, Scout and Alchemist artwork and fit inputs.
- [x] Author a separate garment and measured source/base landmarks for each body.
- [x] Keep anatomy and base clothing out of the source garment.
- [x] Export transparent 240 × 320 WebPs on the shared canvas; no runtime offset.
- [x] Match shoulders, upper arms, elbows, waist, cuffs and hem to the frozen base.
- [x] Keep continuous side-panel coverage between anchors, not just at anchors.
- [x] Cover outer trouser edges below the hands without clipping trousers away.
- [x] Preserve visible head/hair, shirt/tie, belt, hands, trousers and shoes.
- [x] Remove isolated suit-jacket fragments beside male/neutral wrists using
  Guardian-specific underlayer paths. Keep hand contours intact.
- [x] Match four fasteners, pocket layout and embroidered motifs across bodies.
- [x] Simplify branching hem borders and retain one isolated chevron per panel.
- [x] Smooth waist piping through a local fit that preserves the outer body fit.
- [x] Check actual exported gold clearance and width; add regression assertions.
- [x] Inspect enlarged portraits and 176 px card composites for all three bodies.
- [x] Keep garment separate from inventory and five accessory slots.
- [x] Add actual-image trouser coverage and app portrait/card tests to Flutter CI.
- [x] Reproduce all three revision 2 exports from their retained source masters;
  confirm byte-for-byte agreement with the candidate manifest.
- [x] Recheck the finished asset pixels: zero outer-trouser exposure, two
  connected garment halves, clear head/shoe regions and 1–2 px waist gold fill.
- [ ] Founder reviews all three bodies in the app, including iPhone Safari.
- [x] Record acceptance and freeze Guardian before moving to Wanderer.

| Body | Revision 2 first-fit exposed outer trouser pixels | Finished candidate | Fit |
| --- | ---: | ---: | --- |
| Male | 57 | 0 | Structured shoulders, wrist contact, smooth side coverage |
| Female | 0 | 0 | Narrower shoulders/torso, higher wrists, visible long hair |
| Gender Neutral | 9 | 0 | Separate balanced silhouette, moderate waist taper |

Counts inspect native-canvas alpha ≥128 on rows 196–240 of the actual coat and
frozen base. Each finished garment has two connected opaque halves, no opaque
pixels above row 72 or below row 294, clear anatomy openings, and a fold-free
fit mapping. These checks do not substitute for founder visual acceptance.

## Reproduction and validation

- Runtime: `assets/images/questwell/avatar/classes/guardian/`, female `v3`,
  male/neutral `v2`.
- Source masters and full built-in prompts: `tool/art_assets/guardian_v2/`.
- Measured landmarks and side contours: `tool/guardian_fit_anchors.json`.
- Export: `node tool/fit_guardian_coat.cjs` (Node + ImageMagick). Smooth inverse
  thin-plate mapping followed by local front-piping and continuous side fitting;
  compose source coordinates, supersample at 4×, and export lossless WebP.
  Reject folded body maps and nonmonotone local fit intervals.
- Coverage source: `tool/guardian_underlayer_visibility.json`.
- Generate matching Flutter/browser paths: `python3 tool/generate_guardian_underlayer.py`.
- Verify all frozen locks and candidate checksums: `python3 tool/verify_avatar_assets.py`.
- App integration tests: `test/guardian_underlayer_clip_test.dart`, run with the
  existing Scholar/Scout/Alchemist suites in the Flutter Check workflow. Decode
  the real WebPs, verify trouser coverage, waist piping clearance/width, anatomy
  retention, body/clip pairing, shared alignment, and portrait/card layout at
  320, 390 and 430 px widths.

Public browser review is a comparison surface; it is not evidence of operating
a signed-in iPhone Safari session. Build success does not confer visual approval.
