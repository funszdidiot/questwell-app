# Locked female Alchemist fit — inward left cuff correction

On 3 October 2026, after the v5 on-body preview, Tanya requested widening the cuff on the inner left wrist and locking in that fit. This means the cuff on the image-left side grows toward the torso; the outer wrist edge and fixed body do not move.

Built-in imagegen produced the wrist edit using the full v5 front source. To preserve all unaffected artwork, the exporter admits only the inner-left-wrist polygon from that edit: (78,154), (81,157), (85,161), (86,166), (86,172), (73,172), (73,161), (76,156), on the shared 240×320 canvas. The edit is registered to the existing wrist height. The rest of the original v5 front, including the entire other cuff, is retained. The rear lining is byte-identical. Body, identity, top, trousers and boots are unchanged.

Rebuild with `bash tool/export_alchemist_female_v6.sh`. The imagegen prompt and source are in `tool/art_assets/alchemist_female_v6/`. The resulting front, foreground cuff and rear assets are frozen under `approved_layers.alchemist_female_v6` in `tool/avatar_assets.json`. This is the locked female Alchemist fitting reference; do not copy female anatomy to male or neutral bodies.

The development app uses v6 in the shared avatar renderer. Checks and deployment evidence are recorded in `PROJECT_STATUS.md`. This visual lock does not authorize a merge to `flutterflow` or launch.
