"""Authorized direct raster garment correction. Never writes body files.

Paint continuous inner sleeve contours and remove excess underarm cloth from a
single registered overlay. Samples existing wool tone/texture as the paint
palette; no sleeve image is independently scaled, shifted, or composited.
"""
from pathlib import Path
import json, hashlib
import numpy as np
from PIL import Image
from scipy.interpolate import PchipInterpolator
from scipy.ndimage import map_coordinates, binary_dilation

ROOT=Path('assets/images/questwell/avatar')
OUT=Path('tool/art_assets/coat_raster_v8'); OUT.mkdir(exist_ok=True)
S=6
# (y, inner sleeve edge, torso edge) along each intentional underarm air space.
CONTOURS={
 'female': {
  'left':[(119,96,96),(125,96,97),(135,94,98),(145,91,94),(153,87.5,89),(160,85,85),(168,83,83)],
  'right':[(119,140,140),(125,140,139),(135,142,137),(145,144.5,142),(155,150,149),(164,155,152),(170,157,154)]},
 'male': {
  'left':[(110,95,95),(116,95,95),(125,94,97),(135,90,98),(145,89,97),(153,85,93),(160,82,86),(169,80,85)],
  'right':[(110,145,145),(116,145,145),(125,146,145),(135,149.5,147),(145,151,147),(153,155,151),(160,160,157),(165,162,159),(168,162,159),(171,161,160),(174,160,160)]},
 'neutral': {
  'left':[(113,99,99),(119,99.5,99.5),(125,98.8,100),(135,96.5,99),(145,95,98),(155,92,95),(165,87,91),(172,85,89),(176,85,87),(180,84,84)],
  'right':[(108,143,143),(122,143,143),(127,147,145),(135,150,147),(145,151,148),(155,154,151),(165,159,155),(172,161,159),(177,161,159),(180,160,160)]}}

def rgba(path):return np.array(Image.open(path).convert('RGBA'))
def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def curve(points, col):return PchipInterpolator([p[0] for p in points],[p[col] for p in points])

