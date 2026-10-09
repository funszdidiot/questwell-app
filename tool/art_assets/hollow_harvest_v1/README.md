# The Hollow Harvest — art handoff

## Arena artwork

`arena_composition_v1.png` shows the boss and spider in the Moonlit Harvest
Clearing. `arena_background_v1.png` is the separate empty environment plate.
Both were created with built-in image generation on October 8, 2026 (Chicago).
These source plates support the deployed development preview. The concept is
founder-approved; derivative artwork has no new founder lock.

Composition prompt: wide crisp pixel-art moonlit autumn clearing, open player
staging area at foreground left, approved boss and spider at right, low fences,
glowing pumpkins and lanterns, violet moon, distant forest/manor, no HUD or text.
Background edit prompt: remove only boss, spider, their shadows and immediate
floating leaves; reconstruct the clearing and preserve camera, environment,
palette and aspect ratio for independent runtime character layering.

Status: DEV DEPLOYED preview at `50591bd5` (PRs #95 and #97); the head
correction in PR #98 remains in QA until its deployment is verified. The
account-free route `?review=hollow-harvest` has three sample strikes, replay
and reduced-motion controls. No seasonal boss selection or reward changes.

The corrected 3.2-second entrance fades in the complete connected boss through
swirling leaves, then slides the spider into place. The pumpkin, neck and collar
stay attached throughout; the roots-up mask and separately falling head were
removed after Tanya reported a floating-head defect. Reduced motion uses a
250ms fade of the assembled figure. Existing encounter persistence suppresses
replay after attacks and remounts. Runtime PNG copies live under
`assets/images/questwell/hollow_harvest/`. `runtime_390.png` records the final
assembled shared-renderer view with the existing avatar at 390px width.

Validation: three Hollow Harvest regressions pass for desktop containment,
entrance persistence and reduced motion. Independent actual-Flutter captures at
phases .4 and .65 confirm continuous pumpkin-neck-collar without a gap or slice.
All required code checks passed on `0ecbd9f8`; documentation follow-up and
hosted head-correction deployment remain pending. The earlier hosted preview
was verified with complete desktop silhouette, sample attack and replay.

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

Remaining: seasonal selection/creation gating with existing encounters playable
after close, lantern flicker, and pumpkin-pile defeat animation. Current preview
uses the existing hit effect and defeated-figure fade. Preserve the existing
25 XP / 50 coin once-per-victory rule when activated. Proposed event cutoff
matches the collection at 2026-11-09T06:00:00Z. No unrelated boss unlock or
economy changes. Runtime integration does not establish a new founder art lock.
