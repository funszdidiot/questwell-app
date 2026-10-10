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
`assets/images/questwell/hearth/witchlight_bookcase_front_v3.webp`.
Canvas: 1182 × 1330. Measured opaque contact row: 1279; visible base: 1279/1330.
No image stretching or alpha editing: the generated PNG was losslessly encoded
as WebP and decoded RGBA equality was verified.

The shared render-spec parser resolves this exact old bundle path at revision 1
to revision 3 before layout and painting. Both existing live catalog rows and
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
continuous plinth; retain moon crest, two finials, three wider shelves, antique plum and
ochre books and three amber bottles. Warm upper-left light, restrained violet
edge, bottle glow contained inside shelves. Complete object on transparency;
no room backdrop, external halo, baked floor shadow, text or clipping.

Source: exec-6e78b63c-d5ca-4529-9c9b-5dc8efdf37c1.png
Source SHA256: ef49f3de60900314c4111f43dc8781bfc69851582148a83effada78a26495bda
WebP SHA256: 4e59540906158a9ed062c43bdf930b074542b8eca9143a8e84fc16d1a55a9b32

## Verification

Pending CI: metadata compatibility regression, full suite and feature-enabled
room exports. Focused captures cover left/right, 390/760 app cameras, avatar
on/off, Standard, Hallowed, Alchemist's Lab and Guardian's Keep. Existing
nine-skin furniture compositions also remain in the CI matrix. Inspect actual
exports and independent review before merge; hosted revision and asset hash
verification before reporting delivery. Account/manual device acceptance is
separate from these account-free review scenes.

## In-room review iteration

The first front-facing candidate (v2) passed contact, alpha and camera checks,
but independent review of all 32 focused captures and eight mixed-furniture
captures found that five dense tiers read as a miniature tower at the fixed
rear-wall scale. It is not the shipping candidate. Run 38077352496 and artifact
11678822275 document that rejected in-room silhouette.

The v3 edit rebuilds it as a broad three-tier cabinet, following the existing
three-tier walnut bookshelf's proportions: larger books and bottles, shorter
crown, fewer tiny details. This corrects readable physical scale in the art
without any per-item layout adjustment. The v2 candidate is retained in git
history, while only v1 and v3 ship in the bundle. Fresh combined CI and
independent v3 in-room review are required.

Read-only live registry verification confirmed the exact legacy bundle path,
revision 1, 1024×1536 canvas and large_furniture profile. The client resolver
therefore also handles existing owned items. Browser review is currently
unavailable after a transport failure and timed-out recovery; do not claim
interactive hosted acceptance from CI or static asset checks.
