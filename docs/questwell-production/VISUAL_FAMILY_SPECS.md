# Questwell Hearth Visual Family Specifications

## Purpose

This document is the production contract for Hearth art families. It exists so swapping one equipped item for another feels intentional, predictable and visually uniform.

The Hearth concept stays stable. New artwork fits the room; the room does not reshape itself around every new asset.

These specifications apply to standard, seasonal, limited and event décor.

## Locked art direction

Questwell remains a **high-detail 64-bit-era cozy fantasy RPG**.

Polish means:
- deliberate pixel/sprite craftsmanship;
- stepped, readable silhouettes;
- tactile material clusters and controlled dithering;
- selective highlights and shadow bands;
- restrained magical effects;
- clean alpha edges;
- strong readability at actual Hearth scale.

Polish does **not** mean:
- photorealism;
- painterly concept-art rendering;
- smooth vector illustration;
- modern 3D realism;
- soft AI-style edge smearing;
- excessive glow used to hide weak geometry.

Approved benchmark pieces include:
- Autumn Ember Lantern;
- walnut bookshelf;
- burgundy reading chair;
- First Journey trophy.

The Warding Lantern and Emerald Wayfarer Rug remain candidates until founder approval and must not be used as quality benchmarks while unapproved.

## Global asset rules

### Source and export

- Transparent décor uses PNG or WebP with alpha.
- Runtime pixel art uses `filter_mode=pixel` / nearest-neighbor filtering unless a locked system explicitly requires another mode.
- Room backgrounds/settings may use smooth filtering because they are full-scene authored environments.
- Do not bake a room background into a furniture sprite.
- Do not bake a contact shadow into ordinary furniture when a reusable shadow profile exists.
- Do not add transparent padding to manipulate runtime scale or placement.
- Record source canvas width, height and visible ground/contact edge in render metadata.

### Lighting

Default Hearth lighting is warm, upper-left / front-biased ambient light with darker lower/rear planes.

A magical object may introduce a secondary local light, but:
- the effect may not erase the 64-bit silhouette;
- glow may not become the dominant shape;
- nearby décor should not appear to change its material palette because one item is equipped.

### Quality at runtime scale

Every item must be reviewed:
1. as a standalone transparent asset;
2. in its canonical Hearth slot;
3. beside at least one approved benchmark;
4. with the avatar visible;
5. without the avatar;
6. on compact mobile width;
7. on wide web width.

A technically valid asset that looks cheaper, flatter, blurrier or more AI-like than the approved room fails visual QA.

## Family geometry contract

The current renderer uses avatar-relative visual height. The family owns scale and grounding; artwork owns only aspect ratio and its visible-contact edge.

### 1. Large furniture

**Backend profile:** `large_furniture`  
**Slots:** `left`, `right`  
**Visual height:** 0.50 × authored avatar height  
**Floor depth:** 0.69 × scene height  
**Default shadow:** `wide_plinth`  
**Render kind:** `static_sprite`

Typical items:
- bookcases;
- workbenches;
- large display cabinets;
- apothecary furniture.

Art requirements:
- recommended visible aspect ratio range: 0.90–1.15;
- feet/plinth/base must have an unambiguous contact edge;
- broad furniture should feel weighty without touching the outer Hearth frame;
- primary verticals should remain readable after pixel filtering;
- decorative clutter must not exceed the silhouette envelope.

Benchmark: walnut bookshelf.

### 2. Pedestal lights / standing magical lamps

**Backend profile:** `pedestal_light`  
**Slots:** `left`, `right`  
**Visual height:** 0.52 × authored avatar height  
**Floor depth:** 0.72 × scene height  
**Default shadow:** `pedestal`  
**Render kind:** `static_sprite`  
**Optional effects:** `warm_glow`, `ward_glow`

Typical items:
- standing lanterns;
- ward lights;
- magical floor lamps;
- small pedestal beacons.

Art requirements:
- silhouette must read before glow is applied;
- base/stand must clearly reach the floor;
- local glow remains restrained and secondary;
- ornament may be asymmetric, but the object must feel structurally balanced;
- avoid smooth symmetric SVG-like construction.

Benchmark: Autumn Ember Lantern.

### 3. Seating

**Backend profile:** `seating`  
**Slots:** `front`, `right`  
**Visual height:** 0.62 × authored avatar height  
**Floor depth:** 0.86 × scene height  
**Default shadow:** `seating`  
**Render kind:** `static_sprite`

