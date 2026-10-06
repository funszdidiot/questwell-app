# C07a — Enforced analyzer and formatting baseline

The shared Flutter workflow previously used `flutter analyze --no-fatal-infos
--no-fatal-warnings`, allowing new warnings and infos through. It now runs a
fail-closed gate before the complete Flutter suite and Chrome checks. The same
reusable workflow guards development preview deployment. This is source/CI work;
it does not establish native, hosted-account, recovery or tester acceptance.

## Policy

- Flutter 3.44.6 / Dart 3.12.2, existing locked dependencies.
- Four focused correctness lints: `valid_regexps`, `hash_and_equals`,
  `collection_methods_unrelated_type`, `unrelated_type_equality_checks`.
- The initial 46 findings from development `eb3e13e` remain explicitly listed
  and printed. Each baseline entry identifies severity, diagnostic type/code,
  repository path, exact message and multiplicity. This is not a total-count
  allowance. New signatures, severity changes or increased multiplicity fail;
  errors can never be baselined. Removed findings require removing their entries.
  Line/column positions are deliberately excluded so comment insertion does not
  manufacture new debt. Identical findings in one file are distinguished by
  count, not source identity; review replacements of existing debt carefully.
- The existing generated/custom-code analyzer exclusions are unchanged. This is
  not an assertion that excluded code or the 46 findings are clean. No new
  blanket ignores or diagnostic downgrades were added. The analyzer policy hash
  must match the reviewed baseline, making policy changes explicit.
- All 273 tracked Dart files are checked by the formatter with `--output=none
  --set-exit-if-changed`. The 217 inherited unformatted files are allowed only at
  their exact original SHA-256. Editing any such file requires formatting that
  file and deleting its allowance. New files have no allowance. Already formatted
  files cannot regress. Missing/symlinked sources, malformed output, incomplete
  file counts, tool failure and unexpected exit codes fail closed.
- Resolved/deleted entries must be removed; there is no automatic baseline update
  command. Do not refresh hashes to accommodate new debt. Any exceptional addition
  or SDK/policy change needs explicit explanation and review in its own PR.
- No runtime Dart files, generated art or asset bytes were edited in this change.
  Existing debt cleanup should be split into focused, characterized changes.

## Run locally

```sh
flutter pub get --enforce-lockfile
python3 -m unittest discover -s tool/qa -p quality_gate_test.py -v
python3 tool/quality_gate.py
flutter test --dart-define=QUESTWELL_ENVIRONMENT=isolated_test
```

Use `--dart /path/to/pinned/dart` for the gate or `DART=/path/to/pinned/dart`
for its tests if Dart is not on PATH. The checks never format source in place.
To fix a file intentionally, run `dart format path/to/file.dart`, inspect its diff,
and remove only its resolved baseline entry. Analyze the whole project again.

## Verification

The Python suite uses disposable projects with the real pinned SDK: clean code;
new warning/info/error; each of the four lint violations; shifted locations;
increased multiplicity; resolved findings; an unformatted fixture; unchanged
legacy bytes versus edited bytes; fixed formatting; invalid syntax; malformed
or incomplete tool output; and missing/symlinked tracked source. The info-level negative control uses an invalid regular expression with the
selected lint enabled. An initial deprecated-member fixture produced no diagnostic
in its temporary package and was replaced rather than weakening the assertion.

Local baseline check: 46 existing findings, 273 files, 217 unchanged formatting
allowances. The PR must pass AI review, full Flutter/Chrome/build and backend CI
before development merge; record actual final-head and deployment evidence in
its PR and FIX_PLAN. Branch protection remains a separate hosted setting (A08),
and native builds/critical-path coverage remain C07b. A green workflow alone
cannot prevent an administrator bypass or establish overall release GO.

References checked 2026-10-06: [Dart analysis](https://dart.dev/tools/dart-analyze)
and [non-writing formatter / CI exit behavior](https://dart.dev/tools/dart-format).
Actual exit codes and machine output were verified with the pinned SDK.
