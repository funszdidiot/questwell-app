# Avatar and familiar magic — October 9, 2026

Status: QA; release authorized, not live. Tanya approved the preview, then
150 coins each for Starlight Aura and Enchanted Leaves for release once checks
pass. Boston Terrier Stardust Wiggle and Hearth Cat Moonlit Purr are included
free. All classes/bodies are eligible. No new inventory grants or balance edits.

The shared renderer keeps fixed bodies and sprites unchanged. Pet accents reuse
the existing clock. Reduced-motion and hidden-route behavior is covered by tests.
The review route offers all four effects, both familiars and all three bodies.
Market samples and renderer capability now include the approved avatar effects.

## Guarded catalog delivery

The pinned CLI created `20261009221011_avatar_magic_catalog.sql`. It stages only
two data rows; `docs/releases/avatar-magic-2026/activate.sql` activates them within
the same guarded atomic payload. No schema, policy or purchase function changes.
`tool/deploy/magic-reviewed-state.json` locks the reviewed live state: 58 history
records, unchanged schema/purchase function and all unrelated catalog data.
Any drift stops execution without a write; ambiguous writes are never retried.

Tanya separately approved a Questwell-only, 24-hour credential with Database Read
and Migrations Read-write, stored securely as `QUESTWELL_MAGIC_MIGRATION_TOKEN`.
Creation and GitHub storage were verified October 9; it expires October 10.
Other release credentials must not be reused. No secret value is recorded here.

After visual review and exact-revision CI, merge to `questwell-dev` under the
approved development release scope. Verify its served revision. The dedicated
`deploy/avatar-magic-approved` branch triggers the reviewed forward workflow,
which requires same-head client/backend checks and served bundle markers before
one Management API migration. Independently verify exact prices, availability
and one matching migration record. No root migration replay or history repair.
No promotion to `flutterflow` or App Store/public launch is included.

## Validation

Initial 1f28d7a and combined 46b044b passed all seven workflows. Dark enlarged
composites were inspected for every body and Tanya approved the preview. Expanded
light/dark, native/enlarged captures exist in artifact 11645213977 from run
37992007722, but the cloud browser security policy blocked downloading it.
Expanded visual inspection remains unresolved; do not infer it from CI success.

The new release checks exercise atomic rollback on pre/postcondition drift,
authenticated purchase retry with one charge, all 15 body/class combinations,
equip/unequip/restoration, effect replacement, ownership and purchase event counts.
These new catalog checks require fresh CI. Local offline deployment/security tests
passed. Actual served-app and physical iPhone verification remain separate.
