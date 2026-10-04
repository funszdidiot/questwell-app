# Male class robes v1

The accepted male robe v3 is the immutable geometry for all five class designs. `tool/male_robe_fit_reference.json` governs the four alpha masks, 240 × 320 registration, straight hips, collar, cuff edges and hand clearance. The body v3, original identity and unified Everyday v2 remain byte-for-byte fixed.

| Class | Surface |
|---|---|
| Scout | Existing accepted olive/flax/brown v3, unchanged |
| Scholar | Navy cloth, gold edging and linked diamonds |
| Alchemist | Sapphire/royal blue, silver edging and narrow lime molecular rings |
| Guardian | Burgundy/red, gold trim, shield and lower chevrons |
| Wanderer | Tobacco brown, copper-gold edging and compass stars |

Built-in imagegen generated each of the four class surfaces from the male cloth target and existing class color/motif references. The reference bodies’ tailoring was excluded. Prompts and sources are saved under `tool/art_assets/male_class_robes_v1/{class}/`. The deterministic exporter imports RGB only, using continuous affine surface registration and bilinear sampling. It transfers the locked cuff/rear tonal pixels into the class palette, retaining every original alpha value. An initial row-wise texture registration produced jagged motif seams and was replaced before delivery; this reinforces the continuous-region repair method.

`node tool/export_male_class_robes_v1.cjs` exports the surface variants. It verifies every locked input before and after export and never writes those inputs. `node tool/verify_male_class_robes.cjs` is read-only and checks all sixteen file hashes/masks, source hashes and exact runtime composites. `exports.json` pins the final outputs. Independent export QA is recorded in `independent_visual_review.json`; this does not claim new founder surface approval.

Runtime paths: `assets/images/questwell/avatar/classes/{class}/{class}_robe_{part}_male_v1.webp` for the four new surfaces; Scout retains its original v3 paths. Both detail and lineup use `QuestwellMalePaperDoll`, so the rendered order remains rear → body → unified everyday outfit → front → original identity → collar → cuffs.

Development review routes: `?review=male-robes` shows all five; `?review=male-robe&class=guardian` opens a specific class with light/dark, clothing and enlargement controls. Class selection is local review state. The route restores its requested class after reload and falls back to Scout for unknown names. No account class, equipment, catalog, ownership, pricing or persistence mutation is introduced. Existing male account wardrobe rollout remains queued for a coherent complete transition. The separate Woodland Scout outfit remains in the avatar pipeline.

At this checkpoint, required CI/deployment and delivered-runtime checks are pending. See the production dashboard for current evidence.
