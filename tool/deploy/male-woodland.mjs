import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {join} from 'node:path';
import {assertDeploymentContext,assertRequiredChecks,deployWoodland,guardedMigration,
  managementRequest,migrationPath,repository,stateQuery} from './woodland-contract.mjs';

const root = fileURLToPath(new URL('../../',import.meta.url));
const expected = JSON.parse(readFileSync(join(root,'tool/deploy/woodland-approved-state.json'),'utf8'));
const sourceSql = readFileSync(join(root,migrationPath),'utf8');
const catalogSql = readFileSync(join(root,'tool/backend_ci/catalog.sql'),'utf8');

try {
  assert.ok(process.argv.length===2 || (process.argv.length===3 && process.argv[2]==='--check'),
    'Only offline --check is accepted; there are no live target/SQL overrides');
  guardedMigration(sourceSql,catalogSql,expected);
  if (process.argv[2]==='--check') {
    console.log('Reviewed Woodland source hash and atomic forward-migration payload verified offline.');
  } else {
    assertDeploymentContext(process.env);
    const revision = process.env.GITHUB_SHA;
    const checksResponse = await fetch(`https://api.github.com/repos/${repository}/commits/${revision}/check-runs?per_page=100`,{
      redirect:'error',signal:AbortSignal.timeout(15000),
      headers:{Authorization:`Bearer ${process.env.GITHUB_TOKEN}`,Accept:'application/vnd.github+json',
        'X-GitHub-Api-Version':'2022-11-28'},
    });
    if (!checksResponse.ok) throw new Error(`Cannot verify reviewed-head checks: HTTP ${checksResponse.status}`);
    assertRequiredChecks((await checksResponse.json()).check_runs,revision);
    const token = process.env.QUESTWELL_WOODLAND_MIGRATION_TOKEN;
    const query = stateQuery(catalogSql,expected.source_sha256);
    const result = await deployWoodland({expected,sourceSql,catalogSql,
      readState:async()=>{
        const response = await managementRequest(token,'query',{query,read_only:true});
        if (!response.ok) throw new Error(`Read-only deployment preflight failed: HTTP ${response.status}`);
        const rows = await response.json();
        assert.ok(Array.isArray(rows) && rows.length===1 && rows[0].state,'Invalid metadata response');
        return rows[0].state;
      },
      applyMigration:async(body,idempotencyKey)=>{
        const response = await managementRequest(token,'migrations',body,idempotencyKey);
        if (!response.ok) throw new Error(`Migration outcome requires reconciliation: HTTP ${response.status}; no automatic retry`);
      },
    });
    // No raw response, SQL, credentials or account data is logged.
    console.log(JSON.stringify({sourceRevision:revision,sourceSha256:expected.source_sha256,
      result:result.status,remoteMigrationVersion:result.version}));
    console.log('Woodland database contract verified. Client merge/deployment remains a separate checked step.');
  }
} catch (error) {
  // Network exception details may carry request context. Keep diagnostics bounded.
  console.error(error instanceof assert.AssertionError || error.message?.startsWith('Missing ')
    || /^(Unexpected database|Cannot verify|Read-only deployment|Migration outcome)/.test(error.message??'')
    ? error.message.split('\n')[0] : 'Woodland deployment stopped; inspect the recorded state before an explicit rerun.');
  process.exitCode = 1;
}
