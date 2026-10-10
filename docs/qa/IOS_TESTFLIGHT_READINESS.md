# Internal iOS TestFlight preparation

Status: registered identity alignment proposed; no signed archive, TestFlight
upload or iPhone acceptance is established. Overall release GO remains unchanged.

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
2. Review and merge this scoped identity PR only with founder approval. Confirm
   effective bundle/team settings again when creating the first signed archive.
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
