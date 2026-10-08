# Reviewed Halloween forward deployment

## Scope and status

Tanya approved six new items at 220/140/100/160/60/60 coins, the Halloween
collection rollout, purchase availability through November 8 Chicago time,
and permanent ownership. PR #75 implements this scope. Existing Harvest prices,
IDs and availability remain unchanged. No bundle SKU or account grants are added.
The root migration history remains incomplete and must not be replayed or repaired.

The forward path is prepared; live execution has NOT occurred. It needs successful
combined-revision CI, independent review, delivered client verification and a new
scoped deployment credential. The prior Woodland credential is expired and outside
this scope. No deployment branch or new secret has been created.

## Reviewed path

- `.github/workflows/questwell-hallowed-forward.yml`
- `tool/deploy/hallowed-hearth.mjs` and `hallowed-contract.mjs`
- `tool/deploy/hallowed-reviewed-state.json`
- `supabase/migrations/20261008015627_hallowed_hearth_catalog.sql`
- `docs/releases/hallowed-hearth-2026/activate.sql`

Only a push to `deploy/hallowed-hearth-approved` in `funszdidiot/questwell-app`
on a GitHub-hosted runner may write. It must equal current `questwell-dev`, have
successful same-SHA analyzer, client coverage, Android, iOS and backend checks,
and match the served development revision and all six image hashes.

One Management API migration targets only project `bdzcazkyypopbanbjnud`, under
name `hallowed_hearth_2026`. Source, manifest, catalog query and activation bytes
are hash locked. Exact metadata preconditions preserve all 51 existing history
rows, legacy catalog/render data, layout profiles/slots and protected schema.
Only the purchase function definition, six new items and five render rows change.
A single guarded SQL transaction stages and activates them atomically and checks
the exact post-state. The API assigns the history version; it need not match the
source filename. No CLI remote push/reset/repair is used.

Purchase dates are enforced after the owned-retry check and before charging.
Activation sets an explicit start and the exclusive end `2026-11-09T06:00:00Z`.
Activation itself refuses an already-closed window. After launch keep these rows
active: the end date closes new purchases while preserving equip and placement.

## Verification

Offline tests reject source drift, unsafe execution context, wrong migration
history and altered workflow branch guards. The disposable backend rehearsal
rejects precondition drift and injected postcondition failure, verifies complete
rollback, and exercises the exact positive payload before rolling it back. After
the approved window closes, it instead verifies expected expiry refusal without
changes. Separate synthetic purchase tests cover all six approved prices,
inactive/future/expired refusal, exact boundaries, single charges, retries after
cutoff, placement, unequip and restoration. No real account is used by CI.

## Credential and execution gate

A newly approved short-lived token scoped only to this project's Database Read
and Migrations Write capabilities must be stored as GitHub Actions secret
`QUESTWELL_HALLOWED_MIGRATION_TOKEN`. Do not paste credentials into chat, reuse
the Woodland secret or grant broad project/account permissions. This new
credential creation/storage is not inferred from artwork approval.

Once the credential and all gates are available, create the dedicated deployment
branch at the verified served development SHA. Inspect the workflow outcome, then
independently query metadata to verify the six prices, start/end dates, renderer
rows, unchanged protected state and one matching migration record.

There are no automatic write retries. On timeout, interruption, drift or ambiguous
API failure, reconcile state and history read-only first. An existing exact
matching migration is verified without another write. Unexpected or partial state
requires investigation; never repair history or widen this payload to proceed.
No main/flutterflow promotion is included.
