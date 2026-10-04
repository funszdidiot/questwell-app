// Scoped sleeve RGB repair and garment-only depth correction. No new anatomy.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const art = 'tool/art_assets/male_robe_edge_repair_v2';
const abs = p => path.join(root, p);
const read = p => fs.readFileSync(abs(p));
const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const raw = {width:240, height:320, channels:4};
const fit = JSON.parse(read('tool/male_robe_fit_reference.json'));
const previous = JSON.parse(read('tool/male_robe_thumb_repair_reference.json'));
const surfaces = JSON.parse(read('tool/art_assets/male_class_robes_v1/exports.json'));
const names = ['scout', 'scholar', 'alchemist', 'guardian', 'wanderer'];
const pixels = p => sharp(read(p)).ensureAlpha().raw().toBuffer();
const lum = (b,i) => .2126*b[i]+.7152*b[i+1]+.0722*b[i+2];
const clamp = v => Math.round(Math.max(0,Math.min(255,v)));
const alpha = b => Buffer.from(Array.from({length:240*320},(_,n)=>b[n*4+3]));
const oldLayers = name => name === 'scout' ? fit.layers : surfaces.classes[name].layers;
function isCloth(data,i,name) {
  const [r,g,b]=data.subarray(i,i+3);
  if(data[i+3]<160)return false;
  if(name==='guardian')return r>g*2.3 && b>g*.65;
  if(name==='scholar'||name==='alchemist')return b>g*1.2;
  if(name==='wanderer')return r>g*1.25 && r<180;
  return r<g*1.3 && g>b*1.2 && r<160;
}
function clothColor(data,x,y,name) {
  const colors=[];
  for(let yy=y-3;yy<=y+3;yy++)for(let xx=x-2;xx<=x+2;xx++) {
    const i=(yy*240+xx)*4;
    if(isCloth(data,i,name))colors.push([...data.subarray(i,i+3)]);
  }
  if(!colors.length)throw Error(`No cloth donor ${name} ${x},${y}`);
  return [0,1,2].map(c=>colors.map(v=>v[c]).sort((a,b)=>a-b)[Math.floor(colors.length/2)]);
}

