# Decorate Hearth — candidate

Tanya approved the independent furniture review and directed implementation on
October 8, 2026 (Chicago). Preserve locked avatars and artwork. Furniture scale
remains family-based; room plans change anchors, not body or sprite size.

## Behavior

- Home opens Decorate Hearth: owned eligible decorations, accessible position
  buttons and matching scene markers, replacement confirmation, preview, Undo,
  Save and Cancel/discard confirmation.
- Only Save writes. One transaction applies the displayed room and stores the
  outgoing and incoming room layouts. Other unsaved room previews are not saved.
- A room switch recalls that room's last saved layout; first-time rooms inherit
  current decor. Undo restores both layout and in-session room memories.
- Ownership, profile/slot, class and supporting-furniture rules are enforced
  server-side. Large back-left furniture plus the left chair is flagged as crowded.
  Existing equipment is not automatically moved or deleted by installation.
- Expected current layout plus revision reject stale saves. Profile and inventory
  locks serialize writes. Unknown save outcomes keep the preview but disable retry
  until reopening; no automatic write retry is added.
- Stored layouts belong to auth.uid(), have no direct client table grants, use RLS,
  and cascade when the application account is deleted. No purchase or reward change.

## Activation boundary

`QUESTWELL_DECORATE_HEARTH` defaults false. The button, new geometry and upgraded
placement service are dormant until the new RPCs have been installed and verified.
The root migration is a candidate forward payload, not a deployable history chain.
Do not enable the flag against a server without the matching functions.

The existing G3 live-database hold in `supabase/README.md` requires scoped rollout
approval. This candidate adds one private table and four functions. Installing it
does not rewrite inventories; users choose Save to apply their own layouts. Prepare
a guarded forward rollout with current schema/history/backup checks; do not use
root migration replay/reset or reuse unrelated rollout credentials.

## Evidence and outstanding checks

- 12 focused draft/widget/layout tests pass with the flag enabled, including
  normal and 200% text, save/cancel, unknown outcomes, undo room-memory and scale.
- Actual widget captures: `build/decorate-hearth/decorator-{390,320}-{overview,spots}.png`;
  these are synthetic fixtures, not signed-in evidence. Independent source and
  pictured Astral visual review approved the feature-disabled candidate.
- The disposable backend harness applies the exact candidate, exercises atomic
  per-room recall and invalid/stale/foreign/class/retired/duplicate/dependency
  requests, verifies privileges and rolls everything back before recovery tests.
- CI pending. Each background needs rendered
  acceptance before activation; initial captures cover Astral Sanctuary only.
- Add saved-layout coverage to operational export/recovery procedures before
  broad rollout. Live migration, delivered browser and physical-device acceptance
  remain pending. No new art lock or production promotion is established.

Rollback: disable the feature flag; keep stored layouts and ownership intact.
Do not drop saved user layouts as a routine rollback.
