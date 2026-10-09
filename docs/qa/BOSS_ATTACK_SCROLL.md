# Boss attack scroll stability

Tanya's October 8, 2026 iPhone recording shows the board briefly jumping to its
arrival header on each attack before returning to the arena. Progress persists.

Cause: `_showEncounter` unconditionally called `jumpTo(0)` before revealing the
encounter, including when its anchor was already laid out. The fix reserves that
reset for discovery of an unbuilt lazy-list anchor. Normal attacks reveal the
existing anchor directly. Deep-plan reveal, busy guards, current-snapshot checks,
rewards and persistence are unchanged.

Validation: 20 focused widget tests passed across attack visibility, board
navigation and refresh animations. The regression observes every scroll change
on a repeated attack in normal and reduced-motion modes at enlarged text; final
offset alone would miss the reported flash. Independent source review approved
the change with no blocking findings. This is not hosted or device acceptance.

Pending: CI, development merge/deployment, and delivered iPhone verification.
Replay the reported two-step encounter and verify no header flash on either hit,
correct progress and a single victory presentation. Rollback is a revert of this
scoped change; no data migration or economy change is involved.
