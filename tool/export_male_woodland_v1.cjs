// A single continuous body-specific registration of one generated outfit.
// No component exports, body masks, fragment assembly or cross-body scaling.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const dir = path.join(__dirname, 'art_assets/male_woodland_v1');
const asset = 'assets/images/questwell/avatar/woodland_scout_unified_male_candidate_v1.webp';
// At each continuous row anchor: source L-outer/L-inner/R-inner/R-outer,
// then target coordinates measured against the immutable male v3 foundation.
const rows = [
  [0, [85,118,129,159], [85,118,129,159]],
  [150, [85,118,129,159], [85,118,129,159]],
  [165, [90,118,129,157], [90,118,129,157]],
  [180, [86,119,123,156], [86,119,123,154]],
  [190, [89,121,124,157], [86,121,122,156]],
  [200, [91,119,127,158], [83,120,121,158]],
  [205, [90,120,129,160], [84,120,122,157]],
  [210, [91,118,131,159], [85,116,127,156]],
  [220, [90,115,134,162], [87,113,130,155]],
  [230, [87,115,136,166], [87,112,133,156]],
  [240, [86,116,136,168], [84,112,133,160]],
  [250, [85,114,138,170], [83,112,133,162]],
  [260, [89,110,142,168], [85,108,137,161]],
  [270, [90,110,147,168], [86,108,141,161]],
  [280, [89,110,148,170], [87,108,142,162]],
  [290, [85,113,146,176], [85,109,142,166]],
  [300, [73,113,146,191], [71,109,141,184]],
  [308, [74,99,161,192], [72,98,156,185]],
  [320, [74,99,161,192], [72,98,156,185]],
];
const smooth = t => t*t*(3-2*t);
function rowAt(y) {
  let i=0; while(i<rows.length-2 && y>rows[i+1][0]) i++;
  const a=rows[i],b=rows[i+1];
  const t=smooth(Math.max(0,Math.min(1,(y-a[0])/(b[0]-a[0]))));
  return [1,2].map(k=>a[k].map((v,j)=>v+(b[k][j]-v)*t));
}
function sourcePoint(x,y) {
  const clamp=t=>Math.max(0,Math.min(1,t));
  // Lower the complete connected crotch join with a smooth field through the
  // trousers. Its source opening must fall below the locked undergarment seam.
  const crotch=10*Math.exp(-Math.pow((x-122)/16,2))
      *smooth(clamp((y-160)/22))*smooth(clamp((218-y)/25));
  const hem=2*smooth(clamp((y-275)/35));
  const sy=y-hem-crotch;
  const s=rowAt(sy)[0],d=rowAt(y-hem)[1];
  const sx=[0,50,...s,210,240],dx=[0,50,...d,210,240];
  let i=0;while(i<dx.length-2 && x>dx[i+1])i++;
  return [sx[i]+(x-dx[i])/(dx[i+1]-dx[i])*(sx[i+1]-sx[i]),sy];
}
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function main() {
  const source=path.join(dir,'outfit_source.png');
  const {data,info}=await sharp(source).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  if(info.width*4!==info.height*3)throw Error('Source must retain the full 3:4 canvas');
  const pixels=Buffer.alloc(240*320*4), samples=4;
  const read=(x,y)=>{
    const px=x*info.width/240-.5,py=y*info.height/320-.5;
    const x0=Math.floor(px),y0=Math.floor(py),fx=px-x0,fy=py-y0;
    const p=[0,0,0,0];
    for(let yy=0;yy<2;yy++)for(let xx=0;xx<2;xx++) {
      const ix=x0+xx,iy=y0+yy;if(ix<0||iy<0||ix>=info.width||iy>=info.height)continue;
      const j=(iy*info.width+ix)*4,w=(xx?fx:1-fx)*(yy?fy:1-fy),a=data[j+3]/255;
      for(let c=0;c<3;c++)p[c]+=data[j+c]*a*w;
      p[3]+=a*w;
    }
    return p;
  };
  for(let y=0;y<320;y++)for(let x=0;x<240;x++) {
    const p=[0,0,0,0];
    for(let yy=0;yy<samples;yy++)for(let xx=0;xx<samples;xx++) {
      const sample=read(...sourcePoint(x+(xx+.5)/samples,y+(yy+.5)/samples));
      for(let c=0;c<4;c++)p[c]+=sample[c]/(samples*samples);
    }
    const j=(y*240+x)*4;if(p[3]>0)for(let c=0;c<3;c++)pixels[j+c]=Math.round(p[c]/p[3]);
    pixels[j+3]=Math.round(p[3]*255);
  }
  const output=path.join(root,asset);
  await sharp(pixels,{raw:{width:240,height:320,channels:4}}).webp({lossless:true}).toFile(output);
  fs.copyFileSync(output,path.join(dir,'outfit_registered.webp'));
  const body='assets/images/questwell/avatar/base/paper_doll_male_v3.webp';
  const identity='assets/images/questwell/avatar/base/paper_doll_male_identity_v3.webp';
  await sharp(path.join(root,body)).composite([{input:output},{input:path.join(root,identity)}]).png().toFile(path.join(dir,'native_composite.png'));
  for(const [name,color] of [['light','#f2e9db'],['dark','#202a2b']]) {
    await sharp(path.join(dir,'native_composite.png')).flatten({background:color}).resize(960,1280,{kernel:'nearest'}).png().toFile(path.join(dir,`full_${name}.png`));
    for(const [label,crop] of Object.entries({upper:{left:55,top:65,width:130,height:140},legs:{left:65,top:155,width:135,height:165}}))
      await sharp(path.join(dir,'native_composite.png')).flatten({background:color}).extract(crop).resize(crop.width*6,crop.height*6,{kernel:'nearest'}).png().toFile(path.join(dir,`${label}_${name}.png`));
  }
  fs.writeFileSync(path.join(dir,'registration.json'),JSON.stringify({method:'One continuous whole-outfit inverse mapping; smooth row interpolation, connected piecewise-affine horizontal mapping, premultiplied bilinear source sampling with 4x4 pixel integration. No garment fragments or body changes.',canvas:[240,320],rows,lowerHemExtension:2,source:{path:'tool/art_assets/male_woodland_v1/outfit_source.png',sha256:sha(source)},outfit:{path:asset,sha256:sha(output)},body:{path:body,sha256:sha(path.join(root,body))},identity:{path:identity,sha256:sha(path.join(root,identity))}},null,2)+'\n');
  console.log('Exported unified male Woodland candidate and native/light/dark QA composites.');
}
main().catch(error=>{console.error(error);process.exitCode=1;});
