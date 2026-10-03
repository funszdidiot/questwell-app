"""Register generated modular Scout clothing to fixed avatar landmarks, offline only.

Uses the same inverse thin-plate map as the existing coat export; samples
premultiplied color once at 4x, then exports the normal 240x320 runtime canvas.
"""
import json
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from scipy.interpolate import RBFInterpolator
from scipy.ndimage import map_coordinates

ROOT = Path(__file__).resolve().parents[1]
spec = json.loads((ROOT / (sys.argv[1] if len(sys.argv) > 1 else 'tool/scout_wardrobe_fit.json')).read_text())
width, height = spec['canvas']
scale = 4
for body, fit in spec['assets'].items():
    original = Image.open(ROOT / fit['source']).convert('RGBA')
    mask = Image.new('L', original.size, 0 if 'keep' in fit else 255)
    draw = ImageDraw.Draw(mask)
    for name, value in [('keep', 255), ('cutouts', 0)]:
        for polygon in fit.get(name, []):
            draw.polygon([(x * original.width / width, y * original.height / height) for x, y in polygon], fill=value)
    source = np.array(original, dtype=np.float64)
    source[:, :, 3] *= np.asarray(mask) / 255
    sh, sw = source.shape[:2]
    source[source[:,:,3] < 32] = 0
    source[:,:,:3] *= source[:,:,3:4] / 255
    target = np.array([p['target'] for p in fit['points']], dtype=float) / height
    origin = np.array([p['source'] for p in fit['points']], dtype=float) / height
    mapping = RBFInterpolator(target, origin, kernel='thin_plate_spline', degree=1)
    yy, xx = np.mgrid[:height*scale, :width*scale]
    xy = np.column_stack(((xx.ravel()+.5)/scale/height, (yy.ravel()+.5)/scale/height))
    # Batches keep fitting memory bounded.
    mapped = np.concatenate([mapping(xy[n:n+20000]) for n in range(0,len(xy),20000)])*height
    sx = mapped[:,0].reshape(xx.shape)*sw/width-.5
    sy = mapped[:,1].reshape(yy.shape)*sh/height-.5
    channels = [map_coordinates(source[:,:,i], [sy,sx], order=1, mode='constant', cval=0) for i in range(4)]
    result = np.stack(channels,axis=-1)
    # Reject a reversed patch anywhere the actual body is visible.
    determinant = np.diff(sx,axis=1)[:-1]*np.diff(sy,axis=0)[:,:-1] - np.diff(sy,axis=1)[:-1]*np.diff(sx,axis=0)[:,:-1]
    if np.any((determinant <= 0) & (result[:-1,:-1,3] > 128)):
        raise ValueError(f'{body}: folded body registration')
    result[:,:,:3] = np.divide(result[:,:,:3]*255, result[:,:,3:4], out=np.zeros_like(result[:,:,:3]), where=result[:,:,3:4]>0)
    image = Image.fromarray(np.round(np.clip(result,0,255)).astype('uint8'), 'RGBA')
    image = image.resize((width,height), Image.Resampling.LANCZOS)
    image.save(ROOT / fit['output'], 'WEBP', lossless=True, method=6)
    print(f'Exported {body}: {fit["output"]}', flush=True)
