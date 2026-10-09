// Deterministic packaging of generated art; no generative drawing or repainting.
// Requires sharp 0.35.4. Sources preserve the approved character identity.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require(process.env.CODEX_PRIMARY_RUNTIME_NODE_MODULES
  ? path.join(process.env.CODEX_PRIMARY_RUNTIME_NODE_MODULES, 'sharp') : 'sharp');
if (sharp.versions.sharp !== '0.35.4') throw new Error('Use sharp 0.35.4');
const root = path.resolve(__dirname, '../../..');
(async () => {
  const evidence = {};
  for (const slug of ['boston-terrier', 'hearth-cat']) {
    const source = path.join(__dirname, `${slug}-source.png`);
    const sheet = await sharp(source).ensureAlpha().raw().toBuffer({resolveWithObject: true});
    if (sheet.info.width !== 1536 || sheet.info.height !== 1024) throw new Error('Unexpected sheet grid');
    const tiles = [], bounds = [];
    for (let i = 0; i < 8; i++) {
      // Reuse the true neutral for repeated rests; avoid generated identity drift.
      const inputFrame = i === 3 || (slug === 'boston-terrier' && i === 7) ? 0 : i;
      const data = await sharp(source).extract({left: inputFrame % 4 * 384,
        top: Math.floor(inputFrame / 4) * 512, width:384, height:512}).ensureAlpha().raw().toBuffer();
      let x0=384,y0=512,x1=0,y1=0;
      for(let y=0;y<512;y++) for(let x=0;x<384;x++) {
        const a=(y*384+x)*4+3;
        // Remove only near-transparent matte residue, keeping antialiased edges.
        if(data[a] <= 8) data[a]=0;
        if(data[a] >= 245) data[a]=255;
        if(data[a] > 0) {x0=Math.min(x0,x);y0=Math.min(y0,y);x1=Math.max(x1,x);y1=Math.max(y1,y);}
      }
      if (x0 <= 0 || y0 <= 0 || x1 >= 383 || y1 >= 511) {
        throw new Error(`${slug} frame ${i} touches a source tile boundary`);
      }
      const w=x1-x0+1,h=y1-y0+1;
      const left=Math.floor((384-w)/2),top=498-h;
      if(left<0||top<0)throw new Error(`${slug} frame ${i} exceeds frame canvas`);
      const cut=await sharp(data,{raw:{width:384,height:512,channels:4}})
        .extract({left:x0,top:y0,width:w,height:h}).png().toBuffer();
      const tile=await sharp({create:{width:384,height:512,channels:4,background:'#00000000'}})
        .composite([{input:cut,left,top}]).png().toBuffer();
      tiles.push({input:tile,left:i%4*384,top:Math.floor(i/4)*512});
      bounds.push({frame:i,inputFrame,sourceBounds:[x0,y0,x1,y1],offset:[left-x0,top-y0],ground:498});
    }
    await sharp({create:{width:1536,height:1024,channels:4,background:'#00000000'}})
      .composite(tiles).webp({lossless:true}).toFile(path.join(root,`assets/images/questwell_familiar_${slug}_idle_v1.webp`));
    evidence[slug]=bounds;
  }
  fs.writeFileSync(path.join(__dirname,'registration.json'),JSON.stringify(evidence,null,2)+'\n');
})().catch(error=>{console.error(error);process.exitCode=1;});
