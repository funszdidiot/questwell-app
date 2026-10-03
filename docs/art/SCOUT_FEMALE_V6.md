# Female paper-doll fitting — revision 6 candidate

Update 2026-10-03: Tanya authorized the finished female outfits in the development app, including the v6 robe as the female Scout default. The robe is the class-family design template, but male/neutral paper dolls must come before fitting those bodies or other class robes. See `FEMALE_WARDROBE_RELEASE.md` for the current integration and validation status. Earlier review notes below record the fitting history.

The v5 review replaced arms and the lower body when rendering clothing, bundled boots into trousers, and used a broad robe-under cutout. Those shortcuts made clothing repairs change the apparent avatar. V6 restores a fixed paper-doll foundation in the development fitting preview.

## Fixed foundation

`base/paper_doll_female_v1.webp` is one complete underwear avatar on the shared 240 × 320 canvas. Every clothing combination uses this exact image, with the same scale and alignment. Her original face, hair, and relaxed grip artwork remain. Arm anatomy is resolved once in the exported base. The loose charcoal shorts hem is tailored once at the air gap between the thighs; that export-time correction only affects charcoal fabric, not skin. No outfit selection regenerates, clips, translates, or replaces this body.

`base/paper_doll_female_identity_v1.webp` restores the same head/hair pixels above garment collars. The body remains a fitting candidate, not founder-approved art.

## Separate clothing

Top, trousers, and boots are independent sprites. The trousers contain no boot pixels. The robe has a continuous rear panel behind the avatar, a front garment, rear cuff openings behind the wrists, and separate curved front cuff hems above them. Narrow accessory masks still handle the explicit book grip and lantern overlap; they do not alter the empty-handed base.

The female path has no `lowerReplacement`, `replacedArms`, or `robeUnder` anatomy mask. Male and neutral candidates retain their earlier fitting until they receive their own accepted templates. The ordinary equipped wardrobe is unchanged: this path requires the development review's `previewScoutLayers` flag.

## Review

The fitting page opens with three equal-size stages: **Underwear**, **Everyday clothes**, and **Robe**. Underwear always uses no clothing or equipment. Top, trousers, boots, and robe controls affect only the dressed stages. Wrist details, accessories, and held objects remain available for inspection. Narrow screens scroll the aligned stages horizontally.

The invariant test cycles all 16 clothing combinations and checks the same body asset, geometry, and alignment; it also checks independent boots and rear/body/front/cuff ordering. These tests establish composition behavior, not visual approval.

## Reproducible artwork

Run, in order:

1. `python3 tool/export_scout_female_v6.py`
2. `python3 tool/export_scout_female_v6_clothes.py`
3. `python3 tool/export_scout_female_v6_robe.py`

The lossless sources live under `tool/art_assets/scout_female_v6/`. Built-in image generation produced the artwork; the exporters normalize canvas size, separate alpha passes, register the rear cloth, and preserve original identity/grip pixels. They do not mesh-warp the body to make garments fit.

Prompt direction: preserve the fixed female pose and identity; remove residual shirt bands from bare arms; fit an ivory short-sleeved linen top, straight brown travel trousers, and compact separate ankle boots; add a softly draped rustic olive Scout robe with narrow brown edging and flax fern embroidery, smooth hips, one continuous back panel, and small cuffs that follow the wrist angle. Targeted follow-up directions corrected garment coverage at the collar/heel and the loose underwear hem. Generated whole-character faces and hands are not substituted for the original identity.

## Acceptance

Founder review must confirm the underwear anatomy, right hip/leg, waist contact, independent footwear, shoulder coverage, natural wrist contact, and robe silhouette in the actual app. Only then may this body's robe geometry become a color/pattern template. No production merge or launch is authorized by this fitting revision.

## Completed development verification — 2026-10-03

Implementation `e646d85d374138e99edf7c2bbbb1e616286e6f74` and phone-test correction `e4618e50b4be493c8762934f1042069bf4ee3d05` are on `questwell-dev`. Final Flutter Check `37100103057` and Preview `37100102961` both passed. Asset integrity verification includes the new candidate assets, source drawings and exporters while preserving all previously locked files. Tests confirm all 16 female clothing combinations retain the same full base, canvas size and alignment, independent boots, and rear/body/front/cuff order. The 320/390-pixel phone checks scroll the page to the comparison row before swiping sideways; the first run failed because that test gesture targeted an offscreen row, and the corrected sequence passes.

The live fitting was inspected in all three stages with empty hands, grimoire, and brass lantern plus accessories. Wrist contact and continuous rear cloth were inspected at the enlarged cuff view. No missing-asset or application error was observed in those views; the cloud browser reported CPU rendering fallback and extension-only metadata errors. This does not substitute for a physical-device test or founder visual acceptance.

Review: https://funszdidiot.github.io/questwell-app/?review=scout-wardrobe&body=female&detail=cuffs&rev=e4618e5

Review image: `questwell-female-paper-doll-v6-1791005614026.jpg`. Female fit acceptance is the next decision. Male and neutral rebuilds, all class color/pattern templates, Market integration, merge and launch remain pending.
