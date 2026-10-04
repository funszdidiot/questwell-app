# Approved neutral outfit rollout

Tanya approved on 2026-10-04: “The neutral outfits are good- push them.”

Neutral Woodland v3 is LOCKED. Its exact single-overlay bytes, locked v4 body and identity are unchanged. Neutral Everyday v3 and the five neutral class robes retain their existing locks and integration. Canonical Woodland reference: `tool/neutral_woodland_fit_reference.json`.

App policy and catalog now support female and neutral Scouts. Male Woodland remains gated. Price 120, Scout class restriction, ownership and other item availability are unchanged.

## Verification

- Asset integrity verification passed; no artwork files changed.
- Migration `20261004212323_neutral_woodland_approved_rollout.sql` applied successfully.
- `tool/qa/neutral_woodland_rollout_check.sql` passed against the account backend: neutral first purchase, one-charge retry, equip/exclusivity, female-neutral equipment persistence, male rejection, class change removal, ownership retention, Everyday across every class/body, legacy availability, RLS and RPC ACLs. All synthetic mutations rolled back.
- Security advisors: zero findings.
- Shared-renderer, Market and inventory tests updated to assert neutral equipment eligibility and locked-body outfit rendering/restoration.
- DEV DEPLOYING: full Flutter gate and delivered runtime verification pending. No real-account login is claimed.
