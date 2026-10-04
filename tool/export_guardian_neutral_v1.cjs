// Guardian surface registration on the immutable founder-approved neutral v11 robe.
const fs=require('node:fs'), path=require('node:path'), crypto=require('node:crypto'), sharp=require('sharp');
const root=path.resolve(__dirname,'..'), art=path.join(__dirname,'art_assets/neutral_class_robes_v1/guardian');
const assetDir=path.join(root,'assets/images/questwell/avatar/classes/guardian');
const W=240,H=320,raw={width:W,height:H,channels:4};
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const fileSha=p=>sha(fs.readFileSync(p));
const clamp=(x,a,b)=>Math.max(a,Math.min(b,x));
const interp=(v,p)=>{if(v<=p[0][0])return p[0][1];for(let i=1;i<p.length;i++){if(v<=p[i][0])return p[i-1][1]+(p[i][1]-p[i-1][1])*(v-p[i-1][0])/(p[i][0]-p[i-1][0]);}return p.at(-1)[1];};
const targetTrim=[[80,151,153,174,176],[84,148,153,174,180],[90,149,155,172,178],[100,151,157,170,176],[120,152,158,169,175],[140,152,158,170,176],[150,151,157,171,176],[160,150,156,171,178],[170,149,155,172,179],[180,147,154,174,180],[190,146,153,175,182],[200,145,152,176,183],[220,143,150,178,185],[240,141,148,180,187],[260,139,146,182,189],[270,138,145,182,189],[285,138,144,183,189]];
const sourceTrim=[[80,148,157,171,179],[84,148,153,174,179],[90,149,156,171,178],[100,151,158,169,176],[120,153,159,168,174],[140,152,157,170,175],[150,151,156,171,176],[160,149,155,172,178],[170,148,154,173,179],[180,147,152,175,180],[190,146,151,176,181],[200,145,150,177,182],[220,143,148,179,184],[240,140,146,181,186],[260,139,145,182,188],[270,138,144,183,189],[285,138,144,183,189]];
function rowExtent(b,width,y){let l=width,r=-1;y=clamp(Math.round(y),0,319);for(let x=0;x<width;x++)if(b[(y*width+x)*4+3]>128){l=Math.min(l,x);r=x;}return [l,r+1];}
function sample(b,width,height,x,y){x=clamp(x,0,width-1);y=clamp(y,0,height-1);let x0=Math.floor(x),y0=Math.floor(y),fx=x-x0,fy=y-y0;let out=[0,0,0,0];for(let j=0;j<2;j++)for(let k=0;k<2;k++){let i=(Math.min(height-1,y0+j)*width+Math.min(width-1,x0+k))*4,w=(k?fx:1-fx)*(j?fy:1-fy);for(let c=0;c<4;c++)out[c]+=b[i+c]*w;}return out;}
function palette(r,g,b,kind,y){
 const brown=r>1.23*g&&g>1.18*b&&r>55;
 const gold=brown&&(kind!=='rear'||y<84||y>268);
 const lum=.2126*r+.7152*g+.0722*b;
 if(gold)return [clamp(lum*2.10+10,0,255),clamp(lum*1.55+5,0,230),clamp(lum*.38,0,255)];
 const scale=kind==='rear'?.90:1;
 return [clamp(lum*1.75*scale,0,255),clamp(lum*.29*scale,0,255),clamp(lum*.39*scale,0,255)];
}
async function main(){
 fs.mkdirSync(assetDir,{recursive:true});
 const ref=JSON.parse(fs.readFileSync(path.join(__dirname,'neutral_robe_fit_reference.json')));
 const fixed=[ref.body,ref.identity,...Object.values(ref.everyday)];
 for(const a of [...fixed,...Object.values(ref.layers)])if(fileSha(path.join(root,a.path))!==a.sha256)throw Error('Changed immutable input: '+a.path);
 const S=4,SW=1280;
 const source=await sharp(path.join(art,'robe_source.png')).resize(SW,SW).ensureAlpha().raw().toBuffer();
 const sourceNative=await sharp(source,{raw:{width:SW,height:SW,channels:4}}).resize(320,320).raw().toBuffer();
 // Nearest interior color padding prevents transparent black from entering locked edge pixels.
 const padded=Buffer.from(source),queue=[],dist=new Int32Array(SW*SW).fill(-1);
 for(let y=0;y<SW;y++)for(let x=0;x<SW;x++){let n=y*SW+x;if(source[n*4+3]>=200){dist[n]=0;queue.push(n);}}
 for(let q=0;q<queue.length;q++){let n=queue[q],x=n%SW,y=Math.floor(n/SW);if(dist[n]>=24)continue;for(const [dx,dy]of[[1,0],[-1,0],[0,1],[0,-1]]){let xx=x+dx,yy=y+dy;if(xx<0||yy<0||xx>=SW||yy>=SW)continue;let m=yy*SW+xx;if(dist[m]>=0)continue;dist[m]=dist[n]+1;for(let c=0;c<3;c++)padded[m*4+c]=padded[n*4+c];queue.push(m);}}
 const target=await sharp(path.join(art,'../references/neutral_locked_cloth.png')).resize(320,320).ensureAlpha().raw().toBuffer();
 const registered=Buffer.alloc(W*H*4);
 for(let y=0;y<H;y++){
   const sy=interp(y,[[0,0],[75,74],[84,84],[150,150],[188,188],[260,261],[287,289],[319,319]]);
   const te=rowExtent(target,320,y),se=rowExtent(sourceNative,320,sy);
   const tk=[te[0],...Array.from({length:4},(_,i)=>interp(y,targetTrim.map(a=>[a[0],a[i+1]]))),te[1]];
   const sk=[se[0],...Array.from({length:4},(_,i)=>interp(sy,sourceTrim.map(a=>[a[0],a[i+1]]))),se[1]];
   const pairs=tk.map((x,i)=>[x,sk[i]]).filter((p,i)=>i===0||p[0]>tk[i-1]);
   for(let x=0;x<W;x++){let sx=interp(x+40+.5,pairs),rgba=sample(padded,SW,SW,sx*S-.5,sy*S-.5);let i=(y*W+x)*4;for(let c=0;c<3;c++)registered[i+c]=Math.round(rgba[c]);registered[i+3]=255;}
 }
 await sharp(registered,{raw}).png().toFile(path.join(art,'registered_surface.png'));
 const outputs={},checks={};
 for(const kind of ['front','rear','cuffs','collar']){
   const locked=await sharp(path.join(root,ref.layers[kind].path)).ensureAlpha().raw().toBuffer(),out=Buffer.from(locked);
   for(let y=0;y<H;y++)for(let x=0;x<W;x++){
     let i=(y*W+x)*4;if(!out[i+3])continue;
     let rgb=[registered[i],registered[i+1],registered[i+2]];
     if(kind==='cuffs'||kind==='rear')rgb=palette(locked[i],locked[i+1],locked[i+2],kind,y);
     // Retain the existing antialiased silhouette outline and its tonal roll-off.
     // Texture registration must not turn a one-pixel contour into a stepped dark fringe.
     if(kind==='front'){
       let edgeDistance=4;
       for(let dy=-3;dy<=3;dy++)for(let dx=-3;dx<=3;dx++){
         let tx=x+40+dx,ty=y+dy;
         if(tx<0||ty<0||tx>=320||ty>=320||target[(ty*320+tx)*4+3]<128)edgeDistance=Math.min(edgeDistance,Math.hypot(dx,dy));
       }
       const weight=clamp((3-edgeDistance)/2,0,1);
       if(weight){const edge=palette(locked[i],locked[i+1],locked[i+2],kind,y);rgb=rgb.map((v,c)=>v*(1-weight)+edge[c]*weight);}
     }
     // Preserve the exact neck band shading and collar finishing edge; clear the Scout motif on the shoulder cloth through the new surface.
     if(kind==='collar'&&((x>=104&&x<=120)||(x>=128&&x<=142))&&locked[i]>1.23*locked[i+1]&&locked[i+1]>1.18*locked[i+2])rgb=palette(locked[i],locked[i+1],locked[i+2],kind,y);
     for(let c=0;c<3;c++)out[i+c]=Math.round(rgb[c]);
   }
   const suffix={front:'robe',rear:'robe_rear',cuffs:'robe_cuff_front',collar:'robe_collar'}[kind];
   const dest=path.join(assetDir,`guardian_${suffix}_neutral_v1.webp`);
   await sharp(out,{raw}).webp({lossless:true}).toFile(dest);
   const decoded=await sharp(dest).ensureAlpha().raw().toBuffer();
   let changedAlpha=0;const a=Buffer.alloc(W*H),b=Buffer.alloc(W*H);for(let j=0;j<W*H;j++){a[j]=locked[j*4+3];b[j]=decoded[j*4+3];if(a[j]!==b[j])changedAlpha++;}
   if(changedAlpha)throw Error(`${kind}: changed alpha values ${changedAlpha}`);
   outputs[kind]={path:path.relative(root,dest),sha256:fileSha(dest),alphaSha256:sha(b)};
   checks[kind]={changedAlphaValues:changedAlpha,alphaMatchesCanonical:sha(b)===ref.layers[kind].alphaSha256};
   if(!checks[kind].alphaMatchesCanonical)throw Error('Canonical alpha mismatch '+kind);
 }
 const item=k=>({input:path.join(root,outputs[k].path)});
 const stack=[item('rear'),{input:path.join(root,ref.body.path)},...['boots','trousers','top'].map(k=>({input:path.join(root,ref.everyday[k].path)})),item('front'),{input:path.join(root,ref.identity.path)},item('collar'),item('cuffs')];
 const fitted=await sharp({create:{...raw,background:'#0000'}}).composite(stack).png().toBuffer();
 await sharp(fitted).toFile(path.join(art,'native_composite.png'));
 await sharp(fitted).resize(720,960).toFile(path.join(art,'guardian_neutral_v1.png'));
 for(const [name,background]of[['light','#f2e9db'],['dark','#202a2b']]){
   await sharp(fitted).resize(720,960).flatten({background}).toFile(path.join(art,`full_${name}.png`));
   await sharp(fitted).extract({left:61,top:158,width:124,height:49}).resize(992,392).flatten({background}).toFile(path.join(art,`hands_${name}.png`));
   await sharp(fitted).extract({left:85,top:61,width:80,height:45}).resize(640,360).flatten({background}).toFile(path.join(art,`collar_${name}.png`));
 }
 for(const a of fixed)if(fileSha(path.join(root,a.path))!==a.sha256)throw Error('Fixed art changed '+a.path);
 const verification={status:'export_verified_visual_review_pending',canonicalTemplate:'tool/neutral_robe_fit_reference.json',source:'robe_source.png',registration:{method:'piecewise monotonic row/trim landmark warp of surface RGB only',targetTrim,sourceTrim,padding:'nearest source RGB extended 6 native pixels beneath immutable alpha'},surfaceTreatment:{front:'generated Guardian surface with front trim and panel landmark registration',cuffs:'locked complete v11 cuff shading palette mapped to burgundy and antique gold',rear:'locked panel/cavity/hand-clearance shading palette mapped, rear hem gold',collar:'registered Guardian shoulder cloth with locked neckline band shading palette mapped'},geometryChecks:checks,fixedArt:fixed,bodyIdentityEverydayUnchanged:true,layerOrder:ref.layerOrder,outputs};
 fs.writeFileSync(path.join(art,'verification.json'),JSON.stringify(verification,null,2)+'\n');
 console.log(JSON.stringify({outputs,checks}));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