records=[]
for body in ['female','male','neutral']:
 original=rgba(ROOT/f'harvest_coat_{body}_v6.webp')
 front=np.array(Image.fromarray(original).resize((240*S,320*S),Image.Resampling.BICUBIC)).astype(float)
 unaltered=front.copy()
 if body=='female':
  # One smooth displacement field through the complete sleeve-to-cuff region.
  # Keep the original connected wool folds and curved cuff painting together.
  ys,xs=np.mgrid[0:320*S,0:240*S].astype(float);y=ys/S;x=xs/S
  t=np.clip((y-130)/37,0,1);ease=t*t*(3-2*t)
  left_limit=np.interp(y,[0,130,145,155,165,175,320],[96,96,92,88,86,85,85])
  right_limit=np.interp(y,[0,130,145,155,165,175,320],[140,140,145,150,155,156,156])
  left=(x<left_limit)&(y<175);right=(x>right_limit)&(y<175)
  dx=np.where(left,4.8*ease,np.where(right,1.0*ease,0))
  dy=np.where(left|right,1.5*ease,0)
  for c in range(4):front[:,:,c]=map_coordinates(unaltered[:,:,c],[ys-dy*S,xs-dx*S],order=1,mode='constant')
 src=front.copy()
 for side,pts in CONTOURS[body].items():
  edge,torso=curve(pts,1),curve(pts,2)
  sign=1 if side=='left' else -1
  for yy in range(int(pts[0][0]*S),int(pts[-1][0]*S)):
   y=yy/S;e=float(edge(y));t=float(torso(y))
   # Coherent inner sleeve paint: broad 8px working region, feathering only
   # within existing wool; the outside contour has a crisp antialiased edge.
   for xx in range(int((e-11)*S),int((e+11)*S)):
    x=xx/S;d=(e-x)*sign
    if -0.5<=d<=8 and y<({'female':166,'male':168,'neutral':170}[body]):
     sx=e-sign*(max(d,0)+3.8)
     rgb=np.array([np.interp(sx*S,np.arange(240*S),src[yy,:,c]) for c in range(3)])
     # Use only adjacent red wool, never a pocket, skin, trim or transparency.
     if not (rgb[0]>rgb[1]*1.35 and rgb[0]>rgb[2]*1.12):continue
     shade=.62+.38*(1-np.exp(-max(d,0)/1.2))
     paint=rgb*shade
     weight=np.clip((8-d)/4,0,1)*np.clip((y-pts[0][0])/8,0,1)
     front[yy,xx,:3]=paint*weight+src[yy,xx,:3]*(1-weight)
     front[yy,xx,3]=255*np.clip(d*S+.5,0,1)
   # Remove the old compensating bridge, with its old dark seam, only in the
   # authored gap between sleeve and torso. Primary body is never masked.
   lo,hi=sorted((e,t))
   if hi>lo:
    for xx in range(int(lo*S),int(hi*S)+1):
     x=xx/S;inside=min(x-lo,hi-x)*S
     if inside>0:front[yy,xx,3]*=1-np.clip(inside,0,1)
 if body=='female':
  # Continuous sleeve ends with a curved front hem. No skin window above a
  # crossing rim: the wrist emerges beneath the cloth, with cavity behind it.
  for cx,rx in [(76.5,8.0),(163.5,7.4)]:
   wool_row=front[164*S-1].copy()
   for yy in range(165*S,175*S):
    y=yy/S
    for xx in range(int((cx-rx-2)*S),int((cx+rx+2)*S)):
     x=xx/S;local_rx=rx-.8*np.clip((169-y)/4,0,1);u=(x-cx)/local_rx
     if abs(u)>1:
      front[yy,xx,3]=0;continue
     hem=169.6+2.4*np.sqrt(max(0,1-u*u))
     if y>hem:
      front[yy,xx,3]=0;continue
     row=wool_row
     valid=np.flatnonzero((row[:,0]>row[:,1]*1.5)&(row[:,0]>80)&(row[:,3]>240)&(abs(np.arange(240*S)/S-cx)<rx))
     sx=valid[np.argmin(abs(valid/S-x))]
     color=row[sx,:3].copy()*(1-.012*(y-165))
     if hem-y<1.0:
      light=.85+.15*(1-abs(u))
      color=np.array([218,171,83])*light
     elif hem-y<1.4:color=np.array([74,36,23])
     front[yy,xx,:3]=color;front[yy,xx,3]=255
 changed=np.any(np.abs(front-unaltered)>0.5,axis=2)
 scope=np.array(Image.fromarray(changed.astype('uint8')*255).resize((240,320),Image.Resampling.BOX))>0
 scope=binary_dilation(scope,iterations=2)
 image=Image.fromarray(np.uint8(np.clip(front,0,255))).resize((240,320),Image.Resampling.LANCZOS)
 front=np.array(image);front[~scope]=original[~scope]
 if body=='female':
  # Preserve the original lower side panels wherever cuff work meets them.
  # They remain behind the unchanged foreground hands.
  for y in range(160,180):
   for anchor,direction in [(100,-1),(140,1)]:
    edge=anchor
    while 0<=edge+direction<240 and original[y,edge+direction,3]>128:edge+=direction
    lo,hi=sorted((edge,anchor))
    for x in range(lo,hi+1):
     if front[y,x,3]<original[y,x,3]:front[y,x]=original[y,x]
 # Restore solid cloth opacity over the foundation along the repaired seams.
 # Source alpha was partially transparent here, allowing the fixed undershirt
 # to bleed through even when skin-only coverage tests passed.
 body_version={'female':'v1','male':'v3','neutral':'v4'}[body]
 foundation=rgba(ROOT/f'base/paper_doll_{body}_{body_version}.webp')
 yy,xx=np.mgrid[:320,:240]
 region=(yy>=({'female':125,'male':108,'neutral':108}[body]))&(yy<165)&(((xx>58)&(xx<103))|((xx>136)&(xx<183)))
 solid=region&(foundation[:,:,3]>240)&(foundation[:,:,0]>100)&(front[:,:,3]>64)&(front[:,:,0]>front[:,:,1]*1.2)
 front[solid,3]=255
 image=Image.fromarray(front)
 path=ROOT/f'harvest_coat_{body}_v8.webp';image.save(path,lossless=True)
 # Rear cuff cavities stay behind the complete body; female registration
 # follows the corrected wrist-centered cuff.
 rear=rgba(ROOT/f'harvest_coat_rear_{body}_v6.webp')
 if body=='female':
  shifted=np.zeros_like(rear)
  shifted[:,:120]=np.roll(np.roll(rear,5,axis=1),2,axis=0)[:,:120]
  shifted[:,120:]=np.roll(np.roll(rear,1,axis=1),2,axis=0)[:,120:]
  rear=shifted
 rearpath=ROOT/f'harvest_coat_rear_{body}_v8.webp';Image.fromarray(rear).save(rearpath,lossless=True)
 v={'female':'v1','male':'v3','neutral':'v4'}[body]
 base=Image.open(ROOT/f'base/paper_doll_{body}_{v}.webp').convert('RGBA')
 comp=Image.alpha_composite(Image.fromarray(rear),base)
 garmentpaths=[ROOT/'everyday_outfit_male_v2.webp'] if body=='male' else [ROOT/(f'scout_{p}_female_v6.webp' if body=='female' else f'everyday_{p}_neutral_v3.webp') for p in ['boots','trousers','top']]
 for p in garmentpaths:
  a=rgba(p);a[:150,:,3]=0;comp=Image.alpha_composite(comp,Image.fromarray(a))
 comp=Image.alpha_composite(comp,image)
 hand=np.array(base);mask=np.zeros((320,240),bool)
 regions={'female':[(66,173,85,193),(156,173,174,193)],'male':[(58,175,85,201),(155,175,183,201)],'neutral':[(67,175,88,201),(156,175,178,201)]}[body]
 for l,t,r,b in regions:mask[t:b,l:r]=True
 hand[~mask,3]=0;comp=Image.alpha_composite(comp,Image.fromarray(hand))
 identity=rgba(ROOT/f'base/paper_doll_{body}_identity_{v}.webp')
 if body=='neutral':identity[74:,108:140,3]=0
 comp=Image.alpha_composite(comp,Image.fromarray(identity))
 for name,color in [('light','#eee5d7'),('dark','#252b3b')]:
  out=Image.alpha_composite(Image.new('RGBA',(240,320),color),comp)
  out.save(OUT/f'{body}_{name}.png');out.resize((720,960),Image.Resampling.LANCZOS).save(OUT/f'{body}_{name}_3x.png')
 records.append({'body':body,'source':str(ROOT/f'harvest_coat_{body}_v6.webp'),'source_sha256':digest(ROOT/f'harvest_coat_{body}_v6.webp'),'contours':CONTOURS[body],'runtime':[{'path':str(p),'sha256':digest(p)} for p in [path,rearpath]]})
(OUT/'record.json').write_text(json.dumps({'status':'BUILDING','method':'founder_authorized_direct_raster_edit','records':records},indent=2)+'\n')
