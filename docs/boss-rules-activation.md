# Boss server rules activated

Founder approval: 2026-10-01, following the reviewed boss walkthrough.

Applied to Project Momentum (`bdzcazkyypopbanbjnud`) using migration
`enforce_boss_victory_cap_and_level_unlocks`.

- New battles default to and cap victory rewards at 25 XP. Coins remain 50.
- XP is awarded once on victory, not per step.
- Creation gates: Inbox Hydra 1; Meeting Mimic 3; Spreadsheet Slime 5;
  Calendar Kraken 7; Printer Poltergeist 10; Notification Swarm 13;
  Ticket Troll 16; Update Dragon 20.
- Existing battles remain playable with their saved rewards.
- Database fingerprints confirmed existing battles, profiles, and reward events
  unchanged. Existing function permissions were retained.
- Post-activation rollback tests passed: all eight exact-level unlocks, seven
  under-level rejections, 2/5/20-step plans, one reward per victory, default/null/
  negative/oversized requested rewards, duplicate completion, and anonymous rejection.
- Security advisor found no new database issues; the pre-existing Auth
  leaked-password-protection warning is unchanged.

SQL: `tool/qa/boss_rules_activation.sql`.
Post-activation regression: `tool/qa/boss_rules_check.sql` (always rolls back).
Earlier candidate files are historical dry runs and must not be reapplied.
No branch merge, beta, promotion, or launch.
