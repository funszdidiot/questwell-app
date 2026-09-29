# Wanderer v2 — development review

Founder direction, 2026-09-29: “Ok! Let’s do wanderer.” This accepts the
preceding Guardian and four-class rear-construction review and authorizes
Wanderer development. Wanderer's appearance still needs its own visual review.

## Design and fit

Tobacco-brown travel coats replace the first blue palette after the founder
requested more class color variation. Copper-gold edging and fasteners, a short shoulder yoke, and small
four-point compass-star embroidery remain. The rear lining is muted ochre. No equipment is baked into the clothing.
The three front masters and rear cloth were created using built-in image
generation; exact prompts are in `tool/art_assets/wanderer_v2/prompts.json`.

Male, Female and Gender Neutral each have their own generated master and
measured fitting controls. All exports are transparent 240 × 320 WebP files.
The runtime draws rear fabric, the matching clipped base, then the front coat
at one origin and scale. Heads, hands, shirt/tie, trousers and boots remain
owned by the frozen base. No base or previously accepted garment was edited.

The first fitting pass exposed a few outer-trouser pixels at the female and
neutral hips. Local side-seam adjustments correct these while preserving the
front piping and sleeves. Actual exported-image checks cover trouser clearance,
open waist piping, trim width and female sleeve/hip continuity. Rear cloth is
continuous, with the legs providing natural occlusion.

Color-edit masters were registered back to the existing body landmarks;
cuff and side-seam clearances were rechecked. The previous blue assets remain
versioned for comparison. Other classes retain their accepted palettes.

## Review surfaces

- `wanderer-fit-review.html`: all three portraits and 176 px selection cards.
- Toggles: coat, rear lining, alignment guides and original jacket comparison.
- `robe-wrap-review.html`: all five classes; Wanderer selected initially.
- `docs/qa/wanderer-fit-v2.png`: rear-off/rear-on and card comparisons.
- `docs/qa/wanderer-lineup-v2.png`: the three complete outfits.

## Checklist

- [x] Three garment-only front assets, each fitted independently.
- [x] Three continuous rear assets and natural leg occlusion.
- [x] Visible hands, compact cuff contact, smooth elbow/hip contours.
- [x] Clear shirt/tie opening and retained stance/boot clearance.
- [x] Shared app renderer and browser review layers match.
- [x] Inspect native portraits, enlarged female fit and 176 px cards.
- [x] Register source/fit/asset hashes and add Wanderer to Flutter checks.
- [ ] Founder accepts Male, Female and Gender Neutral appearance.
- [ ] Founder completes the broader iPhone Safari/Epic 2 visual gate.

## Reproduction

1. `node tool/fit_wanderer_coat.cjs`
2. `node tool/fit_wanderer_rear.cjs`
3. `python3 tool/generate_wanderer_underlayer.py`
4. `python3 tool/render_wanderer_review.py`
5. `python3 tool/verify_avatar_assets.py`

Flutter coverage: `test/wanderer_underlayer_clip_test.dart` plus
`test/robe_wrap_test.dart`. A passing build is not founder visual acceptance.
Development remains on `questwell-dev`; no merge to `flutterflow` or launch.
