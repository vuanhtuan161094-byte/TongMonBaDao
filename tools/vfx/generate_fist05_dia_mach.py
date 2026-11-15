#!/usr/bin/env python3
"""FIST05 Dia Mach Lien Chan. Original alpha-painted earth-rift sprite
production. Three masters were isolated from a first-party ImageGen illustration,
not redistributed game artwork. All 40 pose images are authored reproducibly.
Does not author a character animation or any gameplay damage.
"""
from PIL import Image,ImageDraw,ImageFilter,ImageEnhance
from pathlib import Path
from math import cos,sin,pi,exp
import random,numpy as np,hashlib
R=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/fist05'
A=R/'assets';O=A/'generated';O.mkdir(parents=True,exist_ok=True)
C=384
GROUND=Image.open(A/'seismic_ground_master.webp').convert('RGBA')
SPIRE=Image.open(A/'spires_master.webp').convert('RGBA')
SHARD=Image.open(A/'molten_shard_master.webp').convert('RGBA')
assert GROUND.size==SPIRE.size==SHARD.size==(C,C)
def blank():return Image.new('RGBA',(C,C),(0,0,0,0))
def place(im,src,center=(192,190),scale=1,angle=0,alpha=1):
    layer=src.rotate(angle,resample=Image.Resampling.BICUBIC,expand=True)
    w,h=layer.size;w=max(1,int(w*scale));h=max(1,int(h*scale));layer=layer.resize((w,h),Image.Resampling.LANCZOS)
    arr=np.asarray(layer).copy();arr[:,:,3]=(arr[:,:,3].astype(np.float32)*alpha).clip(0,255).astype(np.uint8)
    layer=Image.fromarray(arr,'RGBA')
    x=int(center[0]-w/2);y=int(center[1]-h/2)
    # consistent use alpha_composite with clipped mask even if partial overlap
    box=blank();box.paste(layer,(x,y))
    im.alpha_composite(box)
def ribbons(frame,seed,count=10,center=(193,289),extent=150,alpha=1):
    rng=random.Random(seed)
    light=blank();base=blank()
    db=ImageDraw.Draw(base,'RGBA');dl=ImageDraw.Draw(light,'RGBA')
    for j in range(count):
        angle=(j/max(1,count))*2*pi+rng.uniform(-.35,.35)
        r=extent*rng.uniform(.44,1.0)
        path=[center];x,y=center
        for h in range(1,6):
            q=h/5
            off=rng.uniform(-9,9)*(1-q)
            path.append((x+cos(angle)*r*q+sin(angle)*off,
                         y+sin(angle)*r*q*.35+cos(angle)*off*.6))
        # random broken stone split, NOT symmetric UI rings
        color=(238,96+rng.randint(0,49),26+rng.randint(0,29),int(100*alpha))
        db.line(path,fill=(119,50,33,int(137*alpha)),width=rng.randint(10,17),joint='curve')
        dl.line(path,fill=color,width=rng.randint(4,7),joint='curve')
        dl.line(path[2:],fill=(255,220,126,int(158*alpha)),width=rng.randint(1,3))
    light=Image.alpha_composite(base.filter(ImageFilter.GaussianBlur(7)),light)
    frame.alpha_composite(light)
def grit(im,seed,count,t,ctr=(192,285),extent=112):
    rng=random.Random(seed);d=ImageDraw.Draw(im,'RGBA')
    for _ in range(count):
        rr=rng.uniform(.3,1)*extent*(.7+t*.7);ang=rng.uniform(-pi,pi)
        x=ctr[0]+rr*cos(ang);y=ctr[1]+rr*sin(ang)*.4-rng.uniform(0,32)*t
        if not 3<x<380 or not 3<y<379:continue
        r=rng.uniform(.8,5.0)*(1-.45*t)
        col=(rng.randint(92,176),rng.randint(65,105),rng.randint(49,78),int((1-.7*t)*rng.randint(70,185)))
        d.polygon([(x-r,y),(x+r*.3,y-r*1.1),(x+r,y+r*.3),(x-r*.6,y+r)],fill=col)
