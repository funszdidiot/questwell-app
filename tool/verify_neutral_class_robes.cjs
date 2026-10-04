// Verify the frozen neutral paper doll and build the actual nine-layer lineup.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const fit = JSON.parse(fs.readFileSync(path.join(__dirname, 'neutral_robe_fit_reference.json')));
const art = path.join(__dirname, 'art_assets/neutral_class_robes_v1');
const classes = ['scout', 'scholar', 'alchemist', 'guardian', 'wanderer'];
const suffix = {front: 'robe', rear: 'robe_rear', cuffs: 'robe_cuff_front', collar: 'robe_collar'};
const abs = p => path.join(root, p);
const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const raw = {width: 240, height: 320, channels: 4};

async function main() {
  const fixed = [fit.body, fit.identity, ...Object.values(fit.everyday)];
  for (const entry of [...fixed, ...Object.values(fit.layers)]) {
    if (sha(fs.readFileSync(abs(entry.path))) !== entry.sha256) throw Error('Locked input changed: ' + entry.path);
  }
  for (const [part, entry] of Object.entries(fit.everyday)) {
    if (sha(fs.readFileSync(abs(`assets/images/questwell/avatar/everyday_${part}_neutral_v3.webp`))) !== entry.sha256) {
      throw Error('Promoted everyday layer changed: ' + part);
    }
  }
  const results = {}, tiles = [];
  for (const name of classes) {
    const files = {}, checks = {};
    for (const [part, ending] of Object.entries(suffix)) {
      const p = `assets/images/questwell/avatar/classes/${name}/${name}_${ending}_neutral_v1.webp`;
      files[part] = abs(p);
      const {data, info} = await sharp(files[part]).ensureAlpha().raw().toBuffer({resolveWithObject: true});
      if (info.width !== 240 || info.height !== 320) throw Error('Registration changed: ' + p);
      const alpha = Buffer.alloc(240 * 320);
      for (let i = 0; i < alpha.length; i++) alpha[i] = data[i * 4 + 3];
      if (sha(alpha) !== fit.layers[part].alphaSha256) throw Error('Alpha changed: ' + p);
      checks[part] = {path: p, sha256: sha(fs.readFileSync(files[part])), alphaSha256: sha(alpha), exactTemplateAlpha: true};
    }
    const inputs = [files.rear, abs(fit.body.path), ...['boots', 'trousers', 'top'].map(k => abs(fit.everyday[k].path)), files.front, abs(fit.identity.path), files.collar, files.cuffs];
    const native = await sharp({create: {...raw, background: '#0000'}}).composite(inputs.map(input => ({input}))).png().toBuffer();
    const dir = path.join(art, name);
    fs.mkdirSync(dir, {recursive: true});
    await sharp(native).toFile(path.join(dir, 'verified_native.png'));
    const title = name[0].toUpperCase() + name.slice(1);
    const label = Buffer.from(`<svg width="240" height="40"><text x="120" y="28" text-anchor="middle" font-family="sans-serif" font-size="18" fill="#283329">${title}</text></svg>`);
    tiles.push({input: native, left: classes.indexOf(name) * 240, top: 45});
    tiles.push({input: label, left: classes.indexOf(name) * 240, top: 365});
    results[name] = checks;
  }
  const heading = Buffer.from('<svg width="1200" height="45"><text x="600" y="29" text-anchor="middle" font-family="sans-serif" font-size="22" fill="#283329">Questwell · Locked neutral robe fit</text></svg>');
  await sharp({create: {width: 1200, height: 415, channels: 4, background: '#f2e9db'}}).composite([{input: heading, left: 0, top: 0}, ...tiles]).png().toFile(path.join(art, 'neutral_class_robes_v1.png'));
  fs.writeFileSync(path.join(art, 'verification.json'), JSON.stringify({status: 'passed', template: 'tool/neutral_robe_fit_reference.json', fixedAssetsUnchanged: true, promotedEverydayIdentical: true, layerOrder: fit.layerOrder, classes: results}, null, 2) + '\n');
  console.log('Verified all 20 robe alpha planes, five fixed body/everyday inputs and three promoted everyday copies. Lineup rendered from actual runtime assets.');
}
main().catch(error => { console.error(error); process.exitCode = 1; });
