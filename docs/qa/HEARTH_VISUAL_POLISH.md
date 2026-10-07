# Hearth visual polish — October 7, 2026

Status: QA on `feat/hearth-visual-polish`, based on development `26a46e4`.
Tanya's “Let's do it” continues the proposed focused Hearth pass.

## Plan and contract

1. Bound the page to a readable 960 px canvas and the existing room to 640 px.
2. Keep the next quest and actions first; place the adventurer overview beside
   them only when width and text size permit. Keep every remaining quest below.
3. Reuse one restrained Hearth panel treatment for overview and destinations.
4. Bring the account-free review into the same shared presentation and order.
5. Check 320/390/430 px phones, wide layouts and 2x text, navigation, and existing
   room geometry. Obtain independent AI review before an authorized dev merge.

Files: `lib/pages/home_page/home_page_widget.dart`,
`lib/widgets/questwell_home_sections.dart`,
`lib/widgets/questwell_home_overview.dart`,
`lib/preview/home_sections_review.dart`, `test/home_sections_test.dart`, `test/mobile_layout_test.dart`,
this handoff, the production dashboard pair and `tool/quality_baseline.json`
(removal of five resolved formatting entries only).

Presentation only: no API/schema, reward/selection behavior, authentication,
dependencies, asset bytes, room slot geometry, prices or equipment changes.
The pinned Flutter SDK remains 3.44.6. Existing widget APIs are checked against
the SDK and official Flutter documentation. Large text is never clamped.

## Verification

Eight added tests cover phone/wide bounds, 2x text fallback, remaining quest
visibility and destination callbacks, plus actual composed Hearth scrolling
and Campfire toggling at 320 px/2x text and 1440 px/1x. Dart formatting passed using the bundled
SDK formatter and the existing package language version (3.0). CI run 37691557845 passed all eleven home-section tests, including the eight
new cases, and the analyzer/format baseline. The full suite exposed a legacy
mobile test that searched only for ListView. It now targets Scrollable and
asserts positive scroll offset, retaining all three page checks. Final CI remains
pending. Independent AI source review found no concrete blocker in
the initial patch; follow-up source review approved the actual-composition tests too.
Local Flutter startup was rejected by automatic approval review because it
attempted a cloud metadata endpoint; it was not retried or bypassed.

The observed deployed `?review=home` uses the old overview-first order.
The ordinary account page requires sign-in; no hosted account test is claimed.
The review uses labeled sample data; no fixture is added to an account path.

## Rollback

Revert the single presentation commit through a development PR. No data rollback.
This work does not authorize production promotion or establish a new art lock.
