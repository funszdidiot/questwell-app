// Garment-only registration and explicit semantic depth masks.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),art=path.join(__dirname,'art_assets/neutral_robe_v8');
const W=240,H=320,S=4,raw={width:W,height:H,channels:4};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const clamp=(x,a,b)=>Math.max(a,Math.min(b,x));
const lerp=(x,knots)=>{for(let i=1;i<knots.length;i++)if(x<=knots[i][0]){const[a,b]=knots[i-1],[c,d]=knots[i];return b+(d-b)*(x-a)/(c-a);}const[a,b]=knots.at(-2),[c,d]=knots.at(-1);return d+(d-b)*(x-c)/(c-a);};
const yKnots=[[0,-40],[75,44],[87,61],[178,163],[286,287],[320,326]];
function sourceY(y){
  const k=yKnots; let j=1;while(j<k.length-1&&y>k[j][0])j++;
  const [x0,y0]=k[j-1],[x1,y1]=k[j],dx=x1-x0,t=clamp((y-x0)/dx,0,1),d=(y1-y0)/dx;
  const slope=i=>i===0?(k[1][1]-k[0][1])/(k[1][0]-k[0][0]):i===k.length-1?(k[i][1]-k[i-1][1])/(k[i][0]-k[i-1][0]):(k[i+1][1]-k[i-1][1])/(k[i+1][0]-k[i-1][0]);
  const m0=clamp(slope(j-1),0,3*d),m1=clamp(slope(j),0,3*d);
  return (2*t*t*t-3*t*t+1)*y0+(t*t*t-2*t*t+t)*dx*m0+(-2*t*t*t+3*t*t)*y1+(t*t*t-t*t)*dx*m1;
}
function sleeve(sx,sy){if(sy<85||sy>174)return 0;const edge=lerp(sy,[[85,130],[110,129],[130,125],[150,121],[174,120]]);return sx<edge?1:sx>320-edge?2:0;}
function locate(x,y,part){
  const sy=sourceY(y),baseX=159.5+(x-123)/.875;
  if(!part)return {sx:baseX,sy};
  const t=clamp((sy-110)/50,0,1),ease=t*t*(3-2*t);
  // Keep the accepted outer wrist anchors while retaining the new inner fullness.
  // Blend this garment-only contour adjustment through the complete lower sleeve.
  const innerAnchor=part===1?93:153,outerCorrection=part===1?4/30:5/30;
  const priorX=innerAnchor+(x-innerAnchor)/(1-outerCorrection*ease);
  const sleeveX=159.5+(priorX-123)/.875;
  const left=lerp(sy,[[85,111],[100,109],[130,101],[150,95],[160,92],[165,92],[174,110]]);
  const outer=part===1?left:320-left,scale=1+.20*ease;
  return {sx:outer+(sleeveX-outer)/scale,sy};
}

