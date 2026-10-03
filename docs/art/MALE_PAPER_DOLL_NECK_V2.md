# Male paper doll — neck-only correction

**Rejected by Tanya:** the narrow contour and fragmented neck edges remained. Superseded by the wider-neck v3 draft in `MALE_PAPER_DOLL_NECK_V3.md`. The following records the attempted v2 repair, not an accepted result.

Tanya identified the head-to-neck join in the first male draft and explicitly authorized correcting only that connection. The original head restoration had carried small old collar fragments into the new neck and left an uneven transition. V2 removes those fragments and softens the neck shading below the unchanged jaw.

This is still an unapproved male foundation. No male outfits, app-avatar replacement, Market/account changes, merge or launch are included. The neutral-first wardrobe gate in `PAPER_DOLL_STANDARD.md` remains in force.

## Final candidate and review

- `tool/art_assets/male_paper_doll_v2/paper_doll_male_candidate_v2.webp`: corrected 240 × 320 full paper doll.
- `tool/art_assets/male_paper_doll_v2/paper_doll_male_identity_candidate_v2.webp`: matching identity foreground, so the removed collar fragments cannot return.
- `tool/art_assets/male_paper_doll_v2/male_paper_doll_review_v2.png`: full review render.
- `tool/art_assets/male_paper_doll_v2/neck_detail_v2.png`: neck close-up.
- `tool/art_assets/male_paper_doll_v2/neck_repair_source.png`: retained generated correction source.
- `tool/art_assets/male_paper_doll_v2/prompt.json`: exact built-in image-editing prompt, hashes and verification results.

Reproduce with `node tool/export_male_neck_v2.cjs`. It starts from the exact v1 candidate, selects only the neck repair, preserves the fixed jaw/face and undershirt, and blends the corrected skin shading without another horizontal cut. The generated crop's face, hair and clothing are not substituted into the draft.

Validation: 269 pixels changed within x100–142, y71–86. No visible RGB or alpha values changed outside that neck rectangle. Checks also found no face or ivory-garment changes. Fully transparent hidden RGB can normalize during lossless WebP encoding without affecting rendering. Existing approved female and neutral asset verification still passes. Both full-size and enlarged neck renders were inspected. Founder visual approval is required before locking the male body; v1 is retained for history.
