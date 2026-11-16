#!/usr/bin/env python3
"""FIST11 Huyết Liệt Quyền R1, original first-party dark-red organic sprite VFX.
Three *independent* project-made painted master images, baked into distinct
RGBA charge (8), travel-fist (12) and single-target impact (8) atlas frames.
No GIF, screenshots, actor pixels, skeletal rig, gameplay damage or reuse of
another unrelated school's VFX master.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np
import math

ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'godot/labs/combat_lab/fist11/assets/source'
OUT=ROOT/'godot/labs/combat_lab/fist11/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)


def master(name):
    with Image.open(SRC/f'f11_{name}_master.webp') as original:
        assert original.size==(768,768) and original.format=='WEBP'
        image=original.convert('RGBA')
    return image
CHARGE=master('charge')
HERO=master('fist')
CONTACT=master('contact')

def mod_alpha(pic,a):
    result=pic.copy()
    result.putalpha(pic.getchannel('A').point(lambda x:int(max(0,min(255,x*a)))))
    return result

def center(dest,src,xy):
    x=int(round(xy[0]-src.width/2));y=int(round(xy[1]-src.height/2))
    l=max(0,-x);top=max(0,-y);r=min(src.width,dest.width-x);b=min(src.height,dest.height-y)
    if r<=l or b<=top:return
    dest.alpha_composite(src.crop((l,top,r,b)),(max(0,x),max(0,y)))

def warp(pic,phase,power):
    # Authored organic liquid displacement, no runtime geometry;
    # alpha boundaries stay in frame. NOTE: preserve actual source pixels.
    data=np.asarray(pic,dtype=np.uint8)
    h,w=data.shape[:2]
    yy=np.arange(h,dtype=np.int32)[:,None]
    xx=np.arange(w,dtype=np.int32)[None,:]
    dx=np.rint(power*(np.sin(yy*.031+phase)*.66+np.sin(yy*.09-phase)*.34)).astype(np.int32)
    xmap=np.clip(xx+dx,0,w-1)
    pixels=data[np.broadcast_to(yy,(h,w)),np.broadcast_to(xmap,(h,w))].copy()
    return Image.fromarray(pixels,'RGBA')

def charge_pose(k):
    u=k/7
    im=Image.new('RGBA',(256,256))
    opacity=[.12,.24,.39,.61,.76,.91,1,.38][k]
    size=[218,195,181,158,145,135,128,164][k]
    src=CHARGE.resize((size,size),Image.Resampling.LANCZOS)
    src=warp(src,.72*k,1.4)
    src=mod_alpha(src,opacity)
    center(im,src,(128+2*math.sin(k*.7),127-3*u))
    return im

def hero_pose(k):
    u=k/11
    im=Image.new('RGBA',(320,320))
    src=HERO.resize((292+int(13*math.sin(k*.32)),292),Image.Resampling.LANCZOS)
    src=warp(src,k*.63,2.2+1.1*math.sin(k*.3))
    # Real first-party fist master changes outline/pressure over flight.
    src=mod_alpha(src,.83+.14*math.sin(math.pi*u))
    center(im,src,(158+10*math.sin(k*.24),163+2*math.cos(k*.33)))
    return im

def contact_pose(k):
    u=k/7
    im=Image.new('RGBA',(256,256))
    strength=[.20,.56,1.,.90,.70,.43,.20,.055][k]
    scale=[.67,.82,1.,1.07,1.12,1.14,1.16,1.17][k]
    src=CONTACT.resize((int(239*scale),int(239*scale)),Image.Resampling.LANCZOS)
    src=warp(src,k*.79,1.5)
    src=mod_alpha(src,strength)
    center(im,src,(127-4*u,126+6*u))
    if k in (1,2,3):
        ember=src.filter(ImageFilter.GaussianBlur(9))
        center(im,mod_alpha(ember,.20*strength),(127,125))
    return im

def atlas(poses,cell,name):
    page=Image.new('RGBA',(cell*4,cell*((len(poses)+3)//4)))
    signatures=[]
    for i,im in enumerate(poses):
        assert im.size==(cell,cell)
        assert im.getchannel('A').getextrema()[1]>0
        signatures.append(im.tobytes())
        page.alpha_composite(im,((i%4)*cell,(i//4)*cell))
    assert len({hash(x) for x in signatures})==len(poses)
    assert page.getchannel('A').getextrema()[0]==0
    page.save(OUT/name,optimize=True)
    return page

charge=atlas([charge_pose(k) for k in range(8)],256,'f11_charge.png')
hero=atlas([hero_pose(k) for k in range(12)],320,'f11_flight_fist.png')
contact=atlas([contact_pose(k) for k in range(8)],256,'f11_contact.png')
raw=charge.width*charge.height*4+hero.width*hero.height*4+contact.width*contact.height*4
assert raw==9109504,raw
print('FIST11_BAKE_PASS atlas=3 poses=28 rgba_bytes=9109504 8charge_12flight_8contact=true no_gif=true no_rig=true')