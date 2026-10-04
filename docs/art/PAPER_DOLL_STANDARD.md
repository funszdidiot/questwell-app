# Paper-doll construction and work order

Tanya explicitly confirmed this method on 2026-10-03. It applies to female, neutral and male avatars.

## Immutable approved foundation

Each body begins as one complete avatar wearing undergarments. After Tanya approves that foundation, its anatomy, proportions, pose, face, hair, arms, hands, hips, legs and feet are locked. All layers share the same 240 × 320 canvas and registration. Garments may be altered; the approved body may not be altered to fix them.

Never regenerate, replace, stretch, shift, clip away or mask body parts to accommodate an outfit. Normal clothing occlusion is allowed: the complete unchanged body remains underneath. A deliberate body revision requires a separate explicit request and new approval, never an incidental clothing repair.

Clothing is a paper-doll construction: rear cloth goes behind the full body; everyday garments, robe fronts and foreground cuff lips sit above it. The original fixed head/hair can form a foreground identity layer, without substituting a newly generated face. Sleeve openings, waist/hips and footwear must fit the locked anatomy. A clothing failure is repaired in the clothing only.

If an output needs a material design choice or clarification, ask Tanya before producing it. Do not silently infer approval from successful tests or a development deployment.

## Approved versus pending

- Female: approved foundation and existing fit standards remain locked. See `FEMALE_FIT_STANDARD.md` and `tool/female_avatar_fit_reference.json`.
- Neutral: **Tanya approved and locked body v4, everyday v3 and robe v11 on 2026-10-03 (America/New_York).** The exact body, identity and everyday garment assets are immutable. The four robe alpha masks, registration and depth order are the template for every neutral class robe. Independent visual QA preceded founder approval. See `tool/neutral_avatar_fit_reference.json`, `tool/neutral_everyday_fit_reference.json`, `tool/neutral_robe_fit_reference.json` and their art records. Alchemist, Scholar, Guardian and Wanderer surface variants are authorized; neutral Woodland Scout remains in the fitting sequence.
- Male: **body v3 and the unified everyday v2 outfit are founder-approved and locked.** `tool/male_avatar_fit_reference.json` and `tool/male_everyday_fit_reference.json` are canonical. Preserve their exact bytes, registration and body → outfit → original identity order. Historical `candidate` filenames do not reopen these approvals. Male robe v3 is accepted with the requested sharp cuff finish completed and independently verified in source commit `16facaf`. Preserve `tool/male_robe_fit_reference.json` and its four masks exactly.

## Current work order

The newer 2026-10-04 thumb-gap repair instruction authorizes a scoped male rear-lining correction. Keep the historical accepted v3 template intact and use `tool/male_robe_thumb_repair_reference.json` for the versioned repaired rear layers. Body, identity, Everyday, front, collar and cuffs stay unchanged. This is a development repair with independent QA; it is not a newly founder-locked template.

1. Neutral foundation v4 is approved and locked. Keep it fixed in all subsequent wardrobe work; v3 remains rejected.
2. Neutral everyday v3 is approved in the **same exact design and illustrated style as the female everyday outfit**. Keep the shirt, trousers and boots fixed while fitting robes; retain body → boots → trousers → top → identity order.
3. Verify the neutral class robes (Alchemist, Scholar, Guardian and Wanderer) against the approved v11 Scout robe geometry and the actual development renderer. Change surface color, pattern and flourishes only. Neutral Woodland Scout remains an unaccepted candidate in active development; it must not be treated as locked or automatically promoted by passing tests.
4. The newer male approval supersedes the earlier male-pending/neutral-first sequence. Preserve the exact male v3 foundation and everyday v2 outfit in a dedicated fixed-body development review, then integrate the exact accepted male robe v3 over those unchanged layers. The newer cuff-finish handoff records the completed acceptance condition and independent QA; male class surfaces inherit this geometry and male Woodland Scout follows. Continue authorized technical work while a genuinely new template decision is pending.
5. Follow `docs/questwell-production/` and its production dashboard for current implementation status. Art locks and runtime integration status are separate. Foundation approval does not authorize replacing every legacy male class renderer with an unfitted combination.

The current autonomous-development instruction authorizes approved development integration, technical verification and push. No merge to `flutterflow`, production launch, Market change or account write is implied by this art workflow; preserve any separately established permission boundary.

## Consistent outfit families

For each body and garment family, establish and review one foundational fit. Once accepted, freeze the silhouette, neck opening, shoulder fit, sleeve and cuff openings, waist/hip allowance, hem, registration and front/back layer masks. Reuse those measurements for that family's color, pattern, embroidery and decorative variants. Other body types require their own fitted templates. A structural garment change requires a new fit review; decorative variety must never drive a body edit.

