// Neck-only correction to the unapproved male foundation, not a body rebuild.
// Import only the generated neck patch; preserve every other v1 pixel.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname,'..');
const src = path.join(__dirname,'art_assets/male_paper_doll_v2');
const previous = path.join(__dirname,'art_assets/male_paper_doll_v1');
const W=240,H=320,raw={width:W,height:H,channels:4};
async function main(){
  fs.mkdirSync(src,{recursive:true});
  const base=await sharp(path.join(previous,'paper_doll_male_candidate_v1.webp')).ensureAlpha().raw().toBuffer();
  const patch=await sharp(path.join(src,'neck_repair_source.png')).resize(80,60).ensureAlpha().raw().toBuffer();
  const result=Buffer.from(base);
  const boundary=[[109,74],[126,74],[127,76],[131,77.5],[134,79],[132.8,80.8],
    [128.9,83],[124,84.7],[119.5,85],[114,84.5],[110,82.4],[106.5,79.5],[108,77.4]];
  const neckMask=await sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="960" height="1280" viewBox="0 0 240 320"><polygon points="${boundary.map(p=>p.join(',')).join(' ')}" fill="white"/></svg>`))
    .resize(W,H).blur(.65).ensureAlpha().raw().toBuffer();
  let changed=0;
  for(let y=71;y<87;y++)for(let x=100;x<143;x++){
    const i=(y*W+x)*4,pi=((y-54)*80+x-80)*4;
    const [r,g,b,a]=base.subarray(i,i+4);
    const collarFragment=y<74&&((x>=104&&x<=111)||(x>=126&&x<=134))&&r>85&&g>70&&b>g*.82&&r-g<70&&a>32;
    const neckSkin=y>=74&&neckMask[i+3]>0&&a>180&&r-g>28&&b<g*.83;
    if(!collarFragment&&!neckSkin)continue;
    // Leave the jaw/face, hair and ivory undershirt intact; soften skin shading
    // into the unchanged jaw and neckline instead of creating another hard cut.
    const blend=collarFragment?1:(neckMask[i+3]/255)*Math.min(1,(y-73)/3,(87-y)/4);
    for(let c=0;c<4;c++)result[i+c]=Math.round(base[i+c]*(1-blend)+patch[pi+c]*blend);
    if(neckSkin&&!collarFragment)result[i+3]=a;
    if(!result.subarray(i,i+4).equals(base.subarray(i,i+4)))changed++;
  }
  const identity=Buffer.alloc(W*H*4);
  result.copy(identity,0,0,74*W*4);
  await sharp(result,{raw}).webp({lossless:true}).toFile(path.join(src,'paper_doll_male_candidate_v2.webp'));
  await sharp(identity,{raw}).webp({lossless:true}).toFile(path.join(src,'paper_doll_male_identity_candidate_v2.webp'));
  const png=await sharp(result,{raw}).png().toBuffer();
  await sharp(png).resize(720,960).png().toFile(path.join(src,'male_paper_doll_review_v2.png'));
  await sharp(png).extract({left:80,top:54,width:80,height:60}).resize(1024,768).png().toFile(path.join(src,'neck_detail_v2.png'));
  const exported=await sharp(path.join(src,'paper_doll_male_candidate_v2.webp')).ensureAlpha().raw().toBuffer();
  let outsideChanges=0;
  for(let y=0;y<H;y++)for(let x=0;x<W;x++) {
    if(x>=100&&x<143&&y>=71&&y<87)continue;
    const i=(y*W+x)*4;
    if(exported[i+3]!==base[i+3]||(base[i+3]>0&&!exported.subarray(i,i+3).equals(base.subarray(i,i+3))))outsideChanges++;
  }
  if(outsideChanges)throw Error(`${outsideChanges} pixels changed outside the neck`);
  console.log(JSON.stringify({changedNeckPixels:changed,outsideNeckChanges:outsideChanges}));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
