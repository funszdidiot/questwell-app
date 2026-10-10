# Internal iOS TestFlight preparation

Status: registered identity merged in PR #119 (`13230d5488b1af28996dad134d6f658c01f64836`).
Postmerge Preview run `38014960131` passed identity, regression, coverage, unsigned
iOS compile, build and deployment; Backend Harness `38014959611` also passed.
Signing preparation is proposed below. No signed archive, TestFlight upload or
iPhone acceptance is established. Overall release GO remains unchanged.

## First increment: Apple upload-compatible compiler

The existing required `iOS unsigned release compile` job retains `macos-15`,
Flutter 3.44.6, the committed Dart dependency lockfile, its real `lib/main.dart`
entrypoint and the `isolated_test` profile. It explicitly selects
`/Applications/Xcode_26.3.app/Contents/Developer` using job-level DEVELOPER_DIR.
A preflight rejects a missing directory, any Xcode version/build other than
26.3 / 17C529, or any iPhoneOS SDK other than 26.2. It never falls back to the
runner's default Xcode 16.4. No new action, package or credential is introduced.

This tests compatibility with an Apple-upload-eligible compiler, not upload
eligibility of the app itself. The isolated_test profile has no working backend
and must never be distributed to testers. Existing six required checks and
independent review apply; preserve concurrent feedback changes when integrating.

## Second increment: registered Apple identity

Founder screenshots confirm active account access, a registered explicit App ID
and the App Store Connect record below. The founder approved this identity-only
source alignment; this is not approval to sign, upload, merge or publish.

| Field | Approved value |
| --- | --- |
| App Store name | Questwell: Cozy Quests |
| Installed display name | Questwell |
| Bundle ID | `com.alreyva.questwell` |
| Development team | `W5779VXQYR` |
| App Store numeric ID | `6821206348` |
| SKU | `questwell-ios-001` |

Runner Debug, Profile and Release use the registered bundle ID and team.
`Info.plist` uses Questwell for both name fields and retains its build-setting
identifier/version substitutions. The existing `projectmomentum` URL scheme,
URL name and Flutter deep-link switch remain unchanged: renaming the app does
not establish functional native authentication. Entitlements, backend profiles,
dependencies and the unsigned compile command remain unchanged. No signing
credential or provisioning profile is added. App Store name availability does
not establish trademark clearance; public-launch name review remains separate.

`python3 tool/qa/ios_identity_test.py` checks all three Runner configurations,
plist identity and the preserved link contract, with deliberate drift fixtures.
The shared analyze job runs this standard-library-only guard. Source checks
cannot establish the final archive's effective settings or signing validity.

## Remaining stages and evidence

1. Account approval and App Store Connect record creation are confirmed by the
   founder's screenshots. Recheck agreements and account access before signing.
2. Identity PR #119 merged with founder approval. Confirm effective bundle/team
   settings again when creating the first signed archive.
3. Prepare a separately reviewed signed archive workflow using approved private
   signing credentials and an explicit functional beta backend profile. Do not
   put signing material into repository files or untrusted pull-request jobs.
4. Resolve native authentication return handling with specific approval. The
   live_beta return URL currently points to the web app; the actual native
   confirmation/reset flow remains unverified. Audit plugin/deep-link ownership,
   entitlements and return links before changing auth.
5. Inspect the final archive's privacy manifests, used APIs/SDKs and actual
   permission prompts; make accurate declarations. An empty app-level privacy
   manifest alone does not prove either compliance or noncompliance.
6. Validate and upload the signed archive to App Store Connect. Record its build
   number, source commit, signing identity, processing result and export-compliance
   disposition. Start with the founder's internal testing group.
7. Install on an actual iPhone and exercise login/recovery, quest and boss
   creation/completion, purchases/equipment, expeditions, feedback attachments,
   offline recovery and authorized disposable-account deletion. Record failures
   and fixes; automated tests do not substitute for device acceptance.
8. Before external testing, complete the TestFlight beta information and first
   external-build review. Public App Store release remains a separate decision.

The second increment changes source identity only, not account configuration,
credentials, auth policy, entitlements, backend, economy or locked artwork.
Existing feedback attachment and release-hardening work remains separate.

