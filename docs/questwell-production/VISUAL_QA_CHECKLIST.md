# Visual QA Checklist

A candidate is not founder-ready until all applicable checks pass.

## Foundation integrity
- correct locked body and identity layer
- 240 x 320 authored canvas where applicable
- no body scaling/translation drift
- face/hair/neck/pose/hands/feet unchanged

## Garment fit
- shoulders follow anatomy
- sleeve widths grow in the intended direction
- cuffs are connected, complete and wrap wrists naturally
- hands remain clear
- waist/hips are natural; no bulges
- crotch/inner-leg coverage is clean
- trouser seams are coherent
- heels/soles are fully covered
- no skin leaks or old garment pixels
- no duplicated seams, floating cloth or AI-smear fragments

## Robes
- continuous rear panel
- natural front fall; no unnecessary flare
- correct front/rear occlusion
- no stray inner flaps
- locked opening/collar/cuff geometry preserved
- class surface details do not alter alpha geometry

## Equipment
- compatible with garment depth
- no hand/body replacement unless explicitly approved
- grimoire remains belt-mounted
- retired Pathfinder boots absent

## Runtime
- correct asset is reachable from inventory/equip rules
- body eligibility matches approved fits
- class restrictions are correct
- equip/unequip works
- default class outfit restores correctly on the same locked body/identity
- equip, unequip, class change and reload do not swap to a different foundation
- compare body assets/layers semantically across transitions as well as checking hashes
- explicit candidate/review availability does not silently broaden account eligibility
- saved loadout survives reload/session restoration without body/class policy drift
- inventory ownership remains intact when an item is hidden or retired
- shared avatar appearance is consistent across Hearth/Adventurer/Market where applicable

## 64-bit art-direction fidelity
- clearly reads as high-detail 64-bit-era cozy fantasy game art at runtime scale
- pixel-authored / sprite-like edges and material treatment remain coherent with approved Questwell décor
- richer polish does not drift into photorealism, painterly concept art, smooth vector illustration or modern 3D rendering
- lighting/glow supports the sprite instead of masking weak geometry
- textures and ornament remain legible at actual Hearth/Market scale
- compare directly against approved benchmark décor such as the Autumn Ember Lantern, walnut bookshelf, burgundy reading chair and First Journey trophy
- seasonal/limited assets must pass the same style gate; novelty cannot override visual-system consistency

## Presentation
- native/full-size review
- enlarged detail review
- app/card/portrait scale
- phone width
- Safari/web consistency where applicable

## Technical
- asset integrity/manifests
- deterministic export verification
- regression tests
- Flutter Check
- required predeployment CI gate passed for the exact revision
- Preview/development deployment verified at its delivered revision
- actual deployed runtime inspected; a commit/build/upload does not prove delivery
- evidence and separate production/art-lock status recorded in the dashboard

Technical success is not founder visual approval.
