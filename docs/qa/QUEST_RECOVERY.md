# Quest completion response-loss verification

Verified October 2, 2026 on the Questwell development branch.

## Database evidence

`tool/qa/quest_recovery_check.sql` was run as five separate database requests
against Project Momentum. The fixture was a new disposable synthetic account;
no founder quest, balance or credentials were modified.

- Injected transaction abort after the completion function: quest remained open,
  completion timestamp stayed null, balances stayed zero and no reward event remained.
- Called the real authenticated `complete_task` RPC, discarded its result, and
  committed before making a separate retry request.
- Five retries were rejected as already completed. Final state: one completed
  quest, unchanged completion timestamp, exactly 25 XP, 5 coins and one reward event.
- Removed the synthetic account and verified its profile, task and reward were gone.

This establishes retry safety across a committed completion in controlled SQL.
It simulates losing the completion result; it does not physically interrupt HTTP,
exercise overlapping requests, or prove a phone disconnected after server commit.
The founder phone offline/reconnect check remains separate evidence.

## Screen correction

The quest board previously said completion failed and left the old quest visible
when its response was uncertain. It now reloads the board after an error and says:
“Completion was not confirmed. Refresh when connected; retry only if the quest is
still open.” A successful read removes an already-completed quest. If still offline,
the existing load-error/refresh state handles recovery. The visit completion count
is not incremented for an unconfirmed response, and no reward toast is fabricated.

No automatic write retry or database function change was added. Existing backend
ownership/status checks and row locks prevent the duplicate completion reward.
CI and preview results are recorded in the readiness checklist. No release approval.
