# Coat underarm and female cuff correction

2026-10-05 America/Chicago — QA; local repair passed independent visual review, development delivery pending.

Founder finding: all three coats have exposed skin or compensating fabric
between sleeves and inner arms; female cuffs remain unnatural. No shoddy patches,
body changes, sleeve stretching or compensating strips are acceptable. This
supersedes the earlier delivered coat visual PASS. Cloak and mantle are accepted
and outside this repair.

## Investigation

- Locked-body and garment assets remain byte-identical in the development app.
- Existing coat exports use uniform source registration. The wrist-depth change
  fixed a disconnected hand cutoff but did not establish acceptable cuff shape.
- New whole-coat image edits were tried with source/composite/body references,
  explicit inward sleeve ease, complete inner-sleeve redraws, and full-canvas
  fitting references. None reliably preserved fit and repaired every contour.
- Rejected female variants left inner arm slivers or shifted the outer sleeve;
  the final extraction experiment introduced unwanted white shirt cuffs.
- Male variants retained image-right inner-arm slivers; one cropped the outer
  cuff. Neutral improved image-left coverage but remains unapproved.
- Generated-person images were fitting studies only. No generated anatomy is
  permitted in the renderer. Never substitute a generated person for the body.
- No new candidate is registered in the production asset manifest or renderer.

## Repair requirements

Repair the entire connected sleeve/armhole/underarm region as coherent wool with
consistent shading and folds. Preserve body-specific outer width, narrow male
elbows, fixed hands/thumbs and existing design. Female cuffs need a small curved
fabric rim around the actual wrist, with rear depth and a foreground lip; do not
use flat tabs, rigid rings, enlarged trumpets or new white cuffs.

Reference assets: `harvest_coat_{female,male,neutral}_v6.webp` and their rear
layers; source coats in `tool/art_assets/legacy_depth_v1/`; immutable foundations
and identity files in the body fit references. Native canvas is 240 x 320.
Inspect both arm contours especially y120–160 and wrist regions female y165–175,
male/neutral y170–182. Distinguish original hair from exposed arm skin.

Before integration: zero unintended upper/forearm skin in the final composite,
no patches or seam fragments, intact original fingers/thumbs, natural cuff wrap,
native/enlarged light/dark independent review, then actual Hearth verification.
Tests and asset hashes cannot substitute for these visual checks.

## Authorized direct repair

Tanya answered “Yes” to direct raster editing of the complete sleeve and cuff
regions. The method decision is resolved; no founder blocker remains. Current
v8 candidates are BUILDING and have not been integrated or deployed. Review
continuous cloth contours, natural underarm air space and wrist depth before
integration. Preserve all locked foundations and accepted cloak/mantle assets.

## Current direct-raster candidate

`tool/paint_coat_v8.py` produces registered v8 fronts and cuff backs. Complete
inner-sleeve contours preserve natural air spaces while covering the fixed arms.
The female correction carries the connected sleeve folds into wrist-centered
cuffs, with a shallow curved front hem and cavity behind the original wrist.
The foreground copy contains original hands only; the primary body is intact.

Rejected intermediate passes included a flat painted forearm, square underarm
cutouts and skin visible above a crossing cuff line. They were not integrated.
Opacity inspection also caught pale undershirt bleed missed by skin-only tests.
`tool/verify_coat_v8.py` checks locked foundations, change scope, opaque coverage
over both skin and undershirt, and preservation of intentional underarm space.
Independent visual review and runtime verification remain required.

Independent local review: PASS on native and 3× exports, light and dark.
Female front `369b7d58837e`, male `5bdcd73f78f8`, neutral `654d3fde86ac`.
Resolved square openings, painted forearm, floating cuff line, pale undershirt
seam and male cuff endpoint notch. This is not founder approval or runtime QA.

## Delivered fit verification and sampling follow-up

Runtime `9f65041`, workflow `37326943014`: 386 Flutter and 12 Node tests,
analysis, locked dependencies, build and deployment passed. All31 delivered
asset hashes matched. Actual shared renderer/Hearth, wear/remove/restoration,
belt grimoire and sample Market preview/purchase/equip/unequip were verified.
All3 delivered enlarged coat fits passed independent visual QA.

Enlarged runtime review caught a separate straight line below the male chin on
coat and cloak, absent from an exact local layer composite. Investigating
identity sampling at its transparent cutoff; scoped bilinear sampling in legacy
chest states is under QA. No body, identity or accepted cloth bytes are changed.
Do not close runtime QA until the delivered follow-up is checked.

Sample Market evidence: female Scholar, 390px layout, Harvest Coat search;
try-on showed v8, sample purchase650→470, Owned→Equip→In use, preview Unequip
returned Owned with470 unchanged. These are in-memory review fixtures, not
a real-account purchase or persistence claim. Catalog eligibility and equipment
policy were unchanged; existing all-body/class restoration regressions passed.

Sampling follow-up `0a4814f`, workflow37329335033, passed the full386Flutter +
12Node gate and31delivery hashes, but the neckline line remained. Bilinear
sampling is therefore reverted. The next rendering correction samples the
exact original head rows0..73 from the complete locked body before clipping the
foreground duplicate. Every visible RGBA pixel in this region equals the locked
identity export; the source files and primary full body stay unchanged. This
is a rendering correction, not replacement anatomy. Actual runtime verification
remains pending.
