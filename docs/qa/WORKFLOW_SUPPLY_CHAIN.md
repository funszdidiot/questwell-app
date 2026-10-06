# C08 — Workflow supply-chain controls

Every repository-owned workflow action reference is pinned to a reviewed full
commit from the upstream repository. `tool/ci/action-pins.json` records the source
major tag and exact revision retrieved on 2026-10-06. The major versions remain
unchanged; no Flutter/application dependency upgrade is included. The existing
checksum-pinned Supabase CLI and scoped historical deployment guard remain intact.

The local Flutter wrapper disables both mutable nested cache actions in the pinned
upstream composite and uses explicitly pinned cache actions. SDK version remains
3.44.6. Its cache keys include platform, architecture and version; package keys also
include the committed pub lockfile. Pages packaging reproduces the upstream Linux
tar layout and uploads with a directly pinned action, avoiding that composite's
mutable upload dependency. Actual CI must verify the wrapper on Linux/macOS and
the Pages archive/deployment before this increment is called delivered.

All workflows default to `contents: read`, and checkout never persists credentials.
Only the preview deployment job has Pages/OIDC write permissions; it is restricted
to `questwell-dev`. The preview build has Pages read access. The existing guarded
Woodland apply job retains contents/checks read. No new live credentials or tokens
are created. Hosted branch/ruleset enforcement is the separate A08 gate.

## Asset proposal workflow

The old asset workflows automatically generated and pushed onto `questwell-dev`.
They now run only by manual dispatch on that trusted branch, with read-only tokens.
Sharp 0.34.5 and YAML 2.8.1 plus transitive packages are integrity-locked in
`tool/ci/package-lock.json`; `npm ci --ignore-scripts` is mandatory. A synthetic
2×2 image verifies the installed Sharp platform binary without touching art.

Each generator may change only its explicit output allowlist. It produces a
seven-day artifact containing a binary patch, base revision, output hashes and
review instructions. It cannot push, publish, activate catalog entries or lock art.
A reviewer/agent must apply that proposal to an isolated branch and open a normal
PR; full CI, AI review and any required founder visual approval precede merging.
No extra write-capable automation token is needed, and a workflow token cannot
silently create an unchecked PR. Locked neutral Woodland v3 cannot be replaced
merely because an old repair generator produces different bytes; any new repair
needs its own scope, version and applicable approval.

No asset-generation workflow is dispatched by this hardening change. Local tests
exercise binary proposal packaging in a disposable synthetic git repository,
including unexpected-file rejection and unchanged HEAD. This is workflow boundary
validation, not visual approval or an end-to-end generated-art PR acceptance.

## Enforcement and updates

`node tool/ci/workflow-security.cjs` parses every workflow plus the allowed local
composite, checks reviewed pins, token scopes, credential-free checkout, trigger
boundaries, nested cache opt-outs and asset output guards. Negative controls reject
mutable/unknown pins, privileged trigger forms, duplicate YAML keys, stored checkout
credentials, direct pushes and unpinned install commands. The shared Flutter gate
runs these checks for every PR and preview delivery. This policy is a scoped
configuration check, not arbitrary-shell analysis or proof that upstream packages
are vulnerability-free. Runtime images/SDK downloads remain upstream infrastructure.

CODEOWNERS records Tanya's repository owner account. It requests review; it does
not establish hosted required approval. Dependabot proposes weekly GitHub Actions,
CI npm and Pub updates against `questwell-dev`, with five open PRs per ecosystem.
Updates must preserve lockfiles and pass normal review; action updates also require
reviewing/updating the explicit pin manifest. No automatic dependency merging is
configured. Dependabot discovery requires this config on the repository default
branch; this development change alone does not claim the hosted scheduler is active.

Reference contracts checked 2026-10-06:
- https://docs.github.com/en/actions/reference/security/secure-use
- https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages
- https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference
- Upstream pinned `action.yml`/`action.yaml` files in the action pin manifest.
