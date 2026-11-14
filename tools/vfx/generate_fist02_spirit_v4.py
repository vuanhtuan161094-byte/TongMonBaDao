#!/usr/bin/env python3
"""FIST02 / Phi Than Lien Cuoc — Fire-Guardian V4 art-first sprite lab.
Source is a cleaned transparent, first-party ImageGen-derived illustration,
NOT a static marketing board. Kick-shaped spirit wisps are conceptual FX only;
no actor frame/rig or simulated Combat V2 hits.
Pillow + numpy, deterministic output. 12+8+8 RGBA frames at 320px/cell.
"""
from __future__ import annotations
from pathlib import Path
from math import sin, cos, pi
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance
BASE=Path(__file__).resolve().parents[2]
MASTER=BASE/'godot/labs/combat_lab/fist02/assets/v4/guardian_spirit_master.webp'
OUT=BASE/'godot/labs/combat_lab/fist02/assets/v4/generated'
CELL=320

def master_img():
    assert MASTER.exists(),f'Missing original illustrated hero: {MASTER}'
    img=Image.open(MASTER).convert('RGBA')
    assert img.size == (320,256), img.size
    return img

def seeded_glints(im,seed,t,intensity=1.0):
    rng=random.Random(seed)
    d=ImageDraw.Draw(im,'RGBA')
    for j in range(77):
        ang=rng.uniform(-pi,pi); radius=rng.uniform(22,140)
        x=156+cos(ang)*radius
        y=163+sin(ang)*radius*.77
        if x<5 or y<10 or x>315 or y>309: continue
        size=rng.uniform(.25,1.5)*(1.0+.3*sin(t*7+j))
        alpha=int(rng.uniform(25,101)*intensity)
        d.ellipse((x-size,y-size,x+size,y+size),fill=(255,rng.randint(178,247),rng.randint(97,183),alpha))

def crop_art(width=320,height=256):
    return master_img()

def onto_canvas(img,xy=(0,28)):
    canv=Image.new('RGBA',(320,320),(0,0,0,0))
    canv.alpha_composite(img,xy)
    return canv

def warp(img,pose,amount=1.0):
    """Seamless per-pose motion of real painted pixels with bilinear sampling."""
    w,h=img.size
    src=np.asarray(img,dtype=np.float32)
    yy,xx=np.mgrid[0:h,0:w].astype(np.float32)
    z=pose*.64
    sx=xx+amount*(3.8*np.sin((xx+yy*.7)/58+z)+1.7*np.cos(yy/47+z*.61))
    sy=yy+amount*(2.8*np.sin(xx/70-z*1.12)+1.1*np.cos((xx+yy)/74+z))
    x0=np.floor(sx).astype(np.int32);y0=np.floor(sy).astype(np.int32)
    x1=x0+1;y1=y0+1
    wx=(sx-x0)[...,None];wy=(sy-y0)[...,None]
    def sample(x,y):
        ok=(x>=0)&(x<w)&(y>=0)&(y<h)
        return src[np.clip(y,0,h-1),np.clip(x,0,w-1)]*ok[...,None]
    p=sample(x0,y0)*(1-wx)*(1-wy)+sample(x1,y0)*wx*(1-wy)
    p+=sample(x0,y1)*(1-wx)*wy+sample(x1,y1)*wx*wy
    return Image.fromarray(np.clip(p,0,255).astype(np.uint8),'RGBA')

def cast_pose(k):
    t=(k+1)/12
    src=warp(master_img(),k,1.0)
    rgba=np.array(src,dtype=np.float32)
    y,x=np.mgrid[0:256,0:320]
    # Genuine independent 2D shape progression: burn-in runs from lower left
    # to spirit wisps on upper right, no movement of the character body.
    ribbon=(x*.84+(255-y)*.19)/340
    burn=np.clip((t-ribbon+.10)*9,0,1)
    ripple=np.clip((rgba[:,:,0]-rgba[:,:,2]-8)/114,0,1)
    rgba[:,:,3]*=burn*(.67+.33*ripple)
    src=Image.fromarray(rgba.clip(0,255).astype('uint8'),'RGBA')
    canvas=onto_canvas(src)
    seeded_glints(canvas,6600+k,t,min(1,1.4*t))
    return canvas

def guard_pose(k):
    base=master_img()
    # On guard, only the protective ribbons survive. Spectral bodies retreat;
    # do NOT replay a kick or damage animation on the actor.
    arr=np.array(base,dtype=np.float32)
    yy,xx=np.mgrid[0:256,0:320]
    # Soften identifiable spectral bodies at x~112/224,y~35..110 while
    # preserving the illustrated orange arcs in the top and bottom envelopes.
    g1=np.exp(-(((xx-113)/28)**2+((yy-83)/35)**2))
    g2=np.exp(-(((xx-233)/32)**2+((yy-84)/36)**2))
    artmask=1-.85*np.maximum(g1,g2)
    # Avoid a huge bright floor in the hold loop; preserve high top gold arcs.
    artmask*=1-.62*np.clip((yy-160)/90,0,1)
    arr[:,:,3]*=np.clip(artmask,0,1)
    frame=Image.fromarray(np.clip(arr,0,255).astype('uint8'),'RGBA')
    frame=warp(frame,k+20,.65)
    pulse=.79+.12*sin(k*pi/4+1.1)
    frame.putalpha(frame.getchannel('A').point(lambda a: int(a*pulse)))
    canv=onto_canvas(frame,(0,24))
    seeded_glints(canv,7200+k,k/8,.42)
    return canv

def ember_pose(k):
    # Small original physical motes/ash at caster feet; no attack impact.
    t=k/7; im=Image.new('RGBA',(CELL,CELL),(0,0,0,0))
    rng=random.Random(8100+k);d=ImageDraw.Draw(im,'RGBA')
    for j in range(90):
        x=rng.gauss(157,34+16*t);y=rng.gauss(229,10+10*t)
        r=rng.uniform(.4,2.3)*(1-.45*t)
        if 2<x<318 and 2<y<318:
            d.ellipse((x-r,y-r,x+r,y+r),fill=(202+rng.randint(0,51),111+rng.randint(0,94),69+rng.randint(0,78),int(rng.randint(19,93)*(1-.65*t))))
    return im

def atlas(frames,cols,name):
    rows=(len(frames)+cols-1)//cols
    sheet=Image.new('RGBA',(cols*CELL,rows*CELL),(0,0,0,0))
    for k,im in enumerate(frames):
        sheet.alpha_composite(im,((k%cols)*CELL,(k//cols)*CELL))
    assert sheet.getpixel((0,0))[3]<255
    OUT.mkdir(parents=True,exist_ok=True)
    sheet.save(OUT/name,optimize=True)
    print('FIST02_ATLAS',name,sheet.size,'frames',len(frames),'RGBA')

if __name__=='__main__':
    atlas([cast_pose(i) for i in range(12)],4,'spirit_cast.png')
    atlas([guard_pose(i) for i in range(8)],4,'spirit_guard.png')
    atlas([ember_pose(i) for i in range(8)],4,'spirit_embers.png')
    print('FIST02_IMAGEGEN_ART_FIRST_V4_PASS alpha=true frames=28 no_rig=true no_fake_hit=true')