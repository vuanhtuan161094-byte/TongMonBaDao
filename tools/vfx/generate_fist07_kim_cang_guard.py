#!/usr/bin/env python3
"""Original pure-gold light armor VFX / Kim Cang Ho The. No rig, no stock pixels.

R2: 16 independent saturated gold plasma-ward frames in 4x4 of 256x256 (activation 0..3,
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

def flame_band(canvas, points, fat, strength, seed, phase):
    """A painted, variable-width luminous silk plume: gold fluid body with
    soft feathered alpha, fine irregular white-hot filament and sharp tip.
    It is original raster art, NOT a flat SVG polygon / concentric GUI ring.
    """
    import math
    rng=random.Random(seed)
    if len(points)<8:return
    n=len(points)
    offsets=[]
    for j,p in enumerate(points):
        u=j/(n-1)
        a=points[max(0,j-1)];b=points[min(n-1,j+1)]
        dx=b[0]-a[0];dy=b[1]-a[1]
        length=max(.001,math.hypot(dx,dy))
        nx,ny=-dy/length,dx/length
        # width tapers into sharp tips; uneven live light on the sides.
        shape=max(.02,math.sin(math.pi*u))**.85
        shape*=.89+.12*math.sin(u*11.0+phase)+.09*math.sin(u*23.0+seed*.1)
        offsets.append((p[0],p[1],nx,ny,shape))
    def boundary(frac=1.):
        l=[];r=[]
        for u,(x,y,nx,ny,w) in enumerate(offsets):
            bend=.11*math.sin(u*.63+phase)
            l.append((x+nx*fat*w*frac*(1+bend),y+ny*fat*w*frac*(1+bend)))
            r.append((x-nx*fat*w*frac*(1-bend),y-ny*fat*w*frac*(1-bend)))
        return PTS(l+list(reversed(r)))
    g=empty();draw=ImageDraw.Draw(g,'RGBA')
    draw.polygon(boundary(2.5),fill=(244,166,18,round(strength*134)))
    canvas.alpha_composite(g.filter(ImageFilter.GaussianBlur(9*S)))
    g=empty();draw=ImageDraw.Draw(g,'RGBA')
    draw.polygon(boundary(1.25),fill=(255,186,29,round(strength*172)))
    canvas.alpha_composite(g.filter(ImageFilter.GaussianBlur(2.5*S)))
    draw=ImageDraw.Draw(canvas,'RGBA')
    draw.polygon(boundary(1.0),fill=(255,207,35,round(strength*214)))
    draw.polygon(boundary(.45),fill=(255,240,115,round(strength*216)))
    draw.line(PTS(points[3:-2]),fill=(255,251,201,round(strength*255)),width=max(1,round((1.85+.12*fat)*S)),joint='curve')
    # Broken smaller plasma traces inside the wide light, never parallel lines.
    for m in range(5):
        first=rng.randrange(3,n-13)
        section=points[first:first+rng.randint(5,11)]
        draw.line(PTS(section),fill=(255,255,232,round(strength*rng.randint(80,165))),width=S)

def draw_ward(k):
    """Pure luminous armor — shaped, flowing pressure, NO schematic plates."""
    img=empty()
    rng=random.Random(SEED+k*101)
    phase=k*.76
    if k<4:
        progression=(k+1)/4.
        strength=.47+.53*progression
    elif k<12:
        progression=1.0
        strength=.94+.06*sin(phase)
    else:
        progression=max(.02,(16-k)/4.)
        strength=progression*.96
    breath=sin(phase)*4.3
    # Back-light has saturated pure gold, never smoky brown texture.
    soft_glow(img,128,153,56*progression,88*progression,int(83*strength),18,color=(255,210,55))
    soft_glow(img,128,168,35*progression,42*progression,int(61*strength),11,color=(255,240,102))
    for side in [-1,1]:
        # Outer protective silk curls around the actor, terminates in sharp
        # golden crown rather than completing a geometric circle.
        outer=cubic((128+side*(57*progression),238),
                    (128+side*(112*progression),194+breath),
                    (128+side*(116*progression),72-breath),
                    (128+side*(32+4*cos(phase+side)),45),40)
        flame_band(img,outer,8.5,strength*.92,SEED+k*11+side,phase)
        # Second live wing follows a different asymmetrical path and tempo.
        inner=cubic((128+side*(48*progression),219+breath),
                    (128+side*(88*progression),202),
                    (128+side*(81*progression),90-8*sin(phase*.8+side)),
                    (128+side*(58*progression),74+6*cos(phase+side)),40)
        flame_band(img,inner,5.8,strength*.75,SEED+200+k*31+side,phase*1.3+side)
        # Three tapered moving flame plates, not polygons/physical armor.
        for j in range(3):
            origin=(128+side*(48+5*sin(phase+j*1.3+side)),207-j*46+breath)
            tip=(128+side*(88+6*cos(phase*.8+j)),156-j*54-3*sin(phase*.7))
            mid1=(origin[0]+side*(24-3*j),origin[1]-19)
            mid2=(tip[0]+side*(11-2*j),tip[1]+23)
            branch=cubic(origin,mid1,mid2,tip,23)
            flame_band(img,branch,4.8-j*.62,strength*(.72-.08*j),SEED+900+k*67+j*2+side,phase+j)
        # White-hot guardian crest, open near head to preserve face silhouette.
        crown=cubic((128+side*27,63+2*breath),
                    (128+side*47,37-6*sin(phase*.5)),
                    (128+side*69,35+3*cos(phase)),
                    (128+side*75,83),27)
        flame_band(img,crown,4.3,strength*.78,SEED+1000+k*19+side,phase*.8)
    # Gold-white heart pulse from original painting underneath idle actor.
    soft_glow(img,128,144,20,26,int(184*strength),5,color=(255,252,159))
    flame_band(img,cubic((128,161),(122,151),(132,137),(128,125),16),3.6,
               strength*.92,SEED+4000+k,phase)
    # Directed glitter, never indiscriminate orange circles.
    scatter(img,k,(128,151),65,(77,65),strength)
    if k>=12:
        for j in range(8):
            x=69+j*17+4*cos(j+phase)
            y=205-j*11-(k-12)*11
            w=cubic((x,y+9),(x-6,y-3),(x+2,y-11),(x+3,y-23),18)
            flame_band(img,w,1.4,strength*.48,SEED+7300+k*15+j,phase)
    return img.resize((CELL,CELL),Image.Resampling.LANCZOS)

def draw_reaction(k):
    """Guarded hit received from front-right: NOT a damage or outgoing skill."""
    img=empty();t=k/7.;env=(1-t)**1.12
    # Shield is pushed inward and then snaps back. Local impact x~166 y~123.
    center=(171+12*t,119-7*t)
    soft_glow(img,*center,47+25*t,41+27*t,int(171*env),13,(255,199,54))
    soft_glow(img,*center,22+16*t,19+14*t,int(229*env),5,(255,251,182))
    # Off-centered crescent, no huge circular screen-space ripple.
    arc=[]
    for i in range(33):
        a=-1.20 + 2.2*i/32
        rr=34+39*t+3*sin(5*a+k*.6)
        arc.append((center[0]+rr*cos(a),center[1]+rr*.85*sin(a)))
    glow_ribbon(img,arc,4.3,env)
    # Shattered bright filaments emitted from exact block point.
    r=random.Random(SEED+88*k)
    for j in range(11):
        a=-1.45+(j/10)*2.5+r.uniform(-.11,.11)
        length=(22+54*t)*r.uniform(.65,1.2)
        p=cubic(center,(center[0]+length*.3,center[1]+5*sin(a)),
                (center[0]+length*.68*cos(a),center[1]+length*.5*sin(a)),
                (center[0]+length*cos(a),center[1]+length*sin(a)),13)
        glow_ribbon(img,p,r.uniform(1.3,3.2),env*(.83 if j%2 else 1.0))
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
