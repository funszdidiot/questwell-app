# C11a — Complete Chronicle reads and totals

Chronicle formerly issued one request each for completed quests, defeated bosses,
progression events and set-aside quests. Independent server row caps truncated
history before `ChronicleSnapshot.fromWins` calculated XP, coins, weekly wins and
boss victories. The retained historical-query control demonstrates 1,750 XP /
2,750 coins / 50 bosses instead of 4,525 XP / 7,025 coins / 127 bosses.

The service now pages all four owner-filtered reads by immutable UUID until an
empty page. A short page is not terminal. Identity is checked before every
request/retry and after every response. Wrong-owner/status rows, invalid IDs,
nonprogressing pages and invalid dates fail the entire load. No history or total
is returned until all four collections finish. Existing reward values, weekly
boundary semantics, chronology, milestone handling and exclusion of set-aside
quests from earned totals are preserved. Failed loads use the existing retry UI.
The optional database/owner/clock arguments provide an isolated test seam;
production calls still use the existing authenticated client.

34 new regressions cover historical truncation; 135 quests, 127 bosses,
111 milestones and 119 set-aside entries with independent small page caps;
exact totals; same-timestamp paging; old versus current-week rewards; empty and
signed-out history; deletion behind the cursor; account switches during every
collection; malformed/duplicate/out-of-order rows; invalid dates; and later-page
failures followed by successful fresh retries. All 34 pass locally with Flutter
3.44.6. Targeted Dart analysis reports no issues; formatting and diff checks pass.
Dependency inputs are unchanged. CI includes this suite in Chrome in addition
to the full Flutter suite; final-head CI and AI review are required before merge.

This fixes row-cap undercounting without live SQL or account writes. It preserves
the existing meaning of totals from recorded completed activity, rather than
changing them to wallet balances or a different ledger definition. It does not
rewrite historical rewards or repair invalid legacy records.

C11's server-side aggregate contract remains separate. Client paging is not a
transactional snapshot across pages or collections; concurrent inserts, deletes
or status changes may require refresh. Memory and read cost grow with history.
Do not claim the full authoritative-aggregate/scalability gate closed from this
client correction. Hosted/native acceptance and overall release GO remain open.

API references checked: https://supabase.com/docs/reference/dart/using-filters-gt
and https://supabase.com/docs/reference/dart/using-modifiers-limit .
Rollback is client-only; reverting reintroduces the known row-cap limitation.
No art, economy, live migration, production promotion or native distribution is
part of this change. Development delivery requires post-merge checks and served
revision verification.
