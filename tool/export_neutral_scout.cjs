// Register generated garment art to the approved body; never alter body pixels.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const src = path.join(__dirname, 'art_assets/neutral_scout_v1');
const out = path.join(root, 'assets/images/questwell/avatar');
const W=240, H=320;
const canvas = () => sharp({create:{width:240,height:330,channels:4,background:'#0000'}});
const save = (pixels,name) => sharp(pixels,{raw:{width:W,height:H,channels:4}})
  .webp({lossless:true}).toFile(path.join(out,name));
function polygonMask(points) {
  return sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="240" height="320"><polygon points="${points.map(p=>p.join(',')).join(' ')}" fill="white"/></svg>`))
    .ensureAlpha().raw().toBuffer();
}
async function main() {
  const base = await sharp(path.join(out,'base/paper_doll_neutral_v1.webp')).ensureAlpha().raw().toBuffer();
  const outfitSource = await sharp(path.join(src,'woodland_source.png')).resize(224,300).png().toBuffer();
  const outfitCanvas = await canvas().composite([{input:outfitSource,left:7,top:29}]).png().toBuffer();
  const outfit = await sharp(outfitCanvas).extract({left:0,top:0,width:W,height:H}).ensureAlpha().raw().toBuffer();
  const originalOutfit = Buffer.from(outfit);
  // Smooth offline leg registration. Transform the garment artwork and its
  // contour together, retaining its seams rather than copying border pixels.
  for(let y=160;y<H;y++) {
    const t=Math.min(1,(y-160)/25);const ease=t*t*(3-2*t);
    for(let x=0;x<W;x++) {
      const pixel=[0,0,0,0];
      for(const [scale,offset,part] of [[1+0.08*ease,-9*ease,'left'],[1+0.15*ease,-26*ease,'right']]) {
        const bootShift=part==='left'?3.6*Math.exp(-Math.pow((y-299)/7,2)):-0.8*Math.exp(-Math.pow((y-301)/6,2));
        const sx=(x-offset+bootShift)/scale;
        if(sx<0 || sx>=W-1 || (part==='left'?sx>=124:sx<124))continue;
        const x0=Math.floor(sx),f=sx-x0;
        const color=[0,1,2,3].map(c=>originalOutfit[(y*W+x0)*4+c]*(1-f)+originalOutfit[(y*W+x0+1)*4+c]*f);
        const alpha=color[3]/255,old=pixel[3]/255,combined=alpha+old*(1-alpha);
        if(combined>0)for(let c=0;c<3;c++)pixel[c]=(color[c]*alpha+pixel[c]*old*(1-alpha))/combined;
        pixel[3]=combined*255;
      }
      for(let c=0;c<4;c++)outfit[(y*W+x)*4+c]=Math.round(pixel[c]);
    }
  }
  await save(outfit,'woodland_scout_unified_neutral_v1.webp');
  const underRobe = Buffer.from(outfit);
  for(let y=0;y<156;y++) for(let x=0;x<W;x++) {
    if(x<100 || x>144) underRobe[(y*W+x)*4+3]=0;
  }
  await save(underRobe,'woodland_scout_robe_under_neutral_v1.webp');

  const robeSource = await sharp(path.join(src,'robe_source.png')).resize(W,H).ensureAlpha().raw().toBuffer();
  const robe=Buffer.alloc(W*H*4);
  // One continuous garment registration: match collar and wrists first,
  // then shorten only the skirt length. No runtime transforms or body warp.
  for(let y=20;y<H;y++) for(let x=3;x<W;x++) {
    const sy=y<=190 ? y-20 : 170+(y-190)/0.8;
    if(sy>=H-1) continue;
    const y0=Math.floor(sy), f=sy-y0;
    for(let c=0;c<4;c++) robe[(y*W+x)*4+c]=Math.round(
      robeSource[(y0*W+x-3)*4+c]*(1-f)+robeSource[((y0+1)*W+x-3)*4+c]*f);
  }
  const rearMask=await polygonMask([[116,154],[132,154],[134,190],[137,220],[140,249],[144,278],[103,278],[105,249],[109,220],[113,190]]);
  const front=Buffer.from(robe), rear=Buffer.from(robe), cuffs=Buffer.from(robe);
  for(let y=0;y<H;y++) for(let x=0;x<W;x++) {
    const i=(y*W+x)*4;
    const a=rearMask[i+3]/255;
    rear[i+3]=Math.round(robe[i+3]*a);
    front[i+3]=Math.round(robe[i+3]*(1-a));
    const cuff=y>=175 && y<=185 && ((x>=63 && x<=86)||(x>=159&&x<=182));
    cuffs[i+3]=cuff?front[i+3]:0;
    if(cuff) {
      rear[i+3]=Math.max(rear[i+3],robe[i+3]);
      front[i+3]=0;
      const cx=x<120?74.5:172.5;
      let inside=0;
      for(let yy=0;yy<4;yy++)for(let xx=0;xx<4;xx++) {
        if(Math.pow((x+(xx+.5)/4-cx)/7.5,2)+Math.pow((y+(yy+.5)/4-182)/1.8,2)<1)inside++;
      }
      cuffs[i+3]=Math.round(cuffs[i+3]*(1-inside/16));
    }
  }
  for(const [pixels,name] of [[front,'robe'],[rear,'robe_rear'],[cuffs,'robe_cuff_front']])
    await save(pixels,`scout_${name}_neutral_v5.webp`);
  console.log('Exported neutral outfit, under-robe garment, front, rear and cuffs.');
}
main().catch(error=>{console.error(error);process.exitCode=1;});
