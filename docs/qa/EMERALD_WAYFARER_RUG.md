# Emerald Wayfarer Rug

Requested by Tanya in the October 2 continuation. Development-only; no merge,
external beta or launch authorized.

- 20 earned coins, common Hearth cosmetic, available to every class.
- Deep green woven fabric, gold border, compass rose and corner diamonds.
- Extends the existing code-drawn rug with the same perspective and footprint.
- Dedicated `floor` slot under the avatar, shadows and furniture. Other room
  objects keep their slots. Returning the rug to inventory restores burgundy.
- Market/inventory share an item icon, room preview and placement picker.
- Account-free visual review: `?review=rug`; sample purchase flow: `?review=market`.

## Verification

The candidate migration and `tool/qa/emerald_rug_check.sql` passed together in a
rolled-back transaction. Synthetic accounts verified aborted-purchase rollback,
five repeated purchases yielding one 20-coin debit/event, unchanged XP/level,
persistent floor placement, coexistence with three furniture items, repeated
placement, invalid-slot rejection, removal/replacement and caller ownership.
No founder coins or inventory were changed.

The catalog migration stages the item inactive. Activate only after the supporting
development build and tests pass. Flutter tests cover 320/390 px, all three bodies,
floor footprint, original-rug restoration and a 320 px placement dialog at 160%
text scale. Build/preview results and browser review remain pending at this commit.

Founder phone acceptance still needs a real interrupted Market purchase. The
synthetic tests do not establish that a request was interrupted on her phone.
