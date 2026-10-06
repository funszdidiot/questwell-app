# Seasonal gallery reconciliation

Reconciled PR #12 with development 5c8f443. Tanya granted standing approval for remaining development merges with AI review on October 5, 2026 at 22:04 America/New_York. This supersedes per-PR merge handoffs only; required checks, AI review, locked art and separate hosted/production gates remain.

The route syntax repair is retained. Market metadata/placement comes from merged PR #31. Registry wall art now retains wall render keys in the placement picker, including center art. The gallery uses shared locked body foundations and foreground identity rendering, never legacy base_male/base_neutral art. Its fictional outfit fixture reuses exact approved female v11, neutral v3 and male v2 Woodland overlays. No artwork is created or changed.

Wearable manifests are explicitly single_overlay_outfit. Layered robe/cloak reviews must use dedicated runtime compositors; this gallery does not claim to validate missing rear/collar/cuff layers. The fixture is not catalog activation or a new approved visual.

The historical wall-art SQL proposal is retained without applying it to a hosted project or replaying root history. The observed isolated baseline already includes wall_art_sprite in the registry constraint. G3 remains in force. Backend CI still validates that observed baseline and reviewed hardening changes in a disposable target.

Validation: manifest preflight and 19 local isolation/catalog tests pass. Fresh Flutter/backend CI and AI review are required before merge; no delivery claim yet.
