# Female fitting, revision 5 — review candidate

The v4 avatar fitting was rejected for hip bulges and unnatural cuffs. The female underlayer also had distorted forearms, clipped hand contours and a kink in the right hip/thigh. None of those previous fittings is an approved template.

## This pass

The female body is being resolved first. Built-in imagegen was used with the actual live female avatar canvas and original identity reference: a direct arm/wrist repair, a targeted trouser contour repair, then a robe painted on that body and a transparent equipment pass. The intermediate full-avatar drawings are references only: their generated faces and hands are not used in the app. The final renderer retains the original face, hair and grip pixels.

The registered sources in `tool/art_assets/scout_female_v5/` contain the corrected arm/top drawing, corrected trousers, and robe sprite. `tool/export_scout_female_v5.py` only separates render passes and applies uniform registration. It does not use the previous local mesh warps. The robe uses one 0.93 scale and (6,18) translation for all its passes, so its painted folds, sleeve contours and front/back alignment stay together. The trousers use one 0.96 scale and (4.8,4) translation. Arms and top use the original canvas registration.

The back skirt panel renders behind the avatar and clothing. The front robe and attached cuff lips render over the wrists, with the front cuff pass retained for held objects. The underlying wrist window starts at y=166 for this female fit. The old hand masks began too low and cut the skin contours: the female review now includes the complete original hands below the original suit cuffs, while excluding adjacent suit trouser pixels. The clean-arm correction belongs to the base, so it remains when clothing is toggled off.

The review opens on the female fit and can display the corrected base beside the robe, at the same scale. Male and neutral candidates remain at v4. The original locked base/class files are unchanged. This is development-only; no production merge, inventory change, or acceptance is implied.

## Acceptance gate

Review the actual in-app image for arm taper, wrist continuity, right hip/thigh contour, shoulder contact, open front, back panel and hem. Also inspect held objects at the sleeve contact. Technical checks do not establish art acceptance. Only after the founder accepts this fit does it become the female geometry template. The other body types must then be constructed and accepted independently before any class color/pattern variants.

## Generation provenance

Built-in imagegen was used, with transparent alpha, under identity-preserve / precise-object-edit / compositing requests. Core direction: preserve the original identity and stance; correct only distorted arms/wrist joins and the right trouser contour; draw the rustic olive Scout robe on the body with straight hip seams, small wrist openings, natural cloth folds, narrow brown edging, flax fern embroidery and a continuous back panel. Intermediate generated avatars are not replacements for the approved base identity.
