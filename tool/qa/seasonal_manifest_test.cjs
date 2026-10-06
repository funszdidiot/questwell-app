const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const root = path.resolve(__dirname, '../..');
function validate(change) {
  const manifest = JSON.parse(fs.readFileSync(path.join(root, 'assets/jsons/seasonal_review_fixture.json')));
  change(manifest);
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'questwell-manifest-'));
  try {
    const file = path.join(temp, 'fixture.json');
    fs.writeFileSync(file, JSON.stringify(manifest));
    return spawnSync(process.execPath, [path.join(root, 'tool/validate_seasonal_release_manifest.cjs'), file], {encoding:'utf8'});
  } finally { fs.rmSync(temp, {recursive:true, force:true}); }
}
test('valid seasonal fixture passes full preflight', () => assert.equal(validate(() => {}).status, 0));
for (const value of [undefined, 'male', [], ['male', 'male']]) {
 test('wearable body declaration rejects ' + JSON.stringify(value), () => {
   const r = validate(m => {m.items.at(-1).wearable.supported_bodies = value;});
   assert.notEqual(r.status, 0);
   assert.match(r.stderr, /supported_bodies/);
 });
}
test('undeclared body assets cannot skip validation', () => {
 const r = validate(m => {m.items.at(-1).wearable.supported_bodies = ['male'];});
 assert.notEqual(r.status, 0);
 assert.match(r.stderr, /assets_by_body/);
});
for (const [profile, kind] of [['wall_art_side','static_sprite'],['pedestal_light','wall_art_sprite']]) {
 test('reject mismatched wall render/profile ' + profile, () => {
  const r = validate(m => {m.items[2].hearth.profile_key = profile; m.items[2].hearth.render.render_kind = kind;});
  assert.notEqual(r.status, 0);
  assert.match(r.stderr, /wall_art/);
 });
}
