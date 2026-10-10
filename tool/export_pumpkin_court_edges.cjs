// Register the imagegen edge cleanup into the existing immutable garment masks.
// Requires ImageMagick 6.9.12-98; no app or npm dependencies are introduced.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const { createHash } = require('node:crypto');
const root = path.resolve(__dirname, '..');
const art = path.join(root, 'tool/art_assets/pumpkin_court_edges_v3');
const dest = path.join(root, 'assets/images/questwell/avatar/halloween_v1/pumpkin_court/male');
const raw = (file, extra = []) => execFileSync('convert', [file, ...extra, '-depth', '8', 'rgba:-'], {maxBuffer: 32 * 1024 * 1024});
const hash = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const version = execFileSync('convert', ['-version'], {encoding:'utf8'}).split('\n')[0];
assert(version.includes('ImageMagick 6.9.12-98'), 'Use the pinned export version');
const source = raw(path.join(art, 'edited_source.png'), ['-filter', 'Lanczos', '-resize', '240x320!']);
assert.equal(source.length, 240 * 320 * 4);
const index = (x, y) => (y * 240 + x) * 4;
const locked = JSON.parse(fs.readFileSync(path.join(root, 'tool/art_assets/halloween_costumes_v1/locked_inputs.json'))).male;
for (const [file, sha] of Object.entries(locked.source_sha256)) assert.equal(hash(path.join(root,file)), sha);
const outputs = {};
for (const part of ['front','rear']) {
  const input = path.join(dest, part === 'front' ? 'front_v2.webp' : 'rear.webp');
  const before = raw(input);
  const after = Buffer.from(before);
  const mask = Buffer.alloc(before.length);
  const bottom = Array.from({length:240}, (_,x) => {
    for (let y=319;y>=0;y--) if (before[index(x,y)+3] > 32) return y;
    return -1;
  });
  const top = Array.from({length:240}, (_,x) => {
    for (let y=0;y<320;y++) if (before[index(x,y)+3] > 32) return y;
    return 320;
  });
  const bounds = Array.from({length:320}, (_,y) => {
    const xs = Array.from({length:240},(_,x)=>x).filter(x=>before[index(x,y)+3]>32);
    return [xs[0] ?? 0,xs.at(-1) ?? 239];
  });
  let changed = 0;
  for (let y = 0; y < 320; y++) for (let x = 0; x < 240; x++) {
    const i = index(x,y);
    if (!before[i+3]) continue;
    const shoulder = y >= 77 && y <= 151 && (x < 96 || x > 145) &&
      (x <= bounds[y][0]+7 || x >= bounds[y][1]-7 || y <= top[x]+7);
    const hem = y >= 254 && y <= 282 && y >= bottom[x]-4;
    if (!(part === 'front' ? shoulder || hem : y >= 262 && y <= 274)) continue;
    const edge = [[x-1,y],[x+1,y],[x,y-1],[x,y+1]].some(([a,b]) => a < 0 || a >= 240 || b < 0 || b >= 320 || before[index(a,b)+3] < 32);
    const [r,g,b] = before.subarray(i,i+3);
    if (part === 'rear' && !(r < 38 && g < 47 && b < 38)) continue;
    // Only sample matching fabric, never the edited full character or backdrop.
    // A nearby source sample handles subpixel registration at silhouette edges.
    let best = null;
    let distance = Infinity;
    const radius = hem ? 12 : 6;
    for (let dy = -radius; dy <= radius; dy++) for (let dx = -radius; dx <= radius; dx++) {
      const xx = x+dx, yy = y+dy;
      if (xx < 0 || xx >= 240 || yy < 0 || yy >= 320) continue;
      const j = index(xx,yy);
      const [sr,sg,sb] = source.subarray(j,j+3);
      const cloth = part === 'front' ? sr > (hem ? 165 : 120) && sg > (hem ? 95 : 35) && sr > sg * 1.4 && sg > sb * 1.4 : sg > sr * 1.08 && sg > sb * 1.05 && sg < 85;
      const d = dx*dx+dy*dy;
      if (cloth && d < distance) { best = j; distance = d; }
    }
    assert.notEqual(best, null, `No fabric sample for ${part} ${x},${y}`);
    for (let channel=0;channel<3;channel++) after[i+channel] = Math.round(source[best+channel] * (edge ? 0.48 : 1));
    mask[i] = 255; mask[i+3] = 255;
    changed++;
  }
  assert(changed > 0, `No ${part} edge repair applied`);
  const file = path.join(dest, `${part}_v3.webp`);
  execFileSync('convert', ['-size','240x320','-depth','8','rgba:-','-define','webp:lossless=true',file], {input: after});
  const decoded = raw(file);
  for (let i = 0; i < before.length; i += 4) {
    assert.equal(decoded[i+3], before[i+3], `${part} alpha changed at ${i/4}`);
    if (before[i+3] && !mask[i+3]) assert.deepEqual(decoded.subarray(i,i+3), before.subarray(i,i+3), `${part} unselected RGB changed`);
  }
  execFileSync('convert', ['-size','240x320','-depth','8','rgba:-',path.join(art,`${part}_change_mask.png`)], {input:mask});
  outputs[part] = {path:path.relative(root,file), sha256:hash(file), inputSha256:hash(input), changedPixels:changed, alphaUnchanged:true, unselectedVisibleRgbUnchanged:true};
}
const layers = ['rear_v3.webp',path.join(root,locked.body),'underlay.webp','front_v3.webp',path.join(root,locked.identity),'collar_v2.webp','cuffs_v2.webp','mask.webp'].map(file=>path.isAbsolute(file)?file:path.join(dest,file));
// Review the real layers, not the generated full-figure source.
for (const [label,bg] of [['light','#f2e9db'],['dark','#202a2b']]) {
  for (const scale of [1,3]) {
    const args = ['-size',`${240*scale}x${320*scale}`,`xc:${bg}`];
    for (const layer of layers) args.push('(',layer,'-filter','Cubic','-resize',`${240*scale}x${320*scale}!`,')','-compose','Over','-composite');
    args.push(path.join(art,`${label}_${scale === 1 ? 'native' : 'enlarged'}.png`));
    execFileSync('convert', args);
  }
}
fs.writeFileSync(path.join(art,'exports.json'),JSON.stringify({version,sourceSha256:hash(path.join(art,'edited_source.png')),bodySha256:hash(path.join(root,locked.body)),identitySha256:hash(path.join(root,locked.identity)),outputs},null,2)+'\n');
console.log(JSON.stringify(outputs,null,2));
