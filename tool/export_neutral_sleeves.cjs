// Replace only the generated shirt sleeves; keep all other outfit pixels exact.
const path=require('node:path');
const sharp=require('sharp');
const root=path.resolve(__dirname,'..');
const src=path.join(__dirname,'art_assets/neutral_scout_v2');
const out=path.join(root,'assets/images/questwell/avatar');
const W=240,H=320,raw={width:W,height:H,channels:4};
const polygons=[
  [[100,84.6],[101.5,99],[102,107],[104,115],[104.5,120],[103,125],[101.5,129],[99.5,130],
    [94,128],[82,124],[78,124],[76.8,121],[77,117],[80,111],[82,104],[84,95],[87,88]],
  [[153,84],[161,86],[165,89],[167.5,96],[169,104],[171,109],[173.5,114],[174,120],
    [172,123],[168,124],[157,128.5],[150.5,130],[148.5,128],[147,124],[147,119],[148,114],[150,109],[151,98]],
];
async function main(){
  const original=await sharp(path.join(out,'woodland_scout_unified_neutral_v1.webp')).ensureAlpha().raw().toBuffer();
  const source=await sharp(path.join(src,'sleeves_fitted_source.png')).resize(W*4,H*4).ensureAlpha().raw().toBuffer();
  const mask=await sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="960" height="1280" viewBox="0 0 240 320">${polygons.map(p=>`<polygon points="${p.map(v=>v.join(',')).join(' ')}" fill="white"/>`).join('')}</svg>`)).ensureAlpha().raw().toBuffer();
  for(let i=0;i<source.length;i+=4)source[i+3]=Math.round(source[i+3]*mask[i+3]/255);
  const sleeve=await sharp(source,{raw:{width:W*4,height:H*4,channels:4}}).resize(W,H).raw().toBuffer();
  const result=Buffer.from(original);
  for(let y=108;y<135;y++)for(let x=75;x<177;x++) {
    if(x>=104&&x<=149)continue;
    const sx=x<120?x-3:x+1;
    const i=(y*W+x)*4,si=(y*W+sx)*4;
    const blend=Math.min(1,(y-108)/4);
    for(let c=0;c<4;c++)result[i+c]=Math.round(original[i+c]*(1-blend)+sleeve[si+c]*blend);
  }
  await sharp(result,{raw}).webp({lossless:true}).toFile(path.join(out,'woodland_scout_unified_neutral_v2.webp'));
  const composite=await sharp(path.join(out,'base/paper_doll_neutral_v1.webp')).composite([
    {input:await sharp(result,{raw}).png().toBuffer()},
    {input:path.join(out,'base/paper_doll_neutral_identity_v1.webp')}]).png().toBuffer();
  await sharp(composite).resize(960,1280).png().toFile(path.join(src,'woodland_fitted.png'));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
