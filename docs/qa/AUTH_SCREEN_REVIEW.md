# Questwell sign-in design review

Requested 2026-09-29 after founder rejected the original template screen.

- Gold Questwell wordmark and approved Hearth background.
- Centered responsive parchment form with readable fields and 52 px primary action.
- Enter the Hearth, account creation mode, password visibility and autofill support.
- Inline validation, busy state and persistent failure feedback.
- Password reset request and password-recovery event route to a new-password form.
- Existing sign-in/signup service and profile insertion preserved; no database or auth-policy changes.
- Browser title and description changed from Project Momentum to Questwell.

Validation: build checks and visual review required. Real login, confirmation email delivery and reset-link roundtrip remain unverified; no emails or passwords changed during visual review. Recovery redirect allowlist remains a project configuration dependency.

## Sign-out access

Added a persistent, labeled Sign out action at the bottom of Adventurer. It remains available during profile loading/errors, calls the existing auth sign-out service, clears stale redirects, and returns to the redesigned sign-in route. Failure shows retry feedback. Authenticated session termination still requires an account-level check. Founder approved the sign-in design (“Perfect”).
