# Approved wardrobe integration — 2026-10-04 UTC

## Scope

Integrate the exact locked male v3 body and everyday v2 unified outfit. The existing
`everyday-adventurer-outfit` inventory item selects this renderer on male bodies.
Female and neutral fits retain their own assets. Male Woodland remains unavailable;
legacy male class outfits remain in place until their new body-specific robe
template is accepted. No old robe is placed over the newly locked body.

The development entry `?review=male-everyday` uses the real Adventurer and Hearth
widgets with explicit sample ownership and in-memory state. This route is not an
authentication bypass and does not write account data. It exercises equip/unequip,
class-outfit restoration, body selection and cross-screen rendering. Database
persistence is tested separately through authenticated-role public RPCs using only
synthetic identities inside a rolled-back transaction.

## Evidence

- `python3 tool/verify_avatar_assets.py`: PASS, including all existing frozen art
  and the three newly ingested runtime files.
- `NODE_PATH="$CODEX_PRIMARY_RUNTIME_NODE_MODULES" node tool/verify_male_everyday.cjs`:
  PASS; original file bytes, alpha, source correspondence, authored canvas and
  reviewed composite pixels match. This read-only check does not regenerate art.
- Independent visual inspection: PASS on reviewed light/dark native composites
  and neck/sleeve/crotch/boot details; founder approval remains a separate record.
- Node preview/recovery suite: 8 tests passed.
- First full CI on `d526da11f8d920dd2293d4816f24f4032e53186d`: analyzer passed;
  333 tests passed, 4 test-harness failures. The mandatory quality dependency
  prevented build and deployment. Corrections address viewport/scroll visibility
  and package import consistency; no assertion or regression file was removed.
- Candidate server migration: rollback preview PASS. See
  `tool/qa/approved_wardrobe_body_support_result.json`. Prices, class restrictions,
  catalog activation, ownership and progression remain unchanged. No real account
  was used; the original function definitions were restored and no fixture remained.

## Delivery state

QA in progress. The corrected full CI run, delivered development revision,
durable migration verification and live browser checks must be recorded before
this integration is marked DEV DEPLOYED. No production promotion is authorized.

## Regression method

Preview calls the reusable Flutter Check workflow before its build/deploy jobs.
All substantive `*_test.dart` files are discovered automatically; only the original
generated no-assertion `widget_test.dart` placeholder is excluded. This prevents a
newly added regression file from silently missing the deployment gate. Tests cover
the immutable male layers, all-class everyday rendering/restoration, body/class
equipment gates, inventory callbacks and cross-screen in-memory loadouts. The
current server regression is `approved_wardrobe_body_support_check.sql`; the older
female-only SQL script is retained as historical release evidence.
