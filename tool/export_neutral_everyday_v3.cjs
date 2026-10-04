// Continuous waistband refinement on garments only. Approved bodies are read-only.
const fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto'), sharp = require('sharp');
const root = path.resolve(__dirname, '..'), art = path.join(__dirname, 'art_assets/neutral_everyday_v3');
const previous = path.join(__dirname, 'art_assets/neutral_everyday_v2');
const assets = path.join(root, 'assets/images/questwell/avatar');
const W = 240, H = 320, raw = {width: W, height: H, channels: 4};
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function main() {
  const lock = JSON.parse(fs.readFileSync(path.join(__dirname, 'neutral_avatar_fit_reference.json')));
  const bodyPath = path.join(root, lock.base.path), identityPath = path.join(root, lock.head_hair.path);
  for (const key of ['base', 'head_hair']) if (sha(path.join(root, lock[key].path)) !== lock[key].sha256) throw Error('Locked avatar changed');
  const oldPath = path.join(previous, 'everyday_trousers_neutral_candidate_v2.webp');
  const old = await sharp(oldPath).ensureAlpha().raw().toBuffer(), trousers = Buffer.from(old);
  const source = await sharp(path.join(art, 'waistband_repair_source.png')).resize(80, 80).blur(0.3).ensureAlpha().raw().toBuffer();
  const boundary = 'M 82 138 H 166 V 171 Q 151 174 137 171 Q 125 174 113 172 Q 98 175 82 171 Z';
  const mask = await sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="240" height="320"><path d="${boundary}" fill="white"/></svg>`)).blur(1).ensureAlpha().raw().toBuffer();
  const admitted = Buffer.alloc(old.length);
  for (let y = 140; y < 178; y++) for (let x = 84; x < 164; x++) {
    const i = (y * W + x) * 4, p = ((y - 140) * 80 + x - 84) * 4;
    let amount = mask[i + 3] / 255;
    // Import a complete edge; blend only fully opaque cloth interiors.
    if (old[i + 3] < 250 || source[p + 3] < 250) amount = amount >= 0.5 ? 1 : 0;
    if (!amount) continue;
    const a = old[i + 3] / 255, b = source[p + 3] / 255, oa = a * (1 - amount) + b * amount;
    for (let c = 0; c < 3; c++) trousers[i + c] = oa ? Math.round((old[i + c] * a * (1 - amount) + source[p + c] * b * amount) / oa) : 0;
    trousers[i + 3] = Math.round(oa * 255);
    admitted[i] = admitted[i + 1] = admitted[i + 2] = 255; admitted[i + 3] = Math.round(amount * 255);
  }
  const topPath = path.join(previous, 'everyday_top_neutral_candidate_v2.webp');
  const bootsPath = path.join(previous, 'everyday_boots_neutral_candidate_v2.webp');
  const trousersPath = path.join(art, 'everyday_trousers_neutral_candidate_v3.webp');
  await sharp(trousers, {raw}).webp({lossless: true}).toFile(trousersPath);
  await sharp(admitted, {raw}).png().toFile(path.join(art, 'waistband_repair_mask.png'));
  const layers = [bootsPath, trousersPath, topPath];
  const blank = {create: {width: W, height: H, channels: 4, background: {r: 0, g: 0, b: 0, alpha: 0}}};
  const clothes = await sharp(blank).composite(layers.map(input => ({input}))).png().toBuffer();
  const fitted = await sharp(bodyPath).composite([{input: clothes}, {input: identityPath}]).png().toBuffer();
  await sharp(fitted).resize(720, 960).png().toFile(path.join(art, 'neutral_everyday_v3.png'));
  const female = await sharp(path.join(assets, 'base/paper_doll_female_v1.webp')).composite(
    ['scout_boots_female_v6.webp', 'scout_trousers_female_v6.webp', 'scout_top_female_v6.webp', 'base/paper_doll_female_identity_v1.webp'].map(p => ({input: path.join(assets, p)}))
  ).png().toBuffer();
  for (const [name, background, ink] of [['light', '#f2e9db', '#243a33'], ['dark', '#202a2b', '#f2e9db']]) {
    const face = await sharp(fitted).extract({left: 82, top: 65, width: 91, height: 71}).resize(364, 284).png().toBuffer();
    const waist = await sharp(fitted).extract({left: 89, top: 140, width: 72, height: 48}).resize(432, 288).png().toBuffer();
    const boots = await sharp(fitted).extract({left: 65, top: 275, width: 131, height: 45}).resize(524, 180).png().toBuffer();
    const labels = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="1040" height="930"><g font-family="sans-serif" fill="${ink}"><text x="35" y="40" font-size="25">Neutral everyday fitting · approved body unchanged</text><text x="505" y="82" font-size="18">Neck, shoulders and sleeve openings</text><text x="530" y="419" font-size="18">Continuous waistband</text><text x="555" y="760" font-size="18">Trouser hems and boots</text></g></svg>`);
    await sharp({create: {width: 1040, height: 980, channels: 4, background}}).composite([
      {input: await sharp(fitted).resize(600, 800).png().toBuffer(), left: -70, top: 95},
      {input: face, left: 558, top: 105}, {input: waist, left: 524, top: 445},
      {input: boots, left: 486, top: 785}, {input: labels, left: 0, top: 0}
    ]).png().toFile(path.join(art, `fit_details_${name}.png`));
  }
  const titles = Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="800"><g font-family="sans-serif" fill="#243a33" text-anchor="middle"><text x="275" y="42" font-size="24">Approved female design</text><text x="825" y="42" font-size="24">Neutral everyday fitting</text></g></svg>');
  await sharp({create: {width: 1100, height: 800, channels: 4, background: '#f2e9db'}}).composite([
    {input: await sharp(female).resize(540, 720).png().toBuffer(), left: 5, top: 65},
    {input: await sharp(fitted).resize(540, 720).png().toBuffer(), left: 555, top: 65}, {input: titles, left: 0, top: 0}
  ]).png().toFile(path.join(art, 'neutral-everyday-comparison.png'));
  const body = await sharp(bodyPath).ensureAlpha().raw().toBuffer(), coverage = await sharp(clothes).ensureAlpha().raw().toBuffer();
  let exposedLowerBody = 0, trouserChangesOutsideRepair = 0;
  const bounds = {left: W, top: H, right: 0, bottom: 0}; let changed = 0;
  for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
    const i = (y * W + x) * 4;
    if (y >= 157 && x >= 65 && x < 195 && !(y < 214 && (x < 90 || x > 157)) && body[i + 3] > 240 && coverage[i + 3] < 235) exposedLowerBody++;
    const differs = trousers[i + 3] !== old[i + 3] || (trousers[i + 3] > 0 && [0, 1, 2].some(c => trousers[i + c] !== old[i + c]));
    if (differs) {
      changed++; if (!admitted[i + 3]) trouserChangesOutsideRepair++;
      bounds.left = Math.min(bounds.left, x); bounds.right = Math.max(bounds.right, x); bounds.top = Math.min(bounds.top, y); bounds.bottom = Math.max(bounds.bottom, y);
    }
  }
  for (const key of ['base', 'head_hair']) if (sha(path.join(root, lock[key].path)) !== lock[key].sha256) throw Error('Avatar changed during garment export');
  const report = {body: lock.base, identity: lock.head_hair, garmentLayersInOrder: layers.map(p => ({path: path.relative(root, p), sha256: sha(p)})), baseAndIdentityUnchanged: true, topAndBootsReusedWithoutChanges: true, exposedLowerBodyPixels: exposedLowerBody, trouserChangesOutsideRepair, changedTrouserPixels: changed, changedBounds: bounds, visualReview: 'see_visual_review.json'};
  fs.writeFileSync(path.join(art, 'verification.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
  if (exposedLowerBody || trouserChangesOutsideRepair) throw Error('Garment fit/preservation check failed');
}
main().catch(error => {console.error(error); process.exitCode = 1;});
