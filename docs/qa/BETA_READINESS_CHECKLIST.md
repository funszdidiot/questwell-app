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
| Weak connection and retry | Partial | All three automated network cases passed. October 1 at 22:25 founder confirmed the instructed offline quest attempt, responsive failure handling, reconnect/retry, and exactly one completion/reward worked. This verifies the offline-before-submit quest path. Connection loss during an in-flight write and interrupted cosmetic purchases/coin deductions remain unverified. |
| Email delivery for external testers | Verified for test inbox | getquestwell.com verified in Resend; native integration configured custom SMTP for Project Momentum. Saved sender Questwell <team@getquestwell.com>, smtp.resend.com:465. Signup confirmation delivery verified by founder with confirmed test account in database. Founder also confirmed completing the email password-reset flow and signing in. Delivery verified for the test inbox; this does not establish delivery across every email provider. |
| Tester feedback | Prepared; destination pending | BETA_TESTER_GUIDE.md contains draft tester instructions and feedback fields. Choose and verify one destination before inviting testers. No feedback collection channel has been deployed and no invitations sent. |
| Mobile acceptance | Partial | Existing small-screen/enlarged-text widget checks and founder iPhone reviews. Record the final signed-in journey on the actual beta target devices; include keyboard, navigation and expedition interruption. |
| Build and preview | Verified for evidence baseline | Latest code 9ec4c58 passed Flutter Check 36959511491 and Preview 36959511384. Earlier failed-run emails do not supersede these results. |
| Deferred visual item | Open, deferred | Male Wanderer cuff fit remains unapproved in PROJECT_STATUS.md. Revisit with founder after other build work. |
| Release approval | On hold | Explicit founder approval still required. |

## Recommended order

1. Choose and verify the feedback destination; tester guide and form fields are drafted.
2. Finish the remaining in-flight-write, purchase, and mobile acceptance checks.
3. Present remaining defects and the deferred visual item for founder review;
   request beta approval only when the concrete beta package is ready.

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
