# Woodland Cottage and Midnight Harvest

Concepts approved by Tanya October 2, 2026. Implemented as development preview
settings with the existing Hearth renderer. Original Hearth remains the default.
No catalog rows, prices, ownership, profile selections or saved placements changed.

Review: `?review=hearth-settings`. Compare all three backgrounds, every class/body,
furnished/empty layouts and swapped shelf/fern sides. Static art introduces no new
animation or timer. Rendering uses existing crop, avatar, rug, wall-art and furniture
anchors. Widget regression checks cover unchanged avatar/wall-art bounds at 320
and 390 px for all three body variants. Visual review is still required for contrast
and architectural alignment; equal layout bounds alone do not prove visual fit.

Images were generated using the built-in image tool and converted to WebP at
original dimensions, quality 90. Original generated PNGs remain available.
Woodland prompt: preserve the existing front-facing room composition and empty
center/floor; use moss plaster, oak beams, climbing ivy, rounded forest window and
warm firelight in richly shaded retro pixel art.
Harvest prompt: preserve the cottage geometry; replace ivy with copper/burgundy
foliage, add midnight autumn forest and crescent moon outside, amber firelight.

This is a review surface, not a purchase/equip feature. Market availability,
pricing and persistent selection await the separate rollout decision. No merge
or launch approval is inferred from art approval.

## Verification — October 2, 2026

Code 703ba3f746c46dd46c7118e412eb0df38e84259d passed Flutter Check 37055011368 and Preview 37055011402. Live browser inspection verified both new assets with furnished female and male Wanderers, three wall paintings, rug, bookshelf, chair/table and trophy; swapped shelf/fern sides also rendered correctly. Widget checks verified asset loading and unchanged avatar/wall-art bounds across three bodies at 320/390 widths. This is browser/automated evidence, not new physical Android/iPhone acceptance. Screenshot: questwell-hearth-settings-preview.jpg. Preview URL: https://funszdidiot.github.io/questwell-app/?review=hearth-settings&rev=703ba3f
