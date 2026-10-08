// Offline only: prints reviewed SQL; never accepts credentials or sends requests.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {guardedPayload, migrationPath} from './content-limits-contract.mjs';
assert.equal(process.argv.length, 2, 'No target or state overrides accepted');
const root = new URL('../../', import.meta.url);
const reviewed = JSON.parse(readFileSync(new URL('tool/deploy/content-limits-reviewed-state.json', root), 'utf8'));
process.stdout.write(guardedPayload(readFileSync(new URL(migrationPath, root), 'utf8'),
  readFileSync(new URL('tool/backend_ci/catalog.sql', root), 'utf8'), reviewed));
