# Android release signing — R04 source safeguard

Release builds now select the existing private `release` signing configuration.
They must not silently use Android's debug key. Debug preview builds continue to
use the normal debug configuration. No application ID, namespace, SDK level,
dependency, signing identity or keystore changes are included.

The source regression failed against merge `0318773` because its release build
selected `signingConfigs.debug`. It passes with `signingConfigs.release`.
The native CI job builds the simulated preview in debug mode, then runs Android
Gradle's real `validateSigningRelease` task without `android/key.properties`.
Only the specific missing release `storeFile` failure satisfies that negative
control; unrelated build or tooling failures do not count as a pass.

## Remaining native gates

This source safeguard does not complete R04 or authorize distribution. Before a
real release, verify ownership of the package ID (currently
`com.mycompany.projectmomentum`) and the intended upload/app-signing keys with
Tanya. Her personal developer-account selection does not determine a certificate
or authorize replacing an existing identity. No key has been generated here.

Once separately approved, keep the keystore and `android/key.properties` private
and outside version control. The existing configuration reads `keyAlias`,
`keyPassword`, `storeFile` and `storePassword`; relative store paths resolve from
`android/app`. Use an absolute path to avoid ambiguity. Never paste passwords or
private keys into chat. Verify the signed AAB's certificate and package ID,
non-debuggable release configuration, and install/upgrade/auth links on a real
device. Store enrollment/verification and device access remain separate gates.

A debug build is not a release artifact. Do not restore debug signing to make a
blocked release build pass. Fix the release configuration or keep distribution
blocked. No APK/AAB is uploaded or distributed by this CI workflow.

Official reference checked October 5, 2026:
https://docs.flutter.dev/deployment/android#sign-the-app
