// Read-only source/export checks; optional reproducible QA composites.
// Does not edit any avatar or garment asset, or imply founder approval.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const W = 240, H = 320;
const base = 'assets/images/questwell/avatar/';
const hand = [[159,187],[159,188],[159,189],[159,190],[159,191],[159,192],
  [159,193],[159,194],[160,194],[159,195],[160,195],[160,196]];
const heels = [[111,298],[111,299],[111,300],[147,300],[147,301]];
const offset = ([x,y]) => (y * W + x) * 4;
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
async function read(relative) {
  const input = fs.readFileSync(path.join(root, relative));
  const {data, info} = await sharp(input).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  assert.deepEqual([info.width, info.height, info.channels], [W,H,4]);
  return {path: relative, input, data, sha256: sha(input)};
}
async function main() {
  const reference = JSON.parse(fs.readFileSync(path.join(root,'tool/neutral_avatar_fit_reference.json')));
  const body = await read(reference.base.path);
  const identity = await read(reference.head_hair.path);
  assert.equal(body.sha256, reference.base.sha256);
  assert.equal(identity.sha256, reference.head_hair.sha256);
  const old = await read(base+'woodland_scout_unified_neutral_v2.webp');
  const outfit = await read(base+'woodland_scout_unified_neutral_v3.webp');
  const allowed = new Set([...hand, ...heels].map(offset));
  let changed = 0;
  for(let i=0; i<outfit.data.length; i+=4) {
    if (!outfit.data.subarray(i,i+4).equals(old.data.subarray(i,i+4))) {
      assert(allowed.has(i), `Unexpected change at ${i/4%W},${Math.floor(i/4/W)}`);
      changed++;
    }
  }
  assert.equal(changed, 17);
  for(const p of hand) assert.equal(outfit.data[offset(p)+3],0,`Hand intrusion ${p}`);
  for(const p of heels) assert.equal(outfit.data[offset(p)+3],255,`Heel leak ${p}`);
  const composite = await sharp(body.input).composite([
    {input:outfit.input}, {input:identity.input},
  ]).png().toBuffer();
  const result = {status:'PASS', candidate:false, founderLock:true,
    composition:[body, outfit, identity].map(({path,sha256})=>({path,sha256})),
    unchangedBodyAndIdentity:true, changedGarmentPixels:changed,
    handPixelsCleared:hand.length, heelPixelsOpaque:heels.length,
    accountEligibility:'female and neutral Scouts; founder approved 2026-10-04'};
  if(process.argv.includes('--render-qa')) {
    const dir = path.join(root,'tool/qa/neutral_woodland_v3');
    fs.mkdirSync(dir,{recursive:true});
    for(const [name, background] of [['light','#f4eddf'],['dark','#18252c']]) {
      const flat = await sharp(composite).flatten({background}).png().toBuffer();
      await sharp(flat).toFile(path.join(dir,`native_${name}.png`));
      await sharp(flat).resize(W*4,H*4,{kernel:'nearest'}).webp({lossless:true})
        .toFile(path.join(dir,`enlarged_${name}.webp`));
    }
    fs.writeFileSync(path.join(dir,'verification.json'),JSON.stringify(result,null,2)+'\n');
  }
  console.log(JSON.stringify(result,null,2));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
