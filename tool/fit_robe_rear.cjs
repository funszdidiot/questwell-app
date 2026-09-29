// Bake generated rear-lining art onto each measured 240 x 320 garment canvas.
// The runtime draws rear -> clipped base -> unchanged front, all at 1:1.
const fs = require('node:fs');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const root = path.resolve(__dirname, '..');
const spec = JSON.parse(fs.readFileSync(path.join(__dirname, 'robe_wrap_fit.json')));
function run(name, args, input) {
  const r = spawnSync(name, args, {input, maxBuffer:64*1024*1024});
  if (r.status !== 0) throw new Error(String(r.stderr));
  return r.stdout;
}
for (const [kind, garment] of Object.entries(spec.classes)) {
  const source = path.join(root, garment.source);
  const [sw, sh] = run('identify', ['-format','%w %h',source]).toString().split(' ').map(Number);
  const rgba = run('convert', [source,'-depth','8','rgba:-']);
  const rows=[];
  for(let y=0;y<sh;y++) {
    let left=sw,right=-1;
    for(let x=0;x<sw;x++) if(rgba[(y*sw+x)*4+3]>=128) {left=Math.min(left,x);right=x;}
    if(right-left>8) rows.push({y,left,right});
  }
  const sy0=rows[0].y,sy1=rows.at(-1).y;
  for (const [body, fit] of Object.entries(garment.bodies)) {
    const scale=4,w=240*scale,h=320*scale,out=Buffer.alloc(w*h*4);
    const anchors=fit.rows;
    for(let y=0;y<h;y++) {
      const py=(y+.5)/scale;
      if(py<anchors[0][0]||py>=anchors.at(-1)[0]) continue;
      const i=anchors.findIndex(p=>p[0]>py),a=anchors[i-1],b=anchors[i];
      const t=(py-a[0])/(b[0]-a[0]);
      const left=a[1]*(1-t)+b[1]*t,right=a[2]*(1-t)+b[2]*t;
      if(!(right>left)) throw new Error('Invalid rear silhouette');
      const v=(py-anchors[0][0])/(anchors.at(-1)[0]-anchors[0][0]);
      const sy=sy0+v*(sy1-sy0),iy=Math.min(sh-2,Math.floor(sy));
      const row=rows[Math.min(rows.length-1,Math.max(0,iy-sy0))];
      for(let x=Math.max(0,Math.floor(left*scale));x<Math.min(w,Math.ceil(right*scale));x++) {
        const u=((x+.5)/scale-left)/(right-left);
        if(u<0||u>1) continue;
        const sx=row.left+1+u*(row.right-row.left-2),ix=Math.floor(sx),fx=sx-ix,fy=sy-iy;
        let alpha=0,red=0,green=0,blue=0;
        for(let dy=0;dy<2;dy++) for(let dx=0;dx<2;dx++) {
          const q=((iy+dy)*sw+ix+dx)*4;
          const weight=(dx?fx:1-fx)*(dy?fy:1-fy)*rgba[q+3]/255;
          alpha+=weight;red+=weight*rgba[q];green+=weight*rgba[q+1];blue+=weight*rgba[q+2];
        }
        const q=(y*w+x)*4;
        if(alpha>0) {
          const shade=garment.interior_light;
          out[q]=Math.round(red/alpha*shade);out[q+1]=Math.round(green/alpha*shade);out[q+2]=Math.round(blue/alpha*shade);out[q+3]=Math.round(alpha*255);
        }
      }
    }
    run('convert',['-size',`${w}x${h}`,'-depth','8','rgba:-','-filter','Lanczos','-resize','240x320','-define','webp:lossless=true',path.join(root,fit.output)],out);
    const fd=fs.openSync(path.join(root,fit.output),'r');fs.fsyncSync(fd);fs.closeSync(fd);
    if(fs.statSync(path.join(root,fit.output)).size<32) throw new Error('Empty rear export');
    run('identify',[path.join(root,fit.output)]);
    console.log(`Fitted ${kind} ${body} rear lining`);
  }
}
