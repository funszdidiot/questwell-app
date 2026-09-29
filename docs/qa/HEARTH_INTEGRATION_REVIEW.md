# Hearth integration — Epic 2 review

All five class robe sets are approved. This pass integrates those frozen assets
with the Hearth environment; it does not change any avatar or garment pixels.

## Changes

- The avatar layout retains the authored 3:4 canvas ratio. Previously a narrow
  mobile rectangle caused contain-fitting to make the character much smaller.
- The contact shadow now aligns with the boot baseline at row 310/320.
- The rug and environmental floor painting render behind the avatar, rather
  than painting over the lower robe and boots.
- Reduced dark overlays on the lower room preserve visible floor detail.
- Welcome and empty-board headings use the established pixel header font.
- Bundled Press Start 2P Regular and Roboto Regular/ExtraBold for dependable
  scene text. Sources: Google Fonts `google/fonts`, with included OFL licenses.
  Roboto static weights were instantiated from its variable font with fontTools.

## Review

Development URL: `https://funszdidiot.github.io/questwell-app/?review=hearth`.
This is the actual Flutter Hearth and Adventurer widgets, with local-only review
controls for five classes, three body types and four viewport widths. It does
not authenticate, load account data or write profile changes. Only the preview
workflow uses `main_preview.dart`; the normal entry point remains `main.dart`.

The production page already passes the saved profile body to both renderers.
Adventurer saves through the existing `set_avatar_body_type` RPC; returning to
Hearth triggers `_loadHomeData`. This data path was inspected, not exercised
against a signed-in account. No Supabase schema, RPC, auth or RLS changes made.

## Acceptance checklist

- [x] All existing artwork hashes remain intact.
- [x] Boot-relative shadow placement and full 3:4 avatar canvas.
- [x] Rug/floor painting precedes avatar drawing.
- [x] Review controls show matching Hearth and Adventurer body/class.
- [x] Add mobile/tablet widget checks for all 15 class/body combinations.
- [ ] Founder accepts lighting, floor contact, scale and framing on iPhone Safari.
- [ ] In the signed-in app: change body, return to Hearth, reload and confirm it persists.
- [ ] Founder closes the full Epic 2 visual gate.

No merge to `flutterflow`, promotion or launch is authorized. Epic 3 follows
the Hearth visual review, not merely a passing automated build.

## Software rendering compatibility

Flutter 3.38.6 can decode assets while leaving them invisible in CPU-only CanvasKit (upstream flutter/flutter#180706). Disabling the browser decoder alone did not fix URL-backed assets. The development build and validation use Flutter 3.44.6, which includes the complete upstream software rendering fix. Approved artwork is unchanged.
