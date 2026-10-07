# Explicit build environments — B02 foundation

The prior client always selected the shared live beta Supabase project and had
an independently overridable auth return URL. Tests and unspecified builds could
inherit that project without an explicit choice.

Builds require `QUESTWELL_ENVIRONMENT`. Three explicit profiles exist:

| Profile | Backend | Auth return | Intended use |
| --- | --- | --- | --- |
| `live_beta` | Existing beta project, unchanged public anon key | Existing GitHub Pages app | Explicit development preview deployment |
| `isolated_test` | Loopback port 1 with a deliberately invalid public key | Loopback port 1 | Injected unit/widget tests; never real Auth/API integration |
| `staging` | Existing synthetic-only staging project | Proposed `/questwell-app/staging/` callback | Non-deployed acceptance candidate; see `STAGING_CLIENT_ACCEPTANCE.md` |

Missing, misspelled and `production` selections fail before SDK
initialization. No fallback to beta exists. The URL, public key and auth return
are selected together; the old independent `QUESTWELL_AUTH_RETURN_URL` override
is removed. No session store, project, key, auth dashboard or redirect allowlist
is changed. The live profile uses the same host and therefore the same SDK
session storage namespace. Tests verify the existing JWT contains only the
public `anon` role and the expected project reference.

CI runs:

    flutter test --dart-define=QUESTWELL_ENVIRONMENT=isolated_test

Both web preview builds explicitly pass:

    --dart-define=QUESTWELL_ENVIRONMENT=live_beta

Ordinary `flutter test` without the isolated selection intentionally fails the
configuration regression, preventing accidental implicit selection. Standalone
builds can compile without a selection but show the startup recovery screen;
compilation is not evidence of a usable configured release. Android signing
fixtures are compile/signing checks only, not runnable release acceptance.

The staging backend has since been provisioned separately, but its new client
artifact is NOT deployed or a completed B02 release gate. The approved
GitHub-hosted disposable backend harness still owns isolated synthetic Auth/REST
integration tests. Hosted staging and native/production targets require actual
platform callback verification; do not relabel the beta project as staging.
No custom native auth scheme is introduced. Current HTTPS callbacks are preserved.

Tests cover missing/invalid/unapproved names, explicit isolated runner selection,
public key/project consistency and separation of backend/key/return URL. Existing
auth callback tests now expect the isolated return URL. Local and CI results will
be recorded in the PR. No credentials or paid resources are requested here.

Rollback must keep the explicit build arguments paired with the matching client
revision. Reverting to implicit live selection would reopen the recorded risk.

Official Dart environment-declaration guidance was checked October 6, 2026:
https://dart.dev/libraries/core/environment-declarations . `String.fromEnvironment`
is used in a const context and Flutter workflows use `--dart-define`.
