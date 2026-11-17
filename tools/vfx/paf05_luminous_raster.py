"""First-party raster luminosity (true RGBA) on hand-directed time-evolving paths.
Brightness material comes from a multiscale turbulent density field, not geometry.
"""
import cv2, math, numpy as np
from PIL import Image,ImageDraw,ImageFilter
from scipy.ndimage import gaussian_filter
TAU=2*math.pi

def bez(a,b,c,d,n=120):
 return [((1-t)**3*a[0]+3*t*(1-t)**2*b[0]+3*t*t*(1-t)*c[0]+t**3*d[0],(1-t)**3*a[1]+3*t*(1-t)**2*b[1]+3*t*t*(1-t)*c[1]+t**3*d[1]) for t in np.linspace(0,1,n)]
def make_canvas(w,paths,t=0.5,mode='hero',seed=735):
 rs=np.random.default_rng(seed)
 y,x=np.indices((w,w),dtype=np.float32)
 norm=lambda z:(z-z.min())/max(.001,z.max()-z.min())
 coarse=norm(gaussian_filter(rs.standard_normal((w,w)).astype('float32'),12))
 med=norm(gaussian_filter(rs.standard_normal((w,w)).astype('float32'),3))
 detail=norm(gaussian_filter(rs.standard_normal((w,w)).astype('float32'),1))
 distmask=np.full((w,w),255,np.uint8)
 line_segs=[]
 for k,(a,b,c,d) in enumerate(paths):
  twist=8*math.sin(t*5.7+k*1.27)
  seq=bez((a[0]+twist*.5,a[1]),(b[0]+twist,b[1]-4*math.cos(t*5+k)),(c[0]-twist*.8,c[1]),(d[0]-twist*.2,d[1]),155)
  pts=[]
  for j,(px,py) in enumerate(seq):
   u=j/(len(seq)-1)
   pts.append((px+5*math.sin(u*15-t*9+k)*math.sin(u*math.pi),py+4*math.cos(u*13+t*7+k)*math.sin(u*math.pi)))
  prog=max(0,min(1,(t+.25-k*.14)*1.75))
  use=pts[:max(2,int(prog*len(pts)))]
  cv2.polylines(distmask,[np.array(use,dtype=np.int32)],False,0,2,lineType=cv2.LINE_AA)
  line_segs.append(use)
 dist=cv2.distanceTransform(distmask,cv2.DIST_L2,5)
 # Variable-width soft body, authentic turbulent tears and feathered emissive edges.
 thickness=(5.5+11.0*coarse)*(1+.28*(med-.5))
 body=np.exp(-((dist/np.maximum(2,thickness))**1.64))
 core=np.exp(-(dist/(1.8+1.35*med))**2)
 halo=np.exp(-((dist/29)**2))* (.60+.40*coarse)
 fall=(.6+.4*coarse)*(.8+.2*detail)
 # Dark gaps within plume remain transparent rather than muddy.
 aa=np.clip((.18*halo + .48*body*fall + .54*core*(.8+.2*detail))*.90,0,.94)
 # Organic inner luma wraps with jade body rather than black-outline vector tubes.
 cold=np.stack((44+70*med,204+37*coarse,180+48*med),axis=-1)
 hot=np.stack((239+12*med,249+6*med,228+25*coarse),axis=-1)
 factor=np.clip(core*.85+.10*body,0,1)
 rgb=cold*(1-factor[...,None])+hot*factor[...,None]
 # Specific moving white and amber caustic packets physically advect along the ridges.
 gold=np.zeros((w,w),dtype='float32');sp=np.zeros_like(gold)
 for k,pts in enumerate(line_segs):
  for j in range(3):
   u=(t*(.87+.10*(k%3))+j*.27+k*.17)%1
   idx=int(u*(len(pts)-1));cx,cy=pts[idx]
   d2=(x-cx)**2+(y-cy)**2
   gold=np.maximum(gold,np.exp(-d2/(2*(3.0+(j%2))**2))*(.9 if j%2==0 else .60))
   sp=np.maximum(sp,np.exp(-d2/(2*(9.0+(j%2)*3)**2))*.40)
 rgb=rgb*(1-gold[...,None]) + np.array([255,223,133],dtype='float32')*gold[...,None]
 aa=np.clip(aa+.33*gold+.10*sp,0,.97)
 # Additional swirls in a separate soft edge layer, avoiding overall zoom and rotation.
 out=np.dstack((rgb.astype(np.uint8),np.uint8(np.round(aa*255))))
 return Image.fromarray(out,'RGBA')

def hero(t,w=480):
 paths=[
 ((90,378),(35,280),(106,110),(292,97)),
 ((318,99),(430,120),(436,293),(335,370)),
 ((131,363),(227,389),(367,313),(395,231)),
 ((97,263),(164,325),(243,250),(270,181)),
 ((363,174),(263,105),(194,186),(158,254)),
 ]
 return make_canvas(w,paths,t,seed=601)

def charge(t,w=320):
 paths=[
 ((49,248),(93,207),(121,163),(170,161)),
 ((268,236),(219,191),(208,145),(165,162)),
 ((189,68),(221,106),(198,152),(167,162)),
 ]
 return make_canvas(w,paths,t,seed=603)

def contact(t,w=256):
 paths=[
 ((35,182),(63,124),(129,107),(178,51)),
 ((187,52),(162,117),(209,162),(230,186)),
 ((69,206),(133,184),(188,209),(204,178)),
 ]
 return make_canvas(w,paths,t,seed=611)

def field(t,w=512):
 # ground view: render in 512 square with vertical squeeze at scene rect.
 paths=[]
 for k in range(6):
  a=(-2.8+k*.89)
  b=(a+.85)
  r=188
  a0=(w/2+r*math.cos(a),w/2+r*math.sin(a)*.55)
  a1=(w/2+r*math.cos(b),w/2+r*math.sin(b)*.55)
  paths.append((a0,(w/2+(r+36)*math.cos(a+.27),w/2+(r+36)*math.sin(a+.27)*.55),(w/2+(r-12)*math.cos(b-.19),w/2+(r-12)*math.sin(b-.19)*.55),a1))
 return make_canvas(w,paths,t,seed=630)
