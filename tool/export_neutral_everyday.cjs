// Garment registration and depth separation only. Never modifies the fixed body.
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const src = path.join(__dirname, 'art_assets/neutral_scout_v2');
const out = path.join(root, 'assets/images/questwell/avatar');
const W=240, H=320;
const raw = {width:W,height:H,channels:4};
const save=(data,name)=>sharp(data,{raw}).webp({lossless:true}).toFile(path.join(out,name));
function sample(data,x,y) {
  if(x<0||x>=W-1||y<0||y>=H-1)return [0,0,0,0];
  const x0=Math.floor(x),y0=Math.floor(y), fx=x-x0,fy=y-y0;
  return [0,1,2,3].map(c=>Math.round(
    data[(y0*W+x0)*4+c]*(1-fx)*(1-fy)+data[(y0*W+x0+1)*4+c]*fx*(1-fy)+
    data[((y0+1)*W+x0)*4+c]*(1-fx)*fy+data[((y0+1)*W+x0+1)*4+c]*fx*fy));
}
async function main(){
  const source=await sharp(path.join(src,'everyday_source.png')).resize(W,H).ensureAlpha().raw().toBuffer();
  const full=Buffer.alloc(W*H*4);
  for(let y=0;y<H;y++)for(let x=0;x<W;x++) {
    const sy=y<156?82+(y-80)*63/76:y<285?145+(y-156)*135/129:280+(y-285)*28/31;
    let sx=y<156?123+(x-123)/1.1:x;
    const p=sample(source,sx,sy);
    for(let c=0;c<4;c++)full[(y*W+x)*4+c]=p[c];
  }
  const top=Buffer.from(full),trousers=Buffer.from(full),boots=Buffer.from(full);
  const bootSource=await sharp(path.join(src,'boots_fitted_source.png')).resize(W,H).ensureAlpha().raw().toBuffer();
  // Follow the belt and ankle seams; all parts remain on the same full canvas.
  for(let y=0;y<H;y++)for(let x=0;x<W;x++) {
    const i=(y*W+x)*4;
    const belt=153+3*Math.max(0,1-Math.pow((x-123)/23,2));
    const ankle=x<125?285:287;
    top[i+3]=y<belt?full[i+3]:0;
    trousers[i+3]=y>=belt&&y<ankle?full[i+3]:0;
    if(y>=ankle)for(let c=0;c<4;c++)boots[i+c]=bootSource[i+c];
    else boots[i+3]=0;
  }
  for(const [data,name] of [[top,'top'],[trousers,'trousers'],[boots,'boots']])
    await save(data,`everyday_${name}_neutral_v1.webp`);
  // Only cloth is occluded by the enclosing robe; the body is never clipped.
  const underRobe=Buffer.from(top);
  for(let y=0;y<H;y++)for(let x=0;x<W;x++)
    if(x<110||x>136)underRobe[(y*W+x)*4+3]=0;
  await save(underRobe,'everyday_top_robe_under_neutral_v1.webp');
  const body=path.join(out,'base/paper_doll_neutral_v1.webp');
  const garmentBuffers=await Promise.all([top,trousers,boots].map(data=>sharp(data,{raw}).png().toBuffer()));
  const reference=await sharp(body).composite([...garmentBuffers.map(input=>({input})),
    {input:path.join(out,'base/paper_doll_neutral_identity_v1.webp')}]).png().toBuffer();
  await sharp(reference).resize(960,1280).png().toFile(path.join(src,'everyday_fitted.png'));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
