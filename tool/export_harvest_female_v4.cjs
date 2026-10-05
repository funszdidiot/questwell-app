// One ImageGen coat source, uniformly normalized onto the locked 240x320 canvas.
// No body edits, per-piece transforms, garment warps or replacement-hand pixels.
// Run from repository root with NODE_PATH pointing to the installed sharp module.
const fs = require('node:fs');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const sharp = require('sharp');
const dir = 'tool/art_assets/harvest_female_v4/';
const root = 'assets/images/questwell/avatar/';
const sha = data => crypto.createHash('sha256').update(data).digest('hex');

(async () => {
  const ref = JSON.parse(fs.readFileSync('tool/female_avatar_fit_reference.json', 'utf8'));
  for (const input of [ref.frozen_body, ref.frozen_head_hair, ref.approved_outfit]) {
    assert.equal(sha(fs.readFileSync(input.path)), input.sha256, input.path);
  }
  const coat = await sharp(dir + 'coat_source_05.png').resize({width: 122}).png().toBuffer();
  const asset = root + 'harvest_coat_female_v4.webp';
  await sharp({create: {width: 240, height: 320, channels: 4, background: '#00000000'}})
    .composite([{input: coat, left: 57, top: 51}]).webp({lossless: true}).toFile(asset);
  const outputs = [{path: asset, sha256: sha(fs.readFileSync(asset))}];
  for (const [name, garment] of [['before', root + 'harvest_coat_female_v3.webp'], ['after', asset]]) {
    const composite = await sharp(ref.frozen_body.path).composite([
      ...['boots', 'trousers'].map(part => ({input: root + `scout_${part}_female_v6.webp`})),
      {input: garment}, {input: ref.frozen_head_hair.path},
    ]).png().toBuffer();
    for (const [background, color] of [['light', '#f4eddf'], ['dark', '#18252c']]) {
      const path = dir + name + '_' + background + '.jpg';
      await sharp(composite).flatten({background: color}).resize(720, 960)
        .jpeg({quality: 95, chromaSubsampling: '4:4:4'}).toFile(path);
      outputs.push({path, sha256: sha(fs.readFileSync(path))});
    }
  }
  console.log(JSON.stringify({source: {
    path: dir + 'coat_source_05.png', sha256: sha(fs.readFileSync(dir + 'coat_source_05.png')),
  }, uniformResizeWidth: 122, offset: [57, 51], outputs}, null, 2));
})().catch(error => { console.error(error); process.exitCode = 1; });
