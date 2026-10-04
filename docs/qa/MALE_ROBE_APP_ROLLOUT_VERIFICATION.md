# Male robe app correction — verified proposal, rollout held

Date: 2026-10-04 (America/Chicago).

Tanya correctly reported that the male robes were not pushed into the normal app. Earlier delivery evidence covered art-review routes. The shared renderer still chose legacy male class art. The production dashboard now explicitly records that app integration is incomplete.

## Prepared and verified

- Draft PR: https://github.com/funszdidiot/questwell-app/pull/9
- Verified code: `adbfc54a48a16406cf352a894ef0a93fc19f1426`
- Complete passing CI and release compilation: https://github.com/funszdidiot/questwell-app/actions/runs/37216424382
- Asset preservation, analyzer, 367 substantive Flutter regressions, 8 Node regressions and the development release build passed. This branch was built **without deployment**.
- All five male class robes use the shared renderer with rear → fixed v3 body → unified approved Everyday → front → original identity → collar → cuffs.
- Tests cover normal portrait/card callers, class selection, approved Everyday equip/unequip, fresh reconstruction, stale/unknown outfits, legacy fit gates, owned inventory/Market controls, body registration and the unchanged belt grimoire. Female and neutral regressions remain covered.
- No artwork files, body/identity pixels or robe geometry changed. Pathfinder remains retired.

## One required product decision

The old male Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle depend on legacy anatomy. Direct suit/Harvest composites exposed fixed-v3 skin/foot edges; closed-cloak paths explicitly clip the legacy body. Neither body substitution nor clipping v3 is an acceptable migration. A read-only database check found each item active and owned by one currently male profile, with zero currently equipped male entries. No personal account details were retained.

The concrete proposal temporarily makes these four male fits unavailable for purchase/equip, retains ownership, and enables the exact approved male Everyday fit. Prices, balances, class rules and other-body support stay unchanged. The unapplied SQL proposal is in PR #9 at `tool/qa/male_robe_rollout_proposed.sql`. Any concurrent stale equipped legacy entry would return to inventory when the approved migration is applied.

**Tanya's smallest action:** approve that temporary male-only availability restriction so the robes can roll out while the four old fits are rebuilt. Her explicit rule requires a stop for material product/economy behavior changes; this is not a routine implementation question or a request for final visual approval. The alternative is completing those four refits before rollout.

## What is actually deployed

Development revision `4bda55c94f78e3140fd30e3f82eed6fba9019cc8`, workflow `37216007779`, changed only the production dashboard and registry. Its existing 367 Flutter + 8 Node tests, asset/analyzer, build and deployment passed. The delivered version stamp and browser dashboard were checked. Screenshot: `questwell-male-robe-rollout-blocker.jpg`.

The normal app's avatar/purchase/equipment behavior and database remain unchanged. The new robe app correction is **not DEV DEPLOYED**. After approval: create/apply the canonical migration, deploy the corrected renderer, test delivered Hearth/Adventurer/Market and class/equipment transitions, and verify persistence before recording app delivery. No real-user account writes or new visual locks were performed in this investigation.
