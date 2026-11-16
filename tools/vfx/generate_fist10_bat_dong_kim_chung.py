#!/usr/bin/env python3
"""FIST10 R4 / FIRST PARTY isolated translucent GOLDEN QI bell sprites.

NEVER uses a GIF, screenshots, character sprites or a downloaded commercial asset as input.
All VFX material is created as independent transparent RGBA vector-brush strokes,
then baked into per-phase alpha atlas. Actor/map are rendered by Godot separately.
Original high-resolution brush strokes are procedural first-party code-art; DO NOT
claim this is ImageGen painted artwork or 28 individually hand-drawn masters.
"""
from __future__ import annotations
from pathlib import Path
import math, random, base64, io
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT=Path(__file__).resolve().parents[2] if Path(__file__).resolve().parents[2].joinpath('godot').is_dir() else Path('/mnt/data')
OUT=ROOT/'godot/labs/combat_lab/fist10/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
K=1
GOLD=(255,206,103); PALE=(255,248,189)

# Source is first-party FIST10 R2 transparent artwork, used ONLY for
# painterly gold light microtexture (not actor, background or GIF pixels).
# R4's new shield geometry/runes are composed in independent RGBA layers.
SOURCE_B64=ROOT/'godot/labs/combat_lab/fist10/assets/source/r2_illustrated_bell_640.webp.b64'
if SOURCE_B64.exists():
    gold_bytes=base64.b64decode(''.join(SOURCE_B64.read_text(encoding='ascii').split()),validate=True)
    with Image.open(io.BytesIO(gold_bytes)) as first_party:
        gold_luma=np.array(first_party.convert('L').resize((768,768)),dtype=np.float32)/255.
else:
    raise FileNotFoundError('First-party R2 illustration required; no fallback to reference GIF')

def mix(a,b,t): return tuple(round((1-t)*aa+t*bb) for aa,bb in zip(a,b))
def bezier(p0,p1,p2,p3,n=72):
    return [((1-t)**3*p0[0]+3*(1-t)**2*t*p1[0]+3*(1-t)*t*t*p2[0]+t**3*p3[0],
             (1-t)**3*p0[1]+3*(1-t)**2*t*p1[1]+3*(1-t)*t*t*p2[1]+t**3*p3[1])
            for t in (i/(n-1) for i in range(n))]
def polyline(canvas, pts, warm=(255,195,70), peak=(255,255,202), width=2.5, alpha=1., sparkle=False, seed=0):
    """Nonuniform 3-pass glowing brush stroke, feathered raster alpha, no vector in Godot runtime."""
    if alpha<=0.001 or len(pts)<2:return
    W,H=canvas.size
    glow=Image.new('RGBA',(W,H));g=ImageDraw.Draw(glow,'RGBA')
    fpts=[(int(round(x*K)),int(round(y*K))) for x,y in pts]
    a=int(min(255,alpha*205))
    g.line(fpts,fill=(*warm,a),width=max(2,round(width*K*4)),joint='curve')
    canvas.alpha_composite(glow.filter(ImageFilter.GaussianBlur(max(2,width*K*3.6))))
    core=Image.new('RGBA',(W,H));d=ImageDraw.Draw(core,'RGBA')
    d.line(fpts,fill=(*warm,int(min(255,alpha*200))),width=max(1,round(width*K*1.65)),joint='curve')
    d.line(fpts,fill=(*peak,int(min(255,alpha*231))),width=max(1,round(width*K*.55)),joint='curve')
    canvas.alpha_composite(core)
    if sparkle:
        rnd=random.Random(seed)
        stars=Image.new('RGBA',(W,H));p=ImageDraw.Draw(stars,'RGBA')
        for _ in range(9):
            cx,cy=rnd.choice(pts)
            rad=rnd.uniform(.3,1.4)
            if rnd.random()<.5:p.ellipse(((cx-rad)*K,(cy-rad)*K,(cx+rad)*K,(cy+rad)*K),fill=(*PALE,int(145*alpha)))
        canvas.alpha_composite(stars)

def bell_curve(sway=0.,size=1.):
    cx=192.; top=49.; lower=311.
    def xf(x):return 192+(x-192)*size
    def yf(y):return top+(y-top)*size
    left=bezier((cx,top), (100+sway,74),(115+sway,133),(89+sway,191))
    left+=bezier(left[-1],(82+sway,251),(64+sway,299),(50,lower))
    right=[(384-x,y) for x,y in left]
    return [(xf(x),yf(y)) for x,y in left],[(xf(x),yf(y)) for x,y in right]

