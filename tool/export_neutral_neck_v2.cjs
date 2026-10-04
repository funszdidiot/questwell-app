// Founder-authorized neck seam/splice cleanup. No body proportions or pose change.
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const sharp=require('sharp');
const root=path.resolve(__dirname,'..');
const art=path.join(__dirname,'art_assets/neutral_paper_doll_v2');
const baseDir=path.join(root,'assets/images/questwell/avatar/base');
const W=240,H=320,raw={width:W,height:H,channels:4};
const crop={left:92,top:56,width:62,height:46};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function main(){
  const sourceBase=path.join(baseDir,'paper_doll_neutral_v1.webp');
  const sourceIdentity=path.join(baseDir,'paper_doll_neutral_identity_v1.webp');
  if(sha(sourceBase)!=='0c76468325e2ac1916ffc5578911c789dbb950be2b0d1344901d248d3582e078')throw Error('Original neutral body differs');
  const original=await sharp(sourceBase).ensureAlpha().raw().toBuffer();
  const identity=await sharp(sourceIdentity).ensureAlpha().raw().toBuffer();
  const next=Buffer.from(original),head=Buffer.from(identity);
  const patch=await sharp(path.join(art,'neck_repair_source.png')).resize(crop.width,crop.height).ensureAlpha().raw().toBuffer();
  // The original jaw, outer neck contour and hair remain outside this mask.
  const mask=await sharp(Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="240" height="320"><path fill="white" d="M 116 73 L 130 73 L 132 75 L 131 78 Q 132 81 128 82 L 118 82 Q 115 80 115 77 Z"/></svg>')).ensureAlpha().raw().toBuffer();
  // Tiny sideways splice fragments were inherited where the old head ended.
  // This local cleanup touches only those lower-hair join regions, not the
  // face, main hairstyle, body outline or neck proportions.
  const sideMask=await sharp(Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="240" height="320"><path fill="white" d="M 103 73 L 116 73 L 116 78 L 111 81 L 103 81 L 101 77 Z M 131 73 L 149 73 L 148 76 L 145 81 L 137 82 L 131 78 Z"/></svg>')).blur(.4).ensureAlpha().raw().toBuffer();
  const allowed=Buffer.from(mask);
  const changed=[];
  for(let y=0;y<H;y++)for(let x=0;x<W;x++){
    const i=(y*W+x)*4;
    const j=((y-crop.top)*crop.width+(x-crop.left))*4;
    const side=y>=73&&y<83 ? sideMask[i+3]/255 : 0;
    if(side){
      const a=original[i+3]/255,b=patch[j+3]/255,oa=a*(1-side)+b*side;
      for(let c=0;c<3;c++)next[i+c]=oa?Math.round((original[i+c]*a*(1-side)+patch[j+c]*b*side)/oa):0;
      next[i+3]=Math.round(oa*255);
      allowed[i+3]=Math.max(allowed[i+3],sideMask[i+3]);
    }
    const amount=mask[i+3]/255;
    if(amount){
    // Exclude existing hair/contour pixels at the side of the neck.
    if(original[i+3]>=250&&original[i]>=90&&original[i+1]>=55){
      if(patch[j+3]<240)throw Error('Repair must remain inside opaque neck');
      for(let c=0;c<3;c++)next[i+c]=Math.round(next[i+c]*(1-amount)+patch[j+c]*amount);
    }}
    if(allowed[i+3]&&y<74)next.copy(head,i,i,i+4);
    if(next[i+3]!==original[i+3]||(next[i+3]>0&&[0,1,2].some(c=>next[i+c]!==original[i+c])))changed.push([x,y]);
  }
  const baseFile=path.join(baseDir,'paper_doll_neutral_v2.webp');
  const identityFile=path.join(baseDir,'paper_doll_neutral_identity_v2.webp');
  await sharp(next,{raw}).webp({lossless:true}).toFile(baseFile);
  await sharp(head,{raw}).webp({lossless:true}).toFile(identityFile);
  const encoded=await sharp(baseFile).ensureAlpha().raw().toBuffer();
  let outsideChanges=0,alphaChanges=0,outsideAlphaChanges=0;
  for(let i=0;i<encoded.length;i+=4){
    if(encoded[i+3]!==original[i+3]){alphaChanges++;if(!allowed[i+3])outsideAlphaChanges++;}
    if(!allowed[i+3]&&original[i+3]>0&&[0,1,2].some(c=>encoded[i+c]!==original[i+c]))outsideChanges++;
  }
  if(outsideChanges||outsideAlphaChanges)throw Error('Export changes artwork outside authorized repair');
  await sharp(baseFile).resize(720,960).png().toFile(path.join(art,'neutral_foundation_v2.png'));
  await sharp(baseFile).resize(720,960).flatten({background:'#f2e9db'}).png().toFile(path.join(art,'neutral_foundation_v2_light.png'));
  for(const [label,file] of [['before',sourceBase],['after',baseFile]])
    await sharp(file).extract(crop).resize(744,552).flatten({background:'#f2e9db'}).png().toFile(path.join(art,`neck_${label}.png`));
  const full=await sharp(baseFile).resize(450,600).png().toBuffer();
  const neck=await sharp(path.join(art,'neck_after.png')).resize(434,322).png().toBuffer();
  const labels=Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="960" height="700"><g fill="#243a33" font-family="sans-serif"><text x="250" y="48" text-anchor="middle" font-size="25">Locked neutral avatar</text><text x="725" y="130" text-anchor="middle" font-size="25">Neck connection</text><text x="725" y="505" text-anchor="middle" font-size="18">Same body, pose and proportions</text><text x="725" y="538" text-anchor="middle" font-size="18">Clothing must fit this foundation</text></g></svg>');
  await sharp({create:{width:960,height:700,channels:4,background:'#f2e9db'}}).composite([{input:full,left:25,top:75},{input:neck,left:508,top:158},{input:labels}]).png().toFile(path.join(art,'neutral-foundation-locked.png'));
  const xs=changed.map(p=>p[0]),ys=changed.map(p=>p[1]);
  const report={repair:'neck_seam_and_adjacent_splice_fragments_only',canvas:[W,H],changedVisiblePixels:changed.length,changedBounds:[Math.min(...xs),Math.min(...ys),Math.max(...xs),Math.max(...ys)],outsideRepairVisibleChanges:outsideChanges,alphaChanges,outsideRepairAlphaChanges:outsideAlphaChanges,originalBaseSha256:sha(sourceBase),baseSha256:sha(baseFile),identitySha256:sha(identityFile),preserved:['face and jaw above y73','main hairstyle above the join','head position','shoulders','torso','arms and hands','hips','legs and feet','undergarments','canvas and registration']};
  fs.writeFileSync(path.join(art,'verification.json'),JSON.stringify(report,null,2)+'\n');
  console.log(JSON.stringify(report));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
