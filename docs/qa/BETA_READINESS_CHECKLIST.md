# Questwell beta-readiness checklist

Reviewed 2026-10-02. Current tested code: questwell-dev
971762e55b72664aefab3e176d77e7c3c6c92a65; dated sections record founder checks.

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
| Quest completion result lost after commit | Verified in controlled SQL | October 2: completion committed with its result discarded, then five retries left one reward (25 XP/5 coins) and one completion timestamp. Aborted completion left no partial changes. Disposable fixture removed. Screen now refreshes after uncertain completion and explains safe retry; physical network interruption is not claimed. See QUEST_RECOVERY.md. |
| Interrupted cosmetic purchases | Verified with controlled faults and observed phone retry | October 2: aborted-transaction, lost-response/retry, insufficient-funds and overlapping-request checks passed. Two overlapping requests produced one item and one 40-coin charge. Client confirms ownership after a lost response and refreshes after unresolved errors. Tests and preview passed at 6be4462; see PURCHASE_RECOVERY.md. October 2 at 08:24 America/Chicago, founder reported a refresh was required to purchase, an error when purchasing with the connection off, and exactly one charge after reconnecting and manually retrying the rug purchase. Observed phone offline/retry path passed. At 08:28, founder clarified she was on the purchase confirmation screen. Exact refresh cause and server-request timing were not established. This does not establish a mid-request disconnect or response loss after commit on the phone. |
| Rug placement persistence | Verified by founder | October 2 at 08:29 America/Chicago, founder confirmed the Emerald Wayfarer Rug stays placed in the Hearth after refresh. Purchase/offline retry and saved placement checks are complete. This is functional acceptance, not a separate blanket art approval. |
| Email delivery for external testers | Verified for test inbox | getquestwell.com verified in Resend; native integration configured custom SMTP for Project Momentum. Saved sender Questwell <team@getquestwell.com>, smtp.resend.com:465. Signup confirmation delivery verified by founder with confirmed test account in database. Founder also confirmed completing the email password-reset flow and signing in. Delivery verified for the test inbox; this does not establish delivery across every email provider. |
| Tester feedback | Verified | Founder selected in-app feedback. Explore -> Send feedback submits to private public.beta_feedback in Project Momentum. Backend isolation/idempotency/validation/rate-limit checks, Flutter tests, and sample UI passed. October 2 at 05:47 America/Chicago, founder sent a live note; database verified one received report from Quests on web-iOS at build 810c911. See BETA_FEEDBACK.md. Tester instructions remain a draft; no invitations sent. |
| Mobile acceptance | Partial | Existing small-screen/enlarged-text widget checks and founder iPhone reviews. October 2 at 07:26 America/Chicago, founder confirmed New Quest accepts a longer task and the submit button remains reachable by scrolling with the phone keyboard open. October 2 at 07:40 America/Chicago, founder confirmed active-expedition Home shows leave confirmation, Stay keeps the timer running, and confirmed leaving returns to the Hearth. October 2 at 07:42 America/Chicago, founder confirmed Quests, Chronicle, Adventurer and Market each return to the Hearth without dead ends, blank screens or incorrect navigation highlights. October 2 at 08:24, the founder confirmed offline rug purchase error, recovery and a single charge on retry. Mid-request response-loss timing remains unverified on the phone; controlled-fault coverage is recorded separately. |
| Build and preview | Verified for current candidate | Code 971762e passed Flutter Check 37031317611 and Preview 37031317581 after the quest completion error-refresh fix. |
| Male Wanderer cuff fit | Revised; improvement confirmed | October 2: male v4 sleeve ends raised and softened to avoid cutting across the hands; founder responded “Better” and moved to the next task. Shared avatar and satchel layering verified; Flutter Check 37017311712 and Preview 37017310989 passed. Retained as the development candidate; no blanket visual or release approval inferred. |
| Signed-in boss victory and reward persistence | Verified by founder | October 2 at 09:31 America/Chicago, founder confirmed the refreshed page shows the latest defeated boss. At 09:32, founder confirmed XP and coins stayed correct after refresh, with no additional reward. This closes the observed signed-in victory/refresh check; no fault-injection or concurrent-request claim is inferred. |
| Compromised-password screening | Enabled and verified | October 2 at 10:42 America/Chicago: founder reported completing the authorized Pro upgrade. Fresh billing view confirms Momentum Labs Pro, $25 current/projected costs, and spend cap enabled. Enabled Prevent use of leaked passwords, saved and reopened to confirm persistence. Supabase security advisor returned zero lints. Other password-policy settings unchanged; no end-to-end password rejection test claimed. |
| Minimum password length | Verified | October 2: saved Supabase minimum of eight characters matches existing signup/recovery validation. Reopened settings confirmed 8. A synthetic seven-character signup request was rejected with HTTP 422 weak_password and “Password should be at least 8 characters.” No account created or existing password changed. |
| Release approval | On hold | Explicit founder approval still required. |

