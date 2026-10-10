# Avatar and familiar magic — October 9, 2026

Status: QA passed for effects; refreshed combined-revision CI in progress, not live. Tanya approved the preview, then
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
composites were inspected for every body and Tanya approved the preview. Tanya supplied the expanded review ZIP directly after browser download was blocked.
All 12 actual renderer captures (three bodies, light/dark, 1x/2x) were visually
inspected on October 9 America/Chicago: faces/hands stay clear, leaf orbit stays
at the feet, familiar silhouettes remain readable, and no effect clipping was
found. Light-background sparkles are intentionally subtle in reduced motion.
Uploaded archive SHA-256: `27d03cfe10fd164c59b3187b5c664637ecb4386634eefac8a461bafcbdff8d99`.
This records the supplied archive, not a claim that it matches an API digest.

The new release checks exercise atomic rollback on pre/postcondition drift,
authenticated purchase retry with one charge, all 15 body/class combinations,
equip/unequip/restoration, effect replacement, ownership and purchase event counts.
All eight workflows passed head `69f972f`, including the isolated catalog checks.
The newer iOS registered-identity change from `13230d5` is now integrated; fresh
combined-revision CI is required. Local offline deployment/security tests passed. Actual served-app and physical iPhone verification remain separate.
