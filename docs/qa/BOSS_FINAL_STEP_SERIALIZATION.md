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
one 25 XP / 50 coin ledger entry and balance increment. Test result pending.
The wrapper and activity probe exist only in the disposable test database;
they are not deployment migrations. Probe access is service-role only.

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
