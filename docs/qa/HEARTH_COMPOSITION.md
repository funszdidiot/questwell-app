# Hearth composition refinement — October 9, 2026

Tanya approved refining the actual furniture arrangements after the decorator
rollout: coherent reading corners, furniture grounded against the room's
architecture, a clear avatar center, and consistent furniture scale.

The room plan now provides background-specific rear floor anchors. Cabinets and
bookcases sit farther down on the visible floor instead of sharing one elevated
baseline across every room. Seating remains in the side zones, with the table
positioned relative to its chair. A table without a chair uses the opposite
foreground when the right side contains large furniture.

Family dimensions, item artwork, avatars, canonical slots, ownership, saved
layout IDs and server rules remain intact. This is a rendering change under the
existing decorator flag; it makes no database or account writes. Both decorator
previews and the Hearth use the same bounds, including bookcase-top dependents.

Three fixture arrangements cover all nine rooms: reading left, reading right,
and display furniture with an unpaired table. `test/hearth_composition_test.dart`
checks constant sprite dimensions and paired/standalone table positions, and
captures actual Flutter scenes. CI retains the pictures as a Hearth composition
artifact for independent visual review before merge. Actual signed-in/device
acceptance is separate from synthetic scene rendering.

Status: QA. Source checks and rendered independent review are pending.
