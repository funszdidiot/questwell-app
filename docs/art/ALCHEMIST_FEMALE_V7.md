# Locked female Alchemist — both cuffs widened inward

On 3 October 2026 Tanya first requested widening the inner image-left wrist cuff and locking it, then requested the same inward widening at the image-right wrist. Version 7 preserves the completed v6 left adjustment and adds only the right adjustment. The exact female body, identity, outer sleeve contours, torso and hem remain unchanged.

Built-in imagegen supplied the right-wrist artwork. `tool/export_alchemist_female_v7.sh` registers it to the existing outer wrist and admits only the inner-right edit polygon: (162,154), (159,157), (155,161), (153,166), (153,172), (164,172), (164,161), (163,156). All other v6 pixels are retained. The rear lining is byte-identical to v5 and v6. Foreground cuff pixels continue to wrap over held equipment without changing the body.

The full reproduction chain is v5 → `bash tool/export_alchemist_female_v6.sh` → `bash tool/export_alchemist_female_v7.sh`. Source artwork and prompts are in the corresponding `tool/art_assets/alchemist_female_v6/` and `alchemist_female_v7/` directories. The resulting v7 front, cuffs and rear are frozen under `approved_layers.alchemist_female_v7` in `tool/avatar_assets.json`. This is the current locked female Alchemist fit.

The shared development renderer and three-stage review use v7. Deployment checks are recorded in `PROJECT_STATUS.md`. This does not change male/neutral bodies or authorize a merge or launch.
