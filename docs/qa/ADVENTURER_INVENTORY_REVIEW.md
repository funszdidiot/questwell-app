# Adventurer and Inventory review

Epic 4 development pass. Homepage and enchanted wordmark approved by founder.

- Shared Appearance/Inventory layout with approved avatar renderer.
- Body/class choices update the hero; existing save handlers and class-change confirmation retained.
- Inventory ownership filters: Owned, Equipped, All items. Category filter reflects actual catalog categories.
- Explicit ownership, class restrictions, and Market or progression unlock paths.
- Removed misleading five-slot counts and long empty-slot grid.
- Existing equipment-art gate remains disabled. Owned unequipped items explicitly say Equip unavailable; already equipped items can still be unequipped. Do not mark equipping complete until approved equipment layers are ready and account persistence is verified.
- Mastery claim conditions and sign-out retained.
- Shared sample review at `?review=adventurer`; sample interactions do not write to accounts.
- Authenticated equipment/class-change/mastery round trips not verified by the agent. Founder previously confirmed body and Campfire persistence after logout/login.
- No merge or launch.

## Typography verification

Pixel section headings confirmed for Adventurer, active class, Body style, Your class, Your collection, and Class mastery. Corrected empty-state heading to Press Start 2P. Explicit Roboto styles added to selection/filter chips, category label, and action buttons instead of inheriting platform defaults. Item/relic names remain Roboto subheaders; descriptions, numbers, and ownership labels remain Roboto. Regression checks cover headings, controls, supporting text and empty state.

## First accessory candidate — round scholar glasses

- Development fixture: `?review=equipment`; female, male and neutral selectors,
  local try-on toggle, Adventurer portrait and matching Hearth preview.
- Brass frames use body-specific face anchors on the frozen 240 × 320 canvas.
  The accessory uses the same contain/bottom-center transform as the artwork.
- Existing `round-scholar-glasses` face slug drives the layer; transparent lenses
  preserve the original eyes. No avatar or garment asset pixels were changed.
- Section headings remain Press Start 2P; controls and supporting copy use Roboto.
- Equipment remains gated in the real inventory pending visual acceptance.
  This fixture neither grants an item nor tests account persistence, ownership,
  class restrictions, or the equip/unequip RPCs. Those remain the next gate.

## Approved glasses enabled (2026-09-30 UTC)

Founder approved the glasses visual. Replaced the blanket Adventurer gate with a
shared slug + category allowlist: only `round-scholar-glasses` in `face` can be
newly equipped. Market and service use the same rule. Existing items can still
be unequipped. Both pages report save failures and refresh server state.
The catalog lists the glasses at 40 coins with no class restriction.

Verified the existing RPCs using synthetic fixtures and the authenticated role
inside a rolled-back transaction: equip/unequip, ownership rejection, class
restriction rejection, universal glasses surviving class changes, cross-account
read/unequip isolation, and saved state after switching test identities. Script:
`tool/qa/equipment_rpc_check.sql`. No schema or persistent account data changed.
This is database verification, not an actual sign-out/sign-in browser test.

Widget regression scenarios cover owned/unowned glasses, class locks, busy
saves, and removal of equipped items. The Adventurer sample preview now allows
local Equip/Unequip. Real phone sign-out/sign-in persistence is still pending.

## Tiny Wizard Hat candidate

Founder confirmed glasses persistence after sign-out/sign-in. Next candidate is
existing universal `tiny-wizard-hat` in the head slot. Added a midnight-purple,
gold-trimmed crown layer with a bent tip and separate body anchors. Existing
avatar and robe assets remain untouched. `?review=headwear` offers all three
bodies, independent hat/glasses toggles, and matching portrait/Hearth views.
The hat remains excluded from the approved equipment allowlist until reviewed.

## Illustrated hat replacement (founder approved)

