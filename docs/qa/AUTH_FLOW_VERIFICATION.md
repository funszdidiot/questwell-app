# Signup and recovery readiness — 2026-10-01

## Observed

- Public Auth settings: signup enabled, email provider enabled, email confirmation
  required (mailer_autoconfirm=false).
- Existing public.handle_new_user trigger creates the profile and starter gear.
  The form's additional UsersTable.insert was redundant and could fail after
  successful signup when a session is returned. It has been removed.
- Invalid recovery-token probes with both the Questwell root and recovery query
  return URLs redirected to http://localhost:3000 with otp_expired. No actual
  token, password, user account or email was used in these probes.
- Dashboard URL configuration requires sign-in in the available browser; the
  connected Supabase tools do not expose Auth URL configuration.

## Implemented

- Signup handles session-present and confirmation-required responses distinctly.
  Server errors no longer produce the ambiguous check-your-email success text.
- Confirmation redirects to https://funszdidiot.github.io/questwell-app/.
- Recovery redirects to https://funszdidiot.github.io/questwell-app/?recovery=true.
  Both use the deployed root so GitHub Pages can load the Flutter application.
- Startup captures callback flags before the SDK consumes its URL fragment.
  Recovery/failed-link landings show the account form even if a session exists.
- Expired/invalid recovery links cannot update a password with a stale session;
  the form offers a new reset link. No tokens or remote error descriptions are
  retained in the callback flags.
- Auth operations use the existing bounded, non-retrying write wrapper.
- Added auth widget regression tests and the existing network suite to CI.

## Required configuration (pending dashboard access)

Site URL: https://funszdidiot.github.io/questwell-app/

Allow the exact confirmation and recovery return URLs above. Preserve unrelated
existing authorized entries; do not add broad wildcard domains. Keep email
confirmation enabled. Check email templates use the confirmation URL or intended
redirect. Inspect SMTP delivery configuration without exposing credentials.

QUESTWELL_AUTH_RETURN_URL is a Dart compile-time override for a future approved
host. The default is the current development app, not a new public launch.

## Acceptance still required

1. Verify invalid links return to Questwell after the dashboard correction.
2. Use a dedicated test inbox for normal signup; receive and open confirmation,
   then sign in and verify exactly one profile and starter-gear grant.
3. Request recovery, receive/open the message on the target device, choose a new
   password, sign out, verify old password fails and new password succeeds.
4. Reuse the consumed link and confirm clear invalid/expired-link recovery.

Automated fakes do not prove SMTP delivery, redirect configuration, or an iPhone
email roundtrip. Do not mark those checks complete until exercised. Do not change
the founder's password or create test users by SQL as a substitute for signup.
No merge, external beta, or launch authorized.

## Verified build and remaining access blocker

Code commit: 6a07cbb9a03d0c64df8f7e4669ed90c05784b58e.
Flutter Check 36950587563 and Preview 36950587545 succeeded. Nine auth
regression cases and the three existing network cases run in CI. The auth cases
include entering from the root email callback, not only from the named form route.
Live browser check passed: invalid email landing -> Request a new reset link ->
email-only reset form -> Back to sign in. No email or password was submitted.

Dashboard access attempt: founder selected ChatGPT, then Google, then passkey.
Google displayed a passkey failure (Something went wrong / proximity and Bluetooth
message). Stopped automated credential entry. Supabase URL configuration has NOT
been changed; real signup/confirmation and password-recovery delivery remain open.
Security advisor still reports the previously known leaked-password protection
warning; this turn made no schema, RLS, SMTP or Auth-policy changes.

## URL configuration resolved — 2026-10-01, after founder sign-in

Founder confirmed dashboard sign-in. Saved Site URL as
https://funszdidiot.github.io/questwell-app/ and added only these two redirect URLs:

- https://funszdidiot.github.io/questwell-app/
- https://funszdidiot.github.io/questwell-app/?recovery=true

Dashboard shows the saved values and two allowed URLs. Repeated the two invalid
recovery-link API probes: both now return HTTP 303 to the intended Questwell URL
with otp_expired, rather than localhost. No account or password was changed and
no email was sent by the probes. This supersedes the earlier URL-access blocker.

Email settings inspection: custom SMTP is disabled; Supabase uses default email
templates. Supabase's current SMTP guide says its default service only delivers
to project-team addresses. External tester signup/reset delivery therefore remains
blocked until a transactional email provider and verified sender are configured.
Do not add testers as project administrators to work around this restriction.
Source: https://supabase.com/docs/guides/auth/auth-smtp

Next needed input: Questwell sender domain and existing email-provider account,
or authorization to set up a chosen provider. Keep email confirmation enabled.
Real signup/confirmation and password-reset email roundtrips remain unverified.
