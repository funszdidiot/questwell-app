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

Pinned file_picker 8.1.7 writes bytes on iOS/Android but returns only a destination
path on desktop; the adapter handles those differences. Its iOS implementation
stages in Documents. A unique operation filename avoids collisions, and finally
removes that source on success/cancellation/error unless it is the explicitly
selected destination itself. Process termination during the native dialog can
leave that source behind; physical-device acceptance and that lifecycle case
remain required before enabling live mobile exports. No package was upgraded.

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

CI, hosted-client result, deployment and physical/browser save acceptance: pending.
Production activation must be a separate reviewed change after acceptance.
