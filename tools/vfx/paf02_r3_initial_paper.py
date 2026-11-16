#!/usr/bin/env python3
"""PAF02 R3 charge-only: animated jade-gold talisman from owner-approved PAF01 R6 first-party art.
Distinct PAF02 paper-curl poses; no rig, no gameplay. Other three PAF02 layers untouched.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math
import numpy as np

DEFAULT_SOURCE = Path(__file__).resolve().parents[2] / 'godot/labs/combat_lab/talisman11/art_sources/paf01_r6_illustrated_source.webp'

def build_hero(i=7, n=14, source=None):
    paper=Image.open(Path(source) if source else DEFAULT_SOURCE).convert('RGBA')
    arr=np.asarray(paper).copy()
    arr[arr[:,:,3]==0,:3]=0
    paper=Image.fromarray(arr,'RGBA')
    q=i/max(1,n-1)
    emergence=.25+.75*min(1.,q/.32)
    w,h=360,416
    b=np.asarray(paper.resize((w,h),Image.Resampling.LANCZOS)).copy()
    res=np.zeros_like(b)
    xx=np.arange(w)
    for y in range(h):
        t=y/max(h-1,1)
        sway=14*math.sin(2*math.pi*(q*.95+t*.71))*(.25+.75*t)
        fold=1-.18*(1-q)*(math.sin(math.pi*t)**2)
        flutter=1+.06*math.sin(2.7*math.pi*t+q*math.pi*2)
        source_x=((xx-w/2-sway)/(fold*flutter)+w/2).astype(int)
        res[y]=b[y,np.clip(source_x,0,w-1)]
    leaf=Image.fromarray(res,'RGBA')
    leaf=leaf.rotate(-9+13*math.sin(2*math.pi*(q*.70+.1)),Image.Resampling.BICUBIC,expand=True)
    out=Image.new('RGBA',(560,560))
    threads=Image.new('RGBA',out.size)
    d=ImageDraw.Draw(threads,'RGBA')
    for j in range(3):
        points=[]
        for v in range(43):
            z=v/42
            x=255+68*z+32*math.sin(z*math.pi*1.1+q*2.1+j*.58)
            y=292+76*z+25*math.sin(z*math.pi*1.7+j*1.2+q)
            points.append((x+(j-1)*20,y+(j-1)*10))
        d.line(points,fill=(68+24*j,221,188,round((72+18*j)*emergence)),width=max(1,5-j))
    haze=threads.filter(ImageFilter.GaussianBlur(10))
    haze.putalpha(haze.getchannel('A').point(lambda a:round(a*.23)))
    out.alpha_composite(haze)
    out.alpha_composite(threads)
    left=(560-leaf.width)//2+round(6*math.sin(q*5.5))
    top=(560-leaf.height)//2-20+round(9*math.sin(2*math.pi*q))
    out.alpha_composite(leaf,(left,top))
    out.putalpha(out.getchannel('A').point(lambda a:round(a*.94)))
    return out
