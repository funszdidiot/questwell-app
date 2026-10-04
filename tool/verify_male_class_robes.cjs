// Read-only validation of surfaces, immutable inputs and reviewed composites.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const read = p => fs.readFileSync(path.join(root, p));
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fit = JSON.parse(read('tool/male_robe_fit_reference.json'));
const catalog = JSON.parse(read('tool/art_assets/male_class_robes_v1/exports.json'));
async function main() {
  for (const entry of [fit.body, fit.identity, fit.outfit, ...Object.values(fit.layers)]) {
    assert.equal(sha(read(entry.path)), entry.sha256);
  }
  assert.deepEqual(catalog.layerOrder, fit.layerOrder);
  for (const [name, variant] of Object.entries(catalog.classes)) {
    for (const [part, layer] of Object.entries(variant.layers)) {
      assert.equal(sha(read(layer.path)), layer.sha256);
      const {data, info} = await sharp(read(layer.path)).ensureAlpha().raw().toBuffer({resolveWithObject:true});
      assert.deepEqual([info.width, info.height, info.channels], [240,320,4]);
      const alpha = Buffer.alloc(240*320);
      for (let i=0;i<alpha.length;i++) alpha[i]=data[i*4+3];
      assert.equal(sha(alpha), fit.layers[part].alphaSha256);
    }
    const dir = `tool/art_assets/male_class_robes_v1/${name}`;
    assert.equal(sha(read(dir+'/robe_source.png')), variant.sourceSha256);
    const composite = read(dir+'/native_composite.png');
    assert.equal(sha(composite), variant.compositeSha256);
    const entries = {...variant.layers, body:fit.body, outfit:fit.outfit, identity:fit.identity};
    const actual = await sharp({create:{width:240,height:320,channels:4,background:'#0000'}})
      .composite(fit.layerOrder.map(key=>({input:read(entries[key].path)}))).ensureAlpha().raw().toBuffer();
    assert.deepEqual(actual, await sharp(composite).ensureAlpha().raw().toBuffer());
  }
  console.log('PASS: 16 class layers, exact locked masks and four reviewed runtime composites.');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
