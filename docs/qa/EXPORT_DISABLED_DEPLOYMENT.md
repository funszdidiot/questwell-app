# Production export holding deployment

Scope: deploy export-account with disabled.ts and verify_jwt=true. The new entrypoint
does not read any environment flag and cannot construct a backend. It returns no
account data, rejects browser origins, and has no automatic activation path.
The existing tested handler, backend and snapshot functions are unchanged.

Source files: disabled.ts, disabled.mjs, handler.mjs and ../_shared/data_policy.mjs.
No external package or new credential is introduced. No active production user
session is needed for the disabled-state probe.

Validation before deployment: existing endpoint tests and four holding-state
tests. After deployment: retrieve deployed files and verify exact content and JWT
gateway setting; test missing/invalid-token denial and a public-anon-token request
returning only the disabled response. Public anon tokens are not user sessions;
this is not proof of an authenticated production download.

Activation and app download/save acceptance remain separate work. Rollback:
redeploy this fixed-disabled entrypoint with gateway JWT verification enabled.
Retain additive database schema; no deletion or history repair.

Deployment result: pending.
