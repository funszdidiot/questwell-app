# Male robe and Everyday identity sampling

## Scope

Continuation of the verified coat-v8 original-head renderer. The separate locked
identity export has identical visible RGBA in rows 0–73, but its transparent cutoff
produced a rectangular neckline in the delivered enlarged renderer. Sample the
full original image, then clip only its foreground head duplicate to those rows.
The complete primary body remains an unclipped sibling at the same registration.

A single QuestwellMaleIdentity component now governs male robes, Everyday,
legacy garments and the isolated Woodland candidate. This changes no asset bytes,
body/class eligibility, inventory, equipment policy, prices or account persistence.
The Woodland candidate remains unavailable as male account equipment.

## Validation

- Asset-integrity verifier passed. All artwork unchanged from 670855e.
- First gate f549005 / 37334073064: analyzer passed; five stale body-count
  assertions in male_robe_occlusion_test failed. They now distinguish the intact
  primary body from the clipped foreground identity, preserving garment checks.
- Corrected runtime candidate: 9da72058deaabe64eb6085e26c7871b7099ba1b8.
- Workflow 37334631348: all 387 Flutter tests, 12 Node checks, analyzer,
  asset integrity, locked dependency checks, build and deployment passed.
- Delivered revision confirmed in the browser script tag: 9da7205.
- All 23 delivered body/identity/Everyday/five-class robe hashes passed;
  tool/qa/male_identity_sampling_delivery.json records exact hashes.
- Actual all-five gallery, 2× Scout/Guardian/Everyday on light/dark backgrounds,
  Body Only → Robe restoration, shared renderer class change, Suit equip and
  unequip → Scout restoration verified with continuous necklines.
- Independent visual review: PASS. No changes observed to anatomy, hands, cuffs,
  garment registration or drape. Evidence includes gallery, Scout, Guardian,
  Everyday, shared renderer and unequip screenshots listed below.
- Actual male Scholar Market at 390px: Everyday search → Preview → sample
  purchase (650 → 610 coins) → Owned → Equip → In use → Preview/Unequip → Owned.
  Balance stays 610 after equip/removal. No real account changes or new account
  persistence claim; catalog/equipment/persistence implementation is unchanged.

Baseline evidence: male-neckline-before.jpg and male-neckline-enlarged-before.jpg
captured from delivered 670855e before correction.

No new founder lock or founder blocker. This is a renderer correction only.

## Delivered screenshots

- male-neckline-gallery-live.jpg
- male-neckline-scout-enlarged-live.jpg
- male-neckline-guardian-enlarged-live.jpg
- male-neckline-everyday-enlarged-live.jpg
- male-neckline-shared-renderer-live.jpg
- male-neckline-unequip-live.jpg
- male-neckline-market-live.jpg

Tanya said “Better!” during this continuation. This records positive feedback,
not a new template lock.
