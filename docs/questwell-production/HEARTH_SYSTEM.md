# Questwell Hearth System

## Founder-locked product intent

The Hearth keeps its current cozy-room concept. Decorating must feel simple and predictable:
- spaces stay in the same general places;
- items that occupy the same kind of space use a uniform visual scale and ground line;
- replacing one item with another should not make the room jump, shrink or feel accidentally rearranged;
- every item must meet the same Questwell 64-bit quality standard;
- seasonal and limited releases inherit the same rules instead of inventing one-off placement behavior.

## Full-stack contract

### Supabase owns semantic placement rules

The backend is the authority for:
- which cosmetics are Hearth décor;
- the layout profile assigned to each Hearth cosmetic;
- which slots each profile may occupy;
- any generic placement dependency, such as a bookshelf being required for `bookshelf_top`;
- persistence, ownership and one-occupant-per-slot conflict handling.

Tables:
- `public.hearth_slots`
- `public.hearth_layout_profiles`
- `public.hearth_profile_slots`
- `public.cosmetics.hearth_profile_key`

`private.place_hearth_cosmetic` validates profile → slot compatibility. It must not grow item-by-item slug branches for ordinary décor releases.

Every `room` or `wall_art` cosmetic is required by database constraint to have a layout profile.

### Flutter owns visual geometry

Flutter is the authority for:
- the exact pixel-space anchor of each canonical slot;
- the scale envelope for each décor family;
- z/depth order;
- contact shadows and restrained effects;
- the actual approved 64-bit artwork.

The renderer follows a slot-first rule:

**space/family geometry → item artwork**

not:

**item artwork → custom coordinates**

Item widgets may declare authored aspect ratio and visible contact edge, but must not invent a new room position or independent scale for an existing family.

## Canonical décor families

Current families include:
- large furniture
- pedestal light
- seating
- plant
- side table
- relic display
- surface collectible/trophy
- floor rug
- wall art
- window feature
- Hearth setting

A seasonal/limited cosmetic should join an existing family whenever its physical role is the same. A new family or new canonical space is a product/layout change and requires founder review.

## Canonical slots

Current backend slots:
- `left` — back-left room zone
- `right` — back-right room zone
- `front` — foreground floor zone
- `side` — beside-chair table zone
- `wall_left`, `wall_center`, `wall_right`
- `mantel`
- `bookshelf_top`
- `window`
- `floor`
- `setting`

Adding a new slot is data/schema-contract work, not something an individual art asset may do silently.

## Uniform-scale invariant

For the same family in the same slot:
- visual height is identical within rendering tolerance;
- the visible ground/contact line is identical;
- depth ordering is identical;
- the room anchor is identical;
- only artwork aspect ratio may change the contained width.

Transparent padding must never be used to make an item appear smaller/larger or float above the floor.

## Decorating UX

The Market and Adventurer placement pickers consume backend profile-slot choices. If a slot is occupied, replacement is explicit and the previous item returns to inventory; ownership is preserved.

The client may use a local fallback only for development fixtures/review routes. Account behavior must follow the backend contract.

## Art-quality invariant

Every Hearth item, including seasonal and limited releases, must pass the locked 64-bit visual QA gate against approved benchmark décor. Technical placement success does not imply visual acceptance.

## New décor release workflow

1. Choose an existing décor family and approved slot behavior.
2. Assign the backend `hearth_profile_key`.
3. Author the asset to the family's visual scale/contact-edge specification.
4. Register the art renderer without adding bespoke room coordinates.
5. Verify backend profile-slot choices.
6. Verify same-family scale/ground-line regressions.
7. Review at actual Hearth scale alongside approved benchmark décor.
8. Keep catalog activation/economy changes separate from art approval.

If an item cannot fit an existing family without changing the room layout, stop for founder review rather than hiding a new layout behavior inside the asset.
