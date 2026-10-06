"""Regression checks for the founder-requested inner-arm/cuff repair.

Pixel constraints complement, and never replace, independent visual/runtime QA.
Run from repository root with Pillow and NumPy installed.
"""
import hashlib
import json
from pathlib import Path
import numpy as np
from PIL import Image

ROOT=Path('assets/images/questwell/avatar')
def rgba(path): return np.array(Image.open(path).convert('RGBA'))

report=[]
for body,version in [('female','v1'),('male','v3'),('neutral','v4')]:
    ref=json.loads(Path(f'tool/{body}_avatar_fit_reference.json').read_text())
    for key in (['frozen_body','frozen_head_hair'] if body=='female' else ['base','head_hair']):
        entry=ref[key]
        assert hashlib.sha256(Path(entry['path']).read_bytes()).hexdigest()==entry['sha256']
    base=rgba(ROOT/f'base/paper_doll_{body}_{version}.webp')
    if body=='male':
        identity=rgba(ROOT/f'base/paper_doll_{body}_identity_{version}.webp')
        visible=(base[:74,:,3]>0)|(identity[:74,:,3]>0)
        assert np.array_equal(base[:74][visible],identity[:74][visible]), 'Original head pixels differ'
    old=rgba(ROOT/f'harvest_coat_{body}_v6.webp')
    coat=rgba(ROOT/f'harvest_coat_{body}_v8.webp')
    assert coat.shape==(320,240,4)
    # Only the authorized sleeve, underarm and wrist regions may differ.
    changed=np.any(old!=coat,axis=2)&((old[:,:,3]>0)|(coat[:,:,3]>0))
    yy,xx=np.mgrid[:320,:240]
    scope=(yy>=106)&(yy<=181)&(((xx>=58)&(xx<=104))|((xx>=134)&(xx<=183)))
    assert not np.any(changed&~scope), f'{body}: unrelated artwork changed'
    # White undershirt bleed is as much a failure as skin exposure. These
    # body-specific arm/underarm regions must have solid wool over the body.
    start=125 if body=='female' else 108
    region=(yy>=start)&(yy<165)&(((xx>58)&(xx<103))|((xx>136)&(xx<183)))
    foundation=region&(base[:,:,0]>100)&(base[:,:,3]>240)
    assert np.all(coat[:,:,3][foundation]>=235), f'{body}: foundation leaks through wool'
    # Intentional arm-to-torso air space must survive; do not fill a rectangle
    # or add a compensating wedge to make the coverage assertion pass.
    gaps={'female':[(95,138),(141,137)],'male':[(94,140),(148,143)],'neutral':[(97,143),(149,140)]}[body]
    for x,y in gaps: assert coat[y,x,3]<20, (body,'air gap closed',x,y)
    report.append({'body':body,'changed_pixels':int(changed.sum()),'opaque_foundation_samples':int(foundation.sum()),'status':'PASS'})
Path('tool/art_assets/coat_raster_v8/verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: fixed foundations, scoped repairs, solid wool, intentional air gaps')
