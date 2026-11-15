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
    """A single cohesive, volumetric plume with an ivory-hot impact head."""
    w,h=384,224
    yy,xx=np.indices((h,w),dtype=np.float32)
    rng=np.random.default_rng(64018+i*177)
    phase=i*.43
    head=307+4*math.sin(phase)
    tail=np.clip((head-xx)/296.0,0,1)
    axis=112+17*np.sin(xx*.026+phase)*tail+7*np.sin(xx*.063-phase*.7)*tail
    tex=rng.random((h,w),dtype=np.float32)
    flutter=.22*np.sin(xx*.13+yy*.055+phase*2)+.14*np.sin(xx*.069-yy*.11-phase)
    width=(9+55*tail**.82)*np.clip(1+flutter,.55,1.40)
    dist=np.abs(yy-axis)
    density=np.exp(-((dist/(width+1))**1.58))*tail**.26
    density*=np.clip(.71+.25*tex+.17*np.sin(xx*.087+yy*.12+phase),.35,1.25)
    envelope=np.clip((head-xx+24)/31,0,1)*np.clip((xx-6)/26,0,1)
    density*=envelope
    # Thick feathered asymmetric flame lobes break the silhouette like paint.
    for lane in range(5):
        sign=-1 if lane%2 else 1
        cx=251-lane*40+16*math.sin(phase+lane*1.2)
        cy=112+sign*(15+lane*12)+12*math.sin(phase*1.5+lane)
        plume=np.exp(-((xx-cx)/(39+lane*8))**2-((yy-cy)/(17+lane*3))**2)
        density=np.maximum(density,plume*(.53+.21*math.sin(phase+lane)**2))
    core=np.exp(-((yy-axis)/(6+16*tail))**2)*np.clip((xx-124)/155,0,1)*envelope
    orb=np.exp(-((xx-head+9)/22)**2-((yy-112)/18)**2)
    fire=np.clip(density*.9+core*.48+orb*.65,0,1.2)
    hot=np.clip(core*.76+orb*.95,0,1)
    alpha=np.clip((180*fire+57*hot)*(1-.18*tail),0,253).astype(np.uint8)
    red=np.clip(126+116*fire+19*tex,0,255).astype(np.uint8)
    green=np.clip(29+132*fire+86*hot,0,255).astype(np.uint8)
    blue=np.clip(11+41*fire+140*hot,0,255).astype(np.uint8)
    im=Image.fromarray(np.dstack([red,green,blue,alpha]),"RGBA")
    im.alpha_composite(underpaint("tal06_fire_comet_atlas.webp",i,(w,h),.08))
    # Four broad curling flame flakes only, subordinate to the painted body.
    glow=Image.new("RGBA",(w,h));d=ImageDraw.Draw(glow,"RGBA")
    for lane in range(4):
        side=1 if lane%2 else -1
        x0=282-lane*20
        x1=119-lane*23+12*math.sin(phase+lane)
        y0=112+side*(9+lane*8)
        y1=112+side*(29+lane*11)+14*math.sin(phase*1.5+lane)
        pts=bezier((x0,y0),(x0-35,y0+side*12),(x1+28,y1-side*15),(x1,y1),28)
        d.line(pts,fill=(255,111+25*lane,38,125-lane*17),width=17-lane*2,joint="curve")
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(8)))
    a=glow.getchannel("A").point(lambda v:int(v*.28));glow.putalpha(a)
    im.alpha_composite(glow)
    headlayer=Image.new("RGBA",(w,h));d=ImageDraw.Draw(headlayer,"RGBA")
    d.ellipse((head-30,92,head+14,132),fill=(255,177,68,185))
    d.ellipse((head-19,101,head+12,124),fill=(255,247,190,231))
    d.ellipse((head-7,105,head+11,119),fill=(255,254,240,248))
    im.alpha_composite(headlayer.filter(ImageFilter.GaussianBlur(9)))
    im.alpha_composite(headlayer)
    emb=Image.new("RGBA",(w,h));d=ImageDraw.Draw(emb,"RGBA")
    for j in range(32):
        x=int(rng.uniform(8,270));y=int(rng.normal(112,42));r=int(rng.choice([1,1,2,3]))
        d.ellipse((x-r,y-r,x+r,y+r),fill=(255,int(rng.uniform(144,232)),45,int(rng.uniform(32,126))))
    im.alpha_composite(emb)
    return im

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
    """One forceful body-local flame bloom with a broken, melting edge."""
    w,h=288,224
    yy,xx=np.indices((h,w),dtype=np.float32)
    rng=np.random.default_rng(8191+i*193)
    q=i/7.0;live=(1-q)**.76
    dx=xx-144;dy=yy-127
    a=np.arctan2(dy,dx)
    turbulence=.15*np.sin(7*a+i*.49)+.11*np.cos(11*a-i*.59)
    feather=.09*np.sin(xx*.17+yy*.07+i*.65)+.07*np.cos(xx*.09-yy*.15)
    dist=np.sqrt((dx/(71-19*q))**2+(dy/(64-13*q))**2)
    edge=np.clip(.87+turbulence+feather,.45,1.30)
    bloom=np.exp(-(dist/(edge+.02))**2.4)
    core=np.exp(-((dx/(23+7*q))**2+(dy/(28+9*q))**2))
    upper=np.exp(-((dx/(38+22*q))**2+((dy+46+15*q)/(41+8*q))**2))
    grain=rng.random((h,w),dtype=np.float32)
    fire=np.clip(bloom*.87+upper*.45+core*.31,0,1.25)
    alpha=np.clip((201*fire+51*grain*fire)*live,0,253).astype(np.uint8)
    red=np.clip(120+130*fire+24*grain,0,255).astype(np.uint8)
    green=np.clip(36+152*fire+71*core,0,255).astype(np.uint8)
    blue=np.clip(12+47*fire+148*core,0,255).astype(np.uint8)
    im=Image.fromarray(np.dstack([red,green,blue,alpha]),"RGBA")
    im.alpha_composite(underpaint("tal06_impact_atlas.webp",i,(w,h),.08))
    # Paint hot internal irregular fissures; never star spokes or global AoE.
    glaze=Image.new("RGBA",(w,h));d=ImageDraw.Draw(glaze,"RGBA")
    for k in range(5):
        sign=-1 if k%2 else 1
        start=(145+sign*(7+k*5),135+7*k)
        end=(int(140+sign*(27+k*9)),int(41+15*q+5*k))
        pts=bezier(start,(start[0]+sign*29,105),(end[0]-sign*24,76),end,25)
        d.line(pts,fill=(255,int(159+50*live),54,int(162*live)),width=10-k,joint="curve")
    im.alpha_composite(glaze.filter(ImageFilter.GaussianBlur(7)))
    a0=glaze.getchannel("A").point(lambda v:int(v*.38));glaze.putalpha(a0)
    im.alpha_composite(glaze)
    spec=Image.new("RGBA",(w,h));d=ImageDraw.Draw(spec,"RGBA")
    if i<5:
        rad=int(17*live+7)
        d.ellipse((144-rad,127-rad,144+rad,127+rad),fill=(255,250,220,int(214*live)))
    # Tumbling burnt embers near the base fade after impact.
    for k in range(42):
        px=int(rng.normal(144,50));py=int(rng.normal(174,19))
        if not 2<px<w-3 or not 2<py<h-3:continue
        r=int(rng.choice([1,1,2,3]))
        d.ellipse((px-r,py-r,px+r,py+r),fill=(255,147+int(rng.uniform(0,80)),50,int(rng.uniform(33,115)*live)))
    im.alpha_composite(spec.filter(ImageFilter.GaussianBlur(5)))
    im.alpha_composite(spec)
    return im

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
