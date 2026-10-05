// Whole-source uniform registration and depth exports. Never alters body files.
const sharp = require('sharp');
const fs = require('fs');
const crypto = require('crypto');
const dir = 'tool/art_assets/legacy_depth_v1/';
const root = 'assets/images/questwell/avatar/';
const sha = buffer => crypto.createHash('sha256').update(buffer).digest('hex');
// Depth contours trace the authored oval cuff cavities, not the avatar.
// The original cavity cloth moves behind the complete wrist; the gold lip
// stays in the front garment. No replacement skin or hand is authored.
const cuffWindows = {
  female: [[72.8,167.3,4.5,1.5],[162.9,166.5,4.6,1.6]],
  male: [[68.2,173.8,9.3,2.7],[172.6,173.7,9.7,2.7]],
  neutral: [[75.7,174.7,6.5,2.4],[167.2,174.9,6.5,2.4]],
};
async function raw(input) { return sharp(input).ensureAlpha().raw().toBuffer({resolveWithObject:true}); }
async function clean(input) {
  const {data,info}=await raw(input),seen=new Uint8Array(info.width*info.height);
  for(let n=0;n<seen.length;n++)if(data[n*4+3]<9)data[n*4+3]=0;
  for(let n=0;n<seen.length;n++) {
    if(seen[n]||!data[n*4+3])continue;
    const pixels=[n];seen[n]=1;
    for(let j=0;j<pixels.length;j++) {
      const p=pixels[j],x=p%info.width,y=Math.floor(p/info.width);
      for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++) {
        const xx=x+dx,yy=y+dy,q=yy*info.width+xx;
        if(xx<0||yy<0||xx>=info.width||yy>=info.height||seen[q]||!data[q*4+3])continue;
        seen[q]=1;pixels.push(q);
      }
    }
    if(pixels.length<6)for(const p of pixels)data[p*4+3]=0;
  }
  return sharp(data,{raw:info}).png().toBuffer();
}
async function bounds(input) {
  const {data,info} = await raw(input); let l=info.width,t=info.height,r=0,b=0;
  for(let y=0;y<info.height;y++)for(let x=0;x<info.width;x++)if(data[(y*info.width+x)*4+3]>128){l=Math.min(l,x);r=Math.max(r,x);t=Math.min(t,y);b=Math.max(b,y);}
  return {l,t,r,b,w:r-l+1,h:b-t+1};
}
async function register(input, target) {
  const bb=await bounds(input), meta=await sharp(input).metadata();
  const scale=target.h/bb.h, width=Math.round(meta.width*scale),height=Math.round(meta.height*scale);
  const left=Math.round((target.l+target.r)/2-(bb.l+bb.r)*scale/2),top=Math.round(target.t-bb.t*scale);
  const resized=await sharp(input).resize(width,height).png().toBuffer();
  const x=Math.max(0,-left),y=Math.max(0,-top),l=Math.max(0,left),t=Math.max(0,top);
  const piece=await sharp(resized).extract({left:x,top:y,width:Math.min(width-x,240-l),height:Math.min(height-y,320-t)}).png().toBuffer();
  return {buffer:await sharp({create:{width:240,height:320,channels:4,background:'#00000000'}}).composite([{input:piece,left:l,top:t}]).png().toBuffer(),registration:{width,height,left,top}};
}
async function save(buffer,name) { fs.writeFileSync(dir+name+'.png',buffer); return sha(buffer); }
(async()=>{
  const records=[];
  for(const body of ['female','male','neutral'])for(const family of ['cloak','mantle','coat']) {
    const stem=family==='cloak'?'moss_cloak':family==='mantle'?'hearthguard_mantle':'harvest_coat';
    const old=root+`${stem}_${body}_${family==='coat'?'v4':'v3'}.webp`;
    const source=dir+(family==='coat'?`cuff_${body}_source.webp`:`${family}_${body}_front_source.webp`);
    const target=await bounds(old);
    // Whole-source male cloak registration gets 1% extra ease and a half-pixel
    // center correction; never stretch an individual sleeve or another body.
    if(family==='cloak'&&body==='male') { target.h*=1.01;target.t-=1;target.l+=.5;target.r+=.5; }
    const registered=await register(source,target);
    let front=await clean(registered.buffer), rear=null;
    if(family==='coat') {
      const ellipses=cuffWindows[body].map(([cx,cy,rx,ry])=>`<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="white"/>`).join('');
      const mask=await sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="960" height="1280" viewBox="0 0 240 320">${ellipses}</svg>`)).resize(240,320).ensureAlpha().raw().toBuffer();
      const f=await raw(front),r=Buffer.from(f.data);
      for(let n=0;n<240*320;n++) {
        const i=n*4,weight=mask[i+3]/255;
        r[i+3]=Math.round(f.data[i+3]*weight);
        f.data[i+3]=Math.round(f.data[i+3]*(1-weight));
      }
      front=await sharp(f.data,{raw:f.info}).png().toBuffer();
      rear=await sharp(r,{raw:f.info}).png().toBuffer();
      await save(rear,`${family}_${body}_rear`);
    }
    if(family!=='coat') {
      // A complete rear sheet behind the full body. Each body's height and
      // footprint are fitted independently inside its front garment envelope.
      const rearTarget={l:target.l+5,r:target.r-5,t:target.t+25,h:target.h-32};
      rear= (await register(dir+family+'_rear_source.webp',rearTarget)).buffer;
      // Hide backing outside the front's continuous outer silhouette, never
      // cut the avatar. At every row the front encloses the rear cloth.
      const f=await raw(front),r=await raw(rear);
      for(let y=0;y<320;y++){
        let l=240,rr=-1;for(let x=0;x<240;x++)if(f.data[(y*240+x)*4+3]>128){l=Math.min(l,x);rr=Math.max(rr,x);}
        for(let x=0;x<240;x++)if(x<l+1||x>rr-1)r.data[(y*240+x)*4+3]=0;
      }
      rear=await sharp(r.data,{raw:r.info}).png().toBuffer();
      await save(rear,`${family}_${body}_rear`);
    }
    await save(front,`${family}_${body}_front`);
    const version=family==='coat'?'v6':'v4';
    const paths={front:root+`${stem}_${body}_${version}.webp`,rear:root+`${stem}_rear_${body}_${version}.webp`};
    await sharp(front).webp({lossless:true}).toFile(paths.front);
    await sharp(rear).webp({lossless:true}).toFile(paths.rear);
    const v={female:'v1',male:'v3',neutral:'v4'}[body];
    const bodyPath=root+`base/paper_doll_${body}_${v}.webp`;
    let garments=body==='male'?[root+'everyday_outfit_male_v2.webp']:['boots','trousers','top'].map(p=>root+(body==='female'?`scout_${p}_female_v6.webp`:`everyday_${p}_neutral_v3.webp`));
    if(family==='coat')garments=await Promise.all(garments.map(async p=>{const r=await raw(p);for(let y=0;y<150;y++)for(let x=0;x<240;x++)r.data[(y*240+x)*4+3]=0;return sharp(r.data,{raw:r.info}).png().toBuffer();}));
    const identity=await raw(root+`base/paper_doll_${body}_identity_${v}.webp`);
    if(body==='neutral')for(let y=74;y<320;y++)for(let x=108;x<140;x++)identity.data[(y*240+x)*4+3]=0;
    const layers=[...(rear?[{input:rear}]:[]),{input:bodyPath},...garments.map(input=>({input})),{input:front}];
    if(family==='coat'){
      const regions={female:[[66,173,85,193],[156,173,174,193]],male:[[58,180,85,201],[155,180,183,201]],neutral:[[67,180,88,201],[156,180,178,201]]}[body];
      const hands=await raw(bodyPath);
      for(let y=0;y<320;y++)for(let x=0;x<240;x++)if(!regions.some(([l,t,r,b])=>x>=l&&x<r&&y>=t&&y<b))hands.data[(y*240+x)*4+3]=0;
      layers.push({input:await sharp(hands.data,{raw:hands.info}).png().toBuffer()});
    }
    layers.push({input:await sharp(identity.data,{raw:identity.info}).png().toBuffer()});
    const composite=await sharp({create:{width:240,height:320,channels:4,background:'#00000000'}}).composite(layers).png().toBuffer();
    for(const [name,background] of [['light','#eee5d7'],['dark','#252b3b']]){
      await sharp(composite).flatten({background}).png().toFile(dir+`${family}_${body}_native_${name}.png`);
      await sharp(composite).flatten({background}).resize(720,960).png().toFile(dir+`${family}_${body}_review_${name}.png`);
    }
    records.push({family,body,source,source_sha256:sha(fs.readFileSync(source)),registration:registered.registration,cuffWindows:family==='coat'?cuffWindows[body]:undefined,front_sha256:sha(front),rear_sha256:sha(rear),runtime:Object.fromEntries(Object.entries(paths).map(([part,path])=>[part,{path,sha256:sha(fs.readFileSync(path))}]))});
  }
  fs.writeFileSync(dir+'exports.json',JSON.stringify({status:'BUILDING',records},null,2)+'\n');
  const manifestPath='tool/avatar_assets.json';
  const manifest=JSON.parse(fs.readFileSync(manifestPath));
  manifest.candidate_layers.legacy_natural_drape_v1={
    visual_approval:'active_founder_requested_repair_not_locked',
    description:'Body-specific natural drape and clean openings; rear cloak/mantle cloth and coat cuff cavities behind complete locked bodies. No account policy changes.',
    assets:records.flatMap(record=>Object.values(record.runtime)),
  };
  fs.writeFileSync(manifestPath,JSON.stringify(manifest,null,2)+'\n');
})();
