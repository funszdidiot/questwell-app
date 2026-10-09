# Boston Terrier and Hearth Cat release

Status: QA. Release authorized; account catalog activation is not yet performed.

Tanya directed “Price them and push them” on October 9, 2026. Both cost **180
coins**, matching Mushroom Familiar and Pumpkin Sprite at rare tier. They are
non-premium standard items, available to all classes and all three body types,
without a seasonal cutoff. Existing purchase/equip APIs remain authoritative.
No inventory gifts, account balance edits, unrelated releases or production
promotion are included.

## Delivery

- PR #110: approved sprite sheets, animations, reduced motion, compact icons,
  release capability and Market samples.
- `supabase/migrations/20261009180421_household_familiars_catalog.sql`: two inactive
  rows, created through pinned Supabase CLI 2.119.0. No schema/policy/function changes.
- `docs/releases/household-familiars-2026/activate.sql`: activates exactly these
  two staged rows within the same atomic migration.
- `tool/deploy/household-familiars.mjs`: dedicated
  `deploy/household-familiars-approved` branch and
  `QUESTWELL_HOUSEHOLD_MIGRATION_TOKEN` secret. Requires exact development head,
  successful client/backend checks, matching served revision and both art hashes.
- Live metadata snapshot: 57 historical records, unchanged schema, purchase
  function and all unrelated catalog/render/profile/slot rows. Drift stops the
  deployment. No history reset, repair or root-chain replay; no automatic write
  retry. A matching existing rollout is verified read-only.

## Validation

Animation head `1d95b2236460a1108ddbf71323d7e555aaa7374e` passed complete Flutter
regressions, analyzer/format baseline, Chrome navigation, web/staging builds,
iOS unsigned compile, Android compile and isolated backend harness. The release
head requires fresh CI. Four offline deployment guard tests pass.

Disposable backend rehearsal checks precondition drift, atomic rollback,
exact pricing, authenticated purchase retry without duplicate charges, all 15
body/class combinations, equip/unequip/restoration, familiar replacement and
persistent ownership. No real account purchases are used for this test.

Delivered visual review, served revision/asset verification, remote catalog
activation and physical iPhone acceptance remain pending. CI evidence and actual
live-account acceptance must be reported separately.

## Remaining credential gate

The repository requires schema/catalog migrations through the reviewed CI path.
Earlier secrets were authorized for other releases. Obtain approval for a new
Questwell-only, 24-hour token with Database Read + Database Migrations Write,
stored as `QUESTWELL_HOUSEHOLD_MIGRATION_TOKEN`. Never paste it in chat, source,
logs or PR text. This is the only credential this new workflow accepts.

Once installed: refresh state read-only; stop/review on drift; ensure the current
`questwell-dev` revision is served and all required checks passed; create the
dedicated deployment branch at that exact revision; monitor and independently
verify the two active catalog rows plus exactly one matching migration record.
After ambiguous write failure, reconcile records/state before any retry.

Rollback after activation is a reviewed forward change that hides only these
two rows, preserving IDs, ownership and purchase history. Do not delete rows or
replay the incomplete root migration chain.

## Release-head CI evidence

`7efdfbfd1cd46f87b6ecff27b801bd461f70474a` passed Flutter run `37971800686`
(full regressions, Chrome, coverage, analyzer/format, web/staging, iOS/Android)
and backend run `37971800313`. The latter explicitly passed the household
activation/rollback/purchase/equipment rehearsal at 18:19:33 UTC. All forward
guard jobs passed. One old 44-item artwork-count expectation was updated to 46.

PR #111 landed before merge, creating only a dashboard-content conflict. Both
entries are preserved; fresh combined-revision checks are required. No pet art,
pricing, catalog SQL or account API changed during reconciliation.
