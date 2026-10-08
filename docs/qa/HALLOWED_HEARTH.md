# Hallowed Hearth — October 7, 2026

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
