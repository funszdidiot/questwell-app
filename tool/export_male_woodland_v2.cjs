// One full-outfit registration; never transforms or edits the locked body.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const dir = path.join(__dirname, 'art_assets/male_woodland_v2');
async function main() {
  const {data, info} = await sharp(path.join(dir, 'outfit_source.png')).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  // Retain the complete connected garment and its antialias fringe; discard
  // disconnected generator specks. This mask is only applied to garment art.
  const n=info.width*info.height, seen=new Uint8Array(n); let largest=[];
  for(let p=0;p<n;p++) {
    if(seen[p] || data[p*4+3]<=16) continue;
    const q=[p]; seen[p]=1;
    for(let i=0;i<q.length;i++) {
      const v=q[i],x=v%info.width,y=Math.floor(v/info.width);
      for(const [dx,dy] of [[-1,0],[1,0],[0,-1],[0,1]]) {
        const xx=x+dx,yy=y+dy,k=yy*info.width+xx;
        if(xx>=0&&xx<info.width&&yy>=0&&yy<info.height&&!seen[k]&&data[k*4+3]>16){seen[k]=1;q.push(k);}
      }
    }
    if(q.length>largest.length) largest=q;
  }
  const keep=new Uint8Array(n);
  for(const v of largest) for(let dy=-3;dy<=3;dy++) for(let dx=-3;dx<=3;dx++) {
    const x=v%info.width+dx,y=Math.floor(v/info.width)+dy;
    if(x>=0&&x<info.width&&y>=0&&y<info.height)keep[y*info.width+x]=1;
  }
  for(let p=0;p<n;p++)if(!keep[p])data.fill(0,p*4,p*4+4);
  const out=Buffer.alloc(240*320*4);
  const scale=1.02, dy=20, dx=120*(1-scale);
  const smooth=t=>{t=Math.max(0,Math.min(1,t));return t*t*(3-2*t);};
  const widthAt=y=>1+.10*smooth((y-72)/10)*(1-smooth((y-100)/20))
      +.018*smooth((y-220)/35);
  const heelAt=y=>1.8*smooth((y-275)/25);
  for(let y=0;y<320;y++)for(let x=0;x<240;x++) {
    const sum=[0,0,0,0];
    for(let sy=0;sy<4;sy++)for(let sx=0;sx<4;sx++) {
      const yyTarget=y+(sy+.5)/4;
      const xxCanvas=x+(sx+.5)/4;
      const innerEase=.75*Math.exp(-Math.pow((xxCanvas-135)/8,2)-Math.pow((yyTarget-244)/12,2));
      const xxTarget=120+(xxCanvas-120)/widthAt(yyTarget)+innerEase;
      const px=((xxTarget-dx)/scale)*info.width/240-.5;
      const py=((yyTarget-heelAt(yyTarget)-dy)/scale)*info.height/320-.5;
      const xx=Math.floor(px),yy=Math.floor(py),fx=px-xx,fy=py-yy;
      for(let iy=0;iy<2;iy++)for(let ix=0;ix<2;ix++) {
        const u=xx+ix,v=yy+iy;if(u<0||u>=info.width||v<0||v>=info.height)continue;
        const p=(v*info.width+u)*4,w=(ix?fx:1-fx)*(iy?fy:1-fy)/16,a=data[p+3]/255;
        for(let c=0;c<3;c++)sum[c]+=data[p+c]*a*w;
        sum[3]+=a*w;
      }
    }
    const p=(y*240+x)*4;
    if(sum[3])for(let c=0;c<3;c++)out[p+c]=Math.round(sum[c]/sum[3]);
    out[p+3]=Math.round(255*sum[3]);
  }
  const garment=path.join(dir,'outfit_registered.webp');
  await sharp(out,{raw:{width:240,height:320,channels:4}}).webp({lossless:true}).toFile(garment);
  const body=path.join(root,'assets/images/questwell/avatar/base/paper_doll_male_v3.webp');
  const identity=path.join(root,'assets/images/questwell/avatar/base/paper_doll_male_identity_v3.webp');
  const composite=await sharp(body).composite([{input:garment},{input:identity}]).png().toBuffer();
  fs.writeFileSync(path.join(dir,'native_composite.png'),composite);
  for(const [name,color] of [['light','#f2e9db'],['dark','#202a2b']])
    await sharp(composite).flatten({background:color}).resize(960,1280,{kernel:'nearest'}).png().toFile(path.join(dir,`full_${name}.png`));
  fs.writeFileSync(path.join(dir,'registration.json'),JSON.stringify({method:'One continuous whole-outfit field; modest shoulder ease and heel containment, no independent parts',scale,offset:[dx,dy],canvas:[240,320],source:[info.width,info.height],cleanup:'Largest alpha>16 component plus 3-source-pixel antialias fringe'},null,2)+'\n');
}
main().catch(e=>{console.error(e);process.exit(1);});
