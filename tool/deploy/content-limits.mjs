import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {migrationPath} from './content-limits-contract.mjs';
import {makePlan, runDeployment} from './content-limits-runner.mjs';

const read = path => readFileSync(new URL('../../' + path, import.meta.url), 'utf8');
try {
  assert.ok(process.argv.length === 2 || (process.argv.length === 3 && process.argv[2] === '--check'));
  const input = {source: read(migrationPath), catalog: read('tool/backend_ci/catalog.sql'),
    expected: JSON.parse(read('tool/deploy/content-limits-reviewed-state.json'))};
  if (process.argv[2] === '--check') {
    makePlan(input.source, input.catalog, input.expected);
    console.log('Content rollout sources verified offline; live approval not implied.');
  } else {
    const result = await runDeployment({...input, env: process.env,
      approval: JSON.parse(read('tool/deploy/content-limits-approval.json'))});
    console.log(JSON.stringify(result));
  }
} catch {
  // Never print server bodies, SQL, environment values, or assertion diffs.
  console.error('Content rollout stopped. Reconcile approval, checks and recorded state before retry.');
  process.exitCode = 1;
}