async function main(){
  const bodyLock=JSON.parse(fs.readFileSync(path.join(__dirname,'neutral_avatar_fit_reference.json'))),day=JSON.parse(fs.readFileSync(path.join(__dirname,'neutral_everyday_fit_reference.json')));
  const fixed=[bodyLock.base,bodyLock.head_hair,...Object.values(day.garments)];
  const verify=()=>{for(const e of fixed)if(sha(path.join(root,e.path))!==e.sha256)throw Error(`Frozen image changed: ${e.path}`);};verify();
  const src=await sharp(path.join(art,'robe_repair_source.png')).resize(320*S,320*S).ensureAlpha().raw().toBuffer();
  // Masks are geometric regions in source coordinates, never RGB classifiers.
  const rearPath='M151.5 132 C150 145 147 160 146.5 170 C144 194 140 231 138.5 260 L137 290 H183.5 L182.5 260 C180.5 231 177 197 174.5 180 C173 164 171 146 169 132 Z';
  const cavityLeft='M90 166 Q96 157.8 103 162.3 Q111 166.5 119 171.3 L126 190 H85 Z';
  const cavityRight='M230 166 Q224 157.8 217 162.3 Q209 166.5 201 171.3 L194 190 H235 Z';
  const maskRaw=async(d,width=320,height=320)=>sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${width*S}" height="${height*S}" viewBox="0 0 ${width} ${height}"><path d="${d}" fill="white"/></svg>`)).ensureAlpha().raw().toBuffer();
  const rearMask=await maskRaw(rearPath),cavityMask=await maskRaw(cavityLeft+' '+cavityRight);
  // This is garment occlusion by the fixed head/hair contour, not an anatomy edit.
  const hairPath='M0 0 H240 V60 H151 Q150 70 145 77 L148 79 Q143 82 136 82 L134 79 L131 76 Q123 78 116 75 L113 79 Q109 84 104 81 L98 79 L100 71 L90 60 H0 Z';
  const hairMask=await maskRaw(hairPath,W,H);
  const high=Buffer.alloc(W*H*S*S*4);
  const highLayers=Object.fromEntries(['front','rear','cuffs','collar'].map(k=>[k,Buffer.alloc(high.length)]));
  const semanticHigh=Buffer.alloc(high.length);
  // Sample geometry and semantic depth in the same transformed coordinate system.
  // Split at source resolution, then downsample each complete layer for smooth boundaries.
  for(let y=0;y<H*S;y++)for(let x=0;x<W*S;x++)for(const part of [0,1,2]){
    const p=locate((x+.5)/S,(y+.5)/S,part);
    if(p.sx<0||p.sy<0||p.sx>=320||p.sy>=320||sleeve(p.sx,p.sy)!==part)continue;
    const si=(Math.floor(p.sy*S)*320*S+Math.floor(p.sx*S))*4,di=(y*W*S+x)*4;
    if(!src[si+3])continue;
    const isPanel=rearMask[si+3]>=128;
    const backBridge=p.sy<51.5&&p.sx>142&&p.sx<178;
    const insideCuff=part&&cavityMask[si+3]>=128;
    const key=isPanel||backBridge||insideCuff?'rear':part&&p.sy>=151?'cuffs':p.sy<65?'collar':'front';
    for(const layer of Object.values(highLayers))layer.fill(0,di,di+4);
    src.copy(high,di,si,si+4);
    src.copy(highLayers[key],di,si,si+4);
    if(isPanel){semanticHigh[di]=semanticHigh[di+1]=semanticHigh[di+2]=255;semanticHigh[di+3]=255;}
    // Same-plane regions overlap across export boundaries so downsampling cannot
    // expose a translucent horizontal join between collar/front/cuff assets.
    if(!isPanel&&!backBridge&&!insideCuff){
      if(p.sy>=63&&p.sy<=67)for(const k of ['front','collar'])src.copy(highLayers[k],di,si,si+4);
      if(part&&p.sy>=149&&p.sy<=153)for(const k of ['front','cuffs'])src.copy(highLayers[k],di,si,si+4);
    }
    highLayers.collar[di+3]=Math.round(highLayers.collar[di+3]*(1-hairMask[di+3]/255));
  }
  const native=buf=>sharp(buf,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).raw().toBuffer();
  const cloth=await native(high),semanticRear=await native(semanticHigh);
  const {front,rear,cuffs,collar}=Object.fromEntries(await Promise.all(Object.entries(highLayers).map(async([k,v])=>[k,await native(v)])));
  const buffers={front,rear,cuffs,collar},paths={};
  for(const [key,data] of Object.entries(buffers)){paths[key]=path.join(art,`scout_robe_${key}_neutral_candidate_v8.webp`);await sharp(data,{raw}).webp({lossless:true}).toFile(paths[key]);}
  await sharp(cloth,{raw}).png().toFile(path.join(art,'registered_cloth.png'));
  await sharp(semanticRear,{raw}).png().toFile(path.join(art,'rear_region_mask.png'));
  await sharp(hairMask,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).png().toFile(path.join(art,'garment_hair_occlusion_mask.png'));
  const bodyPath=path.join(root,bodyLock.base.path),identityPath=path.join(root,bodyLock.head_hair.path);
  const everyday=['boots','trousers','top'].map(k=>({input:path.join(root,day.garments[k].path)}));
  const stack=[{input:paths.rear},{input:bodyPath},...everyday,{input:paths.front},{input:identityPath},{input:paths.collar},{input:paths.cuffs}];
  const fitted=await sharp({create:{...raw,background:'#0000'}}).composite(stack).png().toBuffer();
  await sharp(fitted).png().toFile(path.join(art,'native_composite.png'));
  await sharp(fitted).resize(720,960).png().toFile(path.join(art,'neutral_robe_v8.png'));
  for(const [name,bg] of [['light','#f2e9db'],['dark','#202a2b']]){
    await sharp(fitted).resize(720,960).flatten({background:bg}).png().toFile(path.join(art,`full_${name}.png`));
    await sharp(fitted).extract({left:57,top:156,width:132,height:52}).resize(1056,416).flatten({background:bg}).png().toFile(path.join(art,`cuffs_${name}.png`));
    await sharp(fitted).extract({left:99,top:65,width:50,height:42}).resize(600,504).flatten({background:bg}).png().toFile(path.join(art,`collar_${name}.png`));
    await sharp(fitted).extract({left:86,top:252,width:83,height:47}).resize(664,376).flatten({background:bg}).png().toFile(path.join(art,`rear_hem_${name}.png`));
  }
  let rearPixelsInFront=0;
  for(let i=0;i<cloth.length;i+=4)if(semanticRear[i+3]>250&&[front,cuffs,collar].some(d=>d[i+3]>128))rearPixelsInFront++;
  if(rearPixelsInFront)throw Error('Rear panel is in foreground');verify();
  const report={status:'export_checks_passed_founder_review_pending',fixedArt:fixed,bodyIdentityEverydayUnchanged:true,rearPanelPixelsInForeground:rearPixelsInFront,checkLimit:'Rear-region check verifies depth membership inside the explicit geometric mask; independent visual review is required to verify that this mask includes the complete illustrated rear panel.',source:{path:'tool/art_assets/neutral_robe_v8/robe_repair_source.png',sha256:sha(path.join(art,'robe_repair_source.png'))},registration:{sourceCanvas:[320,320],targetCanvas:[W,H],sourceCenterX:159.5,targetCenterX:123,horizontalScale:.875,verticalKnots:yKnots,sourceInwardCuffWidthScale:1.2,outerCuffAnchorCorrection:{left:4,right:-5,innerAnchors:[93,153],blendSourceY:[110,160]}},sourceMasks:{rearPath,cavityLeft,cavityRight,garmentHairOcclusionPath:hairPath},layerOrder:['rear','body','boots','trousers','top','front','identity','collar','cuffs'],assets:Object.fromEntries(Object.entries(paths).map(([k,p])=>[k,{path:path.relative(root,p),sha256:sha(p)}]))};
  fs.writeFileSync(path.join(art,'verification.json'),JSON.stringify(report,null,2)+'\n');
  console.log(JSON.stringify({bodyIdentityEverydayUnchanged:true,rearPanelPixelsInForeground:rearPixelsInFront}));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
