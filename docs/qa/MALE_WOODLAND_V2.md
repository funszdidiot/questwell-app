# Male Woodland v2 sleeve and overall fit correction

Tanya rejected the earlier Woodland sleeve/overall-size fit and requested work
by body. This candidate addresses male v3 individually. Earlier v1 technical and
visual PASS does not override the founder rejection. Female/neutral fit work is
separate; accepted cloak/mantle, repaired coats and all locked bodies are intact.

One built-in image edit produced the complete connected outfit. The exact prompt
and original RGBA source are preserved in tool/art_assets/male_woodland_v2/.
The export uses one continuous whole-outfit mapping, retaining a single overlay;
no independently stretched shirt/vest/trousers/boots, patch strips or body masks.
Disconnected generation specks are removed from garment art only. Initial uniform
registration exposed shoulders and 13 lower pixels and was rejected. The final
continuous field adds shoulder ease, .75px inner-calf ease and 1.8px heel extension.

Source/registration: tool/export_male_woodland_v2.cjs.
Canonical locked fit record: tool/male_woodland_v2_fit_reference.json.
Versioned app asset: assets/images/questwell/avatar/woodland_scout_unified_male_candidate_v2.webp.
Historical v1 files/references remain unchanged.

## Local QA

Independent visual review PASS: shoulder support, inward sleeve edges, natural
rolled cuff contours, no breast pockets, complete hands, continuous waist/hip/fly/
inner-leg contours, correct outward footwear and full heel/sole coverage.
Reviewed source, exact export, native and enlarged light/dark composites against v1.
Existing coverage predicate: 6,111 opaque body pixels covered at alpha>=250;
872 hand pixels clear at alpha<=2. Locked body/identity/Everyday hash checks pass.
The local QA was completed before founder acceptance; Tanya’s later approval is recorded below.

## Integration

Male Woodland renderer points to v2, sharing the original-head component and
unmodified belt-mounted grimoire. Body/Everyday/robe/Woodland transitions use the
same locked foundation. Male account Woodland remains unavailable; female/neutral
Scout eligibility, existing ownership, catalog pricing, equipment and persistence
are unchanged. Review text now accurately says Everyday/robes are live and Woodland
is a fit candidate. The existing v2 implementation completed development deployment at
`ae72f23b0386420e28282021133378f17385d546`. This continuation verified that
exact revision; it did not redraw or change the outfit.

## Delivered verification — 2026-10-05

At verification, production was **DEV DEPLOYED / technically verified** and art was a candidate. The subsequent founder acceptance below locks this exact fit.

- Preview workflow `37342883393` passed the asset-integrity, locked-dependency,
  analyzer, Flutter, build and deployment gates. The analyzer still reports
  existing warnings; passing its configured gate does not mean warning-free.
- CI output: `387 tests passed.`; preview Node output: `tests 12 / pass 12 / fail 0`.
  Backend-harness workflow `37342882902` separately passed 19 Node guard checks,
  10 isolated fixture assertions and 4 isolated application smoke assertions.
- The delivered `questwell-version.json` returned the exact revision above.
  Five fetched assets match repository SHA-256 values: locked male v3 body,
  identity, Everyday v2, Woodland v2 and the belt-mounted grimoire.
- Actual browser review passed Body only → Everyday → Scout robe → Woodland
  transitions, enlarged light/dark inspection, belt-grimoire rendering and route
  reload restoring Woodland with the accessory off. The same complete body and
  visible identity persist; hands are unobstructed and heels/soles are covered.
- Independent delivered-image review by `/root/woodland_runtime_review` found no
  blocking defects in shoulders, sleeve/cuff ends, hands, neckline, seams,
  proportions or boots. Complete soles are visible in the native runtime capture;
  the enlarged runtime viewport clips the boot bottoms, so enlarged export
  composites were also inspected. The visual QA itself did not establish approval; Tanya’s subsequent acceptance is recorded below.
- Existing passing widget regressions cover body/class eligibility, guarded
  equipment and route restoration at 320, 390 and 1363 pixels. The scoped candidate
  makes no account, catalog, economy or saved-loadout writes.

Evidence: `tool/qa/male_woodland_v2_delivery.json` and
`docs/qa/male-woodland-v2-{native,enlarged,grimoire}-ae72f23.jpg`.
Review: https://funszdidiot.github.io/questwell-app/?review=male-woodland

## Limits and rollback

Physical iOS/Safari, real-account purchase/equip and real-user persistence were not
verified in this candidate-only continuation. Male Woodland remains unavailable
for account equipping; female/neutral Scout support remains unchanged. Founder acceptance is recorded below; account rollout is not inferred from QA.

This documentation follow-up changes evidence and dashboard status only. Revert
its commit to roll it back; no app, asset, schema or data rollback is required.
Historical v1 remains preserved for provenance, not accepted as the current fit.


## Founder acceptance — 2026-10-05 America/Chicago

Tanya responded **“It’s good”** to the verified v2 screenshot and development
review. Male Woodland v2 is now **LOCKED** at
`tool/male_woodland_v2_fit_reference.json`, retaining the exact approved asset
SHA-256 `bc923c9b5043950e617ad81b5b4caed7448846ccc4536e4fcc56ad90725c8ed8`.
No artwork or renderer bytes changed when recording the approval. Preserve its
single-overlay silhouette, sleeves/cuff openings, hand clearance, waist/hip/leg
contours, footwear, alpha and registration on locked male v3. Historical candidate
naming and the earlier v1 reference do not reopen this approval.

Remaining integration: route male Woodland through the shared avatar renderer,
update supported-body policy and catalog description consistently with the server
contract, then verify Scout-only equip/unequip, purchase, ownership and saved-loadout
restoration. Current account support remains female + neutral Scouts. The approval
record does not claim that this remaining rollout has been completed.
