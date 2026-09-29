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

## Implementation rule
Do not compensate for bad art with a second generic runtime scale or translation. The final asset itself must be authored/fitted to the 240 x 320 body-specific canvas. Runtime rendering should stack the base and class overlay 1:1.

## Release gate
Reject the garment if any of these appear:
- floating coat
- oversized shoulders
- disconnected sleeves
- cuffs that miss wrists
- swallowed hands
- torso wider than the base body
- one body type looking like a resized version of another
