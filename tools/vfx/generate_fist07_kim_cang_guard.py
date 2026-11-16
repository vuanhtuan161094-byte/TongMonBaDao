#!/usr/bin/env python3
"""Original pure-gold light armor VFX / Kim Cang Ho The. No rig, no stock pixels.

V1: 16 distinct ward frames in 4x4 of 256x256 (activation 0..3,
continuous breath 4..11, fade 12..15), and 8 guarded-hit reaction poses
in 4x2. RGBA PNG, source seed fixed; 6 MiB total uncompressed.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
from math import sin, cos, pi
import random

OUT = Path(__file__).resolve().parents[2] / 'godot/labs/combat_lab/fist07/assets/generated'
S = 2
CELL = 256
PIX = CELL*S
SEED = 71216

def empty(): return Image.new('RGBA',(PIX,PIX),(0,0,0,0))
def P(p):return (round(p[0]*S), round(p[1]*S))
def PTS(points):return [P(p) for p in points]
def cubic(a,b,c,d,steps=36):
    result=[]
    for i in range(steps+1):
        t=i/steps
        result.append(((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0],
                      (1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1]))
    return result

def glow_ribbon(canvas, path, width=3.0, strength=1., color='gold'):
    """Bloom + actual chromatic core; colored light lies on distinct spline poses."""
    g=empty();d=ImageDraw.Draw(g,'RGBA')
    if color=='gold': core=(255,249,207); mid=(255,204,58); outer=(246,150,18)
    else: core=(255,255,230);mid=(255,223,113);outer=(244,175,41)
    d.line(PTS(path),fill=(*outer,int(210*strength)),width=round((width+12)*S),joint='curve')
    canvas.alpha_composite(g.filter(ImageFilter.GaussianBlur(10*S)))
    g=empty();d=ImageDraw.Draw(g,'RGBA')
    d.line(PTS(path),fill=(*outer,int(123*strength)),width=round((width+5)*S),joint='curve')
    canvas.alpha_composite(g.filter(ImageFilter.GaussianBlur(3*S)))
    d=ImageDraw.Draw(canvas,'RGBA')
    d.line(PTS(path),fill=(*mid,int(236*strength)),width=max(1,round(width*1.25*S)),joint='curve')
    d.line(PTS(path),fill=(*core,int(245*strength)),width=max(1,round(width*.42*S)),joint='curve')

def soft_glow(canvas,cx,cy,rx,ry,alpha=95,blur=10,color=(253,184,47)):
    layer=empty();d=ImageDraw.Draw(layer,'RGBA')
    d.ellipse(((cx-rx)*S,(cy-ry)*S,(cx+rx)*S,(cy+ry)*S),fill=(*color,alpha))
    canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur*S)))

def poly(canvas,points,rgba,shadow=True):
    if shadow:
        g=empty();ImageDraw.Draw(g,'RGBA').polygon(PTS(points),fill=(240,150,21,78))
        canvas.alpha_composite(g.filter(ImageFilter.GaussianBlur(5*S)))
    ImageDraw.Draw(canvas,'RGBA').polygon(PTS(points),fill=rgba)

def shade_shard(img,points,brightness=1.):
    # Beveled gold prism: luminous left edge + transparent champagne center,
    # never full opaque gold plate covering the 3.5-head actor.
    poly(img,points,(253,192,62,round(94*brightness)))
    d=ImageDraw.Draw(img,'RGBA')
    d.line(PTS(points[:3]),fill=(255,230,127,round(204*brightness)),width=2*S,joint='curve')
    d.line(PTS([points[0],points[-1]]),fill=(255,246,196,round(243*brightness)),width=S)

def scatter(img,k,center,count,spread,opacity=1.):
    r=random.Random(SEED + k*107)
    d=ImageDraw.Draw(img,'RGBA')
    for i in range(count):
        x=center[0]+r.gauss(0,spread[0]);y=center[1]+r.gauss(0,spread[1])
        if not(10<x<246 and 9<y<247):continue
        rr=r.uniform(.3,1.45)
        a=int(opacity*r.randint(65,175))
        d.ellipse(((x-rr)*S,(y-rr)*S,(x+rr)*S,(y+rr)*S),fill=(255,231,140,a))
        if i%7==0:
            d.line(PTS([(x-3,y),(x+3,y)]),fill=(255,255,215,round(a*.56)),width=1)

def draw_ward(k):
    img=empty();r=random.Random(SEED+17*k)
    if k<4:
        q=(k+1)/4
        env=.34+.66*q
    elif k<12:
        q=1
        env=.91+.08*sin((k-4)*pi/4)
    else:
        q=max(.0,(16-k)/4)
        env=q*q*.89
    phase=k*.65
    breath=sin(phase)*3.0
    # The hero is negative-space architecture: separate side shield wings,
    # open head, chest and body. Pure yellow/gold light, no orange/brown rubble.
    soft_glow(img,128,132,67*q,103*q,int(87*env),19,color=(255,191,47))
    soft_glow(img,128,174,44*q,54*q,int(42*env),12,color=(255,233,103))
    for side in [-1,1]:
        shift=side*(3*sin(phase+side)+2*cos(phase*.8))
        x=128+side*(80*q)+shift
        # Outer pressure crest reaches overhead but never closes into a ring.
        arch=cubic((128+side*20,52-8*q),
                   (128+side*(99*q),61-breath),
                   (128+side*(124*q),132),
                   (128+side*(96*q),231+breath),44)
        glow_ribbon(img,arch,3.1,env*.98)
        # Shoulder and flank gold refractive armor facets, visually separated.
        for band in range(3):
            cy=98+band*45+breath*(.5+band*.08)
            xx=128+side*(77+6*sin(phase*.6+band+side)) * q
            pts=[(xx-side*16,cy-23),(xx+side*9,cy-31),
                 (xx+side*(17+4*sin(phase+band)),cy-1),
                 (xx+side*6,cy+24),(xx-side*8,cy+10)]
            shade_shard(img,pts,env*(.92-.07*band))
            gl=cubic((xx-side*13,cy-20),(xx+side*8,cy-27),
                     (xx+side*15,cy+8),(xx-side*2,cy+25),24)
            glow_ribbon(img,gl,2.2,env*.85)
        # Energetic sweep outside the shields: unequal lengths and changing
        # height so sustain is not rotating a single ring icon.
        a=91+19*sin(phase+side*.8)
        curl=cubic((128+side*42,28+a*.16),
                   (128+side*112,83+a*.26),
                   (128+side*104,179-8*sin(phase*.8)),
                   (128+side*61,241-a*.06),39)
        glow_ribbon(img,curl,1.35,env*.57)
    # Broken shoulder crest, no halo-ring UI around the character.
    for side in [-1,1]:
        top=cubic((128+side*18,48-2*breath),
                  (128+side*41,31-3*breath),
                  (128+side*69,46+2*breath),
                  (128+side*70,74+2*breath),20)
        glow_ribbon(img,top,2.8,env*.84)
    # A small brilliant sternum point, controlled bloom / not a white disk.
    soft_glow(img,128,139,16,19,int(147*env),8,color=(255,225,84))
    glow_ribbon(img,cubic((123,148),(129,142),(123,132),(128,128),14),1.9,env*.7)
    scatter(img,k,(128,145),42,(77,75),env*.9)
    if k>=12:
        # Different ending frame contents: released light filaments drift up.
        for i in range(6):
            xx=80+i*19+4*sin(k+i);yy=185-i*19-(k-12)*9
            p=cubic((xx,yy+8),(xx-3,yy),(xx+2,yy-9),(xx+4,yy-18),12)
            glow_ribbon(img,p,1.0,env*.5)
    return img.resize((CELL,CELL),Image.Resampling.LANCZOS)

def draw_reaction(k):
    """Guarded hit received from front-right: NOT a damage or outgoing skill."""
    img=empty();t=k/7.;env=(1-t)**1.12
    # Shield is pushed inward and then snaps back. Local impact x~166 y~123.
    center=(171+12*t,119-7*t)
    soft_glow(img,*center,38+28*t,31+25*t,int(120*env),13,(255,199,54))
    soft_glow(img,*center,18+14*t,14+12*t,int(164*env),5,(255,251,182))
    # Off-centered crescent, no huge circular screen-space ripple.
    arc=[]
    for i in range(33):
        a=-1.20 + 2.2*i/32
        rr=34+39*t+3*sin(5*a+k*.6)
        arc.append((center[0]+rr*cos(a),center[1]+rr*.85*sin(a)))
    glow_ribbon(img,arc,2.75,env)
    # Shattered bright filaments emitted from exact block point.
    r=random.Random(SEED+88*k)
    for j in range(11):
        a=-1.45+(j/10)*2.5+r.uniform(-.11,.11)
        length=(22+54*t)*r.uniform(.65,1.2)
        p=cubic(center,(center[0]+length*.3,center[1]+5*sin(a)),
                (center[0]+length*.68*cos(a),center[1]+length*.5*sin(a)),
                (center[0]+length*cos(a),center[1]+length*sin(a)),13)
        glow_ribbon(img,p,r.uniform(.8,2.1),env*(.66 if j%2 else .92))
    scatter(img,k+100,center,52,(53+25*t,42+27*t),env)
    return img.resize((CELL,CELL),Image.Resampling.LANCZOS)

def atlas(frames,cols,name):
    height=((len(frames)+cols-1)//cols)*CELL
    out=Image.new('RGBA',(cols*CELL,height),(0,0,0,0))
    for i,frame in enumerate(frames):out.alpha_composite(frame,((i%cols)*CELL,(i//cols)*CELL))
    OUT.mkdir(parents=True,exist_ok=True)
    fp=OUT/name;out.save(fp,optimize=True)
    assert out.getpixel((0,0))[3] == 0
    print('FIST07_PNG',name,'size=',out.size,'frames=',len(frames))

if __name__=='__main__':
    atlas([draw_ward(k) for k in range(16)],4,'gold_ward.png')
    atlas([draw_reaction(k) for k in range(8)],4,'guarded_hit.png')
    print('FIST07_ATLAS_PASS frames=24 textures=2 raw_rgba_bytes=6291456 no_rig=true')
