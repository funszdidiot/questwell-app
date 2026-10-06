import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {guardedPayload} from '../deploy/hardening-contract.mjs';
const manifest=JSON.parse(readFileSync(new URL('../deploy/hardening-reviewed-state.json',import.meta.url),'utf8'));
const catalog=readFileSync(new URL('../backend_ci/catalog.sql',import.meta.url),'utf8');
const sources=manifest.migrations.map(f=>({...f,sql:readFileSync(new URL('../../'+f.path,import.meta.url),'utf8')}));
const expected={...manifest,after_schema_sha256:manifest.after_schema_sha256??'1'.repeat(64)};
test('reviewed source renders one atomic statement without replaying transaction wrappers',()=>{
  const sql=guardedPayload(sources,catalog,expected);
  assert.ok(sql.startsWith('-- questwell-hardening-source-sha256:'));
  assert.equal((sql.match(/^do \$questwell_hardening\$/gm)||[]).length,1);
  assert.equal((sql.match(/^commit;/gm)||[]).length,0);
  assert.ok(sql.includes('Hardening precondition drift'));
  assert.ok(sql.includes('Hardening postcondition failed'));
});
test('changed source bytes are refused',()=>{
  const changed=sources.map(s=>({...s})); changed[0].sql+='\n';
  assert.throws(()=>guardedPayload(changed,catalog,expected),/Source changed/);
});
test('a weakened catalog query is refused',()=>{
  assert.throws(()=>guardedPayload(sources,catalog+'\n',expected),/Catalog query changed/);
});
test('unrehearsed postcondition cannot produce an executable payload',()=>{
  assert.throws(()=>guardedPayload(sources,catalog,{...expected,after_schema_sha256:null}));
});
test('missing or reordered migration input is refused',()=>{
  assert.throws(()=>guardedPayload(sources.slice(1),catalog,expected));
  assert.throws(()=>guardedPayload([...sources].reverse(),catalog,expected));
});
