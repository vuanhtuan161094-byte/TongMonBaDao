#!/usr/bin/env python3
"""HF01 R4: original, reproducible painted fire atlas. Lab-only; no game logic.

Repaints the existing first-party R3 underpaint into new 12/12/8 alpha poses.
This generator is run before Godot imports the R4 atlases (CI/local).
Source rights: exclusively original TMB material; no Source A/JX pixels.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import hashlib
import math
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "godot/labs/combat_lab/talisman06/assets"

def underpaint(name, index, size, strength=.16):
    old = Image.open(ASSETS / name).convert("RGBA")
    w, h = size
    tile = old.crop(((index % 4)*w, (index // 4)*h,
                     (index % 4 + 1)*w, (index // 4 + 1)*h))
    alpha = tile.getchannel("A").point(lambda a: int(a*strength))
    tile.putalpha(alpha)
    return tile

def bezier(a,b,c,d,n=32):
    result=[]
    for i in range(n):
        t=i/(n-1);s=1-t
        result.append((int(s*s*s*a[0]+3*s*s*t*b[0]+3*s*t*t*c[0]+t*t*t*d[0]),
                       int(s*s*s*a[1]+3*s*s*t*b[1]+3*s*t*t*c[1]+t*t*t*d[1])))
    return result

def layered_stroke(dst,points,wide,rgba):
    mask=Image.new("RGBA",dst.size,(0,0,0,0)); brush=ImageDraw.Draw(mask,"RGBA")
    brush.line(points,fill=rgba,width=wide,joint="curve")
    for x,y in [points[0],points[-1]]:
        brush.ellipse((x-wide//2,y-wide//2,x+wide//2,y+wide//2),fill=rgba)
    # Three sizes of bloom emphasize painted plasma, not code-drawn neon.
    bloom=mask.filter(ImageFilter.GaussianBlur(9))
    a=bloom.getchannel("A").point(lambda x:int(x*.45))
    bloom.putalpha(a);dst.alpha_composite(bloom)
    dst.alpha_composite(mask.filter(ImageFilter.GaussianBlur(2.6)))
    dst.alpha_composite(mask)

def comet_frame(i):
    w,h=384,224
    yy,xx=np.indices((h,w),dtype=np.float32)
    rng=np.random.default_rng(64018+i*177)
    head=307+4*math.sin(i*.58)
    tail=np.clip((head-xx)/300.0,0,1)
    axis=112+13*np.sin(xx/34+i*.63)*tail+5*np.sin(xx/13-i*.31)*tail
    fine=rng.random((h,w),dtype=np.float32)
    warp=(np.sin(xx*.12+yy*.06+i*.68)+np.sin(xx*.057-yy*.13-i*.49))*.22
    rwidth=(8+53*tail)*(1+warp)
    body=np.exp(-(np.abs(yy-axis)/(rwidth+1))**1.55)*tail
    rag=np.clip(.35+.75*fine+.17*np.sin(xx*.33+i),0,1.2)
    body*=rag*np.clip((head-xx+25)/28,0,1)
    alpha=np.clip(132*body,0,180).astype(np.uint8)
    red=np.clip(103+145*body+19*fine,0,255).astype(np.uint8)
    green=np.clip(29+126*body+18*fine,0,255).astype(np.uint8)
    blue=np.clip(18+26*body,0,255).astype(np.uint8)
    base=Image.fromarray(np.dstack([red,green,blue,alpha]),"RGBA")
    base.alpha_composite(underpaint("tal06_fire_comet_atlas.webp",i,(w,h),.12))
    # Independently articulated tongues: golden fire coils around a compact white head.
    for lane in range(7):
        phase=i*.39+lane*.88
        sign=-1 if lane%2 else 1
        sy=112+sign*(3+lane*2)
        length=115+lane*22+18*math.sin(phase)
        ey=sy+sign*(23+8*lane)+12*math.sin(phase*1.4)
        start=(298-int(lane*2),int(sy))
        end=(int(head-length),int(ey))
        pts=bezier(start,(235,int(sy+sign*(18+lane*5))),
                   (188-int(lane*11),int(ey-sign*25*math.sin(phase))),end)
        layered_stroke(base,pts,max(2,12-lane),
                       (255,88+min(100,lane*12),26+min(65,lane*7),145-lane*9))
        if lane<4:
            inside=pts[:int(len(pts)*(.68 if lane<2 else .42))]
            layered_stroke(base,inside,3 if lane<2 else 2,(255,228,140,154-lane*17))
    # A strong directional, ivory-white spear tip gives the projectile force.
    gl=Image.new("RGBA",(w,h));p=ImageDraw.Draw(gl,"RGBA")
    p.ellipse((head-38,93,head+6,132),fill=(255,164,48,198))
    p.ellipse((head-22,101,head+13,123),fill=(255,239,155,227))
    p.polygon([(head-14,101),(head+25,112),(head-14,123)],fill=(255,249,221,239))
    base.alpha_composite(gl.filter(ImageFilter.GaussianBlur(8)))
    base.alpha_composite(gl)
    ash=Image.new("RGBA",(w,h));p=ImageDraw.Draw(ash,"RGBA")
    for j in range(52):
        x=int(rng.uniform(16,270));y=int(112+rng.normal(0,32))
        r=int(rng.choice([1,1,2,2,3]));p.ellipse((x-r,y-r,x+r,y+r),
           fill=(255,int(rng.uniform(137,226)),int(rng.uniform(32,105)),int(rng.uniform(30,142))))
    base.alpha_composite(ash)
    return base

def seal_frame(i):
    w=h=256;rng=np.random.default_rng(3103+i*67)
    base=underpaint("tal06_flame_seal_atlas.webp",i,(w,h),.30)
    s=i/11.0
    paper=Image.new("RGBA",(w,h));p=ImageDraw.Draw(paper,"RGBA")
    # Split, burning parchment instead of a spinning flat UI glyph.
    outline=[(86,37),(148,30),(171,45),(163,204),(102,217),(86,198)]
    skew=math.sin(s*3.8)*8
    outline=[(int(x+skew*abs(y-120)/140),y) for x,y in outline]
    p.polygon(outline,fill=(117,38,17,int(215*(1-.42*s))))
    p.line(outline+[outline[0]],fill=(255,171,74,204),width=5)
    p.polygon([(94,48),(150,41),(155,190),(106,203)],fill=(215,125,51,int(204*(1-.37*s))))
    for j in range(95):
        x=int(rng.uniform(104,151));y=int(rng.uniform(52,195))
        p.ellipse((x,y,x+2,y+2),fill=(49,22,15,int(rng.uniform(23,120))))
    # Ink ignites progressively; exact flame poses are independently baked.
    strokes=[[(111,67),(148,69),(122,91),(149,99)],
             [(119,104),(145,119),(115,135)],
             [(143,140),(113,158),(150,171)],
             [(113,186),(145,186)]]
    for j,line in enumerate(strokes):
        progress=np.clip((s*5-j)/1.35,0,1)
        if progress<=0:continue
        count=max(2,int(len(line)*progress))
        p.line(line[:count],fill=(255,245,169,int(245*progress)),width=6,joint="curve")
        p.line(line[:count],fill=(255,253,227,int(218*progress)),width=2,joint="curve")
    base.alpha_composite(paper.filter(ImageFilter.GaussianBlur(5)))
    base.alpha_composite(paper)
    for j in range(6):
        a=i*.52+j*1.29; x=128+math.cos(a)*(39+j*3)
        y=132+math.sin(a)*(65+j*4)
        end=(x+math.sin(a)*13,y-22-7*math.sin(i*.73+j))
        pts=bezier((x,y),(x-9,y-15),(end[0]+8,end[1]+9),end)
        layered_stroke(base,pts,4 if j%2 else 7,(255,142+12*(j%4),48,136))
    return base

def impact_frame(i):
    w,h=288,224
    rng=np.random.default_rng(8191+i*193)
    base=underpaint("tal06_impact_atlas.webp",i,(w,h),.18)
    q=i/7.0;power=(1-q)**.75
    # One local molten collision against lower torso; smoke/ash sink to the feet.
    yy,xx=np.indices((h,w),dtype=np.float32)
    n=rng.random((h,w),dtype=np.float32)
    flame=np.exp(-(((xx-144)/(21+35*q))**2+((yy-123)/(28+37*q))**2))
    smoke=np.exp(-(((xx-144)/(61+35*q))**2+((yy-155)/(41+35*q))**2))*n
    layer=Image.fromarray(np.dstack([
        np.clip(163+84*flame,0,255).astype("uint8"),
        np.clip(62+174*flame,0,255).astype("uint8"),
        np.clip(22+93*flame,0,255).astype("uint8"),
        np.clip(flame*196*power+smoke*82*(.4+.6*power),0,235).astype("uint8")]),"RGBA")
    base.alpha_composite(layer)
    for lane in range(7):
        sign=1 if lane%2 else -1
        x=144+(lane-3)*12
        high=43+18*q+lane*2
        p0=(x,165)
        p1=(int(x+sign*(17+lane*2)),int(139-12*q))
        p2=(int(x-sign*18),int(112-15*power))
        p3=(int(x+sign*(9+lane*2)),int(high))
        pts=bezier(p0,p1,p2,p3)
        layered_stroke(base,pts,7 if lane<4 else 4,
                       (255,int(132+60*power),40,int((140-lane*7)*power)))
        if lane<3:layered_stroke(base,pts[:17],2,(255,244,178,int(145*power)))
    hot=Image.new("RGBA",(w,h));p=ImageDraw.Draw(hot,"RGBA")
    if i<5:
        size=int(19*(1-q)+4)
        p.ellipse((144-size,133-size,144+size,133+size),
                  fill=(255,250,216,int(217*power)))
    # Ground ash is horizontal and restrained; no fake AoE indicator or extra target.
    for j in range(47):
        x=int(rng.normal(144,45+14*q));y=int(rng.normal(181,10))
        if not 2<=x<w-2 or not 1<=y<h-2:continue
        r=int(rng.choice([1,1,2,3]))
        p.ellipse((x-r,y-r,x+r,y+r),fill=(255,170,77,int(rng.uniform(19,98)*(.6+.4*power))))
    base.alpha_composite(hot.filter(ImageFilter.GaussianBlur(6)))
    base.alpha_composite(hot)
    return base

def atlas(frames,w,h):
    out=Image.new("RGBA",(w*4,h*((len(frames)+3)//4)))
    for i,fr in enumerate(frames):
        out.alpha_composite(fr,((i%4)*w,(i//4)*h))
    return out

def main():
    outputs={
        "tal06_r4_seal_atlas.webp":atlas([seal_frame(i) for i in range(12)],256,256),
        "tal06_r4_comet_atlas.webp":atlas([comet_frame(i) for i in range(12)],384,224),
        "tal06_r4_impact_atlas.webp":atlas([impact_frame(i) for i in range(8)],288,224)}
    for name,im in outputs.items():
        p=ASSETS/name;im.save(p,quality=94,method=6,exact=True)
        assert im.getchannel("A").getextrema()==(0,im.getchannel("A").getextrema()[1])
        count=8 if "impact" in name else 12
        cell=(288,224) if count==8 else ((384,224) if "comet" in name else (256,256))
        hashes=set()
        for j in range(count):
            x=j%4*cell[0];y=j//4*cell[1]
            hashes.add(hashlib.sha256(im.crop((x,y,x+cell[0],y+cell[1])).tobytes()).hexdigest())
        assert len(hashes)==count,(name,len(hashes))
        print("HF01_R4_ATLAS",name,im.size,"bytes",p.stat().st_size,
              "sha256",hashlib.sha256(p.read_bytes()).hexdigest(),
              "unique_poses",len(hashes))
    print("HF01_R4_SPRITES_PASS")

if __name__=="__main__":main()
