# R01: task reward authority

Approved scope: source and synthetic disposable-CI tests only. No live migration,
authentication configuration, balances, artwork, pricing or release change.
Base: ae72f23b0386420e28282021133378f17385d546, preserving concurrent avatar work.

## Contract before implementation

- Existing REST create/edit requests and `complete_task(p_task_id uuid)` response
  shape remain compatible. No new public schema or client API is introduced.
- Server computes rewards from difficulty: 1 = 10 XP/5 coins, 2 = 20/10,
  3 = 35/18, 4 = 60/30. Caller reward amounts are ignored.
- Only open quests complete. Completion locks the owned quest and updates its
  state, reward ledger and account balance in one transaction. Duplicate calls
  retain the existing error contract and never pay again.
- Clients may create open quests and edit open/set-aside quests. Open ↔ set_aside
  remains supported; clients cannot mark completed, reopen paid quests or forge
  completion timestamps. Chronicle repeats remain new IDs with no initial reward.
- Clients cannot supply or change a quest ID or owner after creation. Deletion
  remains available; deleting a paid quest does not authorize reusing its ID.
- Existing historical balances and reward records are not rewritten. Completion
  recomputes rewards even for older open rows with forged reward columns.
- Invalid/missing difficulty fails safely; existing invalid legacy rows must be
  edited to a valid difficulty before completion. Inventory those rows before any
  separately approved live rollout; no speculative repair is performed here.

## Planned files and verification

`tool/backend_ci/task-rewards.mjs`, `tool/backend_ci/run.mjs`, the baseline smoke
fixture (explicit valid difficulty), one CLI-created `supabase/migrations/` file,
and this evidence note. The observed baseline remains unchanged.

First run the hostile requests against the captured baseline and record failures.
Then apply only the new migration to that disposable database and run the same
HTTP cases, plus SQL privilege checks and forced downstream rollback cases.
CI must also run existing Flutter/Node/asset checks and the web build.

Merge needs Tanya's separate approval. Existing preview deployment may run after
merge, but it does not apply this migration to a hosted database. Production
migration reconciliation and exact sensitive rollout remain blocked separately.

Rollback: stop affected writes or forward-fix. Do not restore exploitable grants
as a purported safe rollback. This change cannot retroactively repair abuse.

## Evidence

Implementation and runtime verification pending. No P0 closure or release claim.

Official references checked October 5, 2026: Supabase database functions, RLS,
triggers and column privileges; PostgreSQL 17 GRANT and explicit row locking.
Supabase CLI 2.119.0 is the existing checksum-pinned CI version.
