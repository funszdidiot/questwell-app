# Guardian — locked female robe geometry, clean front opening

Tanya requested Guardian next on 3 October 2026, then explicitly rejected the extra inner flap on the first generated source and asked to keep the original design. A second built-in image edit removed both unwanted narrow lining strips behind the gold front borders. The robe retains burgundy cloth, antique-gold trim, a small sleeve shield crest, four brass fasteners, a discreet chest welt, lower hip welts and one chevron per lower front panel.

The app exports copy the exact Alchemist v7 front, foreground cuff and rear alpha masks. Both inward-widened cuffs, sleeve outer contours, shoulders, waist, front opening and hem remain locked on the shared 240 × 320 canvas. The female paper doll, identity and Everyday underclothes are unchanged. The continuous rear cloth is a depth layer behind the body; it does not add hanging strips at the front opening.

Source art, both prompts and RGB registration landmarks are preserved under `tool/art_assets/guardian_female_v4/`. `bash tool/export_guardian_female_v4.sh` uses the corrected source and registers its surface to the approved shape; dense front-edge landmarks keep the gold trim aligned. Final alpha is always copied unchanged from the locked template. The existing Guardian rear texture supplies the burgundy lining surface. No runtime transforms or body clipping are introduced.

The shared renderer now uses this female Guardian default and restores it after other outfits are removed. `?review=guardian-wardrobe&compare=none&detail=cuffs` shows the robe and wrists; the three-stage mode keeps the same body and scale. Male and neutral Guardian assets retain their previous behavior.

Automated checks compare every alpha pixel of all three new layers to the locked template, retain the frozen-body checks and exercise mobile layouts, equipment and outfit restoration. Deployment evidence is recorded in `PROJECT_STATUS.md`. The geometry is approved; this Guardian surface awaits founder visual acceptance. No merge to `flutterflow` or launch.
