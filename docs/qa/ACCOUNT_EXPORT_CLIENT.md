# Account export client — staging acceptance

The account settings page offers Download my data only in the existing staging
environment. Production and live beta remain gated, and production export-account
continues to use its fixed-disabled entrypoint. No production activation or
database change is part of this work.

Prepare makes one authenticated empty POST through the existing HTTP 1.4.0
dependency. It supplies no owner, destination or durable token URL and never
retries automatically. It validates the eight record groups, owner isolation,
referenced attachment completeness and SHA256 hashes before enabling Save.
Accepted responses are limited to 40 MiB; attachments retain the server's 5 MiB
per-file, 25 MiB total and 100-file limits. HTTP 1.4.0 streams browser responses
using Fetch and cancels the reader when the bound is exceeded. Larger exports
fail without a partial download.

Prepared bytes expire after two minutes. Closing the screen, discarding, saving,
cancelling or a failed operation clears the held buffer. Session identity is
checked after retrieval and before saving; refreshing a token within the same
session is allowed. The UI locks repeat requests and local account actions while
an operation is running. Errors contain fixed messages, never response bodies.

Save requires a fresh tap, preserving browser user activation. The web 1.1.1
adapter uses a JSON Blob and a temporary object URL, removed after handoff; the
URL is revoked after 30 seconds. The browser cannot confirm that the user kept
the file, so the message says only that a save request was sent.

Android and desktop retain the pinned file_picker 8.1.7 adapter. iOS now uses a
small native adapter with Apple's `UIDocumentPickerViewController(forExporting:
asCopy: true)` (minimum iOS 14, already the project's deployment target). It
stages the verified bytes in `Library/Caches/QuestwellAccountExport`, using an
atomic write with complete file protection. Caches is excluded from device
backup by iOS. The picker copies the file to the user's chosen provider; its
returned destination URLs are never passed to cleanup.

The native adapter recovers its own cache directory on launch, before each save,
and after success/cancellation. It rejects concurrent saves and unexpected
symlink roots. A process exit while the picker is open leaves only a private
cache source; the next launch removes it. If storage is inaccessible on launch,
cleanup is retried before another save and must succeed. A cleanup failure
returns a fixed error with no path or private content. Restart recovery cannot
run while the app is terminated: it does not claim immediate erasure after a kill.

For upgrades from the previous staging implementation, launch recovery also
removes direct regular files in private Documents with exactly the old
`questwell-account-export-<24 lowercase hex digits>.json` generated name. It
never follows links or descends into directories. This compatibility cleanup is
disabled if any document-sharing/browser flag is enabled. New exports never use
Documents. No package or platform minimum was upgraded.

The macOS CI job compiles and runs the actual Swift storage helper against
synthetic files. It checks a separate process exiting without cleanup, recovery
by a fresh instance, copy/cancel cleanup, idempotency, untouched user copies and
unrelated files, symlink boundaries, invalid sizes and legacy compatibility.
Flutter tests check the iOS channel's bytes, completion/cancellation, safe errors,
missing adapter and stale-session rejection. UIKit is compiled by the existing
unsigned iOS release job. These tests do not establish physical-device acceptance.

Apple API references:
- https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller/init(forexporting:ascopy:)
- https://developer.apple.com/documentation/foundation/using-the-file-system-effectively


API verification used the published package source archives for file_picker
8.1.7, web 1.1.1, gotrue 2.12.0 and functions_client 2.4.2. Source entrypoints:
file_picker/lib/src/file_picker.dart and ios/Classes/FilePickerPlugin.m;
web/lib/src/dom/fileapi.dart and url.dart; gotrue/lib/src/types/session.dart.

Tests cover empty authenticated request, no signed-out network access, session
changes, same-session token refresh, HTTP failures, malformed/incomplete/foreign
records, attachment corruption, size limits, concurrent requests and timeouts.
Widget tests cover large text, explicit prepare/save, repeated taps, navigation
away, cancellation, expiry, discard and safe errors. The authenticated CI probe
uses only the existing synthetic staging account, validates the actual Dart
client's export, rate denial, local prepared-data invalidation and revoked-token
denial. It logs no private response and saves no export file.

Previous staged-client delivery (PR #140): 1,102 Flutter and 438 Chrome tests
passed; authenticated staging workflow 38065551732 verified owner isolation,
attachment integrity, throttling, logout invalidation and revoked-token denial.
Development revision 1e2e55620ee80101786dbf9475fd353b35efb9d9 was published and
its served staging bundle hash verified. Recovery follow-up CI evidence belongs
to its PR and does not replace phone acceptance.

## Phone acceptance still required

Use only a staging account with synthetic data. Never send an exported file or
token in chat.

1. On iPhone Safari, open the staging site, sign in, then Account settings →
   Download my data → Save data file. Confirm the JSON exists in Files and opens.
2. Cancel a second save. Confirm the screen remains usable; prepare again after
   the rate-limit wait. Discard or leave the screen and confirm Save is cleared.
3. In a native iOS **staging** build containing this follow-up, repeat save/cancel
   for On My iPhone and iCloud Drive. Force-quit while the native save dialog is
   open, relaunch, then prepare and save again. Confirm an earlier saved copy
   remains. An unsigned CI build is not an installable TestFlight delivery.
4. Native sandbox inspection in a development test run must confirm the dedicated
   cache has no source after save/cancel or relaunch recovery. Automated Swift
   filesystem tests cover this boundary; a user-visible Files check alone cannot
   prove it.

Record device, iOS/browser version, build revision, destination provider and
pass/fail for each step. No device outcome has been reported yet.
Production activation must be a separate reviewed change after acceptance.
