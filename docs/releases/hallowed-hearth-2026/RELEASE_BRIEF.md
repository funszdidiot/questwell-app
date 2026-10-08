# Hallowed Hearth Halloween expansion — 2026

## Founder authority

Tanya requested a Halloween collection to price and push out, then approved the five generated furnishing designs with “I love them!” on October 7, 2026 (America/Chicago). The Hallowed Hearth background and spider direction were approved earlier in this thread. Record these six visual approvals without treating them as a passed runtime test or approval of unquoted prices.

## Approved price list (coins)

| New item | Price | Existing profile |
|---|---:|---|
| The Hallowed Hearth | 220 | hearth_setting |
| Velvet Batwing Chair | 140 | seating |
| Moonbrew Side Table | 100 | side_table |
| Witchlight Bookcase | 160 | large_furniture |
| Moonweb Rug | 60 | floor_rug |
| Midnight Visitors Print | 60 | wall_art_side |

New subtotal: 740. No premium flag, cash payment or bundle checkout. Tanya approved these exact prices with “Yes” on October 7, 2026 at 20:49 America/Chicago. Activation still requires passing technical gates.

Read-only live catalog verification confirmed four featured existing items: Pumpkin Sprite 180, Midnight Harvest Coat 180, Harvest Apothecary Display 140, Autumn Ember Lantern 240. Preserve their IDs, prices and ownership. The existing Midnight Harvest room at 120 remains an alternative. The ten featured pieces total 1,480; all eleven items in the expanded underlying group total 1,600. A 740-coin subtotal is not a bundle product.

The verified private.task_reward_values implementation returns 5/10/18/30 coins for difficulty 1/2/3/4. Illustrative planning scenario only: three 10-coin quests each day yield 30/day, so 740 takes approximately 25 days before other earnings or spending. No claim about actual player completion rates or balances.

## Approved availability

Start when final quality checks and economic approval are complete; do not invent a guaranteed ship date. Approved new-item purchase cutoff: November 9, 2026 at 00:00 America/Chicago (2026-11-09T06:00:00Z), covering November 8. Owned items remain equippable afterward. Existing harvest items currently have null availability bounds: do not silently impose this new cutoff on them. All six additions are class-neutral cosmetics.

## Art and contract

Five new exact lossless RGBA WebP exports are tracked in art-provenance.json; the approved room asset is inherited from the spider commit. Preserve approved images and all existing avatar/wardrobe art. The six-item proposed manifest reuses collection_key midnight-harvest, preserving the current catalog grouping. No new slots or schema are proposed.

The five-item assets/jsons/hallowed_hearth_decor_2026.json fixture targets the existing account-free seasonal gallery. The room uses the dedicated Hallowed Hearth renderer route; do not pretend a generic static-sprite entry can render an animated room. Gallery fixture and existing renderer support do not establish client account capability.

## Verification

PASS: five PNG-to-WebP full RGBA pixel equality checks; measured alpha bounds and canvas metadata; six-item release manifest full validation; five-item gallery manifest full validation; git diff whitespace check. Both manifests retain runtime QA as not_run and economy as approved.

Implemented, awaiting CI: 16-bit market icons, generic family neighbor spacing, composed review, inactive catalog migration, server-authoritative cutoff and retry/ownership tests.

Pending: actual composed 320/390/430/desktop view and furniture depth; frozen-body comparison; missing-asset/error behavior; protected CI; server-authoritative catalog/purchase/equip/restore/archive behavior; lost-response retry and concurrency; final served revision. Local Flutter setup remains blocked by automatic review after metadata-endpoint access, as recorded in the prior QA file. Do not work around that access boundary.

The chair/table adjacency is now profile-aware with legacy parity tests. Preserve canonical geometry. A new bookcase does not automatically gain legacy bookshelf-top attachments; verify the backend placement contract before advertising that feature.

## Rollout

1. Complete candidate furnishing composition and generic family behavior; generate matching 16-bit catalog icons.
2. Finish same-revision review and existing Flutter/backend/client gates on a scoped PR to questwell-dev.
3. Prepare one idempotent forward catalog change, including exact approved prices and versioned assets; no history reset or replay. Honor supabase/README.md's scoped forward-deployment requirements.
4. Publish the reviewed client capability, then the approved catalog activation in the safe tested order; verify fresh and existing owners.
5. Verify delivered Market collection, purchase, placement, equip/unequip, reload, reduced-motion and post-end-date ownership behavior.

No live catalog mutation, push, PR, merge or collection deployment was performed in this phase. Rollback closes only new purchase availability with an end timestamp (keep active=true for owners) and reverts the new render revision; it must retain earned ownership and existing harvest items.

## Approval continuation

Tanya explicitly approved the 740-coin six-piece price list, availability through November 8, and permanent ownership. Continue scoped implementation, review, GitHub development publication and tested activation without reopening these decisions. No broader app-production launch is inferred.
