# Male robes and Everyday: normal-app integration

Status: **QA / DEV DEPLOYING**. Last updated 2026-10-04 UTC. This corrects the earlier review-only delivery; deployment and delivered-runtime checks are pending.

## Authority and scope

Tanya directed “Push the male robes and every day outfit to the app” on 2026-10-04, then selected the non-restrictive legacy migration: replace the legacy male foundation with locked v3 and preserve existing outfit availability. All five male class defaults and Everyday equip/unequip/restoration must use the same full v3 body and identity. Business Suit, Midnight Harvest Coat, Moss Green Cloak and Hearthguard Mantle remain available and owned; fit garments to v3 without clipping or substituting the primary body. Everyday account support is female + neutral + male; Woodland remains female-only. Migration `20261004164110` supersedes the temporary restriction applied before the concurrent decision was reconciled. No new art lock or production promotion is inferred.

All five male class defaults use the shared renderer called by normal Hearth, Adventurer and Market. The full v3 body, identity, single Everyday v2 overlay, class front/collar/cuffs and repaired rear files are byte-for-byte preserved. Robe order: rear → body → Everyday → front → identity → collar → cuffs. Removing Everyday restores the class robe over the same body. Unknown/unsupported equipment cannot restore legacy anatomy. The belt grimoire keeps the avatar's hands; Pathfinder is retired.

Concurrent `questwell-dev` changes are merged and retained. The four legacy chest items use `QuestwellMaleLegacyChestFoundation`; the primary v3 body bypasses all legacy underlayer/closed-cloak clipping. Suit clipping applies only to the old garment image, excluding its old identity/hands. Existing accessory foreground occlusion uses copies of the same foundation. No existing garment surface is newly approved or locked by this integration.

## Database verification

Canonical CLI-created migrations are reconciled to their applied server versions. `20261004163513` initially applied the earlier restriction proposal. Before app publishing, the newer concurrent founder instruction was recovered and `20261004164110` restored legacy availability while retaining male Everyday support. The earlier migration found zero equipped male legacy items; no account needed restoration. No ownership, balances, prices, class requirements or active flags changed.

`tool/qa/male_robe_everyday_rollout_check.sql` verifies deployed public RPCs with synthetic authenticated identities inside a rolled-back transaction: Everyday first purchase/retry on all bodies; five class transitions; equip/unequip and chest exclusivity; all four legacy male first purchases/retries/equip/body transitions; unchanged female Scout Woodland restrictions; identity/unowned guards, RLS/ACLs, XP/level/balance invariants. **PASS** against the applied final policy. Zero retained fixtures; existing 57 ownership rows and aggregate 798 coins unchanged; security advisors returned zero findings. The starter suit is automatically owned by new profiles, so its retry is checked without asserting a false first purchase.

## Build and runtime verification

The earlier proposal passed run `37216424382` with 367 Flutter tests, 8 Node tests, assets, analyzer and release build. The combined final code must pass the full mandatory workflow again. No art assets changed.

Development deployment, delivered version/hash checks and browser verification are pending. The normal app browser is signed out. Shared Hearth/Adventurer/Market fixture checks are in-memory and do not establish real-user login or refresh persistence; deployed public-RPC checks separately test database behavior without retained data.
