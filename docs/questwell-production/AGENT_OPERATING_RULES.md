# Questwell Production Agent Operating Rules

## Mission

Standardize and automate Questwell visual production, development integration, technical/runtime QA, architecture/scalability work, seasonal/limited releases and documentation while protecting founder-approved visual standards.

## Default autonomy

The agent may autonomously:
- use locked templates to build body-specific variants;
- perform deterministic exports, registration, masking and layer assembly;
- make corrections necessary to match an already locked template;
- run visual-integrity scripts, tests, Flutter checks and previews;
- wire approved assets into development runtime paths and equipment policies;
- add non-destructive catalog metadata consistent with an approved release brief;
- maintain documentation, manifests, naming/versioning and review routes;
- fix obvious implementation drift where code contradicts a locked standard;
- iterate on technical defects without asking Tanya to reconfirm the established rule.

## Mandatory founder stop

Stop and ask Tanya before:
- establishing, replacing or reopening a visual template;
- making an aesthetic choice not determined by a locked template or approved brief;
- materially changing gameplay/product behavior, economy, pricing or progression;
- destructive/irreversible data or repository actions;
- purchasing/upgrading a paid service;
- an action requiring unavailable credentials or permissions;
- a manual FlutterFlow/device action that cannot be automated;
- production launch/promotion when founder approval is required.

Do not create a founder gate merely because CI passed or because a visual is still being actively developed. Tanya has explicitly said she will indicate when visuals are ready for final approval. A future template decision does not block independent approved work.

When a genuine stop is necessary, identify exactly what Tanya must decide or supply, why that specific work cannot safely continue without it, and the smallest action she needs to take. Continue other authorized work. Do not request routine implementation choices or reapproval of established permissions.

## Build behavior

1. Resolve body, garment family, class/collection and authoritative template.
2. Verify the template is LOCKED before derivative production.
3. Preserve body and geometry.
4. Produce candidate assets with deterministic naming and provenance.
5. Run automated integrity checks before visual review.
6. Integrate only to the development path unless promotion is explicitly authorized.
7. Verify renderer/layer composition, inventory/catalog, body/class eligibility, equipment policy, equip/unequip/restoration, persistence, relevant tests, development deployment and actual runtime behavior. Asset existence, a commit or a successful build alone is insufficient.
8. Present founder review only when a genuine aesthetic/approval decision remains.
9. On approval, update the registry and documentation in the same change.

## Never do these

- Do not modify anatomy to hide clothing errors.
- Do not stretch a female/neutral/male garment to another body and call it fitted.
- Do not treat generated concept art as production-ready.
- Do not overwrite a locked asset with an unapproved candidate.
- Correct stale policy only within the approved, semantically valid account-fit scope. An isolated approved asset or candidate renderer does not authorize account capability promotion.
- Do not switch between different foundations when clothing is equipped/removed. The same-body invariant applies across class changes and reload too.
- Do not declare something pushed because a file exists in GitHub; verify runtime routing.
- Do not merge/launch based only on Flutter Check or Preview.
- Do not reintroduce retired Pathfinder boots.
- Do not equip the grimoire by replacing avatar hands.

## Naming

Use semantic body/family/version names. Candidates increment versions. A locked asset keeps a documented canonical reference; later experiments never reuse its filename.

## Seasonal automation

Seasonal/limited work follows `SEASONAL_RELEASE_PLAYBOOK.md`. Template inheritance is the default. Novel silhouettes are exceptions and require a founder template decision.

## Production tracking and evidence

Maintain `PRODUCTION_DASHBOARD.md` and its development-app page with:

**QUEUED → BUILDING → QA → DEV DEPLOYING → DEV DEPLOYED → TANYA REVIEW → LOCKED**, plus **BLOCKED** when appropriate.

Keep immutable art/template lock separate from production integration status. An approved male v3 body remains locked while its ingestion or renderer integration is BUILDING. Do not reset or reopen its art lock because technical work is incomplete.

- QUEUED: scoped approved work awaiting execution.
- BUILDING: implementation, ingestion or active visual development.
- QA: automated checks and actual exported/composite review are under way.
- DEV DEPLOYING: required predeployment gates have passed and the development deployment is running.
- DEV DEPLOYED: the delivered development revision and actual runtime behavior have been verified.
- TANYA REVIEW: technically integrated work has a concrete genuine founder decision remaining.
- LOCKED: the work is integrated and technically verified, with required founder decisions recorded; any existing art lock is preserved throughout.
- BLOCKED: a real impediment prevents this work; record its evidence and precise next action without blocking independent work.

Record the revision, checks, deployed URL and runtime evidence before claiming completion. Distinguish passed checks from checks still pending. CI or a deployed dashboard is never evidence that an autonomous worker remains active after the session ends.

Prioritize avatar production, then Issue #6 Warding Lantern/Emerald Wayfarer Rug, then Issue #7 architecture/scalability before launch. Keep the two #6 catalog entries inactive and retain ownership until founder approval of the replacement visuals. Preserve modular renderer, catalog/eligibility, equipment and persistence boundaries; visual acceleration never overrides the core architecture.

Male v3/everyday v2 art remains locked while its dedicated fixed-body review is in QA and account rollout is queued. Do not promote it to account capability when unequip restores different legacy anatomy. Neutral Woodland remains candidate-review-only; existing female-only account support stays in force. Approved Everyday account support is female + neutral. No new founder request is required to correct these implementation violations.
