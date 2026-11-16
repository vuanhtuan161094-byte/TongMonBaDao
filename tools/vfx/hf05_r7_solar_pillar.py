#!/usr/bin/env python3
"""HF05 R7 finale: a SINGLE source-painted impact becomes a GOLD-WHITE solar
fire pillar with two organic asymmetric side wings, then rises as ember flecks.
Not R6's ring/lotus; R6 is retained in git history as self-rejected art.

First-party original source is the R5/HF02 Hỏa Phù luminous flame master.
No rig, no vector HUD circle, no additional gameplay projectile/hit/status.
"""
from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np, math, hashlib
from hf02_r5_source_painted import source_flame, deform

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/talisman10/assets"
CELL=(640,400);COUNT=20

def ease(a,b,v):
    q=max(0.0,min(1.0,(v-a)/(b-a)))
    return q*q*(3-2*q)

def painted(master,i,w,h,angle=0,gain=1.,whiten=.0):
    p=deform(master,i,sx=w/master.width,sy=h/master.height)
    z=np.asarray(p.convert("RGBA")).copy()
    if whiten>0:
        # Preserve original irregular alpha/silhouette, but create a hotter
        # ivory-yellow source body in the *central* flame, not a HUD ellipse.
        al=z[:,:,3].astype(float)/255.
        z[:,:,0]=np.uint8(np.clip(z[:,:,0].astype(float)+27*whiten*al,0,255))
        z[:,:,1]=np.uint8(np.clip(z[:,:,1].astype(float)+65*whiten*al,0,255))
        z[:,:,2]=np.uint8(np.clip(z[:,:,2].astype(float)+119*whiten*al,0,255))
    z[:,:,3]=np.uint8(np.clip(z[:,:,3].astype(float)*gain,0,255))
    p=Image.fromarray(z,"RGBA")
    if angle:p=p.rotate(angle,Image.Resampling.BICUBIC,expand=True)
    return p

def add(dst,img,x,y,blur=.23):
    pos=(round(x-img.width/2),round(y-img.height/2))
    # glow follows true authored source-pixel borders
    b=img.filter(ImageFilter.GaussianBlur(9))
    b.putalpha(b.getchannel("A").point(lambda a:round(a*blur)))
    dst.alpha_composite(b,pos)
    dst.alpha_composite(img,pos)

def pose(i,source):
    q=i/(COUNT-1)
    c=Image.new("RGBA",CELL)
    compress=(1.0-ease(.10,.33,q))
    column=ease(.045,.20,q)*(1.0-ease(.56,.81,q))
    wings=ease(.08,.31,q)*(1.0-ease(.57,.91,q))
    ground=ease(.04,.19,q)*(1.0-ease(.52,.77,q))
    ash=ease(.38,.59,q)*(1.0-ease(.83,1.10,q))
    # 1. Original illustrated seal compresses into ONE source-painted yellow
    # knot, instead of vanishing into an empty atlas cell.
    if compress>.002:
        bulb=painted(source,i+10,148,62,84,compress*.58,.68)
        add(c,bulb,320,251-12*q,.47*compress)
    # 2. ONE central vertical fire column with a white-gold core.
    if column>.002:
        climb=ease(.10,.47,q)
        core=painted(source,i+54,340+int(48*climb),88+int(10*climb),
                     89+3*math.sin(i*.40),column*.97,.83)
        add(c,core,320,206-37*climb,.34*column)
        peak=painted(source,i+84,248+int(35*climb),63,
                     87+4*math.sin(i*.37),column*.82,.98)
        add(c,peak,322,221-22*climb,.23*column)
    # 3. Flame WINGS: their upper ends climb while roots stay inside the one
    # canonical circle. Their asymmetry makes a jagged flame-FAN, NOT a ring.
    if wings>.002:
        spread=ease(.13,.52,q)
        for j,(sgn,ang,xscale,yscale,offset) in enumerate([
            (-1,-47,.86,.92,-2),(1,49,1.06,1.08,6),
            (-1,-27,.87,1.04,9),(1,29,.91,.81,-8)]):
            width=int((295+36*spread)*xscale)
            thick=int((75+11*spread)*yscale)
            p=painted(source,i+j*13+101,width,thick,
                      ang+4*math.sin(i*.29+j),wings*(.65+.24*(j<2)),.20+.12*(j<2))
            x=320+sgn*(75+61*spread)+offset
            y=222-33*spread+(j//2)*51
            add(c,p,x,y,.18*wings)
        # A few broken hot flame-creases at the top give a jagged explosion,
        # not flat identical rays/equidistant spokes.
        for j in range(3):
            x=251+j*79+15*math.sin(i*.32+j)
            y=130-26*spread +9*math.cos(i*.27+j)
            crest=painted(source,i+j*17+155,147,43,
                 (-41+j*40)+7*math.sin(i*.24+j),wings*.34,.38)
            add(c,crest,x,y,.08*wings)
    # 4. Source-painted FIRE SPLASH tears horizontally across the ground
    # once, then retracts; there is no 360-degree loop.
    if ground>.002:
        splash=painted(source,i+210,495+int(65*ease(.17,.50,q)),85,
            4*math.sin(i*.22),ground*.85,.42)
        add(c,splash,320,286,.21*ground)
    # 5. Ash comes from microcrops of ORIGINAL flames, drifting UP, not
    # generic code points or floor decals; deterministic original image poses.
    if ash>.001:
        for j in range(19):
            sx=20+(j*41)%255;sy=10+(j*13)%45
            crop=source.crop((sx,sy,sx+35,sy+28)).convert("RGBA")
            width=12+(j%4)*7
            height=11+(j%3)*7
            ember=painted(crop,i+j*5+310,width,height,
                (j*17+i*2)%120-60,ash*(.35+.32*math.sin(j*1.3)**2),.3)
            x=320+((j*67)%470-235)*(0.44+.58*ease(.35,.70,q))
            y=277-((j*31)%85)-(q-.38)*151 + 9*math.sin(i*.18+j)
            add(c,ember,x,y,.10*ash)
    if q>=.98:
        last=painted(source,i+441,62,20,-15,.045)
        add(c,last,322,216,.02)
    return c

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    source=source_flame()
    atlas=Image.new("RGBA",(CELL[0]*4,CELL[1]*5))
    distinct=set()
    for i in range(COUNT):
        im=pose(i,source)
        alpha=im.getchannel("A")
        assert alpha.getextrema()[0]==0 and alpha.getextrema()[1]>10,(i,alpha.getextrema())
        h=hashlib.sha256(im.tobytes()).hexdigest()
        assert h not in distinct,(i,"duplicate painted frame")
        distinct.add(h)
        atlas.alpha_composite(im,((i%4)*CELL[0],(i//4)*CELL[1]))
    path=OUT/"tal10_r7_solar_pillar.webp"
    atlas.save(path,"WEBP",quality=94,method=6,exact=True)
    print("HF05_R7_FINALE_ATLAS_PASS",path.name,atlas.size,COUNT,hashlib.sha256(path.read_bytes()).hexdigest())
    print("HF05_R7_FINALE_SOURCE_BAKE_PASS")
if __name__=="__main__":main()
