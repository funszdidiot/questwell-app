// Garment-only candidate: body and identity stay read-only. Register the new
// top/boots and refit the existing trouser drawing without changing its design.
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const sharp=require('sharp');
const root=path.resolve(__dirname,'..');
const a=path.join(root,'assets/images/questwell/avatar');
const out=path.join(__dirname,'art_assets/neutral_everyday_v2');
const W=240,H=320,S=4,raw={width:W,height:H,channels:4};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
function removeDetachedPixels(data){
  const seen=new Uint8Array(W*H),keep=new Uint8Array(W*H);
  for(let start=0;start<W*H;start++){
    if(seen[start]||data[start*4+3]<=8)continue;
    const component=[start];seen[start]=1;
    for(let q=0;q<component.length;q++){
      const p=component[q],x=p%W,y=Math.floor(p/W);
      for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++){
        const nx=x+dx,ny=y+dy,np=ny*W+nx;
        if(nx<0||nx>=W||ny<0||ny>=H||seen[np]||data[np*4+3]<=8)continue;
        seen[np]=1;component.push(np);
      }
    }
    if(component.length>=100)for(const p of component)keep[p]=1;
  }
  for(let p=0;p<W*H;p++)if(!keep[p])data.fill(0,p*4,p*4+4);
}
async function main(){
  const lock=JSON.parse(fs.readFileSync(path.join(__dirname,'neutral_avatar_fit_reference.json')));
  for(const key of ['base','head_hair'])if(sha(path.join(root,lock[key].path))!==lock[key].sha256)throw Error(`Locked ${key} changed`);
  const src=await sharp(path.join(out,'garments_source.png')).resize(W*S,H*S).ensureAlpha().raw().toBuffer();
  const trouserSource=await sharp(path.join(a,'everyday_trousers_neutral_v1.webp')).resize(W*S,H*S).ensureAlpha().raw().toBuffer();
  const bodyNative=await sharp(path.join(root,lock.base.path)).ensureAlpha().raw().toBuffer();
  const trouserNative=await sharp(path.join(a,'everyday_trousers_neutral_v1.webp')).ensureAlpha().raw().toBuffer();
  const easeByRow=[];
  for(let y=0;y<H;y++){
    let oldL=123,oldR=123,bodyL=123,bodyR=123;
    for(let x=89;x<=158;x++){
      const i=(y*W+x)*4;
      if(trouserNative[i+3]>220){oldL=Math.min(oldL,x);oldR=Math.max(oldR,x);}
      const rgb=[bodyNative[i],bodyNative[i+1],bodyNative[i+2]];
      const charcoal=rgb[2]>=rgb[1]&&Math.max(...rgb)-Math.min(...rgb)<25&&Math.max(...rgb)<155;
      if(y>=153&&y<=204&&bodyNative[i+3]>160&&charcoal){bodyL=Math.min(bodyL,x);bodyR=Math.max(bodyR,x);}
    }
    easeByRow[y]={left:bodyL<123?Math.min(5,Math.max(0,oldL-bodyL+1)):0,right:bodyR>123?Math.min(5,Math.max(0,bodyR-oldR+1)):0,oldL,oldR};
  }
  const smoothEase=easeByRow.map((row,y)=>{
    const near=easeByRow.slice(Math.max(153,y-3),Math.min(208,y+4));
    if(y<153||y>210||!near.length)return {...row,left:0,right:0};
    const taper=Math.max(0,Math.min(1,(211-y)/10));
    return {...row,left:near.reduce((s,r)=>s+r.left,0)/near.length+.4*taper,right:near.reduce((s,r)=>s+r.right,0)/near.length+1.6*taper};
  });
  const topHigh=Buffer.alloc(W*H*S*S*4),bootsHigh=Buffer.alloc(topHigh.length),trousersHigh=Buffer.alloc(topHigh.length);
  for(let y=0;y<H*S;y++)for(let x=0;x<W*S;x++){
    const gx=x/S,gy=y/S,i=(y*W*S+x)*4;
    const belt=153+3*Math.max(0,1-Math.pow((gx-123)/23,2));
    const sy=gy<=112?gy:112+(gy-112)*(147.4-112)/(156-112);
    if(gy<belt&&sy>=0&&sy<H){
      const topScale=1+.10*Math.max(0,Math.min(1,(gy-120)/36));
      const shoulderEase=2*Math.max(0,Math.min(1,(gy-82)/7,(113-gy)/8))*Math.max(0,Math.min(1,(gx-140)/14));
      const sx=123+(gx-123)/topScale-shoulderEase;
      const si=(Math.round(sy*S)*W*S+Math.round(sx*S))*4;
      src.copy(topHigh,i,si,si+4);
    }
    const ankle=gx<125?285:287;
    const bootY=gy-7;
    if(gy>=ankle-2&&bootY>=0&&bootY<H){
      const center=gx<125?95:166;
      const sx=center+(gx-center)/1.08;
      const si=(Math.round(bootY*S)*W*S+Math.round(sx*S))*4;
      src.copy(bootsHigh,i,si,si+4);
    }
    if(gy>=153&&gy<ankle){
      const dx=gx-123;
      const crotch=Math.max(0,1-Math.abs(gy-201)/14)*Math.max(0,1-Math.abs(dx)/11)*8;
      const py=gy-crotch;
      const row=smoothEase[Math.min(H-1,Math.floor(gy))];
      const extra=dx<0?row.left:row.right;
      const oldSpan=dx<0?123-row.oldL:row.oldR-123;
      const ease=oldSpan>10?(oldSpan-10+extra)/(oldSpan-10):1;
      const px=123+Math.sign(dx)*(Math.abs(dx)<=10?Math.abs(dx):10+(Math.abs(dx)-10)/ease);
      const si=(Math.round(py*S)*W*S+Math.round(px*S))*4;
      if(si>=0&&si+4<=trouserSource.length)trouserSource.copy(trousersHigh,i,si,si+4);
    }
  }
  const top=await sharp(topHigh,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).raw().toBuffer();
  const boots=await sharp(bootsHigh,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).raw().toBuffer();
  const trousers=await sharp(trousersHigh,{raw:{width:W*S,height:H*S,channels:4}}).resize(W,H).raw().toBuffer();
  for(const garment of [top,trousers,boots])removeDetachedPixels(garment);
  await sharp(top,{raw}).webp({lossless:true}).toFile(path.join(out,'everyday_top_neutral_candidate_v2.webp'));
  await sharp(boots,{raw}).webp({lossless:true}).toFile(path.join(out,'everyday_boots_neutral_candidate_v2.webp'));
  await sharp(trousers,{raw}).webp({lossless:true}).toFile(path.join(out,'everyday_trousers_neutral_candidate_v2.webp'));
  const cloth=await sharp({create:{width:W,height:H,channels:4,background:{r:0,g:0,b:0,alpha:0}}}).composite(await Promise.all([boots,trousers,top].map(async d=>({input:await sharp(d,{raw}).png().toBuffer()})))).png().toBuffer();
  const bodyPath=path.join(root,lock.base.path),identityPath=path.join(root,lock.head_hair.path);
  const fitted=await sharp(bodyPath).composite([{input:cloth},{input:identityPath}]).png().toBuffer();
  await sharp(fitted).resize(720,960).png().toFile(path.join(out,'neutral_everyday_review_v2.png'));
  await sharp(fitted).resize(720,960).flatten({background:'#f2e9db'}).png().toFile(path.join(out,'neutral_everyday_review_v2_light.png'));
  await sharp(fitted).extract({left:68,top:76,width:110,height:65}).resize(880,520).flatten({background:'#f2e9db'}).png().toFile(path.join(out,'sleeve_fit_detail_v2.png'));
  await sharp(fitted).extract({left:65,top:278,width:130,height:42}).resize(910,294).flatten({background:'#f2e9db'}).png().toFile(path.join(out,'boot_fit_detail_v2.png'));
  const body=await sharp(bodyPath).ensureAlpha().raw().toBuffer();
  const coverage=await sharp(cloth).ensureAlpha().raw().toBuffer();
  let exposedLowerBody=0;const exposed=[];
  for(let y=157;y<H;y++)for(let x=65;x<195;x++){
    const i=(y*W+x)*4;
    // Exclude exposed hands at the hips; all underwear, legs, feet must be covered.
    if(y<214 && (x<90||x>157))continue;
    if(body[i+3]>240&&coverage[i+3]<235){exposedLowerBody++;exposed.push([x,y,coverage[i+3]]);}
  }
  const stats={lockedBodyAndIdentityVerified:true,trousersSha256:sha(path.join(a,'everyday_trousers_neutral_v1.webp')),exposedLowerBody,exposed:exposed.slice(0,80)};
  console.log(JSON.stringify(stats));
  if(exposedLowerBody)throw Error(`${exposedLowerBody} lower-body pixels lack garment coverage`);
}
main().catch(e=>{console.error(e);process.exitCode=1;});
