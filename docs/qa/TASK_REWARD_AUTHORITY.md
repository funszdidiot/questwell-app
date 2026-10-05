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

Baseline RED: head `369309b93325262b9d333add850b9ed61284d51e`, backend run
`37344553355`, job `111879734464`, failed for the six intended security cases:
forged insert rewards, forged edit rewards, invalid difficulty, forged completion,
reopening completed history, and deletion/ID reuse. Ten legitimate behavior cases
passed. The captured catalog matched first; all 10 fixture and 4 application smoke
checks passed. Raw test summary: `Task rewards: 10 passed; 6 failed (regressions).`
The disposable stack and synthetic data were removed successfully.

Implementation now proposes the migration created with verified CLI 2.119.0:
`supabase/migrations/20261005165421_task_reward_authority.sql`. It adds one pure
private reward mapping, an invoker write guard, narrow client column grants,
a ledger lookup index and the existing completion function's replacement.
An existing paid ledger entry also blocks a row reopened before hardening.
No client/API type shape changes or additional package dependencies are needed.

GREEN verification is pending. Added post-fix coverage also includes privileged
synthetic legacy-row seeding, SQL privilege assertions, and injected ledger and
balance failures to verify transactional rollback. No P0 closure or release claim.

First fix run `37345250356` stopped before applying the migration because CLI
`db query --file` rejects multiple prepared statements. The runner now copies
only this exact proposal beside the verified baseline and uses the installed,
help-verified `migration up --local`. It does not copy the root migration chain.
The follow-up also inventories security advisors using verified CLI flags.

Official references checked October 5, 2026: Supabase database functions, RLS,
triggers and column privileges; PostgreSQL 17 GRANT and explicit row locking.
Supabase CLI 2.119.0 is the existing checksum-pinned CI version.
