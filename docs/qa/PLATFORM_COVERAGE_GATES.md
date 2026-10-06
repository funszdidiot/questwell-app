# C07b — Native compile checks and critical client coverage

The shared Flutter workflow now runs Android and iOS compile jobs on every PR
for `questwell-dev` and `flutterflow`, and on development preview delivery.
There are no source-path filters. The preview build depends on completion of
all jobs in this reusable workflow. Existing isolated backend CI remains a
separate job/workflow on every PR and development push.

## Checks and limits

| Check | Evidence produced | Does not establish |
| --- | --- | --- |
| `analyze` | Explicit analyzer/format baseline; complete Flutter suite with line/branch instrumentation; critical coverage report; Chrome regressions; web release compile on both PR targets | Device or hosted-account acceptance |
| `android / signing` | Debug compile of `lib/main.dart` under `isolated_test`; release packaging must fail with the exact missing-signing-credentials error | Signed release AAB, store acceptance or install/upgrade |
| `iOS unsigned release compile` | Release compile of `lib/main.dart` on `macos-15`, no codesigning, under `isolated_test`; toolchain versions in logs | Signed archive/IPA, Apple identity attestation or install/upgrade |
| `Isolated application schema and smoke tests` | Existing disposable backend/Auth/REST/Edge/Storage assertions and cleanup | Hosted acceptance or numeric server coverage |

The Android signing workflow is reused rather than duplicated; its manual
trigger remains available. It no longer has an independent path-filtered PR
trigger because the shared Flutter workflow invokes it on all PRs. Release
signing stays fail-closed. No signing secrets, live backend credentials, store
uploads, application identifier changes or native distribution are introduced.
The unsigned iOS output is compile evidence, not an installable release artifact.

## Coverage scope

`tool/critical_coverage.json` explicitly maps client source files to rewards,
purchases, account deletion and recovery. `flutter test --coverage
--branch-coverage` instruments the complete existing test suite; no tests are
excluded. `tool/critical_coverage.py` reports each area's measured line and
branch numerator/denominator separately, with uncovered coordinates per file
in JSON. This is client-code execution coverage, not behavior-path completeness.
It does not infer SQL or Edge coverage from Dart tests or combine Chrome results.

The reporter fails on missing selected source records, missing branch data,
malformed/truncated LCOV, inconsistent totals and duplicate scope. Repeated
valid source records merge by line/branch identity without inflating denominators.
Zero instrumented branches show N/A rather than 100%. Six focused parser/report
tests exercise these failure cases. No arbitrary percentage threshold or claim
of acceptable risk is introduced: use measured gaps to prioritize subsequent
characterized tests. Native/device branches remain manual evidence requirements.

The job summary and seven-day artifact `critical-client-coverage-<commit>` retain
LCOV plus Markdown/JSON reports. PR/FIX_PLAN records preserve the actual observed
numbers and workflow IDs beyond artifact expiration. Reporter or test failure
blocks its workflow; there is no continue-on-error or successful partial report.

```sh
flutter pub get --enforce-lockfile
flutter test --dart-define=QUESTWELL_ENVIRONMENT=isolated_test --coverage --branch-coverage
python3 -m unittest discover -s tool/qa -p coverage_report_test.py -v
python3 tool/critical_coverage.py coverage/lcov.info --output coverage/critical-paths
```

## Validation and remaining release gates

The initial local instrumented full-suite run encountered Flutter tester
segmentation faults in rendering tests. A single-file instrumented reproduction
passed, but serial full-suite execution also failed; no root-cause or local
full-suite success is claimed. Authoritative final-head GitHub checks must pass
without suppressing these failures before merge; record results in the PR and
FIX_PLAN. Both native jobs must actually run and pass, not merely exist in YAML.

C07b remains incomplete until selected signed release builds, install/upgrade,
required hosted check settings and release critical-path acceptance are verified.
A08 requires authorized repository-administration access; no branch settings are
changed here. Current native identifiers, signing readiness and privacy/link
attestations remain C13/R04 work. Overall release remains NO-GO.

References checked 2026-10-06: [Flutter iOS release requirements](https://docs.flutter.dev/deployment/ios),
[GitHub reusable workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).
The pinned Flutter 3.44.6 CLI advertises `--coverage` and `--branch-coverage`;
actual generated LCOV and native CI logs govern the evidence.
