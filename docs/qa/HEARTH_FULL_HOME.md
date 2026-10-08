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

## Development delivery and live correction

PR #71 merged to development at `f88f070930f7a17cd32aaaecb044ea1d8aa12797`.
Preview `37708222571` built and deployed successfully. Premerge check
`37707646776` passed 905 Flutter / 397 Chrome tests, analyzer/format, coverage,
Android and iOS builds; backend `37707646567` and migration guards also passed.
Merged deployment repeated the required checks successfully.

Live review confirmed the richer room and whole-page hierarchy, and sample quest
completion updated 95→105 XP and 49→51 coins. Both root and the independent visual
reviewer found the compact XP rail empty despite the correct numeric value: its
8px height was entirely consumed by shared-meter padding/borders. The scoped
follow-up raises it to 16px, leaving 6px visible fill, and asserts seven earned
segments have positive painted height across all existing viewport/text-scale cases.
Independent source review approved the correction. Its CI and delivered check are
recorded in the follow-up PR; no XP calculation or account behavior changes.

Earlier CI also caught a removed private reward helper still used by the completion
dialog (restored byte-for-byte), enlarged reward-label overflow (flexible wrapping),
and Campfire scroll reset (stable content key). Wooden navigation is intentionally
limited to Home so other screens retain their tested viewport layout. Existing tests
were preserved, and switch hit testing now verifies the scroll position survives.

Furnished live QA additionally found the overlaid logo/rule crossing the canonical
center-wall painting at 390px. The same correction reserves an attached header
strip above the scene; room coordinates and artwork remain untouched. Regression
checks require the header to end before the room bounds at all tested widths and
text scales. This is a safe space for the logo, not a moved decor slot.

The 320px / 200% text review found short labels breaking within words. At narrow
widths with enlarged text, navigation now uses full-width rows and Campfire places
its switch beside the description below the title. Text scaling remains intact.
A bundled-font regression checks actual rendered word boxes for the three
navigation labels and “Campfire”; normal-size composition is unchanged.

## Full-goal review and interface refinement — October 7

Tanya requested a fresh independent assessment against the entire loved reference.
Two reviewers agreed that cozy atmosphere is established, but premium interface
craftsmanship and mobile composition remain incomplete. The 390px / 740px initial
view partly hid the completion button and left Campfire below the fold. Prior
functional QA did not constitute full art-direction acceptance.

The next scoped pass preserves scene dimensions, asset bytes, canonical placement,
avatar/body/garment locks, account writes and economy. A shorter decorative header,
20px featured title and tighter card spacing improve the first useful view. Shared
frames gain carved wood gradients, forged brass brackets and rivets; parchment
gains restrained fibers and edge ornament; the emerald action and selected tab
share directional light and recessed edges. Dedicated small Hearth illustrations
replace the simpler Home navigation symbols without changing other destinations.

A bundled-font 390px / 740px regression requires the complete quest button to sit
at least 8px above fixed navigation and work without scrolling. Existing enlarged
text, pending completion, notes, Campfire and navigation tests remain intact.
Status: QA; required checks, independent source review and delivered aesthetic
comparison pending. No measured retention claim or new artwork lock is implied.

The existing server-derived milestone reward now sits directly below Campfire,
so users need not expand More to discover their next unlock. Its selection,
eligibility and empty behavior are unchanged; no new reward or economy rule is
introduced. Weekly momentum and secondary actions remain in More.
