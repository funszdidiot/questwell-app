# Questwell private-beta tester guide — draft

Status: prepared for founder review. Feedback destination: Explore -> Send feedback inside Questwell. Invited testers
and start date are not yet selected. Do not distribute until Tanya approves the beta.
Current candidate: 971762e55b72664aefab3e176d77e7c3c6c92a65 (development preview, not a launch).

## Proposed first beta — founder decision pending

Prepared October 2, 2026. This is a proposed scope, not authorization to invite
anyone, merge branches, or launch.

| Item | Proposal |
| --- | --- |
| Group | 3–5 testers selected by Tanya; names and contacts not yet chosen. |
| Duration | Seven days starting on a date Tanya selects. |
| Platform | Founder selected iPhone and Android web on October 2 at 11:11 America/Chicago. Existing iPhone checks stand; Android phone acceptance is pending. Record phone model, OS and browser/version for each platform. Native app distribution and desktop are outside this selected scope. |
| Candidate | `971762e55b72664aefab3e176d77e7c3c6c92a65`; existing development preview at https://funszdidiot.github.io/questwell-app/. |
| Purpose | Learn whether starting/completing quests and returning to Questwell feels clear and useful. |
| Feedback | Explore -> Send feedback. Tanya reviews once daily during the beta; this routine is proposed, not an automated schedule. |
| First session | Explore unaided, then use the walkthrough below across short sessions. |
| Art | Retain the current Wanderer cuff improvement and rug for the proposed beta; collect further visual feedback. This proposed disposition is not recorded as final art approval. |
| Stop condition | Pause invitations and investigate any reproducible account-access failure, lost progress, duplicate reward/charge, or private-data exposure. |

### Evidence supporting this proposal

Signup/confirmation, password recovery, account deletion, saved progress,
phone navigation/keyboard/expedition exit, feedback receipt, rug retry/placement,
and latest-boss/reward persistence have recorded checks. Purchase fault tests and
the separately committed quest retry check found a single reward/charge.
Eight-character password rules match and leaked-password screening is enabled.
Flutter Check 37031317611 and Preview 37031317581 passed for the candidate.

### Limits and decisions

Android, desktop and native-app acceptance are not established by the founder
phone checks. Email delivery is verified for the test inbox, not every provider.
Controlled discarded-response tests do not establish physical phone response loss
after commit. The reported need to refresh before buying has no established cause;
a reproducible recurrence should include the screen and connection state.

Tanya selected iPhone and Android web. Complete Android acceptance before invitations;
do not reopen completed iPhone checks without a new defect. Then Tanya selects the
actual group/date and confirms the feedback-review routine and proposed art
disposition. External beta still requires her explicit release approval. Approval
of a plan alone does not authorize the agent to send messages.

## Android phone acceptance — pending

Use the existing web preview in Chrome on an actual Android phone. Record phone
model, Android version and Chrome version; browser emulation alone does not close
these checks. No Android result has been reported yet.

1. Sign in to the existing test account and confirm the Hearth loads with the
   expected adventurer, XP, coins and saved quests.
2. Create a small disposable quest with the keyboard open; confirm the submit
   control is reachable and the page has no horizontal overflow.
3. Complete that quest once, refresh, and confirm it stays completed with one reward.
4. Check Quests, Chronicle, Adventurer and Market navigation, then expedition
   Stay/Leave behavior.
5. Confirm owned-item appearance and saved Hearth placement after refresh.
6. Test offline-before-submit quest recovery, reconnect and retry only while open;
   confirm one reward. Do not label this as a proven mid-request disconnect.
7. Submit one clearly labeled Android test note through Explore -> Send feedback;
   verify receipt before closing this check.

Start with step 1 and record results one at a time. If an Android device is
unavailable, retain this as pending rather than claiming automated coverage.

## Invitation text

Questwell turns everyday tasks into quests, with an adventurer and a Hearth that
grow as you make progress. We are testing whether the experience feels useful,
clear, and motivating. Your feedback will guide the next UX changes.

Use a small, non-sensitive task. You do not need to share its wording with us.
There is no right way to explore, and you can stop whenever you want.

## First session: explore before reading the walkthrough

Spend a few minutes trying to start and finish one small task. Follow whichever
path seems natural. If you get stuck, tell us where and what you expected to do.

Before continuing, note:
- What did you think Questwell would help you do?
- What felt clear, and where did you have to guess?
- What, if anything, made you want to return?

## Then try the existing features

Across a few short sessions:
- Find a previous completed quest.
- Try a focus session and leave it early once.
- Change your adventurer's appearance or a Hearth item you own.
- Close and reopen Questwell and see whether your progress looks right.
- Explore boss battles if one is available at your level. Tell us what you think
  they are for before following any extra instructions.
- Try Campfire Mode and describe when you would use it, if at all.

No purchases or task grinding are required. If something is locked, report what
you expected the lock to mean. Do not include private work, client, health, or
account information in feedback.

## Feedback form template

Opening copy: "Help shape Questwell. A quick observation is enough."

Required:
1. What were you trying to do? (Short text; task wording is not needed.)
2. What happened? (Long text.)

Screen/feature is included automatically. Expected behavior is optional.

Optional:
1. What did you expect?
2. Steps to reproduce, if it happened more than once.
3. Device or browser details. Screen, coarse platform, build, and submission time
   are included automatically.
4. Contact email if you want a reply.

Suggested report types: Something broke / Hard to understand / Idea / Worked well.
Do not require a contact email or screenshot to submit feedback.

After a few sessions, ask:
- When did you choose Questwell, and when did you choose another approach?
- Which part helped most? Which part got in the way?
- What one change would make you more likely to use it again?

## Founder triage

Record the observed problem before proposing a solution. Group repeated reports,
preserve differing preferences, and distinguish reproducible defects from UX
suggestions. Prioritize lost progress, duplicate rewards, access problems, and
blocked task completion. Use tester findings to choose UX changes.

## Before inviting testers

- In-app feedback submission and founder receipt are verified. Confirm the review routine before invitations.
- Founder iPhone purchase/retry, saved placement, navigation and boss reward-persistence checks are complete. Choose the beta device/browser scope explicitly; broader device coverage remains unverified.
- Founder-approved Pro upgrade is complete. Compromised-password screening is enabled and the backend eight-character minimum matches signup/recovery validation; security advisor reports no lints. See BETA_READINESS_CHECKLIST.md for the precise verification scope.
- Resolve or explicitly defer remaining visual items with the founder.
- Confirm the specific beta audience and obtain Tanya's release approval.

