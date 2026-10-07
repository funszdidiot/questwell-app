# Staging client candidate — October 7, 2026

PR #66 extends the PR #64 baseline described below with reviewed staging hash
routing, preference separation, callback cleanup, location guards and hosted
packaging. It retains the compile-time profile selection, exact public anon key,
artifact checks and retained candidate. Deployment and actual account acceptance
must be recorded separately; source integration alone does not close this gate.

## Historical PR #64 baseline

The following describes the original retained-only artifact. PR #66 behavior is
documented above and in STAGING_APP.md. Neither source change proves deployment
or actual account acceptance.

Status at PR #64: QA candidate, not deployed and not a release GO.

The explicit `staging` profile selects the existing synthetic-only project
`hpjzfytwivlpsdhiupyd` and proposed callback
`https://funszdidiot.github.io/questwell-app/staging/` as one fixed unit.
The public legacy anon key was read from that exact project's enabled keys;
it is used for compatibility with the pinned client, not privileged access.
No account password, session, service-role key or other secret is included.
The `live_beta` and `isolated_test` profiles are unchanged. Unknown profiles
still fail closed; tests always execute with `isolated_test`.

The existing quality workflow now also builds the real `lib/main.dart` for
staging. It does not use visual fixtures as acceptance evidence. The artifact
validator requires the staging project and rejects the live project in compiled
JavaScript, checks the base path, adds a visible synthetic-only notice, and
records environment, exact Git revision and bundle SHA256. The artifact is
retained for seven days. No DSN is supplied: monitoring remains disabled.

`questwell-preview.yml` is deliberately unchanged. The artifact is not uploaded
as `github-pages`, no deploy job is added, and no existing beta route is replaced.
The callback URL is a proposed deployment target, NOT evidence it exists or is
allowlisted. Do not distribute the artifact as a signed native release.

## Current verified backend facts

Read-only connector checks on October 7 confirmed ACTIVE_HEALTHY, two synthetic
Auth users, zero sessions, 52 cosmetics and 13 public RLS-enabled tables.
These counts do not prove user isolation or actual application behavior. No
Auth rows, passwords, sessions, schema or live-user data were changed.

## Next acceptance steps

1. Pass full CI and independent code review on the final candidate.
2. Publish staging separately only after reviewing route fallback and cache
   isolation; preserve the current beta route. A subpath shares browser origin
   storage and is not a security boundary. Use synthetic accounts only and
   verify both auth and application draft/preferences isolation explicitly.
3. Set and verify the exact staging Site URL/redirect allowlist through authorized
   dashboard access. Do not modify live callbacks or weaken confirmation/signup.
4. Sign in as each existing QA account through secure credential handoff; never
   paste passwords/tokens into chat, commits, logs or public issue comments.
5. Verify onboarding, account switch, quest/reward idempotency, bosses, purchases,
   equip/reload, feedback attachments/retry and poor-network behavior. Use only
   newly-created, explicitly authorized synthetic fixtures for deletion tests.
6. Record actual served revision, request destination and observed acceptance.
   Verify real uploaded file bytes and timed isolated restore separately.

The available Supabase connector cannot configure Auth redirect URLs or perform
an interactive QA-account sign-in. That needs approved browser access/secure
handoff. Do not mint sessions from SQL or use service-role access as a substitute
for signed-in acceptance. Sentry access, inbound support delivery, product-policy
decisions, backup recovery and signed-device acceptance remain separate gates.

Official redirect configuration guidance checked October 7:
https://supabase.com/docs/guides/auth/redirect-urls . Exact redirects must match
the allowlist; the Site URL is the fallback used by confirmation/recovery flows.
The current changelog was checked; this change upgrades no SDK or database.

Rollback: revert this profile/test/artifact increment. No deployed beta build,
database or existing account needs restoration because this PR changes none.
