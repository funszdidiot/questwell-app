# Witchlight Bookcase perspective redesign — October 10, 2026

Status: QA. Tanya requested that the Halloween bookcase follow the new spatial
and perspective rules. This authorizes a scoped development replacement, not a
new founder art lock.

The old asset showed a prominent right side and unequal front foot depths.
The new front-facing bookcase retains its moon crest, finials, dark walnut,
plum/ochre books and three amber bottles. Uprights stay parallel, shelf fronts
stay level, and a shallow continuous plinth replaces the staggered feet.
Transparent margins and restrained recess lighting let the room supply the
surrounding light and shared contact shadow.

## Registration and compatibility

The historical v1 asset is unchanged. The new file is
`assets/images/questwell/hearth/witchlight_bookcase_front_v2.webp`.
Canvas: 1024 × 1536. Measured opaque contact row: 1507; visible base: 1507/1536.
No image stretching or alpha editing: the generated PNG was losslessly encoded
as WebP and decoded RGBA equality was verified.

The shared render-spec parser resolves this exact old bundle path at revision 1
to revision 2 before layout and painting. Both existing live catalog rows and
bundled fixtures therefore use identical artwork/contact. Network assets,
unrelated paths and newer server revisions remain authoritative. Older clients
retain their existing v1 bundle, with no broken remote paths. Both architectural
maps and the generic large_furniture family remain unchanged. No catalog,
account, price, availability, ownership, equipment or database write is included.

## Generation provenance

Built-in imagegen, precise-object-edit. References: existing Witchlight v1
(identity), walnut_bookshelf_front_v1 (camera) and hallowed_hearth_v1 (style).
Prompt: redesign the existing bookcase for a centered front camera, upright
parallel sides, level shelf fronts, subtle shallow shelf interiors and a level
continuous plinth; retain moon crest, two finials, five shelves, antique plum and
ochre books and three amber bottles. Warm upper-left light, restrained violet
edge, bottle glow contained inside shelves. Complete object on transparency;
no room backdrop, external halo, baked floor shadow, text or clipping.

Source: exec-dda85ad5-d3cb-410d-8723-4a47df4cbcca.png
Source SHA256: 73ea842a36d369efd237f93f6645bd7738e1867cee997fe421de9d43f0f794c5
WebP SHA256: fdc0da726cdc90d58689c15a6cb6dc3961a0da15e90b2c2f900bb90a83f8c360

## Verification

Pending CI: metadata compatibility regression, full suite and feature-enabled
room exports. Focused captures cover left/right, 390/760 app cameras, avatar
on/off, Standard, Hallowed, Alchemist's Lab and Guardian's Keep. Existing
nine-skin furniture compositions also remain in the CI matrix. Inspect actual
exports and independent review before merge; hosted revision and asset hash
verification before reporting delivery. Account/manual device acceptance is
separate from these account-free review scenes.
