// Reference renders only: all source layers and the body remain untouched.
const path = require('node:path');
const fs = require('node:fs');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const assets = path.join(root, 'assets/images/questwell/avatar');
const out = path.join(__dirname, 'art_assets/neutral_scout_v2');
async function main() {
  fs.mkdirSync(out, {recursive:true});
  const base = path.join(assets, 'base/paper_doll_neutral_v1.webp');
  const identity = path.join(assets, 'base/paper_doll_neutral_identity_v1.webp');
  await sharp(base).resize(960,1280).png().toFile(path.join(out,'fixed_base_reference.png'));
  const outfit = path.join(assets,'woodland_scout_unified_neutral_v1.webp');
  await sharp(outfit).resize(960,1280).png().toFile(path.join(out,'outfit_reference.png'));
  const dressed = await sharp(base).composite([{input:outfit},{input:identity}]).png().toBuffer();
  await sharp(dressed).resize(960,1280).png().toFile(path.join(out,'dressed_reference.png'));
  const female = await sharp(path.join(assets,'base/paper_doll_female_v1.webp')).composite(
    ['scout_trousers_female_v6.webp','scout_top_female_v6.webp','scout_boots_female_v6.webp',
      'base/paper_doll_female_identity_v1.webp'].map(p=>({input:path.join(assets,p)}))).png().toBuffer();
  await sharp(female).resize(960,1280).png().toFile(path.join(out,'female_everyday_reference.png'));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
