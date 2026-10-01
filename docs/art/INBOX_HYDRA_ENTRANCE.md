# Inbox Hydra arcade entrance

First detailed boss encounter, pending founder visual approval. Shared `QuestwellBossEncounter` is used by actual Inbox Hydra cards and the account-free `?review=boss` practice encounter. Existing boss tasks, completion RPCs and reward flow are preserved. Profile appearance/equipment comes from the existing cosmetics snapshot; no inventory writes.

3.2-second entrance: dark warning banner, rightward offscreen start sliding left into place, small landing bounce and pixel dust, typewriter taunt, health-bar fill, YOUR MOVE. Tap anywhere on the stage or use Skip. Local preferences remember finished/skipped encounters by unique battle ID on that device; resumed battles with progress and completed battles bypass the intro. Reduced motion shows the final readable state. Inactive TickerMode pauses the entrance. Cached sprite/avatar children avoid rebuilding those trees each animation frame. Defeat fades the Hydra; existing live reward dialog remains authoritative.

Practice controls allow replay, sample attacks/reward, body selection and reduced motion without account writes.

Art: built-in ImageGen, source `exec-eb221042-7dcb-495d-872f-d49295677bdb.png`; converted proportionally to640px WebP, `assets/images/questwell_inbox_hydra_v1.webp`. No other boss artwork replaced.

Prompt:
Production game enemy sprite for Questwell, detailed64-bit retro fantasy painterly pixel-era RPG aesthetic. Exactly one charmingly menacing INBOX HYDRA: three serpentine heads with amber eyes, forest-green scales and aged brass accents, long winding necks rising from an overstuffed antique wooden letter tray. Paper envelopes and rolled scrolls tangled around its compact body, a few wax-sealed letters clutched in claws. Three distinct expressive heads, smug rather than horrifying, no gore. Three-quarter view facing LEFT toward player, readable large silhouette for a mobile RPG boss. Rich shaded texture consistent with cozy dark academia fantasy, deliberate crisp details. Complete body and tail, generous clear margin. No text, no letters written on envelopes, no UI, no backdrop, no ground plane. Genuinely transparent background. Square canvas.
