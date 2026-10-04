// Center the original head by a rigid pixel translation; preserve the torso.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),art=path.join(__dirname,'art_assets/neutral_paper_doll_v3');
const baseDir=path.join(root,'assets/images/questwell/avatar/base');
const W=240,H=320,DX=4,raw={width:W,height:H,channels:4};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function main(){
  const oldPath=path.join(baseDir,'paper_doll_neutral_v2.webp');
  if(sha(oldPath)!=='4c816fcb5e57ad0041bb1c032212d7a8a4070d8f2ab85e4032f77b28f9a1c636')throw Error('v2 foundation changed');
  const old=await sharp(oldPath).ensureAlpha().raw().toBuffer(),result=Buffer.from(old);
  // Use the exact user-selected edit source's generated correction only for
  // the small under-jaw/lower-hair transition, never its regenerated face.
  const patch=await sharp(path.join(art,'alignment_repair_source.png')).resize(62,46).ensureAlpha().raw().toBuffer();
  for(let y=0;y<74;y++)for(let x=0;x<W;x++){
    const i=(y*W+x)*4,sx=x-DX;
    if(sx>=0)old.copy(result,i,(y*W+sx)*4,(y*W+sx)*4+4);
    else result.fill(0,i,i+4);
  }
  // Preserve the neck base/collar/shoulders. Register the generated transition
  // one pixel left to the original neck center; taper only into the old join.
  for(let y=74;y<84;y++)for(let x=100;x<153;x++){
    const i=(y*W+x)*4,p=((y-56)*62+(x-92+1))*4;
    const amount=y<=80?1:Math.max(0,(84-y)/4);
    const a=old[i+3]/255,b=patch[p+3]/255,oa=a*(1-amount)+b*amount;
    for(let c=0;c<3;c++)result[i+c]=oa?Math.round((old[i+c]*a*(1-amount)+patch[p+c]*b*amount)/oa):0;
    result[i+3]=Math.round(oa*255);
  }
  const identity=Buffer.alloc(result.length);
  // Keep the matching complete head/neck foreground on the same registration.
  result.copy(identity,0,0,82*W*4);
  const basePath=path.join(baseDir,'paper_doll_neutral_v3.webp'),idPath=path.join(baseDir,'paper_doll_neutral_identity_v3.webp');
  await sharp(result,{raw}).webp({lossless:true}).toFile(basePath);
  await sharp(identity,{raw}).webp({lossless:true}).toFile(idPath);
  const exported=await sharp(basePath).ensureAlpha().raw().toBuffer();
  let torsoChanges=0,headTranslationErrors=0;
  const differs=(a,ai,b,bi)=>a[ai+3]!==b[bi+3]||(a[ai+3]>0&&[0,1,2].some(c=>a[ai+c]!==b[bi+c]));
  for(let y=0;y<H;y++)for(let x=0;x<W;x++){
    const i=(y*W+x)*4;
    if(y>=84&&differs(exported,i,old,i))torsoChanges++;
    if(y<74&&x>=DX&&differs(exported,i,old,(y*W+x-DX)*4))headTranslationErrors++;
  }
  if(torsoChanges||headTranslationErrors)throw Error('Head translation or fixed torso invariant failed');
  const skinCenter=y=>{
    const xs=[];
    for(let x=108;x<=140;x++){
      const i=(y*W+x)*4;
      if(exported[i+3]>240&&exported[i]>190&&exported[i+1]>95&&exported[i+2]<190&&exported[i]>exported[i+1]+30)xs.push(x);
    }
    if(!xs.length)throw Error(`No skin landmark at row ${y}`);
    return (Math.min(...xs)+Math.max(...xs))/2;
  };
  const chinCenters=[70,71,72].map(skinCenter),neckCenters=[84,85,86,87].map(skinCenter);
  const mean=v=>v.reduce((a,b)=>a+b,0)/v.length;
  const chinCenter=mean(chinCenters),neckCenter=mean(neckCenters);
  if(Math.abs(chinCenter-neckCenter)>.5)throw Error('Chin is not centered over the fixed neck');
  const full=await sharp(basePath).resize(450,600).png().toBuffer();
  const crop={left:94,top:56,width:64,height:47};
  const detail=await sharp(basePath).extract(crop).resize(448,329).flatten({background:'#f2e9db'}).png().toBuffer();
  await sharp(basePath).resize(720,960).png().toFile(path.join(art,'neutral_foundation_v3.png'));
  await sharp(basePath).resize(720,960).flatten({background:'#f2e9db'}).png().toFile(path.join(art,'neutral_foundation_v3_light.png'));
  fs.writeFileSync(path.join(art,'neck_centered_v3.png'),detail);
  const labels=Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="960" height="700"><g fill="#243a33" font-family="sans-serif"><text x="250" y="48" text-anchor="middle" font-size="25">Centered neutral avatar</text><text x="725" y="130" text-anchor="middle" font-size="25">Head and neck alignment</text><text x="725" y="530" text-anchor="middle" font-size="18">Original head · fixed body</text></g></svg>');
  await sharp({create:{width:960,height:700,channels:4,background:'#f2e9db'}}).composite([{input:full,left:25,top:75},{input:detail,left:505,top:158},{input:labels}]).png().toFile(path.join(art,'neutral-foundation-centered.png'));
  const report={repair:'rigid_head_centering_and_neck_transition',headTranslationNativePixels:[DX,0],headScaling:1,headRotationDegrees:0,canvas:[W,H],chinCenterNativeX:chinCenter,neckBaseCenterNativeX:neckCenter,centerDifferenceNativePixels:chinCenter-neckCenter,headTranslationPixelErrors:headTranslationErrors,unchangedBodyFromY:84,bodyVisibleOrAlphaChanges:torsoChanges,baseSha256:sha(basePath),identitySha256:sha(idPath),editSource:'selected_edit_source.png',sourceNote:'The exact user-selected crop was supplied to built-in imagegen. Only its corrected under-jaw transition is used; the original full avatar head is translated intact.'};
  fs.writeFileSync(path.join(art,'verification.json'),JSON.stringify(report,null,2)+'\n');
  console.log(JSON.stringify(report));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
