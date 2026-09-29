# Rear robe construction — development candidate

Revision: `robe-wrap-v1`. Founder accepted all twelve fits on 2026-09-29 and directed “Ok! Let’s do wanderer.”
The founder authorized correcting the missing wrap-around construction before
starting Wanderer. This supersedes the earlier single-front-layer construction,
not the approved class colors, designs or frozen avatar anatomy.

## Construction

Every supported class now draws three full-size, aligned 240 × 320 layers:
**rear lining → clipped frozen base → existing front garment**.

The generated inside-back fabric is continuous and opaque. The actual legs hide
it, leaving natural interior fabric visible between them. The rear side edges
sit inside the measured front-panel footprint so front cloth overlaps the rear
at the hips and sides. A curved, recessed back hem ends above the front tips and
boots. Interior shading provides depth without another gold/silver border.

This is front-view garment construction. It does not add rear-facing avatars,
turnaround animation or a back-view selector.

Four source masters were authored with built-in image generation. Each class
uses its own navy/indigo, forest-green, sapphire or burgundy cloth. Each of the
three bodies has separate waist, side and hem coordinates measured from its
existing front garment. The front assets and all base/underlayer bytes remain
unchanged, including the latest female Guardian sleeve/hip correction.

## Review

- [All classes](https://funszdidiot.github.io/questwell-app/robe-wrap-review.html)
- Each class review has a **Show rear lining** checkbox for before/after comparison.
- [All twelve portrait/card comparisons](robe-wrap-all-fits-v1.png)
- [Guardian close comparison](guardian-rear-wrap-v1.png)

| Class | Male | Female | Neutral |
| --- | --- | --- | --- |
| Guardian | New rear candidate | New rear candidate; front v3 | New rear candidate |
| Scholar | New rear candidate | New rear candidate | New rear candidate |
| Scout | New rear candidate | New rear candidate | New rear candidate |
| Alchemist | New rear candidate | New rear candidate | New rear candidate |

Previous front-design approvals remain recorded. They do not approve the newly
layered appearance. Guardian was accepted with this review; Wanderer may proceed.

## Checklist

- [x] Preserve approved front artwork, bases, poses and underlayer visibility.
- [x] Fit twelve separate transparent rear assets on the shared canvas.
- [x] Use actual leg occlusion, not painted-on legs or leg-shaped holes.
- [x] Keep side joins behind front panels and rear hems above the boots.
- [x] Inspect all twelve composites and 176 px cards.
- [x] Connect shared runtime layers and all four class review pages.
- [x] Add rear continuity, head/feet clearance and layer-order checks to Flutter CI.
- [x] Founder reviews wrap, lining colors, side joins and hem depth on all bodies.
- [x] Founder accepts the layered construction before Wanderer begins.

## Reproduction and provenance

- Masters and exact prompts: `tool/art_assets/robe_wrap_v1/`.
- Per-body rear coordinates: `tool/robe_wrap_fit.json`.
- Export: `node tool/fit_robe_rear.cjs` (Node and ImageMagick).
- Composite proof: `python3 tool/render_robe_wrap_review.py` (Pillow).
- Integrity check: `python3 tool/verify_avatar_assets.py`, including the new
  `candidate_layers.robe_wrap` assets and fit inputs.
- Runtime tests: `test/robe_wrap_test.dart` plus the existing four class suites.

Development review only. No production merge, Epic 2 promotion or launch is
authorized by this construction change or by a passing build.
