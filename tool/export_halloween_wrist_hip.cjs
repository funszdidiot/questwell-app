// Complete source-traced garment extraction. Never modifies a foundation.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {execFileSync:exec}=require('node:child_process'),{createHash}=require('node:crypto');
const root=path.resolve(__dirname,'..'),art=path.join(root,'tool/art_assets/halloween_wrist_hip_v1');
const hash=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const raw=(p,args=[])=>exec('convert',[p,...args,'-depth','8','rgba:-'],{maxBuffer:64*1024*1024});
const write=(b,p)=>exec('convert',['-size','240x320','-depth','8','rgba:-','-define','webp:lossless=true',p],{input:b});
const locks=JSON.parse(fs.readFileSync(path.join(root,'tool/art_assets/halloween_costumes_v1/locked_inputs.json')));
const specs=JSON.parse(fs.readFileSync(path.join(art,'sources.json'))),results=[];
const shapes={
 female:[
  [[94,82],[105,83],[110,109],[111,134],[106,179],[102,230],[98,292],[88,292],[69,286],[68,280],[51,270],[58,251],[69,224],[77,202],[84,179],[91,151],[96,131],[98,117],[96,98]],
  [[131,83],[144,84],[142,113],[143,130],[150,154],[158,181],[168,210],[181,247],[188,268],[179,275],[171,279],[173,286],[141,293],[139,257],[135,218],[132,180],[127,137],[127,111]],
  [[95,84],[85,87],[81,94],[77,113],[73,129],[75,133],[70,146],[65,163],[64,170],[85,174],[87,163],[90,151],[96,132],[99,120],[98,101]],
  [[140,84],[151,89],[157,102],[160,119],[164,132],[163,137],[168,151],[173,171],[152,175],[149,161],[145,148],[140,130],[138,111]]
 ],
 neutral:[
  [[98,79],[110,79],[114,110],[114,139],[111,180],[108,220],[104,261],[103,287],[76,286],[74,281],[61,273],[65,250],[76,220],[84,194],[91,160],[96,134],[98,112]],
  [[134,79],[145,83],[148,111],[150,140],[155,171],[162,202],[174,236],[186,270],[173,281],[174,287],[145,288],[143,258],[140,220],[137,181],[133,142],[132,110]],
  [[98,81],[83,83],[77,95],[76,119],[72,138],[69,155],[66,179],[88,184],[91,165],[96,148],[99,128],[102,109]],
  [[143,79],[163,85],[170,102],[172,123],[171,145],[176,169],[178,180],[157,185],[153,165],[148,149],[145,126],[140,109]]
 ],
 male:[
  [[96,75],[110,76],[112,110],[111,141],[108,181],[104,223],[100,263],[99,281],[73,280],[70,274],[56,266],[62,246],[73,217],[81,189],[88,156],[92,127],[92,102]],
  [[135,74],[147,77],[149,108],[152,141],[158,178],[166,209],[176,239],[184,266],[172,274],[174,280],[143,283],[141,256],[137,218],[133,180],[129,143],[129,108]],
  [[96,76],[80,80],[72,90],[67,109],[63,127],[62,145],[59,173],[81,180],[84,160],[90,142],[94,120],[99,97]],
  [[146,76],[161,82],[173,98],[177,120],[180,143],[182,170],[159,180],[155,161],[150,142],[145,119],[141,95]]
 ]
};
for(const spec of specs){
 const {outfit,body}=spec,folder=path.dirname(path.join(root,spec.source)),dest=path.join(root,'assets/images/questwell/avatar/halloween_v1',outfit,body),lock=locks[body],pumpkin=outfit==='pumpkin_court';
 for(const[p,h]of Object.entries(lock.source_sha256))assert.equal(hash(path.join(root,p)),h);
 const polygons=shapes[body].map(p=>p.map(q=>[...q]));
 // Pumpkin inner gold borders differ slightly; follow their own source outline.
 if(pumpkin&&body==='neutral'){for(let i=3;i<=7;i++)polygons[0][i][0]-=2;}
 if(pumpkin&&body==='male'){polygons[1][polygons[1].length-1][0]-=2;}
 const svg='<svg xmlns="http://www.w3.org/2000/svg" width="960" height="1280" viewBox="0 0 240 320">'+polygons.map(p=>'<polygon fill="white" points="'+p.map(x=>x.join(',')).join(' ')+'"/>').join('')+'</svg>';
 const maskPath=path.join(folder,'garment_mask.svg');fs.writeFileSync(maskPath,svg);
 const src=raw(path.join(root,spec.source),['-filter','Lanczos','-resize','960x1280!']),mask=exec('convert',['-size','960x1280','xc:none','-fill','white','-draw',polygons.map(p=>'polygon '+p.map(([x,y])=>`${x*4},${y*4}`).join(' ')).join(' '),'-depth','8','rgba:-'],{maxBuffer:64*1024*1024}),rgba=Buffer.from(src);
 for(let i=0;i<src.length;i+=4){const[r,g,b]=src.subarray(i,i+3);rgba[i+3]=r>200&&g>185&&b>160?0:mask[i+3];}
 const high=path.join(require('node:os').tmpdir(),`questwell-${outfit}-${body}-extracted.png`);exec('convert',['-size','960x1280','-depth','8','rgba:-','-channel','A','-morphology','Erode','Disk:2','+channel',high],{input:rgba});
 const front=raw(high,['-filter','Lanczos','-resize','240x320!']),foundation=raw(path.join(root,lock.body)),rear=raw(path.join(dest,pumpkin&&body==='male'?'rear_v3.webp':'rear.webp')),cuffs=Buffer.alloc(front.length);
 const handMask=new Set(),start=body==='female'?170:body==='neutral'?178:173;
 for(const [seedX,seedY,minX,maxX]of [[76,185,50,94],[164,185,148,190]]){
  const queue=[[seedX,seedY]],seen=new Set();while(queue.length){const[x,y]=queue.pop(),k=y*240+x;if(x<minX||x>maxX||y<start||y>206||seen.has(k))continue;seen.add(k);if(foundation[k*4+3]<16)continue;handMask.add(k);queue.push([x-1,y],[x+1,y],[x,y-1],[x,y+1]);}
 }
 const previous=raw(path.join(dest,pumpkin&&body==='male'?'front_v3.webp':'front_v2.webp'));
 const collar=Buffer.alloc(front.length);
 for(let y=0;y<320;y++)for(let x=0;x<240;x++){
  const i=(y*240+x)*4;
  if(body==='female'&&y<86)previous.copy(front,i,i,i+4);
  if(y<103)front.copy(collar,i,i,i+4);
  // Remove inherited side rectangles as a continuous full rear-side region.
  if(body==='neutral'&&(x<105||x>139))rear[i+3]=0;
  // Source side cloth belongs behind the whole original hand, including outline.
  if(handMask.has(y*240+x)){
   // Garment pixels beneath the hand are hidden by the unchanged full body.
   if(front[i+3]){front.copy(rear,i,i,i+4);front[i+3]=0;}
  }
 }
 assert(handMask.size>100&&handMask.size<1200,`${body}: unexpected hand component size ${handMask.size}`);
 for(const k of handMask)assert.equal(front[k*4+3],0,`${body}: foreground covers fixed hand`);
 const outputs={};for(const[name,b]of Object.entries({front,rear,cuffs,...(body!=='female'?{collar}:{})})){const file=path.join(dest,name+'_fit_v4.webp');write(b,file);outputs[name]={path:path.relative(root,file),sha256:hash(file)};}
 const layers=['rear_fit_v4.webp',path.join(root,lock.body),'underlay.webp','front_fit_v4.webp',path.join(root,lock.identity),...(body!=='female'?['collar_fit_v4.webp']:[]),'cuffs_fit_v4.webp','mask.webp'];
 for(const[label,bg]of[['light','#f2e9db'],['dark','#202a2b']])for(const scale of[1,3]){const a=['-size',`${240*scale}x${320*scale}`,`xc:${bg}`];for(const f of layers)a.push('(',path.isAbsolute(f)?f:path.join(dest,f),'-filter','Cubic','-resize',`${240*scale}x${320*scale}!`,')','-compose','Over','-composite');a.push(path.join(folder,`${label}_${scale===1?'native':'enlarged'}.png`));exec('convert',a);}
 results.push({outfit,body,sourceSha256:hash(path.join(root,spec.source)),bodySha256:hash(path.join(root,lock.body)),identitySha256:hash(path.join(root,lock.identity)),underlaySha256:hash(path.join(dest,'underlay.webp')),protectedHandPixels:handMask.size,outputs});
}
fs.writeFileSync(path.join(art,'exports.json'),JSON.stringify(results,null,2)+'\n');console.log('Six complete source-traced garment candidates exported.');
