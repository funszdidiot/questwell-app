# Legacy fit repair — 2026-10-04 America/Chicago

Status: QA. Development delivery not yet verified.

Scope: Business Suit, Midnight Harvest Coat, Moss-Green Cloak and Hearthguard Mantle on locked male v3, female v1 and neutral v4. User explicitly requested female and neutral checks.

The deployed audit at 7533e3b exposed suit shoulder/foot leaks, a neutral inner-leg gap, Harvest shoulder/arm leakage and cloak exposed arms. New garment-only suit v1 and coat v3 overlays preserve each historical design. Cloaks reuse exact existing artwork with whole-drape registration. No body, identity, approved Everyday, robe, Woodland, grimoire or account-policy file changes.

Independent reviewer legacy_suit_visual_qa passed all six suit light/dark composites and all six final coat composites. Female shoulder/armpit and neutral upper-arm/forearm/cuff leaks were corrected, and female leaf motif distortion was resolved before PASS. Cloak/mantle trials pass arm coverage and ornament/drape checks; actual runtime foreground-neck restoration remains to verify. Exact reviewed hashes, inputs and prompt briefs are in tool/art_assets/legacy_refit_v1/provenance.json. Built-in image generation supplied garment-only sources; reproducible Node/sharp exporters perform continuous registration and light/dark composites.

The renderer uses body → unified suit → original identity, with no old suit anatomy. Harvest uses the full body plus garment-only Everyday lower coverage and the coat. Regression coverage includes all classes/bodies, equipment restoration, held-item/cloak policy, no body ClipPath, retired Pathfinder exclusion and garment pixel checks. CI and runtime results will be recorded after delivery. No real account writes or new template approval is inferred.
