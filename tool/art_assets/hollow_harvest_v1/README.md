# The Hollow Harvest — art handoff

## Arena artwork

`arena_composition_v1.png` shows the boss and spider in the Moonlit Harvest
Clearing. `arena_background_v1.png` is the separate empty environment plate.
Both were created with built-in image generation on October 8, 2026 (Chicago).
These are art candidates, not a deployed encounter or animated runtime.

Composition prompt: wide crisp pixel-art moonlit autumn clearing, open player
staging area at foreground left, approved boss and spider at right, low fences,
glowing pumpkins and lanterns, violet moon, distant forest/manor, no HUD or text.
Background edit prompt: remove only boss, spider, their shadows and immediate
floating leaves; reconstruct the clearing and preserve camera, environment,
palette and aspect ratio for independent runtime character layering.

Status: BUILDING. Local shared encounter implementation and account-free preview
at `?review=hollow-harvest` exist. Not deployed; no seasonal boss creation or
reward changes applied.

The 3.2-second entrance reveals the connected body from roots upward with a falling head through
complementary silhouette masks, with swirling leaves and a sliding spider. Reduced motion uses
a 250ms fade of the assembled figure. Existing encounter persistence suppresses
replay after attacks and remounts. Runtime PNG copies live under
`assets/images/questwell/hollow_harvest/`. `runtime_390.png` records the final
assembled shared-renderer view with the existing avatar at 390px width.

Validation: 13 tests passed across hollow_harvest_entrance_test.dart and
boss_entrance_test.dart. Scoped analyzer found only the pre-existing TickerMode.of
deprecation. Local visual inspection confirms intact final silhouette, separate
avatar and boss, and correctly grounded arena placement. Independent review found and corrected rectangular-mask fragments and the
preview OS motion override. CI and delivered verification remain pending.

Tanya approved the concept on October 8, 2026 (America/Chicago), then requested
implementation. `approved_concept.png` preserves that exact approved reference.
`idle_source_v1.png` is the first transparent character-and-spider extraction,
generated with the built-in image generation tool. It is not an animation sheet
or a tested runtime sprite. The derivative is not a new founder lock.

Preserve the pumpkin grin and curved stalk, purple/green ragged cloak, copper
brooch, rope belt, straw cuffs, wooden hands/root feet, and purple spider.

Generation prompt: create a transparent full-body idle sprite from the approved
concept; preserve character identity and open-armed pose, retain a separate spider
at lower left, remove scenery/ground/particles/shadows/text, use crisp detailed
RPG pixel clusters, and keep the entire silhouette inside the canvas.

Remaining: independent sprite/scale and transparency QA; separate motion assets;
entrance, idle, hit and pumpkin-pile defeat animation; runtime and seasonal
creation gating with existing encounters still playable after close; regression
tests and reviewed development deployment. Keep the existing 25 XP / 50 coin
once-per-victory rule. Proposed event cutoff matches the collection at
2026-11-09T06:00:00Z. No unrelated boss unlock or economy changes.
