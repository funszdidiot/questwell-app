# C09b — Engineering standards

These standards preserve Questwell's existing Flutter architecture. They guide
new code and focused fixes; they do not assert that every legacy file already
complies. No new state-management framework or broad generated-code rewrite is
required. Use the actual checked-in contracts and regression tests as examples.

## Responsibilities and naming

Presentation widgets own rendering, transient UI state, loading/error controls
and navigation. Keep the existing stateful-widget/model pattern. Domain services
own access checks, input validation, backend calls and response interpretation;
small policy/model classes hold reusable pure logic. See `lib/services/` for
task, boss, cosmetic, account and Chronicle boundaries. Keep transport handling
in `lib/backend/supabase/questwell_network.dart` instead of repeating it in UI.

Use Dart `lower_snake_case.dart` filenames, `UpperCamelCase` types and
`lowerCamelCase` members. Match existing `Questwell…Service`, policy and model
names when extending those families. Name methods for domain actions, not table
plumbing; distinguish a confirmed mutation from an uncertain network result.
Use private members for implementation details. Naming and responsibility
placement are review requirements; the current lint gate does not enforce them
universally. Do not rename legacy/generated public APIs as incidental cleanup.

## Server authority and account boundaries

Rewards, purchases, ownership, starter creation, idempotency and final boss
completion remain server-authoritative. A disabled button prevents some duplicate
taps but cannot provide transaction safety. Preserve the reviewed RPC contracts,
RLS and grants; validate client inputs for clear feedback without replacing
server authorization. Do not invent new domain limits or coerce historical data.

Capture the authenticated owner when an operation is requested. Recheck before
each network attempt and after awaited results, including work queued behind
other calls. Clear owner-bound caches/state on an account change. Do not publish
old-account success events into a new session. Check widget mounted/request
identity before applying asynchronous UI results. Owner guards prevent stale
client publication; they cannot undo a mutation already committed by the server.
Use server identity/RLS for authorization, not a client-provided owner alone.

## Errors, retries and parsing

Use the existing typed `QuestwellNetworkException` for recognized connectivity
failures through `QuestwellNetwork`; preserve SDK/domain failure types when they
carry a different meaning. Keep detailed causes internal and show safe,
actionable UI messages. Never log credentials, email addresses or user task text.
Avoid blanket catches that turn failure into empty data or false success.

The network wrapper retries bounded transient reads once. Generic writes run
once: a timeout does not prove rollback, so a blind retry can duplicate work.
Use an existing stable request identity and reconciliation contract for a
retryable domain mutation. Retain drafts on failure and invalidate pending work
when accounts change. Validate expected fields/types/ranges before treating a
response as a confirmed result. Do not derive authoritative totals from a
truncated history page; preserve deterministic paging and reviewed totals RPCs.

## Enforced checks and their limits

| Rule | Existing enforcement / negative control |
| --- | --- |
| No new Dart diagnostic debt | `tool/quality_gate.py`, exact diagnostic signatures/counts; a real new warning/info/error fails `tool/qa/quality_gate_test.py` |
| Correctness lints | `analysis_options.yaml`: valid regexes, equality/hash consistency, unrelated collection/equality types; actual violating Dart fixtures are rejected |
| Format edited/new Dart files | Real formatter in non-writing mode; unformatted and changed legacy fixtures fail; unchanged legacy byte hashes remain explicit |
| Locked dependencies | `flutter pub get --enforce-lockfile` and dependency-input diff guards in CI; no broad upgrades in unrelated changes |
| Owner isolation and uncertain writes | Focused service/HTTP, recovery and Chrome regression tests; see `test/auth_catalog_adapters_test.dart`, `test/client_service_adapters_test.dart` and `test/questwell_network_test.dart` |
| Server authorization and transactions | Disposable Auth/REST/database harness; local fixtures cannot substitute for hosted release acceptance |

The 18 existing quality-gate tests provide the deliberately violating fixtures
for this standard; do not add duplicate tests merely to restate documentation.
They use the real pinned Dart SDK in disposable projects and fail closed on
malformed/truncated tool output. Run them with the commands in
[CONTRIBUTING.md](../CONTRIBUTING.md). The workflow already invokes them before
the full application suite. This C09b change documents and uses those hooks;
it introduces no new analyzer ignores, baseline allowances or test exclusions.

At PR #47 the baseline retained 45 inherited diagnostics and 214 unchanged legacy
format allowances. Treat those as a dated checkpoint, not an adjustable budget.
The baseline file and current CI output are authoritative. Existing generated
analyzer exclusions remain visible debt. No check above proves all architectural
rules, payload validation or account races are exhaustively covered.

## Release and sensitive changes

Follow the current FIX_PLAN and scoped founder approvals for environment changes,
live migrations, history repair, native signing, diagnostics providers, restores
and production promotion. Use only explicit approved build profiles. Never
introduce service-role credentials into a client or PR job. Apply avatar/body/fit
locks from AGENTS and production art standards; CI hashes alone are not visual
acceptance. Record implementation, CI, deployment and tester acceptance separately.

Rollback a faulty client or gate in a reviewed change while keeping its remaining
release limitation explicit. Never disable a failing test to declare GO or roll
back an additive server safety contract without a compatibility plan.
