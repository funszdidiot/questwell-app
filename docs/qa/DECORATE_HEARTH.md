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
  pictured visual review approved the feature-disabled candidate across all nine
  backgrounds for the chair/table/right-cabinet arrangement.
- The disposable backend harness applies the exact candidate, exercises atomic
  per-room recall and invalid/stale/foreign/class/retired/duplicate/dependency
  requests, verifies privileges and rolls everything back before recovery tests.
- CI pending. Other furniture combinations still need placement acceptance.
- Recovery rehearsals include the candidate private table and remembered-room
  data in the existing complete public/private schema backup and content hashes. Live migration, delivered browser and physical-device acceptance
  remain pending. No new art lock or production promotion is established.

Rollback: disable the feature flag; keep stored layouts and ownership intact.
Do not drop saved user layouts as a routine rollback.

## Prepared forward rollout — historical plan, approved below

The reviewed candidate is rendered offline by
`node tool/deploy/render-decorate-hearth.mjs`. It pins the source and catalog
query hashes and the metadata-only live snapshot in
`tool/deploy/decorate-hearth-reviewed-state.json` (55 migration records; target
`bdzcazkyypopbanbjnud`; new objects absent). It checks the whole prior schema and
history, locks the relevant catalog/inventory tables, adds only the new objects,
checks protected metadata and permissions, and refreshes the API schema cache.
Drift, postcondition failure, timeout and repeated execution are rehearsed only
in disposable CI. At preparation time no live SQL had been applied and no credential was created.

After scoped approval and a current verified backup, submit this exact rendered
SQL once using the migration-recording API under `decorate_hearth_layouts_live`.
Do not replay root migrations or repair history. If the outcome is unknown,
inspect schema/history and reconcile the recorded payload before any retry.
Verify the old 55 records remain byte-identical and exactly one new record stores
the rendered payload. After backend verification, enable `QUESTWELL_DECORATE_HEARTH` in the
development build and run its gates. Verify authenticated read/save and restored
arrangements on the development account before recording hosted acceptance. No production
branch promotion is included. On any mismatch leave the feature disabled.

## Approved live database rollout — October 9, 2026

Tanya explicitly approved the scoped rollout after PR #102 passed independent
review and all five CI workflows. Applied the exact guarded payload to
`bdzcazkyypopbanbjnud` with migration `20261009051815`, named
`decorate_hearth_layouts_live`. Payload SHA256:
`3a48d6e886444f0662fd807c8f892b39eb89af305f9ae52cae3d1ceb4c0dc504`.
Read-back confirms one matching recorded statement, the original 55 history rows
unchanged, empty initial layout storage, RLS enabled, authenticated RPC access,
and no anonymous RPC or direct authenticated table access. Existing inventories
were not changed. The verified backup evidence from October 8 remains within its
recorded 24-hour window. No new credentials or history repair was needed.

The development live-beta web build now explicitly enables the flag. Staging
and default/native builds retain the disabled default until their own server
is verified. Activation CI and hosted signed-in/device acceptance remain pending.

Live authenticated-role RPC smoke verification passed for an empty synthetic
identity: read returned the empty layout and save rejected the missing profile.
The transaction rolled back and touched no account data. This verifies callable
permissions; it is not a signed-in existing-account persistence test.
