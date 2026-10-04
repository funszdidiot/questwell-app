# Male robe app rollout: historical proposal

**Superseded status:** Tanya directed the app push, then explicitly selected the non-restrictive legacy migration. PR #9's temporary four-item restriction is superseded. The combined implementation preserves availability and male v3 while enabling Everyday. Migration `20261004164110` restores legacy support after the newer decision was recovered. Current evidence: `MALE_ROBE_EVERYDAY_APP_INTEGRATION.md`. The proposal below is retained only as decision history.

Tanya reported on 2026-10-04: “The robes weren’t pushed to the app.” This is correct. The earlier DEV DEPLOYED evidence proved isolated review routes, not the normal app's shared male renderer. The latter still selected legacy class coats and anatomy. Those earlier claims do not establish app delivery.

## Prepared correction

The shared `QuestwellLayeredAdventurerArt` now selects the exact seven-layer male stack for Scout, Scholar, Alchemist, Guardian and Wanderer. Hearth, Adventurer, Market previews and other callers inherit this renderer. The full v3 foundation, identity, single Everyday v2 overlay, original foreground robe layers and versioned repaired rears remain byte-for-byte unchanged. Equip/unequip, class change and fresh widget reconstruction preserve the locked body. The grimoire remains book-only at its existing belt anchor; Pathfinder remains retired.

The proposal enables the already approved male Everyday fit, with matching client/server capability rules. Woodland remains an unaccepted candidate and keeps its existing account eligibility. No new art/template approval is implied.

## Required product decision

The older male Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle were authored for legacy anatomy. Keeping them available while migrating the default robe can switch bodies; putting them directly over v3 leaves invalid sleeve/foot coverage. Clipping or modifying v3 is prohibited. A read-only catalog check found each item active and owned by one currently male profile; none was currently equipped. No identifying account data was read into this report.

The prepared proposal temporarily marks these four **male fits** unavailable for purchase/equip while preserving ownership and every other body fit. Any concurrent stale equipped entry would return to inventory in the migration. Prices, balances, class rules and activation flags are unchanged. The proposed SQL is `tool/qa/male_robe_rollout_proposed.sql`; it has NOT been applied. This is a product behavior change and requires Tanya's authorization under her explicit stop rules.

Smallest action: approve the temporary male-only fit restriction until the four legacy garments are refitted to v3. After approval, create/apply the canonical migration, deploy this app correction and verify actual delivered screens and persistence. The alternative is to finish those four new fits first, without a temporary restriction. Neither route permits changing the locked body.

## Verification status

Asset preservation and the eight Node regressions pass locally. Full Flutter/renderer/equipment validation is being run on the proposal branch. Actual app deployment, database rollout and delivered-runtime QA are pending; do not mark this complete or DEV DEPLOYED.