Check the complete unclothed foundation first, then everyday clothing, then the additional garment. View the neck, shoulders, wrists, waist and feet at normal scale and enlarged. Pixel hashes establish preservation; they cannot establish a natural visual connection. Neutral robe v11 supersedes the rejected cuff iterations and is the approved template. Do not reuse v6–v10 as geometry references for new class robes.

## Required methodology for every future avatar

Tanya explicitly adopted the v4 repair methodology for all future avatars on 2026-10-03. Construct and review the complete foundation before fitting clothing. When a join is defective, repair the entire connected region with consistent anatomy, contours, outlines and shading. Preserve the character's identity and unaffected anatomy. Avoid horizontal strip splices, unrelated patches, stale fragments and crossfading of displaced transparent silhouettes. An authorized foundation repair must resolve the connection fully before a new lock is recorded.

Review the actual registered export and final depth-ordered composite, not only the attractive generated source. Inspect normal size, enlarged pixels, smooth enlargement, light and dark backgrounds, and the foreground identity layer. Check neck/head centering, shoulders, wrists/hands, hips, ankles and all affected joins. An independent visual review must pass before presenting a foundational avatar or garment fit; its result does not replace Tanya's approval. Retain reproducible sources, export logic, fixed-body checks and the exact reviewed hashes.

For sleeves and cuffs, compare each complete hand and thumb silhouette directly against the fixed foundation. Inspect every overlapping garment layer, including the main robe side panels. A clean cuff opening does not establish correct hand depth; adjacent side cloth must not obscure the exposed palms, thumbs or fingers.

Once approved, the full body, identity and registration are locked. A garment defect is repaired in one coherent garment region while that body stays byte-for-byte unchanged. Every foundational garment fit must be accepted before it becomes the geometry template for decorative variants.

## Locked neutral robe v11 template

Tanya's approval on 2026-10-03 (America/New_York): “Better. So, now lock this as the robe template for all robes for neutral avatar. You will build all the other class robes now”. This authorizes the neutral class robe surface variants. Tanya additionally instructed “and start pushing to the app”, authorizing development app integration and push for this work. No merge to `flutterflow`, production launch or Market/account writes are authorized.

Use `tool/neutral_robe_fit_reference.json` for the exact four source assets and their file/alpha SHA-256 values. Preserve every alpha value rather than redrawing approximately similar outlines. Keep the 240 × 320 canvas, zero offsets, all registration parameters, natural hanging skirt, rear hem behind the legs, inward cuff width, complete cuff finishing edges, repaired inner cuff joins and exposed hand silhouettes fixed. The order is rear → body → boots → trousers → top → front → identity → collar → cuffs. The separate collar preserves continuous trim beneath the fixed hair while avoiding the former identity-layer cutoff.

All five classes—Scout, Alchemist, Scholar, Guardian and Wanderer—share this neutral geometry. Decorative differences must remain within the locked masks. Check each final composite on the unchanged body v4 and everyday v3, and obtain independent visual review before presenting it. Geometry changes or a different body fit require a new explicit fitting review.

## Runtime continuity requirement

For a migrated paper doll, equipment changes must preserve the same locked body and identity across equip, unequip, class switching and reload. A valid hash for each file does not make switching between two different foundations acceptable. The attempted male Everyday account integration selected v3 only when equipped and restored legacy anatomy when removed; that approach is superseded. Tanya directed “Push the male robes and every day outfit to the app” on 2026-10-04, then selected the non-restrictive legacy migration: replace the legacy male foundation with locked v3 and preserve existing outfit availability. All five male class defaults and Everyday equip/unequip/restoration must use the same full v3 body and identity. Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle remain available and owned; fit garments to v3 without clipping or substituting the primary body. Everyday account support is female + neutral + male; Woodland remains female-only. Migration `20261004164110` supersedes the temporary restriction applied before the concurrent decision was reconciled. No new art lock or production promotion is inferred.


## Latest male sleeve and thumb repair (2026-10-04)

Tanya additionally reported dark outer sleeves and persistent thumb-adjacent holes. This newer instruction supersedes the earlier rear-only scope: `tool/male_robe_edge_repair_reference.json` permits new foreground RGB surfaces inside the existing alpha masks and a garment-only occlusion contour. The Everyday file stays one byte-identical overlay; only when a robe is worn, the renderer clips its hidden trouser pixels beside the thumbs. Never wrap or clip the body with that contour. The whole original body and hands remain visible at their original registration, with the existing repaired rear lining behind them. Collar, cuffs, rear, all historical files and every front alpha remain unchanged. This scoped correction does not establish a new founder lock.

Lesson: alpha-only thumb checks can pass while an opaque trouser layer still covers the lining. Inspect final composite color and actual renderer depth, not just rear opacity. Check all class colors, garment-only clipping, equip/unequip and the complete hand silhouette.
