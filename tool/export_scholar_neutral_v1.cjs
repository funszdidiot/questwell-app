// Transfer Scholar surface art to founder-approved neutral v11 geometry.
// All four alpha planes and every body/everyday asset remain exact.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),art=path.join(__dirname,'art_assets/neutral_class_robes_v1/scholar');
const fit=JSON.parse(fs.readFileSync(path.join(__dirname,'neutral_robe_fit_reference.json')));
const W=240,H=320,raw={width:W,height:H,channels:4};
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const abs=p=>path.join(root,p),clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
// [target x,y, generated source x,y], native registration after square normalization.
const pins=[[109,80,108,80],[136,80,138,80],[85,87,83,87],[160,87,162,87],[77,105,77,105],[169,105,169,105],[98,125,98,125],[147,125,147,125],[74,136,74,135],[172,136,172,135],[67,178,67,178],[93,182,93,182],[153,182,153,182],[179,178,179,178],[113,92,113,92],[115,112,115,112],[114,137,114,137],[111,167,111,168],[108,195,109,195],[105,220,105,220],[102,250,102,250],[101,272,101,272],[134,92,134,92],[132,112,132,112],[133,137,133,137],[136,167,136,168],[139,195,138,195],[141,220,141,220],[144,250,144,250],[146,272,146,272],[63,270,61,271],[184,270,186,271],[75,281,73,283],[102,285,104,287],[144,285,143,287],[171,281,173,283],[123,275,123,277]];
function locate(x,y){let sx=0,sy=0,total=0;for(const[a,b,c,d]of pins){let dd=(x-a)**2+(y-b)**2;if(dd<.01)return[c,d];let w=1/(dd*dd);sx+=(c-a)*w;sy+=(d-b)*w;total+=w;}return[x+sx/total,y+sy/total];}
function lockedPalette(r,g,b){
  const l=.2126*r+.7152*g+.0722*b;
  const navy=[l*.35,l*.40,l*.87].map(v=>clamp(Math.round(v),0,255));
  const gold=[r*1.25,r*1.00,r*.28].map(v=>clamp(Math.round(v),0,255));
  const warm=clamp((r-g-17)/24,0,1)*clamp((r-53)/45,0,1);
  return navy.map((n,j)=>Math.round(n*(1-warm)+gold[j]*warm));
}
async function main(){
 const fixed=[fit.body,fit.identity,...Object.values(fit.everyday)];
 for(const p of [...fixed,...Object.values(fit.layers)])if(hash(fs.readFileSync(abs(p.path)))!==p.sha256)throw Error('Source changed: '+p.path);
 const square=await sharp(path.join(art,'robe_source.png')).resize(1280,1280).ensureAlpha().raw().toBuffer();
 function sample(x,y){let xx=clamp(Math.round((x+40)*4),0,1279),yy=clamp(Math.round(y*4),0,1279),i=(yy*1280+xx)*4;if(square[i+3]>150)return[square[i],square[i+1],square[i+2]];let best=null,dist=Infinity;for(let dy=-16;dy<=16;dy++)for(let dx=-16;dx<=16;dx++){let a=clamp(xx+dx,0,1279),b=clamp(yy+dy,0,1279),j=(b*1280+a)*4;if(square[j+3]>200&&dx*dx+dy*dy<dist){dist=dx*dx+dy*dy;best=[square[j],square[j+1],square[j+2]];}}return best||[20,24,53];}
 const out={},checks={};
 const names={front:'scholar_robe_neutral_v1.webp',rear:'scholar_robe_rear_neutral_v1.webp',cuffs:'scholar_robe_cuff_front_neutral_v1.webp',collar:'scholar_robe_collar_neutral_v1.webp'};
 fs.mkdirSync(abs('assets/images/questwell/avatar/classes/scholar'),{recursive:true});
 for(const[k,p]of Object.entries(fit.layers)){
  const original=await sharp(abs(p.path)).ensureAlpha().raw().toBuffer(),d=Buffer.from(original);
  for(let y=0;y<H;y++)for(let x=0;x<W;x++){const i=(y*W+x)*4;if(!d[i+3])continue;const [sx,sy]=locate(x,y);let rgb=sample(sx,sy);
   // Preserve the completed cuff rim/inner joins and neck shading exactly.
   // Sleeve cloth is also palette transferred to retain the approved folds.
   const sleeveEdge=99-clamp((y-150)/35,0,1)*8;
   const sleeve=(y<190&&(x<sleeveEdge||x>246-sleeveEdge));
   const neckTrim=k==='collar'&&original[i]-original[i+1]>35;
   if(k==='cuffs'||neckTrim||sleeve||original[i+3]<8)rgb=lockedPalette(...original.slice(i,i+3));
   for(let j=0;j<3;j++)d[i+j]=rgb[j];
  }
  const pth='assets/images/questwell/avatar/classes/scholar/'+names[k];
  await sharp(d,{raw}).webp({lossless:true}).toFile(abs(pth));
  const decoded=await sharp(abs(pth)).ensureAlpha().raw().toBuffer();
  let diff=0;for(let i=3;i<d.length;i+=4)if(decoded[i]!==original[i])diff++;
  if(diff)throw Error('Changed alpha '+k);
  checks[k]={path:pth,sha256:hash(fs.readFileSync(abs(pth))),alphaPixelsDifferent:diff};out[k]=abs(pth);
 }
 const stack=[out.rear,abs(fit.body.path),abs(fit.everyday.boots.path),abs(fit.everyday.trousers.path),abs(fit.everyday.top.path),out.front,abs(fit.identity.path),out.collar,out.cuffs];
 const native=await sharp({create:{...raw,background:{r:0,g:0,b:0,alpha:0}}}).composite(stack.map(input=>({input}))).png().toBuffer();
 await sharp(native).png().toFile(path.join(art,'native.png'));
 await sharp(native).resize(720,960).png().toFile(path.join(art,'scholar_neutral_v1.png'));
 for(const[n,bg]of [['light','#eee6d7'],['dark','#25262c']]){
  await sharp(native).flatten({background:bg}).resize(720,960).png().toFile(path.join(art,'full_'+n+'.png'));
  await sharp(native).extract({left:60,top:153,width:126,height:54}).flatten({background:bg}).resize(1008,432,{kernel:'nearest'}).png().toFile(path.join(art,'cuffs_'+n+'.png'));
 }
 for(const p of fixed)if(hash(fs.readFileSync(abs(p.path)))!==p.sha256)throw Error('Fixed asset changed '+p.path);
 fs.writeFileSync(path.join(art,'export_metadata.json'),JSON.stringify({status:'exported_pending_independent_visual_review',template:'tool/neutral_robe_fit_reference.json',layers:checks,fixedAssetHashChecks:fixed.length,allFixedAssetsUnchanged:true,registration:{method:'inverse_distance_landmark_rgb_warp',pins,immutableAlpha:true,cuffsNeckTrimAndSleeves:'Exact locked pixels palette mapped for navy cloth and gold edging; original geometry and shading structure retained'},preview:'scholar_neutral_v1.png'},null,2)+'\n');
 console.log(JSON.stringify(checks));
}
main().catch(e=>{console.error(e);process.exit(1)});
