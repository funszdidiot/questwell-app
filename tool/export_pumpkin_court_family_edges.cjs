// Color-only female/neutral Pumpkin Court cleanup; never imports source alpha.
// ImageMagick 6.9.12-98 and Node built-ins; no application dependencies.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const { createHash } = require('node:crypto');
const root = path.resolve(__dirname, '..');
const art = path.join(root, 'tool/art_assets/pumpkin_court_edges_v4');
const hash = p => createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const raw = (p, args=[]) => execFileSync('convert',[p,...args,'-depth','8','rgba:-'],{maxBuffer:32*1024*1024});
const index=(x,y)=>(y*240+x)*4;
const version=execFileSync('convert',['-version'],{encoding:'utf8'}).split('\n')[0];
assert(version.includes('ImageMagick 6.9.12-98'));
const locks=JSON.parse(fs.readFileSync(path.join(root,'tool/art_assets/halloween_costumes_v1/locked_inputs.json')));
const results={version,bodies:{}};
for(const body of ['female','neutral']) {
  const locked=locks[body];
  for(const [file,sha] of Object.entries(locked.source_sha256)) assert.equal(hash(path.join(root,file)),sha);
  const folder=path.join(art,body);
  const dest=path.join(root,'assets/images/questwell/avatar/halloween_v1/pumpkin_court',body);
  // Female screenshot registration: native x,y -> screenshot 1.245*x-58,1.245*y-26.
  // It was measured against the original screenshot, not generated anatomy.
  const size=body==='female'?[162,397]:[240,320];
  const source=raw(path.join(folder,'edited_source.png'),['-filter','Lanczos','-resize',`${size[0]}x${size[1]}!`]);
  function sample(x,y,kind) {
    let best=null,dist=Infinity;
    const sx=body==='female'?x*1.245-58:x;
    const sy=body==='female'?y*1.245-26:y;
    const radius=kind==='gold'?18:14;
    for(let dy=-radius;dy<=radius;dy++)for(let dx=-radius;dx<=radius;dx++) {
      const xx=Math.round(sx+dx),yy=Math.round(sy+dy);
      if(xx<0||xx>=size[0]||yy<0||yy>=size[1])continue;
      const j=(yy*size[0]+xx)*4;
      const [r,g,b]=source.subarray(j,j+3);
      const match=kind==='orange'?r>125&&r>g*1.5&&g>b*1.5:
        kind==='green'?g>35&&g<110&&g>r*1.09&&g>b*1.1:
        r>135&&g>75&&r>g*1.12&&g>b*1.45;
      const d=dx*dx+dy*dy;
      if(match&&d<dist){best=j;dist=d;}
    }
    assert.notEqual(best,null,`${body}: missing ${kind} sample at ${x},${y}`);
    return source.subarray(best,best+3);
  }
  const outputs={};
  for(const part of ['front','cuffs']) {
    const input=path.join(dest,`${part}.webp`),before=raw(input),after=Buffer.from(before),mask=Buffer.alloc(before.length);
    const bottom=Array.from({length:240},(_,x)=>{for(let y=319;y>=0;y--)if(before[index(x,y)+3]>32)return y;return -1;});
    const top=Array.from({length:240},(_,x)=>{for(let y=0;y<320;y++)if(before[index(x,y)+3]>32)return y;return 320;});
    const bounds=Array.from({length:320},(_,y)=>{const xs=Array.from({length:240},(_,x)=>x).filter(x=>before[index(x,y)+3]>32);return[xs[0]??0,xs.at(-1)??239];});
    let changed=0;
    for(let y=0;y<320;y++)for(let x=0;x<240;x++) {
      const i=index(x,y);if(before[i+3]<32||x<50||x>194)continue;
      if(part==='cuffs' && !(body==='female'?y>=163&&y<=174:y>=165&&y<=185))continue;
      const shoulder=body==='female'&&y>=78&&y<=151&&(x<96||x>143)&&(x<=bounds[y][0]+6||x>=bounds[y][1]-6||y<=top[x]+4);
      const cuff=body==='female'?y>=151&&y<=162:y>=163&&y<=168;
      const hem=y>=260&&y<=294&&y>=bottom[x]-5;
      if(!(part==='cuffs'||shoulder||hem||cuff))continue;
      const [r,g,b]=before.subarray(i,i+3);
      if(Math.max(r,g,b)>=(hem?125:85))continue; // Keep the embroidery, trim and ordinary cloth.
      if(part==='front'&&cuff&&!(x<=bounds[y][0]+6||x>=bounds[y][1]-6))continue;
      const edge=[[-1,0],[1,0],[0,-1],[0,1]].some(([dx,dy])=>x+dx<0||x+dx>=240||y+dy<0||y+dy>=320||before[index(x+dx,y+dy)+3]<32);
      const kind=hem?'gold':part==='cuffs'||cuff?'green':'orange';
      const rgb=sample(x,y,kind);
      for(let c=0;c<3;c++)after[i+c]=Math.round(rgb[c]*(edge?0.62:1));
      mask[i]=255;mask[i+3]=255;changed++;
    }
    assert(changed>0);
    const file=path.join(dest,`${part}_v2.webp`);
    execFileSync('convert',['-size','240x320','-depth','8','rgba:-','-define','webp:lossless=true',file],{input:after});
    const decoded=raw(file);
    for(let i=0;i<before.length;i+=4){assert.equal(decoded[i+3],before[i+3]);if(before[i+3]&&!mask[i+3])assert.deepEqual(decoded.subarray(i,i+3),before.subarray(i,i+3));}
    execFileSync('convert',['-size','240x320','-depth','8','rgba:-',path.join(folder,`${part}_change_mask.png`)],{input:mask});
    outputs[part]={path:path.relative(root,file),sha256:hash(file),inputSha256:hash(input),changedPixels:changed,alphaUnchanged:true,unselectedVisibleRgbUnchanged:true};
  }
  const names=['rear.webp',path.join(root,locked.body),'underlay.webp','front_v2.webp',path.join(root,locked.identity),...(body==='neutral'?['collar.webp']:[]),'cuffs_v2.webp','mask.webp'];
  for(const [label,bg] of [['light','#f2e9db'],['dark','#202a2b']])for(const scale of [1,3]) {
    const args=['-size',`${240*scale}x${320*scale}`,`xc:${bg}`];
    for(const layer of names)args.push('(',path.isAbsolute(layer)?layer:path.join(dest,layer),'-filter','Cubic','-resize',`${240*scale}x${320*scale}!`,')','-compose','Over','-composite');
    args.push('-depth','8',path.join(folder,`${label}_${scale===1?'native':'enlarged'}.png`));execFileSync('convert',args);
  }
  results.bodies[body]={sourceSha256:hash(path.join(folder,'edited_source.png')),bodySha256:hash(path.join(root,locked.body)),identitySha256:hash(path.join(root,locked.identity)),outputs};
}
fs.writeFileSync(path.join(art,'exports.json'),JSON.stringify(results,null,2)+'\n');
console.log(JSON.stringify(results,null,2));
