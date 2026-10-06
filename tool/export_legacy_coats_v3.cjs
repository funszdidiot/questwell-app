// Reproduce from repository root with NODE_PATH pointing to installed sharp.
// Fits one continuous garment surface per body; never reads body pixels into clothing.
// Body and identity are read only for QA composites. See legacy_refit_v1/provenance.json.
const sharp=require('sharp');
(async()=>{for(const body of ['male','female','neutral']) {
const root='assets/images/questwell/avatar/',version=body==='male'?'v3':body==='female'?'v1':'v4';
const cfg={male:[1,0.8,0,11],female:[.79,.79,26,17],neutral:[.85,.74,18,17]}[body];
const [sx,sy,left,top]=cfg;
const garment=await sharp(`tool/art_assets/legacy_refit_v1/coat_${body}_source.png`).resize(Math.round(240*sx),Math.round(320*sy)).png().toBuffer();
const output=root+`harvest_coat_${body}_v3.webp`;
const initial=await sharp({create:{width:240,height:320,channels:4,background:'#00000000'}}).composite([{input:garment,left,top}]).png().toBuffer();
const data=await sharp(initial).ensureAlpha().raw().toBuffer(),out=Buffer.alloc(data.length);
const smooth=t=>{t=Math.max(0,Math.min(1,t));return t*t*(3-2*t)};
for(let y=0;y<320;y++)for(let x=0;x<240;x++) {
let sx=x,sy=y-(body==='male'?10:body==='neutral'?4:-4)*smooth((125-y)/45);
const arm=smooth((y-87)/20)*smooth((174-y)/12);
if(x<104)sx-=(body==='male'?8:body==='neutral'?6:4)*arm*Math.exp(-Math.pow((x-88)/13,2));
if(x>140)sx+=(body==='male'?8:4)*arm*Math.exp(-Math.pow((x-154)/13,2));
if(body==='female'&&x<100)sx+=6*smooth((y-77)/15)*smooth((152-y)/15)*Math.exp(-Math.pow((x-83)/10,2));
if(body==='neutral') {
 const shoulder=smooth((y-79)/12)*smooth((124-y)/15);
 if(x>140)sx-=5*shoulder*Math.exp(-Math.pow((x-158)/12,2));
 if(x<112)sx-=4*smooth((y-100)/14)*smooth((147-y)/13)*Math.exp(-Math.pow((x-97)/10,2));
 const cuff=smooth((y-142)/25)*smooth((192-y)/8);
 if(x<95)sx-=5*cuff;
 if(x>145)sx+=3*cuff;
 if(x>155)sx-=4*smooth((y-136)/13)*smooth((179-y)/8)*Math.exp(-Math.pow((x-172)/10,2));
}
if(body==='male') {
 const elbow=smooth((y-115)/15)*smooth((162-y)/15);
 if(x<76)sx+=4*elbow*Math.exp(-Math.pow((x-65)/11,2));
 if(x>164)sx-=4*elbow*Math.exp(-Math.pow((x-175)/11,2));
}
if(body==='female')sx+=4*smooth((y-110)/10)*smooth((162-y)/12)*smooth((x-92)/6)*smooth((120-x)/6);
if(body==='female'&&x<83)sx+=2*smooth((y-132)/10)*smooth((170-y)/8);
if(body==='male') {let cuff=smooth((y-142)/22)*smooth((190-y)/10); if(x<95)sx-=4*cuff; if(x>145)sx+=5*cuff;}
let ix=Math.floor(sx),iy=Math.floor(sy),v=[0,0,0,0];
for(let yy=0;yy<2;yy++)for(let xx=0;xx<2;xx++){let X=ix+xx,Y=iy+yy;if(X<0||X>=240||Y<0||Y>=320)continue;let j=(Y*240+X)*4,a=data[j+3]/255,w=(xx?sx-ix:1-sx+ix)*(yy?sy-iy:1-sy+iy);for(let c=0;c<3;c++)v[c]+=data[j+c]*a*w;v[3]+=a*w;}
let i=(y*240+x)*4;for(let c=0;c<3;c++)out[i+c]=v[3]?Math.round(v[c]/v[3]):0;out[i+3]=Math.round(v[3]*255);
}
await sharp(out,{raw:{width:240,height:320,channels:4}}).webp({lossless:true}).toFile(output);
let layers=body==='male'?[root+'everyday_outfit_male_v2.webp']:['boots','trousers'].map(p=>root+(body==='female'?`scout_${p}_female_v6.webp`:`everyday_${p}_neutral_v3.webp`));
if(body==='male'){const {data,info}=await sharp(layers[0]).ensureAlpha().raw().toBuffer({resolveWithObject:true});for(let y=0;y<150;y++)for(let x=0;x<240;x++)data[(y*240+x)*4+3]=0;layers=[await sharp(data,{raw:info}).png().toBuffer()];}
const comp=await sharp(root+`base/paper_doll_${body}_${version}.webp`).composite([...layers.map(input=>({input})),{input:output},{input:root+`base/paper_doll_${body}_identity_${version}.webp`}]).png().toBuffer();
for(const [name,color] of [['light','#f4eddf'],['dark','#18252c']])await sharp(comp).flatten({background:color}).resize(720,960).png().toFile(`tool/art_assets/legacy_refit_v1/coat_${body}_${name}.png`);
}})();
