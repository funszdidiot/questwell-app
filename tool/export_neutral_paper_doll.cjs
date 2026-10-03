// Export the revised neutral frame once; future clothes only add layers.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const baseDir = path.join(root, 'assets/images/questwell/avatar/base');
async function main() {
  const width=240, height=320;
  const source = await sharp(path.join(__dirname,'art_assets/neutral_paper_doll_v1/frame_refined_source.png'))
    .resize(width,height,{fit:'fill'}).ensureAlpha().raw().toBuffer();
  const original = await sharp(path.join(baseDir,'base_neutral.webp')).ensureAlpha().raw().toBuffer();
  const identity = Buffer.alloc(width*height*4);
  // Restore the exact original head/hair; the new body starts below this line.
  original.copy(source,0,0,74*width*4);
  original.copy(identity,0,0,74*width*4);
  for(const [pixels,name] of [[source,'paper_doll_neutral_v1.webp'],[identity,'paper_doll_neutral_identity_v1.webp']]) {
    await sharp(pixels,{raw:{width,height,channels:4}}).webp({lossless:true}).toFile(path.join(baseDir,name));
  }
  console.log('Exported revised neutral frame with original head/hair.');
}
main().catch(error=>{console.error(error);process.exitCode=1;});
