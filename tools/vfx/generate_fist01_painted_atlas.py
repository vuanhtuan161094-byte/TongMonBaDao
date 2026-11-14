#!/usr/bin/env python3
"""FIST01 R9 original raster sprite factory. Requires Pillow, no rig, no external art.
Produce transparent, reproducible 320x320 alpha-frame atlases for Godot:
hero 4x3 (12), charge 4x2 (8), contact 4x2 (8).
All geometry hand-authored with per-pose brush, grain and physically readable
compressed fist silhouette. Transparent background and no decorative UI/text.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
from math import sin, cos, pi, exp
import random

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "godot/labs/combat_lab/fist01/assets/painted_r9"
CELL = 320
S = 2
SIZE = CELL * S
RANDOM_SEED = 890114

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

def charge_pose(k):
    rng=random.Random(RANDOM_SEED+100+k)
    t=k/7
    img=rgba_layer()
    cx,cy=163+2*sin(k*.7),165+2*cos(k*1.1)
    blob(img,cx,cy,62,59,(218,102,53,int(65+24*t)),20)
    d=ImageDraw.Draw(img,"RGBA")
    for j in range(13):
        a=j*2.399+k*.39
        far=110-(62*t)+rng.uniform(-12,12)
        start=(cx+cos(a)*far,cy+sin(a)*far*.80)
        ending=(cx+cos(a+1.1)*(14+5*(1-t)),
                cy+sin(a+1.1)*13)
        pts=curve(start,(cx+cos(a+.3)*far*.64,cy+sin(a+.3)*far*.49),
                  (cx+cos(a+.7)*far*.21,cy+sin(a+.7)*far*.25),ending,12)
        stroke(d,pts,(252,159,77,int(65+110*t)),rng.uniform(.6,2.2))
        if j%4==0:
            stroke(d,pts[6:],(255,244,191,int(70+105*t)),.9)
    # A painterly compressed knot at the wrist: NOT a generic neon circle.
    blob(img,cx+9,cy-2,29+6*t,19+6*t,(248,162,76,int(86+55*t)),8)
    d=ImageDraw.Draw(img,"RGBA")
    for j in range(6):
        base=cy+(j-2.5)*7
        ps=curve((cx-34+rng.uniform(-8,8),base),
                 (cx-5,base-15),
                 (cx+16,base+rng.uniform(-7,7)),
                 (cx+30,cy+rng.uniform(-11,10)),12)
        stroke(d,ps,(251,166+j*9,78+j*5,int(65+11*j+14*t)),1.6+j*.35)
    sprinkle(img,rng,(cx,cy),70,(114,93),True)
    return img.resize((CELL,CELL),Image.Resampling.LANCZOS)

def hero_pose(k):
    rng=random.Random(RANDOM_SEED+220+k)
    t=k/11
    img=rgba_layer()
    yy=159+4*sin(k*.81)
    lead=267+4*cos(k*.57)
    blob(img,174,yy,120,61,(234,112,54,105),26)
    blob(img,lead-16,yy,51,51,(255,178,82,122),13)
    d=ImageDraw.Draw(img,"RGBA")
    # Seven broken, individually moving flames shaped like thick brush-ink
    # on compressed air; no opaque rectangle and no simple flat triangle.
    for j in range(9):
        lane=j-4
        phase=k*.67+j*2.43
        x0=rng.uniform(17,72)+j*2
        y0=yy+lane*13+rng.uniform(-8,8)
        x1=lead-27-abs(lane)*8
        y1=yy+lane*6+rng.uniform(-7,7)
        path=curve((x0,y0),(102+rng.uniform(-10,12),y0-16),
                   (179+rng.uniform(-14,14),y1+7*sin(phase)),
                   (x1,y1),19)
        w=2.1+j%4*1.6
        stroke(d,path,(135,58,58,int(65+30*sin(phase)**2)),w+6)
        stroke(d,path,(246,127,59,int(100+35*sin(phase)**2)),w+2)
        stroke(d,path,(255,198,108,int(120+40*sin(phase)**2)),w*.65)
        if j%3==1:
            stroke(d,path[8:],(255,243,194,180),max(.65,w*.18))
    # Hand-painted fist-shaped concentrated energy head, not a spear tip:
    # wrist -> palm -> upper/lower knuckles, blunt front wall.
    shift=4*sin(k*.66)
    contour=[(171,yy-22),(200,yy-37),(227,yy-34),
             (240,yy-45+shift),(254,yy-44+shift),(259,yy-35),
             (271,yy-39),(278,yy-29),(279,yy-20),
             (285,yy-14),(285,yy-4),
             (282,yy+3),(287,yy+10),(282,yy+23),
             (270,yy+29),(260,yy+30),(253,yy+36),
             (240,yy+39),(223,yy+37),(201,yy+30),(173,yy+19)]
    contour=[(x+(lead-267)*.38,y) for x,y in contour]
    body=rgba_layer()
    bd=ImageDraw.Draw(body,"RGBA")
    bd.polygon([pt(p) for p in contour],fill=(132,56,46,195))
    img.alpha_composite(body.filter(ImageFilter.GaussianBlur(6*S)))
    d=ImageDraw.Draw(img,"RGBA")
    d.polygon([pt(p) for p in contour],fill=(228,110,51,140))
    # Body has multiple warm value bands and textured brush scuffs.
    for j in range(5):
        cy=yy-21+j*11+rng.uniform(-2,2)
        c=curve((198,cy),(222,cy-10),(249,cy-6),(272,cy+2),12)
        stroke(d,c,(255,176+j*10,87+j*12,98+j*14),rng.uniform(2,4))
    # Individual gilded knuckle caps give a recognizable, CLOSED fist head.
    for j in range(4):
        by=yy-29+j*17
        x=271+2*sin(k*.72+j)
        draw=ImageDraw.Draw(img,"RGBA")
        draw.arc((int((x-13)*S),int((by-9)*S),
                  int((x+9)*S),int((by+10)*S)),
                 210,345, fill=(255,241,177,170), width=3*S)
        draw.arc((int((x-11)*S),int((by-6)*S),
                  int((x+6)*S),int((by+7)*S)),
                 206,338, fill=(255,252,224,134), width=S)
    for j in range(24):
        x=rng.uniform(125,288); y=yy+rng.uniform(-49,48)
        if rng.random()<.52:
            stroke(d,[(x,y),(x+rng.uniform(3,12),y+rng.uniform(-5,5))],
                   (255,229,176,rng.randint(15,75)),rng.uniform(.35,1.2))
    sprinkle(img,rng,(160,yy),130,(165,94),True)
    return img.resize((CELL,CELL),Image.Resampling.LANCZOS)

def impact_pose(k):
    rng=random.Random(RANDOM_SEED+410+k)
    t=k/7
    img=rgba_layer()
    glow=(1-t)**.7
    blob(img,162+11*t,160,59+41*t,41+29*t,
         (243,133,69,int(95*glow)),19)
    d=ImageDraw.Draw(img,"RGBA")
    # Forward-biased concussive cloud; irregular brush petals, no icon-star.
    for j in range(11):
        a=rng.uniform(-1.15,1.10)
        ox=151+rng.uniform(-10,7)
        oy=163+rng.uniform(-16,15)
        length=(42+85*t)*rng.uniform(.45,.99)
        end=(ox+length*cos(a),oy+length*sin(a)*.75)
        bend=(ox+length*.53,oy+length*.4*sin(a))
        pts=curve((ox,oy),(ox+27,bend[1]-rng.uniform(5,25)),
                  (end[0]-22,bend[1]+rng.uniform(-16,16)),end,14)
        width=(9+7*int(j%3))*(1-.68*t)
        stroke(d,pts,(113,60,57,int(56*glow)),width+5)
        stroke(d,pts,(235,137,77,int(75*glow)),max(1,width*.43))
        if j%4==0:
            stroke(d,pts[8:],(255,229,147,int(89*glow)),1.3)
    # Small displaced grit, not radial star tips.
    for j in range(64):
        theta=rng.uniform(-pi,pi)
        dist=(27+115*t)*rng.uniform(.16,1)
        x=163+dist*cos(theta)+15*t
        y=170+dist*sin(theta)*.68
        r=rng.uniform(.8,4.4)*(1-.49*t)
        col=(158+rng.randint(0,78),102+rng.randint(0,58),
             67+rng.randint(0,45),int(rng.uniform(35,156)*glow))
        d.polygon([pt((x-r,y-r*.6)),pt((x+r*.6,y-r)),
                   pt((x+r,y+.3*r)),pt((x-r*.4,y+r))],fill=col)
    if k<4:
        blob(img,164,157,22+8*t,15+7*t,
             (255,249,209,int(135*(1-k/4))),7)
    sprinkle(img,rng,(173,167),95,(150,103),False)
    return img.resize((CELL,CELL),Image.Resampling.LANCZOS)

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
    atlas([charge_pose(i) for i in range(8)],4,OUT/"fist_charge_r9.png")
    atlas([hero_pose(i) for i in range(12)],4,OUT/"fist_hero_r9.png")
    atlas([impact_pose(i) for i in range(8)],4,OUT/"fist_impact_r9.png")
    print("FIST_R9_PAINTED_GENERATOR=PASS alpha=true no_rig=true")
