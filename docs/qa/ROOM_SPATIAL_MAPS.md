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


## Independent rendered review — passed

Head `8e5751a`, Flutter Check `38021548251`, artifact `11658386634`:
all 288 compositions plus 18 window captures passed independent visual review.
Native 760/284 checks confirm standard cabinets clear the fireplace/post and
sit against the wall. Partial foreground-avatar occlusion leaves readable
furniture frontage. Hallowed cabinet/bookshelf positions clear the fire. Tables
sit outside chair arms with clear seats and legs; cushions remain on the floor.
All 252 non-reported compositions and 18 window captures are byte-identical to
the preceding source-identical run. The 36 reported captures now use Pumpkin
Court through the correct chest slot.

CI passed 1,075 full tests, 27 feature-enabled decorator checks, 418 Chrome tests,
analyzer/format, native builds, both web packages, backend and six guard workflows.
A concurrent familiar-visibility merge required combining `fadaf96`; only the
dashboard text conflicted, and both entries were retained. Furniture code/art
is unchanged. Fresh combined CI and hosted review are still required. PR #126
is the delivery record for the final head, deploy run and hosted verification;
this snapshot does not claim physical iPhone or signed-in acceptance.
