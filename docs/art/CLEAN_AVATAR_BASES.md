# Clean avatar foundation v1

Founder authorized this after the Midnight Harvest season build. The baked-in business jacket and tie should no longer constrain future outfits. This replaces the rendering foundation, preserving existing equipment and progression.

## Construction

- Three independent generated anatomy designs: opaque ivory sleeveless undershirts, charcoal shorts, bare arms and legs. The 64-bit-style illustrated artwork remains distinct from the 16-bit catalog icons.
- `tool/art_assets/clean_bases_v1/` retains source masters. `tool/clean_base_fit.json` and `tool/fit_clean_bases.py` register them offline to each original 240 x 320 wardrobe canvas. No runtime scale or translation changes garment fit.
- `QuestwellCleanBase` composes clean anatomy with original head/hair and hands. Generated faces are hidden, preserving the accepted characters. `tool/clean_base_layers.json` records the paths in `CleanBaseClipper`.
- When an existing class or Harvest garment is worn, the original trousers/shoes and cuff contacts are separate clipped outfit components. Anatomy beneath those components is suppressed, avoiding bare toes around boots. The jacket and tie are not part of these components.
- The explicit `starter-business-suit` choice retains the full original outfit. Existing class-default behavior stays intact; removing an item still restores the class garment. No inventory, catalog, profile or onboarding migration is required.
- Existing body-specific class occlusion masks remain for garment coverage. Closed cloaks, held-item hand replacement, satchel forearms and Pathfinder boots continue through the same shared renderer.
- All frozen source avatars, approved garments and fit manifests remain byte-for-byte unchanged. This new authorized foundation supersedes the old fit spec's requirement that the suit remain beneath every class outfit; its fixed anchors and garment acceptance gates still apply.

## Review

`?review=clean-bases` shows all three bodies in modest base layers, selection-card size and portrait size. Controls exercise five classes, Harvest coat, business suit, both closed cloaks, accessories and held items without touching account data.

Automated gates: existing asset SHA verification; new clean-base canvas/identity/clothing checks; existing class portrait/card, Harvest, boot, cloak, grimoire and equipment tests. New stack expectations retain rear-first/front-last assertions and body-specific clip checks.

Development update `00762646eea8f2139e63ae1d2c46837dd00468bf`: Flutter Check `37086976439` and Preview `37086976352` passed. Live browser review verified all three clean bases at card and portrait sizes, Harvest coat with accessories, switching to the explicit business suit, and restoring class clothing. Implementation delivery does not imply founder visual acceptance or production-launch approval. Development branch only; no merge to flutterflow.


## Founder approval and wardrobe fit pass — 2026-10-02 (America/Chicago)

Tanya approved the three clean bases (“I like it”), then authorized a full wardrobe fit pass. Approval covers the bases; it does not authorize a production merge or launch.

Reviewed all nine outfit designs on female, male and neutral bodies: Scholar, Scout, Alchemist, Guardian, Wanderer, Midnight Harvest Coat, Business Suit, Moss Green Cloak and Hearthguard Mantle. Browser inspection covered portrait/card scale, neckline, wrists, waist and hem. No new garment overlap was found; approved anatomy and garment artwork remained unchanged.

Full accessory views checked the wizard hat, glasses, scarf, brooch, Pathfinder boots, both satchels, book and lantern. Both closed cloaks correctly suppressed held items. New regression coverage exercises five classes × three bodies × four chest items × two hand/bag combinations (120 equipped scenarios), restoring the exact default class/body asset stack after each removal and checking that rendering does not mutate the equipment map. These are renderer checks, not new signed-in server persistence tests.

The comparison page now accepts validated archetype/outfit/gear/held/bag query choices. Fixed phone overflow in its dropdowns and comparison labels; tests cover 320px and 390px viewport widths. Initial run found those two review-layout failures; final correction f9231acdd2ea91a5795414a7f53fa9ff1ed232f7 passed all 288 tests (Flutter Check 37088649997), and Preview 37088649877 deployed successfully. Actual iPhone hardware was not exercised in this pass.

Final review screenshot: questwell-wardrobe-fit-checked.jpg. Development branch only; no database, inventory, reward or catalog changes.
