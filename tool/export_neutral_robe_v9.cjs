// Correct garment depth beside the hands; preserve all existing artwork and fit.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');

const root = path.resolve(__dirname, '..');
const previous = path.join(__dirname, 'art_assets/neutral_robe_v8');
const output = path.join(__dirname, 'art_assets/neutral_robe_v9');
const raw = { width: 240, height: 320, channels: 4 };
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const json = p => JSON.parse(fs.readFileSync(p));
const sidePanelAtHand = (x, y) => y >= 181 && y <= 204 && (x <= 88 || x >= 158);

async function main() {
  const body = json(path.join(__dirname, 'neutral_avatar_fit_reference.json'));
  const day = json(path.join(__dirname, 'neutral_everyday_fit_reference.json'));
  const old = json(path.join(previous, 'fit_reference.json'));
  const fixed = [body.base, body.head_hair, ...Object.values(day.garments)];
  function verifyFixed() {
    for (const entry of fixed) {
      if (sha(path.join(root, entry.path)) !== entry.sha256) throw Error(`Changed fixed asset: ${entry.path}`);
    }
  }
  verifyFixed();
  for (const entry of Object.values(old.layers)) {
    if (sha(path.join(root, entry.path)) !== entry.sha256) throw Error(`Changed v8 source: ${entry.path}`);
  }
  const originalFront = await sharp(path.join(root, old.layers.front.path)).ensureAlpha().raw().toBuffer();
  const front = Buffer.from(originalFront);
  const transferred = Buffer.alloc(front.length);
  let movedPixels = 0;
  for (let y = 0; y < raw.height; y++) {
    for (let x = 0; x < raw.width; x++) {
      const i = (y * raw.width + x) * 4;
      if (!sidePanelAtHand(x, y) || !front[i + 3]) continue;
      front.copy(transferred, i, i, i + 4);
      front.fill(0, i, i + 4);
      movedPixels++;
    }
  }
  // Move intact side cloth behind the unchanged hands. No hand cutout or overlay.
  // The split boundaries occupy the gap between the hands and dressed hips.
  const originalRear = await sharp(path.join(root, old.layers.rear.path)).ensureAlpha().raw().toBuffer();
  const rear = await sharp(path.join(root, old.layers.rear.path))
    .composite([{ input: transferred, raw }]).ensureAlpha().raw().toBuffer();
  for (let i = 0; i < rear.length; i += 4) {
    if (!transferred[i + 3]) originalRear.copy(rear, i, i, i + 4);
  }
  const paths = {};
  for (const key of ['front', 'rear', 'cuffs', 'collar']) {
    paths[key] = path.join(output, `scout_robe_${key}_neutral_candidate_v9.webp`);
    if (key === 'cuffs' || key === 'collar') fs.copyFileSync(path.join(root, old.layers[key].path), paths[key]);
    else await sharp(key === 'front' ? front : rear, { raw }).webp({ lossless: true }).toFile(paths[key]);
  }
  const stack = [
    { input: paths.rear }, { input: path.join(root, body.base.path) },
    ...['boots', 'trousers', 'top'].map(key => ({ input: path.join(root, day.garments[key].path) })),
    { input: paths.front }, { input: path.join(root, body.head_hair.path) },
    { input: paths.collar }, { input: paths.cuffs },
  ];
  const fitted = await sharp({ create: { ...raw, background: '#0000' } }).composite(stack).png().toBuffer();
  await sharp(fitted).png().toFile(path.join(output, 'native_composite.png'));
  await sharp(fitted).resize(720, 960).png().toFile(path.join(output, 'neutral_robe_v9.png'));
  for (const [name, background] of [['light', '#f2e9db'], ['dark', '#202a2b']]) {
    await sharp(fitted).resize(720, 960).flatten({ background }).png().toFile(path.join(output, `full_${name}.png`));
    await sharp(fitted).extract({ left: 61, top: 163, width: 124, height: 44 }).resize(992, 352)
      .flatten({ background }).png().toFile(path.join(output, `hands_${name}.png`));
  }
  const basePixels = await sharp(path.join(root, body.base.path)).ensureAlpha().raw().toBuffer();
  const newPixels = await sharp(fitted).ensureAlpha().raw().toBuffer();
  const oldPixels = await sharp(path.join(previous, 'native_composite.png')).ensureAlpha().raw().toBuffer();
  const counts = { changedCompositePixels: 0, changedPixelsOutsideSideRegion: 0, opaquePalmPixelsCoveredByFront: 0 };
  for (let y = 0; y < raw.height; y++) {
    for (let x = 0; x < raw.width; x++) {
      const i = (y * raw.width + x) * 4;
      if (!newPixels.subarray(i, i + 4).equals(oldPixels.subarray(i, i + 4))) {
        counts.changedCompositePixels++;
        if (!sidePanelAtHand(x, y)) counts.changedPixelsOutsideSideRegion++;
      }
      if (y >= 188 && y <= 202 && (x >= 61 && x <= 88 || x >= 158 && x <= 185) && basePixels[i + 3] > 128 && front[i + 3] > 128) {
        counts.opaquePalmPixelsCoveredByFront++;
      }
    }
  }
  if (counts.changedPixelsOutsideSideRegion || counts.opaquePalmPixelsCoveredByFront) throw Error(JSON.stringify(counts));
  verifyFixed();
  const report = {
    status: 'export_checks_passed_founder_review_pending',
    correction: 'Whole side-cloth regions beside the hands transferred from front to rear; fixed body, cuff width, collar, drape and artwork retained.',
    sidePanelDepthRegions: { y: [181, 204], imageLeftX: [0, 88], imageRightX: [158, 239] },
    movedPixels, ...counts, fixedArt: fixed, bodyIdentityEverydayUnchanged: true,
    cuffsAndCollarByteIdenticalToV8: true,
    assets: Object.fromEntries(Object.entries(paths).map(([key, p]) => [key, { path: path.relative(root, p), sha256: sha(p) }])),
  };
  fs.writeFileSync(path.join(output, 'verification.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({ movedPixels, ...counts }));
}
main().catch(error => { console.error(error); process.exitCode = 1; });
