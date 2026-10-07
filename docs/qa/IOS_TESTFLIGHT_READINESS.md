# Internal iOS TestFlight preparation

Status: toolchain change proposed; no signed archive, TestFlight upload or iPhone
acceptance is established. Overall release GO remains unchanged.

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

## Remaining stages and evidence

1. Verify Apple Developer Program enrollment is active and App Store Connect
   access is available. Account creation alone does not prove enrollment.
2. Confirm the intended signing team and registered app identity. Source currently
   uses `com.mycompany.projectmomentum` and the display name `Project Momentum`.
   Do not rename either or choose a team without the founder's scoped decision.
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

No account, credential, auth policy, identity, entitlement, backend, economy or
locked artwork is changed by this first increment. Existing feedback attachment
and release-hardening work remains tracked separately.

## Review and validation

Independent AI review is required on the exact final change. CI must exercise
the pinned Xcode/SDK preflight and unsigned compile, plus existing required
checks. At proposal creation these checks have not yet run. Record the actual
run/head evidence in the PR; never carry forward Xcode 16.4 success as 26.3 proof.

Rollback: revert this two-file change through a reviewed PR. Doing so restores
the prior compile gate but reopens the Apple upload-toolchain gap; it does not
make the prior compiler eligible for TestFlight. No distributed build is affected.

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
