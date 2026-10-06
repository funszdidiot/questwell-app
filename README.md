# Questwell

Questwell is a Flutter application with a Supabase backend. The development
branch is `questwell-dev`; `flutterflow` is the repository default branch and
must not receive a production promotion without separate approval.

Use Flutter **3.44.6**, its bundled Dart **3.12.2**, and the committed
`pubspec.lock`. Start with [CONTRIBUTING.md](CONTRIBUTING.md) and the
[engineering standards](docs/ENGINEERING_STANDARDS.md).

```sh
flutter pub get --enforce-lockfile
python3 tool/quality_gate.py
flutter test --no-pub --dart-define=QUESTWELL_ENVIRONMENT=isolated_test
```

`isolated_test` intentionally has no working backend; tests inject synthetic
adapters. The existing development web deployment explicitly uses `live_beta`.
There is no approved persistent staging or production profile. Read
[environment boundaries](docs/qa/EXPLICIT_BUILD_ENVIRONMENTS.md) before running
an app against any backend. Real Auth/REST tests belong in the
[disposable backend harness](docs/qa/ISOLATED_BACKEND_HARNESS.md).

See [platform and coverage gates](docs/qa/PLATFORM_COVERAGE_GATES.md) for measured
coverage and unsigned compile checks. Passing these checks does not establish
store signing, physical-device testing, hosted-account acceptance or release GO.
Read [AGENTS.md](AGENTS.md) and the applicable art references before touching
avatars; visual approval and technical integration are separate decisions.
