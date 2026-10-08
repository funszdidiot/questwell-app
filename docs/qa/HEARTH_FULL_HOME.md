# Full Hearth reference implementation — October 7, 2026

Tanya clarified: “I meant the entire home page, buttons, layout, background—literally all of it.” The supplied portrait concept is the composition target, not merely a palette or room texture reference. This supersedes the earlier restrained material-only scope and desktop sidebar arrangement.

## Implemented candidate

- Full-width room and integrated wordmark; a single 760px maximum canvas keeps the same hierarchy on wide screens.
- Horizontal class/level/XP/coin strip immediately below the room. The strip opens the existing Adventurer destination.
- One dominant parchment quest panel, measured timber heading plaque, bundled serif task/action typography, reward icons and evergreen/brass completion control.
- Campfire directly below the featured quest. Native switch, pending disablement, motion preference and persistence callbacks remain intact.
- Timber navigation, illustrated Hearth/Quests/Explore icons and an evergreen active tile. Existing destinations and Explore routes remain intact.
- Secondary actions, next reward, Chronicle and additional quests stay reachable under “More at the Hearth.” Empty, loading, error, saved notes, pinned and completion-pending states remain supported.
- Interactive sample uses the same quest contents, locally completing the sample for +10 XP/+2 coins without account writes.

## Artwork provenance and preservation

Original setting uses new `hearth_environment_v3.webp`; v2 is retained. Built-in image generation refined the original v2 image, preserving camera, architecture, wall/floor anchors and empty decorating zones. First candidate was rejected for noisy central plaster and excessive central orange. Revision 2 quieted plaster texture by approximately 75% and reduced the central floor's orange cast while retaining amber firelight and blue window light. Independent visual reviewer accepted revision 2 for furnished composite testing.

Generation direction: late-90s illustrated fantasy RPG material richness; exact room layout and perspective; restrained blue-gray plaster; warm left firelight and cool right window light; no avatars, rugs, furniture, UI or baked contact shadows. Export uses ImageMagick format conversion only (WebP quality 95); no post-generation visual edits. The avatar, clothing, rug, contact shadow, decor slot geometry and layer order are byte-identical/algorithmically unchanged. Immersive mode removes only the scene's outer label/frame; default scene presentation elsewhere is preserved. The room is scaled as one responsive composition.

`DejaVuSerif-Bold.ttf` is bundled as `HearthSerif`, with its redistribution notice alongside it. No dependency versions or lockfile changed.

## Review and verification

Independent source review caught and resolved a misplaced borderless parameter and a scaled plaque overlap. The plaque now participates in normal layout before the card. Tests check actual plaque/title separation at 320/390/430/1440px and 100/200% text; completion, XP/coin update, Campfire toggle, secondary reachability, empty state and customization are covered. Existing saved-details/pending-action tests remain intact. Formatting debt is removed only for files actually formatted; no diagnostic budget or guard is relaxed.

Status: QA. Required GitHub Actions, final independent source review, deployed mobile/desktop and furnished visual checks are pending. No production promotion, new avatar lock, signed-in-account acceptance or physical-device acceptance is claimed. Local Flutter startup remains blocked by the earlier automatic approval review; existing CI is used.

## First material pass reconciliation

The preceding material pass is DEV DEPLOYED at `efad9b5eb1c51405e3145b1bf94ac231400ca264`, manual Preview run `37704535201`. All required checks passed (903 Flutter / 397 Chrome tests plus analyzer, format and build gates); delivered UI and Campfire/320px enlarged text were independently checked. PR #70 metadata remained stale despite verified development ancestry and tree; deployment was verified by the successful workflow and actual UI, not the blocked served-version JSON endpoint.
