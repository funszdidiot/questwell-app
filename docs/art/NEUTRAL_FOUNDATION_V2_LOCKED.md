# Neutral foundation v2 — neck seam repaired and locked

**Superseded by v3:** Tanya subsequently identified that the head remained left of the neck center. V3 translates the original head four native pixels right and updates the canonical lock. Do not use v2 for new fittings. See `NEUTRAL_FOUNDATION_V3_CENTERED.md`.

Tanya explicitly instructed: fix the avatar first, then lock it, before refitting the clothing. She emphasized that foundational fits determine all future garments and that variety should come from colors, patterns and flourishes on consistent designs. This narrow base correction is therefore authorized; it does not reopen the body for later outfit-driven adjustments.

## Repair

The v1 base had a pale slit and double shadow beneath the chin where the original head had been copied onto a separately generated torso. Preserving v1 preserved that defect. Built-in imagegen supplied a local neck-shading repair. `tool/export_neutral_neck_v2.cjs` imports only the small neck patch and cleanup of adjacent horizontal splice fragments. It never imports the generated face, shoulders or clothing. The main hairstyle above the join remains original.

Exactly 335 visible/alpha pixels changed, within x101–147 and y73–81. All visible RGB and alpha outside the repair mask remain identical. Alpha cleanup is confined to 184 pixels in the adjacent lower-hair splice regions; it does not alter the body silhouette. The head position, jaw above the seam, face, body proportions, pose, undergarments, arms, hands, hips, legs and feet remain original. The corrected foreground identity receives the repaired row beneath the chin so an old overlay cannot restore the seam.

Full-figure and enlarged neck renders were inspected after exporting the actual 240 × 320 files. The bright horizontal slit, doubled neck band and sideways splice fragments are removed. The region retains a natural under-jaw shadow. This visual inspection accompanies the pixel comparison; hash checks alone are not used as evidence that the neck looks connected.

## Canonical locked files

- `assets/images/questwell/avatar/base/paper_doll_neutral_v2.webp`
- `assets/images/questwell/avatar/base/paper_doll_neutral_identity_v2.webp`
- `tool/neutral_avatar_fit_reference.json`

The asset manifest locks the new files and their repair source. V1 and its former lock record remain for provenance. The neutral paper-doll widget selects the corrected foundation. All future reference preparation must read the canonical lock JSON; historical v1 exporters remain only to reproduce their earlier drafts. The source, exact imagegen prompt, evidence and previews are retained in `tool/art_assets/neutral_paper_doll_v2/`.

## Clothing remains pending

The everyday and robe candidates are not approved by this repair. The v6 robe wrist fit was rejected and remains pending correction. Establish the everyday fit and each garment-family fit on this one fixed body, then preserve the accepted geometry and depth masks across decorative variations. No clothing pixels were changed during the foundation repair, and no male wardrobe work was started.

This correction is locked in the working repository. The earlier shared-branch push was blocked by automatic approval review; this task does not retry it or claim a live-app deployment. No merge to `flutterflow`, account/Market mutation, or launch occurred.
