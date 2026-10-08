# Reviewed Halloween forward deployment

## Scope and status

Tanya approved six new items at 220/140/100/160/60/60 coins, the Halloween
collection rollout, purchase availability through November 8 Chicago time,
and permanent ownership. PR #75 implements this scope. Existing Harvest prices,
IDs and availability remain unchanged. No bundle SKU or account grants are added.
The root migration history remains incomplete and must not be replayed or repaired.

**Verified active:** PR #79 centers the print on the fireplace; development
revision `973f49642eb779543e2b4df1a65ac7085bb8917e` is served and all six
artwork hashes match. Independent source/visual review and all client/backend
gates passed. Preview `37722573952` and backend `37722573519` succeeded.

Tanya approved the exact 24-hour project-scoped Database Read + Migrations Write
token and GitHub Actions storage. It was created and stored; the prior Woodland
credential was not reused. Branch `deploy/hallowed-hearth-approved` remains at
the verified release SHA. Activation workflow `37723523792`, job `113136402518`,
succeeded at 03:36:53 UTC October 8 as migration `20261008033653`.

Independent read-only post-verification confirmed six active approved-price
items, five renderer entries, nonpremium/all-class access, start
`2026-10-08T03:36:53.444481Z`, end `2026-11-09T06:00:00Z`, exact protected
schema/catalog/51-prior-history hashes and one new matching forward record.
The combined source digest is
`4321040c7b9b9324368668967aadc3f58b18cbf160b3396066b8f540e148187a`.
No retry or history repair occurred. Total migration history is now 52.

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

The approved short-lived token, now stored, is scoped only to this project's Database Read
and Migrations Write capabilities and is stored as GitHub Actions secret
`QUESTWELL_HALLOWED_MIGRATION_TOKEN`. Do not paste credentials into chat, reuse
the Woodland secret or grant broad project/account permissions. This new
credential creation/storage is not inferred from artwork approval.

The dedicated deployment branch was created only after all gates passed, and
the workflow outcome plus independent read-only metadata checks were verified.
Preserve that branch as execution evidence; do not move it for documentation.

There are no automatic write retries. On timeout, interruption, drift or ambiguous
API failure, reconcile state and history read-only first. An existing exact
matching migration is verified without another write. Unexpected or partial state
requires investigation; never repair history or widen this payload to proceed.
No main/flutterflow promotion is included.
