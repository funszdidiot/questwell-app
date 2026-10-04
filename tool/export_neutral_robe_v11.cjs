// Recover the existing continuous cuff rim from the rear cavity depth region.
// Registration is identical to v8; all other v10 garment art stays fixed.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),art=path.join(__dirname,'art_assets/neutral_robe_v11');
const raw={width:240,height:320,channels:4},S=4,W=240,H=320;
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const read=p=>JSON.parse(fs.readFileSync(p));
const clamp=(x,a,b)=>Math.max(a,Math.min(b,x));
const lerp=(x,knots)=>{for(let i=1;i<knots.length;i++)if(x<=knots[i][0]){const[a,b]=knots[i-1],[c,d]=knots[i];return b+(d-b)*(x-a)/(c-a);}const[a,b]=knots.at(-2),[c,d]=knots.at(-1);return d+(d-b)*(x-c)/(c-a);};
const yKnots=[[0,-40],[75,44],[87,61],[178,163],[286,287],[320,326]];
function sourceY(y){
  const k=yKnots;let j=1;while(j<k.length-1&&y>k[j][0])j++;
  const[x0,y0]=k[j-1],[x1,y1]=k[j],dx=x1-x0,t=clamp((y-x0)/dx,0,1),d=(y1-y0)/dx;
  const slope=i=>i===0?(k[1][1]-k[0][1])/(k[1][0]-k[0][0]):i===k.length-1?(k[i][1]-k[i-1][1])/(k[i][0]-k[i-1][0]):(k[i+1][1]-k[i-1][1])/(k[i+1][0]-k[i-1][0]);
  const m0=clamp(slope(j-1),0,3*d),m1=clamp(slope(j),0,3*d);
  return(2*t*t*t-3*t*t+1)*y0+(t*t*t-2*t*t+t)*dx*m0+(-2*t*t*t+3*t*t)*y1+(t*t*t-t*t)*dx*m1;
}
function sleeve(sx,sy){if(sy<85||sy>174)return 0;const edge=lerp(sy,[[85,130],[110,129],[130,125],[150,121],[174,120]]);return sx<edge?1:sx>320-edge?2:0;}
function locate(x,y,part){
  const sy=sourceY(y),t=clamp((sy-110)/50,0,1),ease=t*t*(3-2*t);
  const innerAnchor=part===1?93:153,outerCorrection=part===1?4/30:5/30;
  const priorX=innerAnchor+(x-innerAnchor)/(1-outerCorrection*ease),sleeveX=159.5+(priorX-123)/.875;
  const left=lerp(sy,[[85,111],[100,109],[130,101],[150,95],[160,92],[165,92],[174,110]]);
  const outer=part===1?left:320-left,scale=1+.20*ease;
  return {sx:outer+(sleeveX-outer)/scale,sy};
}
async function main(){
  const previous=read(path.join(__dirname,'art_assets/neutral_robe_v10/fit_reference.json'));
  const fixed=[previous.body,previous.identity,...Object.values(previous.everyday)];
  for(const a of [...fixed,...Object.values(previous.layers)])if(sha(path.join(root,a.path))!==a.sha256)throw Error(`Changed source: ${a.path}`);
  const src=await sharp(path.join(__dirname,'art_assets/neutral_robe_v8/robe_repair_source.png')).resize(320*S,320*S).ensureAlpha().raw().toBuffer();
  const left='M90 167.6 Q96 159.4 103 163.9 Q111 168.1 119 172.9 L126 190 H85 Z';
  const right='M230 167.6 Q224 159.4 217 163.9 Q209 168.1 201 172.9 L194 190 H235 Z';
  const mask=await sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="1280" viewBox="0 0 320 320"><path d="${left} ${right}" fill="white"/></svg>`)).ensureAlpha().raw().toBuffer();
  const cuffHigh=Buffer.alloc(W*H*S*S*4),rearHigh=Buffer.alloc(cuffHigh.length);
  for(let y=167*S;y<189*S;y++)for(let x=63*S;x<184*S;x++)for(const part of [1,2]){
    const p=locate((x+.5)/S,(y+.5)/S,part);
    if(p.sx<0||p.sy<151||p.sx>=320||p.sy>=174||sleeve(p.sx,p.sy)!==part)continue;
    const si=(Math.floor(p.sy*S)*320*S+Math.floor(p.sx*S))*4,di=(y*W*S+x)*4;
    if(!src[si+3])continue;
    src.copy(mask[si+3]>=128?rearHigh:cuffHigh,di,si,si+4);
  }
  const native=b=>sharp(b,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).raw().toBuffer();
  const rim=await native(cuffHigh),cavity=await native(rearHigh);
  const cuffs=await sharp(path.join(root,previous.layers.cuffs.path)).ensureAlpha().raw().toBuffer();
  const rear=await sharp(path.join(root,previous.layers.rear.path)).ensureAlpha().raw().toBuffer();
  const v8Cuffs=await sharp(path.join(__dirname,'art_assets/neutral_robe_v8/scout_robe_cuffs_neutral_candidate_v8.webp')).ensureAlpha().raw().toBuffer();
  const v8Rear=await sharp(path.join(__dirname,'art_assets/neutral_robe_v8/scout_robe_rear_neutral_candidate_v8.webp')).ensureAlpha().raw().toBuffer();
  let recoveredRimPixels=0;
  for(let y=173;y<=187;y++)for(let x=65;x<=182;x++){
    if(x>94&&x<151)continue;
    const i=(y*W+x)*4;
    if(rim[i+3]<=v8Cuffs[i+3]+1||!cuffs.subarray(i,i+4).equals(v8Cuffs.subarray(i,i+4)))continue;
    rim.copy(cuffs,i,i,i+4);recoveredRimPixels++;
    // Preserve the later local backing/fold repair; update unmodified cavity art.
    if(rear.subarray(i,i+4).equals(v8Rear.subarray(i,i+4)))cavity.copy(rear,i,i,i+4);
  }
  const assets={};
  for(const key of ['front','rear','cuffs','collar']){
    const file=path.join(art,`scout_robe_${key}_neutral_candidate_v11.webp`);
    if(key==='rear'||key==='cuffs')await sharp(key==='rear'?rear:cuffs,{raw}).webp({lossless:true}).toFile(file);
    else fs.copyFileSync(path.join(root,previous.layers[key].path),file);
    assets[key]={path:path.relative(root,file),sha256:sha(file)};
  }
  const a=k=>({input:path.join(root,assets[k].path)});
  const stack=[a('rear'),{input:path.join(root,previous.body.path)},...['boots','trousers','top'].map(k=>({input:path.join(root,previous.everyday[k].path)})),a('front'),{input:path.join(root,previous.identity.path)},a('collar'),a('cuffs')];
  const fitted=await sharp({create:{...raw,background:'#0000'}}).composite(stack).png().toBuffer();
  await sharp(fitted).png().toFile(path.join(art,'native_composite.png'));
  await sharp(fitted).resize(720,960).png().toFile(path.join(art,'neutral_robe_v11.png'));
  for(const[name,background]of[['light','#f2e9db'],['dark','#202a2b']]){
    await sharp(fitted).resize(720,960).flatten({background}).png().toFile(path.join(art,`full_${name}.png`));
    await sharp(fitted).extract({left:61,top:163,width:124,height:44}).resize(992,352).flatten({background}).png().toFile(path.join(art,`hands_${name}.png`));
  }
  const before=await sharp(path.join(__dirname,'art_assets/neutral_robe_v10/native_composite.png')).ensureAlpha().raw().toBuffer();
  const after=await sharp(fitted).ensureAlpha().raw().toBuffer();
  let changedCompositePixels=0,outside=0,palmChanges=0;
  for(let y=0;y<H;y++)for(let x=0;x<W;x++){
    const i=(y*W+x)*4;if(before.subarray(i,i+4).equals(after.subarray(i,i+4)))continue;
    changedCompositePixels++;
    if(y<173||y>187||x<65||x>182||x>94&&x<151)outside++;
    if(y>=188)palmChanges++;
  }
  if(outside||palmChanges)throw Error(JSON.stringify({outside,palmChanges}));
  const report={status:'export_checks_passed_founder_review_pending',source:'Existing v8 generated cloth, unchanged texture; cavity boundary moved 1.6 source pixels below its prior position to retain the continuous dark lip.',sourceCavityPaths:{left,right},recoveredRimPixels,changedCompositePixels,changedPixelsOutsideCuffRims:outside,palmChanges,fixedArt:fixed,bodyIdentityEverydayUnchanged:true,frontAndCollarByteIdenticalToV10:true,assets};
  fs.writeFileSync(path.join(art,'verification.json'),JSON.stringify(report,null,2)+'\n');
  console.log(JSON.stringify({recoveredRimPixels,changedCompositePixels,outside,palmChanges}));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
