# Flutter dependency lock — release hardening B01

Date: 2026-10-05 (America/Chicago)  
Finding: QW-11, missing application lockfile.  
Review: [PR #17](https://github.com/funszdidiot/questwell-app/pull/17).

## Scope and provenance

The application lockfile is the unedited output of Flutter's resolver, not a
handwritten reconstruction. No pubspec constraints, overrides, application
code, assets, native identities, authentication settings or database objects
change in this PR.

Verified toolchain:

- Flutter 3.44.6, stable; framework revision
  ee80f08bbf97172ec030b8751ceab557177a34a6.
- Dart 3.12.2; engine revision
  83675ed27633283e7fc296c8bca22e841224c096.
- Resolution: 118 dependencies, comprising 113 hosted pub.dev packages and five
  Flutter SDK packages, excluding the root application.
- All 118 names/versions match the successful development-preview quality job
  111791976588 in run 37318677872 and the Phase 1 audited package inventory.
  There are no git/path dependencies in this resolution.

Capture source:
[run 37320613927](https://github.com/funszdidiot/questwell-app/actions/runs/37320613927),
job 111798420883, commit e6d995b719dc60a7e39a45b1820b5ee40ff2a32e.
Artifact 11348709526 contained only pubspec.lock, dependencies.json and
flutter-version.json. Its downloaded ZIP matched the recorded SHA-256:

    a8b37587c67876178216aff42372f6e6bd6afe640c68d9baf48ae3d4525955eb

The generated and committed lockfile content must retain SHA-256:

    8e8e57700f395aba87509b095549289126720eedcd5d44d4de919f97a29af4a2

The unchanged pubspec.yaml SHA-256 is:

    243b895c69c4a7bd5128dc92f71017df27fb3cbad4aa6fce31bf69b3caf1d340

The temporary capture/upload step is absent from the final workflow. The
short-lived artifact is supporting provenance, not a required build input.
The committed lockfile remains the durable source of dependency resolution.

## Test first: the missing tracked lockfile

Before the fix, the real CI assertion failed after dependency resolution:

    2026-10-05T13:56:30.6896518Z error: pathspec 'pubspec.lock' did not match any file(s) known to git
    2026-10-05T13:56:30.6911724Z ##[error]Process completed with exit code 1.

This was the intended failure at "Require the application lockfile in version
control"; capture, Node tests and asset checks had passed. No application tests
or web build from that failing run are claimed.

## Enforced contract

Both Flutter Check and the preview build require pubspec.lock to be tracked,
then run:

    flutter pub get --enforce-lockfile
    git diff --exit-code -- pubspec.yaml pubspec.lock

Flutter Check repeats strict resolution with a previously nonexistent,
runner-local PUB_CACHE directory and records the lockfile digest. A final diff
check detects dependency-input changes made by analysis, tests or builds.
Preview also checks its dependency inputs after building, before upload/deploy.

Use Flutter 3.44.6 for the current release candidate. For an intentional future
dependency update, modify/review the manifest and generated lockfile together
in a separate PR, inspect resolved changes, and run the complete relevant
verification. Never hand-edit package versions or checksums to bypass a failed
resolution, and never use pub upgrade merely to make CI green.

Current official references, checked October 5:

- [Dart pub get and lockfile enforcement](https://dart.dev/tools/pub/cmd/pub-get)
- [Dependency graph output](https://dart.dev/tools/pub/cmd/pub-deps)

The installed Flutter 3.44.6 help output also confirmed --enforce-lockfile.

## Acceptance evidence and limits

Use the checks for the current PR head to establish green status: tracked
lockfile, normal and empty-cache strict resolution, unchanged package inputs,
Node/Flutter regressions, asset validation and release web build. The earlier
capture run intentionally failed and is not green evidence.

This controls Dart/Flutter package resolution, not all inputs to a hermetic
build. Native Gradle/CocoaPods/toolchains, GitHub action revisions, signing,
app runtime behavior and live backend reconstruction remain separate audit
concerns. Bit-identical binaries are not claimed.

Package versions match the audit; this is not a dependency security upgrade or
a new license-compliance attestation. Existing advisor/license/privacy findings,
45 tolerated analyzer warnings/infos and the excluded placeholder widget test
remain visible. Local Flutter/Dart/Supabase tooling was unavailable, so fresh
Flutter evidence must come from CI. No clean database or physical-device test
is implied.

Risk: an incompatible locked resolution would stop a build. The same versions
as the last successful app reduce that risk; normal and empty-cache checks and
the actual build are required before merge. Rollback is a reviewed revert of
this PR with an explicit temporary release block for the lost reproducibility
guard. No data migration or user-data rollback is involved.
