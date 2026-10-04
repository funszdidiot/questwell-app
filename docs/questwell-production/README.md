# Questwell Production System

This directory is the governing source of truth for Questwell production: avatar assets, development integration, QA, architecture/scalability work and founder review. Current explicit founder instructions govern any conflict with older notes.

## Authority order

1. Founder-approved locked template registry in `LOCKED_TEMPLATE_REGISTRY.md`.
2. Body-specific fit standards and machine-readable references named by that registry.
3. `VISUAL_BIBLE.md` and `AGENT_OPERATING_RULES.md`.
4. Class/collection specifications.
5. Candidate/review documents.
6. Historical drafts.

A historical asset, review page, or older candidate never overrides a locked template.

## Core method

Questwell uses a paper-doll system. Approve the body first, lock anatomy, then fit garments to that body. Never alter anatomy to solve a garment problem. Each body type is fitted independently; do not scale one body's clothing onto another.

Production state is:

**QUEUED → BUILDING → QA → DEV DEPLOYING → DEV DEPLOYED → TANYA REVIEW → LOCKED**

Use **BLOCKED** for an actual impediment, with the precise reason and smallest next action. Active visual development is not itself a blocker. Work proceeds through development integration and technical/runtime verification; a file, commit or successful build does not complete a task.

Production status and immutable art/template lock are separate fields. A founder-locked body or garment may still be BUILDING or QA while it is being integrated. Its lock never permits anatomy or template changes. TANYA REVIEW is used when a genuine decision is needed; do not manufacture a new approval requirement for routine integration of an already approved template. LOCKED records completed, technically verified work with any necessary founder decision recorded.

Founder visual approval locks geometry. Later color/pattern/detail variants inherit that geometry unless Tanya explicitly reopens the template.

## Required companion documents

- `PRODUCTION_DASHBOARD.md` — current work, status, evidence and precise founder actions; mirrored by `web/production-dashboard.html` in the development app
- `VISUAL_BIBLE.md`
- `LOCKED_TEMPLATE_REGISTRY.md`
- `AGENT_OPERATING_RULES.md`
- `SEASONAL_RELEASE_PLAYBOOK.md`
- `VISUAL_QA_CHECKLIST.md`
- `LESSONS_LEARNED.md`

The repository, not chat memory, is the durable source of truth. When a new founder decision changes a standard, update these documents in the same development change.

## Delivery priorities

Complete the current avatar-production pipeline first. Continue with established high-priority structural/scalability work, then the queued UX issues. Preserve architecture boundaries throughout visual work. Do not defer core architecture protections merely to move artwork faster.

The development preview must pass the reusable Flutter Check workflow before the build/deploy jobs can run. The gate covers asset integrity, Node checks, analyzer and discovered substantive Flutter tests. The generated `test/widget_test.dart` counter placeholder is explicitly excluded because it contains no behavioral assertion. Adding a real regression test under `test/` must automatically include it in CI. Runtime verification remains a separate required step after deployment.
