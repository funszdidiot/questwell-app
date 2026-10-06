# C07b — Native compile checks and critical client coverage

The shared Flutter workflow now runs Android and iOS compile jobs on every PR
for `questwell-dev` and `flutterflow`, and on development preview delivery.
There are no source-path filters. The preview build depends on completion of
all jobs in this reusable workflow. Existing isolated backend CI remains a
separate job/workflow on every PR and development push.

## Checks and limits

| Check | Evidence produced | Does not establish |
| --- | --- | --- |
| `analyze` | Explicit analyzer/format baseline; complete Flutter suite; Chrome regressions; web release compile on both PR targets | Device or hosted-account acceptance |
| `Critical client coverage` | Separate fresh-runner focused line/branch suite, validated report and artifact | Whole-suite or behavior-path completeness |
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
purchases, account deletion and recovery. The complete existing Flutter suite remains an unchanged mandatory regression
step. A separate fresh `ubuntu-24.04` job runs a 114-test focused suite using `--coverage --branch-coverage
--concurrency=1` across open quests, boss lists, boss creation recovery, purchase
recovery, deletion UI, authentication, network handling, startup and direct client
service adapters. It does not
claim whole-suite coverage, and no rendering tests are excluded from the full
regression gate. `tool/critical_coverage.py` reports each area's measured line and
branch numerator/denominator separately, with uncovered coordinates per file
in JSON. This is client-code execution coverage, not behavior-path completeness.
It does not infer SQL or Edge coverage from Dart tests or combine Chrome results.

The reporter fails on missing selected source records, missing branch data,
malformed/truncated LCOV, inconsistent totals and duplicate scope. Repeated
valid source records merge by line/branch identity without inflating denominators.
Zero instrumented branches show N/A rather than 100%.
The pinned Flutter exporter uses Dart coverage 1.15.0, whose `formatter.dart`
writes BRDA entries and no BRF/BRH totals. The explicit `--flutter-lcov` mode
accepts omission of BOTH fields and derives counts from BRDA; a partial pair
always fails. Strict/default LCOV requires both totals when branches exist.
Supplied totals are always cross-checked. This cannot detect branch entries
omitted by the producer from an otherwise well-formed record; it does not claim
a source-independent branch census. AI review prompted strict pair validation
and this documented, tested producer-specific compatibility rule. Seven focused parser/report
tests exercise these failure cases. No arbitrary percentage threshold or claim
of acceptable risk is introduced: use measured gaps to prioritize subsequent
characterized tests. Native/device branches remain manual evidence requirements.

The job summary and seven-day artifact `critical-client-coverage-<commit>` retain
LCOV plus Markdown/JSON reports. PR/FIX_PLAN records preserve the actual observed
numbers and workflow IDs beyond artifact expiration. Reporter or test failure
blocks its workflow; there is no continue-on-error or successful partial report.

```sh
flutter pub get --enforce-lockfile
flutter test --dart-define=QUESTWELL_ENVIRONMENT=isolated_test
flutter test --dart-define=QUESTWELL_ENVIRONMENT=isolated_test --coverage --branch-coverage --concurrency=1 \
  test/open_task_list_test.dart test/boss_list_test.dart test/boss_creation_recovery_test.dart \
  test/purchase_recovery_test.dart test/delete_account_test.dart test/auth_flow_test.dart \
  test/questwell_network_test.dart test/startup_bootstrap_test.dart test/widget_test.dart \
  test/client_service_adapters_test.dart
python3 -m unittest discover -s tool/qa -p coverage_report_test.py -v
python3 tool/critical_coverage.py coverage/lcov.info --flutter-lcov --output coverage/critical-paths
```

## Validation and remaining release gates

The initial local instrumented full-suite run encountered Flutter tester
segmentation faults in rendering tests. A single-file instrumented reproduction
passed, but serial full-suite execution also failed; both crashed local attempts
were stopped. No root-cause or local full-suite success is claimed. The separate
focused instrumented suite then passed all 72 tests locally. Its first CI attempt
in the same job after the full regression suite stalled, so coverage now uses a
fresh runner and checkout, with no shared test-build state. This is isolation,
not a proven diagnosis of the runtime crash. All jobs remain mandatory for
preview delivery, and branch instrumentation remains enabled. The unchanged full
regression suite plus focused instrumentation must both pass on the final GitHub
head before merge. Record actual results in PR/FIX_PLAN. Both native jobs must
actually run and pass, not merely exist in YAML.

Initial focused measurement (client service files, not backend assertions):

| Area | Lines | Branch entries |
| --- | --- | --- |
| Rewards | 15/84 (17.86%) | 5/37 (13.51%) |
| Purchases | 4/155 (2.58%) | 6/69 (8.70%) |
| Account deletion | 0/13 (0.00%) | 0/7 (0.00%) |
| Recovery | 93/120 (77.50%) | 52/72 (72.22%) |

These gaps are real: UI tests with injected callbacks and backend integration
assertions do not establish execution coverage of the client service adapters.
The next increment adds 42 direct client adapter tests using the real services and
pinned Supabase SDK with a synthetic session and an intercepted HTTP boundary.
No production service, dependency, schema, account or art changes are needed.
The adapter tests exercise deletion confirmation, failure and owner-local cleanup;
server-authoritative quest/boss rewards and no automatic replay after disconnect;
creation receipts retained across explicit retries; purchase reconciliation in
ownership-then-balance order; failure notification behavior, queue recovery and
account switches while queued or during each purchase response stage.

Local focused measurement after this increment (114 passing tests):

| Area | Lines | Branch entries |
| --- | --- | --- |
| Rewards | 66/84 (78.57%) | 24/37 (64.86%) |
| Purchases | 34/155 (21.94%) | 17/69 (24.64%) |
| Account deletion | 12/13 (92.31%) | 6/7 (85.71%) |
| Recovery | 93/120 (77.50%) | 52/72 (72.22%) |

The one uncovered deletion line/branch entry is its private unused constructor,
not proof of complete deletion behavior coverage. The Purchases group includes
the entire cosmetic service: catalog/profile loading, equipment, placement,
onboarding and identity preferences remain unexercised by this focused suite.
The purchase method's reported line entries are exercised, but execution counts
do not prove every interleaving or failure path. Rewards still includes uncovered
status-transition and list-adapter paths; the auth service remains unexercised.
These are follow-up priorities, not waivers or acceptable-risk declarations.
Mocks verify SDK request/response contracts; the separate backend harness governs
actual server effects. No hosted-account, physical-device or tester acceptance
is inferred. Final-head CI and deployment results belong in PR/FIX_PLAN.

C07b remains incomplete until selected signed release builds, install/upgrade,
required hosted check settings and release critical-path acceptance are verified.
A08 requires authorized repository-administration access; no branch settings are
changed here. Current native identifiers, signing readiness and privacy/link
attestations remain C13/R04 work. Overall release remains NO-GO.

References checked 2026-10-06: [Flutter iOS release requirements](https://docs.flutter.dev/deployment/ios),
[GitHub reusable workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).
The pinned Flutter 3.44.6 CLI advertises `--coverage` and `--branch-coverage`;
actual generated LCOV and native CI logs govern the evidence.
