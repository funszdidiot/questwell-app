# Adventurer heading layout — October 7, 2026

QA checkpoint on `fix/adventurer-heading-wrap`, based on development `6e0a8a5`.
Tanya's “Keep going” continues the approved visual/mobile polish.

## Problem and change

The delivered 320 px/200% preview placed ADVENTURE beside the back button and
wrapped the final R onto its own line. This is valid Flutter layout, so ordinary
overflow-exception checks miss the visual defect.

Use Wrap for the existing back button and complete title. If they cannot fit on
one row, the title takes the next row at its original scaled font size. Preserve
approved typography, the subtitle, button tooltip/callback, artwork, renderer,
inventory, equipment and all account behavior. The existing view is formatted;
remove only its now-resolved formatting exemption, with no diagnostic allowances.

## Verification plan and status

Six tests render the real Adventurer view at 320/390/430 px with 1x/2x text.
Assert a single text-selection box for the complete title, unchanged title and
subtitle scaling, bounds/non-overlap, a 48 px back-button target, and the callback.
Formatter and diff whitespace checks passed. Required CI and independent source
review are pending at this checkpoint. The PR will record exact-revision results.
Local Flutter is not retried after the prior automatic metadata-endpoint rejection.

After protected development merge, verify the delivered revision and actual
320 px/200% header, normal-size header, and back navigation. Independent rendered
review precedes completion. Sample browser evidence does not establish signed-in
account or physical-device acceptance. No new art lock or production promotion.

## Rollback

Revert the scoped presentation change through a development PR; no data rollback.
