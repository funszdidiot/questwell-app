# Room and page loading follow-up

Status: QA — not deployed.

Founder report: room selection would not load; recording also shows late
destination illustrations and a prolonged initial Boss Battles spinner.

## Confirmed defects and scoped changes

- Hearth backgrounds previously retained the old frame while fetching a new
  room, and failed silently into a gradient. A shared scene loader now covers
  stale artwork with the requested room name, gives a bounded loading state,
  and provides explicit Retry for failure or a 12-second stall. Late results
  cannot replace a newer selection. Retry evicts/reconnects the image cache;
  cache failures remain recoverable. No room-selection persistence writes.
- Destination illustrations use the same loading/error/retry treatment.
- The editor explains when the current arrangement is already saved. It does
  not make that claim after an unconfirmed save error.
- Independent appearance/layout reads start together when opening the editor.
- Boss battles and steps load concurrently, with complete owner-checked keyset
  pagination retained. Both collections must succeed before publishing a list;
  either failure surfaces promptly. No schema, economy or account-data changes.

## Evidence and boundaries

- Independent source review identified these mechanisms; the screenshot alone
  does not prove the specific cause of the founder's failed room switch.
- All nine live room-background URLs returned HTTP 200 during read-only checks.
- Four cache-backed image tests cover stalled/failed downloads, successful
  retry with a real Image child, failed cache eviction, disposal, and stale
  prior-room completions. 21 boss-list tests pass, including concurrency and
  early/late-error regressions. Existing room tests pass.
- Independent re-review accepted after resolving cache-eviction errors and
  misleading saved-state copy after an uncertain save. 19 combined image,
  editor and small-screen battle navigation tests pass. Quality gate passes
  with no new findings (45 existing; 342 files, 145 legacy formatting entries).
- Full regression suite and deployment evidence pending.
- This change does not compress/replace locked artwork or promise faster image
  transfer. It exposes/recoverably handles background failures and removes
  avoidable serial data waits. Avatar/decor asset completion is not gated by
  the room-background loader. Physical iPhone and signed-in network latency
  remain separate acceptance checks.
