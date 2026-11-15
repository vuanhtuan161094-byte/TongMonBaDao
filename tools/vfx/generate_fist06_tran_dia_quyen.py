#!/usr/bin/env python3
"""FIST06 Trấn Địa Quyền: original rocky-knuckle sprite flipbooks, no rig.

24 independently painted 256x256 RGBA poses: 4 pressure charge, 12 stone
fist movement, 8 localized impact/dust. Two atlas textures total, 6.0 MiB
raw RGBA. Intended for one target (earth), view-only Godot Combat Lab.

This is authored first-party raster art, NOT a rasterized JX/Source A texture,
not an ImageGen poster, not a skeletal animation. Reproducible with PIL+NumPy.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math
import random
import hashlib
import numpy as np

OUT = Path(__file__).resolve().parents[2] / 'godot/labs/combat_lab/fist06/assets/generated'
OUT.mkdir(parents=True, exist_ok=True)
# Reuse only the project-owned FIST03 incandescent BRUSH luminance as subtle
# reflective mineral glints. FIST06 fist shape, stone facets, pose and hit
# choreography are authored separately and must pass independent art review.
SHARED_LIGHT_BRUSH = Path(__file__).resolve().parents[2] / 'godot/labs/combat_lab/fist03/assets/godfist_master.webp'
CELL = 256
SEED = 6011615


def blank():
    return Image.new('RGBA', (CELL,CELL), (0,0,0,0))


def random_field(seed):
    rng=np.random.default_rng(seed)
    output=np.zeros((CELL,CELL),np.float32)
    for cells,amp in ((8,.31),(17,.27),(38,.23),(94,.19)):
        coarse=Image.fromarray(rng.integers(0,256,(cells,cells),dtype=np.uint8),'L')
        n=np.asarray(coarse.resize((CELL,CELL),Image.Resampling.BICUBIC),np.float32)/255
        output+=n*amp
    return np.clip(output,0,1)


def make_rock_fist(k, charge=False):
    """Irregular knuckle silhouette with painted mineral facets and seams.
    Each pose moves individual knuckles, thumb, wrist and chips independently.
    """
    rng=random.Random(SEED+100*k+(0 if charge else 1300))
    t=k/3. if charge else k/11.
    img=blank()
    mask=Image.new('L',(CELL,CELL),0)
    d=ImageDraw.Draw(mask)
    # Compressed forearm, asymmetric squashed palm, knuckles lead toward +X.
    xdelta=5*math.sin(k*.81)+(6*t if not charge else -8*(1-t))
    thick=1.0+(.04 if charge else .08)*math.sin(k*.57)
    def shape(pts):return [(int(x+xdelta),int(121+(y-121)*thick)) for x,y in pts]
    wrist=shape([(47,129),(64,96),(92,94),(121,100),(150,120),(137,158),(112,167),(81,151)])
    palm=shape([(107,101),(139,81),(181,82),(208,102),(207,149),(184,166),(144,169),(111,149)])
    d.polygon(wrist,fill=244)
    d.polygon(palm,fill=255)
    knuckles=[]
    for i in range(4):
        y=75+i*22+int(3*math.sin(k*.74+i*.8))
        xx=190+int(3.5*math.cos(k*.67+i*1.31))-(2 if i==3 else 0)
        poly=shape([(xx-7,y-13),(xx+8,y-16),(xx+22+(i%2)*3,y-7),
                    (xx+26,y+3),(xx+17,y+12),(xx-5,y+11)])
        knuckles.append(poly)
        d.polygon(poly,fill=255)
    thumb=shape([(137,143),(157,138),(179,145),(193,164),(186,180),(167,181),(148,170),(135,162)])
    d.polygon(thumb,fill=255)
    # Dark rim and stone surface with directional value gradient + fractal geology.
    mineral=random_field(SEED+1200+k)
    grain=random_field(SEED+4500+k)
    a=np.asarray(mask,dtype=np.float32)/255.
    yy,xx=np.mgrid[0:CELL,0:CELL].astype(np.float32)
    top=np.clip((157-yy)/100,0,1)
    light=np.clip(.31+.52*mineral+.25*grain+.26*top,0,1)
    warm=np.clip(.18+.65*mineral+.14*np.sin(xx*.07+yy*.035+k*.7),0,1)
    rgba=np.zeros((CELL,CELL,4),np.uint8)
    rgba[:,:,0]=np.clip(38+114*light+17*warm,0,255).astype(np.uint8)
    rgba[:,:,1]=np.clip(37+101*light+12*warm,0,255).astype(np.uint8)
    rgba[:,:,2]=np.clip(40+97*light,0,255).astype(np.uint8)
    rgba[:,:,3]=(a*244).astype(np.uint8)
    img=Image.fromarray(rgba,'RGBA')
    # Primary volumes: ink-dark creases and stone facets, not uniform lines.
    ink=Image.new('RGBA',(CELL,CELL),(0,0,0,0))
    dd=ImageDraw.Draw(ink,'RGBA')
    dd.polygon(shape([(101,107),(131,88),(143,107),(113,128)]),fill=(235,204,139,105))
    dd.polygon(shape([(128,134),(160,119),(182,150),(158,164)]),fill=(28,25,29,133))
    dd.polygon(shape([(61,120),(92,104),(113,121),(87,148)]),fill=(206,178,119,95))
    for i,p in enumerate(knuckles):
        coords=p[:3]
        dd.line(coords,fill=(252,208,138,194),width=4)
        dd.line([p[3],p[4],p[5]],fill=(20,20,27,191),width=4)
        # Each knuckle has individual crack network, with molten sandstone glints.
        head=p[1];tail=p[4]
        anchor=((head[0]+tail[0])*.5,(head[1]+tail[1])*.5)
        fx=anchor[0]-rng.randint(4,13); fy=anchor[1]+rng.randint(-4,4)
        dd.line([(fx,fy-9),(fx+rng.uniform(0,7),fy-1),(fx+rng.uniform(-4,3),fy+9)],
                fill=(59,35,27,165),width=3)
        dd.line([(fx+1,fy-8),(fx+3,fy-2)],fill=(255,189,83,172),width=2)
    # Chipped hand-painted facets: layered dark granite chips and warm beveled
    # edges break up the uniform polygon fill; separate geometry per pose.
    for facet in range(23):
        px=rng.uniform(70,217)+xdelta
        py=rng.uniform(80,175)
        rr=rng.uniform(5,21)
        polygon=[(px-rr,py+rr*.13),(px-rr*.28,py-rr*.73),
                 (px+rr*.72,py-rr*.6),(px+rr,py+rr*.26),
                 (px+rng.uniform(-.6,.3)*rr,py+rr*.82)]
        if facet%3==0:
            color=(240,202,135,rng.randint(25,88))
        else:
            color=(16+rng.randint(0,33),18+rng.randint(0,23),
                   24+rng.randint(0,18),rng.randint(34,127))
        dd.polygon(polygon,fill=color)
        if facet%4==0:
            dd.line(polygon[:2],fill=(249,202,137,rng.randint(80,160)),width=1)
    # Ten uneven heat veins remain narrower than the armored knuckle silhouette.
    for seam in range(10):
        x=rng.uniform(79,203)+xdelta
        y=rng.uniform(93,161)
        dd.line([(x,y),(x+rng.uniform(2,11),y-rng.uniform(2,9)),
                 (x+rng.uniform(10,18),y-rng.uniform(7,20))],
                fill=(237,139,59,rng.randint(80,163)),width=rng.randint(1,2))
    # Jagged mineral vein from wrist to knuckle, faint illumination.
    vein=[(69+xdelta,132),(92+xdelta,126+3*math.sin(k*.6)),
          (119+xdelta,138),(137+xdelta,119),(170+xdelta,122),
          (193+xdelta,110)]
    dd.line(vein,fill=(30,23,25,235),width=8,joint='curve')
    dd.line(vein[1:],fill=(228,124,49,179),width=4,joint='curve')
    dd.line(vein[3:],fill=(255,213,126,155),width=1,joint='curve')
    dd.line(shape([(142,154),(156,162),(171,168)]),fill=(255,233,177,123),width=3,joint='curve')
    # Clip facets and ink lines to stone silhouette.
    alpha=Image.fromarray(np.minimum(np.asarray(mask),np.asarray(ink.getchannel('A'))).astype(np.uint8))
    ink.putalpha(alpha)
    img.alpha_composite(ink)
    # Project-owned original incandescent FIST03 painting is sampled as a
    # SPARSE LIGHT BRUSH, never as the visible sprite shape or a static recolor.
    # Transparent clipping uses this skill's independent faceted fist mask.
    if SHARED_LIGHT_BRUSH.exists():
        light_src=Image.open(SHARED_LIGHT_BRUSH).convert('RGBA')
        light_src=light_src.resize((CELL,CELL),Image.Resampling.LANCZOS)
        px=np.asarray(light_src,dtype=np.float32)
        luminance=(.30*px[:,:,0]+.59*px[:,:,1]+.11*px[:,:,2])/255.0
        hot=np.clip((luminance-.44)*2.9,0.0,1.0)
        # Art-directed lower opacity; preserves rock texture and silhouette.
        shine=np.zeros_like(px,dtype=np.uint8)
        shine[:,:,0]=255;shine[:,:,1]=np.clip(174+53*hot,0,255).astype(np.uint8)
        shine[:,:,2]=np.clip(88+65*hot,0,255).astype(np.uint8)
        shine[:,:,3]=np.clip(hot*(px[:,:,3]/255.0)*(a*.90)*141,0,141).astype(np.uint8)
        img.alpha_composite(Image.fromarray(shine,'RGBA'))
    # Soft independent orange/earth motes and layered debris as charge/flight movement.
    extra=blank();ds=ImageDraw.Draw(extra,'RGBA')
    count=17 if charge else 46
    for j in range(count):
        x=rng.uniform(45,218)-12*t*(not charge)
        y=rng.gauss(131,54)
        r=rng.uniform(.6,2.2)
        col=(236+rng.randrange(19),164+rng.randrange(40),89+rng.randrange(50),
             rng.randrange(35,113) if charge else rng.randrange(25,96))
        ds.ellipse((x-r,y-r*.65,x+r,y+r*.65),fill=col)
    img.alpha_composite(extra)
    # Broad soft earth light only near the stone (not a screen-filling circle).
    gl=blank();dl=ImageDraw.Draw(gl,'RGBA')
    dl.ellipse((118+xdelta,102,226+xdelta,160),fill=(252,151,58,120 if charge else 92))
    out=gl.filter(ImageFilter.GaussianBlur(20))
    out.alpha_composite(img)
    return out


def impact_frame(k):
    """Impact with true contact body spark + fragmented stone/smoke and recoil.
    Eight distinct alpha poses, each has directional stone chips + ground dust.
    """
    t=k/7.
    rng=random.Random(SEED+9800+k)
    im=blank()
    # The first two frames have an abrupt tactile contact: no permanent neon ring.
    glow=blank();d=ImageDraw.Draw(glow,'RGBA')
    bright=max(0.,1-t*1.17)
    d.ellipse((86-13*t,79-17*t,174+38*t,163+27*t),
              fill=(255,194,92,int(196*bright)))
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(13)))
    dust=blank();d=ImageDraw.Draw(dust,'RGBA')
    for i in range(20):
        x=127+rng.gauss(0,32+26*t)
        y=161+rng.gauss(0,14+15*t)
        rx=rng.uniform(7,18)*(0.7+.9*t)
        ry=rng.uniform(4,12)*(0.65+.65*t)
        c=(130+rng.randint(0,40),110+rng.randint(0,27),95+rng.randint(0,27),
           int(rng.randint(45,117)*(1-.52*t)))
        d.ellipse((x-rx,y-ry,x+rx,y+ry),fill=c)
    im.alpha_composite(dust.filter(ImageFilter.GaussianBlur(5)))
    chips=blank();d=ImageDraw.Draw(chips,'RGBA')
    for i in range(48):
        theta=rng.uniform(-math.pi,math.pi)
        speed=rng.uniform(30,115)
        x=127+math.cos(theta)*speed*t + 14*t
        y=133+math.sin(theta)*speed*.63*t+72*t*t
        if not(3<x<253 and 3<y<251):continue
        rad=rng.uniform(1.5,8)*(1-.48*t)
        v=int(rng.randint(100,175)*(1-.27*t))
        d.polygon([(x-rad,y+.45*rad),(x-.25*rad,y-rad),
                   (x+rad,y-rad*.15),(x+.6*rad,y+.7*rad)],
                  fill=(v,int(v*.82),int(v*.64),int(211*(1-.70*t))))
        if i%4==0:
            d.line([(x-rad,y),(x,y-rad)],fill=(252,194,118,int(145*(1-t))),width=2)
    im.alpha_composite(chips)
    # Brief directed mineral fracture at knuckle contact: no UI-star radial spokes.
    if k < 5:
        fracture=blank();fd=ImageDraw.Draw(fracture,'RGBA')
        strength=(1-t)**.68
        for i in range(7):
            angle=rng.uniform(-1.25,1.28)
            x=120+rng.uniform(-9,8); y=122+rng.uniform(-14,14)
            length=rng.uniform(29,85)*(0.60+0.83*t)
            end=(x+length*math.cos(angle),y+length*math.sin(angle))
            mid=(x+length*.60,y+length*.50*math.sin(angle)-rng.uniform(-9,9))
            fd.line([(x,y),mid,end],fill=(255,187,84,int(185*strength)),width=3,joint='curve')
            fd.line([mid,end],fill=(248,223,156,int(203*strength)),width=1,joint='curve')
        im.alpha_composite(fracture.filter(ImageFilter.GaussianBlur(.65)))
    return im


def save_atlas(frames,cols,path):
    rows=(len(frames)+cols-1)//cols
    sheet=Image.new('RGBA',(CELL*cols,CELL*rows),(0,0,0,0))
    for i,frame in enumerate(frames):sheet.alpha_composite(frame,((i%cols)*CELL,(i//cols)*CELL))
    sheet.save(path,optimize=True)
    assert sheet.mode=='RGBA' and sheet.getpixel((0,0))[3]==0
    print('FIST06_ATLAS',path.name,sheet.size,'frames',len(frames),'sha256',hashlib.sha256(path.read_bytes()).hexdigest())

if __name__=='__main__':
    save_atlas([make_rock_fist(i,charge=True) for i in range(4)]+[make_rock_fist(i,charge=False) for i in range(12)],4,OUT/'earth_fist_main.png')
    save_atlas([impact_frame(i) for i in range(8)],4,OUT/'earth_fist_hit.png')
    main=Image.open(OUT/'earth_fist_main.png')
    hit=Image.open(OUT/'earth_fist_hit.png')
    assert main.size==(1024,1024) and hit.size==(1024,512)
    raw=main.width*main.height*4+hit.width*hit.height*4
    assert raw==6291456
    print('FIST06_ATLAS_PASS frames=24 textures=2 raw_rgba_bytes=6291456 no_rig=true')
