# Staging acceptance — October 8, 2026 UTC

Status: partial hosted acceptance; **not release GO**.

## Build and environment

- Hosted root and staging manifests reported `f88f070930f7a17cd32aaaecb044ea1d8aa12797`.
- The staging manifest identifies `hpjzfytwivlpsdhiupyd`, environment `staging`, and `/questwell-app/staging/`.
- Downloaded staging JavaScript: 4,333,385 bytes; SHA256 `2ec268f87c7b277cbce3382900010d20db07da3aeff83537a5473f8c0f773077`, matching the manifest. Compiled staging endpoint present.
- Feedback UI independently identifies build `f88f0709`. This confirms the active page version even while development continues to receive newer commits.
- PR #71 head `7ee38d42d274965233af70c03adf39fd4a758445`: Flutter Check `37707646776`, Backend Harness `37707646567`, and reviewed forward guard `37707646552` returned completed/success. This is CI evidence, not a substitute for acceptance or a claim that later revisions were tested.

## Observed signed-in acceptance

Only the two existing synthetic staging users were used. User completed secure sign-in; no credentials/session values were read, pasted into chat, or minted through SQL. Read-only database checks corroborate application writes; privileged reads do not prove RLS.

| Check | Actual observation | Limit |
|---|---|---|
| A login/persistence | Signed in, reopened app, created an Easy synthetic quest; creation survived reopening | No expiry/recovery callback test |
| A completion | Completion removed quest; reopened board remained empty; Hearth and DB showed 10 XP / 5 coins | No controlled duplicate/concurrent request test |
| A signout | Account signout returned login UI | Root/staging preference isolation remains untested |
| A to B switch | A open marker existed; B signed in with 0 XP / 0 coins and empty Quest Board | This verifies UI separation in this direction, not exhaustive API/RLS |
| B persistence | Created B marker; fresh tab restored signed-in B and showed only B marker | Original reload control timed out; fresh-tab result was verified |
| B completion | Board showed one finished quest and empty state; DB showed one completed quest and 10 XP / 5 coins | No retry/network fault injection |
| Boss creation | Created one Inbox Hydra with two steps; board auto-loaded one active battle | Normal successful create only |
| Boss progression | First attack showed 1/2 and 50% health; final attack showed 2/2 and victory | No concurrent final-step requests |
| Boss reward | UI +25 XP / +50 coins; DB B totals 35 XP / 55 coins, A unchanged at 10 XP / 5 coins | Single successful completion only |

Evidence: `questwell-qa-b-isolation-20261008.jpg` and `questwell-boss-victory-20261008.jpg`. Both contain synthetic data only.

Browser-control note: accessibility field values temporarily disagreed with the rendered Flutter boss inputs. Explicitly focusing the field and committing keyboard input populated the visible fields; the valid form succeeded. Do not report this as an application defect without a normal-user reproduction. Browser timeouts and interrupted calls were reconciled before retrying writes.

## Subsequent feedback and purchase acceptance

On build `c616440416b829bd5236ea236b89fdc8d37ee131` (identified by the feedback form and submitted report):

- Submitted exactly one synthetic feedback report with one JPEG screenshot through the real app. UI displayed NOTE RECEIVED.
- Database confirmed one report, one attachment and the expected build. The referenced Storage bucket is private, with image/jpeg and 62,583 stored bytes, matching source length. This is metadata/length evidence, not a downloaded-byte hash comparison or restore drill.
- B bought Everyday Adventurer Outfit once for 40 earned test coins. Market displayed 15 coins and Owned; database confirmed one ownership row, 15 coins and A unchanged.
- Equip changed Market to In use; database confirmed equipped=true with B still at 35 XP / 15 coins.
- Reload verification remains incomplete: interrupted reload left about:blank, reopening the previously observed Market URL loaded the staging shell, then browser inspection timed out. Do not claim visible post-reload equip persistence, identity preservation, duplicate-request behavior, or insufficient-funds handling from these checks.
- Synthetic screenshot evidence: `questwell-feedback-success-20261008.jpg`.

## Reopening, equipment and Expedition follow-up

On October 8 UTC, a fresh staging tab recovered the same signed-in synthetic B session after the old tab's browser-control timeout. No credentials were read or resubmitted. Active build was not re-pinned in this follow-up, so these observations do not certify a final release candidate.

- Market displayed 15 coins and Everyday Adventurer Outfit In use immediately after reopening. This supersedes the earlier incomplete reopen check for ownership/equipment display only.
- Unequip changed the item to Owned. Adventurer showed one owned item, zero equipped, and Nothing equipped yet.
- Equip from Inventory completed successfully: one owned, one equipped. Hearth showed the Everyday outfit. Before/after screenshots show the same head, hair, face and exposed hands across the default Wanderer robe and Everyday outfit for this account. This is scoped visual evidence, not all bodies/classes or post-reload pixel proof.
- Read-only database reconciliation confirmed A at 10 XP / 5 coins with no ownership; B at 35 XP / 15 coins with exactly one owned and equipped item. No duplicate charge or ownership appeared during these normal actions; controlled duplicate/lost-response testing remains pending.
- Round Scholar Glasses cost 40 coins; the detail action was disabled and labeled 25 more coins. No purchase request was submitted. This is client affordability guard evidence, not a server-side rejection test.
- Expedition selected 15 minutes, started, and counted down (14:34 then 14:11). Pause held at 13:53. Attempting to leave showed the unfinished-session confirmation. Stay here preserved 13:53; Resume Expedition advanced to 13:32.
- A later attempt to open the running-session exit confirmation reached repeated browser DOM/screenshot timeouts. End and leave was not clicked or verified. No claim of full-duration completion, page/process-death persistence, expiry behavior or reward is made.

Evidence: `questwell-unequipped-20261008.jpg`, `questwell-reequipped-20261008.jpg`, and `questwell-insufficient-funds-20261008.jpg`. Synthetic account only; no application source/schema, live account, art, pricing, production deployment or automation changes.

## Remaining acceptance and release gates

- Reverse account switch and direct authenticated API isolation; preference/draft separation and legacy root service-worker behavior.
- Genuine email confirmation/reset/change-email and expired-link callbacks. Example.com synthetic accounts cannot prove delivery.
- Retry/duplicate/uncertain-outcome quest, boss, purchase and feedback behavior; remaining equipment/class/reload coverage; remaining expedition lifecycle; disposable-user deletion.
- Feedback retry/ownership and actual byte recovery; timed isolated Auth/schema/data plus Storage-byte restore with exact source/target/handling and approved objectives.
- Inbound support route and delivered acknowledgement, content-limit/retention/export decisions, signed iPhone/Android installation and upgrade acceptance, store/signing readiness.
- Fresh acceptance against a pinned final release candidate. No production promotion, account deletion, paid service, economy change or art modification occurred.
