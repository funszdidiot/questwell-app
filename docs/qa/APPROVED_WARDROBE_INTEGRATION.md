# Approved wardrobe integration — 2026-10-04 UTC

## Current scope

Preserve the exact locked male v3 body and everyday v2 unified outfit. Their art
approval is complete; account wardrobe rollout is not. The dedicated development
entry `?review=male-everyday` compares the unchanged v3 body with and without the
approved clothing overlay. It must keep the same original body/identity and
registration in both states. It does not authenticate a user or write account data.

The earlier proposal enabled male Everyday through the live account renderer but
restored a different legacy male body on unequip. That violates the paper-doll
same-body invariant even though all individual files retained valid hashes. That
proposed capability was removed before delivery. Male account Everyday remains unavailable
until the remaining accepted fits permit a coherent same-body wardrobe transition.
Legacy account male paths are not migrated by this change.

Approved account fit scope is female + neutral for Everyday, and female-only for
Woodland Scout. Neutral Woodland remains an unaccepted candidate in explicit
development review; renderer availability alone does not authorize account
eligibility. Neutral body v4, everyday v3 and class-robe v11 integration remain in
the approved audit scope, specifically neutral Everyday ↔ all five class robes
on the same neutral v4 foundation. Existing female art and fit behavior remain fixed.

Database persistence was verified separately against the deployed authenticated-role
public RPCs using synthetic identities inside a rolled-back transaction. Browser
reviews used in-memory fixtures. No real-user login, account write, page-refresh
restoration or login-restoration flow was exercised in this browser pass. An
in-memory review alone does not establish account persistence.

## Known legacy integration limitation

The batch does not complete wardrobe-wide foundation migration. For both female
and neutral, the existing `QuestwellLayeredAdventurerArt` chest paths still select:

| Existing chest item | Current foundation path |
|---|---|
| `starter-business-suit` | Direct legacy `assets/images/questwell/avatar/base/base_{body}.webp` |
| `midnight-harvest-coat` | `QuestwellCleanBase(withTrousers: true)`, the body-specific Harvest v2 coat and existing underlayer clipping |
| `moss-green-cloak`, `hearthguard-mantle` | `QuestwellCleanBase(withTrousers: true)`, legacy class overlays and closed-cloak body/foreground masks |

`QuestwellCleanBase` assembles `clean_{body}_v1.webp` with identity/trouser regions
from legacy `base_{body}.webp`. Removing these chest items restores the approved
paper doll for supported classes, so those transitions still need coherent
foundation migration and garment-fit verification. Existing Harvest tests prove
coat selection and pixel clearance; they do not prove same-body continuity.

This is a **Priority 1 QUEUED** avatar-integration task. Catalog behavior, ownership
and availability remain unchanged. It is not a new blocker or founder request.
Current delivery claims are limited to the dedicated fixed-v3 male review and the
approved neutral Everyday ↔ five-class-robe transitions; they do not imply an
all-wardrobe or all-body migration.

## Verified delivery

Runtime code revision **`4cfef7f277eba89ac65a1ea965cdea7dfb169d1f`** was served by
`questwell-version.json` and inspected in the development browser. GitHub Actions
run **`37174925231`** passed asset verification, analyzer, **351 Flutter tests**,
**8 Node tests**, web build and development deployment. The final publishing
commit also includes a bounded Market fixture correction: changing its body now
clears unsupported equipped slugs through the shared policy while retaining
ownership. The final full gate and additional delivered Market body-switch check
are pending for that follow-up. The detailed runtime evidence below remains
verified on `4cfef7f`; the dashboard publishing stamp may therefore differ.

The exact delivered male files matched their locked SHA-256 values:

| Asset | SHA-256 |
|---|---|
| `paper_doll_male_v3.webp` | `9e35a6ebdda22719851fa37f33c81f2b6c1340719453bf50d9ac4acf9156ebda` |
| `paper_doll_male_identity_v3.webp` | `efe243c89320352e61f858dd0c5335f99f61ee91788e2b37efdb3ff58b631a1a` |
| `everyday_outfit_male_v2.webp` | `f1677830404354248d8fe13c1aec35da059946c7ee902ff21411dcca584b2cee` |

The local male verifier also passed alpha/RGBA, source correspondence, canvas and
reviewed-composite checks without regenerating artwork. Independent inspection
of the delivered screenshots passed; founder approval remains a separate existing
art lock.

## Delivered browser checks

