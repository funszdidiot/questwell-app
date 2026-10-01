# Class mastery relics

Required follow-through; Hearth placement is outside the launch-critical MVP.

Implemented on questwell-dev:
- Five 32-pixel collectible icons for mastery, inventory, and avatar badges.
- Illustrated relics on the mantel or bookcase, or matching walnut floor stands
  along the left/window-side walls. No new foreground placement.
- Bookcase placement requires a placed bookcase. Occupied spots show the item
  being replaced; saving still requires replacement confirmation.
- Old foreground placements remain visible until moved to an updated spot.
- Claim, place, move, remove, and replacement confirmation in the shared UI.
- Appearance saves invalidate Hearth data; reads wait for pending saves.

Pending activation:
- Review and apply tool/qa/class_mastery_relic_catalog_candidate.sql to an
  approved development database. It converts existing mastery rewards to room
  décor, preserving IDs, ownership, class restrictions, and collection criteria.
  It also adds a class-relic branch to the existing placement RPC: left/right
  pedestals, mantel, or a supported bookcase top. These changes must activate
  together; the current server otherwise rejects class relics on surfaces.
- Exercise the existing claim/place/move/remove RPCs with a development account.
  Confirm a locked reward cannot be placed, another user's item cannot be placed,
  a changed occupant requires fresh confirmation, and a class change unequips
  incompatible relics.
- Founder visual approval before any launch or promotion.

The account-free review uses sample ownership and local placement only.
The candidate has not been applied to the live database.
