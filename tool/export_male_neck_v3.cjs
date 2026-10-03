// Register the generated wider neck as one coherent RGBA patch.
// Keep the unapproved male candidate's face, pose and remaining body unchanged.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const folder = path.join(__dirname, 'art_assets/male_paper_doll_v3');
const previous = path.join(__dirname, 'art_assets/male_paper_doll_v2');
const width = 240, height = 320, raw = {width, height, channels:4};

async function main() {
  const base = await sharp(path.join(previous, 'paper_doll_male_candidate_v2.webp')).ensureAlpha().raw().toBuffer();
  // Register the generated neckline to the original shoulder height; the
  // generator placed its shirt slopes two native pixels too high. Taper this
  // local vertical offset from the fixed jaw and back into the shirt interior.
  const source = await sharp(path.join(folder, 'neck_repair_source.png')).resize(320,240).ensureAlpha().raw().toBuffer();
  const registered = Buffer.alloc(320*240*4);
  for(let y=0;y<240;y++) for(let x=0;x<320;x++) {
    const globalY=y/4+54;
    const offset=Math.max(0,Math.min(2,(globalY-73)*.4,(93-globalY)*.4));
    const sy=Math.max(0,Math.min(239,Math.round(y-offset*4)));
    source.copy(registered,(y*320+x)*4,(sy*320+x)*4,(sy*320+x)*4+4);
  }
  const patch = await sharp(registered,{raw:{width:320,height:240,channels:4}}).resize(80,60).raw().toBuffer();
  // The upper boundary follows BELOW the original jaw, protecting actual facial
  // pixels while admitting a continuous replacement at both old broken joins.
  const shape = 'M 99 69 L 104 68 L 109 71 L 114 73.5 L 119 74.5 L 124 73.5 L 129 71 L 134 68 L 140 69 L 146 80 L 141 88 L 134 91 L 104 91 L 97 85 Z';
  const mask = await sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="960" height="1280" viewBox="0 0 240 320"><path d="${shape}" fill="white"/></svg>`)).resize(width,height).blur(.65).ensureAlpha().raw().toBuffer();
  const result = Buffer.from(base);
  let changed=0, minX=width,minY=height,maxX=0,maxY=0;
  for(let y=65;y<96;y++) for(let x=93;x<150;x++) {
    const i=(y*width+x)*4, p=((y-54)*80+x-80)*4;
    const m=mask[i+3]/255;
    if(!m) continue;
    // Premultiplied blending avoids fringes from hidden RGB in transparent
    // pixels. Crucially, alpha is replaced too: the narrow v2 contour is NOT
    // an invariant now that Tanya explicitly requested a wider neck.
    const a=base[i+3]/255, b=patch[p+3]/255, outAlpha=a*(1-m)+b*m;
    for(let c=0;c<3;c++) result[i+c]=outAlpha ? Math.round((base[i+c]*a*(1-m)+patch[p+c]*b*m)/outAlpha) : 0;
    result[i+3]=Math.round(outAlpha*255);
    if(result[i+3]!==base[i+3] || (result[i+3]>0&&!result.subarray(i,i+3).equals(base.subarray(i,i+3)))) {
      changed++; minX=Math.min(minX,x);minY=Math.min(minY,y);maxX=Math.max(maxX,x);maxY=Math.max(maxY,y);
    }
  }
  const identity=Buffer.alloc(width*height*4);
  result.copy(identity,0,0,74*width*4);
  await sharp(result,{raw}).webp({lossless:true}).toFile(path.join(folder,'paper_doll_male_candidate_v3.webp'));
  await sharp(identity,{raw}).webp({lossless:true}).toFile(path.join(folder,'paper_doll_male_identity_candidate_v3.webp'));
  const png=await sharp(result,{raw}).png().toBuffer();
  await sharp(png).resize(720,960).png().toFile(path.join(folder,'male_paper_doll_review_v3.png'));
  await sharp(png).resize(720,960).flatten({background:'#f2e9db'}).png().toFile(path.join(folder,'male_paper_doll_review_v3_light.png'));
  await sharp(png).extract({left:80,top:54,width:80,height:60}).resize(1024,768).png().toFile(path.join(folder,'neck_detail_v3.png'));
  // Opaque light and dark QA surfaces distinguish genuine stray pixels from
  // transparent-preview artifacts. They are reproducible scratch proofs.
  for(const [name,background] of [['light','#f2e9db'],['dark','#222a30']]) {
    await sharp(png).extract({left:90,top:62,width:60,height:36}).resize(900,540).flatten({background}).png().toFile(`/workspace/scratch/male-neck-v3-${name}.png`);
  }
  const exported=await sharp(path.join(folder,'paper_doll_male_candidate_v3.webp')).ensureAlpha().raw().toBuffer();
  let outsideChanges=0, faceChanges=0;
  for(let y=0;y<height;y++) for(let x=0;x<width;x++) {
    const i=(y*width+x)*4;
    const differs=exported[i+3]!==base[i+3] || (base[i+3]>0&&!exported.subarray(i,i+3).equals(base.subarray(i,i+3)));
    if(differs && (x<93||x>=150||y<65||y>=96)) outsideChanges++;
    if(differs && y<65) faceChanges++;
  }
  if(outsideChanges||faceChanges) throw Error(`Invariant failed: outside=${outsideChanges} face=${faceChanges}`);
  console.log(JSON.stringify({changedPixels:changed,changedBounds:{minX,minY,maxX,maxY},outsideRepairChanges:outsideChanges,upperFaceChanges:faceChanges}));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
