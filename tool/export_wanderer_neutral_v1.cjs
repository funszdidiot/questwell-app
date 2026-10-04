const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),art=path.join(__dirname,'art_assets/neutral_class_robes_v1/wanderer'),out=path.join(root,'assets/images/questwell/avatar/classes/wanderer');
const lock=JSON.parse(fs.readFileSync(path.join(__dirname,'neutral_robe_fit_reference.json')));
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const clamp=(n,a,b)=>Math.max(a,Math.min(b,n));
// target320 -> source320. Surface-only inverse displacement; all output alpha planes remain canonical.
const landmarks=[
 [163,75,163,74],[151,81,150,81],[175,81,176,81],
 [125,87,124,87],[199,87,199,87],[203,94,203,94],[205,105,205,105],[155,109,155,109],[172,109,172,109],
 [118,132,119,133],[208,132,208,133],[155,141,155,142],[172,141,172,142],
 [135,159,136,158],[191,159,191,158],
 [109,174,108,173],[129,181,129,183],[199,181,198,183],[217,174,218,174],
 [149,181,149,182],[177,181,177,182],
 [145,218,144,220],[181,218,181,220],
 [139,260,139,262],[186,260,186,262],
 [104,270,102,270],[115,277,114,279],[140,284,140,286],
 [185,284,185,286],[212,277,213,279],[222,270,225,270],
 [163,276,163,276],
];
function locate(x,y){let sx=0,sy=0,total=0;for(const [tx,ty,px,py]of landmarks){const d=(x-tx)**2+(y-ty)**2;if(d<.0001)return[px,py];const w=1/Math.pow(d,1.5);sx+=(px-tx)*w;sy+=(py-ty)*w;total+=w;}return[x+sx/total,y+sy/total];}
function rgbToHsl(r,g,b){r/=255;g/=255;b/=255;const hi=Math.max(r,g,b),lo=Math.min(r,g,b),d=hi-lo,l=(hi+lo)/2;let h=0,s=0;if(d){s=d/(1-Math.abs(2*l-1));h=hi===r?((g-b)/d)%6:hi===g?(b-r)/d+2:(r-g)/d+4;h=(h*60+360)%360;}return[h,s,l];}
function hslToRgb(h,s,l){const c=(1-Math.abs(2*l-1))*s,x=c*(1-Math.abs((h/60)%2-1)),m=l-c/2;let q=h<60?[c,x,0]:h<120?[x,c,0]:h<180?[0,c,x]:h<240?[0,x,c]:h<300?[x,0,c]:[c,0,x];return q.map(v=>Math.round((v+m)*255));}
function palette(rgb){let[h,s,l]=rgbToHsl(...rgb);if(h<45&&s>.15){return hslToRgb(35,clamp(s*1.06,.48,.83),clamp(l*1.35,0,.83));}return hslToRgb(24,.60,l*.95);}
(async()=>{
 fs.mkdirSync(out,{recursive:true});const fixed=[lock.body,lock.identity,...Object.values(lock.everyday)];for(const v of fixed)if(sha(path.join(root,v.path))!==v.sha256)throw Error('Locked source changed '+v.path);
 const width=640,height=640;const src=await sharp(path.join(art,'robe_source.png')).resize(width,height).ensureAlpha().raw().toBuffer();
 // RGB extension beneath transparent pixels. No new visible geometry is created.
 const known=new Uint8Array(width*height),queue=new Int32Array(width*height);let tail=0;for(let p=0;p<known.length;p++)if(src[p*4+3]>=128){known[p]=1;queue[tail++]=p;}
 for(let head=0;head<tail;head++){const p=queue[head],x=p%width,y=(p-x)/width;for(const q of[x? p-1:-1,x<width-1?p+1:-1,y?p-width:-1,y<height-1?p+width:-1])if(q>=0&&!known[q]){known[q]=1;queue[tail++]=q;for(let c=0;c<3;c++)src[q*4+c]=src[p*4+c];}}
 const sample=(x,y)=>{x=clamp(x*2,0,width-1.001);y=clamp(y*2,0,height-1.001);const ix=Math.floor(x),iy=Math.floor(y),a=x-ix,b=y-iy;return[0,1,2].map(c=>Math.round(src[(iy*width+ix)*4+c]*(1-a)*(1-b)+src[(iy*width+ix+1)*4+c]*a*(1-b)+src[((iy+1)*width+ix)*4+c]*(1-a)*b+src[((iy+1)*width+ix+1)*4+c]*a*b));};
 const rgb=Buffer.alloc(240*320*4);for(let y=0;y<320;y++)for(let x=0;x<240;x++){const p=(y*240+x)*4,[sx,sy]=locate(x+40+.5,y+.5),color=sample(sx,sy);for(let c=0;c<3;c++)rgb[p+c]=color[c];rgb[p+3]=255;}
 const names={front:'wanderer_robe_neutral_v1.webp',rear:'wanderer_robe_rear_neutral_v1.webp',cuffs:'wanderer_robe_cuff_front_neutral_v1.webp',collar:'wanderer_robe_collar_neutral_v1.webp'},layers={},report={status:'exported_pending_independent_visual_review',template:lock.revision,landmarks,outputs:{},fixedAssets:{}};
 for(const part of Object.keys(names)){if(sha(path.join(root,lock.layers[part].path))!==lock.layers[part].sha256)throw Error('Locked robe source changed '+part);const original=await sharp(path.join(root,lock.layers[part].path)).ensureAlpha().raw().toBuffer(),data=Buffer.from(rgb),alph=Buffer.alloc(240*320);for(let p=0;p<alph.length;p++){const i=p*4;data[i+3]=alph[p]=original[i+3];if(part==='cuffs'){ const y=Math.floor(p/240), x=p%240; const t=clamp((y-169)/4,0,1), blend=t*t*(3-2*t);const color=palette([...original.subarray(i,i+3)]);for(let c=0;c<3;c++)data[i+c]=Math.round(data[i+c]*(1-blend)+color[c]*blend); }}const filename=path.join(out,names[part]);await sharp(data,{raw:{width:240,height:320,channels:4}}).webp({lossless:true}).toFile(filename);const decoded=await sharp(filename).ensureAlpha().raw().toBuffer();let differences=0;for(let p=0;p<alph.length;p++)differences+=decoded[p*4+3]!==alph[p];if(differences||hash(alph)!==lock.layers[part].alphaSha256)throw Error('Alpha drift '+part);layers[part]=filename;report.outputs[part]={path:path.relative(root,filename),sha256:sha(filename),alphaSha256:hash(alph),alphaDifferences:0};}
 const paths={...layers,body:path.join(root,lock.body.path),identity:path.join(root,lock.identity.path),...Object.fromEntries(Object.entries(lock.everyday).map(([k,v])=>[k,path.join(root,v.path)]))};
 const native=await sharp({create:{width:240,height:320,channels:4,background:'#00000000'}}).composite(lock.layerOrder.map(n=>({input:paths[n]}))).png().toBuffer();await sharp(native).png().toFile(path.join(art,'neutral_wanderer_v1_native.png'));await sharp(native).resize(720,960).png().toFile(path.join(art,'neutral_wanderer_v1.png'));
 for(const [name,bg]of[['light','#eee7da'],['dark','#20272e']]){await sharp(native).flatten({background:bg}).resize(720,960).png().toFile(path.join(art,'full_'+name+'.png'));await sharp(native).flatten({background:bg}).extract({left:58,top:156,width:131,height:54}).resize(1048,432,{kernel:'nearest'}).png().toFile(path.join(art,'cuffs_'+name+'.png'));await sharp(native).flatten({background:bg}).extract({left:83,top:67,width:83,height:46}).resize(664,368,{kernel:'nearest'}).png().toFile(path.join(art,'collar_'+name+'.png'));await sharp(native).flatten({background:bg}).extract({left:59,top:252,width:131,height:46}).resize(786,276,{kernel:'nearest'}).png().toFile(path.join(art,'hem_'+name+'.png'));}
 await sharp(rgb,{raw:{width:240,height:320,channels:4}}).png().toFile(path.join(art,'registered_surface_rgb.png'));
 for(const v of fixed){const actual=sha(path.join(root,v.path));if(actual!==v.sha256)throw Error('Fixed asset changed');report.fixedAssets[v.path]={sha256:actual,preserved:true};}
 report.layerOrder=lock.layerOrder;report.surfaceMethod='Generated RGB registered by inverse-distance landmark displacement. Original v11 complete cuff RGB palette mapped, with a smooth RGB-only transition across upper cuff cloth y169–173, preserving continuous curved rim and inner join shading. Collar uses the registered surface. Each alpha plane copied exactly.';fs.writeFileSync(path.join(art,'export_metadata.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report.outputs,null,2));
})();
