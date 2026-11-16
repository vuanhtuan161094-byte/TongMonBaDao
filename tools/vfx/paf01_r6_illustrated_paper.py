#!/usr/bin/env python3
"""PAF01 R6 first-party illustrated silk talisman / 16 independently warped poses.
Transparent generated illustration source, NOT a procedural rectangle icon.
R3 streamer, mark, arrival, fade and simulation clocks are unchanged; no rig.
"""
from pathlib import Path
from PIL import Image
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
MASTER=ROOT/"godot/labs/combat_lab/talisman11/art_sources/paf01_r6_illustrated_source.webp"
W,H=480,560

def _elastic_pose(src,index,total=16):
    # Asymmetrical traveling wind wave changes PAPER OUTLINE, never simply rotates a texture.
    a=np.asarray(src.convert("RGBA"),dtype=np.float32)
    h,w=a.shape[:2]
    yy,xx=np.mgrid[:h,:w].astype(np.float32)
    u=yy/max(1,h-1)
    q=float(index)/total
    env=np.sin(np.pi*np.clip(u,0,1))*.58+.32
    dx=12.0*np.sin(u*5.1+q*2*np.pi)*env+3.2*np.sin(u*12.5+q*2*np.pi*1.3)
    dx+=u*u*11.0*np.cos(q*2*np.pi+.3)
    dy=4.2*np.sin((xx/w)*4+q*2*np.pi+u*1.7)*np.sin(np.pi*u)
    xr=xx-dx
    yr=yy-dy
    x=np.clip(xr,0,w-1.001);y=np.clip(yr,0,h-1.001)
    x0=np.floor(x).astype(np.int32);y0=np.floor(y).astype(np.int32)
    x1=np.minimum(x0+1,w-1);y1=np.minimum(y0+1,h-1)
    xf=(x-x0)[...,None];yf=(y-y0)[...,None]
    top=a[y0,x0]*(1-xf)+a[y0,x1]*xf
    bot=a[y1,x0]*(1-xf)+a[y1,x1]*xf
    z=np.clip(top*(1-yf)+bot*yf,0,255).astype(np.uint8)
    z[(xr<0)|(xr>w-1)|(yr<0)|(yr>h-1),3]=0
    return Image.fromarray(z,"RGBA")

def make_talisman_r6(index=0):
    if not MASTER.exists():raise FileNotFoundError(str(MASTER))
    source=Image.open(MASTER).convert("RGBA")
    assert source.size==(180,216),source.size
    # Original transparent material remains visible, including asymmetrical curled tip and tassel.
    enlarged=source.resize((302,361),Image.Resampling.LANCZOS)
    pose=_elastic_pose(enlarged,index,16)
    result=Image.new("RGBA",(W,H))
    result.alpha_composite(pose,(87,96))
    return result
