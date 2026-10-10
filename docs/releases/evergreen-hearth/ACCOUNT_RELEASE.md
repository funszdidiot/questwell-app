# Evergreen Hearth account release — proposal

Status: catalog candidate prepared; pricing and activation await Tanya's decision.
No live catalog, inventory, balances, ownership or eligibility have been changed.

## Proposed release

| Item | Coins | Eligibility | Placement |
| --- | ---: | --- | --- |
| Hearthwoven Macramé | 120 | All classes and bodies | Any of the three wall slots |
| Woodland Path Tapestry | 120 | All classes and bodies | Any of the three wall slots |
| Guardian’s Oath Tapestry | 120 | Guardians, all bodies | Any of the three wall slots |
| Mad Alchemist’s Lab | 300 | All classes and bodies | Hearth setting |
| Guardian’s Keep | 300 | All classes and bodies | Hearth setting |

All five are permanent standard shop items, bought with earned coins, with no
premium requirement, purchase deadline, expiration or automatic inventory grant.
The gallery arrangement uses independently owned items in existing wall slots;
the companion Fern and Celestial Study frames are not bundled into these prices.

Read-only live catalog inspection on October 10 found the existing standard wall
art at 120 coins and Astral Sanctuary/Emberglass Conservatory at 300. These proposed
prices reuse those tiers; Guardian-only artwork carries no additional price.
The five candidate slugs and `wall_textile` profile were absent from the live DB.

## Prepared implementation

`catalog-candidate.sql` adds one wall-art profile, its three slot mappings, five
inactive cosmetics and three generic render registrations. It is deliberately
outside the migration chain and has no live deployment workflow. It does not
replace functions, policies, existing catalog records, ownership or history.
Room art uses the already delivered setting renderer. All approved images remain
unchanged. Account client capability remains gated until the reviewed rollout.

`tool/backend_ci/evergreen-forward.mjs` rehearses the candidate only in the
existing guarded disposable GitHub database and rolls the transaction back.
The SQL scenarios cover inactive-item purchase rejection, exact proposed prices,
one charge across retries, Guardian purchase/placement/save restrictions, all
three wall slots, floor rejection, room switching and saved gallery recall,
ownership retention, cross-user ownership rejection and complete rollback.
CI outcome is recorded in the draft PR; source preparation alone is not a pass.

## Remaining release sequence

1. Obtain the explicit price and Market activation decision for the table above.
2. Promote the exact reviewed candidate to a scoped forward migration with fresh
   live schema/catalog/history guards. Preserve the root-history hold.
3. Finish account client capability and Market/Inventory icon routing, and verify
   the catalog-driven purchase/equip/unequip/save flow in development.
4. Deploy and verify the client and scoped catalog activation in their reviewed
   order. Check actual signed-in persistence and class behavior before claiming
   account delivery. No `flutterflow` promotion or free inventory grants implied.

## Delivered visual review

PR #139 merged as `c97bd48c9caaf3ba4d598ca96523ca9f7ceebf17`.
Preview run `38067855821` succeeded. The served revision and all five asset hashes
were verified, with live standard/macramé and Guardian/Guardian's Oath galleries
checked at phone and desktop sizes. Final PR CI included 1,112 Flutter tests,
27 decorator tests, 438 Chrome tests and the backend harness; all required checks
passed. Review URL: https://funszdidiot.github.io/questwell-app/?review=evergreen-hearth
