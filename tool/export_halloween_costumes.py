"""Register generated RGB into unchanged robe alpha; never transform a body.

Sources are independently authored per body. Masks are registered by eye
landmarks. All coordinates belong to the original 240x320 garment canvas.
"""
from pathlib import Path
import hashlib
import json
import numpy as np
from PIL import Image, ImageDraw
from scipy.ndimage import distance_transform_edt, map_coordinates, gaussian_filter1d

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'tool/art_assets/halloween_costumes_v1'
DEST = ROOT / 'assets/images/questwell/avatar/halloween_v1'
BODIES = ('female', 'neutral', 'male')
COSTUMES = ('midnight_masquerade', 'pumpkin_court')
SOURCES_Y = {
    'midnight_masquerade': {'female':[64,130,159,282,310], 'neutral':[56,126,156,275,303], 'male':[59,134,155,267,293]},
    'pumpkin_court': {'female':[80,141,166,284,305], 'neutral':[75,150,178,279,305], 'male':[72,149,173,277,310]},
}
TARGET_Y = {'female':[79,141,173,289,313], 'neutral':[77,156,179,287,314], 'male':[77,156,178,287,312]}
EYES = {'female':[(106.5,55),(125,52)], 'neutral':[(114,55),(132,55)], 'male':[(112,52),(128.5,52)]}

def load(path): return Image.open(path).convert('RGBA')
def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def alpha_sha(im): return hashlib.sha256(im.getchannel('A').tobytes()).hexdigest()

def registered_surface(costume, body, reference):
    source = np.array(load(ART/costume/body/'surface_source.png').resize((240,320),Image.Resampling.LANCZOS))
    # Extend edge RGB into transparent source pixels before sampling. This is
    # color padding only; none of the generated alpha becomes robe geometry.
    _, indices = distance_transform_edt(source[:,:,3]<128, return_indices=True)
    rgb = source[indices[0],indices[1],:3]
    target = np.array(reference)
    yy, xx = np.mgrid[:320,:240].astype(float)
    sy = np.interp(yy[:,0], TARGET_Y[body], SOURCES_Y[costume][body])
    lefts=[]; scales=[]
    # Continuous row-envelope registration for each independently authored fit.
    for y in range(320):
        t = np.flatnonzero(target[y,:,3]>128)
        s = np.flatnonzero(source[int(np.clip(round(sy[y]),0,319)),:,3]>128)
        if len(t)>3 and len(s)>3:
            scale=(s[-1]-s[0])/max(1,t[-1]-t[0])
            lefts.append(s[0]-t[0]*scale); scales.append(scale)
        else:
            lefts.append(lefts[-1] if lefts else 0)
            scales.append(scales[-1] if scales else 1)
    # Sleeve-to-skirt envelope changes cannot introduce horizontal RGB jumps.
    offsets=gaussian_filter1d(np.array(lefts),7)
    widths=gaussian_filter1d(np.array(scales),7)
    sx=offsets[:,None]+xx*widths[:,None]
    sy2 = np.broadcast_to(sy[:,None],(320,240))
    return np.stack([map_coordinates(rgb[:,:,c].astype(float),[sy2,sx],order=1,mode='nearest') for c in range(3)],axis=-1).astype('uint8')

def palette_rear(original,costume):
    a=np.array(original); lum=a[:,:,:3]@np.array([.2126,.7152,.0722])
    color=np.array([.70,.28,.53]) if costume=='midnight_masquerade' else np.array([.35,.48,.28])
    a[:,:,:3]=np.clip(lum[:,:,None]*color,0,255).astype('uint8')
    return Image.fromarray(a)

def fitted_mask(costume,body):
    # Prefilter the high-resolution accessory before its small affine sample;
    # otherwise copper microtexture aliases into disconnected bright pixels.
    source=load(ART/costume/'mask_source_v2.png').resize((192,128),Image.Resampling.LANCZOS)
    # Eye centers measured from the authored mask and immutable foundation.
    left,right=EYES[body]
    scale=(right[0]-left[0])/540
    tilt=(right[1]-left[1])/(right[0]-left[0])
    scale_y=.050
    # Inverse transform: target canvas -> source accessory. Body is untouched.
    a=1/scale; c=500-left[0]/scale
    d=-tilt/scale_y; e=1/scale_y
    f=535-left[1]/scale_y+tilt*left[0]/scale_y
    return source.transform((240,320),Image.Transform.AFFINE,(a/8,0,c/8,d/8,e/8,f/8),Image.Resampling.BICUBIC)

