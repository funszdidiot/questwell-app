// Register generated cloth only. The approved neutral body is always read-only.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const out = path.join(__dirname, 'art_assets/neutral_robe_v6');
const everyday = path.join(__dirname, 'art_assets/neutral_everyday_v2');
const W = 240, H = 320, S = 4;
const raw = {width: W, height: H, channels: 4};
const sha = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));
const png = data => sharp(data, {raw}).png().toBuffer();
const blank = () => sharp({create: {...raw, background: '#0000'}});
const interpolate = (v,knots) => {
  for(let i=1;i<knots.length;i++)if(v<=knots[i][0]) {
    const [a,b]=knots[i-1], [c,d]=knots[i];
    return b+(d-b)*clamp((v-a)/(c-a),0,1);
  }
  return knots[knots.length-1][1];
};
function sleevePart(x,y) {
  if(y<94||y>173)return 0;
  const left=interpolate(y,[[94,98],[113,97],[130,94.5],[145,88],[155,85],[173,82]]);
  const right=interpolate(y,[[94,149],[113,149],[130,150],[145,157],[155,160],[173,165]]);
  return x<left ? 1 : x>right ? 2 : 0;
}

async function main() {
  const lock = JSON.parse(fs.readFileSync(path.join(__dirname, 'neutral_avatar_fit_reference.json')));
  for (const key of ['base', 'head_hair']) {
    if (sha(path.join(root, lock[key].path)) !== lock[key].sha256) throw Error(`Locked ${key} differs`);
  }
  const source = await sharp(path.join(out, 'robe_source.png')).resize(W*S,H*S).ensureAlpha().raw().toBuffer();
  const clothHigh = Buffer.alloc(W*H*S*S*4);
  const sleeveHigh=Buffer.alloc(clothHigh.length);
  // Anchor collar, wrist and hem to the existing body. These are cloth-only
  // registration coordinates; no generated anatomy is read or used.
  for (let y=0; y<H*S; y++) for (let x=0; x<W*S; x++) {
    const gx=x/S, gy=y/S;
    const sy=gy<=178 ? 58+(gy-75)*(165-58)/(178-75) : 165+(gy-178)*(288-165)/(286-178);
    if(sy<0||sy>=H)continue;
    const ease=clamp((sy-100)/65,0,1);
    const di=(y*W*S+x)*4;
    // Keep the skirt untransformed while registering each isolated sleeve.
    for(const [part,shift] of [[0,0],[1,5.5*ease],[2,-6*ease]]) {
      const sx=gx-shift;
      if(sx<0||sx>=W||sleevePart(sx,sy)!==part)continue;
      const si=(Math.floor(sy*S)*W*S+Math.floor(sx*S))*4;
      if(!source[si+3])continue;
      source.copy(clothHigh,di,si,si+4);
      if(part)source.copy(sleeveHigh,di,si,si+4);
    }
  }
  const cloth=await sharp(clothHigh,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).raw().toBuffer();
  const sleevePixels=await sharp(sleeveHigh,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).raw().toBuffer();
  const front=Buffer.from(cloth), rear=Buffer.alloc(cloth.length), cuffs=Buffer.alloc(cloth.length);
  // Follow the actual inner brown borders row by row. Move the continuous
  // central lining behind the complete avatar, with no fabricated inner flap.
  const brown=(i)=>cloth[i+3]>100&&cloth[i]>90&&cloth[i]>cloth[i+1]*1.3&&cloth[i+1]>cloth[i+2]*1.25;
  const boundaries=[];
  for(let y=153;y<278;y++) {
    let left=117,right=130;
    for(let x=122;x>=95;x--) if(brown((y*W+x)*4)) {left=x;break;}
    for(let x=123;x<=151;x++) if(brown((y*W+x)*4)) {right=x;break;}
    boundaries.push([y,left,right]);
    for(let x=left+1;x<right;x++) {
      const i=(y*W+x)*4;
      cloth.copy(rear,i,i,i+4); front[i+3]=0;
    }
  }
  for(let y=171;y<187;y++) for(let x=0;x<W;x++) {
    if(x>=94&&x<=153)continue;
    const i=(y*W+x)*4;
    if(!cloth[i+3]||!sleevePixels[i+3])continue;
    // The lower dark underside lives behind the wrist; the colored hem is
    // an attached foreground lip. Do not carve an ellipse through the cuff.
    const underside=cloth[i]<90&&cloth[i+1]<65&&y>=176;
    cloth.copy(underside?rear:cuffs,i,i,i+4);
    front[i+3]=0;
  }
  const assets={front:'scout_robe_neutral_candidate_v6.webp',rear:'scout_robe_rear_neutral_candidate_v6.webp',cuffs:'scout_robe_cuff_front_neutral_candidate_v6.webp'};
  for(const [key,data] of Object.entries({front,rear,cuffs}))
    await sharp(data,{raw}).webp({lossless:true}).toFile(path.join(out,assets[key]));
  const base=path.join(root,lock.base.path),identity=path.join(root,lock.head_hair.path);
  // The short-sleeve top stays complete: the fitted long sleeve covers it.
  const garmentFiles=['boots','trousers','top'].map(piece=>path.join(everyday,`everyday_${piece}_neutral_candidate_v2.webp`));
  const layers=[{input:await png(rear)},{input:base},...garmentFiles.map(input=>({input})),{input:await png(front)},{input:identity},{input:await png(cuffs)}];
  const fitted=await blank().composite(layers).png().toBuffer();
  const casual=await blank().composite([{input:base},...garmentFiles.map(input=>({input})),{input:identity}]).png().toBuffer();
  await sharp(fitted).resize(720,960).png().toFile(path.join(out,'neutral_robe_review_v6.png'));
  await sharp(fitted).resize(720,960).flatten({background:'#f2e9db'}).png().toFile(path.join(out,'neutral_robe_review_v6_light.png'));
  await sharp(fitted).extract({left:57,top:150,width:132,height:57}).resize(1056,456).flatten({background:'#f2e9db'}).png().toFile(path.join(out,'neutral_cuff_detail_v6.png'));
  const pairNative=await sharp({create:{width:560,height:350,channels:4,background:'#f2e9db'}}).composite([{input:casual,left:20,top:15},{input:fitted,left:300,top:15}]).png().toBuffer();
  const pair=await sharp(pairNative).resize(1120,700).png().toBuffer();
  await fs.promises.writeFile(path.join(out,'neutral_everyday_and_robe_v6.png'),pair);
  const arm=await sharp(base).ensureAlpha().raw().toBuffer();
  const covered=await blank().composite([{input:await png(front)},{input:await png(cuffs)}]).ensureAlpha().raw().toBuffer();
  const uncovered=[];
  for(let y=91;y<175;y++)for(let x=65;x<185;x++) {
    if(!(x<96||x>150))continue;
    const i=(y*W+x)*4;
    // Only warm skin pixels are relevant; exclude any dark shorts/torso art.
    if(arm[i+3]>240&&arm[i]>150&&arm[i+1]>95&&arm[i]>arm[i+2]*1.3&&covered[i+3]<235)uncovered.push([x,y]);
  }
  const report={status:'review_candidate_not_approved',lockedBodyAndIdentityVerified:true,canvas:[W,H],layerOrder:['rear cloth','complete approved body','boots','trousers','top','robe front','original identity','cuff fronts'],uncoveredArmPixels:uncovered,assets:Object.fromEntries(Object.entries(assets).map(([key,file])=>[key,{file,sha256:sha(path.join(out,file))}]))};
  fs.writeFileSync(path.join(out,'verification.json'),JSON.stringify(report,null,2)+'\n');
  console.log(JSON.stringify({lockedBodyAndIdentityVerified:true,uncoveredArmPixelCount:uncovered.length,uncovered:uncovered.slice(0,30)}));
}
main().catch(error=>{console.error(error);process.exitCode=1;});
