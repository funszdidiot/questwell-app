# Cloak and mantle inner-flap removal

Status: **DEV DEPLOYED** — 2026-10-05. Runtime `e46a42bf8c14debd2ad338c12228f16da39f46ca`, workflow `37312732888` passed analysis, 386 Flutter tests, 8 Node tests, asset verification, build and deployment. Analyzer retains 45 nonfatal baseline findings.

Delivered version and all 31 garment/body/identity/Everyday hashes match (`tool/qa/legacy_depth_delivery.json`). Actual shared-renderer gallery checked all nine fits and all three bodies' unequip-to-Guardian-robe restoration. Independent review of delivered screenshots passed all nine. Male sample Market coat preview, purchase, equip and unequip checked; fixture coins only, no account persistence claim. Existing catalog/class eligibility and equipment policy are unchanged and covered by regression tests.

Evidence: `natural-drape-male-live.jpg`, `natural-drape-female-live.jpg`, `natural-drape-neutral-live.jpg`. No founder lock inferred; no founder blocker.

Tanya requested removal of the unwanted hanging inner flaps from the cloak and mantle. Scope: all six body-specific Moss-Green Cloak and Hearthguard Mantle fits. Preserve outer cloth, embroidery, collars, registration and arm/hand coverage. The central front opening must not contain extra lining tongues or doubled inner hems.

Her follow-up additionally requires a continuous rear cloth layer behind the complete avatar, natural body-specific shoulder drape, and wider Harvest Coat cuffs that visibly wrap around the wrists. “Helm” is interpreted as Hearthguard Mantle in the current cloak/mantle context. Business Suit stays outside this correction. Cuff openings must have a rear rim and curved foreground lip without obscuring original thumbs or replacing hands.

Keep every locked body, identity and Everyday asset unchanged. Historical v3 garment exports remain preserved; replacement exports require independent composite QA, complete technical gates and delivered-runtime verification. No new founder lock is inferred.

Latest founder corrections: narrow male coat elbows while keeping widened wrist
openings; replace the excessive cloak/mantle flare with natural gravity-hanging
cloth. The six broad candidates were rejected before deployment. Do not confuse
the prior deployed baseline with acceptance of these replacements. Natural drape
is now recorded in PAPER_DOLL_STANDARD.md and LESSONS_LEARNED.md for future work.

Independent review of all nine final composites passed at native and 3× size on
light/dark backgrounds. A female mantle candidate with unsupported pinched folds
below the hands was rejected and replaced with continuous downward drape before
the final pass. The male mantle's thin outer-arm leak was corrected in connected
cloth before passing. No founder lock is inferred from this technical review.

Local gates: all 18 runtime WebP hashes/canvases/depth checks pass, all six
cloak/mantle fronts cover intact arms/hands, center fronts are clear, rear cloth
is continuous, coat cavities lie behind unchanged wrists, all frozen assets
verify, 8 Node tests and seasonal structure validation pass, and git diff has no
whitespace errors. Flutter is unavailable locally; the existing mandatory remote
analyzer/full Flutter regression/build gate is required before delivery.

Runtime paths: cloak/mantle front + rear v4; coat front + cuff-cavity rear v6.
The shared renderer places all rear layers before the whole locked foundation.
Catalog ownership, body/class eligibility, prices, grimoire attachment and
equipment policy are unchanged. Sources, edit brief, reproducible exporter and
hashes: `tool/art_assets/legacy_depth_v1/` and `tool/export_legacy_depth_v1.cjs`.
