const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {spawnSync} = require('node:child_process');

// Exercise Git's actual pattern semantics, isolated from user/global ignores.
// Only the root policy is copied: platform-specific files must not hide gaps.
function ignoredPaths(t, candidates) {
  const fixture = fs.mkdtempSync(path.join(os.tmpdir(), 'questwell-ignore-test-'));
  t.after(() => fs.rmSync(fixture, {recursive: true, force: true}));
  fs.copyFileSync(path.resolve(__dirname, '../../.gitignore'), path.join(fixture, '.gitignore'));
  const env = {...process.env, GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: os.devNull};
  // Do not let a parent Git hook or custom worktree redirect the disposable repo.
  for (const name of ['GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR', 'GIT_INDEX_FILE']) {
    delete env[name];
  }
  const run = (args, input) => spawnSync('git', ['-c', `core.excludesFile=${os.devNull}`, ...args], {
    cwd: fixture, env, input, encoding: 'utf8',
  });
  const init = run(['init', '--quiet', '--template=']);
  assert.equal(init.status, 0, init.error?.message || init.stderr);
  const result = run(['check-ignore', '--no-index', '--stdin'], candidates.join('\n') + '\n');
  assert.ok(result.status === 0 || result.status === 1, result.error?.message || result.stderr);
  return result.stdout.trim().split('\n').filter(Boolean).sort();
}

test('local environment files are ignored at root and in nested projects', t => {
  const candidates = [
    '.env', '.env.local', '.env.production', '.env.example.local',
    'supabase/.env', 'supabase/functions/.env.staging', 'tool/.env.local',
  ];
  assert.deepEqual(ignoredPaths(t, candidates), [...candidates].sort());
});

test('Android and Apple signing material cannot be accidentally added by default', t => {
  const candidates = [
    'android/key.properties', 'android/app/upload.jks', 'keys/release.keystore',
    'ios/signing/distribution.p12', 'keys/distribution.pfx',
    'ios/signing/app.mobileprovision', 'ios/signing/app.provisionprofile',
    'keys/AuthKey_fixture.p8',
  ];
  assert.deepEqual(ignoredPaths(t, candidates), [...candidates].sort());
});

test('generated dependency, build and local Supabase state stays untracked', t => {
  const candidates = [
    '.dart_tool/package_config.json', '.packages', '.flutter-plugins',
    '.flutter-plugins-dependencies', 'build/web/main.dart.js',
    'coverage/lcov.info', 'node_modules/fixture/index.js',
    'tool/node_modules/fixture/index.js', 'supabase/.temp/project-ref',
    'supabase/.branches/_current_branch', 'tool/__pycache__/fixture.pyc',
    'tool/fixture.pyc',
  ];
  assert.deepEqual(ignoredPaths(t, candidates), [...candidates].sort());
});

test('source, lockfiles, migrations, assets and safe config examples remain trackable', t => {
  const candidates = [
    'pubspec.yaml', 'pubspec.lock', 'package-lock.json',
    'supabase/functions/deno.lock', 'supabase/config.toml', 'supabase/seed.sql',
    'supabase/migrations/fixture.sql', 'lib/main.dart', 'test/widget_test.dart',
    'assets/images/questwell/avatar/base/fixture.png',
    'tool/art_assets/fixture/fit_reference.json',
    'docs/audit/FIX_PLAN.md', '.github/workflows/questwell-flutter-check.yml',
    '.env.example', '.env.sample', '.env.template', '.env.production.example',
    'supabase/.env.example', 'tool/.env.local.template',
    'android/key.properties.example',
  ];
  assert.deepEqual(ignoredPaths(t, candidates), []);
});
