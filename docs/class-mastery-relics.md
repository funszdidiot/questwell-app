# Class mastery relics

Required follow-through; Hearth placement is outside the launch-critical MVP.

Implemented on questwell-dev:
- Five 32-pixel collectible icons for mastery, inventory, and avatar badges.
- Illustrated relics on the mantel or bookcase, or matching walnut floor stands
  at the founder-marked back-left, back-right, and front-left floor anchors.
  Left-side pedestals are mirrored to face inward; right-side art faces left.
- Bookcase placement requires a placed bookcase. Occupied spots show the item
  being replaced; saving still requires replacement confirmation.
- Front-left placement is available using the existing front slot.
- Claim, place, move, remove, and replacement confirmation in the shared UI.
- Appearance saves invalidate Hearth data; reads wait for pending saves.

Database activation completed with explicit founder approval on 2026-10-01:
- Applied migration `activate_class_mastery_hearth_relics` to Project Momentum
  (`bdzcazkyypopbanbjnud`). The reviewed SQL is retained in
  `tool/qa/class_mastery_relic_catalog_candidate.sql`.
- All five class-mastery catalog items are active room décor.
- The placement RPC now accepts their left/right/front pedestals, mantel, and supported
  bookcase top. Other item-specific placement rules are preserved.
- Post-apply queries verified all five categories, the added server rules,
  unchanged earned-reward rows, and unchanged function permissions.
- Security advisor reported no database findings. Its only warning was the
  existing Auth leaked-password-protection setting; this change does not alter Auth.

Remaining account validation:
- Exercise claim/place/move/remove through a signed-in development account.
  Confirm class restrictions, ownership, bookcase support, and stale-occupant
  confirmation in the UI.
- Founder visual approval before launch or promotion. No branch merge performed.

The account-free review continues to use sample ownership and local placement.

2026-10-01 placement follow-up: extend the class-relic RPC whitelist to `front`,
matching the founder's marked floor plan. Existing item and surface checks remain.
