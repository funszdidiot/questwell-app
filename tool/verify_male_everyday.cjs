// Read-only verification of the approved male foundation and unified outfit.
// No exporter is rerun and no locked file or approval record is rewritten.
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');

const root = path.resolve(__dirname, '..');
const absolute = relative => path.join(root, relative);
const read = relative => fs.readFileSync(absolute(relative));
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const foundation = JSON.parse(read('tool/male_avatar_fit_reference.json'));
const fit = JSON.parse(read('tool/male_everyday_fit_reference.json'));

async function verify(entry) {
  const bytes = read(entry.path);
  assert.equal(sha(bytes), entry.sha256, `Locked file changed: ${entry.path}`);
  const {data, info} = await sharp(bytes).ensureAlpha().raw()
      .toBuffer({resolveWithObject: true});
  assert.deepEqual([info.width, info.height, info.channels], [240, 320, 4],
      `Canvas changed: ${entry.path}`);
  const alpha = Buffer.alloc(240 * 320);
  for (let i = 0; i < alpha.length; i++) alpha[i] = data[i * 4 + 3];
  assert.equal(sha(alpha), entry.alphaSha256, `Alpha changed: ${entry.path}`);
  if (entry.rgbaSha256) assert.equal(sha(data), entry.rgbaSha256);
  if (entry.source) assert.deepEqual(bytes, read(entry.source));
}

async function main() {
  assert.deepEqual(fit.body, foundation.base);
  assert.deepEqual(fit.identity, foundation.head_hair);
  assert.deepEqual(fit.layerOrder, ['body', 'outfit', 'identity']);
  assert.deepEqual(fit.runtimeRegistration, {
    canvas: [240, 320], offset: [0, 0], scale: [1, 1], rotationDegrees: 0,
  });
  for (const entry of [fit.body, fit.outfit, fit.identity]) await verify(entry);
  assert.deepEqual(read(fit.outfit.path), read(fit.sourceOutfit.path));
  assert.equal(sha(read(fit.composite.path)), fit.composite.sha256);
  assert.equal(sha(read(fit.source.path)), fit.source.sha256);
  for (const repair of fit.registration.drawingRepairs) {
    assert.equal(sha(read(`tool/art_assets/male_everyday_v2/${repair.path}`)),
        repair.sha256);
  }
  const actual = await sharp(absolute(fit.body.path)).composite([
    {input: absolute(fit.outfit.path)}, {input: absolute(fit.identity.path)},
  ]).ensureAlpha().raw().toBuffer();
  const reviewed = await sharp(absolute(fit.composite.path))
      .ensureAlpha().raw().toBuffer();
  assert.deepEqual(actual, reviewed,
      'Runtime body → unified outfit → identity differs from reviewed pixels');
  console.log('Verified male v3 body/identity and everyday v2: exact file, alpha, source, canvas, registration and reviewed composite preservation.');
}

main().catch(error => { console.error(error); process.exitCode = 1; });
