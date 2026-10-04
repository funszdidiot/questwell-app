const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),art=path.join(__dirname,'art_assets/male_robe_v3'),raw={width:240,height:320,channels:4};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function main(){
 const lock=path.join(__dirname,'male_robe_fit_reference.json');
 if(fs.existsSync(lock)){
  const approved=JSON.parse(fs.readFileSync(lock));
  if(approved.status.startsWith('founder_accepted')){
   for(const a of [approved.body,approved.identity,approved.outfit,...Object.values(approved.layers)])if(sha(path.join(root,a.path))!==a.sha256)throw Error(`Changed approved asset ${a.path}`);
   console.log('Male robe v3 approved lock verified; no regeneration.');return;
  }
 }
 const previous=JSON.parse(fs.readFileSync(path.join(__dirname,'art_assets/male_robe_v2/fit_reference.json')));
 for(const a of [previous.body,previous.identity,previous.outfit,...Object.values(previous.layers)])if(sha(path.join(root,a.path))!==a.sha256)throw Error(`Changed input ${a.path}`);
 const old=await sharp(path.join(root,previous.layers.cuffs.path)).ensureAlpha().raw().toBuffer(),next=Buffer.from(old);
 const gen=await sharp(path.join(art,'cuff_redraw_source.png')).resize(132,88,{fit:'fill'}).ensureAlpha().raw().toBuffer();
 // Only new cuff-face color is imported. Existing alpha, openings and geometry
 // are retained exactly; no generated anatomy or background is used.
 let changed=0;
 for(let y=160;y<181;y++)for(let x=55;x<186;x++){
  const i=(y*240+x)*4;if(!old[i+3])continue;
  const t=Math.max(0,Math.min(1,(old[i]/Math.max(1,old[i+1])-1.10)/.18));
  if(!t)continue;
  const weight=t*t*(3-2*t),sx=x-54,sy=y-131,gi=(sy*132+sx)*4;
  for(let c=0;c<3;c++)next[i+c]=Math.round(old[i+c]*(1-weight)+gen[gi+c]*.94*weight);
  changed++;
 }
 const layers={};
 for(const key of ['front','rear','collar','cuffs']){
  const file=path.join(art,`scout_robe_${key}_male_v3.webp`);
  if(key==='cuffs')await sharp(next,{raw}).webp({lossless:true}).toFile(file);else fs.copyFileSync(path.join(root,previous.layers[key].path),file);
  const rgba=await sharp(file).ensureAlpha().raw().toBuffer(),alpha=Buffer.from(Array.from({length:240*320},(_,i)=>rgba[i*4+3]));
  layers[key]={path:path.relative(root,file),sha256:sha(file),alphaSha256:crypto.createHash('sha256').update(alpha).digest('hex')};
  if(layers[key].alphaSha256!==previous.layers[key].alphaSha256)throw Error(`Alpha changed: ${key}`);
 }
 const assets={...layers,body:previous.body,identity:previous.identity,outfit:previous.outfit};
 const fitted=await sharp({create:{...raw,background:'#0000'}}).composite(previous.layerOrder.map(k=>({input:path.join(root,assets[k].path)}))).png().toBuffer();
 fs.writeFileSync(path.join(art,'native_composite.png'),fitted);
 for(const[name,background]of[['light','#f2e9db'],['dark','#202a2b']]){
  await sharp(fitted).resize(720,960).flatten({background}).toFile(path.join(art,`male_robe_${name}.png`));
  await sharp(fitted).extract({left:54,top:159,width:132,height:42}).resize(1056,336).flatten({background}).toFile(path.join(art,`hands_${name}.png`));
 }
 const before=await sharp(path.join(__dirname,'art_assets/male_robe_v2/native_composite.png')).ensureAlpha().raw().toBuffer(),after=await sharp(fitted).ensureAlpha().raw().toBuffer();
 let outside=0,total=0;for(let i=0;i<240*320;i++)if(!before.subarray(i*4,i*4+4).equals(after.subarray(i*4,i*4+4))){total++;if(!old[i*4+3])outside++;}
 if(outside)throw Error('Composite changed outside original cuff layer');
 const reference={...previous,revision:'male-robe-v3',status:'cuff_finish_review',layers,sourceRevision:'male-robe-v2',cuffRedraw:{path:path.relative(root,path.join(art,'cuff_redraw_source.png')),sha256:sha(path.join(art,'cuff_redraw_source.png')),import:'Color only inside original brown cuff facings; exact original alpha and registration retained.'},compositeSha256:sha(path.join(art,'native_composite.png')),visualReview:'tool/art_assets/male_robe_v3/visual_review.json',verification:'tool/art_assets/male_robe_v3/verification.json'};
 fs.writeFileSync(path.join(art,'fit_reference.json'),JSON.stringify(reference,null,2)+'\n');
 const report={bodyIdentityEverydayByteIdentical:true,frontRearCollarByteIdentical:true,allFourAlphaMasksIdentical:true,changedCuffPixels:changed,changedCompositePixels:total,changedOutsideCuffLayer:outside,compositeSha256:reference.compositeSha256};
 fs.writeFileSync(path.join(art,'verification.json'),JSON.stringify(report,null,2)+'\n');console.log(report);
}
main().catch(e=>{console.error(e);process.exitCode=1;});