Rejected flat vector hat replaced with a transparent illustrated PNG extracted
from the approved male concept using built-in image generation. Prompt preserved
the purple felt, gold band/star, curved brim and bent point, removing the character
and background. Original approved avatar/robe pixels remain untouched.
Body-specific bounds align the transparent brim opening with the hair; portrait
framing reserves headroom for the point. Hat enabled alongside glasses in the
shared equipment policy. Other unfinished items remain unavailable to equip.
Asset: `assets/images/questwell/avatar/wizard_hat_illustrated_v2.png`.

## Emerald Scholar Scarf integration

Founder approved the illustrated emerald/gold open-drape concept. Built-in image
generation extracted a transparent scarf sprite; no avatar or garment pixels
changed. Body-specific scarf bounds and an opening mask preserve the shirt collar.
Browsed all 15 fits (five classes × three bodies) in `?review=scarf-matrix`.
Individual try-on, class/body selectors and Hearth view: `?review=scarf`.
Added the exact scarf slug + neck category to the shared equipment allowlist and
to the ownership/class/busy/unequip widget scenarios. Hat persistence was confirmed
by the founder. Scarf phone sign-out/sign-in confirmation remains pending.

## Scarf acceptance and persistence confirmed

Founder approved the female correction at `29107d8` and confirmed the scarf stays
equipped after sign-out/sign-in (2026-09-29 America/Chicago). Scarf fit and founder
persistence checks are complete.

## Leather satchel candidate

Art standard reaffirmed by the founder: all accessories must match the approved
64-bit retro fantasy game aesthetic, evaluated at actual avatar and Hearth scale.
The generated source image alone is not visual acceptance.

- Illustrated cognac-leather bag, brass hardware, stitching and rolled parchment.
  Generated with the built-in image tool using the previous satchel and frozen
  female base as style references; transparent PNG preserved unchanged.
- Body-specific shoulder strap and hip anchors; original forearm/hand layers sit
  above the bag. Scarf stays above the strap. Original avatar and robe assets unchanged.
- Review: `?review=satchel`; all five classes and three bodies: `?review=satchel-matrix`.
- Review-only slug; neither actual satchel slug is enabled in the equipment policy.
  No grants, purchases, account writes, merge or launch.
- Next gate: founder visual approval, then ownership/equip/persistence validation.
- Generation brief: standalone front-view cognac leather satchel bag only, no long
  strap, rich illustrated fantasy RPG style, one brass buckle, tan stitching, small
  rolled parchment and upper attachment rings; clean transparent background.

Delivery checkpoint: founder explicitly authorized uploading the satchel artwork
and code to funszdidiot/questwell-app on questwell-dev for preview only.
Visual acceptance, equipment enablement, merge and launch remain gated.

### Satchel fit revision 2

Founder found the first in-game candidate odd. Increased and moved the bag inward
and down so its main flap stays visible beside the forearm; narrowed and darkened
the shoulder strap, reduced its buckle and anchored it to the bag's outer ring.
The illustrated asset, approved robes and accessories are unchanged. This remains
a review-only candidate, with equipment, merge and launch gated.

### Satchel strap attachment correction

Founder flagged the strap connection in revision 2. Reattached the front strap to
the inner (viewer-right) brass eyelet at source pixel (1064, 230), behind the bag
artwork. Both the image and strap now share the same body-specific bag bounds and
contain/center transform, including transparent image margins. The strap follows
a direct curve from shoulder to this ring; bag placement and other gear are unchanged.
Still preview-only, pending founder visual approval.

### Satchel material finishing pass

Founder requested the proposed subtle contact shadow and softer strap highlight.
Added a low-opacity shadow derived from the bag's alpha silhouette, offset 1.1px
right / 1.3px down with 0.65px blur on the 240 x 320 canvas. Softened the strap's
center highlight to a finer translucent brown line. Bag bounds, ring attachment,
source art and equipment gates remain unchanged. Preview review remains pending.
