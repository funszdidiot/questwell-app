// Offline garment export. Requires Node and ImageMagick, never runs in the app.
// Clean source art is fitted through measured landmarks. No silhouette masks,
// anatomy cutouts, or runtime scaling are used.
const fs = require('node:fs');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const root = path.resolve(__dirname, '..');
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'guardian_fit_anchors.json')));
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

// Solve the inverse thin-plate map from measured body points to source points.
// This keeps first derivatives continuous, so triangle boundaries cannot put
// sharp bends back into the newly smoothed front piping.
function smoothMap(points) {
  const controls = points.map(p => p.target.map(v => v / height));
  const n = controls.length, size = n + 3;
  const matrix = Array.from({length: size}, () => Array(size + 2).fill(0));
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      const dx = controls[i][0] - controls[j][0], dy = controls[i][1] - controls[j][1];
      const r2 = dx * dx + dy * dy;
      matrix[i][j] = r2 > 0 ? .5 * r2 * Math.log(r2) : 0;
    }
    [1, ...controls[i]].forEach((v, j) => { matrix[i][n + j] = v; matrix[n + j][i] = v; });
    matrix[i][size] = points[i].source[0] / height;
    matrix[i][size + 1] = points[i].source[1] / height;
  }
  for (let c = 0; c < size; c++) {
    let pivot = c;
    for (let r = c + 1; r < size; r++) if (Math.abs(matrix[r][c]) > Math.abs(matrix[pivot][c])) pivot = r;
    if (Math.abs(matrix[pivot][c]) < 1e-12) throw new Error('Degenerate smooth fit landmarks');
    [matrix[c], matrix[pivot]] = [matrix[pivot], matrix[c]];
    const divisor = matrix[c][c];
    for (let j = c; j < size + 2; j++) matrix[c][j] /= divisor;
    for (let r = 0; r < size; r++) if (r !== c) {
      const factor = matrix[r][c];
      for (let j = c; j < size + 2; j++) matrix[r][j] -= factor * matrix[c][j];
    }
  }
  const coefficients = matrix.map(row => row.slice(size));
  return {controls, weights: coefficients.slice(0, n), affine: coefficients.slice(n)};
}

for (const [body, spec] of Object.entries(manifest.bodies)) {
  const source = path.join(root, spec.source);
  const [sw, sh] = command('identify', ['-format', '%w %h', source]).toString().split(' ').map(Number);
  const input = command('convert', [source, '-depth', '8', 'rgba:-']);
  const dw = width * scale, dh = height * scale;
  const output = Buffer.alloc(dw * dh * 4);
  const contourRows = spec.contour_fit?.rows;
  // Keep source coordinates, not a second raster texture. The contour pass
  // samples the original master once, avoiding repeated color interpolation.
  const smooth = spec.mapping === 'thin_plate_spline';
  const sourceMap = contourRows || smooth ? new Float32Array(dw * dh * 2) : null;

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

  if (smooth) {
    const {controls, weights, affine} = smoothMap(spec.points);
    for (let y = 0; y < dh; y++) for (let x = 0; x < dw; x++) {
      const px = (x + .5) / scale / height, py = (y + .5) / scale / height;
      let sx = affine[0][0] + affine[1][0] * px + affine[2][0] * py;
      let sy = affine[0][1] + affine[1][1] * px + affine[2][1] * py;
      for (let i = 0; i < controls.length; i++) {
        const dx = px - controls[i][0], dy = py - controls[i][1];
        const r2 = dx * dx + dy * dy;
        const radial = r2 > 0 ? .5 * r2 * Math.log(r2) : 0;
        sx += weights[i][0] * radial;
        sy += weights[i][1] * radial;
      }
      sx *= height; sy *= height;
      sample(sx, sy, (y * dw + x) * 4);
      if (sourceMap) {
        sourceMap[(y * dw + x) * 2] = sx;
        sourceMap[(y * dw + x) * 2 + 1] = sy;
      }
    }
  } else for (const triangle of spec.triangles) {
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
      const sx = u * s[0][0] + v * s[1][0] + w * s[2][0];
      const sy = u * s[0][1] + v * s[1][1] + w * s[2][1];
      sample(sx, sy, (y * dw + x) * 4);
      if (sourceMap) {
        sourceMap[(y * dw + x) * 2] = sx;
        sourceMap[(y * dw + x) * 2 + 1] = sy;
      }
    }
  }

  if (smooth) {
    // Reject a fold anywhere the garment is visible. Contour fitting below
    // preserves row order and uses positive horizontal scale factors.
    for (let y = 0; y < dh - 1; y++) for (let x = 0; x < dw - 1; x++) {
      const p = y * dw + x;
      if (output[p * 4 + 3] < 128) continue;
      const q = p * 2, r = q + 2, b = q + dw * 2;
      const dx = sourceMap[r] - sourceMap[q], dy = sourceMap[r + 1] - sourceMap[q + 1];
      const vx = sourceMap[b] - sourceMap[q], vy = sourceMap[b + 1] - sourceMap[q + 1];
      if (dx * vy - dy * vx <= 0) throw new Error(`${body}: folded smooth fit at ${x / scale},${y / scale}`);
    }
  }

  if (contourRows) {
    for (let y = 0; y < dh; y++) {
      const py = (y + .5) / scale;
      if (py <= contourRows[0].y || py >= contourRows.at(-1).y) continue;
      const index = contourRows.findIndex(row => row.y >= py);
      const before = contourRows[index - 1], after = contourRows[index];
      const t = (py - before.y) / (after.y - before.y);
      const lerp = key => before[key] * (1 - t) + after[key] * t;
      const left = lerp('left'), innerLeft = lerp('inner_left');
      const innerRight = lerp('inner_right'), right = lerp('right');
      const fittedLeft = lerp('fitted_left'), fittedRight = lerp('fitted_right');
      if (!(left < innerLeft && innerLeft < innerRight && innerRight < right &&
            fittedLeft < innerLeft && innerRight < fittedRight)) {
        throw new Error(`${body}: invalid contour ordering at ${py}`);
      }
      for (let x = 0; x < dw; x++) {
        const px = (x + .5) / scale;
        let oldX = px;
        if (px < innerLeft) oldX = innerLeft + (px - innerLeft) * (innerLeft - left) / (innerLeft - fittedLeft);
        if (px > innerRight) oldX = innerRight + (px - innerRight) * (right - innerRight) / (fittedRight - innerRight);
        if (Math.abs(oldX - px) < 1e-8) continue;
        const q = oldX * scale - .5;
        const x0 = Math.floor(q), fx = q - x0;
        const offset = (y * dw + x) * 4;
        output.fill(0, offset, offset + 4);
        if (x0 < 0 || x0 + 1 >= dw) continue;
        const a = (y * dw + x0) * 2, b = a + 2;
        sample(sourceMap[a] * (1 - fx) + sourceMap[b] * fx,
               sourceMap[a + 1] * (1 - fx) + sourceMap[b + 1] * fx, offset);
      }
    }
  }
  command('convert', ['-size', `${dw}x${dh}`, '-depth', '8', 'rgba:-',
    '-filter', 'Lanczos', '-resize', `${width}x${height}`, '-define', 'webp:lossless=true',
    path.join(root, spec.output)], output);
  console.log(`Exported clean ${body} Guardian coat on ${width} x ${height} canvas`);
}
