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
text scale. Flutter Check 37011934083 and Preview 37011934049 passed for code 59bcab9.
Browser review confirmed the new rug and restoration, plus sample Market purchase
(650 to 630 coins), ownership and floor placement preview. The live catalog is active.

Remote migration history records 20261002131724_emerald_wayfarer_rug; the identical
CLI-created source file is 20261002130617_emerald_wayfarer_rug.sql. Security advisor
reported only the pre-existing leaked-password-protection warning.

Activation after green checks:

```sql
update public.cosmetics set active=true
where slug='emerald-wayfarer-rug' and price=20
  and category='room' and unlock_method='shop';
```

## Founder phone purchase check — 2026-10-02, 08:24 America/Chicago

Founder reported: the app required a refresh to purchase; an attempt with the
connection off showed an error; after reconnecting, retrying charged her once.
Observed phone offline/retry acceptance passed. Refresh timing and cause are not
established. Do not infer that the first request reached the server or lost its
response after commit. Controlled-fault checks cover that distinct technical case.
At 08:28, founder clarified she was on the purchase confirmation screen.
At 08:29, after being asked to place the rug and refresh, founder confirmed:
"It stays in place." Purchase-and-placement functional acceptance is complete.
This confirmation does not constitute separate blanket art approval. No merge, external beta or launch is authorized.
