# Scout wardrobe fitting preview

The founder approved the ivory linen top, brown travel trousers and softer forest-green Scout robe concept. This candidate is fitted to all three existing bodies and exposed through `?review=scout-wardrobe` only. It does not change inventory, prices, ownership, production defaults, or the other classes.

Nine separate body-specific transparent images were generated using the built-in image generation tool, using the corresponding clean base as the pose reference and the approved Scout wardrobe sheet as the design reference. Source exports live in `tool/art_assets/scout_wardrobe_v1`. `tool/scout_wardrobe_fit.json` records each source/target landmark. Run `OPENBLAS_NUM_THREADS=1 python3 tool/fit_scout_wardrobe.py` to export 240x320 lossless runtime WebP layers; Pillow, NumPy and SciPy are required. The fit checks for reversed registration patches and samples premultiplied color at 4x before downsampling.

Prompt set:
- Top, independently generated for female, male and gender-neutral: warm ivory linen short-sleeve henley, split neckline, stitched placket, natural folds, body-specific shoulders and waist, no person or other clothing, transparent background.
- Trousers, independently generated for each body: charcoal-brown relaxed travel trousers, simple waistband and brass button, natural knee folds, outward-facing brown ankle boots, no formal suit crease, no skin or other clothing, transparent background. The ankle boots are currently part of this lower garment; equipped Pathfinder boots replace them through the existing footwear clip.
- Robe, independently generated for each body: forest-green woven cloth, soft shoulder/elbow folds, two continuous open front panels, lower-calf curved hem, gold leaf embroidery, curved wrist cuffs, no armor epaulettes or center flaps, transparent open front and background, no anatomy or other clothing.

The shared renderer accepts an explicit optional preview layer set. Omitting it preserves existing wardrobe behavior. Removing any candidate layer leaves the modest clean base. Equipping the trousers hides the old lower anatomy, never uses business-suit pants, and retains the original hands. The robe hides under-sleeves; its back collar is occluded at the neck. Original face, hair and hands are restored over clothing, with the existing held-item grip clipping preserved.

Review controls: linen top, travel trousers, Scout robe, accessories, empty hands/lantern/grimoire and cuff detail. Query options: `layers=top,trousers,robe`, `gear=all`, `held=brass-lantern` or `annotated-grimoire`, `detail=cuffs`. An empty `layers=` shows the clean base.

Validation before publishing: all nine exports passed the non-folding fit check; existing frozen avatar asset hashes passed. Local six-view compositing exposed sleeve protrusion and collar overlap, corrected in the runtime clipping. CI and live preview inspection follow the development commit. Fitting approval and market-slot integration remain separate follow-up work.
