# C11b — Chronicle server totals (prepared, not live)

Chronicle currently loads every history page but folds totals in the client. Reads
across several tables may observe different moments. This proposal adds
`public.chronicle_totals(timestamptz)`: one stable, invoker-rights aggregate over
owner-filtered completed quests and bosses. Existing RLS and all table grants stay
unchanged. Only authenticated callers receive execution permission. It cannot
write rewards, balances, history or account data.

The week argument is the client's local Monday midnight converted to an absolute
timestamp. Comparison is inclusive, with no upper bound, matching the current UI.
Null/infinite boundaries and null/infinite completed timestamps fail explicitly.
XP and coins preserve saved historical values, with null rewards treated as zero.
Counts and sums are decimal strings to avoid browser JSON precision loss. The
response includes owner ID and the effective week boundary for future client
validation. These are retained-history totals, not wallet balances: deleting a
completed history row removes it from this aggregate, as it does today.

PostgreSQL STABLE functions use the calling query's snapshot; both tables and
all totals are selected together. This does not promise that independently paged
history has the same snapshot. No client calls this endpoint in this proposal.
Client integration and activation follow verified backend deployment.

## Evidence required before approval

- Isolated backend harness applies this migration **after** the pinned seven-change
  hardening rehearsal; its original before/after hashes remain unchanged.
- Catalog comparison permits only the new function, its execution grants, and
  two partial completed-history indexes keyed by owner. SQL checks verify index
  validity, predicates and query usability (not a production load benchmark).
- SQL contract checks STABLE, invoker security, empty search path, and grants.
- Real local Auth/REST tests cover empty accounts, two-owner isolation, anonymous
  and service-role denial, invalid parameters, 1,205 quests + 1,107 bosses beyond
  the REST cap, historical rewards, statuses, microsecond/week boundaries,
  deletion, and malformed date failure/recovery.
- Existing reward/deletion/creation regressions remain part of the same run.

No CI result is hosted beta or physical-device acceptance. No concurrent writer
stress test is claimed; the snapshot guarantee is the PostgreSQL STABLE contract.

## Exact rollout boundary (G3)

Source: `supabase/migrations/20261006054430_chronicle_server_totals.sql`.
Target after separate founder approval: ProjectMomentum beta
`bdzcazkyypopbanbjnud`. Apply this **one** additive migration only, after verifying
current schema/history and absence of this function, from the reviewed revision.
Do not push/reset/replay the root migration chain or repair migration history.
The same migration adds `tasks_chronicle_owner_idx` and
`bosses_chronicle_owner_idx`. These are ordinary transactional index builds,
subject to the migration's 3-second lock / 20-second statement timeouts; inspect
row counts and approve a suitable beta window before applying. Timeout means
stop and review, never disable guards or retry automatically. No Edge functions,
auth, existing grants, table definitions or historical rows change.
Verify exact function definition, ACL, security/volatility and unchanged schema
outside this addition after applying; record remote migration history and hash.

Deployment alone does not close C11: next change must validate the response and
account identity in the client, pass native/web tests, and be activated only after
the backend exists. Until then C11a's complete-history client remains operational.
If deployment fails, stop and inspect the atomic result. There is no automatic
live rollback. Before client activation, leaving this authenticated read endpoint
unused is the lowest-risk recovery; dropping it later needs a reviewed scope.

References:
- https://www.postgresql.org/docs/current/xfunc-volatility.html
- https://supabase.com/docs/guides/database/functions
