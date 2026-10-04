// Deterministic scoped repair for Neutral Woodland Scout v2 -> v3.
//
// Authority: tool/qa/neutral_woodland_audit_20261004/review.json
// Never alter the locked neutral v4 body or identity. This script edits only
// the garment export and only the two audited fit defects:
//   1) right-hand inner-edge intrusion at x=159..160, y=187..196
//   2) incomplete inner heels near (111,298..300) and (147,300..301)
//
// Output remains a single coherent 240x320 outfit overlay.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');

const root = path.resolve(__dirname, '..');
const input = path.join(root,
  'assets/images/questwell/avatar/woodland_scout_unified_neutral_v2.webp');
const output = path.join(root,
  'assets/images/questwell/avatar/woodland_scout_unified_neutral_v3.webp');

const W = 240, H = 320;
const at = (x,y) => (y * W + x) * 4;

function clearPixel(p, x, y) {
  const i = at(x,y);
  p[i] = p[i+1] = p[i+2] = p[i+3] = 0;
}
function copyPixel(p, sx, sy, dx, dy, alpha = 255) {
  const s = at(sx,sy), d = at(dx,dy);
  p[d] = p[s]; p[d+1] = p[s+1]; p[d+2] = p[s+2];
  p[d+3] = Math.max(p[d+3], alpha);
}

async function main() {
  const meta = await sharp(input).metadata();
  if (meta.width !== W || meta.height !== H) {
    throw new Error(`Expected ${W}x${H}, got ${meta.width}x${meta.height}`);
  }
  const pixels = Buffer.from(await sharp(input).ensureAlpha().raw().toBuffer());

  // Right hand: remove only the audited garment intrusion. Keep surrounding
  // sleeve/trouser contour unchanged and expose the untouched body beneath.
  for (const [x,y] of [
    [159,187],[159,188],[159,189],[159,190],[159,191],[159,192],
    [159,193],[159,194],[160,194],[159,195],[160,195],[160,196]
  ]) clearPixel(pixels,x,y);

  // Inner heels: extend adjacent opaque boot leather into the five audited
  // partially transparent body-overlap pixels. Colors come from immediately
  // neighboring boot pixels so no new style/detail is invented.
  copyPixel(pixels,110,298,111,298);
  copyPixel(pixels,110,299,111,299);
  copyPixel(pixels,110,300,111,300);
  copyPixel(pixels,148,300,147,300);
  copyPixel(pixels,148,301,147,301);

  await sharp(pixels,{raw:{width:W,height:H,channels:4}})
    .webp({lossless:true})
    .toFile(output);
  console.log(output);
}
main().catch(error => { console.error(error); process.exitCode = 1; });