def pressure_glow(im,loc=(192,272),r=(125,55),alpha=125):
    # Sparse, irregular ground-light falloff: never a filled graphic UI ellipse.
    yy,xx=np.mgrid[0:C,0:C].astype(np.float32)
    qx=(xx-loc[0])/max(1,r[0]);qy=(yy-loc[1])/max(1,r[1])
    jitter=.14*np.sin(xx*.083+yy*.023)+.08*np.sin(xx*.131-yy*.11)
    rr=np.sqrt(qx*qx+qy*qy)/(1.0+jitter)
    fall=np.maximum(0.0,1.0-rr)**2.25
    light=np.zeros((C,C,4),dtype=np.uint8)
    light[:,:,:3]=np.array([255,139,46],dtype=np.uint8)
    light[:,:,3]=np.clip(fall*alpha*.56,0,255).astype(np.uint8)
    im.alpha_composite(Image.fromarray(light,'RGBA'))
def charge(k):
    t=(k+1)/8;im=blank();pressure_glow(im,(190,285),(35+65*t,20+30*t),int(38+47*t))
    place(im,GROUND,(191,193),scale=.35+.50*t,alpha=.42+.55*t)
    if k>=3:ribbons(im,8500+k,3+k//3,(194,287),int(23+70*t),.24+.45*t)
    grit(im,8700+k,12+2*k,t,extent=60)
    return im
def fault(k):
    t=(k+1)/12;im=blank();pressure_glow(im,(192,288),(49+124*t,21+24*t),int(37+52*t))
    # Painted earth texture is the hero, not a perfect circle polygon.
    place(im,GROUND,(192,191),scale=.49+.64*t,alpha=.44+.53*t)
    ribbons(im,9400+k,4+int(t*7),center=(193,287),extent=int(24+147*t),alpha=.34+.45*t)
    grit(im,9600+k,24+int(37*t),t,extent=int(53+104*t))
    return im
def eruption(k):
    t=k/11;grow=min(1.0,(t+.06)/.39);fade=1.0 if t<.55 else max(0.0,1-(t-.55)/.45)
    im=blank();pressure_glow(im,(193,289),(125+24*t,51+18*t),int(84*fade))
    # Independent painted rock formations emerge at different locations and heights.
    place(im,SPIRE,(182-3*sin(k),225-53*grow),scale=.28+.57*grow,angle=-7+2*sin(k*.7),alpha=fade)
    place(im,SHARD,(101+6*sin(k),267-50*grow),scale=.22+.42*grow,angle=-16+4*cos(k*.6),alpha=fade*.91)
    place(im,SHARD,(283+5*cos(k*.5),276-35*grow),scale=.18+.36*grow,angle=14-3*sin(k*.7),alpha=fade*.75)
    place(im,GROUND,(191,195),scale=.62+.33*grow,alpha=fade*.82)
    if t>.15:ribbons(im,11700+k,5+int(5*t),center=(192,287),extent=int(82+84*t),alpha=fade*.48)
    grit(im,11900+k,38+int(70*t),t,extent=159)
    return im
def impact(k):
    t=k/7;fade=(1-t)**.65;im=blank();pressure_glow(im,(192,252),(66+65*t,65+28*t),int(98*fade))
    place(im,SHARD,(197,208-38*t),scale=.47+.17*t,angle=-5+14*t,alpha=fade*.83)
    place(im,SPIRE,(165,209-54*t),scale=.27+.17*t,angle=11-13*t,alpha=fade*.61)
    ribbons(im,12300+k,8,center=(189,269),extent=int(67+101*t),alpha=fade*.68)
    grit(im,12700+k,93,t,extent=162)
    return im
def atlas(fn,n,cols,name):
    out=Image.new('RGBA',(C*cols,C*((n+cols-1)//cols)),(0,0,0,0))
    for i in range(n):out.alpha_composite(fn(i),(C*(i%cols),C*(i//cols)))
    p=O/name;out.save(p,optimize=True)
    print('FIST05_ATLAS',name,'frames',n,'pixel',out.size,'sha256',hashlib.sha256(p.read_bytes()).hexdigest())
if __name__=='__main__':
    atlas(charge,8,4,'charge.png')
    atlas(fault,12,4,'fault.png')
    atlas(eruption,12,4,'eruption.png')
    atlas(impact,8,4,'contact.png')
    print('FIST05_ART_PASS frames=40 alpha=RGBA source=original_first_party_painted_masters no_rig=true')
