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

## Library Market and founder inventory rollout

Founder requested app availability and a free inventory copy. Library is priced
at 120 earned coins, class-neutral, and uses the existing exclusive setting slot.
Client slug resolution, thumbnail, placement choices and sample Market now include
Library with the corrected gallery. Migration 20261002203554 stages it inactive;
activation and founder grant follow successful client deployment. SQL checks passed
purchase retry safety, replacement confirmation, furniture coexistence, wrong-slot
rejection, removal and cross-account rejection. Security advisor returned no lints.

Activation completed after ac752faba50d0e340abb2f8c9638ca3a45559168 passed Flutter
Check 37061775991 and Preview 37061775825. Catalog verified active at 120 earned
coins. Founder inventory grant verified, source founder_grant, unequipped;
847-coin balance unchanged. Existing settings and furnishings were not changed.
No merge or public launch.

## Four additional settings

Founder requested Midnight Observatory and Alchemist’s Workshop plus two more
expensive animated designs. Static rooms cost 120 earned coins; Astral Sanctuary
and Emberglass Conservatory cost 300 earned coins each. No real-money billing.
Generated base art uses the original room as geometry reference, with clear wall
and floor. Converted to WebP quality 90. Animation is code-painted in side margins,
behind furniture, using one repaint-only clock per visible animated room. Motion
stops under reduced motion, TickerMode off, or inactive app lifecycle.
Catalog staged inactive until successful CI/deployment. No launch or merge.

Activated all four entries after 8f8b55c5c5f65b7c34c93fb629ebc39e9ac07f3e passed
Flutter Check 37063929090 and Preview 37063929048. Verified active prices 120/120/300/300.
SQL fixtures covered each setting purchase/retry, replacement, slot rejection,
removal and ownership isolation; rolled back. Security advisor zero lints.
Browser furnished review verified wall-art clearance and side effects; automated
motion tests verified reduced motion, hidden TickerMode, app pause and resume.
Screenshot: questwell-four-new-settings.jpg. Physical phone acceptance pending.
No inventory grants for these four were performed in this rollout.

## Stronger ambience and bookcase concept

Founder requested more noticeable effects. e381796aec73318f704a893a2367f625cdd03fa2
adds inset moving aurora ribbons, stronger crystal glow, 24 brighter side lights,
and wider firefly paths with short trails. Cycle is 9 seconds; existing repaint-only,
reduced-motion, TickerMode and lifecycle behavior retained. Flutter Check
37066114692 and Preview 37066114702 passed. Browser frames verified visible motion
with furnished rooms. Screenshot: questwell-stronger-ambience.jpg.

Front-facing walnut bookcase concept generated for founder review: straight vertical
uprights, level shelves, continuous flat plinth, transparent background. Generated
asset exec-cf99385d-261d-4e72-b31b-5198ba597e8b.png. Not yet substituted in app;
floor and trophy anchors must be fitted to the approved candidate before replacement.

## Front-facing bookcase replacement

Founder approved replacement. New asset walnut_bookshelf_front_v1.webp retains
the 1225x1284 canvas, with a level continuous plinth at source y=1200. Placement
anchors that opaque baseline to the room floor. Single horizontal contact shadow
replaces angled foot shadows; trophy and relic surfaces move to y=.078 of canvas.
Ownership and walnut-bookshelf item identity remain unchanged.
