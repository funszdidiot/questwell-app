# Questwell Visual Bible

## Art direction

Questwell is a cozy fantasy productivity game with a high-detail 64-bit-era RPG sensibility. Art should feel intentionally pixel-authored, warm, tactile and game-like rather than generically AI-rendered.

**Founder-locked visual rule — 64-bit vision:** Questwell must remain visibly rooted in a 64-bit-era cozy fantasy RPG aesthetic across avatars, Hearth décor, Market art, seasonal releases, limited releases, bosses and secondary screens. Polish means richer pixel-authored material depth, selective shading, controlled glow, tactile texture, stronger silhouettes and cleaner sprite craftsmanship—not photorealism, painterly concept-art rendering, smooth vector illustration or modern 3D realism. High-detail assets may use higher-resolution source art, but the final runtime presentation must still read as cohesive retro game art at app scale.

Typography and UI must remain consistent with the established Questwell system. Avoid visual drift between Hearth, Adventurer, Market, Boss Battles, Chronicle and secondary modes.

## Avatar architecture

Three selectable foundations exist: female, male and gender neutral. They are paper dolls.

A locked foundation includes anatomy, proportions, pose, face, hair, neck, shoulders, hands, hips, legs, feet, canvas registration and identity foreground. Clothing must conform to it.

Rules:
- Never change a locked body to make clothing fit.
- Never use generic scaling to adapt a garment between bodies.
- Fit each body independently on the shared 240 x 320 canvas.
- Preserve bottom-center alignment and authored registration.
- Prefer coherent garment overlays rather than independently stretching garment fragments.
- Preserve the original hands unless an approved equipment methodology explicitly requires otherwise.
- Preserve the same locked body/identity across equip, unequip, class change and reload. Switching between differently shaped bodies is a violation even if each file hash is unchanged.
- Keep fixed-body development reviews distinct from account wardrobe capability. A candidate renderer or isolated approved garment is not proof that every account transition preserves anatomy.
- Equipment must respect the paper-doll method. The grimoire is belt-mounted; Pathfinder boots are retired.

## Garment depth

Robes use authored depth:
1. rear garment
2. locked body
3. everyday underlayer where required
4. front garment
5. identity/head-hair foreground
6. collar
7. cuff foreground
8. compatible equipment/accessories

The back panel must read as continuous fabric behind the avatar. Front panels must hang naturally. Cuffs wrap around wrists rather than float, detach, cover hands, or flare unnaturally.

## Locked robe principle

Once a body-specific robe geometry is founder-approved, class robes for that body preserve the silhouette, alpha geometry, openings, seams, cuffs, collar behavior, rear panel and hand clearance. Class differentiation comes from approved colors, textures, embroidery, trim and motifs—not arbitrary refitting.

## Class identities

- Scholar: intellectual/arcane; navy/plum-violet family with gold; linked-diamond language.
- Scout: rustic woodland; forest/moss green, brown trim, flax/fern stitching; no breast pockets.
- Alchemist: science/chemistry; sapphire/royal blue, silver, restrained neon yellow-green chemistry accents; no literal beaker on the robe.
- Guardian: burgundy/red with gold; shield/chevron language.
- Wanderer: tobacco brown, copper-gold and muted ochre; compass/star language.

## Review standard

Judge actual runtime assets, not concept art alone. Inspect full figure and close detail at native/app scale, including shoulders, neck, wrists, hands, waist, hips, crotch/inseam, legs, heels/soles, seams, transparency, rear/front overlap and equipment intersections. Also inspect portrait/card/mobile contexts.

A build/test pass proves technical health; it does not constitute visual approval.
