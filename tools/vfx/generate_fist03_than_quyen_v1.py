#!/usr/bin/env python3
"""Thần Quyền: isolated art-first original spirit fist flipbook.
This is a presentation-only Divine Fist concept aligned with Bao Quyen
Sơn Hà Chấn Thiên Human ultimate mechanics, not a new canonical skill.
Source artwork: first-party image-generation concept cropped/cleaned into
unique production WebP masters with independent compositing, no copied
commercial art. No character rig; character is an unmoving preview proxy.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageEnhance,ImageFilter
from math import pi,sin,cos
import numpy as np, random, hashlib
ROOT=Path(__file__).resolve().parents[2] / 'godot/labs/combat_lab/fist03'
ASSETS=ROOT / 'assets'
OUT=ASSETS / 'generated'
CELL=384
OUT.mkdir(parents=True,exist_ok=True)
FIST=Image.open(ASSETS/'godfist_master.webp').convert('RGBA')
BURST=Image.open(ASSETS/'impact_master.webp').convert('RGBA')
assert FIST.size==BURST.size==(CELL,CELL)

def center_scene(src,scale=1.0,rot=0.0,alpha=1.0,shift=(0,0)):
    tmp=src.rotate(rot,resample=Image.Resampling.BICUBIC,expand=False)
    n=int(round(CELL*scale))
    tmp=tmp.resize((n,n),Image.Resampling.LANCZOS)
    arr=np.asarray(tmp,dtype=np.uint8).copy()
    arr[:,:,3]=np.clip(arr[:,:,3].astype(np.float32)*alpha,0,255).astype('uint8')
    tmp=Image.fromarray(arr,'RGBA')
    frame=Image.new('RGBA',(CELL,CELL),(0,0,0,0))
    px = int(round((CELL-n)/2 + shift[0]))
    py = int(round((CELL-n)/2 + shift[1]))
    if 0 <= px <= CELL-n and 0 <= py <= CELL-n:
        frame.alpha_composite(tmp,(px,py))
    else:
        frame.paste(tmp,(px,py),tmp)
    return frame

def glints(frame,seed,count,intensity=1):
    d=ImageDraw.Draw(frame,'RGBA');rng=random.Random(seed)
    for i in range(count):
        r=rng.uniform(12,156);a=rng.uniform(-pi,pi)
        x=192+r*cos(a);y=194+r*sin(a)*.61
        if not (8<x<376 and 7<y<377):continue
        q=rng.uniform(.5,2.1)
        d.ellipse((x-q,y-q*.67,x+q,y+q*.67),fill=(255,rng.randint(197,241),rng.randint(90,175),int(rng.randint(25,105)*intensity)))

def charge(k):
    t=(k+1)/8
    im=center_scene(FIST,scale=.44+.24*t,rot=-10+5*sin(k*.8),alpha=.12+.47*t,shift=(-47,12))
    halo=Image.new('RGBA',(CELL,CELL),(0,0,0,0));d=ImageDraw.Draw(halo,'RGBA')
    for j in range(14):
        a=j*2.399+k*.38
        x=188+cos(a)*(42+48*(1-t));y=214+sin(a)*(27+40*(1-t))
        dx=188+cos(a+.7)*19;dy=213+sin(a+.7)*16
        d.line([(x,y),(dx,dy)],fill=(255,173,81,int(29+49*t)),width=1+j%3)
    im.alpha_composite(halo.filter(ImageFilter.GaussianBlur(2)))
    glints(im,2700+k,50,t)
    return im

def hero(k):
    t=k/11
    im=center_scene(FIST,scale=.71+.17*sin(pi*(t*.6+.15)),rot=-6+3.5*sin(k*.84),alpha=.90,shift=(2*sin(k),-1*int(k%3)))
    # Subtle hand-painted integral hot rim: keeps actual image material, not flat polygon.
    halo=im.filter(ImageFilter.GaussianBlur(13))
    arr=np.asarray(halo,dtype=np.uint8).copy()
    arr[:,:,3]=np.clip(arr[:,:,3].astype(np.float32)*.29,0,255).astype('uint8')
    warm=Image.fromarray(arr,'RGBA')
    warm.alpha_composite(im)
    glints(warm,3700+k,48,.8)
    return warm

def impact(k):
    t=k/11
    opacity=(1.0-t)**.75
    im=center_scene(BURST,scale=.81+.19*t,rot=(k-6)*.48,alpha=.95*opacity)
    # Localized outward dust & small stone flakes, anchored at confirmed (preview) target positions.
    d=ImageDraw.Draw(im,'RGBA');rng=random.Random(4700+k)
    for j in range(60):
        a=rng.uniform(-pi,pi);r=rng.uniform(13,53+93*t)
        x=188+cos(a)*r;y=243+sin(a)*r*.51
        if not (5<x<378 and 6<y<376):continue
        z=rng.uniform(1,4)*(1-.43*t)
        d.polygon([(x-z,y-.5*z),(x+.4*z,y-1.4*z),(x+z,y+.3*z),(x-.6*z,y+z)],fill=(rng.randint(106,178),rng.randint(72,110),rng.randint(46,70),int(95*opacity)))
    glints(im,4900+k,70,opacity)
    return im

def dust(k):
    t=k/7
    im=Image.new('RGBA',(CELL,CELL),(0,0,0,0));rng=random.Random(5100+k)
    d=ImageDraw.Draw(im,'RGBA')
    for j in range(165):
        x=rng.gauss(192,35+72*t);y=rng.gauss(270,10+28*t)
        rr=rng.uniform(.6,4.1)*(1-.45*t)
        if not (2<x<CELL-2 and 2<y<CELL-2):continue
        d.ellipse((x-rr,y-rr*.7,x+rr,y+rr*.7),fill=(rng.randint(141,199),rng.randint(95,144),rng.randint(65,95),int(rng.randint(32,93)*(1-.75*t))))
    return im

def atlas(items,columns,name):
    rows=(len(items)+columns-1)//columns
    image=Image.new('RGBA',(columns*CELL,rows*CELL),(0,0,0,0))
    for i,item in enumerate(items):image.alpha_composite(item,((i%columns)*CELL,(i//columns)*CELL))
    target=OUT/name;image.save(target,optimize=True)
    assert image.mode=='RGBA' and image.getpixel((0,0))[3]==0
    print('THAN_QUYEN_ATLAS',target.name,image.size,'frames',len(items),'sha256',hashlib.sha256(target.read_bytes()).hexdigest())

if __name__=='__main__':
    atlas([charge(i) for i in range(8)],4,'charge.png')
    atlas([hero(i) for i in range(12)],4,'godfist.png')
    atlas([impact(i) for i in range(12)],4,'impact.png')
    atlas([dust(i) for i in range(8)],4,'dust.png')
    print('THAN_QUYEN_ART_V1=PASS atlas_frames=40 alpha=RGBA original_source=ImageGen_cropped no_rig=true')