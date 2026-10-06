// Candidate export only. Never modifies locked bodies or live assets.
// Each source is an independently drawn garment; only uniform registration applies.
const sharp = require('sharp');
const fs = require('fs');
const dir = 'tool/art_assets/legacy_refit_v2/';
const root = 'assets/images/questwell/avatar/';
(async () => {
  for (const f of JSON.parse(fs.readFileSync(dir + 'fits.json')).fits) {
    let source = sharp(dir + f.source).resize(f.width, f.height);
    const x = Math.max(0, -f.left), y = Math.max(0, -f.top);
    const left = Math.max(0, f.left), top = Math.max(0, f.top);
    const resized = await source.png().toBuffer();
    const input = await sharp(resized).extract({left:x,top:y,width:Math.min(f.width-x,240-left),height:Math.min(f.height-y,320-top)}).png().toBuffer();
    const overlay = await sharp({create:{width:240,height:320,channels:4,background:'#00000000'}}).composite([{input,left,top}]).png().toBuffer();
    const path = dir + `${f.family}_${f.body}_registered.png`;
    fs.writeFileSync(path, overlay);
    const v = {male:'v3',female:'v1',neutral:'v4'}[f.body];
    let garments = f.body === 'male' ? [root+'everyday_outfit_male_v2.webp'] : ['boots','trousers','top'].map(p => root+(f.body==='female'?`scout_${p}_female_v6.webp`:`everyday_${p}_neutral_v3.webp`));
    if(f.family==='coat') garments=await Promise.all(garments.map(async path=>{const {data,info}=await sharp(path).ensureAlpha().raw().toBuffer({resolveWithObject:true});for(let y=0;y<150;y++)for(let x=0;x<240;x++)data[(y*240+x)*4+3]=0;return sharp(data,{raw:info}).png().toBuffer();}));
    // Foreground identity restores hair, not a rectangular patch of neck over a collar.
    // The full unmodified neck is already in the complete primary body below clothing.
    let identity = await sharp(root+`base/paper_doll_${f.body}_identity_${v}.webp`).ensureAlpha().raw().toBuffer({resolveWithObject:true});
    if (f.body === 'neutral') for(let y=74;y<320;y++) for(let x=108;x<140;x++) identity.data[(y*240+x)*4+3]=0;
    const hair = await sharp(identity.data,{raw:identity.info}).png().toBuffer();
    const bodyLayer = root+`base/paper_doll_${f.body}_${v}.webp`;
    const hands = [];
    if(f.family==='coat') {
      // Foreground duplicate of exact original hands at unchanged registration.
      // Never mask, crop, shift or replace the complete primary body underneath.
      const regions={male:[[58,180,85,201],[155,180,183,201]],female:[[66,173,85,193],[156,173,174,193]],neutral:[[67,180,88,201],[156,180,178,201]]}[f.body];
      const {data,info}=await sharp(bodyLayer).ensureAlpha().raw().toBuffer({resolveWithObject:true});
      for(let y=0;y<320;y++)for(let x=0;x<240;x++)if(!regions.some(([l,t,r,b])=>x>=l&&x<r&&y>=t&&y<b))data[(y*240+x)*4+3]=0;
      hands.push({input:await sharp(data,{raw:info}).png().toBuffer()});
    }
    const comp = await sharp(bodyLayer).composite([...garments.map(input=>({input})),{input:overlay},...hands,{input:hair}]).png().toBuffer();
    for (const [name, background] of [['light','#eee5d7'],['dark','#252b3b']]) {
      await sharp(comp).flatten({background}).png().toFile(dir+`${f.family}_${f.body}_native_${name}.png`);
      await sharp(comp).flatten({background}).resize(720,960).png().toFile(dir+`${f.family}_${f.body}_review_${name}.png`);
    }
  }
})();
