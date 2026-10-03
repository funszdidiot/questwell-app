// Foundation draft only. No runtime avatar or existing body asset is changed.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const assets = path.join(root, 'assets/images/questwell/avatar/base');
const out = path.join(__dirname, 'art_assets/male_paper_doll_v1');
const raw = {width:240,height:320,channels:4};
async function main() {
  fs.mkdirSync(out, {recursive:true});
  const original = await sharp(path.join(assets,'base_male.webp')).ensureAlpha().raw().toBuffer();
  const reference = await sharp(path.join(assets,'clean_male_v1.webp')).ensureAlpha().raw().toBuffer();
  original.copy(reference,0,0,74*240*4);
  const referencePng = await sharp(reference,{raw}).png().toBuffer();
  await sharp(referencePng).resize(960,1280).png().toFile(path.join(out,'fixed_identity_reference.png'));
  const sourcePath = path.join(out,'body_source.png');
  if(!fs.existsSync(sourcePath)) return;
  const candidate = await sharp(sourcePath).resize(240,320,{fit:'fill'}).ensureAlpha().raw().toBuffer();
  const identity = Buffer.alloc(240*320*4);
  original.copy(candidate,0,0,74*240*4);
  original.copy(identity,0,0,74*240*4);
  await sharp(candidate,{raw}).webp({lossless:true}).toFile(path.join(out,'paper_doll_male_candidate_v1.webp'));
  await sharp(identity,{raw}).webp({lossless:true}).toFile(path.join(out,'paper_doll_male_identity_candidate_v1.webp'));
  const preview = await sharp(candidate,{raw}).png().toBuffer();
  await sharp(preview).resize(720,960).png().toFile(path.join(out,'male_paper_doll_review.png'));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
