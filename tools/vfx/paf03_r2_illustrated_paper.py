#!/usr/bin/env python3
"""PAF03 R2: first-party illustrated wind paper from owner-approved PAF01 R6 lineage.
This source is used ONLY in the PAF03 charge layer; moving ally cleanse FX distinct.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np
import math,random

ROOT=Path(__file__).resolve().parents[2]
MASTER=ROOT/'godot/labs/combat_lab/talisman11/art_sources/paf01_r6_illustrated_source.webp'
S=3
def P(points):return [(round(x*S),round(y*S)) for x,y in points]
def B(a,b,c,d,n=50):
    p=[]
    for i in range(n+1):
        t=i/n;u=1-t
        p.append((u**3*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t**3*d[0],
                  u**3*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t**3*d[1]))
    return p
def line(draw,p,color,w=2):
    draw.line(P(p),fill=color,width=max(1,round(w*S)),joint='curve')
def charge(i,n=12,size=320):
    q=i/max(n-1,1)
    canvas=Image.new('RGBA',(320*S,320*S))
    wind=Image.new('RGBA',canvas.size);d=ImageDraw.Draw(wind,'RGBA')
    for j in range(5):
        wave=math.sin(q*5+j*.8)
        p=B((95+j*14,191+j*4),(34+j*17,103+25*j+15*wave),
            (245-j*20,286-24*j),(82+j*38+12*wave,270+j*6))
        line(d,p,(71,230,200,80+j*16),7 if j==0 else 2.5)
        line(d,p,(234,250,203,80),1)
    glow=wind.filter(ImageFilter.GaussianBlur(10*S))
    glow.putalpha(glow.getchannel('A').point(lambda z:round(z*.23)))
    canvas.alpha_composite(glow);canvas.alpha_composite(wind)
    # Preserve the approved illustrated silk texture/material and original alpha.
    src=Image.open(MASTER).convert('RGBA')
    w=158*S;h=191*S
    src=src.resize((w,h),Image.Resampling.LANCZOS)
    raw=np.array(src).copy()
    yy=np.arange(h)
    x=np.arange(w)
    for y in range(h):
        t=y/max(h-1,1)
        drift=int(round(S*(8*math.sin(q*5.2+t*math.pi*1.6)*(0.3+.7*t))))
        stretch=.96+.06*math.sin(q*6+t*math.pi)
        sample=np.clip(((x-w/2)/stretch+w/2+drift).astype(int),0,w-1)
        raw[y]=raw[y,sample]
    src=Image.fromarray(raw,'RGBA')
    src=src.rotate(-14+12*math.sin(q*3.6+.1),Image.Resampling.BICUBIC,expand=True)
    dest=(canvas.width-src.width)//2+round(8*S*math.sin(q*3.1))
    y=(canvas.height-src.height)//2-round(15*S)
    canvas.alpha_composite(src,(dest,y))
    # Readable white-core accents and free-flowing golden silk, no HUD circle.
    spark=Image.new('RGBA',canvas.size);d=ImageDraw.Draw(spark,'RGBA')
    for j in range(4):
        p=B((146-13*j,99+21*j),(162+23*j,103+35*j),
            (119+16*j,223-14*j),(185+10*j,268))
        line(d,p,(235,238,181,100+17*j),1.7 if j==0 else 1.0)
    for j in range(24):
        x=88+(j*71)%148+8*math.sin(q*5+j)
        y=80+(j*47)%190
        radius=.5+1.4*math.sin((j+1)*2.1)**2
        d.ellipse(P([(x-radius,y-radius),(x+radius,y+radius)]),
                  fill=(255,232,168,145 if j%3==0 else 75))
    bloom=spark.filter(ImageFilter.GaussianBlur(7*S))
    bloom.putalpha(bloom.getchannel('A').point(lambda z:round(z*.18)))
    canvas.alpha_composite(bloom);canvas.alpha_composite(spark)
    return canvas.resize((size,size),Image.Resampling.LANCZOS)