Typical items:
- reading chairs;
- seasonal armchairs;
- compact benches only if they fit the seating envelope.

Art requirements:
- seat height must remain believable beside the avatar;
- legs/base must read clearly against the Hearth floor;
- upholstery texture must survive actual runtime scale;
- item may overlap the avatar intentionally; do not shrink it to avoid natural overlap.

Benchmark: burgundy reading chair.

### 4. Plants

**Backend profile:** `plant`  
**Slots:** `left`, `right`, `front`  
**Rear visual height:** 0.40 × authored avatar height  
**Front visual height:** 0.43 × authored avatar height  
**Rear floor depth:** 0.70 × scene height  
**Front floor depth:** 0.86 × scene height  
**Default shadow:** `plant`  
**Render kind:** `static_sprite`

Art requirements:
- pot/container provides the physical contact point;
- foliage can break the nominal width visually but cannot collide with the outer frame;
- leaf clusters should use readable 64-bit shapes, not fuzzy brush noise.

### 5. Side tables

**Backend profile:** `side_table`  
**Slot:** `side`  
**Visual height:** 0.49 × authored avatar height  
**Floor depth:** 0.89 × scene height  
**Default shadow:** `side_table`  
**Render kind:** `static_sprite`

Art requirements:
- table surface remains readable under small props;
- legs must remain visible on compact screens;
- do not embed a seasonal chair or large prop into the table sprite;
- the table may shift left/right based on chair placement, but its own scale is fixed.

### 6. Floor rugs / textiles

**Backend profile:** `floor_rug`  
**Slot:** `floor`  
**Render kind:** `floor_sprite`  
**Shadow:** `none`

Canonical runtime footprint:
- left: 0.22 × scene width;
- top: 0.69 × scene height;
- width: 0.56 × scene width;
- height: 0.26 × scene height.

Art requirements:
- perspective must already match the canonical floor plane;
- no runtime perspective warping to rescue a flat rectangular design;
- weave, fringe and border must read as textile, not vector-panel decoration;
- center motifs must remain legible beneath the avatar without competing with it;
- corners must not appear to float;
- edge texture should show handcrafted variation without becoming noisy.

The Emerald Wayfarer Rug is not a benchmark until founder-approved.

### 7. Wall art — side

**Backend profile:** `wall_art_side`  
**Slots:** `wall_left`, `wall_right`  
**Render kind:** `wall_art_sprite` through the generic Hearth render registry

Architectural envelope: use the shared Original or Hallowed gallery resolver
in `QuestwellHearthDecor.wallArtBounds`, including its responsive cover crop.
Side frame aspect ratio remains 0.58 width/height. Do not add theme-specific
scale exceptions or a third compact-gallery layout.

Art requirements:
- frame is part of the wall-art asset/system;
- composition must remain readable at small display size;
- no tiny text;
- avoid high-frequency detail that collapses to noise.

### 8. Wall art — center

**Backend profile:** `wall_art_center`  
**Slot:** `wall_center`  
**Render kind:** `wall_art_sprite` through the generic Hearth render registry

Architectural envelope: use the same two-family gallery resolver as side art.
Center frame aspect ratio remains 1.4 width/height.

Center pieces may be wider but must not visually overpower the avatar or fireplace.

### 9. Relic displays

**Backend profile:** `relic_display`  
**Slots:** `left`, `right`, `front`, `mantel`, `bookshelf_top`  
**System:** mastery relic renderer

Rear visual height: 0.40 × authored avatar height  
Front visual height: 0.49 × authored avatar height

Relic displays are a special authored system because floor furniture and the class artifact share lighting/perspective.

Do not treat ordinary seasonal furniture as a relic display.

### 10. Surface collectibles / trophies

**Backend profile:** `trophy_surface`  
**Slots:** `mantel`, `bookshelf_top`  
**System:** milestone/trophy renderer

Surface collectibles are intentionally smaller than floor décor and are anchored relative to the fireplace or bookshelf.

New milestone trophies may require system registration because unlock behavior is gameplay, not merely decoration.

### 11. Window features

**Backend profile:** `window_feature`  
**Slot:** `window`  
**System:** window renderer

Current example: Rainy Window.

Animated/interactive windows are special systems. A simple static seasonal window may later become registry-driven, but do not silently route an animated feature through `static_sprite`.

### 12. Hearth settings / room environments

**Backend profile:** `hearth_setting`  
**Slot:** `setting`  
**System:** full-scene setting renderer

