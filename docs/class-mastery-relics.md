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

2026-10-01 bookcase and placement follow-through:
- Removing or replacing the last placed bookcase returns both milestone collectibles
  and all five class relics from its top to inventory. Ownership is retained.
- Moving the bookcase between supported floor slots keeps its collectible displayed.
- Applied `return_all_unsupported_hearth_collectibles`; retained SQL is
  `tool/qa/bookcase_collectible_support.sql`. Post-apply audit found no unsupported displays.
- Save placement and Cancel stay outside the scrolling placement content.
- Regression coverage includes all five preview relics and a 390×600 phone with 160% text.
