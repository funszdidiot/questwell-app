# Seasonal and Limited Release Playbook

## Goal

Make seasonal drops fast and repeatable without degrading Questwell's avatar methodology or core visual identity.

## Release brief

Every collection starts with:
- collection name and theme;
- release window/availability;
- included item types;
- class/body eligibility;
- palette/material/motif direction;
- whether each item inherits an existing locked template;
- economy/price decisions, if any, separately approved when needed.

## Template-first production

For every wearable:
1. Map it to a locked garment family.
2. Reuse that body's exact geometry and registration.
3. Change only approved surface treatment: palette, fabric, trim, embroidery, motif and small non-structural ornament.
4. Produce each supported body from its own locked body-specific template.
5. If the concept requires a new silhouette or equipment interaction, stop for founder approval and establish a new template before scaling it.

## Limited-release states

Use the shared production lifecycle: **QUEUED → BUILDING → QA → DEV DEPLOYING → DEV DEPLOYED → TANYA REVIEW → LOCKED**, plus **BLOCKED** when appropriate.

Track release availability separately as planned, scheduled, available or archived. Brief approval and immutable art/template approval are recorded separately from integration status; neither implies deployment or launch.

Availability dates do not authorize launch by themselves.

## Required QA

- correct body and class eligibility;
- exact canvas/registration;
- no anatomy drift;
- no stray/opaque pixels;
- clean shoulders/neck;
- cuffs and hands;
- waist/hips;
- crotch/inseam and leg coverage;
- heel/sole coverage;
- rear/front ordering;
- equipment compatibility;
- inventory/Market visibility;
- equip/unequip and class restoration;
- mobile/Safari/web framing;
- Flutter Check, regression tests and preview.

## Archive behavior

Limited items may become unavailable for purchase while ownership history remains intact. Never destructively remove historical ownership merely because a release ends.

## Batch production

A collection may be generated as a batch only after its template mappings and brief are approved. Any item that fails geometry/integrity checks leaves the batch and returns to fitting; passing siblings need not be reopened.
