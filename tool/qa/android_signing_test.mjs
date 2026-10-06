import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

test('Android release selects the private release signing configuration', () => {
  const source = readFileSync(new URL('../../android/app/build.gradle', import.meta.url), 'utf8');
  const buildTypes = source.split('buildTypes {')[1];
  assert.ok(buildTypes, 'Android build types must be present');
  assert.doesNotMatch(buildTypes, /signingConfig\s+signingConfigs\.debug\b/,
    'Release must never fall back to the debug key');
  assert.match(buildTypes, /release\s*\{\s*signingConfig\s+signingConfigs\.release\b/);
});
