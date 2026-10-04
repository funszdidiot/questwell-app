# Approved wardrobe integration — 2026-10-04 UTC

## Current scope

Preserve the exact locked male v3 body and everyday v2 unified outfit. Their art
approval is complete; account wardrobe rollout is not. The dedicated development
entry `?review=male-everyday` compares the unchanged v3 body with and without the
approved clothing overlay. It must keep the same original body/identity and
registration in both states. It does not authenticate a user or write account data.

The earlier proposal enabled male Everyday through the live account renderer but
restored a different legacy male body on unequip. That violates the paper-doll
same-body invariant even though all individual files retained valid hashes. Remove
that proposed capability before delivery. Male account Everyday remains unavailable
until the remaining accepted fits permit a coherent same-body wardrobe transition.
Legacy account male paths are not migrated by this change.

Approved account fit scope is female + neutral for Everyday, and female-only for
Woodland Scout. Neutral Woodland remains an unaccepted candidate in explicit
development review; renderer availability alone does not authorize account
eligibility. Neutral body v4, everyday v3 and class-robe v11 integration remain in
the approved audit scope. Existing female art and fit behavior remain fixed.

Database persistence is tested separately through authenticated-role public RPCs
using only synthetic identities inside a rolled-back transaction. An in-memory
review does not establish account persistence or authorize a catalog activation.

## Evidence

- `python3 tool/verify_avatar_assets.py`: passed for the ingested snapshot,
  including the frozen art and three exact male runtime files. Rerun on the final
  revision after the semantic routing corrections.
- `NODE_PATH="$CODEX_PRIMARY_RUNTIME_NODE_MODULES" node tool/verify_male_everyday.cjs`:
  passed; original bytes, alpha/RGBA, source correspondence, canvas and reviewed
  composite pixels match. This read-only check does not regenerate art.
- Independent visual inspection passed on reviewed light/dark native composites
  and neck/sleeve/crotch/boot details. It does not prove account same-body continuity.
- Node preview/recovery suite: 8 tests passed on the earlier candidate.

| CI revision | Result | Meaning |
|---|---|---|
| `d526da11f8d920dd2293d4816f24f4032e53186d` | Analyzer passed; 333 tests passed, 4 failed | Harness viewport/scroll and package-import problems surfaced when all substantive tests were included. Mandatory gating prevented build/deploy. |
| `fcd9f987b478024b275834ab3b7720e53532563a` | 346 tests passed, 1 failed | Remaining failure was a Market modal test tap. No deployment completed. |
| `88cda121f3cd19472bbf6322649fcdfa788ae0c2` | 346 tests passed, 1 failed | The Market fixture still overrode view dimensions with zero-sized `MediaQueryData`; preserving actual dimensions addresses this test defect. No deployment completed. |
| New same-body and eligibility correction | Pending | Rerun the complete gate with the fixed harness, dedicated male review, no male account fit and female-only Woodland account support. Earlier passes do not validate this new revision. |

The harness corrections retain actual scroll/tap/hit-test behavior and meaningful
assertions. They do not remove a regression file or weaken the deployment gate.

The corrected `tool/qa/approved_wardrobe_body_support_result.json` rollback
experiment passed with female/neutral Everyday, female-only Woodland, and neither
item supported for male accounts. This supersedes the earlier broader experiment.
The current check preserves prices, class restrictions, ownership, catalog
activation and progression; original functions were restored exactly, the temporary
helper is absent and zero fixtures remain. No real account was used and no durable
migration is claimed. The passing rollback demonstrates the proposed scoped rules;
a deployed server change still requires its own verification.

## Delivery state

The served development baseline was checked as
`7537b962e2d04033813131c0e410876b1a0e4e73` in `questwell-version.json`.
The failed candidate gates did not deploy new code; no newer served revision is
claimed here. Third run `37174209362` completed with failure.

The dedicated male review and approved neutral audit are **QA**. Male account
wardrobe rollout is **QUEUED** pending the remaining accepted fits and coherent
same-body migration. The corrected full CI run, delivered development revision,
scoped server verification and live browser checks must be recorded before any
corresponding work item is marked DEV DEPLOYED. No production promotion is
implied or authorized by this evidence.

## Regression method

Preview requires the reusable Flutter Check workflow before build/deploy. It
discovers all substantive `*_test.dart` files; only the original generated
no-assertion `widget_test.dart` placeholder is excluded.

Cover immutable male review layers; the same v3 body before/after overlay toggles;
no accidental account selection of that review fit; supported-body and class
rules; neutral approved wardrobe restoration; female-only Woodland account
eligibility; explicit candidate review visibility; inventory callbacks; and scoped
RPC persistence. Test file hashes and semantic state transitions separately.
Historical tests that expected male equip to v3 and unequip to a different legacy
body encoded the wrong behavior and must be replaced, not cited as evidence of
correct integration.
