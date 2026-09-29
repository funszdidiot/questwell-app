# Scout fit review — 29 September 2026

**Founder approved on 29 September 2026: `scout-approved-v1`.**

Approved source: `8f067e7317e30498513f47f6e75d936cf0cebb34`, artwork
`scout-polish-v1`. Approval covers the current Male, Female and Gender Neutral set.
After the app deployment, the founder directed: “Good to go. Next.”

Uses the approved `scholar-approved-v1` checklist and frozen business-suit bases.
Scholar artwork and visibility definitions are unchanged. Scout approval does not
promote Epic 2 or authorize merging to `flutterflow` or launching.

## Review surfaces

- App: https://funszdidiot.github.io/questwell-app/ — Scout Adventurer portrait
  and all three body selection cards.
- Direct comparison: https://funszdidiot.github.io/questwell-app/scout-fit-review.html
  — exact runtime assets and generated Scout visibility paths, matching portrait
  fill and 176 px card sizing. Coat/jacket toggles expose the underlying fit.

## Developer checklist

- [x] Preserve the three frozen base files and approved Scholar template.
- [x] Author a separate forest-green/gold garment for each body; no anatomy,
  shirt, tie, belt, trousers or footwear in the garment source.
- [x] Export each coat to a transparent 240 × 320 WebP at the base origin.
- [x] Fit neck, shoulder slope, armpit, elbow, waist and wrist independently.
- [x] Keep compact cuffs at the hand boundary and hems clear of the boots.
- [x] Polish gold piping, sleeve surfaces and split-hem contours.
- [x] Add Scout-specific underlayer visibility; occlude jacket shoulders,
  sleeves and hip flaps while preserving hair, shirt/tie, belt, hands and legs.
- [x] Inspect all three composites at portrait and 176 px card sizes.
- [x] Use shared class rendering for the app portrait and body selection cards.
- [x] Keep the starter coat out of accessory slots and preserve inventory state.
- [x] Founder accepted the current three-body Scout set after app delivery.
- [x] Record the founder's Scout approval and freeze its artwork/fit inputs.

| Body | Shoulders / sleeve path | Cuffs / hands | Front opening / waist | Hem / stance | Current visual result |
| --- | --- | --- | --- | --- | --- |
| Male | Structured shoulders, independently fitted sleeves | Both hands exposed, compact cuffs | Shirt/tie framed; jacket flaps hidden | Split tails clear boots | Founder approved current set |
| Female | Narrower shoulders and arms; long hair preserved | Cuffs aligned to the higher wrists | Narrow torso and natural waist | Clear stance and boot baseline | Founder approved current set |
| Gender Neutral | Separate balanced torso and relaxed sleeve paths | Both hands exposed | Scout waist clasps frame base belt | Split tails clear boots | Founder approved current set |

The comparison page is a visual review surface. It is not evidence of a signed-in
iPhone Safari session. Build checks also do not establish visual approval.

## Sources and reproduction

Runtime files: `assets/images/questwell/avatar/classes/scout/scout_coat_*_polish_v1.webp`.
Original Scout files remain historical inputs; the app uses the versioned files.

The built-in image-generation tool created three garment masters from the
existing Scout designs and the approved body fit. A second finish pass removed
distorted piping after the initial fit. Final masters and the exact prompt set
are in `tool/art_assets/polished_scout/`. Each master is garment-only.

`tool/scout_fit_anchors.json` records the final body-specific wrist corrections.
`node tool/fit_scout_coat.cjs` reproduces the final lossless WebPs with Node and
ImageMagick. It performs a premultiplied-alpha offline texture bake, rejects
folded triangles and writes the 240 × 320 files. No runtime garment transform.

`python3 tool/generate_scout_underlayer.py` generates Flutter and browser
visibility paths from `tool/scout_underlayer_visibility.json`.
`python3 tool/verify_avatar_assets.py` checks the approved Scholar locks plus
Scout candidate assets and fit sources. Both build workflows verify committed
assets without materializing older artwork over them.

`test/scout_underlayer_clip_test.dart` covers anatomy retention, jacket occlusion,
female curls, contain alignment, body/asset/clip matching, and portrait/card
layouts at 320, 390 and 430 px widths. Scout is recorded under approved classes in the manifest. Its artwork and
fit-input checksums remain locked alongside the approved Scholar template.

Next class: Alchemist. Use the same body-fit checklist, with its own artwork,
coverage paths and visual review.
