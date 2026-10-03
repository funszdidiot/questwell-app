# Female avatar fitting standard — accepted 3 October 2026

Tanya approved the inward-sleeve Woodland Scout fit and instructed that its dimensions govern every future female outfit and robe. The authoritative machine-readable reference is `tool/female_avatar_fit_reference.json`; assets and sources are protected by the avatar integrity manifest.

## Frozen body and alignment

- Canvas: **240 × 320 px**, origin at top left. Every layer shares this full canvas, `BoxFit.contain`, bottom-center alignment. No per-piece runtime transforms.
- Body: `base/paper_doll_female_v1.webp`, SHA-256 `00a7fcaefb8bba3e8e528e8ee2cd1dea6650c61cf6b8f0f877eadd505a47938a`.
- Head/hair foreground: `base/paper_doll_female_identity_v1.webp`, SHA-256 `4f2a7fa8c41ff7373821177977a067cf98004863805f89d7317fd14ccf0ed27e`.
- Body bounds at alpha > 128: **(68, 13)–(185, 310)**, with right/bottom bounds exclusive.
- Approved Woodland outfit: `woodland_scout_unified_female_v11.webp`; bounds **(70, 69)–(191, 316)**. Source normalized uniformly to **210 × 280**, placed at **(7, 36)**.
- The rolled short-sleeve outer extremes are **x70 and x169** over rows 105–139. Needed sleeve width grows **inward**, toward the torso.
- Long robe sleeves terminate at the actual wrists, approximately **(76, 170)** and **(164, 170)**. These are distinct from the short-sleeve hems. Detailed arm cross-sections are in the JSON reference.

## Construction rules

Fit clothing to the frozen anatomy. Do not regenerate or mask away shoulders, arms, hips, legs, hands, or feet to fix a garment. Keep the face, hair, stance and proportions identical. Use one coherent outfit illustration, with only necessary cloth depth passes and equipment occlusion. Do not independently stretch shirt, vest, trousers and boots.

Maintain a narrow natural waist and smooth hips. No protruding white underarm inserts, enlarged vest side wedges, detached cuffs, duplicated shoulder seams, or skin showing through clothing. Cover heels and soles fully. Preserve matching sleeve tabs on Woodland Scout.

For robes, retain a continuous back panel behind the body and a front garment ahead of it. Wrist hems must stay attached to sleeves and curve naturally around the wrist. The female Scout v7 robe is now accepted. Other female class robes use its geometry as the fitting reference, with their own colors and surface patterns. Male and neutral bodies require their own completed, accepted paper dolls before clothing or class-robe work.

## Development integration

The approved Woodland Scout now uses one complete static image in the shared avatar renderer. Equip/unequip, Market, Hearth and Adventurer portraits share that renderer. The fitting page compares the frozen body, existing Everyday outfit, and approved Woodland outfit; its single outfit toggle reflects the actual construction. Existing optional footwear replaces the lower image region through the established footwear occlusion, without rescaling the body or outfit.

This approval authorizes the development app update. The hold on merging to `flutterflow` and launching remains.
