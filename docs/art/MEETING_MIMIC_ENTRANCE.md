# Meeting Mimic entrance

Built-in image generation; approved Hydra visual direction, second boss. Sprite: `assets/images/questwell_meeting_mimic_v1.webp`. Transparent source resized to 640 px with alpha preserved.

## Prompt

Use case: stylized-concept. Production game enemy sprite for Questwell, detailed 64-bit retro fantasy painterly pixel-era RPG aesthetic, cozy dark academia. Exactly one MEETING MIMIC: an antique burgundy leather high-backed conference chair transformed into a mischievous monster. The seat and back hinge form a wide toothy mouth, expressive small amber eyes in the carved wooden crest, brass nailhead trim, stout carved claw feet, two curved wooden armrests as grasping arms. A blank parchment agenda and small brass bell caught at the mouth. Strong readable silhouette, charmingly menacing rather than horror, no gore. Full body three-quarter view facing LEFT toward player. Rich warm mahogany, oxblood leather, aged gold details, crisp shaded game-sprite texture consistent with a richly illustrated fantasy RPG. No human, no other creature, no text, no UI, no backdrop, no ground plane. Generous clear margin around complete chair and feet, square composition. Genuinely transparent background.

## Integration

Shared encounter renderer now selects Hydra or Meeting Mimic art/name/taunt. Mimic has a higher hop and brief wooden-chair wobble on landing. Existing skip, once-per-encounter persistence, reduced motion and ticker lifecycle retained. Real task/reward logic unchanged. Review `?review=boss&boss=meeting_mimic` offers sample attacks, replay and both boss selectors. Male Wanderer cuff polish remains deferred.
