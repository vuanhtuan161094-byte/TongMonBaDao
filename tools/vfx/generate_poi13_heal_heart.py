#!/usr/bin/env python3
"""POI13 Giải Độc Hộ Tâm: original source-painted true-alpha healing light.
NO GIF, no rig, no imported commercial pixels, no in-game healing mechanics.
Independent source art: jade butterfly-leaves/heart lantern and rising warm motes.
"""
from pathlib import Path
import math
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/poison13_heal_heart/r1/assets"
SCALE=2
PARTS=(("charge",8,(192,192)),("heart",10,(256,256)),("release",8,(256,256)))

def blend(p,rgb,opacity):
    a=np.clip(opacity,0.0,1.0).astype(np.float32)
    old=p[:,:,3]
    val=a+old*(1-a)
    p[:,:,:3]=(p[:,:,:3]*old[:,:,None]*(1-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(val[:,:,None],1e-6)
    p[:,:,3]=val

def image(part,q,size):
    w,h=size
    yy,xx=np.mgrid[0:h*SCALE,0:w*SCALE].astype(np.float32)
    x=(xx+.5)/SCALE-w*.5
    y=(yy+.5)/SCALE-h*.5
    rad=np.hypot(x,y)
    p=np.zeros((h*SCALE,w*SCALE,4),np.float32)
    def put(rgb,opacity):blend(p,rgb,opacity)
    mint=(26,241,163)
    jade=(46,214,190)
    pale=(235,255,211)
    cyan=(65,180,250)
    gold=(245,225,139)
    if part=="charge":
        # Fine liquid herb filaments curl into one white-hot medicinal pearl.
        strength=.24+.76*q
        ripple=rad-((18+5*q)+4*np.sin(3*np.arctan2(y,x)+2*q))
        put(jade,np.exp(-(ripple/3.2)**2)*(.25+.05*q)*strength)
        put(mint,np.exp(-((x/(12+7*q))**2+(y/(12+7*q))**2))*.40*strength)
        for k in range(4):
            a=k*math.pi/2+q*.55
            xr=x*math.cos(a)+y*math.sin(a)
            yr=-x*math.sin(a)+y*math.cos(a)
            line=np.exp(-((yr-(5+q*7)*np.sin(xr/19+1.5*q))/2.5)**2)
            length=np.clip((xr+37)/12,0,1)*np.clip((34-xr)/12,0,1)
            put(mint if k%2 else cyan,line*length*.20*strength)
        put(pale,np.exp(-(rad/(3.4+q*2.6))**2)*(.56+.26*q))
    elif part=="heart":
        # Two cupped soft, translucent leaf wings form around a bright healing heart.
        # Source shape is deliberately NOT a filled polygon/ring or a gameplay guard.
        power=np.sin(math.pi*(.13+.79*q))**.6
        for sign in (-1.,1.):
            yr=(y+4)/73
            shoulder=np.clip(1-np.abs(yr),0,1)
            center=sign*(18+38*shoulder**1.4+6*np.sin((y+55)/66*math.pi+q*.44))
            thickness=5.5+9.5*shoulder
            edge=np.exp(-((x-center)/thickness)**2)*np.clip((y+75)/18,0,1)*np.clip((65-y)/19,0,1)
            inner=np.exp(-((x-center-sign*8)/(thickness+12))**2)*np.clip((y+71)/18,0,1)*np.clip((60-y)/19,0,1)
            put(jade,inner*.16*power)
            put(mint,edge*.51*power)
            # Ivory vein grows diagonally toward the central heartbeat.
            vein=sign*(12+30*shoulder)
            line=np.exp(-((x-vein)/2.3)**2)*np.clip((y+55)/16,0,1)*np.clip((56-y)/16,0,1)
            put(pale,line*.40*power)
            # Symmetrical, compact tip highlights.
            tip=np.exp(-((x-sign*23)/5.4)**2-((y+53)/8.3)**2)
            put(gold,tip*.27*power)
        # Small medicinal white hot center, brighter than wings.
        put(jade,np.exp(-((x/19)**2+(y/19)**2))*.32*power)
        put(pale,np.exp(-((x/6.9)**2+(y/6.7)**2))*.88*power)
        put(gold,np.exp(-((x/3.8)**2+((y-3)/4.2)**2))*.38*power)
    elif part=="release":
        # The treatment exits as independent weightless jade light-leaf motes.
        fade=.13+.87*(1-q)**1.18
        for k in range(7):
            a=math.tau*k/7+0.18*k
            start_x=math.cos(a)*(12+13*(k%3))
            xp=start_x+math.sin(a+.4)*q*(23+7*(k%3))
            yp=18+math.sin(a)*(10+6*(k%2))-q*(52+10*k)
            dx=x-xp
            dy=y-yp
            tilt=a-.35
            along=dx*math.cos(tilt)+dy*math.sin(tilt)
            cross=-dx*math.sin(tilt)+dy*math.cos(tilt)
            shape=np.exp(-((along/(10+2*(k%3)))**2+(cross/3.5)**2))
            put(mint if k%3 else cyan,shape*.62*fade)
            inner=np.exp(-((along/7.5)**2+(cross/1.3)**2))
            put(pale,inner*.47*fade)
        put(jade,np.exp(-(rad/(31+14*q))**2)*.14*fade)
        put(pale,np.exp(-(rad/7.8)**2)*.72*fade)
        # No long-lived poison shield/status badge.
    else:raise ValueError(part)
    rgba=np.zeros_like(p,dtype=np.uint8)
    rgba[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    rgba[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    rgba[:16,:,3]=0;rgba[-16:,:,3]=0;rgba[:,:16,3]=0;rgba[:,-16:,3]=0
    rgba[rgba[:,:,3]==0,:3]=0
    return Image.fromarray(rgba,"RGBA").resize(size,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    total=0
    for part,n,size in PARTS:
        d=OUT/"master"
        d.mkdir(exist_ok=True)
        w,h=size
        atlas=Image.new("RGBA",(w*4,h*math.ceil(n/4)))
        for idx in range(n):
            frame=image(part,idx/max(1,n-1),size)
            assert frame.getchannel("A").getbbox(),(part,idx)
            atlas.alpha_composite(frame,((idx%4)*w,(idx//4)*h))
            if idx==n//2:
                frame.save(d/f"poi13_{part}_master_rgba.png",optimize=True)
        dest=OUT/f"poi13_{part}_{n:02d}.png"
        atlas.save(dest,optimize=True)
        total+=atlas.width*atlas.height*4
        print("POI13_RGBA_ATLAS",part,n,atlas.size,"PNG",dest.stat().st_size)
    print("POI13_NO_GIF_TRUE_RGBA_PASS poses=26 raw_rgba_bytes=",total)
if __name__=="__main__":main()
