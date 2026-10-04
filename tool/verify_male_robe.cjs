// Read-only verification. Never regenerate or modify the accepted template.
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const read = p => fs.readFileSync(path.join(root, p));
const hash = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fit = JSON.parse(read('tool/male_robe_fit_reference.json'));
const previous = JSON.parse(read('tool/art_assets/male_robe_v2/fit_reference.json'));

async function main() {
  assert.deepEqual(fit.layerOrder,
    ['rear', 'body', 'outfit', 'front', 'identity', 'collar', 'cuffs']);
  for (const entry of [fit.body, fit.outfit, fit.identity, ...Object.values(fit.layers)]) {
    assert.equal(hash(read(entry.path)), entry.sha256, entry.path);
    const { data, info } = await sharp(read(entry.path)).ensureAlpha().raw()
      .toBuffer({ resolveWithObject: true });
    assert.deepEqual([info.width, info.height, info.channels], [240, 320, 4]);
    const alpha = Buffer.alloc(240 * 320);
    for (let i = 0; i < alpha.length; i++) alpha[i] = data[i * 4 + 3];
    assert.equal(hash(alpha), entry.alphaSha256, `Alpha: ${entry.path}`);
  }
  for (const [key, layer] of Object.entries(fit.layers)) {
    assert.deepEqual(read(layer.path), read(
      `assets/images/questwell/avatar/classes/scout/scout_robe_${key}_male_v3.webp`));
    assert.equal(layer.alphaSha256, previous.layers[key].alphaSha256);
    if (key !== 'cuffs') assert.deepEqual(read(layer.path), read(previous.layers[key].path));
  }
  const entries = { ...fit.layers, body: fit.body, outfit: fit.outfit, identity: fit.identity };
  const actual = await sharp({ create: {
    width: 240, height: 320, channels: 4, background: '#0000',
  }}).composite(fit.layerOrder.map(key => ({ input: read(entries[key].path) })))
    .ensureAlpha().raw().toBuffer();
  const composite = read('tool/art_assets/male_robe_v3/native_composite.png');
  assert.equal(hash(composite), fit.compositeSha256);
  assert.deepEqual(actual, await sharp(composite).ensureAlpha().raw().toBuffer());
  assert.equal(hash(read(fit.source.path)), fit.source.sha256);
  assert.equal(hash(read(fit.cuffRedraw.path)), fit.cuffRedraw.sha256);
  console.log('PASS: exact male robe exports, locked body/outfit, four masks, depth order and reviewed composite.');
}
main().catch(error => { console.error(error); process.exitCode = 1; });
