# Two architectural furniture maps — October 9, 2026

Status: QA. Tanya clarified that artistic room versions share a structural layout
and directed implementation of exactly two furniture maps. Prior PR #120 fixed
camera registration but its spatial acceptance was too broad: rear cabinets
could still straddle fireplace/support posts, and the table obscured the chair.

Original Hearth and all seven square artistic variants share the same map object.
Hallowed uses the second map. Large furniture belongs on suitable flat wall/bay
spaces, not generic floor anchors. Cabinets use front contact just in front of
measured baseboards. Seating/cushions remain in lower floor areas. Tables are
smaller with limited arm-edge overlap and nearly the same floor depth as seating.
All family sizes and contacts follow source-art coordinates, including seating;
changing viewport ratio no longer recomposes foreground furniture separately.

The standard cabinet envelopes clear both timber posts; foreground avatar
occlusion is intentional, rather than moving cabinets into the fireplace or
walkway to keep them artificially visible. Hallowed preserves the fire opening.
Same-family invariants, artwork proportions and the two-map inheritance rule
remain explicit. Bodies, sprites, saved semantic slots, ownership, backend
eligibility and room memory are unchanged. No migrations or economy changes.

QA includes actual Moonbrew/velvet/witchlight metadata, the reported left copper
cabinet/right chair/Moonbrew combination, cushions and 760px desktop framing.
A source review corrected the standard right cabinet to avoid the right post.
The review tightened the old .065H floor-gap allowance to .025H and added whole
cabinet/seat overlap checks. CI exports 288 compositions: nine skins, eight
arrangements, four viewports. Actual visual and hosted results remain pending.

Use existing GitHub CI for Flutter. Local Flutter startup was rejected earlier;
no retry is required. Required CI, independent rendered review and hosted
revision verification must pass before claiming deployment. Founder design
acceptance remains separate from technical QA. No production promotion.
