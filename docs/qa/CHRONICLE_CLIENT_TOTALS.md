# C11c — use verified Chronicle server totals

Backend prerequisite is satisfied: Tanya approved PR #42; its byte-identical SQL
was deployed to beta bdzcazkyypopbanbjnud as migration 20261006111607. Schema,
ACL, two valid owner indexes, unchanged prior history and read-only SQL execution
were verified. This client change introduces no migration or live account write.

Chronicle still loads all four owner-filtered history collections. It then calls
`chronicle_totals` with the existing client-local Monday boundary converted to
UTC. All summary fields come from that single server response. It checks account
identity before each request/retry and after the response, and validates returned
owner, matching absolute week boundary and every required decimal-string total.
Counts must be nonnegative. Historical signed rewards retain their existing
meaning. Values outside ±9,007,199,254,740,991 fail explicitly on both native and
web instead of silently rounding. No RPC failure or invalid response falls back
to a client fold or plausible zero. The existing retry/error UI handles failures.
`ChronicleSnapshot.fromWins` remains for local sample/fixture construction only;
network-loaded snapshots use the RPC.

The aggregate and paged list can represent different moments during concurrent
edits. We deliberately do not compare them or claim a shared transaction. A
removed row may still appear in the just-loaded list while the fresher server
total excludes it. Refresh reloads both. All pages must still succeed before
publishing a snapshot. History loading cost remains proportional to its length.

Validation:
- Baseline implementation fails the new server-authority regression (no RPC
  request); restored implementation passes.
- 93 focused tests pass: 34 existing history tests plus 59 server-contract cases,
  covering malformed/missing/unsafe values, account changes, retry, zero and safe
  limits, RPC failure, history preservation and explicit server-authoritative
  totals. Targeted Dart analysis is clean.
- Chrome CI includes the new contract suite to verify browser integer behavior.
- Full Flutter/Chrome/backend CI and exact-head AI review are required before
  merge; deployed revision verification follows. No hosted signed-in acceptance
  or physical-device result is implied by synthetic transports.

Rollback: revert client use to the previous complete-history loader with its
known cross-read consistency limitation, preserving the safe deployed RPC and
indexes. Do not undo approved reward/deletion hardening or migration history.
