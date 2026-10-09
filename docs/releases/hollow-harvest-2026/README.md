# Hollow Harvest seasonal activation

Status: QA; not yet activated. Founder approved the Halloween/fall boss and
instructed deployment. Head correction preview was verified at `24eab12`.

The single forward SQL payload adds one supported boss type and preserves the
existing creation function except its accepted type, level-1 mapping and a
creation-only seasonal check. It guards the exact observed function hash, type
constraint and existing Hallowed Hearth collection dates, failing atomically
on drift. Do not reset or replay root migrations. Apply only the reviewed file
after same-revision backend CI and independent review. No new credentials needed
when the authorized Supabase connector can apply this scoped migration.

Window: 2026-10-08T03:36:53.444481Z inclusive to 2026-11-09T06:00:00Z exclusive.
All regular levels remain unchanged. Existing battles and creation receipts
are retained; reward, completion, RLS, grants and account-fence code are unchanged.
Client shows a seasonal label and respects the date for selection; the server
is authoritative. An uncertain create can still query its successful receipt
after close. No player inventory, coins or progress is altered by activation.

Validation: 26 focused Flutter tests pass. The disposable database harness tests
opening/closing boundaries, caller-controlled reward normalization, retry after
close, rejection of a new request after close, completion after close, duplicate
completion reward protection, and unchanged regular boss gates. This test changes
only the disposable function's clock and restores its original definition.

Deploy database first after CI; verify definition, constraint and preserved
history, then merge/deploy client with fresh checks and browser review. If a
remote call is ambiguous, inspect postconditions instead of blindly retrying.
The head-fix art and arena are reused. Lantern flicker and pumpkin-pile defeat
remain separate animation work and are not claimed in this release.
