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
size 1536 × 1024. Furniture and mantel inherit that map. Window effects use individually traced
glass outlines for the two new artworks.
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

PR #139 publishes the approved artwork and review implementation. Tanya’s
“Send it” authorizes completing QA and delivering this review to the development
app. Market pricing, catalog activation and account grants remain separate.

The initial GitHub run passed all six new Hearth tests and produced 72 real
renderer captures. It found one existing room-list test omission, corrected in
`6183bb4`. Source review and captured compositions then identified avatar overlap,
a bookshelf hiding the right textile, and the Keep’s distinct wide window pane.
The follow-up raises the standard statement textile, raises Hallowed-family right
hangings, traces each new window’s glass and adds gallery-with-avatar captures.
The new masks apply to rain and Amberfall while existing room masks remain fixed.
Fresh CI and visual captures must pass before merge; delivered revision, route and
asset hashes must then be checked before reporting development delivery.

Local Flutter dependency setup remains blocked by automatic review after the
setup command contacted an instance-metadata endpoint. It has not been retried.
GitHub CI provides the Flutter analyzer, tests, web and native build gates.
All five source artworks remain byte-for-byte unchanged. Local checks cover Dart
formatting, JavaScript syntax, asset provenance and diff whitespace.

## Approved account continuation — October 10, 2026

Tanya's **Yes** approves 120 coins per textile, 300 coins per room and permanent
Market availability. This supersedes the earlier price/activation hold for these
five items only. Guardian's Oath remains Guardian-only; all other items support
all classes. The scoped account rollout is defined in `ACCOUNT_RELEASE.md`.
No free inventory grants, root-history replay or flutterflow promotion.
