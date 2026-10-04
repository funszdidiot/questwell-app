// Apply image-generated local fold repairs within the founder-marked cloth areas.
const fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto'), sharp = require('sharp');
const root = path.resolve(__dirname, '..'), dir = path.join(__dirname, 'art_assets/neutral_robe_v10');
const raw = { width: 240, height: 320, channels: 4 };
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const read = p => JSON.parse(fs.readFileSync(p));
const clamp = x => Math.max(0, Math.min(1, x));
function weight(x, y) {
  const left = x >= 84 && x <= 95, right = x >= 149 && x <= 161;
  if ((!left && !right) || y < 174 || y > 190) return 0;
  const edges = left ? [84, 95] : [149, 161];
  return clamp(Math.min(x - edges[0], edges[1] - x, y - 174, 190 - y) / 2);
}
const olive = (r, g, b) => r < g * 1.32 && g > b * 1.08;

async function main() {
  const old = read(path.join(__dirname, 'art_assets/neutral_robe_v9/fit_reference.json'));
  const fixed = [old.body, old.identity, ...Object.values(old.everyday)];
  for (const a of fixed) if (sha(path.join(root, a.path)) !== a.sha256) throw Error(`Changed locked asset: ${a.path}`);
  const source = await sharp(path.join(dir, 'join_repair_source.png')).resize(124, 64).ensureAlpha().raw().toBuffer();
  const assets = {}, changes = {};
  for (const [key, a] of Object.entries(old.layers)) {
    const data = await sharp(path.join(root, a.path)).ensureAlpha().raw().toBuffer();
    let changed = 0;
    for (let y = 174; y <= 190; y++) for (let x = 84; x <= 161; x++) {
      const i = (y * 240 + x) * 4, w = weight(x, y);
      if (!w || !data[i + 3] || !olive(data[i], data[i + 1], data[i + 2])) continue;
      const si = ((y - 151) * 124 + x - 61) * 4;
      if (source[si + 3] < 220 || !olive(source[si], source[si + 1], source[si + 2])) continue;
      // Register the recessed crease from the generated cloth to each existing
      // inner tip. Its adjacent fold highlight must not become an isolated hook.
      const leftJoin = x < 120, centerX = leftJoin ? 88.5 : 156.8;
      const crease = clamp(1 - Math.pow((x - centerX) / 3.3, 2) - Math.pow((y - 187) / 4.5, 2));
      const creaseI = ((y - 151) * 124 + (leftJoin ? 90 : 156) - 61) * 4;
      let differs = false;
      for (let c = 0; c < 3; c++) {
        const repaired = source[si + c] * (1 - crease) + source[creaseI + c] * crease;
        const v = Math.round(data[i + c] * (1 - w) + repaired * w);
        if (v !== data[i + c]) differs = true;
        data[i + c] = v;
      }
      if (differs) changed++;
    }
    // Close interior opacity holes left by the old multi-layer split. This
    // continuous backing cloth stays behind the complete fixed wrist and hand.
    if (key === 'rear') for (let y = 180; y <= 190; y++) for (let x = 86; x <= 160; x++) {
      const leftJoin = x < 120;
      const cx = leftJoin ? 89.5 : 156.5;
      const fill = clamp(Math.min((4 - Math.abs(x - cx)) / 1.2, (5.5 - Math.abs(y - 185)) / 1.2));
      if (!fill || !weight(x, y)) continue;
      const i = (y * 240 + x) * 4;
      const si = ((y - 151) * 124 + (leftJoin ? 90 : 156) - 61) * 4;
      const priorAlpha = data[i + 3], nextAlpha = Math.max(priorAlpha, Math.round(255 * fill));
      if (nextAlpha === priorAlpha) continue;
      for (let c = 0; c < 3; c++) data[i + c] = Math.round((data[i + c] * priorAlpha + source[si + c] * (nextAlpha - priorAlpha)) / nextAlpha);
      data[i + 3] = nextAlpha;
      changed++;
    }
    const file = path.join(dir, `scout_robe_${key}_neutral_candidate_v10.webp`);
    if (!changed) fs.copyFileSync(path.join(root, a.path), file);
    else await sharp(data, { raw }).webp({ lossless: true }).toFile(file);
    assets[key] = { path: path.relative(root, file), sha256: sha(file) };
    changes[key] = changed;
  }
  const a = key => ({ input: path.join(root, assets[key].path) });
  const stack = [a('rear'), { input: path.join(root, old.body.path) },
    ...['boots', 'trousers', 'top'].map(k => ({ input: path.join(root, old.everyday[k].path) })),
    a('front'), { input: path.join(root, old.identity.path) }, a('collar'), a('cuffs')];
  const fitted = await sharp({ create: { ...raw, background: '#0000' } }).composite(stack).png().toBuffer();
  await sharp(fitted).png().toFile(path.join(dir, 'native_composite.png'));
  await sharp(fitted).resize(720, 960).png().toFile(path.join(dir, 'neutral_robe_v10.png'));
  for (const [name, background] of [['light', '#f2e9db'], ['dark', '#202a2b']]) {
    await sharp(fitted).resize(720, 960).flatten({ background }).png().toFile(path.join(dir, `full_${name}.png`));
    await sharp(fitted).extract({ left: 61, top: 163, width: 124, height: 44 }).resize(992, 352)
      .flatten({ background }).png().toFile(path.join(dir, `hands_${name}.png`));
  }
  const before = await sharp(path.join(__dirname, 'art_assets/neutral_robe_v9/native_composite.png')).ensureAlpha().raw().toBuffer();
  const after = await sharp(fitted).ensureAlpha().raw().toBuffer();
  let changedCompositePixels = 0, outside = 0;
  for (let y = 0; y < 320; y++) for (let x = 0; x < 240; x++) {
    const i = (y * 240 + x) * 4;
    if (!before.subarray(i, i + 4).equals(after.subarray(i, i + 4))) {
      changedCompositePixels++;
      if (!weight(x, y)) outside++;
    }
  }
  if (outside) throw Error(`${outside} pixels changed outside local joins`);
  const report = { status: 'export_checks_passed_founder_review_pending', changes, changedCompositePixels,
    changedPixelsOutsideMarkedJoins: outside, fixedArt: fixed, bodyIdentityEverydayUnchanged: true,
    foregroundLayerAlphaUnchanged: true, rearOpacityRepairConfinedToMarkedJoins: true,
    source: { path: 'tool/art_assets/neutral_robe_v10/join_repair_source.png', sha256: sha(path.join(dir, 'join_repair_source.png')) }, assets };
  fs.writeFileSync(path.join(dir, 'verification.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({ changes, changedCompositePixels, outside }));
}
main().catch(e => { console.error(e); process.exitCode = 1; });