def save(im,path):
    path.parent.mkdir(parents=True,exist_ok=True)
    im.save(path,lossless=True)
    return {'path':str(path.relative_to(ROOT)),'sha256':sha(path),'alphaSha256':alpha_sha(load(path))}

def main():
    inputs=json.loads((ART/'locked_inputs.json').read_text())
    result={'status':'candidate_fit_review_pending','canvas':[240,320],'outfits':{},'fixedAssetsUnchanged':True}
    for body,r in inputs.items():
        for p,expected in r['source_sha256'].items():
            assert sha(ROOT/p)==expected, f'Locked input changed: {p}'
        reference=load(ART/'references'/f'{body}_locked_clothes.png')
        for costume in COSTUMES:
            out=DEST/costume/body
            rgb=registered_surface(costume,body,reference)
            images={}; meta={}
            for part,path in r['layers'].items():
                original=load(ROOT/path)
                a=np.array(original); a[:,:,:3]=rgb
                layer=palette_rear(original,costume) if part=='rear' else Image.fromarray(a)
                meta[part]=save(layer,out/f'{part}.webp')
                assert load(out/f'{part}.webp').getchannel('A').tobytes()==original.getchannel('A').tobytes()
                images[part]=layer
            under=Image.new('RGBA',(240,320))
            for path in r['under']: under=Image.alpha_composite(under,load(ROOT/path))
            under_a=np.array(under)
            # Only replace the shirt's RGB. Existing boot/trouser pixels remain
            # exact, preserving their fitted joins and registration.
            yy,xx=np.mgrid[:320,:240]
            if body!='male':
                top_path=next(p for p in r['under'] if '_top_' in p)
                shirt=np.array(load(ROOT/top_path))[:,:,3]>0
            else:
                # The male underlay is one unified immutable source, so select
                # its torso and pale sleeve cloth rather than split its fit.
                pale=(under_a[:,:,:3].min(axis=2)>100)&(np.ptp(under_a[:,:,:3].astype(int),axis=2)<65)
                shirt=(yy>=78)&((yy<=155)|((yy<185)&pale))&(under_a[:,:,3]>0)
            under_a[shirt,:3]=rgb[shirt]
            under=Image.fromarray(under_a)
            if body=='male':
                # Existing robe-only clothing occlusion; never applied to body.
                import cairosvg, io
                occlusion=Image.open(io.BytesIO(cairosvg.svg2png(url=str(ROOT/'tool/art_assets/male_robe_edge_repair_v2/underrobe_occlusion.svg')))).convert('RGBA')
                a=np.array(under); a[:,:,3]=(a[:,:,3].astype(float)*(1-np.array(occlusion)[:,:,3]/255)).astype('uint8')
                under=Image.fromarray(a)
            images['underlay']=under; meta['underlay']=save(under,out/'underlay.webp')
            mask=fitted_mask(costume,body)
            images['mask']=mask; meta['mask']=save(mask,out/'mask.webp')
            composite=Image.new('RGBA',(240,320))
            order=[images['rear'],load(ROOT/r['body']),under,images['front'],load(ROOT/r['identity'])]
            if 'collar' in images: order.append(images['collar'])
            order += [images['cuffs'],mask]
            for im in order: composite=Image.alpha_composite(composite,im)
            folder=ART/costume/body
            composite.save(folder/'native_composite.png')
            for label,bg in [('light','#f2e9db'),('dark','#202a2b')]:
                canvas=Image.new('RGBA',(240,320),bg); canvas.alpha_composite(composite)
                canvas.resize((480,640),Image.Resampling.NEAREST).convert('RGB').save(folder/f'{label}.png')
            result['outfits'][f'{costume}:{body}']={'layers':meta,'sourceSha256':sha(folder/'surface_source.png'),'maskSourceSha256':sha(ART/costume/'mask_source_v2.png'),'robeAlphaExact':True,'template':r['layers'],'eyes':EYES[body]}
        for p,expected in r['source_sha256'].items(): assert sha(ROOT/p)==expected
    (ART/'exports.json').write_text(json.dumps(result,indent=2)+'\n')
    # Contact sheet is a diagnostic rendering of real exported layers.
    sheet=Image.new('RGB',(1440,1360),'#f2e9db'); draw=ImageDraw.Draw(sheet)
    for row,costume in enumerate(COSTUMES):
        for col,body in enumerate(BODIES):
            draw.text((col*480+20,row*680+12),f'{costume} / {body}',fill='#222222')
            sheet.paste(Image.open(ART/costume/body/'light.png'),(col*480,row*680+32))
    sheet.save(ART/'fitted_review.png')
    print('Exported six candidates. Exact robe alpha and source-body hashes verified; visual QA pending.')

if __name__=='__main__': main()
