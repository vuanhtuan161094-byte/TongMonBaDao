#!/usr/bin/env python3
"""HF05 Vạn Phù Phần Thiên — isolated ultimate painterly flipbook baker.

Original first-party master `hf05_original_van_phu_hero_master_rgba.webp.b64`
is an alpha-isolated illustrated mega-talisman made for this project, NOT an
in-engine screenshot. A 24-pose flowing constellation of smaller *real paper*
talismans, 20-pose staggered descending flame-paper rain, independent charging
and 12-pose contact. No rig, fake damage, copied third-party commercial pixels
or massive code-only UI ring. Pose-count derives from the moving storm duration.
"""
from pathlib import Path
from PIL import Image, ImageFilter
import base64, hashlib, io, math
import numpy as np
from hf02_r5_source_painted import source_flame

ROOT=Path(__file__).resolve().parents[2]
LAB=ROOT/"godot/labs/combat_lab/talisman10"
OUT=LAB/"assets"
MASTER=LAB/"art_sources/hf05_original_van_phu_hero_master_rgba.webp.b64"
SMALL=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64"
FOUR_PI=4*math.pi

def load(path,size,label):
    raw=base64.b64decode(path.read_text().strip(),validate=True)
    im=Image.open(io.BytesIO(raw)).convert("RGBA")
    assert im.size==size,(label,im.size,size)
    assert im.getchannel("A").getextrema()[0]==0 and im.getchannel("A").getextrema()[1]>=120,label
    print("HF05_ORIGINAL_MASTER_SHA",label,hashlib.sha256(raw).hexdigest())
    return im

def place(dst,pic,center,scale=1.0,angle=.0,opacity=1.0):
    if opacity<=.003:return
    if scale!=1.0:
        pic=pic.resize((max(1,round(pic.width*scale)),max(1,round(pic.height*scale))),Image.Resampling.LANCZOS)
    if abs(angle)>.03:pic=pic.rotate(angle,Image.Resampling.BICUBIC,expand=True)
    if opacity<.999:
        pic=pic.copy();pic.putalpha(pic.getchannel("A").point(lambda a:round(a*opacity)))
    x=round(center[0]-pic.width*.5);y=round(center[1]-pic.height*.5)
    dst.alpha_composite(pic,(x,y))

def lumina(dst,opacity=.17):
    blur=dst.filter(ImageFilter.GaussianBlur(7))
    blur.putalpha(blur.getchannel("A").point(lambda a:round(a*opacity)))
    blur.alpha_composite(dst)
    return blur

def fire_spray(src,i,w=186,h=66,opacity=.65):
    pic=src.resize((w,h),Image.Resampling.LANCZOS)
    z=np.array(pic,dtype=np.float32)
    y,x=np.indices((h,w),dtype=np.float32)
    sx=np.clip(x+4.2*np.sin(y*.13+i*.41)+1.8*np.sin(x*.053-i*.38),0,w-1).astype(int)
    sy=np.clip(y+2.4*np.sin(x*.055+i*.53),0,h-1).astype(int)
    z=z[sy,sx].copy()
    # alpha source is already unmatted from first-party original RGB.
    z[:,:,3]=np.clip(z[:,:,3]*opacity,0,255)
    z[:,:,0]=np.clip(z[:,:,0]*1.07,0,255)
    z[:,:,1]=np.clip(z[:,:,1]*1.09,0,255)
    return Image.fromarray(np.uint8(z),"RGBA")

def charge(i,hero,small,fire):
    c=Image.new("RGBA",(320,320));q=i/15
    for j in range(5):
        a=i*.17+j*math.tau/5
        r=98-53*q
        x=158+math.cos(a)*r;y=145+math.sin(a)*r*.71
        place(c,small,(x,y),.46+.08*q,math.degrees(a)*.11-13,.30+.58*q)
    for j in range(3):
        a=i*.19+j*math.tau/3
        f=fire_spray(fire,i+j*4,157,51,.20+.39*q)
        place(c,f,(164+math.cos(a)*(36-15*q),151+math.sin(a)*(29-12*q)),
              1,-39+j*59,.98)
    place(c,hero,(158,147),.70+.23*q,math.sin(q*math.pi*1.7)*7,.42+.55*q)
    return lumina(c,.24)