def oval(cx,cy,rx,ry,start=0,end=2*math.pi,steps=120,wiggle=0.,phase=0.):
    pts=[]
    for i in range(steps):
        ang=start+(end-start)*i/(steps-1)
        w=1+wiggle*math.sin(3*ang+phase)+.025*math.sin(9*ang-phase*1.4)
        pts.append((cx+rx*w*math.cos(ang),cy+ry*w*math.sin(ang)))
    return pts

def sign(canvas,cx,cy,s=1.,a=.6):
    # Short independent calligraphic lightning-like divine rune, not a font/UI symbol.
    base=[(-6,-16),(1,-14),(-2,-9),(7,-9),(1,-3),(6,2),(-2,7),(2,13),(-5,16)]
    seg=[(cx+x*s,cy+y*s) for x,y in base]
    polyline(canvas,seg,width=1.1,alpha=a,warm=(252,175,74),peak=(255,255,210))
    for dx,dy in ((-9,-1),(10,4)):
        polyline(canvas,[(cx+dx*s,cy+(dy-7)*s),(cx+(dx+2)*s,cy+(dy-1)*s)],width=.7,alpha=a*.66)

def mound(canvas,cx,cy,size=1.,phase=0.,alpha=1.):
    # Luminous coiled footing; painterly open ribbon in 3D foreshortened perspective.
    for j in range(4):
        op=(.68-j*.13)*alpha
        r=129*size-j*13*size
        arc=oval(cx,cy+j*2*size,r,20*size-j*2*size,-.06,math.tau-.06,145,.045,phase+j)
        polyline(canvas,arc,(255,175+10*j,66+11*j),(255,250,193),2.5-.25*j,op,seed=43+j)
    for j in range(13):
        q=(j*7+phase*12)%13
        a=math.tau*q/13
        x=cx+(112*size)*math.cos(a);y=cy+17*size*math.sin(a)
        l=10*size*(1.4 if j%5==0 else .7)
        polyline(canvas,[(x,y),(x+math.cos(a)*l,y+math.sin(a)*l)],(255,183,64),PALE,.9,.17*alpha)

def background_lighting(canvas, cx, cy, opacity, rx,ry):
    w,h=canvas.size
    yy,xx=np.ogrid[:h,:w]
    rr=((xx/K-cx)/rx)**2+((yy/K-cy)/ry)**2
    al=np.clip((1-rr)*opacity*28.,0,50).astype(np.uint8)
    layer=np.zeros((h,w,4),dtype=np.uint8)
    layer[:,:,:3]=[255,191,89]
    layer[:,:,3]=al
    canvas.alpha_composite(Image.fromarray(layer,'RGBA'))

