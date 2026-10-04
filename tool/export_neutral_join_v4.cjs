// Repair the connected jaw / lower-hair / neck join on the centered foundation.
// Generated artwork is admitted only through a contour-shaped local repair mask.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const art = path.join(__dirname, 'art_assets/neutral_paper_doll_v4');
const baseDir = path.join(root, 'assets/images/questwell/avatar/base');
const W = 240, H = 320, raw = {width: W, height: H, channels: 4};
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function main() {
  const oldPath = path.join(baseDir, 'paper_doll_neutral_v3.webp');
  if (sha(oldPath) !== '0601c52466c328765c0520e82a6b01fd8712164d8e7d6baa58a26c06b1f49146') throw Error('Source foundation changed');
  const old = await sharp(oldPath).ensureAlpha().raw().toBuffer();
  const result = Buffer.from(old);
  // Same square crop and registration as the exact edit reference. Slightly
  // soften the generated local artwork to match the existing native sprite.
  const patch = await sharp(path.join(art, 'join_repair_source.png'))
    .resize(80, 80).blur(0.4).ensureAlpha().raw().toBuffer();
  const region = 'M 93 64 C 99 67 101 63 106 63 C 109 67 114 72 121 73 Q 124 73.7 128 72.6 C 134 70 139 65 141 63 C 145 63 151 64 155 64 L 157 83 L 136 83 Q 124 85 112 83 L 93 83 Z';
  const svg = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="240" height="320"><path d="${region}" fill="white"/></svg>`);
  const mask = await sharp(svg).blur(0.7).ensureAlpha().raw().toBuffer();
  const admitted = Buffer.alloc(old.length);
  for (let y = 60; y < 84; y++) for (let x = 90; x < 160; x++) {
    const i = (y * W + x) * 4, p = ((y - 35) * 80 + x - 86) * 4;
    let amount = mask[i + 3] / 255;
    // The crop has its own complete, single hair silhouette. Never crossfade
    // two displaced transparent silhouettes: select the replacement contour.
    if (old[i + 3] < 250 || patch[p + 3] < 250) amount = amount >= 0.5 ? 1 : 0;
    if (!amount) continue;
    const a = old[i + 3] / 255, b = patch[p + 3] / 255;
    const oa = a * (1 - amount) + b * amount;
    for (let c = 0; c < 3; c++) result[i + c] = oa ? Math.round((old[i + c] * a * (1 - amount) + patch[p + c] * b * amount) / oa) : 0;
    result[i + 3] = Math.round(oa * 255);
    admitted[i] = admitted[i + 1] = admitted[i + 2] = 255;
    admitted[i + 3] = Math.round(amount * 255);
  }
  const identity = Buffer.alloc(result.length);
  result.copy(identity, 0, 0, 84 * W * 4);
  const basePath = path.join(baseDir, 'paper_doll_neutral_v4.webp');
  const idPath = path.join(baseDir, 'paper_doll_neutral_identity_v4.webp');
  await sharp(result, {raw}).webp({lossless: true}).toFile(basePath);
  await sharp(identity, {raw}).webp({lossless: true}).toFile(idPath);
  await sharp(admitted, {raw}).png().toFile(path.join(art, 'repair_mask.png'));
  const exported = await sharp(basePath).ensureAlpha().raw().toBuffer();
  let changed = 0, bodyChanges = 0, outsideMaskChanges = 0, centralFaceChanges = 0;
  const bounds = {left: W, top: H, right: 0, bottom: 0};
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
    const i = (y * W + x) * 4;
    const differs = exported[i + 3] !== old[i + 3] || (exported[i + 3] > 0 && [0, 1, 2].some(c => exported[i + c] !== old[i + c]));
    if (!differs) continue;
    changed++;
    if (y >= 84) bodyChanges++;
    if (x >= 116 && x < 131 && y < 69) centralFaceChanges++;
    if (!admitted[i + 3]) outsideMaskChanges++;
    bounds.left = Math.min(bounds.left, x); bounds.right = Math.max(bounds.right, x);
    bounds.top = Math.min(bounds.top, y); bounds.bottom = Math.max(bounds.bottom, y);
  }
  if (bodyChanges || outsideMaskChanges || centralFaceChanges) throw Error('Fixed body or protected artwork changed');
  const skinCenter = y => {
    const xs = [];
    for (let x = 108; x <= 140; x++) {
      const i = (y * W + x) * 4;
      if (exported[i + 3] > 240 && exported[i] > 190 && exported[i + 1] > 95 && exported[i + 2] < 190 && exported[i] > exported[i + 1] + 30) xs.push(x);
    }
    if (!xs.length) throw Error('Missing skin landmark');
    return (Math.min(...xs) + Math.max(...xs)) / 2;
  };
  const mean = values => values.reduce((a, b) => a + b, 0) / values.length;
  const chinCenter = mean([70, 71, 72].map(skinCenter));
  const neckCenter = mean([84, 85, 86, 87].map(skinCenter));
  if (Math.abs(chinCenter - neckCenter) > 0.5) throw Error('Head alignment changed');
  await sharp(basePath).resize(720, 960).png().toFile(path.join(art, 'neutral_foundation_v4.png'));
  const crop = {left: 94, top: 56, width: 64, height: 47};
  for (const [name, background] of [['light', '#f2e9db'], ['dark', '#202a2b']]) {
    const full = await sharp(basePath).resize(360, 480).png().toBuffer();
    const detail = await sharp(basePath).extract(crop).resize(512, 376, {kernel: 'nearest'}).png().toBuffer();
    const smooth = await sharp(basePath).extract(crop).resize(384, 282).png().toBuffer();
    const native = await sharp(basePath).png().toBuffer();
    const ink = name === 'light' ? '#243a33' : '#f2e9db';
    const labels = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="840"><g font-family="sans-serif" fill="${ink}"><text x="30" y="42" font-size="24">Neutral foundation · join repair candidate</text><text x="45" y="90" font-size="18">Full avatar (1.5×)</text><text x="445" y="90" font-size="18">Native pixels enlarged (8×)</text><text x="90" y="610" font-size="18">Native size</text><text x="555" y="535" font-size="18">Smooth enlargement</text></g></svg>`);
    await sharp({create: {width: 1120, height: 940, channels: 4, background}}).composite([
      {input: full, left: 15, top: 110}, {input: detail, left: 445, top: 110},
      {input: native, left: 75, top: 615}, {input: smooth, left: 510, top: 560}, {input: labels, left: 0, top: 0}
    ]).png().toFile(path.join(art, `review_${name}.png`));
  }
  const full = await sharp(basePath).resize(450, 600).png().toBuffer();
  const detail = await sharp(basePath).extract(crop).resize(448, 329).png().toBuffer();
  const labels = Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="960" height="700"><g fill="#243a33" font-family="sans-serif"><text x="250" y="48" text-anchor="middle" font-size="25">Repaired neutral avatar</text><text x="725" y="130" text-anchor="middle" font-size="25">Head and neck detail</text><text x="725" y="530" text-anchor="middle" font-size="18">Continuous join · fixed body</text></g></svg>');
  await sharp({create: {width: 960, height: 700, channels: 4, background: '#f2e9db'}}).composite([
    {input: full, left: 25, top: 75}, {input: detail, left: 505, top: 158}, {input: labels, left: 0, top: 0}
  ]).png().toFile(path.join(art, 'neutral-foundation-repaired.png'));
  const report = {repair: 'continuous_contour_join', canvas: [W, H], changedVisibleOrAlphaPixels: changed, changedBounds: bounds, unchangedBodyFromY: 84, bodyVisibleOrAlphaChanges: bodyChanges, outsideRepairMaskChanges: outsideMaskChanges, centralFaceChanges, chinCenterNativeX: chinCenter, neckBaseCenterNativeX: neckCenter, baseSha256: sha(basePath), identitySha256: sha(idPath), source: 'join_repair_source.png', reference: 'join_edit_reference.png', referenceCrop: {left: 86, top: 35, width: 80, height: 80}, visualAcceptance: 'recorded_separately_in_visual_review.json'};
  fs.writeFileSync(path.join(art, 'verification.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
}
main().catch(error => {console.error(error); process.exitCode = 1;});
