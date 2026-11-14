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
import numpy as np

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

def _fractal_noise(seed, dimensions=(SIZE,SIZE)):
    """Original coarse-to-fine chromatic noise, no external pixel sources."""
    rng=np.random.default_rng(seed)
    h,w=dimensions
    field=np.zeros((h,w),dtype=np.float32)
    for cells,weight in ((5,.33),(11,.24),(24,.19),(55,.13),(115,.11)):
        tile=rng.integers(0,256,(cells,cells),dtype=np.uint8)
        layer=Image.fromarray(tile,mode="L").resize((w,h),Image.Resampling.BICUBIC)
        field+=np.asarray(layer,dtype=np.float32)/255.*weight
    return np.clip(field,0,1)

def hero_pose(k):
    """Original painted plasma fist: irregular turbulent knuckle core and smoky wake.
    Fist identity comes from four living hot knuckle pressure pockets, not
    an opaque cartoon mitt. Each of the 12 poses warps actual raster material.
    """
    rng=random.Random(RANDOM_SEED+220+k)
    t=k/11.
    phase=k*.76
    noise=_fractal_noise(RANDOM_SEED+220+k)
    noise_detail=_fractal_noise(RANDOM_SEED+900+k)
    yy,xx=np.mgrid[0:SIZE,0:SIZE].astype(np.float32)
    xx/=S
    yy/=S
    front=253+13*sin(phase*.9)
    # Flow warps across the entire sheet: broad curling smoke plus fine shredding.
    swirl=20*np.sin((xx-23)*.034+phase)*np.clip((front-xx)/190.,0,1)
    swirl+=7*np.sin(xx*.071-phase*1.4)
    wavy=yy-159.-swirl
    # Blast widens into four blunt hot lobes like an actual fist impact.
    body=np.exp(-((xx-(204+9*sin(phase)))/70)**2-(wavy/34)**2)
    crown=np.exp(-((xx-(front-18))/45)**2-(wavy/45)**2)
    tail=np.exp(-((xx-125)/97)**2-(wavy/(21+6*sin(phase)**2))**2)
    knuckles=np.zeros_like(body)
    for j in range(4):
        knuckle_y=(-28+j*18)+3*sin(phase+j*1.4)
        knot=np.exp(-((xx-(front+6+4*sin(j+phase)))/15)**2 -
                    ((wavy-knuckle_y)/12)**2)
        knuckles=np.maximum(knuckles,knot)
    # Torn edges: real alpha lost in coarse dark strokes, never a flat disk.
    erosion=np.clip((noise-.32)*2.6 + (noise_detail-.5)*.45,0,1)
    gas=(tail*.48+body*.67+crown*.62)*erosion
    density=np.clip(gas+knuckles*.42,0,1)
    leftfade=np.clip((xx-20)/33.,0,1)
    rightfade=np.clip((318-xx)/32.,0,1)
    fade=leftfade*rightfade
    alpha=np.clip((density-.095)*285,0,212)*fade
    # Rich luminous pigment: black plum -> umber -> ember -> gold -> milk white.
    photon=np.clip(knuckles*.84+crown*.32 + noise_detail*.14*body,0,1)
    warmth=np.clip((body+crown*.45)*(.47+noise*.62),0,1)
    r=np.clip(119+116*warmth+34*photon+33*noise_detail,0,255)
    g=np.clip(48+105*warmth+101*photon+22*noise_detail,0,255)
    b=np.clip(47+33*warmth+115*photon,0,255)
    rgba=np.stack([r,g,b,alpha],axis=-1).astype(np.uint8)
    img=Image.fromarray(rgba,"RGBA")
    # Controlled, very thin hot highlights and painterly scraps on top:
    # no nine identical parallel stripes.
    energy=Image.new("RGBA",(SIZE,SIZE),(0,0,0,0))
    d=ImageDraw.Draw(energy,"RGBA")
    for j in range(14):
        lane=j-6.5
        seed=j*2.399+k*.71
        x0=23+rng.uniform(7,78)
        y0=159+lane*8.3+rng.uniform(-9,9)
        x1=front-rng.uniform(10,57)
        y1=159+lane*rng.uniform(3.2,6.5)
        pts=curve((x0,y0),
                  (101+rng.uniform(-18,19),y0-28*sin(seed)),
                  (178+rng.uniform(-15,25),y1+19*sin(seed*1.7)),
                  (x1,y1),18)
        width=rng.uniform(.7,3.1)
        if j%3:
            stroke(d,pts,(248,136+rng.randint(0,40),73, rng.randint(47,96)),width)
        else:
            stroke(d,pts[8:],(255,218,146, rng.randint(75,142)),width*.65)
    energy=energy.filter(ImageFilter.GaussianBlur(.75*S))
    img.alpha_composite(energy)
    # Isolated ash and bright grain over the softer plasma shape.
    sprinkle(img,rng,(174,158),76,(176,97),True)
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
