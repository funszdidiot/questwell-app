# Questwell Production System

This directory is the canonical operating layer for automated Questwell visual production.

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

`DRAFT -> FITTING -> QA READY -> FOUNDER REVIEW -> LOCKED -> DEV INTEGRATED -> VERIFIED -> PROMOTION CANDIDATE`

Founder visual approval locks geometry. Later color/pattern/detail variants inherit that geometry unless Tanya explicitly reopens the template.

## Required companion documents

- `VISUAL_BIBLE.md`
- `LOCKED_TEMPLATE_REGISTRY.md`
- `AGENT_OPERATING_RULES.md`
- `SEASONAL_RELEASE_PLAYBOOK.md`
- `VISUAL_QA_CHECKLIST.md`
- `LESSONS_LEARNED.md`

The repository, not chat memory, is the durable source of truth. When a new founder decision changes a standard, update these documents in the same development change.
