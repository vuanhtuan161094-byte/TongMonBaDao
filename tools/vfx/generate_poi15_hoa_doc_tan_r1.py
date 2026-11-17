#!/usr/bin/env python3
"""POI15 Hóa Độc Tán R1: original translucent spreading poison VFX.

Distinct AREA-POISON (circle, target cap 3, poison 1 stack 6s) versus POI14
cleanse and POI13 heal. ORIGINAL true RGBA independent atlas keyframes:
8 charged germ, 12 widening medicinal poison luminous vapour, 8 targeted
status wisps. First-party code-drawn light, NO GIF, no rig, no external pixels.
"""
from pathlib import Path
import math
import numpy as np
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison15_hoa_doc_tan/r1/assets"
SCALE=2
SPECS=(("charge",8,(192,192)),("field",12,(320,320)),("mark",8,(128,128)))
COLOR={
    "jade":(30,240,157), "emerald":(19,203,116), "aqua":(49,224,221),
    "silver":(223,255,242), "ivory":(246,255,211), "purple":(148,58,229),
    "plum":(195,80,234), "lime":(154,247,122)
}

def over(p,rgb,a):
    a=np.clip(a,0,1).astype(np.float32)
    old=p[:,:,3]
    n=a+old*(1-a)
    p[:,:,:3]=(p[:,:,:3]*old[:,:,None]*(1-a[:,:,None])+np.array(rgb)*a[:,:,None])/np.maximum(n[:,:,None],1e-6)
    p[:,:,3]=n

def gauss(x,y,cx,cy,sx,sy):
    return np.exp(-((x-cx)/sx)**2-((y-cy)/sy)**2)

def g(v,a,b,edge):
    return np.clip((v-a)/edge,0,1)*np.clip((b-v)/edge,0,1)

