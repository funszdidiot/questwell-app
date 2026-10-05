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
registration exposed shoulders and13 lower pixels and was rejected. The final
continuous field adds shoulder ease, .75px inner-calf ease and1.8px heel extension.

Source/registration: tool/export_male_woodland_v2.cjs.
Canonical candidate record: tool/male_woodland_v2_fit_reference.json.
Versioned app asset: assets/images/questwell/avatar/woodland_scout_unified_male_candidate_v2.webp.
Historical v1 files/references remain unchanged.

## Local QA

Independent visual review PASS: shoulder support, inward sleeve edges, natural
rolled cuff contours, no breast pockets, complete hands, continuous waist/hip/fly/
inner-leg contours, correct outward footwear and full heel/sole coverage.
Reviewed source, exact export, native and enlarged light/dark composites against v1.
Existing coverage predicate:6111 opaque body pixels covered at alpha>=250;
872 hand pixels clear at alpha<=2. Locked body/identity/Everyday hash checks pass.
No founder lock is inferred; new fit remains a candidate.

## Integration

Male Woodland renderer points to v2, sharing the original-head component and
unmodified belt-mounted grimoire. Body/Everyday/robe/Woodland transitions use the
same locked foundation. Male account Woodland remains unavailable; female/neutral
Scout eligibility, existing ownership, catalog pricing, equipment and persistence
are unchanged. Review text now accurately says Everyday/robes are live and Woodland
is a fit candidate. Full CI/deployment and actual delivered checks are pending.
