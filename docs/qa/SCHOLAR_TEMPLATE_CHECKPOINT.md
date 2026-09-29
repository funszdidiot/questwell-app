# Scholar template checkpoint — 29 September 2026

**Approved and frozen by founder direction on 29 September 2026.**
Template revision: `scholar-approved-v1`. Approved source commit:
`71f6f5d38315155222ce6832ea6fc6ee12b13be0`.
Approval covers Male, Female and Gender Neutral Scholar variants and their
current fit/layering/presentation. It does not authorize a production merge or
launch, or establish approval of any other class.

## Approved rules to carry forward

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
- [x] Founder approved freezing the current three-body Scholar template.

Review record: founder supplied in-app views of all three bodies during fit
review, then supplied the final female iPhone view and directed the template
freeze. We did not independently operate a signed-in iPhone Safari session.

The public review page uses the same assets and generated visibility coordinates.
Its portrait fill and card sizing mirror the app. It is a visual review surface;
the signed-in mobile app remains the founder acceptance surface for future classes.

Retain this checkpoint as the template. The build verifier locks the base/robe
hashes plus the Scholar visibility specification and generated Flutter clipper.
Changes to the approved Scholar inputs need another visual review. Refit other
class art to each body independently; do not resize one body's garment to make
the remaining variants.

Next class: Scout. Use its existing forest-green/gold identity, author three
garment-only 240 × 320 overlays, and create Scout-specific jacket-coverage paths.
Reuse the checklist and coordinate system; do not assume Scholar's visibility
polygons fit a different garment silhouette. Review all three bodies in the
portrait and selection cards before accepting Scout.
