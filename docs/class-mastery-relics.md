# Class mastery relics

Required follow-through; Hearth placement is outside the launch-critical MVP.

Implemented on questwell-dev:
- Five matching collectible symbols for the character sheet and inventory.
- Relics on display stands using existing left, right, and foreground Hearth spots.
- Claim, place, move, remove, and replacement confirmation in the shared UI.
- Appearance saves invalidate Hearth data; reads wait for pending saves.

Pending activation:
- Review and apply tool/qa/class_mastery_relic_catalog_candidate.sql to an
  approved development database. It converts existing mastery rewards to room
  décor, preserving IDs, ownership, class restrictions, and collection criteria.
- Exercise the existing claim/place/move/remove RPCs with a development account.
  Confirm a locked reward cannot be placed, another user's item cannot be placed,
  a changed occupant requires fresh confirmation, and a class change unequips
  incompatible relics.
- Founder visual approval before any launch or promotion.

The account-free review uses sample ownership and local placement only.
The candidate has not been applied to the live database.
