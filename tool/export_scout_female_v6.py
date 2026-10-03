"""Separate generated artwork into fixed, registered paper-doll render passes.

The underwear body is resolved once and exported as one immutable image.
Clothing never supplies anatomy or changes the body's registration.
Coordinates below use the common 240 x 320 design canvas.
"""
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'tool/art_assets/scout_female_v6'
OUT = ROOT / 'assets/images/questwell/avatar'
S = 4
SIZE = (240 * S, 320 * S)


def read(path):
    return Image.open(path).convert('RGBA').resize(SIZE, Image.Resampling.LANCZOS)


def select(im, polygons, inverse=False):
    mask = Image.new('L', SIZE, 255 if inverse else 0)
    draw = ImageDraw.Draw(mask)
    for p in polygons:
        draw.polygon([(round(x*S), round(y*S)) for x, y in p], fill=0 if inverse else 255)
    out = im.copy()
    out.putalpha(ImageChops.multiply(out.getchannel('A'), mask))
    return out


def save(im, name):
    im.resize((240, 320), Image.Resampling.LANCZOS).save(OUT / name, 'WEBP', lossless=True, method=6)


def export_base():
    original = read(OUT / 'base/base_female.webp')
    generated = read(SRC / 'base_source.webp')
    shapes = json.loads((ROOT / 'tool/clean_base_layers.json').read_text())['female']
    anatomy = select(generated, shapes['anatomy'])
    # Tailor the loose underwear hem once, before freezing the base. Import
    # only the generated air gap between the thighs, and only where the old
    # pixels are charcoal fabric. Skin and limb geometry remain untouched.
    tailored = np.array(read(SRC / 'clothes_coverage_source.webp'))
    aa = np.array(anatomy)
    patch = aa[173*S:191*S,117*S:129*S]
    cloth = (patch[:,:,0] < 160) & (patch[:,:,1] < 130) & (patch[:,:,0].astype(float)-patch[:,:,2] < 40)
    new_alpha = tailored[173*S:191*S,117*S:129*S,3]
    patch[:,:,3] = np.where(cloth, np.minimum(patch[:,:,3], new_alpha), patch[:,:,3])
    anatomy = Image.fromarray(aa)
    # Preserve the existing grip pixels. Only the forearm/hand contact is
    # blended once here; equipping clothes cannot trigger this operation.
    hand_regions = [[(60,171),(85,171),(85,196),(60,196)],
                    [(155,171),(180,171),(180,196),(155,196)]]
    original_hands = select(original, hand_regions)
    a = np.array(anatomy)
    h = np.array(original_hands)
    for left, right in [(0,90),(150,240)]:
        a[174*S:202*S,left*S:right*S,3] = 0
    for left, right in [(0,90),(150,240)]:
        a[171*S:174*S,left*S:right*S,3] = (
            a[171*S:174*S,left*S:right*S,3].astype(float) *
            h[171*S:174*S,left*S:right*S,3] / 255).astype('uint8')
    anatomy = Image.fromarray(a)
    fade = np.clip((np.arange(320*S)/S-171)/3,0,1)
    h[:,:,3] = (h[:,:,3]*fade[:,None]).astype('uint8')
    anatomy.alpha_composite(Image.fromarray(h))
    identity = select(original, [p for p in shapes['identity'] if p[0][1] < 167])
    anatomy.alpha_composite(identity)
    save(anatomy, 'base/paper_doll_female_v1.webp')
    save(identity, 'base/paper_doll_female_identity_v1.webp')
    anatomy.save(SRC / 'fixed_base_reference.png')


if __name__ == '__main__':
    export_base()
