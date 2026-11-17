#!/usr/bin/env python3
"""POI17 Yểm Ảnh Bộ (Poison shared Human mobility) - original RGBA 40 poses.

Semantic movement: readable paired shadow FOOTPRINTS + flowing dark-jade
sleeves + caster afterimage physically left behind (Godot draws approved
caster sprite unchanged at prior positions), followed by a landing pulse.
First-party true-alpha source. NO GIF, RIG, commercial assets or false teleport.
"""
from pathlib import Path
from math import ceil,pi
import numpy as np
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison17_yem_anh_bo/r1/assets"
SS=2
PARTS=(("gather",8,(256,224)),("stride",12,(320,160)),
       ("footprint",12,(256,192)),("landing",8,(256,224)))
RGB={
 "shadow":(20,97,82), "deep":(31,133,110), "jade":(16,221,168),
 "cyan":(49,235,218), "mint":(114,255,214),
 "ivory":(225,252,229), "violet":(115,102,195)
}

def gauss(x,y,cx,cy,sx,sy):
    return np.exp(-(((x-cx)/sx)**2+((y-cy)/sy)**2))

def gate(v,a,b,soft):
    return np.clip((v-a)/soft,0,1)*np.clip((b-v)/soft,0,1)

def over(arr,rgb,alpha):
    a=np.clip(alpha,0,1).astype(np.float32)
    o=arr[:,:,3]
    z=a+o*(1-a)
    arr[:,:,:3]=(arr[:,:,:3]*o[:,:,None]*(1-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(z[:,:,None],1e-8)
    arr[:,:,3]=z

def footprint(x,y,x0,y0,phase,lean=1):
    """A tapered BOOT sole, separated toe clusters and a heel light groove.
    Shoe shape deliberately recognizable; no geometric circle UI glyph.
    """
    xx=x-x0
    yy=y-y0
    # lean directs the left/right stagger along the movement axis
    s=(xx*.95+yy*.30*lean)
    side=-xx*.30*lean+yy*.95
    sole=np.exp(-((s/17.0)**4+(side/7.8)**4))
    tip=gauss(s,side,13,0,9.2,9.0)
    heel=gauss(s,side,-13,-1,7.4,6.5)
    body=np.clip(sole*.73+tip*.57+heel*.41,0,1)
    toe_a=gauss(s,side,21,-5,3.7,3.9)
    toe_b=gauss(s,side,23,3,3.7,3.9)
    groove=np.exp(-((side-1.0)/1.6)**2)*gate(s,-9,14,6)
    return body,toe_a+toe_b,groove

def render(name,t,cell):
    w,h=cell
    yy,xx=np.mgrid[:h*SS,:w*SS].astype(np.float32)
    x=(xx+.5)/SS-w*.5;y=(yy+.5)/SS-h*.5
    p=np.zeros((h*SS,w*SS,4),np.float32)
    noise=np.clip(.88+.09*np.sin(.044*x+.083*y+5.2*t)*np.cos(.066*x-.036*y-2.4*t),.64,1)
    def ink(c,a):over(p,RGB[c],a)
    if name=="gather":
        q=.20+.80*t
        # Clear pre-step energy under the ankles; no portal or magic disk.
        for k in range(2):
            ox=(k-.5)*26
            oy=29+(k%2)*14
            body,toes,groove=footprint(x,y,ox,oy,t,1 if k else -1)
            ink("shadow",body*.35*q)
            ink("jade",body*.47*q*noise)
            ink("mint",toes*.37*q)
            ink("ivory",groove*.52*q)
        # Individual curved brush-splash light strands leading RIGHT.
        for k in range(5):
            yy0=(k-2)*17
            arc=yy0+10*np.sin((x+36)*.018+k*.65+t*.8)
            stroke=np.exp(-((y-arc)/(3.4+k%2))**2)*gate(x,-60,64,21)
            ink("deep" if k%2 else "cyan",stroke*.25*q*noise)
            ink("ivory",np.exp(-((y-arc)/1.3)**2)*gate(x,-20,35,22)*.12*q)
        ink("jade",gauss(x,y,0,13,27,37)*.17*q)
        ink("ivory",gauss(x,y,0,17,9,12)*.39*q)
    elif name=="stride":
        # Horizontal first-party 320x160 strip. Godot scales it exactly across
        # the *actual* short-lived movement vector, NOT a fake projectile.
        strength=np.clip(.73+.25*np.sin(pi*t),0,1)
        for k in range(6):
            center=(k-2.5)*12 +7*np.sin((x+30)*.022+k*.8+t*1.2)
            end=(.55+.34*np.sin(x*.012+k*.58+3*t))
            line=np.exp(-((y-center)/(3.8+(k%3)))**2)*gate(x,-146,126,32)
            ink("deep" if k%3==0 else "jade",line*.35*strength*end*noise)
            ink("cyan",np.exp(-((y-center)/2.0)**2)*gate(x,-109,106,33)*.24*strength)
        # Diffuse shadow-sleeve body behind runner, leaving energy tail.
        ink("shadow",gauss(x,y,-8,0,117,40)*.11*strength*noise)
        for k in range(17):
            phi=k*2.399963
            px=-123+(k%17)*15+15*t
            py=(k%5-2)*11+5*np.sin(phi+t*3)
            ink("cyan" if k%4 else "mint",gauss(x,y,px,py,2.4,4.7)*.37*strength)
            ink("ivory",gauss(x,y,px,py,1.1,2.2)*.20*strength)
    elif name=="footprint":
        # 2 sequential distinct left/right little shadow steps behind the
        # real moving caster. These MUST look like an after-trail of feet.
        power=max(.18,(1-t)**.50)
        for k in range(2):
            ox=(k-.5)*51+11*t
            oy=(k-.5)*27+14
            body,toes,groove=footprint(x,y,ox,oy,t,-1 if k else 1)
            ink("shadow",gauss(x,y,ox,oy,32,29)*.16*power)
            ink("deep",body*.41*power)
            ink("jade",body*.62*power*noise)
            ink("cyan",toes*.60*power)
            ink("ivory",groove*.52*power)
            # a thin botanical POISON-school trace, not a stationary HUD rune
            for j in range(2):
                tail=(y-oy)+7*np.sin((x-ox)*.045+j*.9)
                streak=np.exp(-(tail/(2.5+j))**2)*gate(x,ox-55,ox-8,12)
                ink("violet",streak*.19*power)
        for k in range(8):
            px=-78+20*k+15*t
            py=-3+19*np.sin(k*1.3)
            ink("mint",gauss(x,y,px,py,1.7,3.7)*.30*power)
    elif name=="landing":
        # A split 'landing slash' and a clear resolved footprint, NOT enemy hit.
        q=max(.04,(1-t)**1.20)
        for k in range(2):
            ox=(k-.5)*24
            oy=18+k*14
            body,toes,groove=footprint(x,y,ox,oy,t,1 if k else -1)
            ink("jade",body*.57*q)
            ink("ivory",groove*.66*q)
            ink("cyan",toes*.45*q)
        for k in range(6):
            a=-1.0+k*.37
            sx=x*np.cos(a)+y*np.sin(a)
            sy=-x*np.sin(a)+y*np.cos(a)
            e=np.exp(-(sy/(2.2+k%2))**2)*gate(sx,13,88+8*t,19)
            ink("cyan" if k%2 else "jade",e*.39*q*noise)
        ink("mint",gauss(x,y,0,8,37,24)*.14*q)
        ink("ivory",gauss(x,y,0,12,8,7)*.40*q)
    # High-chroma CORE / lit footstep / exterior SOFT shadow hierarchy.
    orig=p[:,:,3]
    gain={"gather":1.58,"stride":1.53,"footprint":1.62,"landing":1.55}[name]
    p[:,:,3]=np.clip(np.where(orig>.04,1-(1-orig)**gain,orig*1.12),0,.965)
    rgba=np.zeros_like(p,dtype=np.uint8)
    rgba[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    rgba[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    rgba[:14,:,3]=0;rgba[-14:,:,3]=0;rgba[:,:14,3]=0;rgba[:,-14:,3]=0
    rgba[rgba[:,:,3]==0,:3]=0
    return Image.fromarray(rgba,"RGBA").resize(cell,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    raw=0
    for name,count,cell in PARTS:
        w,h=cell
        atlas=Image.new("RGBA",(4*w,ceil(count/4)*h))
        for i in range(count):
            f=render(name,i/(count-1),cell)
            assert f.getchannel("A").getbbox(),(name,i)
            atlas.alpha_composite(f,((i%4)*w,(i//4)*h))
            if i==count//2:
                (OUT/"master").mkdir(exist_ok=True)
                f.save(OUT/"master"/f"poi17_{name}_master_rgba.png",optimize=True)
        target=OUT/f"poi17_{name}_{count:02d}.png"
        atlas.save(target,optimize=True)
        raw+=atlas.width*atlas.height*4
        print("POI17_ORIGINAL_MOBILITY_RGBA",name,count,atlas.size,target.stat().st_size)
    print("POI17_YEM_ANH_BO_R1_SOURCE_PASS poses=40 atlases=4 no_gif_no_rig=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
