#!/usr/bin/env python3
"""POI13 Giải Độc Hộ Tâm R2: original energy-first soft RGBA VFX.
Zero imported image pixels, zero GIF, no shield icon/rig. Floating-point light
and translucent non-geometric ribbons; low-opacity nebula and luminous particles.
"""
from pathlib import Path
import math
import numpy as np
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison13_heal_heart/r2/assets"
PARTS=(("charge",8,(192,192)),("aura",12,(256,256)),("release",10,(256,256)))
SCALE=2
COLORS={
 "aqua":(31,235,188), "jade":(42,245,133), "mint":(123,255,204),
 "silver":(218,255,238), "ivory":(251,255,221), "teal":(35,179,202),
 "gold":(255,231,161)
}

def over(dst,rgb,alpha):
    a=np.clip(alpha,0,1).astype(np.float32)
    old=dst[:,:,3]
    combined=a+old*(1-a)
    dst[:,:,:3]=(dst[:,:,:3]*old[:,:,None]*(1-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(combined[:,:,None],1.e-6)
    dst[:,:,3]=combined

def smoothgate(v,lo,hi,edge):
    return np.clip((v-lo)/edge,0,1)*np.clip((hi-v)/edge,0,1)

def gaussian(x,y,cx,cy,sx,sy):
    return np.exp(-((x-cx)/sx)**2-((y-cy)/sy)**2)

def draw(part,t,size):
    w,h=size
    yy,xx=np.mgrid[0:h*SCALE,0:w*SCALE].astype(np.float32)
    x=(xx+.5)/SCALE-w*.5
    y=(yy+.5)/SCALE-h*.5
    p=np.zeros((h*SCALE,w*SCALE,4),np.float32)
    def paint(name,a):over(p,COLORS[name],a)
    # Stable subtle organic luminance texture, not a visible lattice/ring.
    texture=(.72+.17*np.sin(.065*x+.042*y+3*t)*np.sin(.031*y-.017*x-2*t)
             +.11*np.sin(.121*x-.023*y+1.7*t))
    texture=np.clip(texture,.42,1.0)
    if part=="charge":
        strength=.22+.78*t
        # Silky, weakly turbulent vapor flows into a bright tiny medicinal pearl.
        for i in range(7):
            phi=i*math.tau/7+.17
            spread=45*(1-t)**.85+10
            cx=np.cos(phi)*spread
            cy=np.sin(phi)*spread*.69
            sx=16+3*i%5
            sy=9+(i%3)*3
            bloom=gaussian(x,y,cx,cy,sx*2.2,sy*2.1)
            paint("jade" if i%3 else "aqua",bloom*.052*strength*texture)
            paint("mint",gaussian(x,y,cx,cy,sx,sy)*.11*strength)
        # Three soft condensation streams, animated by phase, never hard lines.
        for i in range(3):
            cy=-31+i*24+11*(1-t)
            centre=(i-1)*13+6*np.sin(y*.022+i*1.9+t*1.2)
            body=np.exp(-((x-centre)/11)**2)*smoothgate(y,cy-38,cy+39,18)
            paint("aqua" if i%2 else "jade",body*.16*strength*texture)
        paint("jade",gaussian(x,y,0,0,32,28)*(.15+.14*t))
        paint("aqua",gaussian(x,y,0,0,19,19)*.22*strength)
        paint("ivory",gaussian(x,y,0,0,5.7+1.2*t,5.7+1.2*t)*.72*strength)
    elif part=="aura":
        # Luminous energy field with sparse open negative space, NOT an outline.
        power=(.37+.63*np.sin(math.pi*(.15+.75*t))**.75)
        wobble=3.5*np.sin(t*2.6) # subpixel screen motion when scaled, NOT snake
        back=gaussian(x,y,-11+wobble,14,54,84)
        center=gaussian(x,y,18-wobble,-6,45,69)
        paint("teal",back*.07*texture*power)
        paint("jade",center*.11*texture*power)
        paint("aqua",gaussian(x,y,0,0,40,58)*.15*texture*power)
        # Filament coordinates run VERTICALLY, softness across width.
        # Each strand has an independent phase and dies at the edges.
        for i in range(9):
            ix=(i-4)*9
            speed=.46+.045*(i%3)
            offset=(t-.4)*speed*23
            flow=ix+5.5*np.sin(y*.018+i*1.27+t*.75)+2.1*np.sin(y*.037+i*.55)
            width=4.0+1.5*(i%4)
            line=np.exp(-((x-flow)/width)**2)
            gate=smoothgate(y,-98+offset+(i%3)*6,80+offset-(i%2)*8,24)
            opacity=(.10+.03*(i%4))*gate*power*texture
            paint("aqua" if i%3==1 else "jade",line*opacity)
            paint("mint",np.exp(-((x-flow)/(width*2.8))**2)*gate*.045*power*texture)
            if i in (2,5,7):
                paint("silver",np.exp(-((x-flow)/1.5)**2)*gate*.08*power)
        # A few glowing, detached drifting light grains, not decorative UI points.
        for i in range(12):
            phase=i*2.39996
            cx=40*np.sin(phase)+6*np.sin(t*3+i)
            cy=58*np.cos(phase*.73)-t*(12+4*(i%4))
            d=gaussian(x,y,cx,cy,2.2+(.8*(i%3)),4.3+(.5*(i%4)))
            paint("ivory" if i%3==0 else "aqua",d*(.12+.07*(i%3))*power)
        paint("jade",gaussian(x,y,0,4,26,31)*.13*power)
        paint("silver",gaussian(x,y,0,3,7.9,9.6)*.40*power)
        paint("ivory",gaussian(x,y,0,3,3.9,5.0)*.56*power)
    elif part=="release":
        retain=max(.085,(1-t)**1.65)
        paint("aqua",gaussian(x,y,0,-12-17*t,42+17*t,56+19*t)*.095*retain*texture)
        # Soft-light strands progressively disintegrate into 15 independent motes.
        for i in range(7):
            angle=i*1.39+.42
            origin=(i-3)*12
            flow=origin+5*np.sin(y*.015+angle)+t*(9*np.sin(angle))
            cy=-18-40*t+(i-3)*8
            strand=np.exp(-((x-flow)/(6+i%3))**2)*smoothgate(y,cy-46,cy+44,22)
            paint("jade" if i%3 else "aqua",strand*.16*retain*texture)
        for k in range(15):
            a=2.39996*k
            cx=math.sin(a)*(17+3*(k%5))+t*math.sin(a+1.2)*(17+4*(k%3))
            cy=25+math.cos(a)*(13+2*(k%4))-t*(60+4*(k%5))
            mote=gaussian(x,y,cx,cy,2.2+.6*(k%3),3.7+1.3*(k%3))
            paint("mint" if k%3 else "gold",mote*(.35+.07*(k%3))*retain)
            paint("ivory",gaussian(x,y,cx,cy,1.15,1.85)*.31*retain)
        paint("silver",gaussian(x,y,0,-8-13*t,5.3+4*t,8+4*t)*.23*retain)
    else:raise ValueError(part)
    rgba=np.zeros_like(p,dtype=np.uint8)
    rgba[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    rgba[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    # No hard clamped square boundary even at 8-bit alpha threshold.
    rgba[:12,:,3]=0;rgba[-12:,:,3]=0;rgba[:,:12,3]=0;rgba[:,-12:,3]=0
    rgba[rgba[:,:,3]==0,:3]=0
    return Image.fromarray(rgba,"RGBA").resize(size,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    total=0
    for phase,n,cell in PARTS:
        w,h=cell
        atlas=Image.new("RGBA",(w*4,h*math.ceil(n/4)))
        for k in range(n):
            im=draw(phase,k/(n-1),cell)
            assert im.getchannel("A").getbbox(),(phase,k)
            atlas.alpha_composite(im,((k%4)*w,(k//4)*h))
            if k==n//2:
                master=OUT/"master"
                master.mkdir(exist_ok=True)
                im.save(master/f"poi13_r2_{phase}_source_rgba.png",optimize=True)
        dest=OUT/f"poi13_r2_{phase}_{n:02d}.png"
        atlas.save(dest,optimize=True)
        total+=atlas.width*atlas.height*4
        print("POI13_R2_ORIGINAL_ENERGY_RGBA",phase,n,atlas.size,"PNG_bytes",dest.stat().st_size)
    print("POI13_R2_ENERGY_SOURCE_PASS poses=30 soft_alpha=true no_gif=true atlas_rgba_bytes=",total)

if __name__=="__main__":
    main()
