# Boss reward authority — R02 / QW-02

Scope: one source/test PR based on `08c925141f4dcc2f24711efcde65336b6a1e7173`.
All database execution uses the approved, guarded, disposable GitHub-hosted
Supabase harness with synthetic accounts. No hosted migration or data operation.

## Contract and corrected threat description

New battles use the approved server reward: **25 XP and 50 coins once on victory**.
Keep the existing public/private signatures and default arguments for old clients;
reward arguments are compatibility fields and cannot select a new battle's payout.
All eight level gates, boss types, step validation and public return fields remain.

The observed baseline's **public wrapper already caps XP at 25 and coins at 50**.
The private creator is callable by the authenticated database role and has no coin
ceiling. Public calls also allow smaller/zero rewards. The private SQL test is a
defense-in-depth boundary test, not proof of a public REST inflation exploit.
The REST suite separately checks oversized requests and rejection of the private
schema profile. The audit's broader custom-request inflation claim needs this
qualification; current live API schema exposure has not been re-audited here.

The founder-approved October 1 rule in `docs/boss-rules-activation.md` explicitly
preserves existing saved rewards. Older battles remain playable with those values;
this proposal does not rewrite existing battles, earned balances or history.
Potentially forged historical rewards therefore need a separately reviewed
inventory/reconciliation decision before live rollout. Do not silently replace
grandfathered 100-XP battles with 25-XP payouts.

The payout transaction must fail if its profile balance cannot be updated. A
failure must roll back the final step, battle status and ledger entry together.
Existing completed-step rejection and same-step serialization remain.

## Proposed implementation

CLI-created migration `20261005183917_boss_reward_authority.sql` replaces only
`private.create_boss_battle`: it overwrites compatibility reward parameters with
25/50 before insertion and uses an empty
search path with qualified application tables. It removes client table-write,
TRUNCATE and administrative privileges from boss battles/steps while retaining
authenticated SELECT and existing owner RLS. The public wrapper, completion
function, client code, signatures and dependency inputs remain unchanged.

The missing-profile test characterizes the existing foreign-key protection;
no completion-function rewrite is needed to preserve its atomic rejection.

## Verification

Corrected test-first head `b5adc25d7cfbdfd1d9b16bc2d8e04f37ce2106c7`,
[backend run 37357515942](https://github.com/funszdidiot/questwell-app/actions/runs/37357515942),
job `111923571031`, reproduced the private SQL creator storing 2,147,483,647
coins. REST reported **16 passed / 3 failed**: negative, zero and smaller caller
rewards violated the intended fixed contract. Oversized public requests were
already capped. R01's 22 reward/rollback checks passed before these failures.

The first test capture at `4c0422a`, run `37357056480`, also had two overly strict
assertions: RLS can safely return HTTP 200 with no affected rows, and the existing
missing-profile foreign-key rejection returns HTTP 409. The corrected baseline
accepts those safe outcomes and verifies persisted state. They are not product
defects and no completion-function change is needed.

The initial implementation at `47fe715` passed backend run `37358043065`
(19 boss regressions + two injected rollbacks, all R01 tests and SQL privilege
checks), Flutter/web run `37358043138`, and automatic review. SQL lint identified
two unused compatibility parameters. The follow-up explicitly overwrites those
parameters with fixed values before reading them for insertion; it does not add
a no-op parameter read or suppress lint. The final head must rerun all checks.

The fixed-schema checks run in [PR #23](https://github.com/funszdidiot/questwell-app/pull/23/checks).
Its description and the Phase 2 FIX_PLAN checkpoint record the final verified
commit and results. The required suite has 19 Auth/REST cases, the authenticated
SQL contract/privilege assertions and two injected rollback checks.
Coverage includes 2/5/20-step plans, old caller compatibility, omitted/null/large/
negative/zero/small rewards, partial progress, all eight level gates, malformed
creation, cross-owner and anonymous denial, direct REST tampering, eight concurrent
requests for the same final step, concurrent independent battles, grandfathered
rewards, and missing-profile payout failure. Two injected database-constraint
failures exercise ledger and balance rollback after the corrected schema passes.
The existing R01 task reward tests run in the same job and must remain green.

No claims of strict clean analysis, native/device testing, live-account testing,
full historical migration reconstruction, or release readiness follow from this
isolated result. The distinct different-final-step race (QW-06 / C04) remains a
separate concern; do not describe same-step retry tests as proving it fixed.

## Rollout and rollback

This migration is a source proposal only. Before hosted application, reconcile
the incomplete migration history, review exact function/grant changes and legacy
reward data, and obtain the existing G3 approval. No new environment, paid service,
client dependency, artwork or economy rebalance is included.

If deployment has a problem, pause affected writes or forward-fix. Reverting to
caller-controlled rewards is not a safe rollback. Existing completed balances
are not repaired or removed by code rollback. Release remains **NO-GO**.

## Documentation checked

- Supabase changelog, October 5, 2026: https://supabase.com/changelog.md
- Function privileges and definer search paths:
  https://supabase.com/docs/guides/database/functions
- PostgreSQL 17 function replacement and privileges:
  https://www.postgresql.org/docs/17/sql-createfunction.html
- Installed Supabase CLI **2.119.0** `migration new --help`; the harness also
  verifies all installed command help before use. No new tooling dependency.
