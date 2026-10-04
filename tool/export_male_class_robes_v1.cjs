// Surface-only export. Geometry and all foundation bytes remain immutable.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const art = path.join(__dirname, 'art_assets/male_class_robes_v1');
const fit = JSON.parse(fs.readFileSync(path.join(__dirname, 'male_robe_fit_reference.json')));
const classes = ['scholar', 'alchemist', 'guardian', 'wanderer'];
const raw = {width: 240, height: 320, channels: 4};
const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const abs = p => path.join(root, p);
const clamp = v => Math.max(0, Math.min(255, Math.round(v)));
const cloth = {scholar: [.36,.43,.91], alchemist: [.12,.58,1.7], guardian: [1.8,.28,.39], wanderer: [1.18,.70,.37]};
function palette(rgb, name, kind, y) {
  const [r,g,b] = rgb, lum = .2126*r + .7152*g + .0722*b;
  const trim = r > 1.22*g && g > 1.12*b && (kind !== 'rear' || y < 84 || y > 272);
  if (trim) return (name === 'alchemist' ? [1.45,1.50,1.56] : [2.08,1.55,.55]).map(v=>clamp(lum*v));
  return cloth[name].map(v=>clamp(lum*v*(kind === 'rear' ? .76 : 1)));
}
function extent(data, width, y) {
  let left=width, right=-1;
  for(let x=0;x<width;x++) if(data[(y*width+x)*4+3]>128){left=Math.min(left,x);right=x;}
  return [left,right];
}
function bounds(data) {
  let top=320,bottom=-1,left=320,right=-1;
  for(let y=0;y<320;y++) {
    const e=extent(data,320,y);
    if(e[1]>=0){top=Math.min(top,y);bottom=y;left=Math.min(left,e[0]);right=Math.max(right,e[1]);}
  }
  return [top,bottom,left,right];
}
function sample(data,x,y,c) {
  x=Math.max(0,Math.min(319,x));y=Math.max(0,Math.min(319,y));
  const xx=Math.floor(x),yy=Math.floor(y),fx=x-xx,fy=y-yy;
  let value=0;
  for(let j=0;j<2;j++)for(let k=0;k<2;k++)value+=data[(Math.min(319,yy+j)*320+Math.min(319,xx+k))*4+c]*(k?fx:1-fx)*(j?fy:1-fy);
  return value;
}
function padColors(data) {
  const out=Buffer.from(data), distance=new Int16Array(320*320).fill(-1), queue=[];
  for(let n=0;n<distance.length;n++) if(data[n*4+3]>200){distance[n]=0;queue.push(n);}
  for(let k=0;k<queue.length;k++) {
    const n=queue[k],x=n%320,y=Math.floor(n/320);
    if(distance[n]>=12) continue;
    for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
      const xx=x+dx,yy=y+dy;if(xx<0||yy<0||xx>=320||yy>=320)continue;
      const m=yy*320+xx;if(distance[m]>=0)continue;
      distance[m]=distance[n]+1;queue.push(m);
      for(let c=0;c<3;c++)out[m*4+c]=out[n*4+c];
    }
  }
  return out;
}
async function main() {
  const fixed=[fit.body,fit.identity,fit.outfit,...Object.values(fit.layers)];
  for(const e of fixed) if(sha(fs.readFileSync(abs(e.path)))!==e.sha256)throw Error('Locked input changed: '+e.path);
  const target=await sharp(path.join(art,'references/male_locked_cloth.png')).resize(320,320).ensureAlpha().raw().toBuffer();
  const [tt,tb,tl,tr]=bounds(target), results={};
  for(const name of classes) {
    const dir=path.join(art,name), sourcePath=path.join(dir,'robe_source.png');
    const source=await sharp(sourcePath).resize(320,320).ensureAlpha().raw().toBuffer();
    const [st,sb,sl,sr]=bounds(source), padded=padColors(source), registered=Buffer.alloc(240*320*4);
    for(let y=0;y<320;y++) {
      const sy=st+(y-tt)*(sb-st)/(tb-tt);
      for(let x=0;x<240;x++) {
        const sx=sl+(x+40-tl)*(sr-sl)/(tr-tl);
        const i=(y*240+x)*4;
        for(let c=0;c<3;c++)registered[i+c]=clamp(sample(padded,sx,sy,c));registered[i+3]=255;
      }
    }
    const layers={};
    for(const [kind,e] of Object.entries(fit.layers)) {
      const original=await sharp(abs(e.path)).ensureAlpha().raw().toBuffer(), out=Buffer.from(original);
      for(let y=0;y<320;y++)for(let x=0;x<240;x++) {
        const i=(y*240+x)*4;if(!original[i+3])continue;
        const base=palette([...original.subarray(i,i+3)],name,kind,y);
        let weight=kind==='rear'||kind==='cuffs'?1:0;
        // Preserve completed edges and cuff joins using the locked tonal pixels.
        if(kind==='front'||kind==='collar') {
          let edge=4;
          for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++) {
            const xx=x+dx,yy=y+dy;
            if(xx<0||yy<0||xx>=240||yy>=320||original[(yy*240+xx)*4+3]<128)edge=Math.min(edge,Math.hypot(dx,dy));
          }
          weight=Math.max(0,Math.min(1,(2-edge)/2));
        }
        for(let c=0;c<3;c++)out[i+c]=clamp(registered[i+c]*(1-weight)+base[c]*weight);
      }
      const dest=`assets/images/questwell/avatar/classes/${name}/${name}_robe_${kind}_male_v1.webp`;
      await sharp(out,{raw}).webp({lossless:true}).toFile(abs(dest));
      const decoded=await sharp(abs(dest)).ensureAlpha().raw().toBuffer(), alpha=Buffer.alloc(240*320);
      for(let n=0;n<alpha.length;n++)alpha[n]=decoded[n*4+3];
      if(sha(alpha)!==e.alphaSha256)throw Error('Template alpha changed: '+dest);
      layers[kind]={path:dest,sha256:sha(fs.readFileSync(abs(dest))),alphaSha256:sha(alpha)};
    }
    const entries={...layers,body:fit.body,outfit:fit.outfit,identity:fit.identity};
    const composite=await sharp({create:{...raw,background:'#0000'}}).composite(fit.layerOrder.map(k=>({input:abs(entries[k].path)}))).png().toBuffer();
    fs.writeFileSync(path.join(dir,'native_composite.png'),composite);
    for(const [label,background] of [['light','#f2e9db'],['dark','#202a2b']]) {
      await sharp(composite).resize(480,640).flatten({background}).png().toFile(path.join(dir,`full_${label}.png`));
      await sharp(composite).extract({left:54,top:155,width:136,height:47}).resize(816,282).flatten({background}).png().toFile(path.join(dir,`hands_${label}.png`));
      await sharp(composite).extract({left:88,top:65,width:72,height:35}).resize(576,280).flatten({background}).png().toFile(path.join(dir,`collar_${label}.png`));
    }
    results[name]={layers,sourceSha256:sha(fs.readFileSync(sourcePath)),compositeSha256:sha(composite),registration:{method:'continuous_affine_surface_rgb_only',targetBounds:[tt,tb,tl,tr],sourceBounds:[st,sb,sl,sr],immutableAlpha:true,cuffs:'locked tonal structure palette transfer'}};
  }
  for(const e of fixed)if(sha(fs.readFileSync(abs(e.path)))!==e.sha256)throw Error('Locked file changed during export');
  fs.writeFileSync(path.join(art,'exports.json'),JSON.stringify({status:'export_verified_visual_qa_pending',template:'tool/male_robe_fit_reference.json',fixedAssetsUnchanged:true,layerOrder:fit.layerOrder,classes:results},null,2)+'\n');
  console.log('PASS: 16 surface exports retain exact male robe alpha and fixed foundations.');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
