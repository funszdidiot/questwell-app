# Privacy-restricted monitoring

Status: implementation candidate; NOT a monitoring gate pass.

The founder approved free Sentry monitoring. This change pins the official Dart
`sentry` package to 9.30.1, uses a private SentryClient (no global integrations),
and sends only five fixed diagnostic codes with validated commit SHA,
environment, platform enum, event ID and timestamp. The SDK envelope identifies
its own package/version. No native crash collection, stack traces, breadcrumbs,
user/session identifiers, request URLs, screenshots, view hierarchy, replay,
tracing, log capture or disk persistence is installed. Network delivery inherently
reveals the connection IP to the provider; the separately verified project setting
must continue to prevent IP storage.

Startup and Flutter/platform failures report fixed codes without passing their
original errors. Existing local handlers and startup error propagation remain.
Each process attempts each code once, with a five-second caller timeout. A timeout
does not cancel the transport; no automatic retry is requested by this service.
The result distinguishes disabled, suppressed, accepted and unavailable. Accepted
means SDK transport acceptance, not proof an event appears in the dashboard.

## Configuration and rollback

Reporting remains disabled unless all three build defines are valid:
`QUESTWELL_SENTRY_DSN`, `QUESTWELL_BUILD` (7–40 lowercase hex commit characters),
and `QUESTWELL_ENVIRONMENT` (`live_beta` or `staging`). Unit-test builds remain
network-disabled. A DSN must be HTTPS on a Sentry organization ingest hostname,
with a 32-character public ingest key and numeric project ID. No secret token is
needed or stored. This PR adds no DSN and changes no deployment workflow.

Rollback: remove the DSN build define and rebuild, or revert this PR. No database
migration, auth change, economy change or production promotion is involved.

## Required evidence before activation

- Run all monitoring tests, analyzer/format gate, full Flutter and Chrome suites,
  native builds and independent review on the final revision.
- Verify free-plan/privacy settings and the exact project DSN in the dashboard.
- Configure a development build only, send the fixed `probe` code through the
  reporter, and verify its event ID, approved fields and absence of attachments.
- Prove a real application error reaches the same project from the served build.
- Keep physical-device/native crash coverage limitations explicit: this is scoped
  Dart error reporting, not automatic native crash reporting.

Tests inspect an actual SDK envelope using an in-memory transport, inject
sensitive fields before the final filter, check invalid destinations/metadata,
concurrent deduplication, disabled states and transport failure behavior.

API verification: official pub.dev 9.30.1 archive and API sources,
https://pub.dev/packages/sentry/versions/9.30.1 and
https://docs.flutter.dev/testing/errors. Archive SHA256:
40a247686af64e497df29ab0de1303a20ca55a2e3c7c7e39b989fac47dcadf84.
All transitive requirements already exist in the locked dependency graph; CI's
empty-cache enforced-lockfile resolution must still verify the updated lockfile.

Current access blockers: automatic approval review denied the Sentry browser
origin, stating no trusted authorization for the private account. Do not work
around that block. It also blocked local Flutter setup due to a possible cloud
metadata request. No live event, dashboard receipt or local Flutter pass is claimed.


## Development activation — October 7, 2026

The founder directed completion of approved gates without repeated approval.
Sentry browser access now works. The exact existing public ingest DSN was read
from Questwell project 4512216571379712 in Momentum Labs; no new key or account
permission was created. Project settings still mandate scrubbing and prevent IP
storage; source fetching remains off. No SDK or dependency versions change.

Only `questwell-preview.yml` supplies that public DSN. Normal/native/PR builds
remain disabled without configuration. Preview `?review=monitoring-check` sends
a fixed probe, then deliberately raises an error inside the real backend startup
try/catch before Supabase is initialized. The normal safe startup failure screen
is expected. No sign-in, account reads/writes, user text or screenshot is used.
This is controlled error-delivery evidence, not evidence of a spontaneous crash.
The regression exercises that startup path with the actual Sentry envelope and
an in-memory transport; its pending CI result must be recorded separately.

Verification: open the delivered preview check once, then inspect both `probe`
and `backendStartup` in Sentry. Match exact release revision, live_beta environment,
web platform, event timestamps and inspect event data for no account/request/
exception/breadcrumb/attachment payloads. SDK transport acceptance alone is not
receipt. Standard preview loading must still show normal startup/sign-in.

Rollback activation: remove the workflow DSN env/build define and rebuild the
development preview. Remove the preview check branch if no longer needed.
No production promotion, database or auth configuration change is included.
