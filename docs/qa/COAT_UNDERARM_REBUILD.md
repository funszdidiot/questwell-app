# Coat underarm and female cuff correction

2026-10-05 America/Chicago — BUILDING; no replacement passed QA or shipped.

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

## Tool limitation / next decision

The available generative editor has not delivered the required local precision
after repeated attempts. Its instruction requires explicit user direction before
switching to another image-editing method. Ask for direct raster editing of the
existing complete sleeve/underarm/cuff regions, with no anatomy modifications or
patch strips. This is a method decision, not acceptance of a failed candidate.
