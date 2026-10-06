// Reproduce from repository root with NODE_PATH pointing to installed sharp.
// Fits one continuous garment surface per body; never reads body pixels into clothing.
// Body and identity are read only for QA composites. See legacy_refit_v1/provenance.json.
const fs=require('fs'),sharp=require('sharp');
const smooth=t=>{t=Math.max(0,Math.min(1,t));return t*t*(3-2*t)};
(async()=>{for(const body of ['male','female','neutral']) {const version=body==='male'?'v3':body==='female'?'v1':'v4';const root='assets/images/questwell/avatar/base/';let {data}=await sharp(`tool/art_assets/legacy_refit_v1/suit_${body}_source.png`).resize(240,320).ensureAlpha().raw().toBuffer({resolveWithObject:true});const out=Buffer.alloc(data.length);
function map(x,y){let sy=y-(body==='neutral'?8:body==='female'?3:3)*smooth((y-275)/35)-(body==='female'?7:5)*Math.exp(-Math.pow((x-121)/18,2))*smooth((y-157)/40)*smooth((238-y)/28);let sx=x;
// Continuous inward widening of sleeve cloth, leaving cuff and hands fixed.
let shoulder=smooth((y-76)/14)*smooth((128-y)/16); if(body!=='male'&&x>130)sx-=(body==='neutral'?5:3)*shoulder*Math.exp(-Math.pow((x-154)/16,2)); if(body==='female'&&x<100)sx+=2*shoulder*Math.exp(-Math.pow((x-82)/13,2));
let arm=smooth((y-112)/16)*smooth((174-y)/12);
if(x<104)sx-=(body==='female'?5:body==='neutral'?7:4)*arm*Math.exp(-Math.pow((x-85)/12,2));
if(x>140)sx+=(body==='male'?4:body==='female'?4:0)*arm*Math.exp(-Math.pow((x-157)/12,2));
if(body!=='male'&&x<90)sx+=(body==='female'?6:8)*arm*Math.exp(-Math.pow((x-77)/9,2));
if(body==='female'&&x>154)sx-=6*arm*Math.exp(-Math.pow((x-162)/9,2));
// Cover feet/calf boundaries as one connected lower garment field.
let inseam=smooth((y-178)/20)*smooth((225-y)/18); if(x<(body==='neutral'?123:121))sx-=(body==='female'?2:4)*inseam*Math.exp(-Math.pow((x-116)/9,2)); if(x>=(body==='neutral'?123:121))sx+=(body==='female'?2:5)*inseam*Math.exp(-Math.pow((x-127)/9,2));
let legs=smooth((y-180)/30);if(body==='neutral'&&x<124)sx-=3*smooth((y-210)/15)*smooth((275-y)/15)*Math.exp(-Math.pow((x-114)/9,2));if(x<118)sx+=(body==='male'?2:0)*legs*Math.exp(-Math.pow((x-85)/13,2));
if(x>129)sx-=(body==='male'?3:body==='neutral'?1:0)*legs*Math.exp(-Math.pow((x-164)/24,2));if(body==='female') {
 let side=smooth((y-112)/10)*smooth((153-y)/12);
 if(x<90)sx+=2*side*Math.exp(-Math.pow((x-77)/8,2));
 if(x>154)sx-=2*side*Math.exp(-Math.pow((x-160)/9,2));
 if(x>135)sx+=3*smooth((y-275)/15)*Math.exp(-Math.pow((x-148)/10,2));
 if(x<125)sx-=2*smooth((y-205)/10)*smooth((240-y)/12)*Math.exp(-Math.pow((x-114)/8,2));
}
if(body==='neutral'&&x>140)sx-=3*smooth((y-165)/15)*smooth((219-y)/16)*Math.exp(-Math.pow((x-154)/10,2));
if(x>160)sx-=(body==='neutral'?5:2)*smooth((y-280)/15)*Math.exp(-Math.pow((x-183)/13,2));
return [sx,sy];}
for(let y=0;y<320;y++)for(let x=0;x<240;x++){let [sx,sy]=map(x,y),a=Math.floor(sx),b=Math.floor(sy),v=[0,0,0,0];for(let yy=0;yy<2;yy++)for(let xx=0;xx<2;xx++){let X=a+xx,Y=b+yy;if(X<0||X>=240||Y<0||Y>=320)continue;let j=(Y*240+X)*4,w=(xx?sx-a:1-sx+a)*(yy?sy-b:1-sy+b),al=data[j+3]/255;for(let c=0;c<3;c++)v[c]+=data[j+c]*al*w;v[3]+=al*w;}let i=(y*240+x)*4;for(let c=0;c<3;c++)out[i+c]=v[3]?Math.round(v[c]/v[3]):0;out[i+3]=Math.round(v[3]*255);}
const output=`assets/images/questwell/avatar/business_suit_${body}_v1.webp`;
await sharp(out,{raw:{width:240,height:320,channels:4}}).webp({lossless:true}).toFile(output);
let c=await sharp(root+`paper_doll_${body}_${version}.webp`).composite([{input:output},{input:root+`paper_doll_${body}_identity_${version}.webp`}]).png().toBuffer();
for(const [name,color] of [['light','#f4eddf'],['dark','#18252c']]) await sharp(c).flatten({background:color}).resize(720,960).png().toFile(`tool/art_assets/legacy_refit_v1/suit_${body}_${name}.png`);
console.log(output);
}})();
