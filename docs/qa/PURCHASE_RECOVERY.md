# Interrupted cosmetic purchase verification

Verified 2026-10-02 on questwell-dev code 6be44622f551a0859702761f421eaab46baaa930.

## Findings and fixes

The existing purchase RPC already changed coins, inventory and the reward event in
one transaction. However, its ownership check ran before obtaining the profile row
lock. Two overlapping requests could both cache not-owned and the second would
fail on the inventory unique key. Its debit would roll back, but retry feedback
would be misleading. The function now locks the caller's profile before reading
class, balance and ownership. Existing ownership returns without another debit.
The private function retains its auth.uid check, existing grants and public wrapper;
its search path is now empty and table references remain schema-qualified.

The client now makes one purchase write. If the response is lost, it reads the
same account's ownership and then its balance. Confirmed ownership resolves as
success and notifies the shared cosmetic state. If it cannot confirm, it preserves
the error, explains safe retry, and refreshes the shop. Account identity is checked
before and after each asynchronous stage. Reads wait until reconciliation ends.
No automatic purchase write retry was added.

## Evidence

- Applied CLI-created 20261002105548_serialize_cosmetic_purchase.sql using
  execute_sql; source is committed, no separate remote migration-history entry.
- tool/qa/purchase_recovery_check.sql passed before and after applying the function:
  aborted transaction leaves coins/inventory/events unchanged; discarded-response
  simulation plus five retries produces one item, one debit and one reward event;
  insufficient funds grants nothing; XP and level are unchanged.
- Two overlapping authenticated SQL transactions used one disposable synthetic
  account and Round Scholar Glasses. First request held its transaction for two
  seconds after purchase; second request was submitted in parallel after a 0.3s
  delay. Results: already_owned false then true, both balance 960 from 1000.
  Verification: one inventory row, one purchase event, total coin charge -40.
  The synthetic account and linked records were removed after the check.
- test/purchase_recovery_test.dart exercises lost responses after mutation,
  failure before mutation, offline confirmation and explicit retry, reads waiting
  for reconciliation, and changed-account rejection.
- Flutter Check 36998632289 and Preview 36998632292 both passed for 6be4462.
- Security advisor reported only the existing leaked-password-protection warning.

Limits: disconnect behavior was injected in automated tests, with real database
transaction/retry tests run separately. This is not a recorded phone airplane-mode
cut during an actual request. That remains part of final device acceptance. The
separate quest-completion in-flight-write test also remains open.

No production-branch merge, external beta invitation or launch was performed.
