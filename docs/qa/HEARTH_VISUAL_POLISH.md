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
`lib/preview/home_sections_review.dart`, `test/home_sections_test.dart`,
this handoff, the production dashboard pair and `tool/quality_baseline.json`
(removal of four resolved formatting entries only).

Presentation only: no API/schema, reward/selection behavior, authentication,
dependencies, asset bytes, room slot geometry, prices or equipment changes.
The pinned Flutter SDK remains 3.44.6. Existing widget APIs are checked against
the SDK and official Flutter documentation. Large text is never clamped.

## Verification

Six added tests cover phone/wide bounds, 2x text fallback, remaining quest
visibility and destination callbacks. Dart formatting passed using the bundled
SDK formatter and the existing package language version (3.0). CI remains pending.
Local Flutter startup was rejected by automatic approval review because it
attempted a cloud metadata endpoint; it was not retried or bypassed.

The observed deployed `?review=home` uses the old overview-first order.
The ordinary account page requires sign-in; no hosted account test is claimed.
The review uses labeled sample data; no fixture is added to an account path.

## Rollback

Revert the single presentation commit through a development PR. No data rollback.
This work does not authorize production promotion or establish a new art lock.
