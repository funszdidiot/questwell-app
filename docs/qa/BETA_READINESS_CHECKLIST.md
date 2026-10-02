# Questwell beta-readiness checklist

Reviewed 2026-10-01 (America/Chicago). Evidence baseline: questwell-dev commit
6d071dc697f347b06781aa746ef60280b352c3d7.

Purpose: verify the existing experience before beta. Let beta testers guide future
UX changes. No merge to flutterflow, external beta, or launch without Tanya's
explicit approval.

Status meanings: Verified = named test or founder confirmation; Partial = some
evidence but remaining acceptance steps; Open = no recorded completion. An open
check is not evidence that the feature is broken.

| Area | Status | Evidence and remaining acceptance |
| --- | --- | --- |
| Sign-in, sign-out, sign back in | Verified by founder | September 29 confirmations recovered from conversation history. Disposable-account API sign-in also exercised during October 1 deletion test. |
| Fresh-account signup | Verified | October 1 founder confirmed test signup/email confirmation worked. Read-only database check found one confirmed auth account with sign-in recorded, one profile, and one starter-business-suit row. Automated regression checks passed at 6a07cbb. See AUTH_FLOW_VERIFICATION.md. |
| Password recovery | Verified by founder | Explicit Questwell callback URL, startup recovery detection and expired-link handling added. Site URL and exact redirects corrected in dashboard; invalid-link API probes now return to Questwell. Expired-link navigation passed live browser review. Resend custom SMTP is now configured. Founder confirmed resetting the test-account password and signing in to the same account on October 1. At 22:08 founder confirmed old-password rejection, invalid/expired handling of the used reset link, and sign-in with the new password. See AUTH_FLOW_VERIFICATION.md. |
| Delete account | Verified | October 1 disposable-account integration: own identity enforced, invalid confirmation/extra target rejected, account and linked rows removed, old token and refresh rejected. Flutter confirmation/cancel/busy/error tests pass. No founder account deleted. |
| Saved progress after reopening | Verified by founder | October 1 at 22:14 founder confirmed the instructed close/reopen checks all worked: open/completed quests, XP/coins, selected customization, and no duplicate reward. Separately reported that removing Business Suit reveals the default Wanderer outfit; clarified in 9ec4c58: chest-item action names the selected class outfit and explains retained ownership. |
| Weak connection and retry | Verified for observed phone recovery | All three automated network cases passed. October 1 founder verified offline-before-submit recovery. October 2 at 06:45 America/Chicago, founder confirmed the phone interruption attempt showed a connection error while service was off; after reconnecting, a manual retry completed the quest and awarded XP and coins exactly once. This verifies the observed interruption/retry path; request timing does not establish whether the first write reached the server or lost a response after commit. Cosmetic purchase recovery is covered by the separate row below. |
| Interrupted cosmetic purchases | Verified with controlled faults and observed phone retry | October 2: aborted-transaction, lost-response/retry, insufficient-funds and overlapping-request checks passed. Two overlapping requests produced one item and one 40-coin charge. Client confirms ownership after a lost response and refreshes after unresolved errors. Tests and preview passed at 6be4462; see PURCHASE_RECOVERY.md. October 2 at 08:24 America/Chicago, founder reported a refresh was required to purchase, an error when purchasing with the connection off, and exactly one charge after reconnecting and manually retrying the rug purchase. Observed phone offline/retry path passed. At 08:28, founder clarified she was on the purchase confirmation screen. Exact refresh cause and server-request timing were not established. This does not establish a mid-request disconnect or response loss after commit on the phone. |
| Rug placement persistence | Verified by founder | October 2 at 08:29 America/Chicago, founder confirmed the Emerald Wayfarer Rug stays placed in the Hearth after refresh. Purchase/offline retry and saved placement checks are complete. This is functional acceptance, not a separate blanket art approval. |
| Email delivery for external testers | Verified for test inbox | getquestwell.com verified in Resend; native integration configured custom SMTP for Project Momentum. Saved sender Questwell <team@getquestwell.com>, smtp.resend.com:465. Signup confirmation delivery verified by founder with confirmed test account in database. Founder also confirmed completing the email password-reset flow and signing in. Delivery verified for the test inbox; this does not establish delivery across every email provider. |
| Tester feedback | Verified | Founder selected in-app feedback. Explore -> Send feedback submits to private public.beta_feedback in Project Momentum. Backend isolation/idempotency/validation/rate-limit checks, Flutter tests, and sample UI passed. October 2 at 05:47 America/Chicago, founder sent a live note; database verified one received report from Quests on web-iOS at build 810c911. See BETA_FEEDBACK.md. Tester instructions remain a draft; no invitations sent. |
| Mobile acceptance | Partial | Existing small-screen/enlarged-text widget checks and founder iPhone reviews. October 2 at 07:26 America/Chicago, founder confirmed New Quest accepts a longer task and the submit button remains reachable by scrolling with the phone keyboard open. October 2 at 07:40 America/Chicago, founder confirmed active-expedition Home shows leave confirmation, Stay keeps the timer running, and confirmed leaving returns to the Hearth. October 2 at 07:42 America/Chicago, founder confirmed Quests, Chronicle, Adventurer and Market each return to the Hearth without dead ends, blank screens or incorrect navigation highlights. October 2 at 08:24, the founder confirmed offline rug purchase error, recovery and a single charge on retry. Mid-request response-loss timing remains unverified on the phone; controlled-fault coverage is recorded separately. |
| Build and preview | Verified for evidence baseline | Rug code 59bcab9 passed Flutter Check 37011934083 and Preview 37011934049; prior purchase-recovery code 6be4462 also passed. Earlier failed-run emails do not supersede these results. |
| Male Wanderer cuff fit | Revised; improvement confirmed | October 2: male v4 sleeve ends raised and softened to avoid cutting across the hands; founder responded “Better” and moved to the next task. Shared avatar and satchel layering verified; Flutter Check 37017311712 and Preview 37017310989 passed. Retained as the development candidate; no blanket visual or release approval inferred. |
| Signed-in boss victory and reward persistence | Verified by founder | October 2 at 09:31 America/Chicago, founder confirmed the refreshed page shows the latest defeated boss. At 09:32, founder confirmed XP and coins stayed correct after refresh, with no additional reward. This closes the observed signed-in victory/refresh check; no fault-injection or concurrent-request claim is inferred. |
| Release approval | On hold | Explicit founder approval still required. |

