# Account controls — isolated UX candidate

Status: QA; local branch `ux/account-controls`, not merged or deployed.

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

The existing `_signOut` callback, auth manager, account service and
`questwell_delete_account.dart` stay unchanged. The same deletion callback and
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

Current Flutter documentation verified Navigator.push, MaterialPageRoute and
AppBar; the installed pinned GoRouter source verifies the navigation APIs.
Local release web build passed (`isolated_test`, `lib/main_preview.dart`):
`Compiling ... 49.9s` and `✓ Built build/web`. It was not uploaded or served. Hosted CI and AI review remain
pending publication. No real sign-out, user deletion, hosted persistence,
physical iOS/Android, browser-history, screen-reader or founder visual acceptance
is claimed. No RLS, Edge Function or live-account changes were made.

## Rollout protection and rollback

This branch is independent of the Hearth UX branch and begins from the same
reviewed development revision b78a191f19ccc3c14e5bcb34bc3e3b949859962c.
No modifications to auth services, migrations, Edge Functions, assets, prices,
workflows, dependencies, deployment branches or the active rollout plan.
The local branch is review-only. Publishing a draft was blocked by automatic
approval review in this session for source-export authorization. Do not use a
connector or another transport to bypass that rejection.

Before later integration: rebase on the completed rollout, run CI and AI review,
verify signed-in navigation and device behavior, then merge only when consistent
with Tanya's rollout instruction. Keep this as its own PR with no auto-merge.
Before integration, dropping this branch requires no live rollback. After a
future merge, revert its UI commit; no database restore is involved.