## Recommended order

1. Rug purchase-and-placement check completed: founder confirmed offline error, single-charge retry from the purchase confirmation screen, and placement retained after refresh. The observed phone offline purchase/retry check passed; do not relabel it as a proven mid-request response-loss test. The general navigation sweep passed. The expedition exit check passed. The New Quest phone keyboard check passed. The observed quest interruption/retry check passed; the controlled committed-completion/discarded-result retry check is now verified in QUEST_RECOVERY.md. Physical HTTP response loss and concurrent completion remain outside that check.
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

## Readiness review — 2026-10-02, 09:33 America/Chicago

Confirmed completed: account flows, saved progress, observed phone network recovery, purchase retry/placement, feedback delivery, navigation/keyboard/expedition exit, and boss victory/reward persistence. Current automated checks are green. This is not blanket all-device or all-fault coverage: Android/native-device acceptance, broad email-provider delivery, and a controlled quest response-loss-after-commit case are not established by the existing evidence. No new duplicate-reward defect is inferred.

Remaining decisions: final visual disposition (male cuff improvement retained; rug functional acceptance does not equal blanket art sign-off), device coverage/scope for any proposed beta, and the compromised-password warning. Draft tester guide updated to current code and completed checks. No invitations, merge, external beta, paid upgrade or launch approved. Dashboard access is restored. Next decision: whether to approve the recurring Pro-plan expense or explicitly defer compromised-password screening while remaining in development. The Email provider also currently shows a six-character minimum; password-policy hardening requires a coordinated app/backend pass before external beta.

## Pro upgrade and password screening — 2026-10-02, 10:42 America/Chicago

Supersedes the earlier Free-plan restriction and pending-upgrade decision. Founder completed the upgrade herself after approving it. Fresh billing page verified Pro and spend cap enabled; no second purchase was submitted. Compromised-password screening saved and verified in the Email provider panel; security advisor returned `lints: []`. This is a configuration/advisor check, not a full security audit. Six-character minimum and password-change policies remain unchanged pending coordinated hardening. No merge, beta invitations or launch.

## Password minimum aligned — 2026-10-02

Supersedes the six-character minimum noted above. Existing app validation already requires at least eight characters for signup and recovery; sign-in only checks that a password is present. Raised the Supabase minimum from six to eight, saved and reopened the provider panel to verify persistence. A synthetic seven-character signup request using a reserved example.invalid address returned HTTP 422 `weak_password`: “Password should be at least 8 characters.” The rejected request did not create an account. No actual user credentials were modified.

Leaked-password screening remains enabled; a fresh security-advisor check returned `lints: []`. Secure-password-change and current-password requirements remain unchanged. This verifies the minimum-length configuration and rejection path, not a new end-to-end recovery or compromised-password test. No app-code change, merge, invitation or launch.

## Quest completion retry — 2026-10-02

The controlled committed-completion/discarded-result check supersedes that specific technical gap in the earlier readiness review. Separate transactions verified one reward after five retries and rollback on abort. The board error path now reloads and uses accurate unconfirmed-completion wording. Physical HTTP response loss, overlapping quest completions and broader-device testing remain unverified by this check. See QUEST_RECOVERY.md. Code `971762e55b72664aefab3e176d77e7c3c6c92a65` passed Flutter Check 37031317611 and Preview 37031317581. No merge, invitation or launch.

## Beta review package — 2026-10-02, 11:07 America/Chicago

BETA_TESTER_GUIDE.md now contains a concrete proposal: 3–5 founder-selected testers, seven days, iPhone web scope, current tested candidate, daily founder feedback review, stop conditions and explicit evidence limits. Group, date, platform scope, art disposition and release approval remain founder decisions; no invitation or launch is authorized. Existing completed checks are not reopened. Next decision: iPhone web first, or include additional named platforms with acceptance checks before invitations.
