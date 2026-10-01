# Market equipment and 16-bit icons

Development branch only. No merge to `flutterflow`, external beta, or launch.

## Requested behavior

All 29 active `shop` catalog entries now have connected character or Hearth
renderers. Existing prices, ownership, class requirements, and earned reward
rules are unchanged. No items or coins were granted to the founder account.

Market and Inventory share distinct 32-pixel, shaded 16-bit-style icons. Existing
illustrated character assets and earned trophy artwork are preserved.

The Market adds search, Wearables / Companions / Hearth / Effects, class,
affordability and ownership filters, item try-on previews, purchase confirmation,
clear coin shortfalls, equip / unequip, and placement / move actions. Purchased
items stay in the same position so their Equip button remains easy to find.

Founder feedback on September 30 at 7:53 p.m. America/Chicago: likes the new
design; prefers the previous tagline. Restored verbatim:

> Rare finds, class gear, and questionable fashion choices.

## Equipment coverage

- Business Suit displays the original suit instead of the class coat.
- Moss-Green Cloak and Hearthguard Mantle add registered rear cloth and clasped shoulders.
- Wayfarer Satchel adds a shoulder strap, green travel bag and rolled map.
- Annotated Grimoire sits behind the gripping hand; Pathfinder Boots cover the feet.
- Victory Sparkle and Focus Tonic add distinct gold sparkles and green bubbles.
- Six companions have distinct visible sprites; ground companions sit beside the feet.
- Warding Lantern uses floor placements. Rainy Window uses its own `window`
  placement and clips rain to the existing environment's glass panes, preserving
  wooden framing and the same cover crop at every viewport size.
- Previously accepted accessories and furniture retain their original renderers.

## Validation

- `tool/verify_avatar_assets.py`: approved asset and fit checksums pass.
- `tool/qa/market_equipment_check.sql`: 105 purchase/equip/unequip cases passed
  against the connected database with five synthetic class profiles in a rolled
  back transaction. Includes precise coin deductions, repeat-purchase protection,
  class restrictions, persisted slots, wrong window spot rejection, and unchanged
  XP/levels.
- `test/market_equipment_test.dart`: icon uniqueness for all 29 entries, every
  item across three body types, and 320px enlarged-text purchase confirmation.
- Account-free `?review=market` uses the actual shop catalog snapshot with
  explicitly labeled sample coins and inventory. It never connects to an account.
- Browser review verified search, companion preview, sample purchase, coin update,
  equip state and cloak fit. Final build and screenshot results are recorded in
  `PROJECT_STATUS.md`.

Supabase advisors show no new schema security findings. The existing
[leaked-password protection notice](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection)
remains unchanged.