## Review and validation

Independent AI review is required on the exact final change. CI must exercise
the pinned Xcode/SDK preflight and unsigned compile, plus existing required
checks. Record the exact reviewed head, local guard results and new CI evidence
in the PR. Earlier toolchain success is not evidence for this identity change.

Rollback: revert the five-file identity increment through a reviewed PR. That
restores legacy source identity and removes its guard, without deleting the
registered Apple record or changing the pinned compiler. Do not upload a build
with the restored legacy identity. No distributed build is affected.

## Official references checked October 6, 2026

- Apple SDK requirement (effective April 28, 2026):
  https://developer.apple.com/news/upcoming-requirements/?id=04282026a
- GitHub macOS 15 installed Xcode and SDK versions:
  https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md
- Apple DEVELOPER_DIR selection:
  https://developer.apple.com/documentation/xcode/configuring-command-line-tools-settings
- Flutter iOS archive and distribution:
  https://docs.flutter.dev/deployment/ios
- Apple TestFlight workflow:
  https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/


## Third increment: signed archive preparation (approved scope, not executed)

Tanya approved the five-file signing-preparation phase on October 9, 2026
(America/New_York). This increment prepares code and a PR. It does not authorize
credential creation, activation/dispatch, merge, Apple upload, auth changes or
public release. No App Store Connect API key is needed for this archive-only step.

### Workflow contract

`.github/workflows/questwell-ios-testflight.yml` accepts only a manual dispatch
on `questwell-dev`, with an exact 40-character `source_sha` equal to the event
revision and an explicit unused build number. Use Apple's three-component
format: first component 1–9999, second and third 0–99 (for example `1.0.1`).
Version remains `1.0.0`; it does not silently increment or upload a build.
The existing quality workflow runs before the credential-bearing job.
Before dispatch, also verify the Backend Harness and required reviews for that
exact source revision. There is no dependency or application-code change.

Signing is limited to the protected `ios-testflight` environment. Configure its
branch restriction to `questwell-dev` and founder review requirement before
adding secrets or enabling it. Verify these controls are available for this
repository/plan; do not silently substitute repository-level secrets or purchase
an upgrade. Set environment variable `IOS_SIGNING_ENABLED` to `true` only after
those controls are verified. The script rejects absent enablement or credentials.
The YAML environment name alone does not establish that protections exist.

GitHub requires the workflow to be registered on the repository's default branch
for initial manual dispatch. The default branch is `flutterflow`; this new file
is absent there. Activation remains blocked until a separately reviewed
workflow-registration change is approved. Do not
promote the development app or change the default branch just to expose a button.

### Credential contract and founder setup

Use GitHub repository **Settings → Environments → ios-testflight** after its
protections are configured and verified. Add the following as environment secrets;
never paste values in chat, commit files or attach private keys to a PR:

| Secret | Required content |
| --- | --- |
| `IOS_DISTRIBUTION_P12_BASE64` | Single-line Base64 of a password-protected `.p12` containing the Apple Distribution certificate and matching private key for `W5779VXQYR` |
| `IOS_DISTRIBUTION_P12_PASSWORD` | Password used to export that `.p12` |
| `IOS_APP_STORE_PROFILE_BASE64` | Single-line Base64 of an unexpired App Store Connect distribution `.mobileprovision` for `com.alreyva.questwell`, including that certificate |

A downloaded `.cer` without its matching private key is insufficient. Certificate
creation/CSR and profile download will be guided separately; no existing Apple
certificate should be revoked to complete this step. Account agreements and
access must be rechecked. The account remains Tanya's individual membership;
these settings do not transfer ownership to Alreyva.

The script generates a temporary keychain password on the runner. It uses only
the supplied certificate/profile and does not request automatic provisioning or
create Apple account resources. P12 and profile values are size/type checked;
secret values are stripped from child-process environments and credential command
output/arguments are excluded from error messages. Credentials are exposed only
to the signing step, after locked Dart dependencies are installed.

### Archive behavior and evidence

