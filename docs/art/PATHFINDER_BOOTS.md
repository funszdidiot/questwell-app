# Pathfinder Boots — detailed equipped art

2026-10-01. User requested 64-bit retro fantasy equipped artwork, preserving the separate 16-bit Market/Inventory icon treatment.

Built-in image generation output: `generated_images/exec-8509b3a4-73c9-4e56-beee-640076d51c2b.png` (1536 × 1024, RGBA). Existing male base used only for style and stance reference; all frozen bases and garments remain unchanged.

Final equipped assets:
- `assets/images/questwell_pathfinder_boot_left_v1.webp`: crop 550×822 at (126,99), resized 275×411.
- `assets/images/questwell_pathfinder_boot_right_v1.webp`: crop 537×827 at (873,99), resized 269×414.

Original transparency preserved. Registration is body-specific in `questwell_pathfinder_boots.dart`; original shoe pixels are hidden only while equipped, and both class fronts and cloak fronts render above boots. Catalog keeps its existing rare/Scout/feet/160-coin rules. Matching olive cuffs, leather, buckles and soles use the established native 32px icon painter. Preview `?review=boots` supports all three bodies, garment comparisons, two cloaks, and unequip without account writes. No inventory grant until founder approval.

## Built-in generation prompt

Use case: stylized-concept. Create a production transparent equipment sprite of TWO Pathfinder Boots for the Questwell avatar in the reference. Reference image is stance, scale proportions and detailed retro-fantasy rendering style only. Output only a matching pair of knee-low/mid-calf boots, no legs, no person, no floor, no shadows outside boots, no text. Detailed '64-bit' retro fantasy RPG painted sprite, crisp controlled detail. Worn dark chestnut leather, dark sturdy soles, olive-green folded top cuffs, understated antique brass buckles and leather crossing straps around ankles, small seam stitching, soft warm upper-left light. Foot shapes follow the reference: viewer-left boot points moderately LEFT in three-quarter view, viewer-right boot points moderately RIGHT in three-quarter view, seen from slightly above as on a standing front-facing character. Keep slim fitted shafts, practical rounded toes, low heels, no bulky armor or huge flared cuffs. Two separate boots side by side with generous transparent gap, each entirely visible, shafts upright, soles level, consistent scale, arranged symmetrically for cropping into individual layers. Actual transparent background. Preserve the reference's grounded foot perspective; boots will replace the shoes and cover the lower trouser legs.
