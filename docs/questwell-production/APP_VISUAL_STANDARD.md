# Questwell application visual standard

Tanya's October 7, 2026 direction extends the accepted Hearth system to the
entire app. This is the governing interface standard for new and revised screens.

## Shared components

- `QuestwellAppStyle`: timber/navy/emerald/brass palette, control and input themes,
  dialogs, sheets, snackbar feedback and disabled controls. Material 2 behavior
  remains in place to avoid an unrelated platform-component migration.
- `QuestwellScaffold`: timber page background around existing page-owned scrolling,
  safe areas and app bars. Navigation and form/controller callbacks are unchanged.
- `QuestwellHearthFrame`: carved wood/brass frame; parchment for actionable quest,
  journal and shop content, dark panels for progress, equipment and settings.
- `QuestwellHearthIcon`: shaded small illustrations with a shared light direction;
  distinct house, clipboard, mountain, book, shop, adventurer, shield and fire.
- `QuestwellAppNavigation`: identical Hearth / Quests / Explore navigation on every
  main destination; whole-word stacked labels for narrow enlarged text.
- Typography: preserved wordmark, short pixel section labels, HearthSerif focal
  titles and primary actions, Roboto for reading, numbers and detailed controls.

Selection, focus, pressed, disabled, busy, success and error states must remain
legible. Destructive actions keep explicit warning color and confirmation wording.
Controls keep at least 48 logical pixels of target height. User text scaling is
never suppressed to make a layout fit. Respect reduced-motion preferences.

## Coverage

| Surface | Shared treatment | Required interaction evidence |
| --- | --- | --- |
| Hearth | Existing reference composition; common controls/icons | Complete, rewards, empty, Campfire, customization |
| Quest Board | Parchment cards, timber board, emerald actions | Add, pin, edit, set aside, complete, busy/error |
| New/Edit quest | Shared shell, parchment form, brass effort choices | Keyboard, validation, draft guard, submit/retry |
| Market | Shared shell, filter tray, framed parchment item cards | Search/filter, detail, buy/cancel, eligibility, equip |
| Adventurer | Shared equipment and mastery panels | Class/body, inventory, collections, equip/remove/place |
| Boss battles | Shared attack/victory panels and controls | Create, attack, pending/failed, history, victory |
| Expedition | Shared timer panel, chrome and controls | Begin, pause, leave confirmation, finish, motion |
| Chronicle | Shared parchment, currency icons and navigation | Search, filter, repeat/restore, pagination |
| Authentication | Current Hearth background, parchment and controls | Sign in/create/reset/recovery, autofill, errors |
| Onboarding | Shared welcome frame and visual hierarchy | Choice, skip/finish, retry, existing progress guard |
| Account | Shared panels; distinct deletion warning | Sign out, disabled state, deletion confirmation |
| Overlays/feedback | Common sheet/dialog/input/action themes | Dismiss/dirty guards, pending/error, safe retry |

Scene identity is intentional: shopfronts, expedition landscapes, battle settings
and furnished rooms retain their own artwork. Avatar bodies, garment templates,
room placement geometry, catalog artwork, economy, eligibility and persistence
are outside this presentation migration.

## Acceptance

The implementation must pass required CI and independent source and delivered
visual reviews. Check 320/390px with 100%/200% text, keyboard-visible forms and a
large screen. Inspect each main destination plus representative overlays. A
passing screenshot does not prove signed-in persistence or sustained engagement.
See the delivery PR for exact revisions, checks, observed results and limitations.
