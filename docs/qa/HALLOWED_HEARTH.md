# Hallowed Hearth — October 7, 2026

## Verified active release — October 8 UTC

PR #79 centered the print over the fireplace and merged as `973f49642eb779543e2b4df1a65ac7085bb8917e`. Independent source and wide/mobile visual review passed. All required checks passed: 928 Flutter tests, 397 Chrome tests, coverage, Android, iOS and backend rehearsal. Preview `37722573952` and backend `37722573519` passed; the served revision and six asset hashes matched. Actual hosted furnishings, avatar and animated spiders were verified.

The approved 24-hour project-scoped credential was created and stored. Reviewed activation workflow `37723523792`, job `113136402518`, succeeded at 03:36:53 UTC as migration `20261008033653`. Read-only post-verification found six active, nonpremium, all-class items at 220/140/100/160/60/60 coins and five exact render entries. Purchases close at `2026-11-09T06:00:00Z`; ownership and placement remain permanent. Keep the rows active after cutoff. Existing catalog, schema and 51 prior history records retain their exact protected hashes; there is one matching new forward record (52 total).

Purchase boundaries, single charging, owned retries after cutoff and placement/restoration were verified with synthetic accounts in the isolated harness. No real-account purchase was made for this release verification. No main/flutterflow promotion occurred. Earlier pending/blocker statements below are historical and superseded for this approved release.

## Saved rug replacement repair — October 8 UTC

Tanya reported that Moonweb Rug was owned but would not save. Live request logs
showed `room spot changed; refresh and confirm replacement`. Read-only diagnosis
found an inactive Emerald Wayfarer Rug still occupying the floor for the affected
Moonweb owner. The active catalog filter hid this occupant from the picker, so
it sent null as the expected occupant and the server correctly refused.

The client now retains equipped slot identities from the ownership response,
independent of active catalog visibility, and passes them to both Market and
Inventory pickers. Hidden items use the label “Stored Hearth item” and require
explicit replacement confirmation. They are not reactivated or rendered. The
server concurrency guard and all ownership/currency rules are unchanged.
The adapter regression exercises the real Market save path, cancellation,
expected occupant ID, exactly one placement request and state reconstruction
on reload. CI and delivered repair verification belong to PR #81; earlier
activation checks did not cover replacement of an inactive stored rug.

## Authority and scope

Tanya approved the generated Halloween room with: “Add some animated spiders and we’re a go.” This scopes the seasonal room art and two ambient spiders. It does not approve price, dates, account activation or production launch. No schema, ownership, currency or auth changes.

## Implementation

- Approved 1536 × 1024 source preserved through lossless WebP encoding at `assets/images/questwell/hearth/hallowed_hearth_v1.webp`.
- Dedicated paint-only `QuestwellHallowedSpiders`: two staggered 24-second silk descent/climb loops, subtle leg flex, zero-velocity seam, no hit testing/semantics, reduced-motion, TickerMode and application-lifecycle stop.
- Explicit development setting in the shared Hearth renderer. Existing canonical avatar/decor positions remain unchanged. Catalog slug support deliberately remains unavailable pending the separate seasonal activation contract.
- Account-free `?review=hallowed-hearth` route with avatar/furnishings/pause controls; nothing writes account equipment.
- Three Flutter tests cover animation pixel changes and loop closure, clear lower room, tap passthrough, reduced motion, hidden route, disposal, image routing, responsive widths and absence in the original setting.
- Existing Dart 3.0 package formatting applied with Dart 3.12.2; obsolete formatting exemption removed for the touched preview entrypoint.

## Verification and limits

Standalone preview checks pass: actual Skia canvas pixels differ during travel, first/last phase pixels are identical, and the lower 60% remains clear. The extracted HTML animation script passes simulated pause/resume, reduced-motion and hidden-page lifecycle checks. Playwright browser execution was unavailable (browser download failed), so no real-browser result is claimed.

Local formatting and `git diff --check` pass. Approved source pixels and decoded WebP pixels match exactly. Flutter tests are written but NOT executed: automatic approval review blocked local Flutter SDK setup because it attempted cloud metadata access. Do not bypass that boundary.

