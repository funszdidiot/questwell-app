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

## Market integration — October 2, 2026

Founder requested both approved settings for purchase. Price: 120 earnable coins
apiece, matching existing Hearth decor. Both are class-neutral room items using a
new `setting` placement slot. Preview and actual Hearth resolve the background
from equipped inventory, preserving furniture/window/floor/wall slots. Removing
the setting returns to Original Hearth while retaining ownership. Generic room
placement provides existing replacement confirmation and stale-slot protection.

Migration 20261002195043_hearth_settings_market.sql was CLI-generated and applied
through execute_sql, retaining authenticated private-RPC grants and profile locking.
Catalog rows are staged inactive until the client passes and deploys. SQL QA passed
purchase/retry, one debit per item, mutually exclusive setting placement, furniture
coexistence, removal/re-equip and cross-account/wrong-slot rejection. Fixtures rolled
back. Widget regression covers inventory-derived background and default restoration.

Activation completed after code cdea5d53dfaeaa9b8e3c496c5f4a76ca5821de47 passed Flutter Check 37057394061 and Preview 37057393992. Both catalog entries are active at 120 coins. Activation SQL: `update public.cosmetics set active=true where slug in ('woodland-cottage','midnight-harvest') and category='room' and price=120 and unlock_method='shop';` Fresh query confirmed both. Security advisor: zero lints. Browser sample Market verified Midnight Harvest purchase (650 to 530), setting preview and placed state, plus Woodland Cottage listing/thumbnail. Existing real accounts were not charged or equipped by the agent. Persistence was checked through database placement state and inventory-driven widget rendering; founder phone refresh acceptance remains to be observed. Screenshot: questwell-settings-market.jpg. No merge or launch.

## Enchanted Library — October 2, 2026

Founder approved the concept (“Love it”). Added the image to the shared renderer
and put it first in the account-free settings review. Existing bounds regression
iterates every enum setting, including Library, across three bodies and two phone
widths. Library remains preview-only, with no catalog entry or inventory grant.

Built-in image-generation prompt preserved the original room perspective, left
fireplace, right window and clear floor. New architecture uses emerald central
paneling, walnut built-in shelves, brass lamps and restrained gold star inlays.
Generated PNG was converted to WebP at original dimensions and quality 90.

Verification: code b2d376b683db5c5b8f02048e2f20e349f4e55913 passed Flutter Check
37059275941 and Preview 37059275886. Live browser inspection confirmed the Library
with furnished female Wanderer, three wall paintings, rug, chair/table, bookshelf
and trophy. Avatar and wall art remain readable against the emerald center; side
shelves and lamps fit the existing crop. Screenshot: questwell-enchanted-library-preview.jpg.
Review: https://funszdidiot.github.io/questwell-app/?review=hearth-settings&rev=b2d376b
This is browser and automated verification, not physical-device acceptance.
Library remains preview-only; no catalog, purchase, inventory or launch changes.

## Library gallery correction

Founder reported awkward painting placement. Library now uses a smaller symmetric
gallery centered inside its emerald arch. The anchors follow the background cover
crop, preserving clearance from built-in shelves, brass lamps and arch trim.
Other settings retain their existing gallery layout.
