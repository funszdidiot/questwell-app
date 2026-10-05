import assert from 'node:assert/strict';

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.keys(value).sort().map(key => [key, canonical(value[key])]));
  }
  return value;
}

export function assertCatalogMatches(expected, actual) {
  assert.deepEqual(Object.keys(actual).sort(), Object.keys(expected).sort(), 'Catalog sections differ');
  for (const section of Object.keys(expected).sort()) {
    const serialize = rows => rows.map(row => JSON.stringify(canonical(row))).sort();
    const want = serialize(expected[section]);
    const got = serialize(actual[section]);
    // Keep function bodies and configuration out of failure logs.
    if (JSON.stringify(want) !== JSON.stringify(got)) {
      const missing = want.filter(row => !got.includes(row)).length;
      const extra = got.filter(row => !want.includes(row)).length;
      throw new Error(`Catalog mismatch: ${section} (${missing} missing/changed, ${extra} unexpected/changed)`);
    }
  }
}
