#!/usr/bin/env python3
"""FIST04 Lei Dinh Chan Quyen: first-party painted energy source -> 40 RGBA poses.
Source is original ImageGen concept painted on 2026-11-14, isolated from an
illustration with chroma-alpha; only sprite material is shipped, NO poster art.
The skill deals Fire damage in a circle of up to THREE confirmed targets; this
view-only lab does not create damage or gameplay events. NO RIG.
"""
from pathlib import Path
from math import cos,sin,pi
import random,hashlib
import numpy as np
from PIL import Image,ImageDraw,ImageFilter,ImageEnhance
ROOT=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/fist04'
A=ROOT/'assets';OUT=A/'generated';OUT.mkdir(exist_ok=True,parents=True)
CELL=384
H=Image.open(A/'thunder_ghost_master.webp').convert('RGBA')
B=Image.open(A/'threefold_impact_master.webp').convert('RGBA')
assert H.size==B.size==(384,384)

def clean(src):
    a=np.array(src,dtype=np.float32)
    yy,xx=np.mgrid[0:CELL,0:CELL]
    edge=np.minimum.reduce([np.clip(xx/22,0,1),np.clip((383-xx)/22,0,1),
                             np.clip(yy/23,0,1),np.clip((383-yy)/22,0,1)])
    a[:,:,3]*=edge
    # Original crop includes faint sky tint; keep only luminous intentional material.
    a[:,:,3]*=np.clip((a[:,:,1]-90)/100,0,1)**.38
    return Image.fromarray(np.clip(a,0,255).astype('uint8'),'RGBA')
H=clean(H);B=clean(B)

def modulate(src,k,scale=1,alpha=1,angle=0,offset=(0,0)):
    im=src.rotate(angle,resample=Image.Resampling.BICUBIC,expand=False)
    w=int(CELL*scale);w=max(4,w)
    im=im.resize((w,w),Image.Resampling.LANCZOS)
    arr=np.array(im,dtype=np.float32);arr[:,:,3]*=alpha
    im=Image.fromarray(np.clip(arr,0,255).astype('uint8'),'RGBA')
    img=Image.new('RGBA',(CELL,CELL),(0,0,0,0))
    img.paste(im,(int((CELL-w)/2+offset[0]),int((CELL-w)/2+offset[1])),im)
    return img

def painter_glints(img,seed,amount=1,base=(198,193),count=52):
    rng=random.Random(seed); d=ImageDraw.Draw(img,'RGBA')
    for k in range(count):
        a=rng.uniform(-pi,pi);r=rng.uniform(10,158)
        x=base[0]+r*cos(a);y=base[1]+r*sin(a)*.7
        if not (7<x<377 and 7<y<377):continue
        z=rng.uniform(.45,2.2)
        color=(255,rng.randint(176,246),rng.randint(84,180),int(rng.randint(34,121)*amount))
        d.ellipse((x-z,y-z*.7,x+z,y+z*.7),fill=color)

def streak(img,seed,k):
    """A few short asymmetrical electric-amber filaments; artwork stays primary."""
    rng=random.Random(seed); layer=Image.new('RGBA',(CELL,CELL),(0,0,0,0));d=ImageDraw.Draw(layer,'RGBA')
    for j in range(9):
        x=rng.uniform(85,270);y=rng.uniform(120,258)
        pts=[]
        for n in range(6):
            pts.append((x+n*rng.uniform(2,7),y+n*rng.uniform(-5,5)))
        d.line(pts,fill=(255,201+rng.randint(0,54),120,int(42+35*sin(k+j)**2)),width=rng.choice([1,2,2]))
    img.alpha_composite(layer.filter(ImageFilter.GaussianBlur(.5)))

def charge(k):
    t=(k+1)/8
    im=modulate(H,k,.52+.14*t,.14+.46*t,angle=-7+4*sin(k*.59),offset=(-17,22))
    painter_glints(im,1500+k,amount=t,base=(186,210),count=52)
    return im

def travel(k):
    t=k/11
    im=modulate(H,k,.74+.10*sin(.2+k*.22),.83+.14*sin(t*pi),angle=-3+2.1*sin(k*.83))
    halo=im.filter(ImageFilter.GaussianBlur(10))
    im=Image.alpha_composite(halo,im)
    streak(im,3110+k*7,k)
    painter_glints(im,2400+k,amount=.9)
    return im

def impact(k):
    t=k/11
    im=modulate(B,k,.73+.24*t,max(.0,(1-t)**.82),angle=(k-4)*.5,offset=(0,15))
    painter_glints(im,4500+k,amount=(1-t),base=(194,227),count=66)
    return im

def grit(k):
    t=k/7.;rng=random.Random(5100+k)
    im=Image.new('RGBA',(CELL,CELL),(0,0,0,0));d=ImageDraw.Draw(im,'RGBA')
    for j in range(95):
        a=rng.uniform(-pi,pi);r=rng.uniform(12,30+126*t)
        x=192+cos(a)*r;y=240+sin(a)*r*.45
        if not (12<x<372 and 15<y<372):continue
        z=rng.uniform(.8,5)*(1-t*.36);opacity=int(rng.randint(40,135)*(1-t*.72))
        d.polygon([(x-z,y+z*.4),(x-z*.4,y-z),(x+z,y-z*.4),(x+z*.6,y+z*.7)],
                  fill=(rng.randint(112,175),rng.randint(80,115),rng.randint(52,80),opacity))
    # Compressed luminous dust under particles; no fake area hit decal.
    return im

def atlas(frames,name):
    rows=(len(frames)+3)//4
    sheet=Image.new('RGBA',(CELL*4,CELL*rows),(0,0,0,0))
    for k,f in enumerate(frames):sheet.alpha_composite(f,(k%4*CELL,k//4*CELL))
    path=OUT/name;sheet.save(path,optimize=True)
    assert sheet.mode=='RGBA' and sheet.getpixel((0,0))[3]==0
    print('LEI_DINH_ATLAS',name,sheet.size,'frames',len(frames),'sha256',hashlib.sha256(path.read_bytes()).hexdigest())

if __name__=='__main__':
    atlas([charge(k) for k in range(8)],'charge.png')
    atlas([travel(k) for k in range(12)],'thunder.png')
    atlas([impact(k) for k in range(12)],'impact.png')
    atlas([grit(k) for k in range(8)],'grit.png')
    print('FIST04_PAINTED_V1_PASS frames=40 alpha=true material=original_ImageGen isolated_painted_rgba no_rig=true')