def frame(part,t,wh):
    w,h=wh
    yy,xx=np.mgrid[0:h*SCALE,0:w*SCALE].astype(np.float32)
    x=(xx+.5)/SCALE-w*.5
    y=(yy+.5)/SCALE-h*.5
    p=np.zeros((h*SCALE,w*SCALE,4),np.float32)
    rad=np.hypot(x,y)
    ang=np.arctan2(y,x)
    noise=np.clip(.8+.10*np.sin(x*.09+y*.027+3.9*t)*np.sin(x*.034-y*.059-3*t)
                    +.075*np.cos(x*.12-y*.043+2*t),.58,1.0)
    def paint(name,a):over(p,COLOR[name],a)
    if part=="charge":
        strength=.20+.80*t
        # Emerald reagent condenses into an opaque-free little pearl.
        for i in range(7):
            a=i*math.tau/7+.15
            r=39*(1-t)+9
            xp=math.cos(a)*r;yp=math.sin(a)*r*.69
            paint("emerald",gauss(x,y,xp,yp,12,15)*.17*strength*noise)
            paint("aqua",gauss(x,y,xp,yp,5,7)*.14*strength)
        # Not a rigid medical cross or ring. Only organic soft forks.
        for i in range(4):
            a=i*math.tau/4+.3
            parallel=x*math.cos(a)+y*math.sin(a)
            normal=-x*math.sin(a)+y*math.cos(a)
            strand=np.exp(-(normal/4.1)**2)*g(parallel,8,49-14*t,12)
            paint("jade" if i%2 else "purple",strand*.23*strength*noise)
        paint("jade",gauss(x,y,0,0,25,22)*.28*strength)
        paint("aqua",gauss(x,y,0,0,14,14)*.23*strength)
        paint("ivory",gauss(x,y,0,0,4.4+2*t,5.2+2*t)*.82*strength)
    elif part=="field":
        # Evolving irregular wavefront, not flat colored disc or interface circle.
        growth=.26+.78*t
        fade=max(.11,1-t*.73)
        distort=1+.10*np.sin(5*ang+.4+1.8*t)+.05*np.cos(8*ang-1.1*t)
        ell=rad/np.maximum(distort,.72)
        edge=120*growth
        shock=np.exp(-((ell-edge)/(9+6*t))**2)
        interior=np.exp(-((ell/(70+22*growth))**2))
        # Soft jade body with deliberate open negative space.
        paint("emerald",interior*.13*fade*noise)
        paint("jade",np.exp(-((ell/(46+24*growth))**2))*.15*fade*noise)
        paint("purple",shock*(.15+.10*(1-t))*fade*noise)
        paint("aqua",shock*.27*fade*noise)
        # Long feather-light filaments radiate outward, with varied lengths.
        for i in range(11):
            a=(i+.13)*math.tau/11
            local=x*math.cos(a)+y*math.sin(a)
            cross=-x*math.sin(a)+y*math.cos(a)
            warp=1.8*np.sin(local*.041+i*1.1+t*1.6)
            thickness=3.0+1.3*(i%3)
            ray=np.exp(-((cross-warp)/thickness)**2)
            length=(61+10*(i%4))*growth+17
            fade_start=6+(i%3)*3
            gate=g(local,fade_start,length,13)
            paint("jade" if i%3 else "aqua",ray*gate*(.21+.06*(i%3))*fade*noise)
            if i%3==1:
                paint("silver",np.exp(-((cross-warp)/1.18)**2)*gate*.14*fade)
        # Wisps are independent *poison smoke light*, not neon radial UI.
        for k in range(15):
            a=2.399963*k+.14
            rp=(32+37*t+5*(k%5))
            cx=rp*math.cos(a)+6*np.sin(k*1.3+t*4)
            cy=rp*math.sin(a)*.82
            q=gauss(x,y,cx,cy,12+2*(k%3),16+3*(k%4))
            paint("purple" if k%4==0 else "jade",q*(.16+.07*(k%3))*fade*noise)
            paint("plum" if k%4==0 else "aqua",gauss(x,y,cx,cy,4.2,7)*.13*fade)
        # The source has a hot, compact center that dims after arrival.
        paint("aqua",gauss(x,y,0,0,23,28)*.25*fade)
        paint("silver",gauss(x,y,0,0,7.4,8.6)*.62*fade)
        paint("ivory",gauss(x,y,0,0,3.4,4)*.63*fade)
    elif part=="mark":
        # Distinct per-target 6-second LAB-only affliction visual.
        # Not a square UI mark. Tiny jade vapour + purple disintegrating motes.
        power=.52+.48*np.sin(t*math.pi*.82+.28)
        paint("emerald",gauss(x,y,0,5,23,30)*.09*power*noise)
        for j in range(5):
            phase=2.39996*j+.42
            cx=(j-2)*8+2*np.sin(t*4.5+j)
            cy=21-28*t+(j%3)*6
            strand=np.exp(-((x-cx-3.5*np.sin(y*.035+j*.9))/4.0)**2)*g(y,cy-18,cy+21,11)
            paint("jade" if j%2 else "purple",strand*.25*power*noise)
        for i in range(8):
            a=i*2.39996+.8
            cx=(12+5*(i%3))*np.sin(a)+5*np.sin(t*5+i)
            cy=(15+3*(i%3))*np.cos(a)-10*t
            mote=gauss(x,y,cx,cy,2.3+(i%3),4+(i%4))
            paint("lime" if i%3 else "plum",mote*.51*power)
            paint("silver",gauss(x,y,cx,cy,1.1,1.6)*.21*power)
        paint("jade",gauss(x,y,0,4,7,10)*.18*power)
        paint("ivory",gauss(x,y,0,4,2.4,3.6)*.31*power)
    else:raise ValueError(part)
    rgba=np.zeros_like(p,dtype=np.uint8)
    rgba[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    rgba[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    rgba[:12,:,3]=0;rgba[-12:,:,3]=0;rgba[:,:12,3]=0;rgba[:,-12:,3]=0
    rgba[rgba[:,:,3]==0,:3]=0
    return Image.fromarray(rgba,"RGBA").resize(wh,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    total=0
    for kind,n,cell in SPECS:
        w,h=cell
        atlas=Image.new("RGBA",(4*w,math.ceil(n/4)*h))
        for i in range(n):
            im=frame(kind,i/(n-1),cell)
            assert im.getchannel("A").getbbox(),(kind,i)
            atlas.alpha_composite(im,((i%4)*w,(i//4)*h))
            if i==n//2:
                folder=OUT/"master"
                folder.mkdir(exist_ok=True)
                im.save(folder/f"poi15_{kind}_master_rgba.png",optimize=True)
        path=OUT/f"poi15_{kind}_{n:02d}.png"
        atlas.save(path,optimize=True)
        total+=atlas.width*atlas.height*4
        print("POI15_ORIGINAL_RGBA_ATLAS",kind,n,atlas.size,path.stat().st_size)
    print("POI15_POISON_AOE_SOURCE_PASS authored_rgba_poses=28 raw_atlas_bytes=",total,"no_gif=true")
if __name__=="__main__":
    main()
