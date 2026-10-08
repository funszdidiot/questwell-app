// Read-only probe, passed to Node inside the fixed disposable Storage container.
// Never run against hosted files; the calling recovery guard pins local Docker.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';

let stage = 'input';
try {
  // Supabase CLI v2.119.0 storage.service.ts mounts its named volume at /mnt.
  const root = '/mnt';
  const input = JSON.parse(fs.readFileSync(0, 'utf8'));
  stage = 'root';
  assert.equal(process.env.STORAGE_FILE_BACKEND_PATH || process.env.FILE_STORAGE_BACKEND_PATH, root);
  const rootStat = fs.lstatSync(root);
  assert.ok(rootStat.isDirectory() && !rootStat.isSymbolicLink());
  assert.equal(fs.realpathSync(root), root);
  if (input.mode === 'discover') {
    stage = 'discovery_input';
    assert.match(input.objectPath, /^[0-9a-f-]{36}\/recovery\.png$/);
    assert.ok(input.version === null || /^[0-9a-f-]{36}$/.test(input.version));
    assert.ok(['/', '-$v-'].includes(input.separator));
    const suffix = `/beta-feedback/${input.objectPath}${input.version ? `${input.separator}${input.version}` : ''}`;
    const pending = [{dir: root, depth: 0}], matches = [];
    stage = 'traversal';
    let examined = 0;
    while (pending.length) {
      const {dir, depth} = pending.pop();
      assert.ok(depth <= 20);
      for (const name of fs.readdirSync(dir)) {
        assert.ok(++examined <= 10000);
        const candidate = path.join(dir, name), stat = fs.lstatSync(candidate);
        assert.ok(!stat.isSymbolicLink());
        if (stat.isDirectory()) pending.push({dir: candidate, depth: depth + 1});
        else if (candidate.endsWith(suffix)) {
          assert.ok(stat.isFile() && stat.size <= 1024 * 1024);
          matches.push(candidate);
        }
      }
    }
    stage = matches.length === 0 ? 'no_match' : 'multiple_matches';
    assert.equal(matches.length, 1);
    stage = 'read_matching_file';
    const bytes = fs.readFileSync(matches[0]);
    process.stdout.write(JSON.stringify({relativePath: path.relative(root, matches[0]),
      bytes: bytes.length, sha256: createHash('sha256').update(bytes).digest('hex')}));
  } else {
    stage = 'absence_input';
    assert.equal(input.mode, 'absent');
    assert.equal(typeof input.relativePath, 'string');
    const parts = input.relativePath.split('/');
    assert.ok(parts.length > 0 && parts.length <= 22 && parts.every(p => p && p !== '.' && p !== '..'));
    stage = 'absence_probe';
    let current = root, absent = false;
    for (const part of parts) {
      current = path.join(current, part);
      try {
        const stat = fs.lstatSync(current);
        assert.ok(!stat.isSymbolicLink());
      } catch (error) {
        if (error.code !== 'ENOENT') throw error;
        absent = true;
        break;
      }
    }
    assert.ok(absent);
    process.stdout.write(JSON.stringify({absent: true}));
  }
} catch (error) {
  // Filesystem errors contain paths. Never disclose them in CI output.
  process.stdout.write(JSON.stringify({error: stage,
    reason: ['ENOENT', 'EACCES', 'EPERM', 'ENOTDIR', 'EAGAIN'].includes(error.code) ? error.code : 'assertion'}));
}
