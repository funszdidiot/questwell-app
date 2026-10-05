# Seasonal and Limited Release Playbook

## Goal

Make seasonal, limited, event and founder-beta drops fast and repeatable without degrading Questwell's 64-bit visual identity, avatar methodology, Hearth architecture, economy controls or user ownership history.

The production agent should be able to carry a release from an approved brief through development integration and technical QA with minimal founder interruption.

A release is **not live** merely because:
- its dates are present;
- its art exists;
- CI passed;
- a development preview deployed;
- its manifest says scheduled.

Launch/activation remains a separate controlled action.

## Governing documents

Seasonal/limited work must follow:
- VISUAL_BIBLE.md
- VISUAL_FAMILY_SPECS.md
- LOCKED_TEMPLATE_REGISTRY.md
- HEARTH_SYSTEM.md
- VISUAL_QA_CHECKLIST.md
- AGENT_OPERATING_RULES.md
- SEASONAL_RELEASE_MANIFEST.schema.json

The release manifest is the batch-level machine-readable source of truth for the collection candidate. Supabase remains the runtime source of truth after approved metadata is applied.

## Release types

Supported edition types mirror the current catalog:
- seasonal
- limited
- event_reward
- founder_beta

Standard evergreen items do not require a seasonal release manifest unless they are being produced as part of a themed batch.

## Phase 1 — Release brief

Every collection starts with a brief containing:
- collection name and key;
- theme summary;
- palette;
- materials;
- motifs;
- intended release type;
- planned availability window, if known;
- included item types;
- class/body eligibility;
- intended visual families;
- whether each wearable inherits an existing locked template;
- whether each Hearth item inherits an existing backend layout profile;
- whether any item needs a special renderer;
- economy decisions, if already approved.

### Founder stop

Stop for Tanya only when the brief requires:
- a genuinely new aesthetic direction;
- a new wearable silhouette/template;
- a new Hearth family or canonical room slot;
- a materially different room composition;
- a new gameplay/economy behavior;
- a paid-service purchase;
- another founder-only category defined in AGENT_OPERATING_RULES.md.

Do not stop for routine palette, motif or material execution already determined by an approved brief and locked family.

## Phase 2 — Create the release manifest

Create one manifest using:
- SEASONAL_RELEASE_MANIFEST.schema.json
- SEASONAL_RELEASE_MANIFEST.example.yaml

The manifest tracks:
- release identity and type;
- theme;
- availability state;
- brief/visual/economy/activation approval states;
- item catalog metadata;
- visual family;
- Hearth profile/render metadata;
- wearable template/body coverage where relevant;
- provenance/version;
- QA status.

### Manifest safety rule

The manifest may describe future launch intent, but it must never infer authorization.

availability.status=scheduled does **not** imply:
- approval.activation_status=authorized;
- catalog active=true;
- economy approval;
- founder visual approval.

### Validate the manifest before art integration

During planning, validate structure even when candidate assets do not exist yet:

    node tool/validate_seasonal_release_manifest.cjs <manifest.json> --structure-only

Once bundle assets exist, run full preflight:

    node tool/validate_seasonal_release_manifest.cjs <manifest.json>

Full preflight additionally checks bundle asset existence and PNG/WebP headers.

Do not apply candidate catalog metadata to Supabase when the manifest fails preflight.

## Phase 3 — Family/template assignment

### Wearables

For every wearable:
1. identify the locked body-specific garment family;
2. reuse that body's exact geometry and registration;
3. change only approved surface treatment:
   - palette;
   - fabric/material;
   - trim;
   - embroidery;
   - motif;
   - small non-structural ornament;
4. produce each supported body from its own locked template;
5. never alter anatomy to make a seasonal garment fit.

If the concept requires a new silhouette or equipment interaction, stop for founder review before batch production.

### Hearth décor

For every Hearth item:
1. assign an existing hearth_profile_key;
2. use the family geometry defined in VISUAL_FAMILY_SPECS.md;
3. use the generic render registry when the item fits an existing render kind;
4. use an existing shadow/effect profile whenever appropriate;
5. author the art to the family envelope instead of changing room geometry.

Examples:
- winter lantern → pedestal_light
- seasonal bookcase → large_furniture
- event chair → seating
- limited rug → floor_rug
- framed holiday print → wall_art_side or wall_art_center

A new ordinary décor slug should not require:
- new room coordinates;
- a new per-slug shadow painter;
- a new scale rule;
- a new placement branch.

## Phase 4 — Asset production

### 64-bit art rule

All seasonal/limited art must remain visibly rooted in Questwell's high-detail 64-bit cozy-fantasy RPG style.

Do not use:
- photorealistic rendering;
- painterly concept-art treatment;
- smooth vector styling;
- modern 3D realism;
- generic AI blur/smearing.

Do use:
- strong sprite silhouette;
- tactile material clusters;
- deliberate dithering;
- selective highlights;
- controlled local glow;
- readable ornament at actual game scale.

### Versioning

Candidate filenames increment versions. Never overwrite a locked asset with an unapproved candidate.

Recommended pattern:

collection/slug_vN.ext

Record the matching asset_revision in the manifest/render registry.

## Phase 5 — Automated preflight

Before integration, automatically fail the candidate if any of these are true:

### Manifest/catalog
- duplicate release ID;
- duplicate item slug;
- invalid edition type;
- invalid rarity/category/archetype/unlock method;
- room/wall-art item missing hearth_profile_key;
- milestone unlock missing level;
- price missing when economy is marked approved;
- availability end precedes start;
- archive policy does not preserve ownership.

