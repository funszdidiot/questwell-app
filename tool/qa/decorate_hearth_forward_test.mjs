import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {guardedPayload,migrationPath} from '../deploy/decorate-hearth-contract.mjs';
const sql=readFileSync(migrationPath,'utf8');
const catalog=readFileSync('tool/backend_ci/catalog.sql','utf8');
const reviewed=JSON.parse(readFileSync('tool/deploy/decorate-hearth-reviewed-state.json','utf8'));
test('Hearth rollout refuses source/catalog changes and wrong target before SQL generation',()=>{
  assert.throws(()=>guardedPayload(sql+'\n',catalog,reviewed));
  assert.throws(()=>guardedPayload(sql,catalog+'\n',reviewed));
  assert.throws(()=>guardedPayload(sql,catalog,{...reviewed,project:'other'}));
  assert.throws(()=>guardedPayload(sql,catalog,{...reviewed,before:{...reviewed.before,tables:1}}));
  assert.ok(guardedPayload(sql,catalog,reviewed).includes('Hearth deployment scope mismatch'));
});