Automatic approval review also rejected the GitHub push dry run, interpreting current authority as local development/preview rather than repository publication. No branch push, PR, CI result, merge or app deployment is claimed. Explicit approval for publishing this scoped branch/PR is the remaining publication step.

The standalone HTML/video are animation design previews, not a compiled Flutter runtime. Mobile/native in-app fit, final furnished composition, persistence and account activation remain unverified. Do not label DEV DEPLOYED or release GO.

## Rollback

Remove the explicit review route, development-only enum value and conditional motion layer; remove the new widget, review, test and asset. Existing room assets, bodies, furniture, account data and catalog remain untouched.

## Approved collection continuation — October 8 UTC

Tanya subsequently requested the whole collection to be priced and pushed out, approved the furnishing art and explicitly approved 220/140/100/160/60/60 coins, availability through November 8 Chicago time and permanent ownership. The earlier publication-approval blocker is superseded. Git terminal publication has no credentials; authenticated GitHub connector publication is available. Local Flutter setup remains unavailable; required runtime tests run in CI.

Client integration now includes all six slugs, five generic render specs, composed review, matching 32px icons, profile-based chair/table spacing and seasonal purchase actions. The new forward migration stages six inactive catalog rows and five renderer entries without touching existing harvest items or ownership. A guarded purchase-function change enforces dates server-side after the owned retry check. The CI harness verifies price, inactive/future/expired purchases, boundary equality, single charges, retry after cutoff, permanent placement and restoration. These checks are implemented, with execution results recorded separately.

The new items must remain inactive until reviewed client delivery and scoped forward deployment are verified. Keep active=true after launch; availability_end closes new purchases. Deactivation would prevent owned Hearth placement. No live migration or activation has been executed.

## CI and independent review — October 8 UTC

PR #75 revision `84c9cbc` passed every client job in run `37717381489`: full
Flutter regression suite, Chrome navigation tests, analyzer/formatting, critical
coverage, Android build and iOS unsigned compile. The actual Flutter-rendered
390px/960px composites for all three bodies plus matching icons received
independent visual PASS. Mantel attachments and portrait spider visibility were
corrected; Rainy Window now maps the approved room's glass panes and passes its
pixel-boundary test. Latest captures are artifact `11524890246`.

The initial isolated backend run `37717381340` found a fixture-only missing
legacy bookshelf dependency, before reaching Halloween scenarios. The two
unrelated bookshelf-required slots are removed from the disposable fixture;
real catalog/lookup data are unchanged. Backend success is not yet claimed.

The scoped activation workflow, drift guards and atomic rollback rehearsal are
prepared in the [deployment runbook](HALLOWED_HEARTH_FORWARD_DEPLOYMENT.md).
Nineteen local forward/workflow tests pass. Independent review found a future
CI expiry issue; the rehearsal now expects safe activation refusal after cutoff.
The final combined-revision backend rehearsal and new credential remain gates.

The first atomic SQL rehearsal (`37718425446`) correctly stopped before writes
when the exact-definition guard compared PostgreSQL's trailing newline against
a literal without it. The guard now strips only outer whitespace; its entire
function body remains exact and the forward metadata hash is unchanged. A
read-only live comparison confirms a match. The source digest was refreshed and
the complete rehearsal is being rerun.

## Verified delivery and founder correction — October 8 UTC

PR #75 merged as `7bd70a9`. Preview run `37719619319` and backend run
`37719618858` passed. The served revision and six image hashes matched; the
actual hosted furnished room, adventurer and animated spiders were verified.
The atomic SQL rehearsal and all purchase/ownership scenarios passed. No catalog
activation occurred.

Tanya then said **“I approve but center the art on the fireplace.”** This
explicitly approves the requested 24-hour project-scoped Supabase Database Read
+ Migrations Write token and its GitHub Actions storage. No repeated credential
approval is needed for that exact scope. The token is not yet created.

The placement correction anchors Hallowed Hearth's left-wall art to source
point (568,179.2), the chimney centerline, using the background's cover crop.
Canonical frame size and other room/slot anchors are unchanged. The correction
applies in the shared account renderer and the review, without changing any art
bytes or catalog records. Fresh CI and independent visual review are pending
before activation.
