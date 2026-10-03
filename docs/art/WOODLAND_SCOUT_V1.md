# Woodland Scout outfit — female fitting candidate

Update 2026-10-03: Tanya authorized the finished female outfits in the development app, including the v6 robe as the female Scout default. The robe is the class-family design template, but male/neutral paper dolls must come before fitting those bodies or other class robes. See `FEMALE_WARDROBE_RELEASE.md` for the current integration and validation status. Earlier review notes below record the fitting history.

The founder accepted the Woodland Scout concept and requested separate avatar layers. This adds a new outfit alongside the rustic robe, starting with the fixed female body. It does not replace the previously fitted robe or any equipped wardrobe.

## Artwork and fitting

The four independent sprites are the rolled-sleeve ivory shirt, moss leather vest with its belt and small pouch, reinforced brown trousers, and folded leather boots. Built-in image generation created each transparent garment using the female paper-doll base as the registration reference and the accepted concept as the design reference. The full shirt exists underneath the vest, so removing the vest reveals complete clothing rather than a hole.

The generated PNG pixels remain unchanged. `tool/woodland_scout_fit.json` records their SHA-256 identities and garment-only registration on the 240 × 320 avatar canvas. Shirt, vest and boots use simple scale/translation. Trousers use monotonic vertical sections to fit waist, crotch, knees and ankles without changing the base body's pose. No anatomy is erased, repainted, translated or substituted. The renderer adds garments above `paper_doll_female_v1.webp` and restores the same fixed head/hair overlay. Existing explicit grimoire/lantern grip handling remains available.

Source direction: preserve the accepted moss leather vest, three brass closures, restrained botanical embroidery, rolled ivory blouse, reinforced trousers and worn boots; remove all human pixels from each garment; retain opaque cloth and transparent neck/arm/leg openings. The body is never taken from a generated dressed illustration.

## Development review

`?review=woodland-scout` shows **Underwear → Shirt and trousers → Woodland Scout**. Each stage has the same canvas size. Four controls toggle clothes independently; the base stage stays undressed. Sleeve detail, existing accessories, grimoire and lantern are available. Phone views scroll the comparison horizontally.

The fitting is female-only. Male and gender-neutral versions require their own body-specific fitting. Technical validation and final in-app visual approval are separate gates. No Market item, inventory grants, production merge, or launch is part of this change.

## Verification

Code/art revision `b70abf66ca651c787d0ba32260fad653be4637ea` passed Flutter Check `37101241975` and Preview `37101242029`. The fixed-body test covers all 16 clothing subsets and restoration of the normal avatar after leaving the candidate. The comparison remains scrollable at 320/390 pixels for both fitting modes. The asset verifier passed with the fixed base, earlier robe and all previously locked assets unchanged; generated PNG identities and monotonic fitting transforms were also checked.

Live browser review verified the three equal-scale stages, rolled-sleeve detail, trouser/boot coverage, brass lantern, grimoire grip and accessories. No application errors appeared; the cloud browser reported its expected CPU rendering fallback. Final review URL: https://funszdidiot.github.io/questwell-app/?review=woodland-scout&rev=b70abf6 . This technical and browser review is not founder visual acceptance. Final female fit approval and physical-phone review remain outstanding, as do any male/neutral variants.
