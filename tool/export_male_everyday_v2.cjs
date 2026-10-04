// One full outfit overlay. Coherent drawing repairs join existing cloth; the
// approved body and identity remain read-only throughout export.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'), art=path.join(__dirname,'art_assets/male_everyday_v2');
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const W=240,H=320;
async function importDrawingRegion(outfit,sourceFile,rect,shape,joinInnerContours=false){
 let drawing=await sharp(sourceFile).resize(rect.width,rect.height).ensureAlpha().raw().toBuffer();
 if(joinInnerContours){
   // Fit the entire redrawn inner contour smoothly into the unchanged lower-leg
   // fall at 4x resolution. The original body never participates in this warp.
   const S=4,sw=rect.width*S,sh=rect.height*S;
   const original=await sharp(sourceFile).resize(sw,sh).ensureAlpha().raw().toBuffer(),fitted=Buffer.from(original);
   const knotsL=[[185,120.1],[198,119.7],[205,119.05],[210,117.5],[219,114],[226,112],[228,111.2]];
   const knotsR=[[185,121.9],[198,122.2],[205,122.9],[210,125.6],[219,131],[226,133],[228,133.2]];
   const curve=(knots,y)=>{
     let n=1;while(n<knots.length-1&&y>knots[n][0])n++;
     const [ay,ax]=knots[n-1],[by,bx]=knots[n],d=(bx-ax)/(by-ay);
     const slope=k=>{if(k===0)return (knots[1][1]-knots[0][1])/(knots[1][0]-knots[0][0]);if(k===knots.length-1)return d;const a=(knots[k][1]-knots[k-1][1])/(knots[k][0]-knots[k-1][0]),b=(knots[k+1][1]-knots[k][1])/(knots[k+1][0]-knots[k][0]);return a*b<=0?0:2*a*b/(a+b);};
     const t=Math.max(0,Math.min(1,(y-ay)/(by-ay))),t2=t*t,t3=t2*t;
     return (2*t3-3*t2+1)*ax+(t3-2*t2+t)*(by-ay)*slope(n-1)+(-2*t3+3*t2)*bx+(t3-t2)*(by-ay)*slope(n);
   };
   for(let row=Math.floor((185-rect.top)*S);row<sh;row++){
     const gy=rect.top+row/S;
     let le=0,re=sw-1;
     for(let col=(100-rect.left)*S;col<(121.5-rect.left)*S;col++)if(original[(row*sw+col)*4+3]>=128)le=col;
     for(let col=Math.floor((121.5-rect.left)*S);col<(145-rect.left)*S;col++)if(original[(row*sw+col)*4+3]>=128){re=col;break;}
     const aL=original[(row*sw+le)*4+3],bL=original[(row*sw+Math.min(sw-1,le+1))*4+3];
     const aR=original[(row*sw+Math.max(0,re-1))*4+3],bR=original[(row*sw+re)*4+3];
     const edgeL=rect.left+(le+(aL===bL?0:(aL-128)/(aL-bL)))/S;
     const edgeR=rect.left+(re-1+(aR===bR?1:(128-aR)/(bR-aR)))/S;
     const ramp=Math.max(0,Math.min(1,(gy-185)/5));
     for(let col=0;col<sw;col++){
       const gx=rect.left+col/S,left=gx<121.5,edge=left?edgeL:edgeR;
       const delta=(curve(left?knotsL:knotsR,gy)-edge)*ramp;
       const weight=Math.max(0,Math.min(1,1-(Math.abs(gx-edge)-4)/15));
       const sx=Math.max(0,Math.min(sw-1,col-delta*S*weight)),x0=Math.floor(sx),x1=Math.min(sw-1,x0+1),f=sx-x0;
       const a=(row*sw+x0)*4,b=(row*sw+x1)*4,i=(row*sw+col)*4,alpha=original[a+3]*(1-f)+original[b+3]*f;
       for(let c=0;c<3;c++)fitted[i+c]=alpha?Math.round((original[a+c]*original[a+3]*(1-f)+original[b+c]*original[b+3]*f)/alpha):0;
       fitted[i+3]=Math.round(alpha);
     }
   }
   drawing=await sharp(fitted,{raw:{width:sw,height:sh,channels:4}}).resize(rect.width,rect.height).raw().toBuffer();
 }
 const mask=await sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="240" height="320"><path d="${shape}" fill="white"/></svg>`)).blur(2).ensureAlpha().raw().toBuffer();
 for(let y=rect.top;y<rect.top+rect.height;y++)for(let x=rect.left;x<rect.left+rect.width;x++){
   const i=(y*W+x)*4,j=((y-rect.top)*rect.width+x-rect.left)*4;
   let m=mask[i+3]/255;if(!m)continue;
   if(outfit[i+3]<250||drawing[j+3]<250)m=m>=.5?1:0;
   const a=outfit[i+3]/255,b=drawing[j+3]/255,combined=a*(1-m)+b*m;
   for(let c=0;c<3;c++)outfit[i+c]=combined?Math.round((outfit[i+c]*a*(1-m)+drawing[j+c]*b*m)/combined):0;
   outfit[i+3]=Math.round(combined*255);
 }
}
async function main(){
 const lock=JSON.parse(fs.readFileSync(path.join(__dirname,'male_avatar_fit_reference.json')));
 const check=()=>{for(const k of ['base','head_hair'])if(sha(path.join(root,lock[k].path))!==lock[k].sha256)throw Error('Locked '+k+' changed');};check();
 const approvedReference=path.join(__dirname,'male_everyday_fit_reference.json');
 if(fs.existsSync(approvedReference)){
   const approved=JSON.parse(fs.readFileSync(approvedReference));
   if(!approved.status.startsWith('founder_approved'))throw Error('Unexpected male everyday lock status; refusing to overwrite existing lock.');
   for(const item of [approved.body,approved.identity,approved.sourceOutfit,approved.outfit,approved.composite])if(sha(path.join(root,item.path))!==item.sha256)throw Error('Approved everyday asset changed: '+item.path);
   const alpha=await sharp(path.join(root,approved.outfit.path)).extractChannel('alpha').raw().toBuffer();
   if(crypto.createHash('sha256').update(alpha).digest('hex')!==approved.outfit.alphaSha256)throw Error('Approved outfit alpha changed');
   console.log('Male everyday v2 is founder-approved and locked. Exact assets verified; no files regenerated or approval metadata overwritten.');
   return;
 }
 const source=path.join(art,'outfit_source.png');
 const scaled=await sharp(source).resize(W,H).png().toBuffer();
 const registered=await sharp({create:{width:W,height:H,channels:4,background:{r:0,g:0,b:0,alpha:0}}}).composite([{input:scaled,left:-3,top:-1}]).ensureAlpha().raw().toBuffer();
 await importDrawingRegion(registered,path.join(art,'pelvis_repair/source.png'),{left:90,top:154,width:65,height:74},'M100 158 Q122 155 144 159 L150 171 L145 204 L151 225 H96 L101 202 L96 173 Z',true);
 await importDrawingRegion(registered,path.join(art,'boot_repair/boot_redraw_source_v3.png'),{left:58,top:248,width:144,height:72},'M58 286 H202 V324 H58 Z');
 const outfitPath=path.join(art,'everyday_outfit_male_candidate_v2.webp');
 await sharp(registered,{raw:{width:W,height:H,channels:4}}).webp({lossless:true}).toFile(outfitPath);
 const fitted=await sharp(path.join(root,lock.base.path)).composite([{input:outfitPath},{input:path.join(root,lock.head_hair.path)}]).png().toBuffer();
 await sharp(fitted).toFile(path.join(art,'native_composite.png'));
 for(const [name,bg] of [['light','#f2e9db'],['dark','#202a2b']]){
   await sharp(fitted).resize(720,960).flatten({background:bg}).png().toFile(path.join(art,'male_everyday_'+name+'.png'));
   for(const [detail,rect] of Object.entries({sleeves:{left:59,top:70,width:120,height:72},crotch:{left:85,top:145,width:78,height:78},boots:{left:62,top:272,width:136,height:48}}))await sharp(fitted).extract(rect).resize(rect.width*6,rect.height*6).flatten({background:bg}).png().toFile(path.join(art,detail+'_'+name+'.png'));
 }
 const alpha=await sharp(outfitPath).extractChannel('alpha').raw().toBuffer();
 const repairs=[{path:'pelvis_repair/source.png',crop:[90,154,65,74],registration:'Continuous 4x inner-contour registration joins the entire redrawn pelvis/upper thighs to the existing lower-leg fall. Whole alpha edge imported; color blends only in opaque cloth interiors.'},{path:'boot_repair/boot_redraw_source_v3.png',crop:[58,248,144,72],registration:'Uniform local crop registration; complete boot drawing joins inside opaque upper shafts.'}].map(r=>({...r,sha256:sha(path.join(art,r.path))}));
 const reference={status:'candidate_pending_founder_review',construction:'one coherent full outfit overlay; no separately exported or equipped shirt, trousers or boots',body:lock.base,identity:lock.head_hair,canvas:[W,H],outfit:{path:path.relative(root,outfitPath),sha256:sha(outfitPath),alphaSha256:crypto.createHash('sha256').update(alpha).digest('hex')},source:{path:path.relative(root,source),sha256:sha(source)},registration:{uniformResize:[240,320],offset:[-3,-1],drawingRepairs:repairs},layerOrder:['body','outfit','identity'],compositeSha256:sha(path.join(art,'native_composite.png'))};
 fs.writeFileSync(path.join(art,'fit_reference.json'),JSON.stringify(reference,null,2)+'\n');check();console.log(JSON.stringify(reference));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
