"""Export a male Pumpkin Court surface repair into exact locked robe masks.

Unlike the v1 whole-row silhouette fit, embroidery is registered to explicit
continuous lapel landmarks. Sleeve width can no longer bend both lapels.
This script never regenerates, scales, masks, or writes a body asset.
"""
from pathlib import Path
import hashlib
import json
import numpy as np
from PIL import Image
from scipy.ndimage import distance_transform_edt, map_coordinates

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'tool/art_assets/male_pumpkin_court_fit_v2'
DEST = ROOT / 'assets/images/questwell/avatar/halloween_v1/pumpkin_court/male'


def load(path):
    return Image.open(path).convert('RGBA')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def registered_rgb():
    source = np.array(load(ART/'surface_source.png').resize((240, 320), Image.Resampling.LANCZOS))
    _, nearest = distance_transform_edt(source[:, :, 3] < 128, return_indices=True)
    rgb = source[nearest[0], nearest[1], :3]
    # Target coordinates are from locked male v3/v4 cloth; source coordinates
    # are measured on the independently generated male-specific surface.
    ys = np.array([0, 77, 85, 105, 125, 145, 165, 185, 210, 240, 270, 279, 319])
    source_y = np.array([0, 72, 80, 99, 120, 141, 161, 181, 206, 237, 266, 275, 319])
    target_outer = np.array([99, 99, 94, 94, 94, 93, 89, 85, 80, 75, 76, 79, 79])
    target_inner = np.array([106, 106, 109, 111, 112, 112, 110, 108, 104, 101, 100, 99, 99])
    source_outer = np.array([110, 110, 102, 98, 98, 98, 94, 90, 85, 79, 74, 74, 74])
    source_inner = np.array([113, 113, 114, 114, 113, 112, 110, 108, 106, 102, 99, 99, 99])
    all_y = np.arange(320)
    sy = np.interp(all_y, ys, source_y)
    to = np.interp(all_y, ys, target_outer)
    ti = np.interp(all_y, ys, target_inner)
    so = np.interp(all_y, ys, source_outer)
    si = np.interp(all_y, ys, source_inner)
    sx = np.empty((320, 240))
    # Lapel edges are independent of the sleeve/cuff silhouette. Both sides
    # share a continuous, centered shirt map, avoiding row-width drift.
    for y in range(320):
        tx = [0, to[y], ti[y], 120.5, 241-ti[y], 241-to[y], 239]
        src = [0, so[y], si[y], 123.5, 247-si[y], 247-so[y], 239]
        sx[y] = np.interp(np.arange(240), tx, src)
    sy = np.broadcast_to(sy[:, None], (320, 240))
    return np.stack([map_coordinates(rgb[:, :, c].astype(float), [sy, sx], order=1, mode='nearest') for c in range(3)], axis=-1).astype('uint8')


def main():
    locked = json.loads((ROOT/'tool/art_assets/halloween_costumes_v1/locked_inputs.json').read_text())['male']
    for path, expected in locked['source_sha256'].items():
        assert sha(ROOT/path) == expected, f'Locked input changed: {path}'
    versioned_outputs = {DEST/f'{part}_v2.webp' for part in ['front', 'collar', 'cuffs']}
    original_files = {str(p.relative_to(ROOT)): sha(p) for p in (ROOT/'assets/images/questwell/avatar').rglob('*.webp') if p not in versioned_outputs}
    rgb = registered_rgb()
    output = {}
    for part in ['front', 'collar', 'cuffs']:
        original = load(DEST/f'{part}.webp')
        pixels = np.array(original)
        pixels[:, :, :3] = rgb
        image = Image.fromarray(pixels)
        path = DEST/f'{part}_v2.webp'
        image.save(path, lossless=True)
        assert load(path).getchannel('A').tobytes() == original.getchannel('A').tobytes()
        output[part] = {'path': str(path.relative_to(ROOT)), 'sha256': sha(path), 'alphaSha256': hashlib.sha256(original.getchannel('A').tobytes()).hexdigest()}
    # Keep the coherent shirt, trousers and boots overlay unchanged for this
    # scoped robe correction; the approved design does not need a new blouse.
    layers = [load(DEST/'rear.webp'), load(ROOT/locked['body']), load(DEST/'underlay.webp'), load(DEST/'front_v2.webp'), load(ROOT/locked['identity']), load(DEST/'collar_v2.webp'), load(DEST/'cuffs_v2.webp'), load(DEST/'mask.webp')]
    composite = Image.new('RGBA', (240, 320))
    for layer in layers:
        composite = Image.alpha_composite(composite, layer)
    composite.save(ART/'native_composite.png')
    for name, color in [('light', '#f2e9db'), ('dark', '#202a2b')]:
        canvas = Image.new('RGBA', (240, 320), color)
        canvas.alpha_composite(composite)
        canvas.convert('RGB').save(ART/f'{name}_native.png')
        canvas.resize((720, 960), Image.Resampling.NEAREST).convert('RGB').save(ART/f'{name}_enlarged.png')
    for path, expected in original_files.items():
        assert sha(ROOT/path) == expected, f'Existing asset changed: {path}'
    (ART/'exports.json').write_text(json.dumps({'status': 'independent_visual_review_pending', 'canvas': [240, 320], 'sourceSha256': sha(ART/'surface_source.png'), 'layers': output, 'existingAssetCount': len(original_files), 'existingAssetsUnchanged': True, 'bodySha256': sha(ROOT/locked['body']), 'identitySha256': sha(ROOT/locked['identity'])}, indent=2)+'\n')
    print(f'Exported 3 versioned robe surface layers; all {len(original_files)} existing avatar assets unchanged; alpha exact.')


if __name__ == '__main__':
    main()
