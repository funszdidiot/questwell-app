# Guardian garment review — 29 September 2026

**Development candidate: `guardian-v1`. Founder visual acceptance is pending.**

Alchemist was approved after its revision 4 app delivery with “Good to go.”
Its three-body set and fitting inputs are frozen as `alchemist-approved-v1`.
Guardian is next in the agreed class sequence; Wanderer waits for Guardian
acceptance. This does not promote Epic 2, merge to `flutterflow`, or launch.

## Design

The candidate uses Guardian's existing burgundy/red and gold palette from
`QuestwellPixelPalette`, with structured cloth, a flat stitched shoulder yoke,
gold piping, four brass fasteners in two pairs, one plain viewer-right chest
welt and two hip welts. A small shield-outline crest on the viewer-left sleeve
and three stacked chevrons on each lower front panel are embroidery only.
There is no held shield, armor, weapon, glove, bag, or other equipment.

The built-in image-generation tool authored three garment-only sources. The
male source supplies the common design; each body uses its own tailoring
reference and independently measured geometry. The Alchemist references are
unchanged and contribute only fitting/rendering guidance, not class identity.

## Review surfaces

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
- [x] Inspect enlarged portraits and 176 px card composites for all three bodies.
- [x] Keep garment separate from inventory and five accessory slots.
- [x] Add actual-image trouser coverage and app portrait/card tests to Flutter CI.
- [ ] Founder reviews all three bodies in the app, including iPhone Safari.
- [ ] Record acceptance and freeze Guardian before moving to Wanderer.

| Body | Initial exposed outer trouser pixels | Finished candidate | Fit |
| --- | ---: | ---: | --- |
| Male | 59 | 0 | Structured shoulders, wrist contact, smooth side coverage |
| Female | 9 | 0 | Narrower shoulders/torso, higher wrists, visible long hair |
| Gender Neutral | 6 | 0 | Separate balanced silhouette, moderate waist taper |

Counts inspect native-canvas alpha ≥128 on rows 196–240 of the actual coat and
frozen base. Each finished garment has two connected opaque halves, no opaque
pixels above row 72 or below row 294, clear anatomy openings, and a fold-free
fit mapping. These checks do not substitute for founder visual acceptance.

## Reproduction and validation

- Runtime: `assets/images/questwell/avatar/classes/guardian/guardian_coat_*_v1.webp`.
- Source masters and full built-in prompts: `tool/art_assets/guardian_v1/`.
- Measured landmarks and side contours: `tool/guardian_fit_anchors.json`.
- Export: `node tool/fit_guardian_coat.cjs` (Node + ImageMagick). Smooth inverse
  thin-plate mapping followed by continuous side fitting; sample the original
  source once, supersample at 4×, and export lossless WebP. Reject folded maps.
- Coverage source: `tool/guardian_underlayer_visibility.json`.
- Generate matching Flutter/browser paths: `python3 tool/generate_guardian_underlayer.py`.
- Verify all frozen locks and candidate checksums: `python3 tool/verify_avatar_assets.py`.
- App integration tests: `test/guardian_underlayer_clip_test.dart`, run with the
  existing Scholar/Scout/Alchemist suites in the Flutter Check workflow. Decode
  the real WebPs, verify trouser coverage, anatomy retention, body/clip pairing,
  shared alignment, and portrait/card layout at 320, 390 and 430 px widths.

Public browser review is a comparison surface; it is not evidence of operating
a signed-in iPhone Safari session. Build success does not confer visual approval.