def painterly_membrane(canvas, time, opacity, energy=1.):
    """Translucent irregular inner spiritual-shield layer. This is NOT a
    rectangle/poster fill. The mathematically curved boundary is baked into
    original transparent RGBA pixels before Godot ever sees the asset.
    """
    yy,xx=np.ogrid[:canvas.height,:canvas.width]
    yf=yy/K; xf=xx/K
    ytop=49; ybot=310
    t=np.clip((yf-ytop)/max(.01,(ybot-ytop)*energy),0.,1.)
    xrad=((56+82*t**1.85)*energy) + 6*np.sin(t*4.8+time*.3)
    # Wide base, tapered organic rim; dark untouched void around actor.
    inside=np.clip((xrad-np.abs(xf-192.0))/12.,0.,1.)
    top=np.clip((yf-ytop*energy)/40.,0,1)
    bottom=np.clip(((ybot+15)*energy-yf)/34.,0,1)
    sub=np.maximum(0,inside*top*bottom)
    # Low-opacity golden atmosphere increases cohesion at 1x but never
    # turns the bell into a solid physical gold metal object.
    breathe=.84+.16*np.sin(time*.84+yf*.033)
    wisps=.74+.26*np.sin(xf*.035+yf*.046+time*1.1)
    uv_y=np.clip((yy*768//max(1,canvas.height)).astype(int),0,767)
    uv_x=np.clip((xx*768//max(1,canvas.width)).astype(int),0,767)
    material=gold_luma[uv_y,uv_x]
    alpha=np.clip((13+13*breathe*wisps+4*material)*sub*opacity,0,255).astype('uint8')
    picture=np.zeros((canvas.height,canvas.width,4),dtype='uint8')
    picture[:,:,:3]=(243,183,78)
    picture[:,:,3]=np.broadcast_to(alpha,picture.shape[:2])
    canvas.alpha_composite(Image.fromarray(picture,'RGBA'))


def calligraphy_streamers(canvas, time, op=1., energy=1.):
    """Uneven original brush sweeps around the bell with tapered alpha,
    no vector shapes drawn by GDScript at runtime.
    """
    for j in range(5):
        phase=time*.72+j*.98
        side=-1 if j%2 else 1
        base_y=197+19*j+6*math.sin(phase)
        spread=(90+14*j)*energy
        start=(192+side*spread,base_y+6)
        ctrl1=(192+side*(spread+63),base_y-41-8*j)
        ctrl2=(192-side*(spread*.44),base_y+26+j*6)
        end=(192-side*(spread*.83),base_y-20+j*3)
        path=bezier(start,ctrl1,ctrl2,end,82)
        trim=int((.47+.2*math.sin(phase))*len(path))
        path=path[max(0,9+j*3):max(12,trim)]
        polyline(canvas,path,warm=(244,160,51),peak=(255,254,210),
                 width=1.25+(j%3)*.35,alpha=op*(.28+.07*(j%3)),sparkle=j%2==0,seed=42+j)
    # independent light flecks around the wall and free space
    rnd=random.Random(4824)
    specks=Image.new('RGBA',canvas.size)
    pen=ImageDraw.Draw(specks,'RGBA')
    for j in range(32):
        ang=j*2.39996+.34*time
        y=(125+200*((j*7)%31)/31.)*energy
        x=192+(145+18*math.sin(j*3.4+time))*(1 if j%2 else -1)
        x+=14*math.cos(ang)
        rad=.33+.75*(j%4)/4
        a=int(100*op*(.55+.45*math.sin(.8*j+time)**2))
        pen.ellipse(((x-rad)*K,(y-rad)*K,(x+rad)*K,(y+rad)*K),fill=(255,243,169,a))
    canvas.alpha_composite(specks.filter(ImageFilter.GaussianBlur(.6*K)))

def style_bell(canvas,phase=0.,op=1.,energy=1.,time=0.,detail=True, floor=True, limit=1.):
    # painterly opacity: no opaque gold metal shell; character remains in negative space.
    op=max(0.,min(1.,op))
    if op<.002:return
    sway=math.sin(time*1.4)*2.1
    left,right=bell_curve(sway=sway,size=energy)
    if floor:
        background_lighting(canvas,192,329,op,132*energy,44)
        mound(canvas,192,332,energy,phase=phase,alpha=op)
    painterly_membrane(canvas,time,op*.87,energy)
    # Side arcs reveal in phases, not a single resized still.
    amount=max(0.01,min(1.,limit))
    step=max(3,round(len(left)*amount))
    polyline(canvas,left[:step],width=3.2,alpha=op*.80,seed=19)
    polyline(canvas,right[:step],width=3.0,alpha=op*.81,seed=24)
    # Restrained second, imperfect strokes: material feels like qi/ink, not wireframe UI.
    if detail:
        for offset,side,sgn in ((-10,left,-1),(13,right,1)):
            if step>24:
                knots=[(x+sgn*(11+4*math.sin(i*.08+time)),y) for i,(x,y) in enumerate(side[13:step:2])]
                polyline(canvas,knots,warm=(238,142,59),peak=(255,212,106),width=1.2,alpha=.30*op)
    # Crown loosely drawn as lotus stroke; a religious-like ornamental light, no jewel.
    top=52+(1-energy)*35
    lotus=[(192,top-18),(180,top-3),(169,top-3),(181,top+8),(192,top+15),(203,top+8),(215,top-3),(202,top-4),(192,top-18)]
    polyline(canvas,lotus,warm=GOLD,peak=PALE,width=1.8,alpha=op*.92)
    # Upper bell shoulder bridge and two stippled inscription bands.
    if amount>.27:
        top_arch=bezier((115,140),(143,102+5*math.sin(time)),(235,103),(268,142))
        polyline(canvas,top_arch[:max(2,int(len(top_arch)*amount))],width=1.8,alpha=op*.72)
    if detail and amount>.55:
        for side in (-1,1):
            for j in range(3):
                sign(canvas,192+side*(69+17*j),158+j*48,1.0-j*.08,op*(.31+.06*((j+1)%3)))
    # Open spiraling energy lines (JX-like movement); no repeated complete torus icon.
    if amount>.4:
        for q,turn in enumerate((-.20,1.45)):
            rr=105*energy+15*q
            swirl=oval(192,210+22*q,rr,27+9*q,
                       math.pi*(.82+turn),math.pi*(2.26+turn),90,phase=.2+time*.85+q,wiggle=.04)
            polyline(canvas,swirl, warm=(255,171,69),peak=PALE,width=1.8+q*.3,alpha=op*.57,seed=23+q)
    if amount>.47: calligraphy_streamers(canvas,time,op*(.48+.32*amount),energy)
    # Absence of painted floor/character inside source is deliberate.

def cast_pose(k):
    im=Image.new('RGBA',(384*K,384*K))
    op=[.08,.18,.26,.43,.65,.83,.95,1,1,.89,.62,.26][k]
    size=[.68,.72,.76,.81,.87,.94,1,1.025,1.038,1.012,.96,.85][k]
    reveal=[.04,.13,.26,.43,.57,.73,.87,.98,1.,1.,1.,1.][k]
    style_bell(im,time=k*.29,phase=k*.37,op=op,energy=size,limit=reveal)
    return im.resize((384,384),Image.Resampling.LANCZOS)

def sustain_pose(k):
    im=Image.new('RGBA',(192*K,192*K))
    full=Image.new('RGBA',(384*K,384*K))
    ph=math.tau*k/8
    style_bell(full,time=ph*.75,phase=ph,op=.36+.04*math.sin(ph),energy=.87,limit=1.)
    # Quiet bell frame is a small thin translucent status glyph, not a solid icon.
    sm=full.resize((150*K,150*K),Image.Resampling.LANCZOS)
    im.alpha_composite(sm,(21*K,21*K))
    return im.resize((192,192),Image.Resampling.LANCZOS)

def block_pose(k):
    im=Image.new('RGBA',(256*K,256*K))
    full=Image.new('RGBA',(384*K,384*K))
    op=[.17,.49,.95,.88,.68,.38,.16,.05][k]
    style_bell(full,time=k*.27,phase=k*.38,op=.78*op,energy=.85+.09*math.sin(k*.4),limit=1.)
    sm=full.resize((214*K,214*K),Image.Resampling.LANCZOS)
    im.alpha_composite(sm,(16*K,20*K))
    # Incoming hit at RIGHT flank; light deflects toward the shield but
    # no outgoing attack, projectile or fake damage to the moving monster.
    cx=206;cy=111
    for i in range(3):
        dx=13*i
        stroke=bezier((252,cy-33+i*21),(244-dx,cy-23+i*18),(224-dx,cy-8+i*13),(cx-2,cy+4))
        polyline(im,stroke,(255,179,76),(255,252,218),2.6-.4*i,op*.83,seed=100+k*3+i)
    # Bright impact arc and brief local bloom, no huge diagonal outgoing ray.
    impact=oval(198,115,21+5*math.sin(k),43,-math.pi*.58,math.pi*.62,69,.03,k*.3)
    polyline(im,impact,(255,186,63),(255,255,218),3,op*.97,seed=k)
    return im.resize((256,256),Image.Resampling.LANCZOS)

def atlas(poses,cell,outfile):
    out=Image.new('RGBA',(cell*4,cell*((len(poses)+3)//4)))
    for k,im in enumerate(poses):out.alpha_composite(im,((k%4)*cell,(k//4)*cell))
    out.save(OUT/outfile,optimize=True)
    return out

cast=atlas([cast_pose(i) for i in range(12)],384,'f10_cast_bell.png')
status=atlas([sustain_pose(i) for i in range(8)],192,'f10_status_seal.png')
block=atlas([block_pose(i) for i in range(8)],256,'f10_guard_resonance.png')
# Full original independent golden qi brush master: two first-party layers.
# No screenshots/GIF input. Deterministic source allows exact GitHub bake.
master_small=Image.new('RGBA',(384,384))
style_bell(master_small,time=.72,phase=.28,op=1.,energy=1.,limit=1.)
master_small.resize((768,768),Image.Resampling.LANCZOS).save(OUT/'f10_r4_original_transparent_qi_master.png',optimize=True)
raw=sum((p.width*p.height*4) for p in [cast,status,block])
assert raw==10354688,raw
print('FIST10_BAKE_PASS poses=28 pages=3 raw_rgba_bytes=10354688 no_rig=true first_party_derived_material=true')
print('FIST10_R4_INDEPENDENT_BRUSH_MASTER no_gif_input=true no_actor_input=true scene_separated=true')