async function main() {
  const fixed = [fit.body,fit.identity,fit.outfit,...Object.values(fit.layers),
    ...Object.values(surfaces.classes).flatMap(c=>Object.values(c.layers)),
    ...Object.values(previous.classes).map(c=>c.rear)];
  for (const e of fixed) if(sha(read(e.path))!==e.sha256) throw Error('Changed input '+e.path);
  const generated = await sharp(read(art+'/sleeve_redraw_source.webp')).resize(240,320).ensureAlpha().raw().toBuffer();
  const template = await pixels(fit.layers.front.path);
  const occlusion = await sharp(read(art+'/underrobe_occlusion.svg')).ensureAlpha().raw().toBuffer();
  const outfit = await pixels(fit.outfit.path), underRobe = Buffer.from(outfit);
  for(let n=0;n<240*320;n++) underRobe[n*4+3]=Math.round(outfit[n*4+3]*(1-occlusion[n*4+3]/255));
  // Diagnostic only: the app clips the one original garment, never the body.
  const underRobePng = await sharp(underRobe,{raw}).png().toBuffer();
  const mask = Buffer.alloc(240*320), samples = new Map();
  // One shared surface region for all classes. The original alpha is retained.
  for(let y=78;y<=166;y++) for(const left of [true,false]) {
    let edge;
    for(let d=0;d<120;d++) {
      const x=left?d:239-d;
      if(template[(y*240+x)*4+3]>128){edge=x;break;}
    }
    if(edge===undefined)continue;
    const direction=left?1:-1;
    const inner=edge+direction*9;
    for(let d=-2;d<9;d++) {
      const x=edge+direction*d, i=(y*240+x)*4;
      if(x<0||x>=240||!template[i+3]||(left?x>100:x<140))continue;
      // Never import gold trim, motifs or a new silhouette.
      const weight=d<=4?1:(9-d)/5;
      mask[y*240+x]=Math.round(weight*255);
      // The generated edge may fall a fraction of a pixel inside the mask.
      // Sample the nearest opaque cloth pixel on the same row, inward only.
      let sx=x;
      while(generated[(y*240+sx)*4+3]<220 && Math.abs(sx-inner)<20)sx+=direction;
      samples.set(y*240+x,{sx,inner});
    }
  }
  const classes={};
  for(const name of names) {
    const layers=oldLayers(name), original=await pixels(layers.front.path), next=Buffer.from(original);
    for(const [n,{sx,inner}] of samples) {
      const y=Math.floor(n/240), i=n*4;
      const [r,g,b]=original.subarray(i,i+3);
      // Preserve any class insignia that reaches the repair boundary.
      if(r>110 && g>r*.4 && g>b*1.45)continue;
      // Transfer the redrawn continuous edge shading into each established
      // class color. Match its inner cloth to avoid a pasted shading strip.
      const donor=clothColor(original,inner,y,name);
      const generatedDonor=clothColor(generated,inner,y,'guardian');
      const ratio=Math.max(.65,Math.min(1.2,lum(generated,(y*240+sx)*4)/Math.max(1,lum(generatedDonor,0))));
      const w=mask[n]/255;
      for(let c=0;c<3;c++)next[i+c]=clamp(original[i+c]*(1-w)+donor[c]*ratio*w);
    }
    const version=name==='scout'?'v4':'v2';
    const dest=`assets/images/questwell/avatar/classes/${name}/${name}_robe_front_male_${version}.webp`;
    await sharp(next,{raw}).webp({lossless:true}).toFile(abs(dest));
    const decoded=await pixels(dest);
    if(!alpha(decoded).equals(alpha(original)))throw Error('Front geometry changed');
    const dir=`${art}/${name}`;fs.mkdirSync(abs(dir),{recursive:true});
    const front={path:dest,sha256:sha(read(dest)),alphaSha256:sha(alpha(decoded))};
    const entries={...layers,rear:previous.classes[name].rear,front,body:fit.body,outfit:fit.outfit,identity:fit.identity};
    const compose=(fixedDepth,repaired)=>sharp({create:{...raw,background:'#0000'}}).composite(fit.layerOrder.map(k=>({input:
      k==='outfit'&&fixedDepth?underRobePng:read(k==='front'&&!repaired?layers.front.path:entries[k].path)}))).png().toBuffer();
    const composite=await compose(true,true), before=await compose(false,false);
    fs.writeFileSync(abs(dir+'/native_composite.png'),composite);
    for(const [label,background] of [['light','#f2e9db'],['dark','#202a2b']]) {
      await sharp(composite).resize(480,640).flatten({background}).webp({lossless:true}).toFile(abs(dir+`/full_${label}.webp`));
      await sharp(composite).extract({left:54,top:74,width:134,height:132}).resize(536,528).flatten({background}).webp({lossless:true}).toFile(abs(dir+`/detail_${label}.webp`));
    }
    const comparison=await sharp({create:{width:268,height:132,channels:4,background:'#f2e9db'}}).composite([
      {input:await sharp(before).extract({left:54,top:74,width:134,height:132}).png().toBuffer(),left:0,top:0},
      {input:await sharp(composite).extract({left:54,top:74,width:134,height:132}).png().toBuffer(),left:134,top:0},
    ]).png().toBuffer();
    await sharp(comparison).resize(1072,528).webp({lossless:true}).toFile(abs(dir+'/comparison.webp'));
    classes[name]={front,previousFront:layers.front,rear:entries.rear,
      collar:layers.collar,cuffs:layers.cuffs,compositeSha256:sha(composite)};
  }
  fs.writeFileSync(abs(art+'/sleeve_rgb_region.bin'),mask);
  const reference={status:'founder_requested_repair_not_newly_locked',
    feedback:{date:'2026-10-04',by:'Tanya',quote:'The male robes have holes by the thumbs and there are dark outlines at the outer sleeves- fix these across the different robes where relevant'},
    historicalTemplate:'tool/male_robe_fit_reference.json',canvas:[240,320],layerOrder:fit.layerOrder,
    body:fit.body,identity:fit.identity,outfit:fit.outfit,
    method:'Generated sleeve RGB only inside a shared outer-edge region; all original robe alpha retained. Clip only hidden Everyday trouser pixels using the connected rear-lining contour, with the complete original body below the unaltered outfit asset.',
    source:{path:art+'/sleeve_redraw_source.webp',sha256:sha(read(art+'/sleeve_redraw_source.webp'))},
    sleeveRegion:{path:art+'/sleeve_rgb_region.bin',sha256:sha(mask)},
    outfitOcclusion:{path:art+'/underrobe_occlusion.svg',sha256:sha(read(art+'/underrobe_occlusion.svg')),appliesOnlyWhenRobe:true},classes};
  fs.writeFileSync(abs('tool/male_robe_edge_repair_reference.json'),JSON.stringify(reference,null,2)+'\n');
  for(const e of fixed)if(sha(read(e.path))!==e.sha256)throw Error('Historical input overwritten');
  console.log('Exported five sleeve surfaces with original alpha and garment-only trouser occlusion.');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
