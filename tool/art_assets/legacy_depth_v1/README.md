# Natural drape and cuff depth correction

Status: BUILDING; active founder-requested correction, not a new template lock.
The exact production and delivery record is `docs/qa/CLOAK_MANTLE_INNER_FLAPS.md`.

Sources were edited with the built-in image-generation tool. Selected source
pixels are stored losslessly as WebP; PNG previews are reproducible outputs,
not separate designs. Earlier rejected broad silhouettes are not selected.

## Prompt/edit brief

- Fronts: remove hanging inner flaps/lining tongues while preserving the existing
  cloak/mantle palette, trim, collar/clasp and body-specific shoulder contact.
- Drape: replace triangular radial flare with predominantly vertical,
  gravity-supported cloth; retain enough upper/middle width to cover complete
  fixed arms/hands, then fall naturally inward below them. No body generation,
  widening or masking. No reintroduced flaps, balloon volume or distorted motifs.
- Rear sources: one continuous plain interior cloth sheet in matching moss green
  or burgundy, subtle vertical folds, no front trim/embroidery or center slit.
- Coat cuffs: widen the openings inward, preserving wrist centers and making a
  curved gold rim. Narrow male outer elbow fullness, taper the forearm, maintain
  continuous inward arm coverage. Preserve all other Harvest Coat design.

## Reproduction and invariants

Run `NODE_PATH=<sharp module parent> node tool/export_legacy_depth_v1.cjs`, then
`node tool/verify_legacy_depth_v1.cjs` with the same NODE_PATH. Whole garment
sources receive uniform registration on the native 240 × 320 canvas. No piecewise
shirt/vest/sleeve warps or runtime transforms. Remove only tiny isolated export
noise. The rear sheet is bounded by its own fitted front's outer envelope, never
by a body mask. Cuff cavity depth contours trace the authored oval openings:
their original dark cloth sits behind the full body, gold rims remain in front.
The established original-hand foreground duplicate exposes fingers and thumbs.

Body, identity, Everyday, historical robe files and their locks are unchanged.
These nine garments are independent fits, not a cross-body geometry template.
`exports.json` records source hashes, registrations, depth contours and all 18
runtime file hashes. Visual QA must inspect the final shared-renderer composite;
automated coverage, hashes and a successful build cannot imply founder approval.
