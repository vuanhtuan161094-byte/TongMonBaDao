#!/usr/bin/env python3
"""HF02 Liên Diệm Phần Giới — ORIGINAL first-party painted sprite atlas recipe.

This is independent of HF01 art, with four independently layered RGBA atlases:
12 ink/fire charge seals, 12 blooming fire-lotus poses, 8 scorched floor poses,
8 local contact tongues. Procedural *source painting* (Pillow/NumPy) is art
provenance, not proof of aesthetic quality. No third-party JX/Source A pixels.
Run BEFORE Godot import; view-only demo, no gameplay damage/status.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import math, hashlib

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/talisman07/assets"

def noise(w,h,seed):
    r=np.random.default_rng(seed)
    z=r.random((h,w),dtype=np.float32)
    im=Image.fromarray(np.uint8(z*255),'L')
    low=np.asarray(im.resize((max(2,w//7),max(2,h//7)),Image.Resampling.BILINEAR).resize((w,h),Image.Resampling.BICUBIC),dtype=np.float32)/255.
    return .47*z+.53*low

def rgba(a,r,g,b):
    a=np.uint8(np.clip(np.broadcast_to(a,np.broadcast_shapes(np.shape(a),np.shape(r),np.shape(g),np.shape(b))),0,255))
    shape=a.shape
    def ch(x):return np.uint8(np.clip(np.broadcast_to(x,shape),0,255))
    return Image.fromarray(np.stack([ch(r),ch(g),ch(b),a],axis=2),'RGBA')

def plume_layer(w,h,i,seed,scale=1.,cy=281):
    yy,xx=np.indices((h,w),dtype=np.float32)
    rng=np.random.default_rng(seed)
    t=i*.51
    n=noise(w,h,seed+13)
    gold=np.zeros((h,w),np.float32)
    hot=np.zeros((h,w),np.float32)
    smoke=np.zeros((h,w),np.float32)
    # Seven asymmetric lotus petals with actually changing, curved silhouettes.
    # Shape is built in a raster field, not a recolored still or HUD line.
    for k in range(7):
        foot=256+(k-3)*32+float(rng.uniform(-9,9))
        top=cy-(137+int(rng.uniform(10,100)))*scale
        tip_wiggle=math.sin(t+k*.9)*14
        stretch=(cy-top)
        u=np.clip((cy-yy)/stretch,0,1)
        line=foot+(k-3)*(35*u**1.2)+tip_wiggle*u+14*np.sin(u*4.6+t*.83+k*.8)*u
        width=(18+int(rng.uniform(10,27)))*(1-u)**.72*(.82+.22*np.sin(u*13+t+k))
        dx=np.abs(xx-line)
        body=np.clip(1-dx/(width+1.5),0,1)**1.45
        gate=np.clip((yy-top)/11,0,1)*np.clip((cy+7-yy)/19,0,1)
        body*=gate*(.65+.35*n)*(1-.06*k)
        gold=np.maximum(gold,body)
        inner=np.clip(1-dx/(width*.37+1.5),0,1)**1.3*gate
        hot=np.maximum(hot,inner*(.83-.32*u))
        smoke+=np.clip(1-dx/(width*2.1+7),0,1)*gate*.065
    # Low localized glow at roots, never a flat opaque circular HUD disc.
    root=np.exp(-(((xx-256)/139)**2+((yy-cy)/45)**2))* (0.4+.6*n)
    power=np.clip(gold*.94+root*.20,0,1)
    alpha= np.clip((219*power+60*hot+53*smoke)*(0.60+0.40*np.sin(min(1.,(i+1)/12)*math.pi/2)),0,247)
    rr=130+117*gold+24*n
    gg=30+143*gold+69*hot
    bb=13+46*gold+100*hot
    base=rgba(alpha,rr,gg,bb)
    # Original painterly inner filament and gilt ash: deliberate hot/cool contrast.
    strokes=Image.new('RGBA',(w,h));d=ImageDraw.Draw(strokes,'RGBA')
    for k in range(7):
        x=256+(k-3)*32
        top=int(cy-(132+11*k+18*math.sin(t+k*.67))*scale)
        mid=(x+int((k-3)*9+11*math.sin(t+k)),int(cy*.60+top*.40))
        d.line([(x,int(cy-17)),mid,(x+int((k-3)*25+9*math.cos(t+k)),top)],
               fill=(255,197+6*(k%4),86,90+20*(k%3)),width=3 if k%2 else 4,joint='curve')
    base.alpha_composite(strokes.filter(ImageFilter.GaussianBlur(5)))
    base.alpha_composite(strokes)
    return base

def lotus(i):
    w,h=512,384
    base=plume_layer(w,h,i,8100+i*71,1.0+0.045*math.sin(i*.65),286)
    rng=np.random.default_rng(20021+i)
    sparks=Image.new('RGBA',(w,h));d=ImageDraw.Draw(sparks,'RGBA')
    for j in range(53):
        x=int(rng.normal(256,115));y=int(rng.normal(221,98))
        if not(4<x<w-4 and 4<y<h-4):continue
        r=int(rng.choice([1,1,1,2,2,3]))
        d.ellipse((x-r,y-r,x+r,y+r),
            fill=(255,int(rng.uniform(125,225)),int(rng.uniform(35,96)),int(rng.uniform(45,175))))
    base.alpha_composite(sparks)
    return base

def seal(i):
    w=h=256;im=Image.new('RGBA',(w,h))
    rng=np.random.default_rng(3351+i*43)
    # Three small original burnt-ink talisman strips, offset in the air.
    l=Image.new('RGBA',(w,h));d=ImageDraw.Draw(l,'RGBA')
    phase=i/11
    for j in range(3):
        a=-.85+j*.82+i*.035
        xc=128+math.sin(a)*38
        yc=132+math.cos(a)*14-11*phase
        dx=math.sin(a)*9
        points=[(xc-16+dx,yc-49),(xc+19+dx,yc-53),
                (xc+14-dx,yc+43),(xc-18-dx,yc+40)]
        d.polygon(points,fill=(123,33,18,int(163+55*phase)))
        d.line(points+[points[0]],fill=(255,168,59,200),width=3,joint='curve')
        # Linked fire ink (not the 火 glyph from HF01).
        path=[(xc-7,yc-23),(xc+8,yc-12),(xc-9,yc+3),(xc+9,yc+14),(xc-5,yc+28)]
        n=max(2,min(len(path),int(phase*6)+1))
        d.line(path[:n],fill=(255,229,123,int(210*phase)),width=4,joint='curve')
    im.alpha_composite(l.filter(ImageFilter.GaussianBlur(7)))
    im.alpha_composite(l)
    for k in range(12):
        a=k*2.4+i*.14;x=128+math.cos(a)*rng.uniform(39,68)
        y=130+math.sin(a)*rng.uniform(35,65)
        d.ellipse((x-2,y-2,x+2,y+2),fill=(255,212,89,int(75+84*phase)))
    # source-baked sparks remain subordinate
    im.alpha_composite(l.filter(ImageFilter.GaussianBlur(2)))
    return im

def ground(i):
    w,h=512,256
    rng=np.random.default_rng(4321+i*143)
    yy,xx=np.indices((h,w),dtype=np.float32)
    n=noise(w,h,6000+i)
    phase=i/7.
    dx=xx-256;dy=yy-130
    elliptical=np.sqrt((dx/176)**2+(dy/73)**2)
    rag=np.sin(np.arctan2(dy,dx)*9+i*.45)*.065+np.cos(xx*.08+i*.24)*.045
    cracked=np.exp(-((elliptical-(.43+.20*phase+rag))/.083)**2)*n
    soot=np.exp(-((elliptical/.96)**2))*(.5+.7*n)
    alpha=np.clip((136*cracked+69*soot)*(1-.28*phase),0,171)
    im=rgba(alpha,161+72*n,51+104*cracked,17+43*n)
    p=Image.new('RGBA',(w,h));d=ImageDraw.Draw(p,'RGBA')
    # Broken irregular, grounded fissures. Intentionally no complete ring.
    for k in range(12):
        a=(k/12.)*2*math.pi+float(rng.uniform(-.21,.21))
        r=float(rng.uniform(34,126))
        x0=256+math.cos(a)*r;y0=130+math.sin(a)*r*.36
        x1=256+math.cos(a+.09)*(r+float(rng.uniform(20,48)))
        y1=130+math.sin(a+.09)*(r+float(rng.uniform(16,59)))*.40
        d.line([(x0,y0),((x0+x1)/2+float(rng.uniform(-10,10)),(y0+y1)/2),(x1,y1)],
               fill=(246,int(rng.uniform(105,180)),46,int(rng.uniform(54,146)*(1-.5*phase))),
               width=int(rng.integers(2,5)),joint='curve')
    im.alpha_composite(p.filter(ImageFilter.GaussianBlur(4)))
    im.alpha_composite(p)
    return im

def contact(i):
    w=h=256;rng=np.random.default_rng(900+i*59)
    yy,xx=np.indices((h,w),dtype=np.float32)
    n=noise(w,h,43000+i)
    q=i/7.; dx=xx-128;dy=yy-138
    phi=np.arctan2(dy,dx)
    rad=np.sqrt((dx/(33+42*q))**2+(dy/(48+24*q))**2)
    envelope=(1+.23*np.sin(phi*7+i*.63)+.13*np.sin(phi*11-i*.32))
    fire=np.exp(-(rad/envelope)**1.95)*(0.54+.57*n)*(1-.74*q)
    hot=np.exp(-((dx/23)**2+((dy+10)/26)**2))*(1-q)
    im=rgba(np.clip(194*fire+90*hot,0,252),155+98*fire,64+151*fire+38*hot,15+94*hot)
    emb=Image.new('RGBA',(w,h));d=ImageDraw.Draw(emb,'RGBA')
    for j in range(18):
        x=int(rng.normal(128,55));y=int(rng.normal(138,43))
        if not (3<x<252 and 3<y<252):continue
        r=int(rng.choice([1,1,2]))
        d.ellipse((x-r,y-r,x+r,y+r),fill=(255,183,69,int(rng.uniform(35,105)*(1-.68*q))))
    im.alpha_composite(emb)
    return im

def atlas(frames,cw,ch):
    im=Image.new('RGBA',(cw*4,ch*((len(frames)+3)//4)))
    for i,fr in enumerate(frames):im.alpha_composite(fr,(i%4*cw,i//4*ch))
    return im

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    assets={
      'tal07_lotus_flipbook.webp':(atlas([lotus(i) for i in range(12)],512,384),512,384,12),
      'tal07_seal_flipbook.webp':(atlas([seal(i) for i in range(12)],256,256),256,256,12),
      'tal07_ground_flipbook.webp':(atlas([ground(i) for i in range(8)],512,256),512,256,8),
      'tal07_contact_flipbook.webp':(atlas([contact(i) for i in range(8)],256,256),256,256,8)
    }
    for name,(im,cw,ch,count) in assets.items():
        assert im.getchannel('A').getextrema()[0]==0,name
        hashes={hashlib.sha256(im.crop((i%4*cw,i//4*ch,(i%4+1)*cw,(i//4+1)*ch)).tobytes()).hexdigest() for i in range(count)}
        assert len(hashes)==count,(name,len(hashes))
        path=OUT/name
        im.save(path,quality=93,method=5,exact=True)
        print('HF02_ASSET',name,im.size,'unique',len(hashes),'sha256',hashlib.sha256(path.read_bytes()).hexdigest(),'bytes',path.stat().st_size)
    print('HF02_SPRITE_ALPHA_GATE=PASS')

if __name__=='__main__':main()
