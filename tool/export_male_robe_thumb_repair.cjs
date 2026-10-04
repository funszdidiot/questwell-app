// Tanya requested continuous rear lining beside the thumbs. The historical
// accepted template and all anatomy/foreground layers remain unchanged.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const art = 'tool/art_assets/male_robe_thumb_repair_v1';
const raw = {width:240, height:320, channels:4};
const abs = p => path.join(root, p);
const read = p => fs.readFileSync(abs(p));
const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const fit = JSON.parse(read('tool/male_robe_fit_reference.json'));
const surfaces = JSON.parse(read('tool/art_assets/male_class_robes_v1/exports.json'));
const names = ['scout', ...Object.keys(surfaces.classes)];
const layer = (name, part) => name === 'scout'
  ? {...fit.layers[part], path:`assets/images/questwell/avatar/classes/scout/scout_robe_${part}_male_v3.webp`}
  : surfaces.classes[name].layers[part];
const inRepair = (x,y) => y >= 179 && y <= 203 && ((x >= 71 && x <= 91) || (x >= 149 && x <= 169));
const holes = [[76,185],[77,185],[163,185],[164,185],[163,186],[164,186],[78,195],[79,196]];

async function main() {
  const inputs = [fit.body,fit.identity,fit.outfit,
    ...Object.values(fit.layers), ...names.flatMap(name=>['rear','front','collar','cuffs'].map(part=>layer(name,part)))];
  for (const e of inputs) if(sha(read(e.path)) !== e.sha256) throw Error('Changed input: '+e.path);
  const mask = await sharp(read(art+'/lining_contours.svg')).ensureAlpha().raw().toBuffer();
  const body = await sharp(read(fit.body.path)).ensureAlpha().raw().toBuffer();
  const classes = {};
  for (const name of names) {
    const previous = layer(name,'rear');
    const original = await sharp(read(previous.path)).ensureAlpha().raw().toBuffer();
    const next = Buffer.from(original);
    // Sample the existing connected side lining inward of its outer contour.
    // No newly generated anatomy, motif, shading strip or separate patch.
    function liningColor(x,y) {
      const left = x < 120; let best = Infinity, color;
      for(let yy=Math.max(170,y-12);yy<=Math.min(215,y+12);yy++)
        for(let xx=left?82:148;xx<=(left?93:158);xx++) {
          const i=(yy*240+xx)*4;if(original[i+3]<250)continue;
          const distance=(xx-x)**2+(yy-y)**2;
          if(distance<best){best=distance;color=original.subarray(i,i+3);}
        }
      if(!color)throw Error('No connected source lining');
      return color;
    }
    for(let y=0;y<320;y++)for(let x=0;x<240;x++) {
      const i=(y*240+x)*4, added=mask[i+3];if(!added)continue;
      if(!inRepair(x,y))throw Error('Contour outside authorized repair');
      const oldA=original[i+3]/255, underA=added/255, resultA=oldA+underA*(1-oldA);
      const color=liningColor(x,y);
      for(let c=0;c<3;c++) next[i+c]=Math.round((original[i+c]*oldA+color[c]*underA*(1-oldA))/resultA);
      next[i+3]=Math.round(resultA*255);
    }
    let changed=0;
    for(let n=0;n<240*320;n++)if(!next.subarray(n*4,n*4+4).equals(original.subarray(n*4,n*4+4))) {
      const x=n%240,y=Math.floor(n/240);if(!inRepair(x,y))throw Error('Unrelated rear pixel changed');changed++;
    }
    const version=name==='scout'?'v4':'v2';
    const dest=`assets/images/questwell/avatar/classes/${name}/${name}_robe_rear_male_${version}.webp`;
    await sharp(next,{raw}).webp({lossless:true}).toFile(abs(dest));
    const dir=`${art}/${name}`;fs.mkdirSync(abs(dir),{recursive:true});
    const alpha=Buffer.alloc(240*320);for(let n=0;n<alpha.length;n++)alpha[n]=next[n*4+3];
    const sourcePath=dir+'/rear.webp';fs.copyFileSync(abs(dest),abs(sourcePath));
    const repaired={path:dest,sourcePath,sha256:sha(read(dest)),alphaSha256:sha(alpha)};
    const entries={...Object.fromEntries(['front','collar','cuffs'].map(part=>[part,layer(name,part)])),
      rear:repaired, body:fit.body,outfit:fit.outfit,identity:fit.identity};
    const compose = rear => sharp({create:{...raw,background:'#0000'}}).composite(fit.layerOrder.map(k=>({input:read(k==='rear'?rear:entries[k].path)}))).png().toBuffer();
    const composite=await compose(dest), before=await compose(previous.path);
    fs.writeFileSync(abs(dir+'/native_composite.png'),composite);
    const pixels=await sharp(composite).ensureAlpha().raw().toBuffer(), oldPixels=await sharp(before).ensureAlpha().raw().toBuffer();
    for(const [x,y] of holes)if(pixels[(y*240+x)*4+3]!==255)throw Error('Thumb hole remains: '+name+' '+x+','+y);
    let handChanges=0,outsideChanges=0;
    for(let y=0;y<320;y++)for(let x=0;x<240;x++) {
      const i=(y*240+x)*4;
      if(!pixels.subarray(i,i+4).equals(oldPixels.subarray(i,i+4))) {
        if(!inRepair(x,y))outsideChanges++;
        if(inRepair(x,y)&&body[i+3]===255)handChanges++;
      }
    }
    if(handChanges||outsideChanges)throw Error('Fixed hand or unrelated composite changed');
    for(const [label,background] of [['light','#f2e9db'],['dark','#202a2b']]) {
      await sharp(composite).resize(480,640).flatten({background}).toFile(abs(dir+`/full_${label}.png`));
      await sharp(composite).extract({left:54,top:155,width:136,height:49}).resize(1088,392).flatten({background}).toFile(abs(dir+`/hands_${label}.png`));
      const pairs=await sharp({create:{width:136,height:98,channels:4,background:'#0000'}}).composite([
        {input:await sharp(before).extract({left:54,top:155,width:136,height:49}).toBuffer(),top:0,left:0},
        {input:await sharp(composite).extract({left:54,top:155,width:136,height:49}).toBuffer(),top:49,left:0},
      ]).png().toBuffer();
      await sharp(pairs).resize(1088,784,{kernel:'nearest'}).flatten({background}).toFile(abs(dir+`/before_after_${label}.png`));
    }
    classes[name]={rear:repaired,previousRear:previous,changedRearPixels:changed,
      opaqueHandPixelsChanged:handChanges,compositeChangesOutsideRepair:outsideChanges,
      compositeSha256:sha(composite),holes:holes.map(([x,y])=>({x,y,alpha:pixels[(y*240+x)*4+3]}))};
  }
  if(new Set(Object.values(classes).map(c=>c.rear.alphaSha256)).size!==1)throw Error('Class rear masks differ');
  for(const e of inputs)if(sha(read(e.path))!==e.sha256)throw Error('Input overwritten');
  const reference={status:'founder_requested_repair_visual_qa_pending_not_newly_locked',
    feedback:{by:'Tanya',localDate:'2026-10-04',timezone:'America/Chicago',quote:'It looks like the robes have holes in them right next to the thumbs- fix it',scope:'Close both thumb-adjacent rear lining gaps; preserve body and all foreground designs.'},
    canvas:[240,320],historicalLockedTemplate:'tool/male_robe_fit_reference.json',
    contour:{path:art+'/lining_contours.svg',sha256:sha(read(art+'/lining_contours.svg'))},
    body:fit.body,identity:fit.identity,outfit:fit.outfit,layerOrder:fit.layerOrder,
    bounds:{left:[71,179,91,203],right:[149,179,169,203]},
    fixedInputsUnchanged:true,foregroundLayersUnchanged:true,underarmSpaceAbove179Unchanged:true,
    method:'Complete connected rear side-lining contours behind the unchanged hands; existing cloth RGB. Historical fit, source exports and class surfaces preserved.',classes};
  fs.writeFileSync(abs('tool/male_robe_thumb_repair_reference.json'),JSON.stringify(reference,null,2)+'\n');
  console.log('PASS: all five rear lining repairs, zero opaque hand changes, eight defect pixels opaque, historical locks preserved.');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
