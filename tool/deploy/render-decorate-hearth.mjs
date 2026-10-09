// Offline renderer only; never applies SQL or accepts target overrides.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {guardedPayload,migrationPath} from './decorate-hearth-contract.mjs';
assert.equal(process.argv.length,2,'No target or state overrides accepted');
const root=new URL('../../',import.meta.url);
process.stdout.write(guardedPayload(readFileSync(new URL(migrationPath,root),'utf8'),
  readFileSync(new URL('tool/backend_ci/catalog.sql',root),'utf8'),
  JSON.parse(readFileSync(new URL('tool/deploy/decorate-hearth-reviewed-state.json',root),'utf8'))));