### Asset
- missing asset;
- corrupt/un-decodable image;
- zero dimensions;
- dimensions do not match manifest/render metadata;
- unsupported file type;
- incorrect filter mode for a locked pixel family;
- alpha/opaque-background failure for transparent décor;
- asset path reused by an unrelated candidate unintentionally.

### Hearth
- profile has no allowed slots;
- render kind unsupported by current client;
- invalid shadow/effect profile;
- visible base outside (0,1];
- same-family scale/contact-line regression;
- item exceeds canonical Hearth frame at compact width;
- ordinary item relies on a slug-specific layout exception.

### Wearables
- unsupported body;
- template missing/not locked;
- body/anatomy drift;
- registration mismatch;
- cuff/hand/hip/crotch/heel coverage failure;
- rear/front layer integrity failure.

A failed preflight returns the item to BUILDING without blocking passing siblings.

## Phase 6 — Development integration

Integrate candidates only into the development path unless launch is explicitly authorized.

Required checks:
- inventory/catalog visibility;
- class/body eligibility;
- equip/unequip/restoration;
- persistence;
- room placement/replacement;
- Market and Adventurer previews;
- responsive mobile/web behavior;
- asset decode/runtime routing;
- full Flutter analysis/regression gate.

A commit or successful build is not sufficient. Verify the delivered development runtime.

## Phase 7 — Seasonal review gallery

Each collection should have one internal review surface capable of:
- showing every candidate item;
- toggling items independently;
- switching female/male/neutral avatars where relevant;
- showing Hearth with/without avatar;
- swapping same-family items in identical slots;
- comparing against approved benchmark décor;
- testing compact and wide layouts;
- surfacing item metadata/version/approval state.

The gallery must not activate the items or grant ownership merely to make them visible.

### Universal development gallery

The development preview entry point is:

`?review=seasonal-gallery&collection=<release-id>`

The collection ID is restricted to lowercase kebab-case and maps to:

`assets/jsons/<release-id-with-underscores>.json`

Example:

`?review=seasonal-gallery&collection=seasonal-review-fixture`

loads:

`assets/jsons/seasonal_review_fixture.json`

The gallery supports:
- item selection across one manifest;
- female / neutral / male body switching;
- class switching;
- avatar/body show-hide;
- compact / standard / wide Hearth widths;
- valid canonical placement choices for Hearth families;
- locked-family benchmark comparison where a benchmark exists;
- data-driven static décor, floor rugs and wall art;
- body-specific wearable preview assets from the manifest;
- visible manifest approval/QA state.

The review surface is account-free and must never mutate catalog, ownership, economy or activation state.

## Phase 8 — Founder gates

### Visual approval

Tanya decides when visuals are ready for final approval.

Do not manufacture a founder gate while visual development is active.

When requested, present:
- actual development runtime;
- candidate version;
- relevant benchmark comparison;
- any unresolved aesthetic tradeoff.

Founder visual approval may move an item from candidate → approved and, when explicitly locked, approved → locked.

### Economy approval

Pricing/premium/progression decisions are separate from visual approval.

Do not infer price from:
- rarity;
- prior seasonal items;
- another collection;
- visual quality.

### Activation approval

Activation is separate from brief, art and economy approval.

Before launch:
- visual state must satisfy the release plan;
- economy must be approved or explicitly not required;
- activation must be authorized;
- required QA must pass;
- dates must be valid;
- client compatibility must be satisfied.

## Phase 9 — Launch

Only after authorization:

1. apply approved catalog metadata;
2. register render/profile/template metadata;
3. set availability window;
4. activate the approved items;
5. verify Market visibility and purchase/unlock behavior;
6. verify ownership/equip behavior;
7. record launched revision and runtime evidence.

Launch must be idempotent. Re-running the launch procedure must not duplicate ownership, mutate unrelated prices or recreate already-existing catalog rows.

## Phase 10 — Archive

When a release ends:
- make unavailable items unavailable for new purchase/unlock according to the release plan;
- preserve historical ownership;
- preserve users' equipped items where product policy permits;
- preserve asset/version provenance;
- mark the release archived;
- do not delete catalog/ownership history simply because the event ended.

## Rollback

Rollback is a first-class release operation.

If a bad asset ships:
- keep cosmetic identity/ownership stable;
- roll the render registry back to the last known-good asset_revision;
- do not create a replacement slug solely to repair visuals;
- verify actual runtime after rollback.

If bad economy/catalog metadata ships:
- correct only the affected metadata;
- do not rewrite ownership history without explicit product authorization.

A rollback does not reopen a locked template unless the template itself is the problem.

## Batch production

A collection may be produced as a batch only after:
- the brief is approved where required;
- template/family mappings are resolved;
- manifest validates;
- any genuinely new family/template decisions are complete.

Passing siblings may continue when one item fails QA.

Do not reopen the entire batch because one asset needs refitting.

## Autonomous agent stop/go matrix

### GO autonomously
- create variants inside a locked family/template;
- prepare/update manifest;
- produce candidate assets;
- increment candidate versions;
- register development metadata;
- run preflight;
- build seasonal review gallery;
- fix technical/runtime defects;
- replace a rejected candidate with another candidate;
- archive a release according to an already-approved archive rule;
- maintain provenance and documentation.

### STOP for Tanya
- new visual family;
- new wearable template/silhouette;
- new canonical Hearth space;
- material room-layout change;
- aesthetic choice not determined by brief/locked standard;
- pricing/economy/progression change;
- launch/activation authorization where required;
- destructive data action;
- paid service;
- unavailable permission/credential;
- unautomatable manual FlutterFlow/device action.

When stopping, state the exact decision, why it blocks only that scope, and the smallest action Tanya needs to take.
