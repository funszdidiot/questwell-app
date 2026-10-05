import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {assertCatalogMatches} from '../backend_ci/catalog.mjs';

const observed = JSON.parse(readFileSync(new URL('../backend_ci/observed_catalog.json', import.meta.url)));
test('every captured function grant retains its complete callable signature', () => {
  const signatures = new Set(observed.functions.map(f => `${f.schema}.${f.name}(${f.identity_arguments})`));
  for (const grant of observed.grants.filter(g => g.kind === 'function')) {
    assert.ok(signatures.has(`${grant.schema}.${grant.name}`), 'Grant signature must match an observed function without name-type truncation');
  }
});
test('catalog comparison accepts reordered equivalent metadata', () => {
  const same = structuredClone(observed);
  for (const rows of Object.values(same)) rows.reverse();
  assert.doesNotThrow(() => assertCatalogMatches(observed, same));
});

for (const [section, mutate] of [
  ['tables', rows => { rows[0].rls = false; }],
  ['grants', rows => { rows.pop(); }],
  ['columns', rows => { rows[0].not_null = !rows[0].not_null; }],
  ['constraints', rows => { rows.pop(); }],
  ['indexes', rows => { rows[0].valid = false; }],
  ['functions', rows => { rows[0].definition += '\n-- altered'; }],
  ['policies', rows => { rows.find(p => p.schema === 'storage').qual = 'true'; }],
  ['triggers', rows => { rows[0].enabled = 'D'; }],
  ['default_privileges', rows => { rows.pop(); }],
  ['buckets', rows => { rows[0].public = true; }],
]) {
  test(`catalog comparison catches drift in ${section}`, () => {
    const drifted = structuredClone(observed);
    mutate(drifted[section]);
    assert.throws(() => assertCatalogMatches(observed, drifted), new RegExp(`Catalog mismatch: ${section}`));
  });
}
test('catalog comparison rejects missing or unexpected metadata sections', () => {
  const missing = structuredClone(observed); delete missing.policies;
  assert.throws(() => assertCatalogMatches(observed, missing), /Catalog sections differ/);
  assert.throws(() => assertCatalogMatches(observed, {...observed, unexpected: []}), /Catalog sections differ/);
});
