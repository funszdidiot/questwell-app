# Female Scout robe fitted to the accepted body

Tanya requested this refit after accepting the unified Woodland Scout dimensions. Follow `FEMALE_FIT_STANDARD.md` and `tool/female_avatar_fit_reference.json` for future female clothing.

Built-in image generation retained the rustic olive open-front robe, flax fern embroidery and narrow brown trim. The full-length sleeves were fitted to the fixed shoulders and arms, with extra width directed inward and tapered wrist hems. The long skirt follows a smooth waist-to-hem line, without extra hip volume.

`tool/art_assets/scout_female_v7/robe_fitted_source.png` is the selected complete front drawing. `bash tool/export_scout_female_v7.sh` uniformly normalizes it to 195 × 260 and places it at (19, 44) on the shared 240 × 320 canvas. The exporter separates existing cuff pixels into the foreground depth pass; it adds no local artwork patches. The previous continuous back panel is lengthened to follow the new hem and stays behind the body. The obsolete detached rear cuff strip is no longer rendered for the female fit.

The original body, head/hair, everyday underclothes and boots remain unchanged. The robe's front and cuff passes recombine into the original normalized front drawing. A read-only arm-coverage check found no clear skin gaps; one left-shoulder boundary pixel is antialiased (cloth alpha 226/255). The composite was inspected for shoulder, inner-arm, wrist, waist and back-panel placement.

Founder accepted the completed female fit on 3 October 2026 (“It’s perfect”) and requested Alchemist next using the locked dimensions. This robe is the accepted female class-robe fitting reference. Scout deployment f83929c passed Flutter Check 37134425340 and Preview 37134425248; the live three-stage comparison was inspected. No merge or launch is authorized.
