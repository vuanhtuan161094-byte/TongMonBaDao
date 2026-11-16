#!/usr/bin/env python3
"""Poison Human Basic R2: ORIGINAL true-RGBA paint; prior GIF is motion reference ONLY.
No source pixel extraction; preserves saturated RGB independently of alpha.
This is a code-painted source, not an image-generation source, no rig or third-party pixels.
"""
from pathlib import Path
import math
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/poison_basic_human_v2/assets"
SCALE=2

def over(dst,rgb,a):
    aa=np.clip(a,0,1)
    old=dst[:,:,3]
    out=aa+old*(1-aa)
    dst[:,:,:3]=(dst[:,:,:3]*old[:,:,None]*(1-aa[:,:,None])+np.asarray(rgb)*aa[:,:,None])/np.maximum(out[:,:,None],1e-5)
    dst[:,:,3]=out

def pose(kind,t,wh):
    w,h=wh
    W,H=w*SCALE,h*SCALE
    y,x=np.mgrid[0:H,0:W].astype(np.float32)
    x=(x+.5)/SCALE-w*.5
    y=(y+.5)/SCALE-h*.5
    p=np.zeros((H,W,4),np.float32)
    def paint(rgb,alpha):over(p,rgb,alpha)
    if kind=="charge":
        strength=np.clip((t+.12)*1.6,0,1)
        angle=np.arctan2(y,x)
        rad=np.sqrt(x*x+y*y)
        for i in range(3):
            a=angle+i*2.094+t*2.4
            r=22+12*t+(6+4*t)*np.sin(3*angle+3*t+i*1.8)
            field=np.exp(-((rad-r)/5.5)**2)
            paint((50,242,176),.23*strength*field*np.clip(np.sin(angle*2.8+i*1.9+3*t)**2+.1,0,1))
            paint((145,76,242),.34*strength*field*np.cos(a*2.1)**2)
        paint((46,236,151),np.exp(-((x/13.5)**2+(y/12.5)**2)*1.4)*.45*strength)
        paint((174,255,214),np.exp(-((x/6.4)**2+(y/5.2)**2))*.82*strength)
        yy=y-1.8*np.sin(x*.087+7*t)
        beam=np.exp(-(yy/(2+3*np.clip((x+9)/48,0,1)))**2)
        long=np.clip((x+22)/9,0,1)*np.clip((37-x)/13,0,1)
        paint((30,232,131),beam*long*.45*strength)
        paint((239,255,195),np.exp(-(yy/1.0)**2)*long*.55*strength)
    elif kind=="flight":
        xt=76+7*np.sin(t*5)
        tail=-111-4*np.sin(t*4)
        u=np.clip((x-tail)/(xt-tail),0,1)
        fall=np.clip((x-tail)/24,0,1)*np.clip((xt-x)/18,0,1)
        drift=y-3.8*np.sin(x*.037+t*5.3)-1.5*np.sin(x*.094+t*7.7)
        body=np.exp(-(drift/np.maximum(1.1+9.3*(1-u)**1.1*fall,1))**2)*fall
        paint((113,46,226),body*.35)
        paint((39,244,174),body*.53)
        for i in range(4):
            offset=(i-1.5)*7.5
            cy=offset*np.sin(np.clip((xt-x)/194,0,1)*math.pi*.84)+(i-1.5)*3.4*np.sin(x*.055+t*9+i)
            sigma=3.3+3.5*np.sin(x*.037+i*1.9+t*9)**2
            strand=np.exp(-((y-cy)/sigma)**2)
            gate=np.clip((x+117)/31,0,1)*np.clip((57-x)/87,0,1)
            hue=(173,64,233) if i%2 else (78,228,191)
            paint(hue,strand*gate*(.16+.08*np.sin(x*.12+t*7.1+i)**2))
        spine=y-2.5*np.sin(x*.052+t*5.5)
        core=np.exp(-(spine/(.95+2.3*(1-u)))**2)*np.clip((x+83)/32,0,1)*np.clip((xt-x)/10,0,1)
        paint((42,253,165),core*.70)
        paint((211,255,220),np.exp(-(spine/1.45)**2)*np.clip((x+70)/30,0,1)*np.clip((xt-x)/9,0,1)*.85)
        for i in range(7):
            xp=-93+i*22+5*np.sin(t*6+i*2)
            yp=14*np.sin(i*1.7+t*6)+7*np.cos(i*3.7)
            paint((163,255,207),np.exp(-((x-xp)/2.0)**2-((y-yp)/1.4)**2)*.40)
    elif kind=="contact":
        growth=.24+.82*np.sin(min(t,1)*math.pi)**.67
        fade=np.maximum(.09,np.clip((1-t)/.54,0,1)**.7) # last keypose remains visible; Godot composites its final fade
        rad=np.sqrt(x*x+y*y)
        angle=np.arctan2(y,x)
        distorted=rad/(1+.12*np.sin(5*angle+8*t)+.07*np.cos(9*angle-9*t))
        for i in range(9):
            a=i*math.tau/9+.11*np.sin(i*4.2+t*8)
            rmax=(35+14*np.sin(i*1.37+4*t))*growth
            diff=np.sin(a-angle)
            along=np.cos(a-angle)
            beam=np.exp(-((diff*rad)/(1.3+2.5*growth))**2)*np.clip((along*rad)/5,0,1)*np.clip((rmax-along*rad)/14,0,1)
            paint((151,60,226),beam*.43*fade)
            paint((66,244,167),beam*.46*fade)
        paint((27,239,146),np.exp(-(distorted/33)**2)*.42*fade)
        paint((76,246,184),np.exp(-((x/15)**2+(y/13)**2))*.50*fade)
        paint((224,255,222),np.exp(-(distorted/6.8)**2)*.91*fade)
        ring=np.exp(-((rad-(23+22*t))/(5+3*t))**2)*np.sin(4*angle+4.6*t)**2
        paint((154,60,243),ring*.18*fade)
    else:raise ValueError(kind)
    raw=np.empty_like(p,dtype=np.uint8)
    raw[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    raw[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    raw[:8,:,3]=0;raw[-8:,:,3]=0;raw[:,:8,3]=0;raw[:,-8:,3]=0
    raw[raw[:,:,3]==0,:3]=0
    return Image.fromarray(raw,"RGBA").resize((w,h),Image.Resampling.LANCZOS)

SPECS=[("charge",6,(192,192)),("flight",8,(288,160)),("contact",8,(256,256))]

def main():
    a=OUT/"atlas";m=OUT/"master";a.mkdir(parents=True,exist_ok=True);m.mkdir(parents=True,exist_ok=True)
    hashes={}
    for kind,n,(w,h) in SPECS:
        sheet=Image.new("RGBA",(w*4,h*math.ceil(n/4)))
        for i in range(n):
            frame=pose(kind,i/max(1,n-1),(w,h))
            sheet.alpha_composite(frame,((i%4)*w,(i//4)*h))
            if i in [0,n//2,n-1]:
                frame.save(m/f"poison_basic_{kind}_{i:02d}_rgba.png")
        file=a/f"poison_basic_{kind}_{n:02d}_rgba.png"
        sheet.save(file,optimize=True)
        print("POISON_BASIC_RGBA_SOURCE",kind,n,sheet.size,"png_bytes",file.stat().st_size)
    print("POISON_BASIC_TRUE_ALPHA_RGB_INDEPENDENT=PASS 22 poses 3 sheets; GIF pixels NOT used")
if __name__=="__main__":main()
