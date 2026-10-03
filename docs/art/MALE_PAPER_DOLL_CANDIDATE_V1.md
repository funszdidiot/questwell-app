# Male paper-doll foundation — approval draft

Tanya authorized the male foundation on 2026-10-03 while explicitly holding all male outfits until the neutral everyday outfit, robes and Woodland Scout are finished. This artifact is a body-approval draft only. It does not replace the current male avatar in the app, and it is not an approved clothing template yet.

The candidate is a complete barefoot male avatar in an ivory sleeveless undershirt and charcoal under-shorts. Existing male identity, overall stance and body-type reference are retained. After body approval, this entire foundation becomes immutable; future clothing belongs in separate front/rear layers. The female and neutral approved bodies were not edited.

## Files

- `tool/art_assets/male_paper_doll_v1/body_source.png`: original generated foundation source.
- `tool/art_assets/male_paper_doll_v1/paper_doll_male_candidate_v1.webp`: full 240 × 320 candidate.
- `tool/art_assets/male_paper_doll_v1/paper_doll_male_identity_candidate_v1.webp`: original head/hair foreground on the same canvas.
- `tool/art_assets/male_paper_doll_v1/male_paper_doll_review.png`: enlarged render of the actual registered candidate for approval.
- `tool/art_assets/male_paper_doll_v1/prompt.json`: complete built-in image-editing prompt and candidate hashes.

Reproduce with `node tool/export_male_paper_doll_candidate.cjs`. The exporter restores the existing male head/hair above y74 from `base/base_male.webp`; it does not import the generated face. Validation found zero changed visible head/hair RGB values and zero changed alpha values in that region. Fully transparent hidden RGB values may be normalized by lossless WebP encoding and do not affect rendering. The existing asset-integrity verification passes for the locked female and neutral art.

Review the frame, undergarments, shoulders, arms, wrists/hands, hips, stance and complete feet. Tanya's explicit approval is required before declaring this body locked. The next wardrobe output is neutral everyday clothing matching the female design, not male clothing. See `PAPER_DOLL_STANDARD.md`.
