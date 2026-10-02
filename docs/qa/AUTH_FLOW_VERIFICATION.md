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
