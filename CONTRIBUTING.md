# Contributing to Questwell

Use a focused branch from current `questwell-dev`, read [AGENTS.md](AGENTS.md),
and follow [ENGINEERING_STANDARDS.md](docs/ENGINEERING_STANDARDS.md). Keep one
functional gate per PR; separate mechanical cleanup from behavior changes when
that makes review clearer. Existing launch and live-data approval holds remain
in force. A development merge does not authorize a migration or production launch.

## Before changing behavior

Reproduce the defect in a focused test when practical. For service changes,
exercise the real adapter with intercepted HTTP and synthetic Auth state; do not
use a real customer session. Cover the relevant success, rejection, uncertain
write result and account-switch paths. Test the corrected behavior, not private
implementation details. Preserve existing public APIs and generated boundaries
unless the change explicitly requires otherwise.

## Local checks

Use Flutter 3.44.6 / Dart 3.12.2 on PATH. Resolve once from the committed lockfile:

```sh
flutter pub get --enforce-lockfile
python3 -m unittest discover -s tool/qa -p quality_gate_test.py -v
python3 tool/quality_gate.py
flutter test --no-pub --dart-define=QUESTWELL_ENVIRONMENT=isolated_test
git diff --check
git diff --exit-code -- pubspec.yaml pubspec.lock
```

For a targeted change, run its tests during iteration; the shared workflow runs
the full Flutter suite, selected Chrome adapters, separate critical coverage and
native compile checks. Use the checked-in workflow's exact commands for matching
CI. The isolated backend workflow is required for reviewed backend contracts;
it may create and dispose only its synthetic local stack. See
[backend instructions](supabase/README.md) before changing migrations or functions.

Format each edited Dart file with `dart format path/to/file.dart`. If it had a
legacy formatting allowance, remove only that allowance. Remove only diagnostics
actually resolved by the change. Never regenerate the baseline or refresh a
legacy hash to conceal new debt. The gate prints inherited debt and rejects new
findings. Existing analyzer exclusions are limitations, not permission to add more.

## Review and delivery

PR descriptions explain the user-visible problem, resulting behavior, measured
tests, remaining limitations and rollback. Record the exact reviewed head and
final CI results. Address AI review findings and re-review changed code; do not
mark a thread resolved just because a test is green. Development merge authority
is governed by the current founder instructions, not this document.

After a development merge, verify postmerge checks, preview deployment and the
served revision. Update the existing FIX_PLAN with evidence and unresolved gates.
Do not label tester feedback accepted, artwork locked or a physical-device flow
passed without the corresponding result. Keep customer content and credentials
out of logs, screenshots, test fixtures, PRs and diagnostic reports.