| Surface | Verified behavior | Scope |
|---|---|---|
| Male Everyday review | Body Only ↔ Outfit toggles retain v3; enlarged review works | Dedicated fixed-body review, not account wardrobe rollout |
| Neutral robe review | All five actual class robes render | Approved v4 body/everyday v3/robe v11 family |
| Adventurer at 390px → Hearth → Adventurer | Select neutral, equip owned Everyday, Hearth shows one worn item, re-entry shows Equipped; unequip returns Hearth to zero worn items and the neutral class robe | In-memory review fixture; real renderer/callback/navigation paths |
| Neutral Everyday → male body selection | Re-equipped Everyday is removed from loadout; inventory shows 15 owned and zero equipped; unsupported action reads Fit unavailable and is disabled | Ownership retained in fixture; no male account promotion |
| Market, neutral Scout fixture | Purchase Everyday for 40 coins changes 650 → 610, marks owned; preview → Equip → In use works | Sample purchase/state, not a real account transaction |
| Market, neutral Woodland | Fit unavailable is disabled | Candidate renderer does not broaden female-only account eligibility |
| [Neutral Woodland candidate review](https://funszdidiot.github.io/questwell-app/?review=neutral-scout) | Four stages render; outfit off/on preserves v4; sleeve/wrist detail controls inspected | Technical delivered review passed; visual QA remains active, no founder lock or independent delivered Woodland screenshot audit claimed |

The browser checks do not establish real-user refresh/login persistence. Deployed
public-RPC persistence and access control were tested separately below.

Screenshots and independent delivered visual QA:

- [Male fixed-body review](male-everyday-runtime-4cfef7f.jpg)
- [Neutral class robes](neutral-robes-runtime-4cfef7f.jpg)
- [Neutral Everyday in Hearth](neutral-everyday-hearth-runtime-4cfef7f.jpg)

## Deployed persistence and security

Migration **`20261004035017`** is applied:
`supabase/migrations/20261004035017_approved_wardrobe_body_support.sql`.
`tool/qa/approved_wardrobe_body_support_result.json` records **PASS** for the
post-deployment public-RPC regression. Support is female/neutral Everyday and
female Scout Woodland; male support for both and neutral Woodland are denied.

The authenticated-role synthetic tests cover purchase/equip, retry/debit safety,
one chest slot, supported-body retention, unsupported body/class changes returning
items to inventory, missing identity, invalid body, unowned item denial and
cross-account RLS. All synthetic writes were rolled back; **zero fixture accounts
remain**. Existing public wrappers and ACLs are unchanged, internal helper execute
permission is withheld, and deployed private function bodies match the reviewed
migration. Prices remain **40/120**, activation and class/collection metadata are
unchanged, and only the fit descriptions were corrected. XP and level remain
unchanged. Security advisors report **zero findings** before and after.

The earlier candidate rollback restored original function definitions; the final
migration was then deliberately applied and retested. Do not mistake that earlier
rollback record for an outstanding deployment step.

## CI correction history

| CI revision | Result | Meaning |
|---|---|---|
| `d526da11f8d920dd2293d4816f24f4032e53186d` | Analyzer passed; 333 tests passed, 4 failed | Harness viewport/scroll and package-import problems surfaced under complete regression discovery. Gating prevented build/deploy. |
| `fcd9f987b478024b275834ab3b7720e53532563a` | 346 tests passed, 1 failed | Remaining Market modal harness tap failed; no deployment. |
| `88cda121f3cd19472bbf6322649fcdfa788ae0c2` | 346 tests passed, 1 failed | Test-only MediaQuery override zeroed the viewport; corrected by preserving actual view dimensions. No deployment. |
| `99e127b` | Quality gate passed; 350 tests passed | Deployment superseded by fixture-consistency follow-up. |
| `4cfef7f277eba89ac65a1ea965cdea7dfb169d1f` | Full gate passed; 351 Flutter + 8 Node tests; build/deploy passed | Delivered revision, assets and scoped runtime behavior verified. |

Harness corrections retain real scrolling/taps/hit-test checks and meaningful
assertions; no regression file or deployment requirement was removed.

## Delivery state and next work

The build repair, dedicated male fixed-body review and scoped approved-neutral
runtime/persistence audit are **DEV DEPLOYED**. Neutral Woodland remains **QA** as
an unaccepted candidate. Remaining male garment templates are **BUILDING** with no
new lock. Male account wardrobe rollout and legacy female/neutral chest migration
remain **QUEUED**. No founder decision is required now, and no production promotion
is implied by development delivery.

Continue the existing male robe/cuff work and neutral Woodland review. Male
Woodland Scout is explicitly **Priority 1 QUEUED**: no existing candidate/fit lock
was found, and it must use one coherent male-specific outfit on immutable v3
without cross-body scaling. Continue the queued coherent foundation migrations. After avatar/template completion, follow Issue #6
Lantern/Rug replacements, then Issue #7 architecture/scalability. Keep existing
art locks, ownership and catalog approval boundaries intact.

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
