## Left-hand orientation and Scholar cuffs — 2026-10-01

Founder review identified the v2 sprite as the opposite hand. Mirror the entire integrated book/grip at render time so the avatar's left thumb faces inward and the book rests toward the thigh. Register the mirrored source wrist at (766,17), keeping all three body wrist anchors fixed. The original art and 16-bit icon are unchanged.

Replace both flat Scholar cuff ends with body-registered curved cuffs: tapered violet fabric, curved gold trim, dark recessed lining, and a front lip over the wrist. Clip the old cuff region from every robe restoration pass. Apply cuffs above held items, omit under closed cloaks and business suits, and preserve the frozen robe/base files and integrity manifest.

# Annotated Grimoire — detailed equipped artwork

## Dedicated spine grip correction — 2026-10-01 America/Chicago

The founder rejected the v1 book sitting behind a relaxed hand. Built-in image editing created an integrated book-and-gripping-hand sprite, with the thumb on the cover and fingers around the spine. This is an equipped-item overlay; frozen avatar and class artwork files remain unchanged. A grimoire-only visibility mask removes the original relaxed hand. The class cuff restores above the replacement wrist. Unequipping or swapping to a cloak removes the grip overlay and its hand mask.

Source: `generated_images/exec-a138ee77-f972-451b-8d8f-47a17d501280.png` (1062 × 1481 RGBA). Active project asset: `assets/images/questwell_annotated_grimoire_grip_v2.webp` (resized to approximately 531 × 741, quality 92, alpha preserved). Wrist registration uses source anchor (296,17) and per-body scales/anchors. The Market/Inventory icon remains book-only.

### Grip edit prompt

Use case: precise-object-edit. Image 1 is the existing Questwell grimoire edit target; preserve this exact plum leather book, gold sun medallion, corner hardware, page block, annotation tabs and ribbon. Image 2 is a style/skin-color reference ONLY for the avatar's existing hand; do not copy its relaxed pose or pixel enlargement. Create a transparent equipped game sprite showing the same closed book actually HELD by ONE small warm-peach cartoon-fantasy hand at its upper-left SPINE edge. The wrist enters vertically from ABOVE at the left spine, with a short bare wrist whose top is horizontal for joining a downward-hanging sleeve. The thumb presses over the front cover just right of the spine; the four fingers curl naturally around the left spine and behind the book. A clear anatomically believable carrying grip, not a relaxed fist pasted over the cover, not fingertips resting on top, not holding a handle. Hand width about 40 percent of the book width, subtle dark outlines and warm golden-peach shading matching the reference avatar. The short wrist extends about 12 percent of the book height above the book top; no forearm beyond that, no sleeve, no second hand, no person. Keep the book fully visible, upright, with the upper-left cover partly occluded by the thumb and fingers as physically appropriate. Preserve the detailed 64-bit-era painted fantasy sprite look; use simple readable hand shapes at small avatar scale, not photoreal skin. Genuinely transparent background and clean alpha, no background shadows, no other objects. Leave modest transparent margins. The result must be one integrated BOOK-AND-GRIPPING-HAND sprite so the hand cannot detach or float.

## Original v1 artwork and fit (superseded)

Created 2026-09-30 America/Chicago using built-in image generation with transparent output.
Source: `generated_images/exec-a94a1e90-30b1-4afe-aa56-0be8ecc4727d.png` (1024 × 1536 RGBA).
Project asset: `assets/images/questwell_annotated_grimoire_v1.webp` (356 × 500, quality 92). Cropped with transparent padding at 984 × 1380 +32+80, then resized; alpha preserved.

Three body-specific placements and a slight outward tilt position the upper cover beneath the existing hand. Both base and class cuff layers restore over the book using the existing hand clip. The production renderer suppresses held items in stale cloak loadouts; existing Market/Inventory confirmation and atomic equipment rules apply unchanged. No new account writes or changes to price/class restriction. The matching 16-bit icon uses plum, gold, ivory, red/blue tabs and a ribbon bookmark.

Review route: `?review=grimoire`. Scholar-only, hands slot, rare, 160 coins. The fixture uses the shared renderer and cloak confirmation dialog without account writes.

## Generation prompt

Use case: stylized-concept. Asset type: ONE transparent equipped spellbook sprite for Questwell, a detailed 64-bit-era retro fantasy RPG. A compact CLOSED Annotated Grimoire, upright portrait proportions approximately 2:3, front cover facing the viewer almost straight on with a narrow view of the cream page block on the right and bottom and a sturdy spine on the left. Deep midnight plum leather, rich sculpted texture, restrained worn edges, warm aged gold corner guards, thin gold rules and a small elegant central sun-and-star medallion. Several tiny red and muted blue annotation tabs protrude from the right-side pages; a short burgundy ribbon bookmark peeks below. Uneven ivory page edges suggest a well-used scholar's field guide. Detailed hand-painted storybook RPG rendering, warmly lit from upper left, crisp clean edges, dimensional leather and brass, matching sophisticated 64-bit-style fantasy avatar equipment. The book will be carried down beside an avatar, gripped at its UPPER LEFT cover edge: keep the top left simple and unobstructed so the avatar's existing fingers can overlap it. Render ONLY the book: no hand, no person, no strap, no handle, no floating effects. Complete book and tabs entirely inside the canvas with modest transparent margins. Genuinely transparent background, no floor or background shadow, no panel or border, no legible lettering, no text, no watermark. Detailed painted sprite, not flat vector, not chunky 16-bit pixels, not a photorealistic product photograph.
