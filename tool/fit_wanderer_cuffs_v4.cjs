// Register ImageGen sleeve artwork to the frozen male wrist coordinates.
// Only the two lower-sleeve regions are changed; visible pixels elsewhere stay v3.
const sharp = require('sharp');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const oldPath = 'assets/images/questwell/avatar/classes/wanderer/wanderer_coat_male_short_v3.webp';
const newPath = 'assets/images/questwell/avatar/classes/wanderer/wanderer_coat_male_short_v4.webp';

async function main() {
  const prior = await sharp(path.join(root, oldPath)).ensureAlpha().raw().toBuffer();
  const donor = await sharp(path.join(__dirname, 'art_assets/wanderer_cuffs_v4/raised_wrist_source.png'))
    .resize(240, 320).ensureAlpha().raw().toBuffer();
  const output = Buffer.from(prior);
  function sample(x, y, c) {
    const ix = Math.floor(x), iy = Math.floor(y), fx = x - ix, fy = y - iy;
    let value = 0;
    for (let dy = 0; dy < 2; dy++) for (let dx = 0; dx < 2; dx++) {
      const at = ((iy + dy) * 240 + ix + dx) * 4;
      value += donor[at + c] * (c === 3 ? 1 : donor[at + 3] / 255) *
        (dx ? fx : 1 - fx) * (dy ? fy : 1 - fy);
    }
    return value;
  }
  let changed = 0;
  for (let y = 148; y <= 180; y++) {
    const t = Math.min(1, (y - 148) / 26);
    for (let x = 54; x <= 185; x++) {
      const left = x < 120;
      const inSleeve = left ? x <= 89 - 8 * t : x >= 151 + 4 * t;
      if (!inSleeve) continue;
      const center = left ? 71 : 166;
      const sx = (x - center) / .85 + (left ? 58 : 182);
      const sy = y + 20;
      const mix = Math.min(1, (y - 148) / 7);
      const at = (y * 240 + x) * 4;
      const alpha = prior[at + 3] * (1 - mix) + sample(sx, sy, 3) * mix;
      for (let c = 0; c < 3; c++) {
        const premultiplied = prior[at + c] * prior[at + 3] / 255 * (1 - mix) + sample(sx, sy, c) * mix;
        output[at + c] = alpha > 0 ? Math.round(premultiplied * 255 / alpha) : 0;
      }
      output[at + 3] = Math.round(alpha);
      if (output.subarray(at, at + 4).compare(prior.subarray(at, at + 4))) changed++;
    }
  }
  await sharp(output, {raw: {width: 240, height: 320, channels: 4}})
    .webp({lossless: true, effort: 6}).toFile(path.join(root, newPath));
  console.log(`Exported ${newPath}; ${changed} lower-sleeve pixels changed.`);
}
main().catch(error => { console.error(error); process.exitCode = 1; });