def storm(i,hero,small,fire):
    c=Image.new("RGBA",(640,384));q=i/23
    # ORIGINAL alpha scroll constellation moves and turns organically; every
    # object's (x,y,angle,alpha,depth) evolves continuously between frames.
    for j in range(13):
        a=i*.125+j*math.tau/13
        radius=110+88*(.5+.5*math.sin(j*1.71+i*.16))
        x=322+math.cos(a)*radius
        y=180+math.sin(a)*radius*.42-38*math.sin(math.pi*q)
        opacity=.35+.43*(.5+.5*math.sin(i*.27+j*1.13))
        size=.40+.27*(.5+.5*math.sin(j*3.31+i*.18))
        place(c,small,(x,y),size,math.degrees(a)*.23+math.sin(i*.3+j)*9,opacity)
    # One readable original illustrated MEGA-talisman is the hero focus.
    s=.96+.25*math.sin(math.pi*q)**2
    place(c,hero,(322,162-24*math.sin(q*math.pi)),s,6*math.sin(q*3.4),.48+.46*math.sin(q*math.pi))
    # Vivid irregular plasma wakes, not mathematical HUD circles.
    for j in range(5):
        a=i*.12+j*math.tau/5
        x=326+173*math.cos(a);y=205+67*math.sin(a)
        f=fire_spray(fire,i+j*7,163,50,.23+.13*math.sin(i*.3+j)**2)
        place(c,f,(x,y),1,-math.degrees(a)*.41-35,.81)
    return lumina(c,.18)

def rain(i,small,fire):
    c=Image.new("RGBA",(640,440));q=i/19
    # Staggered downward talisman rain, 9 tapering painted columns. The same
    # nine legal VISUAL rays are part of ONE area event, not extra hits.
    for j in range(9):
        phase=((q*1.35+j*.197) % 1.0)
        x=78+(j%5)*119 + 13*math.sin(i*.27+j*1.65)
        y=-90+phase*510
        long=130+int(67*math.sin((i+j)*.24)**2)
        f=fire_spray(fire,i+j*3,66,long,.42+.18*math.sin(phase*math.pi)**2)
        place(c,f,(x,y-57),.94,92+9*math.sin(i*.36+j),.74)
        place(c,small,(x,y+18),.41+.13*phase,7*math.sin(i*.31+j),.50+.31*phase)
    return lumina(c,.21)

def impact(i,hero,fire):
    c=Image.new("RGBA",(640,320));q=i/11
    decay=max(.05,(1-q)**.83)
    # One broad irregular original fire burst plus signed paper fragments.
    for j in range(7):
        a=j*math.tau/7+i*.07
        r=34+123*q*(.68+.20*math.sin(j*1.47))
        x=320+math.cos(a)*r;y=183+math.sin(a)*r*.48
        f=fire_spray(fire,i+j*11,170+int(57*q),61+int(15*q),decay*.68)
        place(c,f,(x,y),1,-math.degrees(a)*.24-28,.84)
    if q<.64:
        place(c,hero,(320,159),.78+q*.64,5*math.sin(i*.5),decay*.66)
    return lumina(c,decay*.28)

def atlas(seq,w,h):
    result=Image.new("RGBA",(w*4,h*math.ceil(len(seq)/4)))
    for i,im in enumerate(seq):result.alpha_composite(im,((i%4)*w,(i//4)*h))
    return result

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    hero=load(MASTER,(96,132),"HF05_ILLUSTRATED_HERO_96x132")
    small=load(SMALL,(96,132),"HF01_APPROVED_PAPER_SOURCE")
    fire=source_flame()
    items={
     "tal10_r1_charge.webp":(atlas([charge(i,hero,small,fire) for i in range(16)],320,320),320,320,16),
     "tal10_r1_storm.webp":(atlas([storm(i,hero,small,fire) for i in range(24)],640,384),640,384,24),
     "tal10_r1_rain.webp":(atlas([rain(i,small,fire) for i in range(20)],640,440),640,440,20),
     "tal10_r1_impact.webp":(atlas([impact(i,hero,fire) for i in range(12)],640,320),640,320,12)
    }
    for name,(im,w,h,n) in items.items():
        assert im.getchannel("A").getextrema()[0]==0,name
        hashes=set()
        for i in range(n):
            a=im.crop((i%4*w,i//4*h,(i%4+1)*w,(i//4+1)*h))
            assert a.getchannel("A").getextrema()[1]>15,(name,i)
            hashes.add(hashlib.sha256(a.tobytes()).hexdigest())
        assert len(hashes)==n,(name,len(hashes))
        path=OUT/name
        im.save(path,"WEBP",quality=90,method=5,exact=True)
        print("HF05_ATLAS_PASS",name,im.size,n,hashlib.sha256(path.read_bytes()).hexdigest())
    print("HF05_R1_SOURCE_ART_BAKE_PASS")
if __name__=="__main__":main()
