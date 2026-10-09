# Autumn Hearth release

Status: QA. The approved artwork is already served; account catalog activation is pending.

Tanya approved the usual-Hearth artwork with “Love it” and authorized pricing and rollout with “Price it and push it out” on October 9, 2026 (America/Chicago). Her subsequent “Yes” approved the displayed prices and a new Questwell-only 24-hour Database Read + Migrations Write token stored in GitHub Actions.

| Item | Coins | Existing profile |
|---|---:|---|
| Amberfall Window | 120 | window_feature |
| Maple Hearth Rug | 60 | floor_rug |
| Mooncap Grove | 120 | plant |
| Harvest Lanterns | 240 | pedestal_light |
| Sage’s Rest | 120 | seating |

The collection is `autumn-hearth`, non-premium, all classes/bodies, with no imposed expiration. Exact approved candidate-named artwork is unchanged. Amberfall uses only the verified Original/Hallowed glass masks; other settings retain ownership but do not draw an unverified overlay. The Market description states supported rooms. No account grants, avatar edits, geometry changes, unrelated prices, policy/function edits or `flutterflow` promotion.

## Guarded delivery

- Manifest: `docs/releases/autumn-hearth-2026/manifest.json`.
- Data-only migration: `supabase/migrations/20261009145238_autumn_hearth_catalog.sql` (created with the Supabase CLI).
- Reviewed deployment: `tool/deploy/autumn-hearth.mjs`; dedicated `deploy/autumn-hearth-approved` branch and `QUESTWELL_AUTUMN_MIGRATION_TOKEN` secret.
- Hash-locked SQL, activation, manifest and schema-query bytes; live schema, unrelated catalog/render/profile/slot data and all 56 existing history rows are fingerprinted. Purchase function is unchanged.
- Requires matching current development SHA, successful client/backend checks, served revision and five exact hosted art hashes before a single atomic Management API migration.
- No automatic write retries. After an ambiguous response, read-only reconciliation must establish whether the exact one-record rollout applied. No root history replay/repair/reset.

## Validation

Local manifest validation and four deployment guard tests pass. Independent technical review found no blockers; 21 Node guard/security tests pass. Full Flutter checks, isolated backend purchase/placement/reload scenarios, hosted revision and post-activation verification are pending. No signed-in account purchase has been performed or claimed.

The disposable backend rehearsal checks precondition drift, rollback on failed activation, exact five-item pricing, 660-coin total debit, idempotent purchase retries, placement/unequip/re-equip, saved decorator layouts, and window replacement without losing ownership.

## Delivery record

Fill from observed successful CI/deployment and read-only backend results. A preview alone is not catalog delivery.
