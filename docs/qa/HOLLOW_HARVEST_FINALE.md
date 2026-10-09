# Hollow Harvest finale and lanterns

Founder direction (2026-10-09, America/Chicago): “I like those last things let’s do them” approves lantern flicker and the pumpkin-pile defeat follow-up.

Status: QA. Independent source review passed provisionally; required CI and runtime visual verification remain pending. PR delivery evidence will record the exact deployed revision.

- Three warm light halos register to the existing arena using the same bottom-aligned cover transform. A 4.2-second loop varies intensity gently without flashing; a separate repaint boundary prevents rebuilding the board.
- On victory, the connected body fades into a low pumpkin pile amid a brief leaf swirl. The spider stays beside the pile. No detached head or moving head cutout.
- Restored completed encounters render the opaque final pile immediately. Reduced motion settles directly to the final state and stops ambient animation; inactive TickerMode stops the light loop.
- No account, backend, reward, seasonal-window or unrelated-boss changes. Existing approved idle and arena bytes remain untouched.

## Artwork provenance

Built-in image generation, using the approved idle sprite only as a style reference. New immutable candidate: `assets/images/questwell/hollow_harvest/defeated_v1.png`.

Prompt: transparent game sprite of the defeated Hollow Harvest; three orange pumpkins on crumpled plum-purple and moss-green cloak with straw and copper brooch; peaceful extinguished jack-o-lantern faces; polished 64-bit fantasy pixel-art, warm highlights and violet edges. Low centered pile, ground contact near canvas bottom. No upright body, limbs, spider, scenery, text or border. True alpha.

## Verification scope

Regression coverage: entrance remains once per encounter, victory transitions through an intermediate state, opaque pile replaces body, spider persists, completed remount does not replay, reduced motion and inactive routes stop scheduled frames. Required Flutter/backend workflows and delivered runtime visual verification gate completion.