Settings replace the environment, not a piece of furniture.

Requirements:
- must preserve avatar and canonical décor readability;
- must preserve the same functional slot map unless founder-approved otherwise;
- use one of the two founder-selected architectural standards below;
- motion overlays are separate from the background asset.

A new setting is a higher-risk visual/system change than a new furniture skin and receives explicit runtime review.

Tanya selected these standards on October 9, 2026 using the Original and Hallowed
Hearth screenshots. Original has an open back wall, left-side fireplace and
right-side window. Hallowed has a front-facing chimney/fireplace and arched
right window. Original, Woodland Cottage, Midnight Harvest, Enchanted Library,
Midnight Observatory, Alchemist’s Workshop, Astral Sanctuary and Emberglass
Conservatory belong to the Original family. Hallowed belongs to the Hallowed
family. Future room surfaces inherit one of these architectures; a third
architecture requires a new founder decision. Existing assets remain intact.

Equipped wall hangings carry between rooms, including empty wall slots. Other
decorations retain their room-specific saved arrangements. Preview and saved
Hearth rendering share the same placement geometry.


## Shadow profiles

Reusable shadow profiles are part of the rendering system:

- `wide_plinth` — large furniture;
- `pedestal` — standing lights / narrow floor objects;
- `seating` — chairs and seats;
- `side_table` — small four-leg or pedestal tables;
- `plant` — pot-based plants;
- `none` — floor textiles and assets whose system supplies its own grounding.

A new ordinary item should reuse a shadow profile. Creating a new shadow profile is allowed only when existing profiles materially fail the physical object, and it requires visual QA across at least two candidate assets before becoming a shared standard.

## Effect profiles

Current reusable effects:
- `ward_glow`;
- `warm_glow`.

Effects are optional. The asset must look finished without the effect layer.

A new effect profile that materially changes the room atmosphere should be treated as a visual-system change rather than a routine item variant.

## Family assignment rules

Use an existing family when the item's physical role is already represented.

Examples:
- winter lantern → `pedestal_light`;
- Halloween armchair → `seating`;
- solstice bookcase → `large_furniture`;
- anniversary rug → `floor_rug`;
- holiday framed print → `wall_art_side` or `wall_art_center`.

Stop for founder review when:
- the concept needs a new canonical room space;
- the item cannot fit an existing family without changing scale/placement;
- a new visual family is required;
- the item changes the room's functional layout;
- a special interactive/animated renderer is required and no locked system exists.

## Wearable family rules

Seasonal wearables use the paper-doll methodology governed by LOCKED_TEMPLATE_REGISTRY.md.

The registry, not this document, decides which body/template versions are currently locked.

### Same-body invariant

For every supported body:
- the locked avatar body/identity remains unchanged;
- clothing fits the body;
- the body is never altered to make clothing fit;
- equip, unequip, class change and reload must restore the same underlying body.

### Body-specific production

Female, male and neutral are independently fitted production targets.

Do not:
- stretch one body's clothing onto another body;
- use anatomy changes to hide garment gaps;
- split a previously locked coherent outfit into independent fragments without reopening the template.

### Seasonal derivatives

A seasonal derivative may normally change:
- palette;
- fabric/material appearance;
- trim;
- embroidery;
- motif;
- small non-structural ornament.

It may not silently change:
- silhouette;
- sleeve/cuff geometry;
- neckline/shoulder fit;
- waist/hip geometry;
- crotch/inseam coverage;
- heel/sole coverage;
- rear-panel ordering;
- equipment interaction.

Any such change is a template change and requires the appropriate founder gate.

### High-risk seams

Every wearable derivative must inspect:
- neck and shoulders;
- both cuffs and hand edges;
- underarms;
- waist and hips;
- crotch/inseam;
- inner legs;
- heels/soles;
- rear/front layering;
- translucent backing beside hands;
- restoration after unequip.

### Accessories

Accessories may layer around the locked body but must not:
- replace hands to carry an item;
- distort anatomy;
- require body clipping;
- reintroduce retired equipment patterns.

A genuinely new equipment interaction is a system/template decision, not a routine seasonal reskin.

## Release acceptance

A family-compliant item is not automatically approved.

The production agent may:
- create variants inside a locked family;
- register metadata;
- run preflight and development integration;
- iterate on technical defects.

The production agent must not:
- lock a new aesthetic direction;
- activate a paid release;
- change approved economy/pricing;
- launch a seasonal collection without the required founder authorization.
