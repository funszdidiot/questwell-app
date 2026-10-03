# Neutral paper doll and Scout fitting — 3 October 2026

Tanya requested the gender-neutral paper doll for the Scout outfit and robes. The initial muscular foundation was rejected as insufficiently neutral. She approved the revised narrower shoulders, straighter torso, balanced hips and softer muscle definition with “Yes.” That revised frame is now the fixed neutral foundation. The Scout clothing fit is a separate review candidate.

The complete 240 × 320 base is `base/paper_doll_neutral_v1.webp`. The original face and hair are restored above y74; the approved revised frame supplies the body. Its hash and rules are recorded in `tool/neutral_avatar_fit_reference.json`. No clothing operation modifies the body. The old male/neutral anatomy clips are not used by this fitting. Female assets and existing equipped avatars remain unchanged.

Built-in imagegen produced the revised body, neutral Woodland Scout garment and rustic olive robe from the approved body and design references. Sources and prompt specifications are retained in `tool/art_assets/neutral_paper_doll_v1/` and `tool/art_assets/neutral_scout_v1/`. The exporters require Node and Sharp:

- `node tool/export_neutral_paper_doll.cjs`
- `node tool/export_neutral_scout.cjs`

Woodland Scout is one coherent outfit image, with ivory rolled sleeves and matching tabs, fern vest, belt/pouch, reinforced trousers and folded boots. Offline garment registration adds the necessary trouser and boot allowance. The runtime uses a single full-canvas layer, not separate scale/offset adjustments. The under-robe variant suppresses only the outfit's short sleeve fabric where the long robe sleeves cover it; it never suppresses body pixels.

The robe front, continuous rear lining and foreground cuff lips are separate depth passes. The rear panel and back cuff edges sit behind the complete body; the front and cuff lips sit above it. The fixed head/hair foreground restores the original identity above collars. There are no chest pockets or extra inner front flaps.

Development review: `?review=neutral-scout`. It compares Fixed base → Woodland Scout → Scout robe at equal scale, with outfit/robe toggles and enlarged wrists. Narrow screens scroll horizontally. `?review=neutral-paper-doll` shows the approved body and anatomy details separately. These routes do not alter accounts, ownership, Market availability or existing equipped outfits.

Validation includes asset hashes, complete lower-body garment coverage, identity preservation, all four outfit/robe combinations, rear/body/front/cuff order and mobile layout. CI and live-review results are recorded in PROJECT_STATUS.md. Tests establish implementation behavior, not founder visual acceptance or a physical-device test.

Next gate: Tanya's visual review of the actual neutral Scout outfit and robe fit. After that fit is accepted, preserve its neutral silhouette and depth masks across the Alchemist, Scholar, Guardian and Wanderer color/pattern variants. Do not stretch the female robe over this body. No merge to flutterflow, external beta or launch is authorized.
