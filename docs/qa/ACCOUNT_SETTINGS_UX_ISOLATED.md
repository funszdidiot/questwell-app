# Account controls — isolated UX candidate

Status: QA; PR #40, pending refreshed-base CI and AI review before merging.

Tanya approved publication and then, on October 6, approved both UX merges
conditional on AI review and approval. The protected beta rollout and C10b
deployment finished before this integration began. PR #39 passed AI review
without findings and merged as `fe9987734fcf2d2f4437cfa4d35d2a2813a493ba`.
A concurrent Chronicle PR #41 merged as
`7a370169152a69958e3ddc1da90390161a58d481`, directly descending from the
Hearth merge and superseding its preview run. PR #40 incorporates that combined
base and follows only after its development deployment is verified. This
supersedes the historical publication and rollout holds below; it does not
authorize production promotion or real account deletion.

Tanya's October 5, 2026 feedback: the sign-out and delete-account buttons are
not in a good spot. This continues the UX work under “do not disturb the current
roll out.” It does not authorize changing auth, deletion safeguards or rollout.

## Scope

- `lib/pages/adventurer_page/adventurer_page_widget.dart`: remove account actions
  from the fixed bottom navigation area. Add a labeled Account settings entry
  at the top, available even if the character sheet is loading or unavailable.
- `lib/widgets/questwell_account_settings.dart`: a separate scrollable account
  screen, with Sign out in its own panel and Permanent deletion in a separate
  lower panel. Standard Back returns to the existing Adventurer screen.
- `test/account_settings_test.dart`: narrow-screen/2x text, opening and back,
  pending sign-out exclusion and deletion cancellation.

The existing `_signOut` callback moves to the route owner without changing its
logic. The auth manager, account service and `questwell_delete_account.dart`
stay unchanged. The same deletion callback and
post-deletion cleanup/navigation are passed through. Typed DELETE, pending and
failure handling remain in the original confirmation dialog. Merely opening
settings does not call either account operation. No real account operation is
part of QA.

## Verification and limitations

Validated together with the independent Hearth candidate in a local review
worktree using pinned Flutter 3.44.6 / Dart 3.12.2 and an unchanged lockfile.

```text
Focused Flutter suite: 00:04 +18: All tests passed!
Complete Flutter suite: 01:07 +486: All tests passed!
Node checks: tests 19 / pass 19 / fail 0
Analyzer: 46 existing issues; no new findings
Locked assets and protected-file/whitespace checks: passed
```

Account-specific tests cover a 320px screen at 2x text, scrolling to deletion,
opening/back without an account operation, pending sign-out disabling both
controls, cancellation, and simulated successful sign-out/deletion navigating
away from settings through the pinned GoRouter 12.1.3. Existing four deletion
dialog tests also pass. Two initial fixture failures were corrected to scroll
and settle the lazy list before locating/tapping its lower controls; those were
test-fixture failures, not deletion defects. The auth implementation, deletion
widget and service match the base byte-for-byte.

The installed pinned GoRouter 12.1.3 source verifies named push, route
information serialization and restoration; the AppBar uses the existing Flutter
API. The raw Navigator route was replaced following AI review.
Local release web build passed (`isolated_test`, `lib/main_preview.dart`):
`Compiling ... 49.9s` and `✓ Built build/web`. It was not uploaded or served. Initial hosted CI passed on `2ee3e24599da5ea0a0442d04f128cd5d9d4d78f7`.
Fresh CI and AI review are required on the head incorporating PRs #39 and #41.
The refreshed merge is conflict-free. AI review identified the unregistered
Navigator route as a web history/refresh defect. The correction registers
`/account` through the existing GoRouter configuration and opens it by name.
A route owner now holds the existing account callbacks; the presentation widget
remains reusable. Direct URL entry provides a Back action to Adventurer.
The route follows the existing Adventurer routing policy; auth services and
backend authorization are unchanged. Local focused tests: **12 passed**,
including production route registration, serialized browser Back/Forward
restoration, direct URL restoration, and successful simulated operation routing.
The account suite is also added to the existing Chrome CI step. Fresh CI and
AI review of this correction remain required.
An additional offline screenshot attempt could not complete because the existing
font setup does not bundle Roboto-Bold. No visual acceptance is inferred from
that attempt; normal application font loading was not changed. No real sign-out, user deletion, hosted persistence,
physical iOS/Android, signed-in hosted browser-history, screen-reader or founder visual acceptance
is claimed. No RLS, Edge Function or live-account changes were made.

## Rollout protection and rollback

This branch is independent of the Hearth UX branch and begins from the same
reviewed development revision b78a191f19ccc3c14e5bcb34bc3e3b949859962c.
No modifications to auth services, migrations, Edge Functions, assets, prices,
workflows, dependencies, deployment branches or the active rollout plan.
Publishing a draft was initially blocked by automatic approval review for
source-export authorization. Tanya explicitly approved publication afterward;
the authenticated GitHub connector published the exact validated tree. That
historical publication blocker is resolved.

Integration sequence: merge the completed development base into this feature
branch, run fresh CI and AI review, resolve findings, then merge under Tanya's
conditional authorization. Keep this as its own PR with no auto-merge. Verify
the deployed revision afterward. Signed-in and physical-device acceptance
remain explicitly pending; simulated routing tests do not establish those results.
Before integration, dropping this branch requires no live rollback. After a
future merge, revert its UI commit; no database restore is involved.
