// Technical fit/depth regressions supplement, never replace, visual review.
const sharp=require('sharp');
const fs=require('fs');
const crypto=require('crypto');
const assert=require('assert/strict');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
async function pixels(path){const {data,info}=await sharp(path).ensureAlpha().raw().toBuffer({resolveWithObject:true});assert.equal(info.width,240);assert.equal(info.height,320);return data;}
const alpha=(d,x,y)=>d[(y*240+x)*4+3];
(async()=>{
  const root='assets/images/questwell/avatar/';
  const bodies={female:['v1','00a7fcaefb8bba3e8e528e8ee2cd1dea6650c61cf6b8f0f877eadd505a47938a'],male:['v3','9e35a6ebdda22719851fa37f33c81f2b6c1340719453bf50d9ac4acf9156ebda'],neutral:['v4','bad2b39c90793b937308eff3de32550fd9ecf06c90140e1233902442fcc7fc24']};
  const manifest=JSON.parse(fs.readFileSync('tool/art_assets/legacy_depth_v1/exports.json'));
  const results=[];
  for(const item of manifest.records){
    const {body,family}=item;
    const basePath=root+`base/paper_doll_${body}_${bodies[body][0]}.webp`;
    assert.equal(sha(fs.readFileSync(basePath)),bodies[body][1]);
    const base=await pixels(basePath);
    for(const file of Object.values(item.runtime))assert.equal(sha(fs.readFileSync(file.path)),file.sha256);
    const front=await pixels(item.runtime.front.path),rear=await pixels(item.runtime.rear.path);
    let missing=0;
    if(family!=='coat'){
      for(let y=115;y<199;y++)for(let x=50;x<190;x++){
        if(x>=96&&x<=144)continue;
        if(alpha(base,x,y)>=230&&alpha(front,x,y)<190)missing++;
      }
      assert.equal(missing,0,`${family}/${body} uncovered arm/hand pixels`);
      for(const y of [160,200,240])assert(alpha(front,122,y)<10,`${family}/${body} unwanted front inner flap`);
      for(const y of [180,220,260])assert(alpha(rear,122,y)>240,`${family}/${body} continuous back cloth`);
      let l=240,r=-1;
      for(let y=230;y<300;y++)for(let x=0;x<240;x++)if(alpha(front,x,y)>128){l=Math.min(l,x);r=Math.max(r,x);}
      assert(r-l+1<=160,`${family}/${body} excessive hem flare (${r-l+1}px)`);
      results.push({family,body,coveredArmPixels:true,lowerWidth:r-l+1,rearContinuous:true});
    }else{
      for(const [cx,cy] of item.cuffWindows){const x=Math.round(cx),y=Math.round(cy);assert(alpha(front,x,y)<40,`${body} cuff cavity foreground`);assert(alpha(rear,x,y)>210,`${body} cuff rear absent`);}
      results.push({family,body,cuffCavityBehindWrist:true});
    }
  }
  console.log(JSON.stringify({status:'PASS',results},null,2));
})();
