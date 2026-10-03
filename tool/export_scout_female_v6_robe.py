"""Separate robe garment pixels into rear, front and wrist depth passes.

Front cloth uses the exact on-body source at identity registration. Rear cloth
uses the robe-only source at its established uniform registration. Masks only
divide garment pixels; the fixed avatar's anatomy is never modified.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'tool/art_assets/scout_female_v6'
OUT = ROOT / 'assets/images/questwell/avatar'
S = 4
SIZE = (240*S,320*S)
SCALE, DX, DY = .71, 34.8, 62.7

# Interior of the single continuous back panel, inside the brown front edges.
BACK = [(106.5,24),(135.0,24),(135.8,34),(134.9,48),(134.2,69),
        (134.6,96),(136.2,123),(139.6,157),(143.1,192),(146.6,226),
        (151.9,286),(89.7,286),(91.6,260),(94.0,225),(97.3,190),
        (100.7,157),(103.9,126),(106.4,99),(107.1,69),(107.0,48),
        (104.6,32)]
CUFFS = [
    [(48,146),(50,144.8),(54,144.5),(60,145.5),(64,147),(67,149.5),
     (68,152),(66.5,155),(63,156.5),(58,156.3),(52,155),(48.2,152),(47.5,149)],
    [(174,147),(179,145),(184,144.7),(190,146),(193,149),(192.8,152.6),
     (190,155),(184,156),(178,155),(174,153),(172.8,150)],
]
OPENINGS = [
    [(50,147.8),(54,146.9),(60,147.6),(64.7,149.5),(65.8,152.1),
     (64,154),(59,153.9),(54,152.7),(50.2,150.5)],
    [(176,149),(180,147.4),(185,147),(189,148),(191,150),
     (189.4,152.4),(184,153.5),(179,153),(176,151.7)],
]

FRONT_ON_BODY = [
    [(107.8,79.3),(101.4,80.7),(93.2,82.2),(88.2,84.3),(85.5,89.0),
     (83.6,98.8),(82.0,113),(79.9,124.5),(77.4,130.8),(77.1,135.2),
     (74.8,140.8),(73.4,149.0),(72.3,158.7),(69.6,165.4),(68.9,169.4),
     (70.2,171.4),(73.0,169.5),(76.5,169.4),(80.2,170.2),(83.3,172.2),
     (83.4,166.7),(86.1,157.0),(89.4,148.0),(94.2,137.0),(97.2,127.5),
     (99.1,115.9),(101.0,126.5),(100.7,132.0),(97.2,141.8),(93.2,153.3),
     (89.6,167),(86.2,185),(82.3,207),(78.2,225),(73.5,241.7),
     (66.7,255.7),(69.1,258),(73.4,259.3),(78.8,260.5),(77.7,264),
     (81.4,267.2),(88.2,270),(98.3,271.8),(99.3,247),(101.6,216),
     (104.3,183),(107.3,152),(109.4,130),(109.9,110),(109.3,90)],
    [(134.0,79.3),(142.5,81.1),(149.6,83.2),(153.7,88.0),(155.9,98.0),
     (157.3,112.8),(159.6,127),(161.9,134.1),(162.2,138),(164.6,145.6),
     (166.2,157.4),(171.3,167.4),(172.2,170.5),(171.5,172.2),
     (168.4,170.3),(164.8,169.7),(161.2,170.2),(158.4,172.3),
     (157.9,168.5),(155.1,158.3),(151.4,149.2),(146.9,138.4),(144.1,128.5),
     (142.4,116.2),(140.9,125.2),(141.5,132.8),(145.2,143.3),(149.5,155.2),
     (152.5,169.7),(156.4,190.4),(160.2,210.8),(164.8,227.3),(169.6,241),
     (179.3,252.9),(177.4,255.2),(172.9,257.3),(167.3,260.2),
     (168.1,264),(164.8,267.2),(158.5,269.8),(148.4,271.4),
     (145.8,242),(142.8,211),(139.6,179.8),(136.5,149),(133.7,123),
     (132.1,101),(132.8,87)],
]
FRONT_CUFF_LIPS = [
    [(69.6,166.9),(72.3,166.1),(76,166.5),(80.1,167.6),(83.2,169.4),
     (83.3,172.2),(80.2,170.2),(76.5,169.4),(73,169.5),(70.2,171.4),
     (68.9,169.4)],
    [(158.5,169),(161.4,167.6),(165.1,167),(168.4,167.3),(171.3,168.5),
     (172.2,170.5),(171.5,172.2),(168.4,170.3),(164.8,169.7),
     (161.2,170.2),(158.4,172.3)],
]

def mask(polygons):
    m = Image.new('L',SIZE)
    d = ImageDraw.Draw(m)
    for p in polygons: d.polygon([(round(x*S),round(y*S)) for x,y in p],fill=255)
    return m

def export(source, m, name, *, registered=True):
    image=source.copy()
    image.putalpha(ImageChops.multiply(source.getchannel('A'),m))
    if registered:
        image=image.resize((round(SIZE[0]*SCALE),round(SIZE[1]*SCALE)),Image.Resampling.LANCZOS)
        canvas=Image.new('RGBA',SIZE)
        canvas.alpha_composite(image,(round(DX*S),round(DY*S)))
        image=canvas
    image.resize((240,320),Image.Resampling.LANCZOS).save(OUT/f'scout_{name}_female_v6.webp',lossless=True,method=6)

def main():
    source=Image.open(SRC/'robe_source.webp').convert('RGBA')
    assert source.size==SIZE
    rear=mask([BACK])
    export(source,rear,'robe_rear')
    # Keep only the upper/rear edge of each old opening behind the wrist;
    # lower lips come from the small natural on-body cuff below.
    rear_cuffs=ImageChops.multiply(mask(CUFFS),mask([
        [(48,144),(68,144),(68,150),(48,150)],
        [(173,144),(194,144),(194,149),(173,149)],
    ]))
    export(source,rear_cuffs,'robe_cuff_rear')
    on_body=Image.open(SRC/'robe_on_body_source.webp').convert('RGBA')
    assert on_body.size==SIZE
    lips=mask(FRONT_CUFF_LIPS)
    front=ImageChops.subtract(mask(FRONT_ON_BODY),lips)
    export(on_body,front,'robe',registered=False)
    export(on_body,lips,'robe_cuff_front',registered=False)

    def asset(path): return Image.open(OUT/path).convert('RGBA').resize(SIZE,Image.Resampling.NEAREST)
    base=asset('base/paper_doll_female_v1.webp')
    dressed=base.copy()
    for part in ['trousers','top','boots']: dressed.alpha_composite(asset(f'scout_{part}_female_v6.webp'))
    dressed.alpha_composite(asset('base/paper_doll_female_identity_v1.webp'))
    robe=asset('scout_robe_rear_female_v6.webp')
    robe.alpha_composite(asset('scout_robe_cuff_rear_female_v6.webp'))
    robe.alpha_composite(dressed)
    robe.alpha_composite(asset('scout_robe_female_v6.webp'))
    robe.alpha_composite(asset('base/paper_doll_female_identity_v1.webp'))
    robe.alpha_composite(asset('scout_robe_cuff_front_female_v6.webp'))
    sheet=Image.new('RGBA',(SIZE[0]*3,SIZE[1]),'#1f3937')
    for i,layer in enumerate([base,dressed,robe]):sheet.alpha_composite(layer,(SIZE[0]*i,0))
    sheet.convert('RGB').resize((1440,640),Image.Resampling.LANCZOS).save('/tmp/female-v6-three-stage-qa.png')
    robe.save(SRC/'fixed_robed_reference.png')

if __name__=='__main__': main()
