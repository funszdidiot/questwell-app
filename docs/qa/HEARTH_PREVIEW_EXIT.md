# Hearth room preview and exit correction

Scope: founder-reported room-selection preview and confusing exit flow, October 9, 2026.
Base reviewed: `0de187d53cf00cea6a6b7f1dca7cc903330165b6`, also returned by the hosted
`questwell-version.json` during this investigation.

## Independent review

A separate AI reviewer inspected the screenshots, widget, draft and tests. Room
selection changed only the selected item, requiring a second placement tap before
preview changed. The footer always said Cancel, including a clean editor. Existing
source already attempts to close after a successful save; the original post-save
symptom is not established by source inspection alone.

The reviewer also inspected this implementation and found no concrete blockers,
conditional on executed tests. Its remove-setting/Undo selection consistency
observation is addressed and covered by regression assertions.

## Behavior and contract

- Selecting an owned room setting immediately switches the local preview, recalling
  that room's arrangement. It performs no server write.
- Room settings no longer require a redundant placement button. Furniture keeps
  its placement choices and replacement confirmation.
- Close and the header X leave a clean editor immediately; actual unsaved changes
  require confirmation. Back uses the same unsaved-change guard.
- Save and close awaits the existing atomic save callback before closing. While
  saving, controls stay disabled. Acknowledgment is tracked separately from an
  unsaved preview, preventing an acknowledged save from requesting discard.
- Save failures retain the draft and existing uncertain-outcome recovery guidance.
- Only the displayed room is saved; other in-session previews remain unsaved.

No database, auth, inventory, pricing, dependency or renderer contract changes.
Flutter remains pinned to 3.44.6 and go_router to 12.1.3.

## Verification

Added widget coverage for room selection reaching the rendered image before any
write, room recall, Original Hearth, Undo selection, clean/dirty Close/X/Back,
save acknowledgment and reopen through go_router. Existing duplicate-save,
failure and 320px/390px rendered-layout coverage is retained.

Verification completed locally:

- Flutter 3.44.6 locked dependencies resolved offline after restoring missing
  packages from pub.dev and verifying every restored archive against the committed
  SHA-256. `pubspec.yaml` and `pubspec.lock` are unchanged.
- Gated Hearth suite: **20 tests passed** across `decorate_hearth_test.dart`,
  `hearth_layout_contract_test.dart`, and `hearth_composition_test.dart`.
- Quality gate: **no new analyzer findings** (45 existing baseline findings);
  formatting checked across 332 tracked files with unchanged legacy debt.
- Independent final code and screenshot review: **PASS**, including 390px
  Midnight Observatory and 320px doubled text. Compact title and shorter guidance
  keep the preview and exit controls usable.
- Full client regression suite: **1,024 tests passed** (2 minutes 14 seconds).

Executed output:
```text
Gated Hearth: 00:08 +20: All tests passed!
Full client: 02:14 +1024: All tests passed!
Analyzer: 45 existing findings remain visible; no new findings.
Format: 332 tracked files checked; 150 unchanged legacy files remain.
```

The GoRouter fixture mocks persistence. Signed-in server round-trip and physical
iPhone/Safari verification are not claimed. Backend/RLS/Edge contracts are
unchanged; required remote CI has not run for this branch.

Tanya explicitly approved publishing this scoped branch and opening its PR after
the initial automatic-review publication gate. The GitHub connector is used
because terminal Git credentials are unavailable. The reviewed implementation
remains unchanged; remote CI, merge and hosted delivery are separate pending steps.

Rollback: revert this scoped PR through the development branch review process;
there are no schema or data changes to undo.
