#!/usr/bin/env python3
"""FIST02 / Phi Than Lien Cuoc: original guard/footwork atlas. VIEW-ONLY.
Original first-party 12 twin-heel flame-stream poses, 8 asymmetric crossing-guard
poses, and 8 footprint-dust poses. Not damage, no rig, no proprietary sprite.
Requires Python Pillow and NumPy; all three 320px RGBA cell atlases are deterministic.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
from math import sin, cos, pi, exp
import random
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "godot/labs/combat_lab/fist02/assets/painted_v1"
CELL = 320
S = 2
SIZE = CELL * S
RANDOM_SEED = 2111402

def rgba_layer():
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

def pt(p):
    return tuple(int(round(a * S)) for a in p)

def stroke(draw, points, color, width):
    draw.line([pt(p) for p in points], fill=color,
              width=max(1, int(round(width*S))), joint="curve")
    for p in (points[0], points[-1]):
        radius = width*S/2
        x, y = pt(p)
        draw.ellipse((int(x-radius), int(y-radius),
                     int(x+radius), int(y+radius)), fill=color)

def blob(target, x, y, rx, ry, color, blur=17.0):
    layer = rgba_layer()
    draw = ImageDraw.Draw(layer, "RGBA")
    draw.ellipse((int((x-rx)*S),int((y-ry)*S),
                  int((x+rx)*S),int((y+ry)*S)), fill=color)
    target.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur*S)))

def curve(a,b,c,d,count=14):
    pts=[]
    for k in range(count+1):
        q=k/count
        x=(1-q)**3*a[0]+3*(1-q)**2*q*b[0]+3*(1-q)*q*q*c[0]+q**3*d[0]
        y=(1-q)**3*a[1]+3*(1-q)**2*q*b[1]+3*(1-q)*q*q*c[1]+q**3*d[1]
        pts.append((x,y))
    return pts

def sprinkle(im, rng, center=(164,160), count=150,
             spread=(120,78), bright=False):
    draw=ImageDraw.Draw(im,"RGBA")
    for i in range(count):
        x=rng.gauss(center[0],spread[0]/2)
        y=rng.gauss(center[1],spread[1]/2)
        if x<8 or x>312 or y<8 or y>312:
            continue
        r=rng.uniform(.35,1.6)
        col = (255,224,157,rng.randint(12,75)) if bright else (
            172+rng.randint(0,65), 75+rng.randint(0,83),
            45+rng.randint(0,65), rng.randint(8,54))
        draw.ellipse((int((x-r)*S),int((y-r)*S),
                      int((x+r)*S),int((y+r)*S)),fill=col)


def _path_light(img, path, seed, base_alpha=1.0):
    """Luminous brush with a broad broken umber pigment, soft golden middle and white tip."""
    rng=random.Random(seed)
    dark=rgba_layer()
    d=ImageDraw.Draw(dark,"RGBA")
    stroke(dark_draw:=d, path, (99,39,35,int(47*base_alpha)), 17)
    img.alpha_composite(dark.filter(ImageFilter.GaussianBlur(13*S)))
    d=ImageDraw.Draw(img,"RGBA")
    stroke(d,path,(165,71,42,int(49*base_alpha)),8.1)
    stroke(d,path[3:-2],(246,133,57,int(96*base_alpha)),4.3)
    stroke(d,path[len(path)//3:],(255,212,126,int(128*base_alpha)),1.75)
    # broken uneven internal highlights: different placement on each frame
    for j in range(7):
        start=rng.randint(3,max(3,len(path)-9))
        segment=path[start:start+rng.randint(3,7)]
        stroke(d,segment,(255,238,183,rng.randint(44,136)),rng.uniform(.48,1.3))

def heel_pose(k):
    """Two separate swift heel-energy streaks; hero form is not a combat hit."""
    rng=random.Random(RANDOM_SEED+100+k)
    phase=2*pi*k/12.
    im=rgba_layer()
    for j in range(2):
        sign=1 if j==0 else -1
        xshift=11*sin(phase+j*1.9)
        yshift=14*cos(phase*1.13+j*.9)
        a=(35+j*13,174+sign*(26+9*sin(phase))+yshift)
        b=(78+xshift,102+sign*36+9*cos(phase+j))
        c=(187-10*j,149-sign*34+yshift)
        d=(269+9*sin(phase),165+sign*(8+4*cos(phase+j)))
        p=curve(a,b,c,d,42)
        _path_light(im,p,RANDOM_SEED+200+k*11+j,1.0)
        tail=p[-9:]
        ImageDraw.Draw(im,"RGBA").ellipse((int((d[0]-6)*S),int((d[1]-5)*S),int((d[0]+6)*S),int((d[1]+5)*S)),fill=(255,238,176,110))
        for m in range(5):
            x=d[0]-rng.uniform(0,32)
            y=d[1]+rng.uniform(-20,20)
            pp=curve((x-17,y),(x-4,y-8),(x+7,y+5),(x+15,y),8)
            stroke(ImageDraw.Draw(im,"RGBA"),pp,(255,176,80,rng.randint(34,104)),rng.uniform(.6,1.4))
    sprinkle(im,rng,(154,164),95,(178,132),True)
    return im.resize((CELL,CELL),Image.Resampling.LANCZOS)

def guard_pose(k):
    """Breathing interrupted crossed oval guard, energy remains around ONE actor only."""
    rng=random.Random(RANDOM_SEED+500+k)
    phase=2*pi*k/8.
    im=rgba_layer()
    for j in range(3):
        lane=float(j)-1.0
        path=[]
        # crescent segments not full concentric neon rings
        for t in range(58):
            a=-0.77+2.47*t/57+j*2.10+phase*.09
            r=98+lane*10+9*sin(2.9*a+phase*.9+j)
            path.append((160+r*cos(a),160+(.86*r)*sin(a)))
        _path_light(im,path,RANDOM_SEED+620+k*17+j,.61 if j!=1 else .83)
    d=ImageDraw.Draw(im,"RGBA")
    for m in range(9):
        a=m*2.399+phase*.31
        rr=82+20*(m%3)+5*sin(phase+m)
        x=160+rr*cos(a)
        y=160+rr*sin(a)*.86
        p=curve((x-9,y-4),(x-2,y-10),(x+8,y+5),(x+15,y+2),8)
        stroke(d,p,(255,197,100,rng.randint(42,118)),rng.uniform(.7,1.5))
    sprinkle(im,rng,(160,160),80,(198,211),True)
    return im.resize((CELL,CELL),Image.Resampling.LANCZOS)

def footfall_pose(k):
    """Small physical footfall plumes, not an attack crater or AoE marker."""
    rng=random.Random(RANDOM_SEED+1100+k)
    t=k/7.
    im=rgba_layer()
    # Two distinct contact points, not a full large shockwave
    for j in range(2):
        x=105+j*114+10*sin(k*.72+j)
        y=215-6*cos(k*.57+j)
        blob(im,x,y,33+23*t,14+9*t,(111,82,77,int(43*(1-.63*t))),17)
        d=ImageDraw.Draw(im,"RGBA")
        for n in range(19):
            dx=rng.uniform(-43,43)*(1+.4*t)
            dy=rng.uniform(-19,9)
            xx=x+dx
            yy=y+dy
            rr=rng.uniform(.7,3.1)*(1-.35*t)
            d.polygon([pt((xx-rr,yy)),pt((xx+rr*.7,yy-rr)),pt((xx+rr,yy+rr))],
                      fill=(149+rng.randint(0,52),99+rng.randint(0,50),
                            63+rng.randint(0,42),int(rng.randint(37,140)*(1-.63*t))))
    sprinkle(im,rng,(163,219),44,(182,53),False)
    return im.resize((CELL,CELL),Image.Resampling.LANCZOS)

def atlas(frames, cols, path):
    rows=(len(frames)+cols-1)//cols
    sheet=Image.new("RGBA",(cols*CELL,rows*CELL),(0,0,0,0))
    for i,frame in enumerate(frames):
        sheet.alpha_composite(frame,(i%cols*CELL,i//cols*CELL))
    path.parent.mkdir(parents=True,exist_ok=True)
    sheet.save(path,optimize=True)
    assert sheet.mode=="RGBA" and sheet.getpixel((0,0))[3]==0
    print(f"PAINTED_FIST_ATLAS={path.name} size={sheet.size} frames={len(frames)}")

if __name__=="__main__":
    atlas([heel_pose(i) for i in range(12)],4,OUT/"heel_motion.png")
    atlas([guard_pose(i) for i in range(8)],4,OUT/"guard_crossflow.png")
    atlas([footfall_pose(i) for i in range(8)],4,OUT/"footfall_dust.png")
    print("VFX_FIST02_RASTER_GEN_PASS=1 frames=28 alpha=RGBA no_rig=1")
