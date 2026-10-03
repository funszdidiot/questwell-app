"""Export the direct female fitting without any local mesh deformation.

Generated artwork is only separated into renderer passes and registered with
one uniform scale and translation per source. No thin-plate fit is used.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'tool/art_assets/scout_female_v5'
OUT = ROOT / 'assets/images/questwell/avatar'
S = 4

def source(name):
    return Image.open(SRC / f'{name}_source.webp').convert('RGBA').resize((240*S,320*S), Image.Resampling.LANCZOS)

def select(im, polygons, inverse=False):
    mask = Image.new('L', im.size, 255 if inverse else 0)
    draw = ImageDraw.Draw(mask)
    for p in polygons:
        draw.polygon([(x*S,y*S) for x,y in p], fill=0 if inverse else 255)
    out = im.copy()
    out.putalpha(ImageChops.multiply(im.getchannel('A'), mask))
    return out

def register(im, scale=1, dx=0, dy=0):
    if scale != 1:
        im = im.resize((round(im.width*scale),round(im.height*scale)), Image.Resampling.LANCZOS)
    out = Image.new('RGBA',(240*S,320*S))
    out.alpha_composite(im,(round(dx*S),round(dy*S)))
    return out

def save(im, name):
    im.resize((240,320),Image.Resampling.LANCZOS).save(OUT / name, 'WEBP', lossless=True, method=6)
    print(name)

base = source('arms_top')
arms = [
    [(73,103),(97,103),(98,117),(91,138),(81,164),(84,172),(66,172),(64,158),(67,136),(72,117)],
    [(140,104),(158,104),(165,137),(173,160),(172,172),(153,172),(156,165),(145,137)],
]
save(select(base,arms), 'base/clean_arms_female_v2.webp')
top = [[(110,77),(128,77),(134,82),(148,85),(153,93),(156,113),(144,117),(141,130),(145,149),(142,153),(97,153),(94,146),(99,127),(97,114),(80,111),(83,92),(93,85),(105,82)]]
save(select(base,top), 'scout_top_female_v5.webp')
pants = [[(96,150),(149,150),(153,174),(156,194),(240,195),(240,320),(0,320),(0,195),(91,195),(91,175)]]
save(register(select(source('trousers'),pants),.96,4.8,4), 'scout_trousers_female_v5.webp')

robe = source('robe')
rear = [[(110,0),(135,0),(135,135),(139,180),(144,220),(150,260),(156,293),(88,293),(95,260),(99,225),(105,180),(109,137)]]
cuffs = [[(60,153),(84,153),(84,166),(60,166)],[(157,153),(181,153),(181,166),(157,166)]]
for part,im in [('robe',select(robe,rear,True)),('robe_rear',select(robe,rear)),('robe_cuff_front',select(robe,cuffs))]:
    save(register(im,.93,6,18),f'scout_{part}_female_v5.webp')
