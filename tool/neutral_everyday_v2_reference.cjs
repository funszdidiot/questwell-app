// References for garment-only edits; never writes a locked avatar asset.
const fs=require('node:fs');
const path=require('node:path');
const sharp=require('sharp');
const root=path.resolve(__dirname,'..');
const a=path.join(root,'assets/images/questwell/avatar');
const out=path.join(__dirname,'art_assets/neutral_everyday_v2');
async function main(){
  fs.mkdirSync(out,{recursive:true});
  const blank={create:{width:240,height:320,channels:4,background:{r:0,g:0,b:0,alpha:0}}};
  const clothes=await sharp(blank).composite(['everyday_top_neutral_v1.webp','everyday_trousers_neutral_v1.webp','everyday_boots_neutral_v1.webp'].map(f=>({input:path.join(a,f)}))).png().toBuffer();
  await sharp(clothes).resize(960,1280).png().toFile(path.join(out,'garment_edit_reference.png'));
  const female=await sharp(blank).composite(['scout_trousers_female_v6.webp','scout_top_female_v6.webp','scout_boots_female_v6.webp'].map(f=>({input:path.join(a,f)}))).png().toBuffer();
  await sharp(female).resize(960,1280).png().toFile(path.join(out,'female_garment_style_reference.png'));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