## Recommended order

1. Rug purchase-and-placement check completed: founder confirmed offline error, single-charge retry from the purchase confirmation screen, and placement retained after refresh. The observed phone offline purchase/retry check passed; do not relabel it as a proven mid-request response-loss test. The general navigation sweep passed. The expedition exit check passed. The New Quest phone keyboard check passed. The observed quest interruption/retry check passed; a controlled quest response-loss-after-commit check remains a distinct technical case.
2. Signed-in boss ordering and reward persistence are founder-confirmed complete. The male cuff revision is retained following founder feedback “Better”; do not repeat these checks or the completed rug/navigation checks without a new defect.
3. Present remaining defects and visual decisions for founder review; request beta approval only when the concrete beta package is ready.

## Evidence notes

- docs/qa/AUTH_SCREEN_REVIEW.md describes implementation but contains historical
  sign-in/sign-out verification gaps superseded by founder confirmation.
- PROJECT_STATUS.md contains historical checkpoints and a stale epic table.
  Later dated approvals supersede older pending labels. Do not interpret every
  historical checkbox as a current blocker.
- docs/delete-account.md and tool/qa/account_delete_cascade.sql record deletion.
- .github/workflows/questwell-flutter-check.yml identifies actual CI coverage.
- test/questwell_network_test.dart was omitted at the original baseline; the
  auth readiness fix now includes it in CI.
- This is an evidence review, not a new full auth, security, or device audit.


## Outfit wording verification — 2026-10-01

In the deployed sample Adventurer preview at 9ec4c58, selected Wanderer, filtered
Chest, and equipped Business Suit. The card displayed Wear Wanderer outfit and
explained that the suit remains owned. Selecting the action restored the default
class outfit, changed the card to Owned / Equip, retained 14 owned items, and kept
Wanderer selected. Preview now tracks suit toggles instead of hardcoding it as
unequipped. Backend equipment behavior and the founder account were not changed.


## Most recent defeated boss — 2026-10-02

During the signed-in acceptance check, Tanya reported that the page showed the first defeated boss instead of the most recent. Fixed in `80ad8b58454e6a6c75022b471eaba6eb88fd86eb` and `cb79c693e2798d9367d21a6c175cecc548d29492`: load existing completion timestamps, sort defeated battles newest-completed first, and let automatic defaults refresh without overriding explicit history selection or the battle being attacked. Active battles retain their existing priority. No database writes or reward changes.

Read-only database query confirmed completed_at is populated. Regression tests cover completion order differing from creation order, reopening, list refresh, explicit selection, absent dates and active-battle priority. Flutter Check 37019103625 and Preview 37019103304 passed. Founder phone recheck passed October 2 at 09:31 America/Chicago: latest defeated boss is shown. At 09:32, founder separately confirmed correct XP/coin totals and no extra reward after refresh. No merge or launch.