- Pinned macOS runner toolchain: Xcode `26.3` build `17C529`, iPhoneOS SDK `26.2`,
  Flutter `3.44.6`, CocoaPods `1.17.0`. Drift stops the run. Existing actions retain
  reviewed SHA pins; no new package, action or external service is added.
- Profile preflight rejects the wrong team/app, expired/wildcard/development/ad
  hoc/enterprise profiles and certificates lacking a matching valid identity.
- Manual signing settings are inserted only into Runner Release in the ephemeral
  checkout, avoiding global provisioning overrides on Pods. The original project
  bytes are restored in `finally`; the committed Xcode project stays unchanged.
- `flutter build ios --config-only --no-codesign` prepares `lib/main.dart`,
  `live_beta`, the existing decorator
  feature flag and source SHA. The live beta backend is functional for existing
  beta users, but its web-oriented auth return URL is not a verified native flow.
  `isolated_test` and `staging` cannot be selected through this workflow.
  Effective Xcode settings must match team/bundle/manual certificate/profile and
  decoded Dart defines. Direct `xcodebuild archive` and `-exportArchive` omit
  automatic provisioning/device-registration flags. This avoids Flutter 3.44.6's
  `build ipa` wrapper, which adds those flags internally even with an export plist.
- Export options are validated against the pinned Xcode help and force local
  App Store Connect export with manual signing, fixed version/build and no upload.
- Both archive and exported IPA are checked for registered identity/version,
  device platform, code-signature integrity, signed entitlements and matching
  embedded distribution profile. New app extensions fail pending separate review.
  A successful archive without a produced IPA is a failure.
- Cleanup restores the project and deletes the installed profile and temporary
  keychain. Temporary files are removed on normal success/failure; forced runner
  termination relies on GitHub-hosted VM disposal. Never run on a self-hosted Mac.
- Only `build/ios-signing-evidence/validation.json` is retained for seven days.
  It records source, versions, team, bundle, certificate fingerprint, profile UUID,
  build number and IPA SHA-256, with `uploaded: false`. No private material,
  archive or IPA is uploaded as an Actions artifact. A later approved upload
  workflow will build/validate/upload together; this preparation run is disposable.

### Validation limits and follow-up gates

`python3 tool/qa/ios_testflight_test.py` exercises trusted-dispatch and credential
boundaries, profile/certificate failures, temporary Release-only configuration,
archive/export rejection, safe process errors, and a synthetic complete
orchestration path plus import/build/export/signature failures and cleanup. The
workflow contract test uses the existing locked `yaml` package under `tool/ci`;
install it with `npm ci --ignore-scripts --prefix tool/ci` first. Fixtures are test
inputs only; passing them is not evidence of a real Apple signature or IPA.

Independent review of the final five-file diff and fresh PR CI are required.
This Linux workspace cannot exercise macOS keychain, Flutter/Xcode signing or
Apple processing. Credential validity, protected environment setup, initial
workflow registration, a real signed archive, native authentication, privacy
manifest/API review, upload/export compliance and physical-device acceptance
remain unverified. No RLS, database, Edge Function or auth change is included.

Existing native reproducibility risk: `ios/Podfile.lock` is not committed. Dart
resolution is locked; CocoaPods' transitive resolution is not. The first real
archive must capture/review that resolution before a separate upload phase; this
increment does not silently claim native dependency reproducibility.

Rollback: revert this five-file signing-preparation increment in a reviewed PR.
Disable the `ios-testflight` environment variable if configured. Preserve the
merged Apple identity and registered app; no distributed build is affected.

### Official references checked October 10, 2026 UTC

- GitHub certificate/profile secrets and temporary keychain commands:
  https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications
- Manual dispatch registration requirement:
  https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow
- Pinned Flutter archive command implementation:
  https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_tools/lib/src/commands/build_ios.dart
- Flutter archive/export flags and build-number overrides:
  https://docs.flutter.dev/deployment/ios
- Apple profile structure, entitlements and signature validation:
  https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles
  https://developer.apple.com/documentation/technotes/tn3161-inside-code-signing-certificates
- Xcode 16+ provisioning-profile directory:
  https://developer.apple.com/documentation/xcode-release-notes/xcode-16-release-notes
- Runner toolchain inventory:
  https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md
