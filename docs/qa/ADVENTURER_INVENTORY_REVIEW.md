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
