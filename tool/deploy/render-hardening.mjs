// Offline renderer only. No network or live execution capability.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {join} from 'node:path';
import {guardedPayload,sha256} from './hardening-contract.mjs';
assert.equal(process.argv.length,2,'No target or state overrides accepted');
const root=fileURLToPath(new URL('../../',import.meta.url));
const manifest=JSON.parse(readFileSync(join(root,'tool/deploy/hardening-reviewed-state.json'),'utf8'));
for(const f of manifest.edge_files) assert.equal(sha256(readFileSync(join(root,f.path),'utf8')),f.sha256,'Reviewed Edge source changed');
process.stdout.write(guardedPayload(manifest.migrations.map(f=>({...f,sql:readFileSync(join(root,f.path),'utf8')})),
  readFileSync(join(root,'tool/backend_ci/catalog.sql'),'utf8'),manifest));
