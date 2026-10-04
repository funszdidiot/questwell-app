// Repair cuff depth membership, retaining the complete existing cloth artwork.
// Bodies, everyday garments, robe colors, contours and registration are read-only.
const fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto'), sharp = require('sharp');
const root = path.resolve(__dirname, '..'), art = path.join(__dirname, 'art_assets/neutral_robe_v7');
const previous = path.join(__dirname, 'art_assets/neutral_robe_v6');
const W = 240, H = 320, raw = {width: W, height: H, channels: 4};
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const read = p => sharp(p).ensureAlpha().raw().toBuffer();
const blank = () => sharp({create: {...raw, background: '#0000'}});
const sourceNames = {front: 'scout_robe_neutral_candidate_v6.webp', rear: 'scout_robe_rear_neutral_candidate_v6.webp', cuffs: 'scout_robe_cuff_front_neutral_candidate_v6.webp'};
const names = {front: 'scout_robe_neutral_candidate_v7.webp', rear: 'scout_robe_rear_neutral_candidate_v7.webp', cuffs: 'scout_robe_cuff_front_neutral_candidate_v7.webp'};
const cuffRegions = [{side: 'left', x0: 64, y0: 176, x1: 88, y1: 186}, {side: 'right', x0: 159, y0: 176, x1: 182, y1: 186}];
async function main() {
  const bodyLock = JSON.parse(fs.readFileSync(path.join(__dirname, 'neutral_avatar_fit_reference.json')));
  const clothingLock = JSON.parse(fs.readFileSync(path.join(__dirname, 'neutral_everyday_fit_reference.json')));
  const frozen = [bodyLock.base, bodyLock.head_hair, ...Object.values(clothingLock.garments)];
  const verifyFrozen = () => {for (const entry of frozen) if (sha(path.join(root, entry.path)) !== entry.sha256) throw Error(`Frozen art changed: ${entry.path}`);};
  verifyFrozen();
  const old = Object.fromEntries(await Promise.all(Object.entries(sourceNames).map(async ([key, name]) => [key, await read(path.join(previous, name))])));
  const front = Buffer.from(old.front), rear = Buffer.from(old.rear), cuffs = Buffer.from(old.cuffs);
  const moved = [];
  // These regions contain only the previously misclassified cuff-edge shadows.
  // Transfer existing nontransparent pixels; do not paint, clip or reshape cloth.
  for (const region of cuffRegions) {
    let count = 0;
    for (let y = region.y0; y < region.y1; y++) for (let x = region.x0; x < region.x1; x++) {
      const i = (y * W + x) * 4;
      if (!old.rear[i + 3]) continue;
      if (old.cuffs[i + 3] || old.front[i + 3]) throw Error('Source layers overlap at cuff');
      old.rear.copy(cuffs, i, i, i + 4); rear.fill(0, i, i + 4); count++;
    }
    moved.push({side: region.side, pixels: count});
  }
  let clothChanges = 0, depthChangesOutsideCuffs = 0, rearLiningChanges = 0;
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
    const i = (y * W + x) * 4;
    const before = [old.front, old.rear, old.cuffs].filter(d => d[i + 3]);
    const after = [front, rear, cuffs].filter(d => d[i + 3]);
    if (before.length > 1 || after.length > 1) throw Error('Cloth pixel assigned to multiple depth passes');
    if (before.length !== after.length || (before.length && [0, 1, 2, 3].some(c => before[0][i + c] !== after[0][i + c]))) clothChanges++;
    const inside = cuffRegions.some(r => x >= r.x0 && x < r.x1 && y >= r.y0 && y < r.y1);
    if (!inside && (rear[i + 3] !== old.rear[i + 3] || cuffs[i + 3] !== old.cuffs[i + 3])) depthChangesOutsideCuffs++;
    if (x >= 94 && x <= 153 && [0, 1, 2, 3].some(c => rear[i + c] !== old.rear[i + c])) rearLiningChanges++;
  }
  if (clothChanges || depthChangesOutsideCuffs || rearLiningChanges) throw Error('Cloth preservation failed');
  fs.copyFileSync(path.join(previous, sourceNames.front), path.join(art, names.front));
  await sharp(rear, {raw}).webp({lossless: true}).toFile(path.join(art, names.rear));
  await sharp(cuffs, {raw}).webp({lossless: true}).toFile(path.join(art, names.cuffs));
  const bodyPath = path.join(root, bodyLock.base.path), identityPath = path.join(root, bodyLock.head_hair.path);
  const everyday = ['boots', 'trousers', 'top'].map(key => ({input: path.join(root, clothingLock.garments[key].path)}));
  const everydayStack = [{input: bodyPath}, ...everyday, {input: identityPath}];
  const stack = [{input: path.join(art, names.rear)}, {input: bodyPath}, ...everyday, {input: path.join(art, names.front)}, {input: identityPath}, {input: path.join(art, names.cuffs)}];
  const fitted = await blank().composite(stack).png().toBuffer(), casual = await blank().composite(everydayStack).png().toBuffer();
  await sharp(fitted).resize(720, 960).png().toFile(path.join(art, 'neutral_robe_v7.png'));
  const labels = Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="800"><g fill="#243a33" font-family="sans-serif" font-size="24" text-anchor="middle"><text x="275" y="42">Approved everyday fit</text><text x="825" y="42">Neutral robe fitting</text></g></svg>');
  await sharp({create: {width: 1100, height: 800, channels: 4, background: '#f2e9db'}}).composite([
    {input: await sharp(casual).resize(540, 720).png().toBuffer(), left: 5, top: 65},
    {input: await sharp(fitted).resize(540, 720).png().toBuffer(), left: 555, top: 65}, {input: labels, left: 0, top: 0}
  ]).png().toFile(path.join(art, 'neutral-robe-fitting.png'));
  for (const [name, background, ink] of [['light', '#f2e9db', '#243a33'], ['dark', '#202a2b', '#f2e9db']]) {
    const detailLabels = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="970"><g fill="${ink}" font-family="sans-serif"><text x="32" y="40" font-size="25">Neutral robe · actual layered export</text><text x="570" y="99" font-size="18">Neck and shoulders</text><text x="560" y="374" font-size="18">Complete cuffs around fixed wrists</text><text x="595" y="666" font-size="18">Rear panel behind the legs</text></g></svg>`);
    const neck = await sharp(fitted).extract({left: 87, top: 62, width: 79, height: 48}).resize(395, 240).png().toBuffer();
    const wrists = await sharp(fitted).extract({left: 57, top: 155, width: 132, height: 52}).resize(594, 234).png().toBuffer();
    const hem = await sharp(fitted).extract({left: 87, top: 231, width: 76, height: 67}).resize(304, 268).png().toBuffer();
    await sharp({create: {width: 1120, height: 970, channels: 4, background}}).composite([
      {input: await sharp(fitted).resize(540, 720).png().toBuffer(), left: -10, top: 105},
      {input: neck, left: 612, top: 111}, {input: wrists, left: 518, top: 390},
      {input: hem, left: 656, top: 680}, {input: detailLabels, left: 0, top: 0}
    ]).png().toFile(path.join(art, `fit_details_${name}.png`));
    await sharp(fitted).flatten({background}).png().toFile(path.join(art, `native_${name}.png`));
    await sharp(fitted).extract({left: 57, top: 155, width: 132, height: 52}).resize(1056, 416, {kernel: 'nearest'}).flatten({background}).png().toFile(path.join(art, `cuffs_nearest_${name}.png`));
  }
  const body = await read(bodyPath), cover = await blank().composite([{input: path.join(art, names.front)}, {input: path.join(art, names.cuffs)}]).ensureAlpha().raw().toBuffer();
  const uncovered = [];
  for (let y = 91; y < 175; y++) for (let x = 65; x < 185; x++) {
    if (!(x < 96 || x > 150)) continue;
    const i = (y * W + x) * 4;
    if (body[i + 3] > 240 && body[i] > 150 && body[i + 1] > 95 && body[i] > body[i + 2] * 1.3 && cover[i + 3] < 235) uncovered.push([x, y]);
  }
  verifyFrozen();
  const report = {status: 'founder_fitting_review_pending',canvas: [W, H], body: bodyLock.base, identity: bodyLock.head_hair, everyday: clothingLock.garments, bodyIdentityEverydayUnchanged: true, movedCuffPixels: moved, clothArtworkRgbaChanges: clothChanges, depthChangesOutsideCuffRegions: depthChangesOutsideCuffs, centralRearLiningChanges: rearLiningChanges, uncoveredArmPixels: uncovered, cuffRegions, layerOrder: ['rear', 'body', 'boots', 'trousers', 'top', 'robe_front', 'identity', 'cuff_fronts'], assets: Object.fromEntries(Object.entries(names).map(([key, name]) => [key, {path: path.relative(root, path.join(art, name)), sha256: sha(path.join(art, name))}]))};
  fs.writeFileSync(path.join(art, 'verification.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({movedCuffPixels: moved, clothArtworkRgbaChanges: clothChanges, centralRearLiningChanges: rearLiningChanges, uncoveredArmPixels: uncovered.length, bodyIdentityEverydayUnchanged: true}));
  if (uncovered.length) throw Error('Sleeve coverage check failed');
}
main().catch(error => {console.error(error); process.exitCode = 1;});
