const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(path.join(root,p))).digest('hex');
async function main() {
  const fit=JSON.parse(fs.readFileSync(path.join(__dirname,'male_woodland_fit_reference.json')));
  for(const input of [fit.body,fit.identity,fit.everyday,fit.source,fit.outfit]) assert.equal(sha(input.path),input.sha256,input.path);
  const outfit=await sharp(path.join(root,fit.outfit.path)).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  const body=await sharp(path.join(root,fit.body.path)).ensureAlpha().raw().toBuffer();
  assert.equal(outfit.info.width,240);assert.equal(outfit.info.height,320);
  assert.equal(sha('tool/art_assets/male_woodland_v1/outfit_registered.webp'),fit.outfit.sha256);
  let coverage=0,hands=0;
  for(let y=170;y<314;y++)for(let x=50;x<200;x++) {
    const i=(y*240+x)*4;if(body[i+3]<250)continue;
    if(y>=198||(x>=86&&x<=156)) {coverage++;assert.ok(outfit.data[i+3]>=250,`Coverage ${x},${y}`);}
    if(y<198&&(x<=83||(x>=158&&x<=190))) {hands++;assert.ok(outfit.data[i+3]<=2,`Hand clearance ${x},${y}`);}
  }
  assert.ok(coverage>4300);assert.ok(hands>400);
  const composite=await sharp(path.join(root,fit.body.path)).composite([{input:path.join(root,fit.outfit.path)},{input:path.join(root,fit.identity.path)}]).ensureAlpha().raw().toBuffer();
  const reviewed=await sharp(path.join(__dirname,'art_assets/male_woodland_v1/native_composite.png')).ensureAlpha().raw().toBuffer();
  assert.deepEqual(composite,reviewed,'Reviewed composite must match exact runtime order');
  console.log(JSON.stringify({status:'PASS',coveragePixels:coverage,handPixels:hands,bodyUnchanged:true,identityUnchanged:true,everydayUnchanged:true,assetSha256:fit.outfit.sha256}));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
