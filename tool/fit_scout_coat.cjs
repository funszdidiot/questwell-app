// Offline garment export. Requires Node and ImageMagick, never runs in the app.
// Clean source art is fitted through measured landmarks. No silhouette masks,
// anatomy cutouts, or runtime scaling are used.
const fs = require('node:fs');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const root = path.resolve(__dirname, '..');
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'scout_fit_anchors.json')));
const [width, height] = manifest.canvas;
const scale = 4;

function command(name, args, input) {
  const result = spawnSync(name, args, {input, maxBuffer: 64 * 1024 * 1024});
  if (result.status !== 0) throw new Error(`${name}: ${result.stderr}`);
  return result.stdout;
}

function area(a, b, c) {
  return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]);
}

for (const [body, spec] of Object.entries(manifest.bodies)) {
  const source = path.join(root, spec.source);
  const [sw, sh] = command('identify', ['-format', '%w %h', source]).toString().split(' ').map(Number);
  const input = command('convert', [source, '-depth', '8', 'rgba:-']);
  const dw = width * scale, dh = height * scale;
  const output = Buffer.alloc(dw * dh * 4);

  function sample(x, y, offset) {
    x = x * sw / width - .5;
    y = y * sh / height - .5;
    const x0 = Math.floor(x), y0 = Math.floor(y);
    const fx = x - x0, fy = y - y0;
    let alpha = 0, red = 0, green = 0, blue = 0;
    for (let j = 0; j < 2; j++) for (let i = 0; i < 2; i++) {
      const px = x0 + i, py = y0 + j;
      if (px < 0 || py < 0 || px >= sw || py >= sh) continue;
      const q = (py * sw + px) * 4;
      // Remove imperceptible source specks; keep visible antialiased contours.
      const a = input[q + 3] < 10 ? 0 : input[q + 3] / 255;
      const weight = (i ? fx : 1 - fx) * (j ? fy : 1 - fy) * a;
      alpha += weight;
      red += input[q] * weight;
      green += input[q + 1] * weight;
      blue += input[q + 2] * weight;
    }
    if (alpha > 0) {
      output[offset] = Math.round(red / alpha);
      output[offset + 1] = Math.round(green / alpha);
      output[offset + 2] = Math.round(blue / alpha);
      output[offset + 3] = Math.round(alpha * 255);
    }
  }

  for (const triangle of spec.triangles) {
    const points = triangle.map(i => spec.points[i]);
    const s = points.map(p => p.source), t = points.map(p => p.target);
    const determinant = area(...t);
    if (area(...s) * determinant <= 0) throw new Error(`${body}: folded fit mesh at ${triangle}`);
    const x0 = Math.max(0, Math.floor(Math.min(...t.map(p => p[0])) * scale));
    const x1 = Math.min(dw - 1, Math.ceil(Math.max(...t.map(p => p[0])) * scale));
    const y0 = Math.max(0, Math.floor(Math.min(...t.map(p => p[1])) * scale));
    const y1 = Math.min(dh - 1, Math.ceil(Math.max(...t.map(p => p[1])) * scale));
    for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) {
      const p = [(x + .5) / scale, (y + .5) / scale];
      const u = area(p, t[1], t[2]) / determinant;
      const v = area(t[0], p, t[2]) / determinant;
      const w = 1 - u - v;
      if (u < -1e-7 || v < -1e-7 || w < -1e-7) continue;
      sample(u * s[0][0] + v * s[1][0] + w * s[2][0],
             u * s[0][1] + v * s[1][1] + w * s[2][1], (y * dw + x) * 4);
    }
  }
  command('convert', ['-size', `${dw}x${dh}`, '-depth', '8', 'rgba:-',
    '-filter', 'Lanczos', '-resize', `${width}x${height}`, '-define', 'webp:lossless=true',
    path.join(root, spec.output)], output);
  console.log(`Exported clean ${body} Scout coat on ${width} x ${height} canvas`);
}
