# Avatar and wardrobe work

Before creating or changing avatar or clothing artwork, read `docs/art/PAPER_DOLL_STANDARD.md` and the applicable body fit reference under `tool/`.

Tanya approved the neutral v4 foundation on 2026-10-03 and directed that its repair methodology govern **all future avatars**:

- Build and visually review a complete, continuous foundation before locking it. Anatomical joins must connect naturally at normal size and when enlarged.
- Repair an entire defective connection coherently. Do not hide a defect with unrelated strips, leftover fragments, a mismatched shading patch, or alpha blending between displaced silhouettes.
- Preserve identity and unaffected anatomy. Keep approved bodies byte-for-byte fixed during every clothing task; adjust garments to their body, never the body to the garments.
- Inspect the actual exported assets and final layer composite on light and dark backgrounds at native and enlarged sizes. Source art, hashes and passing automated checks do not establish visual quality.
- Obtain an independent visual review before presenting a new foundation or foundational garment fit. Resolve concrete defects before calling it ready. Record founder approval separately from QA.
- Lock approved geometry and registration. Each body and garment family needs its own fit template; colors, patterns and flourishes reuse that geometry.

Tanya approved and locked **neutral robe v11** on 2026-10-03 (America/New_York), explicitly authorizing all remaining neutral class robes. `tool/neutral_robe_fit_reference.json` is the canonical template. Reuse the exact front, rear, cuffs and collar alpha values, registration, drape, cuff openings/rims, hand clearance and layer order for every neutral class robe. Change only colors, patterns and flourishes; never regenerate class-specific geometry or alter the approved body/everyday layers. Surface variants still require export preservation checks and independent visual QA.

Current sequence: neutral v4 body, everyday v3 and robe v11 are approved and locked (`tool/neutral_avatar_fit_reference.json`, `tool/neutral_everyday_fit_reference.json` and `tool/neutral_robe_fit_reference.json`) → build Alchemist, Scholar, Guardian and Wanderer robe surfaces on v11 → finish neutral Woodland Scout → male outfits after its foundation is approved. Do not infer deployment, Market/account writes, merge or launch authorization from an art approval.

Tanya additionally directed “and start pushing to the app” during the neutral class-robe build. Development app integration and push are authorized for this work. No merge to `flutterflow`, production launch or Market/account writes are authorized.

Tanya subsequently directed removal of Pathfinder boots and a different grimoire attachment to protect the fixed-avatar methodology. Retire Pathfinder from app catalog views and renderers; do not replace approved feet or erase ownership history. The grimoire uses book-only art attached to the belt, with body-specific accessory anchors. Never use replacement-hand grip art or mask the avatar's hand to equip it.
