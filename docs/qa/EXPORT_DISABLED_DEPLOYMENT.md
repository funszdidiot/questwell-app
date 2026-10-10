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

Deployment verified 2026-10-10: production version 1, verify_jwt=true; all four
retrieved files match tested source. Missing/malformed bearer returned 401;
public-anon request returned generic disabled 503 with no-store; unlisted origin
returned 403. All PR #138 checks passed; merged at b7143ea72e4e6d93ac23ba8ecad7f6cd4e46be55.
Artifact SHA256: d4a433a809ebd141ea33de9c8484546dd1e17e6abbed6f2b69adbb0dfd229f2d.
These probes did not export private data or establish authenticated download acceptance.

