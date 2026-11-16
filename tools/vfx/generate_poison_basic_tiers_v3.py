#!/usr/bin/env python3
"""Poison normal-attack tiers V3: original code-painted transparent RGBA raster.
No GIF generation, GIF extraction, rigging or pixels borrowed from other games.
Three DISTINCT silhouettes, not a recolor: Human needle, Immortal two-echo
lance, Divine gold-jade heaven-tipped spear with distinct local contact.
"""
from pathlib import Path
import math
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/poison_basic_tiers_v3/assets"
SCALE=2
TIERS=("human","immortal","divine")
SPECS=(("charge",6,(192,192)),("flight",8,(288,160)),("contact",8,(256,256)))
PALETTE={
 "human":((30,238,161),(106,56,224),(224,255,222)),
 "immortal":((39,251,202),(58,159,250),(242,255,233)),
 "divine":((67,251,153),(226,197,88),(255,255,228)),
}

def over(p,rgb,a):
    a=np.clip(a,0,1).astype(np.float32)
    old=p[:,:,3]
    new=a+old*(1.0-a)
    p[:,:,:3]=(p[:,:,:3]*old[:,:,None]*(1.0-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(new[:,:,None],1.e-6)
    p[:,:,3]=new

def gate(v,l,r,fade):
    return np.clip((v-l)/fade,0,1)*np.clip((r-v)/fade,0,1)

def image(tier,kind,t,cell):
    w,h=cell
    hh,ww=h*SCALE,w*SCALE
    yy,xx=np.mgrid[0:hh,0:ww].astype(np.float32)
    x=(xx+.5)/SCALE-w*.5
    y=(yy+.5)/SCALE-h*.5
    p=np.zeros((hh,ww,4),dtype=np.float32)
    jade,accent,hot=PALETTE[tier]
    order=TIERS.index(tier)
    def put(rgb,opacity):over(p,rgb,opacity)
    rad=np.hypot(x,y);angle=np.arctan2(y,x)
    if kind=="charge":
        # Painted root energy. Lower tiers are deliberately leaner.
        power=np.clip((t+.18)*1.22,0,1)
        for k in range(2+order):
            phase=angle+(.35*t)+(math.tau*k/(2+order))
            shape=np.exp(-((rad-(13+5.5*t+5.0*order+3.4*np.cos(3*phase)))/
                         (3.5+order))**2)
            put(jade,shape*.25*power*np.clip(np.cos((2+order)*phase)**2+.18,0,1))
            put(accent,shape*.16*power*np.clip(np.sin((3+order)*phase)**2+.1,0,1))
        put(jade,np.exp(-(rad/(12+3.6*order))**2)*(.38+.09*order)*power)
        put(hot,np.exp(-(rad/4.0)**2)*(.62+.09*order)*power)
        # A short straight horizontal spearlet forms without wobbling.
        width=1.5+order*.45
        core=np.exp(-(y/width)**2)*gate(x,-23,36+8*order,9)
        put(jade,core*.42*power)
        put(hot,np.exp(-(y/.8)**2)*gate(x,-13,34+8*order,12)*.61*power)
        if tier=="divine":
            # Four delicate source-painted gold lines; no giant HUD glyph.
            for sign in (-1,1):
                wing=np.exp(-((y-sign*(5+np.abs(x)*.14))/1.5)**2)*gate(x,-20,30,16)
                put(accent,wing*.34*power)
    elif kind=="flight":
        # Main axis is deliberately STRAIGHT. No wavy 'snake' sine movement.
        head=80+3*t
        tail=-112
        gx=gate(x,tail,head,16)
        progress=np.clip((x-tail)/(head-tail),0,1)
        # Graded volumetric needle sheath is transparent but keeps saturated RGB.
        width=(3.0+order*.65)+ (11+order*4)*(1-progress)**1.3
        body=np.exp(-(y/width)**2)*gx
        put(accent,body*(.20+.07*order))
        put(jade,body*(.42+.085*order))
        # A sharp tapered spear point, stable orientation toward +X.
        core=np.exp(-(y/(1.0+.85*(1-progress)))**2)*gate(x,-83,head,10)
        put(jade,core*(.67+.06*order))
        put(hot,np.exp(-(y/.92)**2)*gate(x,-48,head,9)*(.69+.07*order))
        # Tail stays locally straight. Two short contours taper to nothing.
        for sign in (-1,1):
            lobe=sign*(4+(9+order*3)*(1-progress)**1.15)
            sliver=np.exp(-((y-lobe)/(1.45+order*.28))**2)*gate(x,-101,52,24)
            put(accent if sign<0 else jade,sliver*(.16+.025*order))
        if order>=1:
            # Immortal evolves to double afterimage LINES (not extra gameplay hits).
            for sign in (-1,1):
                echo=sign*(13+(12+order*4)*(1-progress))
                taper=np.exp(-((y-echo)/(1.0+order*.25))**2)*gate(x,-84,38,23)
                put((151,244,251) if tier=="immortal" else accent,taper*(.47 if order==1 else .59))
            tip_veil=np.exp(-((x-(head-15))/16)**2-(y/(5+2*order))**2)
            put(jade,tip_veil*.22)
        if order==2:
            # Divine golden articulated apex plus two separated ornament trails.
            for sign in (-1,1):
                wing=sign*(6+19*np.clip((head-x)/53,0,1))
                cut=np.exp(-((y-wing)/1.0)**2)*gate(x,10,head,12)
                put(accent,cut*.75)
                crown=np.exp(-((x-20)/4.3)**2-((y-sign*15)/3.0)**2)
                put(accent,crown*.33)
        # Hairline white-jade point anchored to actual tip.
        put(hot,np.exp(-((x-(head-8))/15)**2-(y/1.7)**2)*(.80+.06*order))
    elif kind=="contact":
        # One cosmetic hit on ONE moving actor; stronger tiers evolve shape only.
        fade=max(.10,float(np.clip((1-t)/.63,0,1)**.75))
        growth=.35+.75*float(np.sin(min(1,t)*math.pi)**.7)
        spokes=(5,7,9)[order]
        size=(29,44,62)[order]*growth
        body=np.exp(-(rad/(15+6*order))**2)
        put(jade,body*.25*fade)
        for k in range(spokes):
            a=k*math.tau/spokes+(.02*t if order==0 else .10*t)
            axial=x*math.cos(a)+y*math.sin(a)
            cross=-x*math.sin(a)+y*math.cos(a)
            plume=np.exp(-(cross/(1.8+order*.25))**2)*gate(axial,0,size,6)
            put(jade,plume*(.52+.08*order)*fade)
            if order>=1:
                secondary=np.exp(-((cross-2.4)/(2.3+order*.3))**2)*gate(axial,5,size*.78,7)
                put(accent,secondary*(.32+.09*order)*fade)
        if order>=1:
            # Immortal elliptical shock ripple. Not an opaque circular disk.
            rip=np.exp(-((rad-(16+22*t+order*4))/(3.3+order))**2)
            broken=.35+.65*np.sin(angle*(spokes//2)+.45)**2
            put(accent,rip*broken*(.15+.055*order)*fade)
        if order==2:
            for k in range(5):
                a=k*math.tau/5
                v=np.exp(-((x-31*math.cos(a)*growth)/2.1)**2-((y-31*math.sin(a)*growth)/3.1)**2)
                put((255,235,146),v*.72*fade)
        put(hot,np.exp(-(rad/(5+1.3*order))**2)*(.91)*fade)
    else:raise ValueError(kind)
    out=np.zeros_like(p,dtype=np.uint8)
    out[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    out[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    # Clean outer gutter, no rectangular source matte.
    out[:12,:,3]=0;out[-12:,:,3]=0;out[:,:12,3]=0;out[:,-12:,3]=0
    out[out[:,:,3]==0,:3]=0
    return Image.fromarray(out,"RGBA").resize(cell,Image.Resampling.LANCZOS)

def main():
    total=0
    for tier in TIERS:
        output=OUT/tier
        master=output/"master"
        master.mkdir(parents=True,exist_ok=True)
        for kind,n,cell in SPECS:
            w,h=cell
            atlas=Image.new("RGBA",(w*4,h*math.ceil(n/4)))
            for k in range(n):
                im=image(tier,kind,k/max(1,n-1),cell)
                assert im.getchannel("A").getbbox() is not None,(tier,kind,k)
                atlas.alpha_composite(im,((k%4)*w,(k//4)*h))
                if k==n//2:
                    im.save(master/f"{tier}_{kind}_master_rgba.png",optimize=True)
            dest=output/f"{tier}_{kind}_{n:02d}.png"
            atlas.save(dest,optimize=True)
            total+=w*4*h*math.ceil(n/4)*4
            print("POISON_BASIC_TIER_ATLAS",tier,kind,n,atlas.size,dest.stat().st_size)
    print("POISON_BASIC_TIERS_TRUE_RGBA_NO_GIF=PASS tiers=3 authored_poses=66 raw_bytes=",total)
if __name__=="__main__":main()
