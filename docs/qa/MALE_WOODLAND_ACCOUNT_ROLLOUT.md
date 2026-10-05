# Approved male Woodland account integration

Status: **DEV DEPLOYED; hosted-account/iPhone acceptance pending.**
Art: **LOCKED**, founder approval “It’s good”, 2026-10-05 America/Chicago.
No asset bytes or locked fit geometry changed.

## Verified development delivery — October 5, 2026

Tanya approved PR #22's development merge with “Yes”. The expected-head guarded
merge produced `fad777787697376a063d5b6a35d2ffc464f2567a` on `questwell-dev`.
Preview workflow `37376148332` passed quality, build and deployment; backend
workflow `37376148039` passed. Post-merge results: 390 Flutter tests, 31 Node tests,
15 prior exact-head deployment guards, eight Woodland Auth/RPC/persistence checks
before R01 and eight after, 22 task and 21 boss reward/rollback checks. The 46
inherited analyzer findings and generated placeholder-test exclusion remain.

The served version JSON returned HTTP 200 and the exact merge SHA. Delivered male
body, identity, Everyday and Woodland files match all four locked SHA-256 hashes.
The browser sample Market at `?review=market&body=male&class=scout` rendered the
approved fit, purchased for 120 sample coins (650 → 530), equipped as “In use”,
and unequipped back to “Owned” without another debit or loss of ownership.
Sample UI state is in-memory; reload persistence is established by isolated Auth
integration tests, not by this sample. No real account was modified by browser QA.

The live database migration `20261005212048` was already verified through guarded
CI and independent metadata reads: male support, exactly one matching rollout,
48 unchanged historical records and unchanged protected schema. This does not
apply R01/R02 or reconcile the incomplete migration history.

**Remaining:** signed-in hosted-account and physical iPhone/Safari acceptance.
Tanya was given equip → reload → unequip instructions; no result has been
reported. Do not mark these checks passed or infer production promotion.
Screenshot evidence: `questwell-male-woodland-deployed-1791236181537.jpg`.

## Behavior and API contract

Woodland is the existing `woodland-scout-outfit` chest cosmetic: 120 coins,
Scout-only, shop unlock, standard edition. Male joins the existing female and
neutral fits. Ownership, activation, pricing and all other catalog fields remain
unchanged except the description listing supported bodies.

| Operation | Existing API | Required behavior |
| --- | --- | --- |
| Purchase | `purchase_cosmetic(p_cosmetic_id)` | Server checks class, balance and fit; concurrent retries charge once and return `cosmetic_id`, `remaining_coins`, `already_owned`. |
| Equip | `equip_cosmetic_loadout(p_cosmetic_id,p_expected_conflict)` | Owner-only; Woodland replaces the chest item; public legacy `equip_cosmetic` remains compatible. |
| Unequip | `unequip_cosmetic(p_cosmetic_id)` | Returns to the same body's class robe; retains ownership. |
| Change body | `set_avatar_body_type(p_body_type)` | All three supported bodies retain equipped Woodland; invalid input fails. |
| Change class | `set_adventurer_archetype(p_archetype)` | Leaving Scout removes Woodland from equipment while preserving ownership. |
| Reload | Existing profile/catalog/ownership reads | Fresh Auth login restores stored body, class and equipped outfit. |

No tables, columns, public RPC signatures, response types or dependencies change.
Client type regeneration is unnecessary because the public contract is identical.
The scoped forward migration only replaces `private.cosmetic_supports_body` and
updates the Woodland description. It retains invoker security, immutability,
empty search path and the existing private execute restrictions.

## Implementation

- Shared avatar rendering uses the exact approved male Woodland v2 overlay over
  the full immutable male v3 body. Identity is restored once above the outfit.
- Market and Adventurer inventory expose the approved male fit while retaining
  catalog-driven class and ownership rules. No account-service API is replaced.
- Preview catalog and approval labels reflect the accepted fit.
- `20261005175137_male_woodland_approved_rollout.sql` was created with pinned
  Supabase CLI 2.119.0. The deployment hold below still applies.

## Verification

Local: asset manifest and dedicated Woodland verifier pass; 6,111 coverage pixels,
872 hand-clearance pixels; body, identity and Everyday unchanged. All 31 existing
Node guard/catalog/preview/account-deletion/repository tests pass. JavaScript
syntax and diff checks pass. Flutter is pinned to 3.44.6 and runs in CI.

New Flutter regressions compare shared renderer pixels to the approved review at
240×320 and 480×640, on light/dark backgrounds, with/without the belt grimoire.
They also check same-body equip/unequip/class/reload and Market/inventory actions.

The guarded backend harness first proves the observed baseline and existing task
reward hardening. It then applies only the new Woodland migration to its fresh
local stack. A complete before/after catalog comparison permits exactly one
private function-body change; other functions, ACLs, RLS, constraints and schemas
must match. Synthetic historical neutral ownership stays equipped. Real local
Auth sessions test all three fits, concurrent purchase retries, fresh-login
persistence, chest exclusivity, class/body transitions, rejection paths and RLS.
No real users, linked database, production keys or live account writes are used.

Green implementation head: `2ff805685ed4e3a2858a78624449f738c4849b1a`,
[PR #22](https://github.com/funszdidiot/questwell-app/pull/22).

- [Flutter workflow 37353366514](https://github.com/funszdidiot/questwell-app/actions/runs/37353366514),
  job `111909498719`: **SUCCESS**, all **390 Flutter tests**, 12 preview Node
  checks, asset and locked-dependency checks, analyzer gate and release web build.
  The gate retains its existing 46 analyzer warnings/infos and generated counter
  placeholder exclusion; this is not a zero-warning claim. Both pixel comparison
  tests pass, covering eight native/enlarged/background/grimoire compositions.
- [Backend workflow 37353366576](https://github.com/funszdidiot/questwell-app/actions/runs/37353366576),
  job `111909647238`: **SUCCESS**, 19 Node guards/catalog checks, 10 fixture checks,
  4 app-smoke checks, 20 task-reward regressions, 2 forced rollback checks and all
  **8 Woodland Auth/RPC/persistence checks**. SQL fit assertions and exact catalog
  comparison pass; post-migration SQL lint reports no schema errors. The isolated
  stack and all synthetic users/data were disposed.
- Initial run `37352836043` stopped on the CLI's single prepared-statement rule;
  the fixture is now one atomic `DO` block. Initial pixel captures did not await
  image decoding; explicit precaching fixes the test setup without changing the
  renderer or relaxing pixel equality. Both corrections passed the runs above.
- Historical predeployment read-only check on 2026-10-05 found male Woodland support
  `false`; Woodland remains active at 120 coins, Scout-only, standard shop edition.
  No live account or schema writes occurred.
- The separate approval record #21 is merged and its dashboard is delivered at
  `08c925141f4dcc2f24711efcde65336b6a1e7173`, preview workflow `37352574164`.
  The fetched version stamp and founder-approval dashboard text match. This is
  approval-record delivery, not delivery of the account integration in #22.

The source/rendering and isolated account contract are verified. Actual delivered
account runtime and physical-device QA remain behind the gate below.

## Remaining acceptance boundary

The scoped database and approved development client have both been deployed and
verified as recorded above. The broader G3 history hold remains. No manual replay,
reset, history repair, unrelated hosted migration or production promotion is
included. Signed-in hosted-account and physical iPhone/Safari checks remain open.

API checks: [Supabase migrations](https://supabase.com/docs/guides/deployment/database-migrations),
[database testing](https://supabase.com/docs/guides/database/testing),
[Flutter render capture](https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html).
