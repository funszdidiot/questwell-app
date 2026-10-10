# Evergreen Hearth — approved artwork, development integration

Tanya approved the macramé, Woodland Path Tapestry, Mad Alchemist’s Lab and
Guardian’s Keep on October 10, 2026. Her subsequent “Let’s go” follows the
Guardian’s Oath Tapestry preview and authorizes this development phase.

## Contract before account activation

| Slug | Category | Profile | Slots | Eligibility intent |
| --- | --- | --- | --- | --- |
| hearthwoven-macrame | wall_art | wall_textile | wall_left, wall_center, wall_right | All classes |
| woodland-path-tapestry | wall_art | wall_textile | wall_left, wall_center, wall_right | All classes |
| guardians-oath-tapestry | wall_art | wall_textile | wall_left, wall_center, wall_right | Guardian |
| mad-alchemists-lab | room | hearth_setting | setting | All classes |
| guardians-keep | room | hearth_setting | setting | All classes |

All five designs are non-seasonal. No expiry, reward, ownership grant or price
is established. Guardian-only account eligibility must be enforced by the server.
The review gallery is an account-free visual fixture, not an eligibility test.

`wall_textile` is a proposed layout profile using the existing three wall slots
and `wall_art_sprite` registry kind. The client contains artwork within one
shared textile envelope per architectural map. The user explicitly requested
large textiles and Hallowed side-wall placement; existing framed art retains
its unchanged profile and coordinates. All three textiles share geometry.

The two new room slugs map to the existing Hallowed architectural map, source
size 1536 × 1024. Furniture, mantel, rain and window overlays inherit that map.
Spiders remain exclusive to Hallowed Hearth. No third room layout is added.

No database/API schema or typed response contract changes are included in this
phase. Production catalog rows, prices and class/slot registrations will require
a separately reviewed forward migration and existing RLS/purchase/equip tests.
No local catalog fixtures are imported into production account paths.

## Review

Development entry point: `?review=evergreen-hearth`. It offers four rooms, three
textiles, three slots, no-hanging mode, avatar/furniture toggles, phone width,
and the existing rainy/Amberfall windows. Switching rooms keeps selected art
and slot. This is local preview state, not saved account persistence.

Artwork provenance and exact source hashes are in `artwork.json`. PNG sources
are copied unchanged. No new packages, dependencies, subscriptions or services.

## Rollback

Revert this PR to remove the gallery and new renderer registrations. No database
or ownership rollback is needed because no live catalog/account writes occur.

## Gallery-wall direction

Tanya’s “Think gallery wall” refines the visual direction: one statement textile
with smaller framed art arranged around it. When a center textile and either side
art are equipped, one shared gallery composition controls all three existing wall
slots. Standard groups sit on the open rear wall; Hallowed groups fit the chimney
above the mantel. Standalone side-wall textiles remain available. Existing groups
without a textile keep their previous coordinates. The review opens on the standard
room with the macramé, Fern Study and Celestial Study.

## Current verification boundary

Local Dart parsing/formatting and asset provenance are checked. Flutter tests and
build remain unrun: automatic review rejected a local Flutter dependency command
for contacting a cloud instance-metadata endpoint. That dependency setup remains
blocked. Tanya subsequently authorized public feature-branch publication and a PR
with “Let’s push it”; GitHub CI is the next gate. The local HTML composition preview
is not evidence of a running Flutter build or account persistence.

Verified locally: all five original artwork hashes/dimensions, transparent alpha
on all three textiles, JavaScript syntax, and Dart 3.0-language formatting for
all nine changed/new Dart files. Browser rendering also remains unverified: the
pinned Playwright browser download returned invalid/truncated archives.
