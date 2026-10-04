// Read-only checks: actual final color/occlusion, not merely opaque thumb pixels.
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),sharp=require('sharp');
const root=path.resolve(__dirname,'..'),read=p=>fs.readFileSync(path.join(root,p));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const ref=JSON.parse(read('tool/male_robe_edge_repair_reference.json'));
const fit=JSON.parse(read(ref.historicalTemplate));
const raw={width:240,height:320,channels:4};
const pixels=p=>sharp(read(p)).ensureAlpha().raw().toBuffer();
const report={classes:{},bodyIdentityEverydayUnchanged:true,allFrontAlphaUnchanged:true};
async function main(){
  for(const e of [ref.body,ref.identity,ref.outfit,...Object.values(fit.layers),ref.source,ref.sleeveRegion,ref.outfitOcclusion])assert.equal(sha(read(e.path)),e.sha256,e.path);
  const region=read(ref.sleeveRegion.path),body=await pixels(ref.body.path),outfit=await pixels(ref.outfit.path);
  const occlusion=await sharp(read(ref.outfitOcclusion.path)).ensureAlpha().raw().toBuffer();
  const cropped=await sharp(read(ref.outfit.path)).composite([{input:read(ref.outfitOcclusion.path),blend:'dest-out'}]).png().toBuffer();
  let commonAlpha;
  for(const [name,c] of Object.entries(ref.classes)){
    for(const e of [c.front,c.previousFront,c.rear,c.collar,c.cuffs])assert.equal(sha(read(e.path)),e.sha256,e.path);
    const before=await pixels(c.previousFront.path),front=await pixels(c.front.path),rear=await pixels(c.rear.path),cuffs=await pixels(c.cuffs.path);
    const alpha=Buffer.alloc(240*320);let changed=0;
    for(let n=0;n<240*320;n++){
      const i=n*4;alpha[n]=front[i+3];assert.equal(front[i+3],before[i+3]);
      if(before[i+3]&&!front.subarray(i,i+3).equals(before.subarray(i,i+3))){
        assert.ok(region[n],`${name} changed outside sleeve region`);changed++;
      }
    }
    assert.ok(changed>500,`${name} sleeve repair missing`);
    assert.equal(sha(alpha),c.front.alphaSha256);
    if(commonAlpha)assert.deepEqual(alpha,commonAlpha);else commonAlpha=alpha;
    const entries={...c,body:ref.body,outfit:ref.outfit,identity:ref.identity};
    const composed=await sharp({create:{...raw,background:'#0000'}}).composite(ref.layerOrder.map(k=>({input:k==='outfit'?cropped:read(entries[k].path)}))).ensureAlpha().raw().toBuffer();
    const nativePath=`tool/art_assets/male_robe_edge_repair_v2/${name}/native_composite.png`;
    assert.equal(sha(read(nativePath)),c.compositeSha256);
    const actual=await pixels(nativePath);
    // Independent sharp destination-out and integer exporter agree within
    // one channel value at antialiased boundaries (their rounding differs).
    for(let i=0;i<actual.length;i++)assert.ok(Math.abs(actual[i]-composed[i])<=1,`${name} depth mismatch ${i}`);
    let handPixels=0;
    for(let y=181;y<=198;y++)for(const [lo,hi] of [[64,83],[156,176]])for(let x=lo;x<=hi;x++){
      const i=(y*240+x)*4;
      if(body[i+3]===255 && !front[i+3]&&!cuffs[i+3] && (!outfit[i+3]||occlusion[i+3]===255)){
        assert.deepEqual(actual.subarray(i,i+4),body.subarray(i,i+4),`${name} original hand changed`);handPixels++;
      }
    }
    assert.ok(handPixels>20,`${name} missing opaque hand checks`);
    // This point was opaque brown trousers in the defective final composite.
    // Verify the original thumb blends with this class's lining, not trousers.
    const i=(190*240+156)*4, a=body[i+3]/255;
    assert.equal(occlusion[i+3],255);assert.ok(outfit[i+3]>250);assert.equal(rear[i+3],255);
    for(let k=0;k<3;k++)assert.ok(Math.abs(actual[i+k]-(body[i+k]*a+rear[i+k]*(1-a)))<=2,`${name} thumb-area cloth color`);
    const sleeve=(145*240+61)*4;
    const luma=b=>.2126*b[sleeve]+.7152*b[sleeve+1]+.0722*b[sleeve+2];
    assert.ok(luma(front)>luma(before)+10,`${name} heavy sleeve edge retained`);
    report.classes[name]={changedSleevePixels:changed,unchangedOpaqueHandPixels:handPixels,thumbColor:[...actual.subarray(i,i+4)],frontAlphaSha256:c.front.alphaSha256};
  }
  console.log(JSON.stringify(report,null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
