# Female wardrobe integration — 2026-10-03

Tanya requested the Woodland Scout and other finished outfits in the app. She specified that the new rustic robe replaces the Scout robe and supplies the shape and layering template for other class robes. She then clarified the prerequisite: male and neutral avatars need their own complete paper-doll foundations before adapting their clothes or class robes.

## Current release scope

- Female Scout default: the accepted v6 rustic robe, complete fixed underwear body, separate everyday shirt/trousers/boots, rear cloth and separate rear/front cuffs. Unequipping another chest outfit restores this default.
- Woodland Scout Outfit: one chest selection, rendered internally as four separate garments over the fixed female body. Every class; 120 earned coins.
- Everyday Adventurer Outfit: one chest selection, using the fitted ivory shirt, brown trousers and boots. Every class; 40 earned coins.
- Both catalog outfits are female-only until the other body-specific fits exist. Market and inventory label this restriction; purchase/equip enforce it on the server. Body changes retain ownership and unequip incompatible clothing. Existing feet equipment replaces the included boots.

The source artwork is unchanged. Male/neutral avatars and other class robes retain their current artwork. No merge to `flutterflow`, invitations, external beta or launch.

## Required next sequence

1. Build and review a complete male underwear paper doll with its original face, hair, hands, stance and limb proportions.
2. Build and review the neutral underwear paper doll under the same rules.
3. Fit separate everyday clothing, Woodland Scout layers and the rustic Scout robe to each body. Validate back-panel order, wrists, hips and feet separately.
4. Only then adapt the class robe family from the accepted robe template. Keep the silhouette and wrapping construction consistent; vary the class colors and decorative patterns. Do not stretch the female fit over a different body or treat an unreviewed body as approved.

## Verification

Database migration `20261003061842_female_paper_doll_wardrobe` stages both catalog entries inactive, preserving existing privilege boundaries. Its purchase/equip/body-switch checks passed with synthetic users inside a rolled-back transaction: each outfit purchases once, retries do not debit twice, only one chest item stays equipped, removal retains ownership, and unsupported body fits are rejected. Security advisors returned no notices. The local CLI could not generate a migration file because its telemetry directory is read-only; the checked-in migration filename mirrors the actual Supabase migration version.

Flutter and live app verification pending. Activate catalog and add unequipped founder copies only after the development build passes.
