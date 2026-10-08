"""Assemble unchanged, registered source layers for costume surface authoring."""
from pathlib import Path
import json
import hashlib
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'tool/art_assets/halloween_costumes_v1'

def read(path):
    return json.loads((ROOT / path).read_text())

def image(path):
    return Image.open(ROOT / path).convert('RGBA')

def main():
    records = {}
    for body in ('female', 'neutral', 'male'):
        if body == 'female':
            ref = read('tool/female_avatar_fit_reference.json')
            layers = dict(zip(('front', 'cuffs', 'rear'),
                [x['path'] for x in ref['robe_template']['geometry_assets']]))
            base, identity = ref['frozen_body']['path'], ref['frozen_head_hair']['path']
            under = [f'assets/images/questwell/avatar/scout_{p}_female_v6.webp'
                     for p in ('trousers', 'top', 'boots')]
        else:
            ref = read(f'tool/{body}_robe_fit_reference.json')
            layer_ref = (read('tool/male_robe_edge_repair_reference.json')['classes']['scout']
                         if body == 'male' else ref['layers'])
            layers = {k: layer_ref[k]['path'] for k in ('rear', 'front', 'cuffs', 'collar')}
            base, identity = ref['body']['path'], ref['identity']['path']
            under = ([ref['outfit']['path']] if body == 'male'
                     else [ref['everyday'][p]['path'] for p in ('boots', 'trousers', 'top')])
        paths = [base, identity, *under, *layers.values()]
        hashes = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
        cloth = Image.new('RGBA', (240, 320))
        for p in [layers['rear'], *under, layers['front'], layers.get('collar'), layers['cuffs']]:
            if p:
                cloth = Image.alpha_composite(cloth, image(p))
        # Reference only: source coordinates are retained; no artwork is redrawn.
        cloth.save(OUT / 'references' / f'{body}_locked_clothes.png')
        records[body] = dict(body=base, identity=identity, under=under, layers=layers,
                             source_sha256=hashes, canvas=[240,320])
    (OUT / 'locked_inputs.json').write_text(json.dumps(records, indent=2)+'\n')

if __name__ == '__main__':
    main()
