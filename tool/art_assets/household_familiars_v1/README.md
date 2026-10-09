# Boston Terrier and Hearth Cat — v1

Tanya approved the two-character concept on October 9, 2026 and asked to continue
with idle animation. The black-and-white Boston terrier keeps its moss bandana
and brass star; the charcoal cat keeps golden eyes, plum collar and crescent.
Animation exports remain candidates until runtime and visual acceptance.

## Source and export

Built-in ImageGen generated the source sheets from the approved concept. Prompt
brief: same character, eight seated poses, four equal columns by two rows,
1536x1024 transparent canvas, natural anatomy and consistent scale. Terrier:
neutral, ear twitch, blink, neutral, left head tilt, right head tilt, happy
wiggle, neutral. Cat: neutral, half blink, blink, neutral, two curled-tail-tip
poses, paw lick with tongue, paw lick without tongue. Correction prompts removed
an extra cat tail and shrank all pets within their cells to prevent overlap.

`export.cjs` uses sharp **0.35.4**, extracts complete sprites, clears only
near-transparent matte residue, and translates them to a shared ground edge.
It never repaints or stretches anatomy. Exact repeated neutral frames reuse
frame zero. `registration.json` records all source bounds and translations.
Runtime sheets are lossless WebP with alpha; all tiles are 384x512, contact edge
498. Source sheets are retained here for reproducibility. Run:

```sh
node tool/art_assets/household_familiars_v1/export.cjs
```

The existing pinned Flutter **3.44.6** renders one cached sheet with clipped
tiles and nearest-neighbor filtering. The existing familiar clock pauses for
reduced motion and disabled TickerMode. These are presentation-only effects.
No new runtime dependency. Release authorization and catalog integration follow
`docs/qa/HOUSEHOLD_FAMILIARS_RELEASE.md`.

The existing code-native 32px icon painter provides smaller inventory-style
icons with matching markings and accessories, separate from in-world sprites.

## Integration scope

Development route: `?review=companions`, defaulting to Boston Terrier. Both new
pets can be tried beside all three bodies and in the usual Hearth. Tanya later
authorized pricing and release; both are now in Market samples and the
render-ready allowlist. Actual availability remains server-authoritative.

`preview.gif` samples the runtime timing at 100ms for a portable art preview.
It is not a recording of the Flutter renderer or evidence of deployment.

## Validation and limits

- PASS: 10,001 timing samples per species; all expected action frames, no invalid
  indices, and neutral loop boundaries (Dart SDK 3.12.2).
- PASS: deterministic export rejects source edge clipping; 16 frames fit their
  cells, carry alpha, and use a consistent ground edge.
- PASS: Dart formatting and `git diff --check`.
- Visual inspection caught and corrected extra tail and clipped-terrier defects.
- Added widget tests for three-body rendering, small/wide bounds, animation
  advancement, reduced motion, TickerMode, removal and Market pricing.
- Local Flutter startup was blocked by automatic approval review because it
  attempted cloud-instance metadata access. No retry or bypass was made.
  Widget tests/analyzer, browser and native builds passed repository CI on
  `1d95b223`; the pricing/release changes require fresh checks.
- Tanya explicitly authorized publishing the branch and opening its review on
  October 9, 2026. The earlier publication hold is resolved; CI and delivery
  are tracked in the pull request.
- Pending: delivered Flutter visual review, physical iPhone acceptance,
  catalog activation, purchase/equip/persistence verification. No live claims.

Rollback: revert client before catalog activation. After activation, hide the
two catalog entries in a reviewed forward change; preserve purchased ownership.

Official APIs checked: api.flutter.dev docs for AnimatedBuilder, AssetImage,
FittedBox, ClipRect, OverflowBox and Transform.translate; sharp.pixelplumbing.com
constructor and output documentation. No new package was added to the app.
