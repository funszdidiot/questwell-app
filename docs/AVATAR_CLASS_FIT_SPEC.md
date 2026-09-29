# Questwell Avatar Class Clothing Fit Spec

## Purpose
All class garments must look worn by the approved business-suit avatar, not layered as a flat costume. The base avatar is the anatomical source of truth. Class art changes clothing identity only; it must not change apparent body proportions.

## Asset contract
**Base avatar owns:** head, hair, face, neck, hands, business suit, shirt, tie, belt, pants, shoes.

**Class overlay owns:** class garment only. No anatomy or base clothing may be baked into a class overlay.

Canvas: **240 x 320** transparent WebP, aligned 1:1 with the corresponding base avatar.

Body-specific files are required for Male, Female, and Gender Neutral. Do not reuse one garment geometry and scale it for the other bodies.

## Fit anchors
Fit each garment to these base-avatar landmarks:
1. neck base
2. left/right shoulder points
3. left/right armpit points
4. chest edges
5. natural waist / belt line
6. left/right elbow path
7. left/right wrist
8. visible hand start/end
9. hip line
10. hem target

The sleeve must follow the actual arm path: **shoulder -> upper arm -> elbow -> forearm -> cuff**.

The torso must follow: **neck -> shoulder -> armpit -> chest -> waist -> hip**.

## Pass / fail
### Shoulders
PASS: garment shoulder seam sits on the avatar shoulder line and follows its slope.
FAIL: a second, wider shoulder line appears.

### Sleeves
PASS: sleeves follow each arm's real angle and bend.
FAIL: sleeves hang as generic straight tubes.

### Cuffs / hands
PASS: cuff ends immediately before the exposed hand; the hand remains readable.
FAIL: hands are swallowed, detached, or floating outside the cuff.

### Chest / lapels
PASS: shirt and tie are naturally framed and centered.
FAIL: lapels create a wider torso than the base avatar.

### Waist
PASS: garment taper aligns with the base belt / natural waist.
FAIL: coat pinches at a different vertical position or remains boxy.

### Lower coat
PASS: hem preserves believable leg length and stance.
FAIL: coat changes perceived avatar height or blocks the stance.

## Body-specific QA
**Male:** keep structured shoulders but no excess width; sleeves must terminate at the actual wrists.

**Female:** narrower upper torso and shoulder span; sleeve path must follow the narrower arm geometry.

**Gender Neutral:** balanced silhouette; do not use a resized Male geometry.

## Required review surfaces
Every class garment must pass in:
- main Adventurer portrait
- Male selection card
- Female selection card
- Gender Neutral selection card

A class is not visually complete until all three bodies pass both portrait and card review.

## Developer fit checklist
Freeze the approved base avatars. Complete **Scholar** for one body type at a time, then compare all three at the same portrait size. Do not start Scout refitting or generalize the template until Scholar passes founder review.

- [ ] Start from the approved business-suit base for the matching body type. Record head height, neck base, both shoulder points and slopes, chest width, waist, elbow paths, wrist and hand positions, inseam and leg opening, and portrait-frame height on the 240 x 320 canvas.
- [ ] Export a garment-only transparent 240 x 320 WebP for that body type. Preserve the base head, hair, face, hands, pants, and shoes; do not bake them into the garment.
- [ ] Place each shoulder seam on the corresponding base shoulder. Trace each sleeve through the elbow and stop the cuff at the wrist, with both hands visible.
- [ ] Fit the lapels around the shirt and tie; taper at the base waist; keep the hem clear of the stance and shoes.
- [ ] If one flat overlay cannot follow the anatomy, author separate torso, left sleeve, right sleeve, and collar/shoulder layers on the same coordinate system. Keep their stacking order explicit and preserve visible hands.
- [ ] Stack base and overlay at exactly the same canvas origin and scale. Check the male, female, and gender-neutral composites individually at native size and at the small selection-card size.
- [ ] Switch among the three Scholar body types. The head position, shoulder width, hand contact, baseline, and apparent height must remain consistent with each selected base.
- [ ] Inspect the main Adventurer portrait and all three selection cards on iPhone Safari. Capture each Scholar body type for founder review; record pass or a specific failed anchor for every image.
- [ ] Keep the business suit underneath each starter class robe or coat. Show 0 / 5 accessory slots and no equipped accessories at this stage.

### Current asset audit (2026-09-29)

| Class | Male | Female | Gender Neutral | Next action |
| --- | --- | --- | --- | --- |
| Scholar | 240 x 320 | 240 x 320 | 240 x 320 | **Active template.** Prior founder feedback: shoulders do not match base shoulders, sleeves/arms misalign, sleeves appear bulky and overwhelm the hands, and the coat floats. Rebuild and review each body on iPhone Safari; dimensions alone do not establish acceptance. |
| Scout | 384 x 512 | 384 x 512 | 384 x 512 | **Hold.** Once Scholar is approved, reauthor all three garment-only coats on their matching 240 x 320 base canvases using the accepted fit rules. |

Do not mark Scholar complete based on a passing build. Record the founder's visual decision for each body type before applying the template to Scout or promoting Epic 2.

## Implementation rule
Do not compensate for bad art with a second generic runtime scale or translation. The final asset itself must be authored/fitted to the 240 x 320 body-specific canvas. Runtime rendering should stack the base and class overlay 1:1.

## Build source correction — 2026-09-29
The preview pipeline was decoding the older `tool/art_assets/scholar_*.b64.*` files over the newer committed WebPs on every build. This restored the wide cuffs and lower shoulder line even after the body-fit commits. All three compiled robes differed from the committed fit.

Both workflows now verify the committed base and Scholar WebPs with `tool/verify_avatar_assets.py`. The compatibility materialization script also verifies without writing. `tool/avatar_assets.json` records all six SHA-256 values and requires a 240 x 320 transparent WebP. Legacy base64 chunks are historical inputs only and are not build sources.

Verified locally:
- [x] All three base/robe pairs use the same 240 x 320 transparent canvas.
- [x] Build preparation preserves all six files byte for byte.
- [x] Substituting an older staged robe causes validation to fail.
- [x] Compared base, previous build art, and committed fit for each body. The committed fit places the sleeve cuffs at the wrists and exposes the hands; the previous build art covered them with flared cuffs.
- [x] Added `scholar-fit-review.html` to preview for direct inspection of all three portraits and 176 px selection cards, with a robe toggle and alignment guides.
- [ ] Founder iPhone Safari acceptance of the actual fitted Scholar art.

The development review page uses the exact same source assets and 1:1 stack as the app. Its SHA prefixes identify the intended robes. Keep Scholar as the template candidate until its visual review is accepted.

## Release gate
Reject the garment if any of these appear:
- floating coat
- oversized shoulders
- disconnected sleeves
- cuffs that miss wrists
- swallowed hands
- torso wider than the base body
- one body type looking like a resized version of another
