# Legacy fit repair — 2026-10-04 America/Chicago

Status: QA. Refit revision `588994d` is delivered; the delivered visual audit found a mantle-neckline defect requiring the scoped correction below.

Scope: Business Suit, Midnight Harvest Coat, Moss-Green Cloak and Hearthguard Mantle on locked male v3, female v1 and neutral v4. User explicitly requested female and neutral checks.

The deployed audit at 7533e3b exposed suit shoulder/foot leaks, a neutral inner-leg gap, Harvest shoulder/arm leakage and cloak exposed arms. New garment-only suit v1 and coat v3 overlays preserve each historical design. Cloaks reuse exact existing artwork with whole-drape registration. No body, identity, approved Everyday, robe, Woodland, grimoire or account-policy file changes.

Independent reviewer legacy_suit_visual_qa passed all six suit light/dark composites and all six final coat composites. Female shoulder/armpit and neutral upper-arm/forearm/cuff leaks were corrected, and female leaf motif distortion was resolved before PASS. Cloak/mantle trials pass arm coverage and ornament/drape checks; actual runtime foreground-neck restoration remains to verify. Exact reviewed hashes, inputs and prompt briefs are in tool/art_assets/legacy_refit_v1/provenance.json. Built-in image generation supplied garment-only sources; reproducible Node/sharp exporters perform continuous registration and light/dark composites.

The renderer uses body → unified suit → original identity, with no old suit anatomy. Harvest uses the full body plus garment-only Everyday lower coverage and the coat. Regression coverage includes all classes/bodies, equipment restoration, held-item/cloak policy, no body ClipPath, retired Pathfinder exclusion and garment pixel checks. CI and runtime results will be recorded after delivery. No real account writes or new template approval is inferred.

## Delivered audit and neckline correction — 2026-10-04 America/Chicago

Revision `588994dc017181b636b14d2f30d27622099e3c15`, workflow `37260274975`, passed 387 Flutter tests, 8 Node tests, asset integrity, the configured analyzer gate, web build and development deployment. Analysis reports 45 nonfatal warnings/information findings; this is not a warning-free result. The delivered version and all twelve checked garment/body/identity hashes match `tool/qa/legacy_refit_delivery_588994d.json`. All 24 provenance files and all six locked body/identity files also match locally.

Actual native and enlarged inspection found a dark horizontal band beneath the Hearthguard Mantle's chin. The head rectangle and neck contour overlap with opposite winding; the nonzero fill rule cancels their overlap at authored rows 70–73. See `mantle-neckline-before-588994d.jpg`. Passing asset checks and point checks below this seam had missed the rendered defect.

`QuestwellCloakForegroundClipper` now describes the same intended head/neck region as one continuous outline. No body, identity, garment artwork, registration, clothing availability or account behavior changes. The new regression checks continuous foreground coverage through the observed band for all three bodies at native, enlarged, tall and wide render dimensions. Complete CI and delivered post-fix inspection remain pending; no new founder lock is recorded.
