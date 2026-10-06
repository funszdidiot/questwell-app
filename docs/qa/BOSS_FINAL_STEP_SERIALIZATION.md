# Boss final-step serialization — C04 / QW-06

Base: development `fd42f26bbcf1b9e7cd3a2e4d53d2130583272f1b`.
Scope: one boss's different final steps completed concurrently. C03 creation
idempotency is being handled separately in PR #32.

## Characterization before implementation

PR #33 first adds an acceptance test against the unchanged completion RPC.
Two real authenticated REST requests invoke a disposable-only wrapper. The
wrapper calls the public completion RPC unchanged, then retains its transaction
for three seconds. The first request's return is observed before starting the
second. Advisory markers show both RPCs returned before either transaction
committed. This controls the interleaving without replacing the implementation
being tested or changing its reads, row locks or reward logic.

The assertion requires both steps completed, a completed battle, and exactly
one 25 XP / 50 coin ledger entry and balance increment. The first run failed in
fixture setup (multiple statements were not accepted by the CLI query path).
After packaging the fixture as one statement and incorporating merged C03,
head `30d18baff194da5b64e1af64e06da6fbfcb76e4d`, backend run `37405874071` /
job `112083207060` reproduced the application defect: both steps committed,
but the battle was still `open`, failing the required completed assertion.
The wrapper and activity probe exist only in the disposable test database;
they are not deployment migrations. Probe access is service-role only.

## Minimal fix and regression scope

CLI 2.119.0 generated `20261006025302_serialize_boss_final_steps.sql` after the
failed characterization. It reads the owned step's parent identity, locks that
owned battle, then re-reads/locks the step before updating and counting. All
completions of one battle now take parent-before-child locks. The existing
completion/reward/balance transaction, public signature and ACL are preserved;
the private function's search path is empty with qualified application objects.

Each harness run first proves the old stranded-battle behavior and rejected
retries, then applies the proposal. The 2-, 5- and 20-step cases observe the
second final-step request waiting on a lock while the first RPC has returned
but not committed. They require all steps complete, one victory, one payout,
unchanged balance on retries and no deadlock. Existing boss authorization,
same-step concurrency, different-battle balance updates, historical rewards
and two injected rollback failures run again after the fix. A full catalog
comparison permits only this private function's definition to change. Fixtures
are dropped before final lint/advisor checks. Final verification pending.

Rollback must forward-fix or pause completion if a regression occurs; restoring
the proven race is not a safe rollback. This proposal does not retrospectively
complete or award any already-stranded battle. Any such repair needs a reviewed
inventory, exact intended outcomes and separate approval.

## Rollout boundaries

Development source and isolated testing are authorized. Hosted migrations,
existing stranded-battle reconciliation, production promotion and new product
rules remain separate. No reward values, art, ownership, level gates or client
API signatures change under this concern. A green fixture test is not hosted
rollout evidence.

Reference checked October 6, 2026: PostgreSQL explicit locking documentation
describes row-lock lifetime and the need for consistent lock order:
https://www.postgresql.org/docs/current/explicit-locking.html . Supabase database
function/security guidance and changelog were checked; no new SDK, package or
provider API is introduced: https://supabase.com/docs/guides/database/functions
and https://supabase.com/changelog .
