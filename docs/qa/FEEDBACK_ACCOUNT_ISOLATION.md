# Feedback account isolation

Scope: C14 flow 9 / C07 client account boundaries. Based on development
`30aba943e703db6ca33d0ec8bfbb7c5945cf32a6`.

## Reproduced defect and fix

Opening feedback captured the draft owner, but the screenshot submission path
later used the current account instead. A switch while the form remained open
could therefore submit the original draft and screenshots as the new account.
The original upload/submit adapters also returned success after account changes,
and a duplicate response could start a reconciliation lookup under new auth.
This is a code/test finding, not evidence that a tester's draft was misattributed.

The runtime form now keeps its opening owner. It checks after local draft load,
local persistence, file selection, every upload, submission and local clearing.
An observed auth change permanently hides the old form's content and offers a
close action; switching back does not revive it. Disposal invalidates pending
picker/send work. Original-owner draft storage remains scoped to its original key.
Preview and injected form callbacks keep their existing local-only behavior.

Services check owner before and after awaited writes and duplicate lookup.
Screenshot cleanup requires every path to belong to the active captured owner;
it rejects stale completion too. Writes still run once. These client guards
prevent stale publication/subsequent requests; they cannot undo a request already
committed by the server. Server RLS remains authoritative and unchanged.

## Verification

The new test uses real adapters and the pinned Supabase SDK with intercepted
HTTP, synthetic sessions, a synthetic file picker and actual feedback widgets.
No live session, customer content, real upload, deletion, schema change or Auth
setting change is used. Coverage includes same-owner success and duplicate
confirmation, wrong owner, logout/switch during upload/insert/lookup/cleanup,
single-attempt network failure, screenshot reassignment, save/submit/clear races,
sticky screen invalidation, and delayed picker completion after switch/disposal.

Tests-only PR head `9af368a71a672d8a345dde23c2540b7efa559891` ran against unchanged
production source in run `37562857794`, job `112603854669`: **814 passed, eight
failed**, all eight failures in the new 14-case isolation test. This includes
actual upload/insert requests from the switched-account screenshot form.
Earlier tests-only attempts stopped at a redundant import and language-version
formatting; both were corrected without weakening the gate. The final suite adds
eight more cases (22 total) for lifecycle and review findings.

Independent review also caught and corrected premature listener cancellation on
failed close, and a new confirmed-delivery cleanup path on disposal. Regression
cases require the stale view to close even when saving fails and require no
remote deletion after a confirmed send on a disposed form. Auth-event identity
latches even a rapid account change. Final green CI and delivery evidence belongs
in PR #51 and the current FIX_PLAN; the reproduction is not a passing result.

Local package resolution was stopped by automatic security review because it
attempted an instance metadata endpoint. It was not retried or bypassed; existing
GitHub Actions provides execution. Local pinned Dart formatting and diff checks
remain available. Both touched Dart files are fully formatted; only their two
resolved legacy allowances are removed. No diagnostic baseline changes.

## Remaining delivery limitation

The pre-existing catch path can remove successfully uploaded screenshots after
an uncertain insert, even if the report committed. Retrying a deterministic
non-upsert upload may also encounter an existing object. This PR isolates account
ownership; it does not claim retry-safe attachment delivery. That distinct
reconciliation/cleanup contract remains required before flow 9 acceptance/GO.
Hosted and signed native/device acceptance also remain open.

Supabase's changelog and current Flutter upload documentation were checked on
October 7, 2026; no SDK or API change is introduced here. The locked SDK remains
2.9.0 (`supabase_flutter`) / 2.4.0 (`storage_client`). References:
https://supabase.com/changelog and
https://supabase.com/docs/reference/dart/storage-from-upload .
