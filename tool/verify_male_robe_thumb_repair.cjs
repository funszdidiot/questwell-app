// Independent read-only export, continuity and preservation gate.
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const fit=JSON.parse(read('tool/male_robe_fit_reference.json'));
const surfaces=JSON.parse(read('tool/art_assets/male_class_robes_v1/exports.json'));
const repair=JSON.parse(read('tool/male_robe_thumb_repair_reference.json'));
const allowed=(x,y)=>y>=179&&y<=203&&((x>=71&&x<=91)||(x>=149&&x<=169));
async function pixels(p){return sharp(read(p)).ensureAlpha().raw().toBuffer();}
async function main(){
  assert.equal(sha(read(repair.contour.path)),repair.contour.sha256);
  assert.deepEqual(repair.layerOrder,fit.layerOrder);
  for(const e of [fit.body,fit.identity,fit.outfit,...Object.values(fit.layers),
    ...Object.values(surfaces.classes).flatMap(c=>Object.values(c.layers))])assert.equal(sha(read(e.path)),e.sha256,e.path);
  const body=await pixels(fit.body.path);let commonAlpha;
  for(const [name,c] of Object.entries(repair.classes)){
    assert.equal(sha(read(c.rear.path)),c.rear.sha256);
    assert.deepEqual(read(c.rear.path),read(c.rear.sourcePath));
    assert.equal(sha(read(c.previousRear.path)),c.previousRear.sha256);
    const current=await pixels(c.rear.path),old=await pixels(c.previousRear.path),alpha=Buffer.alloc(240*320);
    for(let y=0;y<320;y++)for(let x=0;x<240;x++){
      const i=(y*240+x)*4;alpha[y*240+x]=current[i+3];
      if(!allowed(x,y)) {
        assert.equal(current[i+3],old[i+3],`${name} outside repair alpha`);
        // WebP may canonicalize unused RGB at alpha 0. Visible RGBA is exact;
        // the independent complete-composite check below also covers rendering.
        if(old[i+3])assert.deepEqual(current.subarray(i,i+4),old.subarray(i,i+4),`${name} outside repair visible pixel`);
      }
      assert.ok(current[i+3]>=old[i+3],`${name} existing lining removed`);
    }
    assert.equal(sha(alpha),c.rear.alphaSha256);
    if(commonAlpha)assert.deepEqual(alpha,commonAlpha);else commonAlpha=alpha;
    const foreground=name==='scout'?fit.layers:surfaces.classes[name].layers;
    const entries={...foreground,body:fit.body,outfit:fit.outfit,identity:fit.identity};
    const compose=rear=>sharp({create:{width:240,height:320,channels:4,background:'#0000'}})
      .composite(fit.layerOrder.map(k=>({input:read(k==='rear'?rear:entries[k].path)}))).ensureAlpha().raw().toBuffer();
    const actual=await compose(c.rear.path),before=await compose(c.previousRear.path);
    const reviewed=`tool/art_assets/male_robe_thumb_repair_v1/${name}/native_composite.png`;
    assert.equal(sha(read(reviewed)),c.compositeSha256);assert.deepEqual(actual,await pixels(reviewed));
    for(const h of c.holes)assert.equal(actual[(h.y*240+h.x)*4+3],255,`${name} hole ${h.x},${h.y}`);
    for(let y=0;y<320;y++)for(let x=0;x<240;x++){
      const i=(y*240+x)*4;
      if(!allowed(x,y)||(allowed(x,y)&&body[i+3]===255))assert.deepEqual(actual.subarray(i,i+4),before.subarray(i,i+4),`${name} unrelated or opaque body pixel`);
    }
  }
  console.log('PASS: five matching repaired rear masks, closed thumb gaps, unchanged opaque hands/foreground/anatomy and unrelated geometry.');
}
main().catch(e=>{console.error(e);process.exitCode=1;});
