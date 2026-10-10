# Deferred work

## Evergreen gallery wall

- Run Flutter regression/capture tests and inspect real renderer after public
  branch publication is explicitly authorized. Local Flutter dependency setup
  and public push were blocked by automatic review; no completed CI is claimed.
- Review the gallery with avatars/furniture and rainy/Amberfall overlays at phone,
  foldable and desktop widths. Artwork equivalence does not prove window-mask fit.
- After prices and activation are approved, add the server-owned `wall_textile`
  profile and catalog/render registry rows in a scoped forward migration. Enforce
  Guardian-only eligibility for Guardian’s Oath, plus ownership, idempotent
  purchasing and placement persistence. Use existing RLS and backend gates.
- Create matching 16-bit inventory icons as part of that catalog phase.

## Autumn Hearth

- Confirm standard-room window visibility at narrow widths before catalog release;
  existing cover crop hides its far-right glass. Do not move locked room geometry
  silently. Other settings need their own verified glass masks.
- Review the new floor décor family fit and app-scale overlap; concept approval
  is not a runtime geometry lock.
- Add matching inventory icons and server catalog metadata only after release
  terms/pricing approval. Verify account equip/unequip/restore and purchases in
  the subsequent catalog phase, with applicable backend and RLS tests.
- Hosted and physical-device acceptance still pending. See qa/AUTUMN_HEARTH.md.
