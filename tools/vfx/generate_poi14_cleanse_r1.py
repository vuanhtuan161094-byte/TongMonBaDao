#!/usr/bin/env python3
"""POI14 Nghịch Độc Phản Chế R1 — original soft transparent CLEANSE VFX.
Sprite-first true RGBA master and flipbooks. NOT POI13 healing, not a GIF,
no imported commercial artwork, no rig, no Combat V2 changes.
Violet impurities are pulled OUT of the ally (not applied), then dissolve
into translucent jade/silver light. One allied target only.
"""
from pathlib import Path
import math
import numpy as np
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison14_cleanse/r1/assets"
SCALE=2
SPECS=(("charge",8,(192,192)),("sever",12,(256,256)),("purge",10,(256,256)))
RGB={
    "jade":(35,249,181),"aqua":(55,204,235),"silver":(218,253,255),
    "ivory":(253,255,215),"poison":(166,66,238),"wine":(225,73,217),
    "gold":(242,228,151)
}
def over(p,rgb,opacity):
    a=np.clip(opacity,0,1).astype(np.float32)
    old=p[:,:,3]
    new=a+old*(1-a)
    p[:,:,:3]=(p[:,:,:3]*old[:,:,None]*(1-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(new[:,:,None],1e-6)
    p[:,:,3]=new

def gauss(x,y,cx,cy,sx,sy):
    return np.exp(-((x-cx)/sx)**2-((y-cy)/sy)**2)

def gate(t,a,b,fade):
    return np.clip((t-a)/fade,0,1)*np.clip((b-t)/fade,0,1)

def pose(phase,q,wh):
    w,h=wh
    yy,xx=np.mgrid[0:h*SCALE,0:w*SCALE].astype(np.float32)
    x=(xx+.5)/SCALE-w/2
    y=(yy+.5)/SCALE-h/2
    p=np.zeros((h*SCALE,w*SCALE,4),dtype=np.float32)
    texture=np.clip(.77+.13*np.cos(x*.068-y*.051+q*3)*np.sin(y*.047+x*.019+q*2)
                        +.07*np.sin(x*.11+y*.045-q*2),.5,1.)
    def paint(name,a):over(p,RGB[name],a)
    rad=np.hypot(x,y)
    if phase=="charge":
        # Condense straight clean rays and a small medicinal sphere, no solid icon/ring.
        strength=.28+.72*q
        for k in range(5):
            angle=k*math.tau/5+.32
            cx=math.cos(angle)*(32-20*q)
            cy=math.sin(angle)*(25-16*q)
            paint("aqua",gauss(x,y,cx,cy,13,17)*.08*strength*texture)
            paint("jade",gauss(x,y,cx,cy,7,12)*.14*strength)
        for sign in (-1,1):
            axis=x-sign*(9+3*(1-q))
            stroke=np.exp(-(axis/(3.8+q*1.2))**2)*gate(y,-46,25+12*q,17)
            paint("jade" if sign<0 else "aqua",stroke*.16*strength*texture)
        paint("jade",gauss(x,y,0,0,27,26)*.25*strength)
        paint("silver",gauss(x,y,0,0,6+2*q,7+2*q)*.59*strength)
        paint("ivory",gauss(x,y,0,0,3.4,4.0)*.60*strength)
    elif phase=="sever":
        # Translucent poison contamination exits UP and AWAY from one ally.
        # This fades over time; never represents adding poison/status.
        poison_strength=np.clip((1.08-q)/1.08,0,1)**.58
        for i in range(9):
            angle=i*2.39996+.55
            bx=math.sin(angle)*(19+7*(i%3))
            by=22+math.cos(angle)*(11+4*(i%4))
            cx=bx+q*(13+6*(i%3))*math.sin(angle+1.5)
            cy=by-q*(42+5*i)
            blob=gauss(x,y,cx,cy,7+(i%3)*2.2,11+(i%4)*2.5)
            # Violet is seen being REMOVED; transparency and size diminish.
            paint("poison" if i%3 else "wine",blob*(.30+.08*(i%3))*poison_strength*texture)
            kernel=gauss(x,y,cx,cy,2.5,4.5)
            paint("wine",kernel*.30*poison_strength)
        # Clean energy flows IN through the chest in bands that are not rigid rings.
        cleanse_strength=.43+.57*np.sin(np.pi*(.11+.78*q))**.75
        paint("aqua",gauss(x,y,0,3,49,61)*.16*cleanse_strength*texture)
        paint("jade",gauss(x,y,-7,-4,34,49)*.15*cleanse_strength)
        for i in range(8):
            pos=(i-3.5)*10.5
            slant=pos+4.5*np.sin(y*.019+i*1.26+q*.64)
            body=np.exp(-((x-slant)/(4.0+1.0*(i%3)))**2)*gate(y,-81+6*(i%3),79-5*(i%4),25)
            paint("jade" if i%3 else "aqua",body*(.13+.034*(i%4))*cleanse_strength*texture)
            if i in (2,5):
                paint("silver",np.exp(-((x-slant)/2.0)**2)*gate(y,-46,62,25)*.15*cleanse_strength)
        # Singular thin cleansing slash, not a geometric icon. It advances upward.
        slash_y=36-62*q
        slash=gauss(x,y,-3,slash_y,35,4.0)
        paint("jade",slash*.52*cleanse_strength)
        paint("silver",gauss(x,y,-3,slash_y,24,1.75)*.70*cleanse_strength)
        paint("ivory",gauss(x,y,-4,slash_y,7.0,2.8)*.55*cleanse_strength)
        paint("aqua",gauss(x,y,0,3,18,26)*.18*cleanse_strength)
        paint("ivory",gauss(x,y,0,3,4.2,5.0)*.54*cleanse_strength)
    elif phase=="purge":
        # No shield and no 8-second status. Dissolve remnants into tiny light.
        fading=max(.11,(1-q)**1.12)
        paint("aqua",gauss(x,y,0,-17-q*19,42+10*q,53+12*q)*.084*fading*texture)
        # Trace residual purple converts to pale jade sparks, never persists.
        for i in range(6):
            theta=i*math.tau/6+.23
            cx=math.cos(theta)*(22+18*q)
            cy=5+math.sin(theta)*(16+11*q)-q*49
            rem=gauss(x,y,cx,cy,9+q*2,12+q*5)
            paint("poison",rem*.13*((1-q)**1.8))
        for k in range(18):
            a=k*2.399963
            cx=(17+4*(k%5))*math.sin(a)+q*(15+3*(k%3))*math.cos(a+.6)
            cy=19+math.cos(a)*(14+4*(k%3))-q*(55+4*(k%6))
            particle=gauss(x,y,cx,cy,2.5+.7*(k%3),4.2+1.0*(k%4))
            paint("jade" if k%4 else "gold",particle*(.58+.045*(k%4))*fading)
            paint("silver",gauss(x,y,cx,cy,1.45,2.15)*.49*fading)
        paint("silver",gauss(x,y,0,-6,7+8*q,9+9*q)*.20*fading)
    else:raise ValueError(phase)
    arr=np.zeros_like(p,dtype=np.uint8)
    arr[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    arr[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    arr[:12,:,3]=0;arr[-12:,:,3]=0;arr[:,:12,3]=0;arr[:,-12:,3]=0
    arr[arr[:,:,3]==0,:3]=0
    return Image.fromarray(arr,"RGBA").resize(wh,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    raw=0
    for name,n,wh in SPECS:
        w,h=wh
        sheet=Image.new("RGBA",(w*4,h*math.ceil(n/4)))
        for i in range(n):
            img=pose(name,i/(n-1),wh)
            assert img.getchannel("A").getbbox(),(name,i)
            sheet.alpha_composite(img,((i%4)*w,(i//4)*h))
            if i==n//2:
                master=OUT/"master"
                master.mkdir(exist_ok=True)
                img.save(master/f"poi14_{name}_source_rgba.png",optimize=True)
        path=OUT/f"poi14_{name}_{n:02d}.png"
        sheet.save(path,optimize=True)
        raw+=sheet.width*sheet.height*4
        print("POI14_CLEANSE_RGBA_ATLAS",name,n,sheet.size,"compressed_bytes",path.stat().st_size)
    print("POI14_CLEANSE_SOURCE_PASS poses=30 no_gif=true original_true_alpha=true raw_atlas_bytes=",raw)
if __name__=="__main__":
    main()
