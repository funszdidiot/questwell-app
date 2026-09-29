# Scholar template checkpoint — 29 September 2026

Candidate frozen for final founder review. No other class fit, production merge,
or launch is included in this checkpoint.

## Rules to carry forward after approval

- Frozen body sources: base_male.webp, base_female.webp, base_neutral.webp.
- Scholar garment source of truth: corresponding scholar_robe_*_polish_v2.webp.
- Each source remains a transparent 240 × 320 canvas, stacked at the same origin.
- Body-specific visibility paths hide the original jacket; head/hair, shirt/tie,
  belt, hands, trousers and shoes are retained.
- The main Adventurer view uses artHeightFactor .96 inside its existing frame.
  This enlarges the complete composition about 9% from .88, with no robe-only
  scaling, recentering, stretching or change to canvas proportions.
- Selection art stays at 176 px high. A gold checkmark plus SELECTED text and
  semantic selected state provide confirmation without a toast.

## Final checks

- [x] All six base/robe hashes remain unchanged in the reviewed manifest.
- [x] Enlarged female shoulder/hair inspection; restored hairline and curl tip
  pixels excluded by the previous underlayer boundary.
- [x] Added coverage checks for those hair points.
- [x] Added native Flutter portrait/card layout checks at 320, 390 and 430 px.
- [ ] Founder final iPhone Safari review of all three bodies.

The public review page uses the same assets and generated visibility coordinates.
Its portrait fill and card sizing mirror the app. It is a visual review surface;
the signed-in mobile app remains the final founder acceptance surface.

After founder approval, record approval here and retain this checkpoint as the
template. Refit other class art to each body independently; do not resize one
body's garment to make the remaining variants.
