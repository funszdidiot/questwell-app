# Female Alchemist — locked-body refit

Requested 3 October 2026 after founder acceptance of the female fit. This is a female-only adaptation; male and neutral paper dolls must be completed before their next garment fitting. Follow `FEMALE_FIT_STANDARD.md` and `tool/female_avatar_fit_reference.json`.

The robe uses the established sapphire-blue laboratory palette, cobalt shadows, green decorative molecular embroidery, cool silver edging and simple pockets. No flask/beaker emblem, mystical sigils or hanging ornaments. Built-in imagegen edited the accepted Scout front-cloth source with the prior Alchemist art as the surface-design reference; the second pass corrected the inward sleeve coverage and wrist height. The accepted anatomy, face, hair, pose, everyday top, trousers and boots are reused byte-for-byte.

Selected source: `tool/art_assets/alchemist_female_v5/robe_refined_source.png`. Prompts are preserved beside it. `bash tool/export_alchemist_female_v5.sh` registers that whole image at 195×260, offset (15,44), on the standard 240×320 canvas. Only generated cuff pixels are separated into the foreground equipment pass. The existing blue lining is registered behind the body and limited to the accepted Scout rear-cloth mask. No independent runtime garment stretching or anatomy masks.

The shared avatar renderer uses this robe as the female Alchemist default. Everyday and Woodland outfits still replace the whole default; removing them restores the Alchemist robe. The fitting route `?review=alchemist-wardrobe` compares underwear, everyday clothes and robe on the same unchanged body, with cuff detail and equipment controls.

Local asset-integrity and source checks pass. The read-only full-length arm check excludes foreground hair and detects no exposed skin pixels over rows 84–164 at cloth alpha <240. Front and cuff passes recombine to the original registered image. Automated tests cover all 16 female clothing subsets for Scout and Alchemist, default body/asset switching, depth ordering, outfit restoration and 320/390px fitting layouts. CI and deployed visual results will be recorded in `PROJECT_STATUS.md` after the release checks finish.

This new Alchemist visual remains for founder review. Approval of the previous Alchemist design and the frozen female fit does not imply approval of this new rendering. No merge or launch.
