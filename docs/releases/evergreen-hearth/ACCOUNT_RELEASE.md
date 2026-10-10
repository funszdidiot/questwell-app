# Evergreen Hearth account release — approved

Tanya approved the exact prices below and permanent Market availability with
**Yes** on October 10, 2026. This authorizes the scoped account rollout and
development delivery. No free inventory grants or flutterflow promotion.
Status: **DEV DEPLOYED / catalog active**. PR #144 delivered `e9a4726` through
Preview `38073413501`; five served artwork hashes were verified. Migration
`20261010180351` activated exactly the five approved items, preserving the prior
60 migration rows and all protected schema/catalog hashes. CI passed 1,126
Flutter, 27 decorator and 440 Chrome tests, native builds and backend checks.
Signed-in manual and physical-device acceptance remain unclaimed.

On October 10 Tanya separately requested all five items in her inventory.
Five idempotent `founder_grant` ownership inserts were verified against her
previously confirmed founder account. Coin balance, profile, prior ownership
and equipped items were unchanged. Guardian eligibility remains enforced.

Her same follow-up identified the standard-room gallery as too high. The
placement correction lowers both companion frames and individual side textiles;
the center envelope moves below the beam and scales proportionally to retain
readable clearance above the avatar. The production Home/Inventory crop
(`width * .68 + 8`) gets viewport-aware fitting, with 320/390/760/960
geometry checks and 24 additional actual app-framing render exports. An
App framing control makes the same camera available in the review. Hallowed geometry and all artwork bytes
remain unchanged. This placement follow-up is in QA; PR #144 remains the
delivered catalog evidence.

## Approved release

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
art at 120 coins and Astral Sanctuary/Emberglass Conservatory at 300. These approved
prices reuse those tiers; Guardian-only artwork carries no additional price.
The five candidate slugs and `wall_textile` profile were absent from the live DB.

## Prepared implementation

The historical `catalog-candidate.sql` is superseded by
`supabase/migrations/20261010173713_evergreen_hearth_catalog.sql` and the approved
`catalog.json`. The forward payload adds one textile profile, three wall mappings,
five inactive records and three render registrations, then activates only those
five records atomically. Existing metadata, schema/functions/policies and migration
history are guarded by exact before/after hashes. No account data is written.

`tool/deploy/evergreen-contract.mjs` builds the guarded payload and verifies its
recorded source digest. `evergreen-reviewed-state.json` records the read-only live
snapshot and input hashes. Use the connected Supabase migration operation only
after the tested development client is served. Do not replay the root history,
reuse a different release token or retry an ambiguous write. Reconcile history
and postconditions before attempting recovery from any uncertain response.

The account client enables the five exact slugs, preserving server-owned class,
price, ownership and slot rules. Five dedicated 32px pixel icons use the existing
Market/Inventory painter. Market tests exercise purchase confirmation, owned-item
placement and Guardian restrictions from the approved catalog. The existing 96
room compositions and new icon exports provide visual evidence.

The guarded disposable harness tests precondition drift, omitted-activation
rollback and the exact successful payload. Its account tests cover inactive
purchase rejection, one charge across retries, actual class switching, Guardian
purchase/placement/save restrictions, all wall slots, floor rejection, saved-room
recall, ownership retention and another account's unowned-item rejection.

## Delivery checks

- Before activation: required PR checks and icon/composition review pass; merge
  to development, verify the served revision and all five exact artwork hashes.
- Read the current guarded state again. Any drift must be explained and reviewed.
- Apply only the reviewed payload as `evergreen_hearth_approved_rollout` using the
  connected migration operation. Verify one new history record, the digest, all
  exact rows and unchanged protected hashes.
- Inspect the hosted Market/Inventory and account persistence where available.
  Report any signed-in/device check separately from CI and catalog activation.
- Rollback after activation preserves ownership: deactivate only these five
  records if needed. Never delete purchased items or rewrite migration history.

## Delivered visual review

PR #139 merged as `c97bd48c9caaf3ba4d598ca96523ca9f7ceebf17`.
Preview run `38067855821` succeeded. The served revision and all five asset hashes
were verified, with live standard/macramé and Guardian/Guardian's Oath galleries
checked at phone and desktop sizes. Final PR CI included 1,112 Flutter tests,
27 decorator tests, 438 Chrome tests and the backend harness; all required checks
passed. Review URL: https://funszdidiot.github.io/questwell-app/?review=evergreen-hearth
