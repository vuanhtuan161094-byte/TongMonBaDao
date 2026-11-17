#!/usr/bin/env python3
"""FIST12: Doan Mach Lien Quyen - energy-first Nether mark VFX.

Godot flipbook generator. NEW energy strokes (no moving fist icon) inspired by
first-party FIST03 hand-painted IMPACT luminance as MICROGRAIN only. Painting
shape is authored here with irregular alpha strokes; neither a GIF nor any
video, actor, map, or external JX/VL pixel is a source. This code-produced
master must be reviewed by a human; a pass means *technical*, not art PASS.
"""
from pathlib import Path
import math, random
from PIL import Image, ImageDraw, ImageFilter, ImageChops
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
PAINT=ROOT/'godot/labs/combat_lab/fist03/assets/impact_master.webp'
OUT=ROOT/'godot/labs/combat_lab/fist12/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
with Image.open(PAINT) as src:
    PIGMENT=src.convert('RGBA').resize((640,640),Image.Resampling.LANCZOS)
assert min(PIGMENT.size)>=300
N=4
RND=np.random.default_rng(121117)


def curve(p0,p1,p2,p3,n=48):
    pts=[]
    for i in range(n):
        t=i/(n-1)
        q=1-t
        x=q*q*q*p0[0]+3*q*q*t*p1[0]+3*q*t*t*p2[0]+t*t*t*p3[0]
        y=q*q*q*p0[1]+3*q*q*t*p1[1]+3*q*t*t*p2[1]+t*t*t*p3[1]
        pts.append((x,y))
    return pts


def trace_mask(size,curves,phase,level,seed):
    """Separated original brush silhouettes: broad feather / strong pigment /
    broken rose-ivory highlights, with varying thickness and posture per pose.
    """
    raw=Image.new('L',(size,size),0)
    ridge=Image.new('L',(size,size),0)
    hot=Image.new('L',(size,size),0)
    d=ImageDraw.Draw(raw);e=ImageDraw.Draw(ridge);h=ImageDraw.Draw(hot)
    rr=random.Random(seed)
    for ci,(pts,base) in enumerate(curves):
        for j in range(len(pts)-1):
            t=(j+.5)/(len(pts)-1)
            wobbly=(.82+.18*math.sin(j*.43+ci*2.1+phase))
            width=base*(.22+.87*math.sin(math.pi*(.01+.98*t))**.75)*wobbly
            width=max(1,width)
            p1,p2=pts[j:j+2]
            d.line((p1,p2),fill=round(202*level),width=max(1,round(width*4.3)),joint='curve')
            e.line((p1,p2),fill=round(232*level),width=max(1,round(width*1.45)),joint='curve')
            # White-light core broken for painterly pulse and uneven edges.
            if (j+3*ci+seed)%10 < 7 and (.05<t<.97):
                h.line((p1,p2),fill=round((189+40*math.sin(j*.41+phase))*level),
                       width=max(1,round(width*.35)),joint='curve')
        # independent fork filaments, not generic symmetric vectors
        for j in range(2, len(pts)-5, 11):
            if rr.random()<.54:
                p=pts[j]
                slope=rr.choice([-1,1])
                q=(p[0]+rr.uniform(12,26),p[1]+slope*rr.uniform(6,18))
                e.line([p,q],fill=round(95*level),width=max(1,round(base*.18)))
    return raw,ridge,hot


def paint_masks(size,curves,phase,level=1.,seed=0,sourcegrain=True):
    broad,strong,hot=trace_mask(size,curves,phase,level,seed)
    halo=broad.filter(ImageFilter.GaussianBlur(max(3,size*.032)))
    haze=broad.filter(ImageFilter.GaussianBlur(max(2,size*.012)))
    # Irregular high frequency alpha + FIRST-PARTY hand-painted lum texture,
    # restricted to the separately authored paths. No picture-shaped crop.
    lum=np.asarray(PIGMENT.resize((size,size),Image.Resampling.LANCZOS),dtype=np.float32)
    g=(lum[:,:,0]*.44+lum[:,:,1]*.36+lum[:,:,2]*.20)/255.
    noise=RND.normal(0,.055,(size,size))
    grain=np.clip(.82+.22*g+noise, .66, 1.0)
    out=Image.new('RGBA',(size,size))
    for mask,color,strength in [(halo,(114,8,91),.72),(haze,(195,17,92),.48),
                                (broad,(214,13,91),.74),(strong,(251,55,133),.90),
                                (hot,(255,231,229),1.0)]:
        vals=np.asarray(mask,dtype=np.float32)
        strengthArray=grain if sourcegrain else 1
        alp=np.uint8(np.clip(vals*strength*strengthArray,0,255))
        layer=Image.new('RGBA',(size,size),color+(0,))
        layer.putalpha(Image.fromarray(alp,'L'))
        out.alpha_composite(layer)
    return out


def splinters(im,k,center,scale=1.,count=9,brightness=1.):
    rr=random.Random(k*1709+121)
    d=ImageDraw.Draw(im,'RGBA')
    for j in range(count):
        a=(j+.41*math.sin(k*.35+j))*math.tau/max(1,count)
        distance=(8+rr.random()*31)*scale
        x=center[0]+math.cos(a)*distance
        y=center[1]+math.sin(a)*distance*.58
        length=rr.uniform(4,13)*scale
        wd=rr.uniform(1,2.7)*scale
        color=(255,rr.randrange(90,180),rr.randrange(115,200),round(110*brightness))
        d.polygon([(x+math.cos(a)*length,y+math.sin(a)*length),
                   (x-math.sin(a)*wd,y+math.cos(a)*wd),
                   (x-math.cos(a)*length*.33,y-math.sin(a)*length*.33),
                   (x+math.sin(a)*wd,y-math.cos(a)*wd)],fill=color)


def charge(k):
    S=256
    p=k/7
    c=(157,137)
    cur=[]
    for j in range(4):
        a=j*math.tau/4+k*.16
        tail=(c[0]-64+13*math.cos(a),c[1]+61*math.sin(a))
        mid1=(c[0]-37,c[1]+36*math.sin(a+.9))
        mid2=(c[0]-12,c[1]+19*math.cos(a+.3+k*.15))
        pts=curve(tail,mid1,mid2,(c[0]+5*p,c[1]+2*math.sin(k*.7)),38)
        cur.append((pts,5+8*p+(j%2)*2))
    img=paint_masks(S,cur,k*.24,.21+.79*p,k+1)
    splinters(img,k,c,scale=.27+.45*p,count=9,brightness=.24+.64*p)
    return img


def wave(k):
    """Five BRAIDED plasma currents. No pointed triangular fist/arrow sprite.
    Nonuniform knots, crossing helical threads and soft luminescent wake
    oscillate independently for every animation frame.
    """
    S=320;f=k/11
    phase=k*.47
    cur=[]
    for j in range(5):
        pts=[]
        strand=(j-2)
        for n in range(56):
            t=n/55
            x=42+227*t + (j-2)*7*(1-t) + 5*math.sin(phase+j*1.8+t*3.9)
            # braided luminous filaments exchange upper/lower positions,
            # with asymmetry to avoid wedge, neon arrow or uniform ribbons
            envelope=(.33+.67*math.sin(math.pi*t)**.62)
            y=153+strand*8.5*(1-.30*t)+(24+5*j%3)*math.sin((1.62+.33*j)*math.pi*t+phase*(.62+.11*j)+j*1.76)*envelope
            y+=9*math.sin((3.3+j*.34)*math.pi*t+phase*.55+j*2.4)
            pts.append((x,y))
        cur.append((pts,5.3+(j%2)*2.4+1.3*math.sin(k*.31+j)**2))
    im=paint_masks(S,cur,phase,.76+.21*math.sin(f*math.pi),120+k)
    # Broken, painterly white-hot energy knots, not a hard crescent ring.
    d=ImageDraw.Draw(im,'RGBA')
    rr=random.Random(1907+k)
    for i in range(11):
        x=75+i*17+rr.uniform(-6,6)
        y=150+29*math.sin(x*.031+phase+i*.7)
        length=rr.uniform(3,12)
        d.line([(x,y),(x+length,y+rr.uniform(-8,8))],
               fill=(255,rr.randint(143,219),rr.randint(168,230),rr.randint(85,155)),
               width=rr.choice([1,2,3]))
    splinters(im,k,(234,150),scale=.22+.13*math.sin(f*math.pi),count=6,brightness=.39)
    return im


def contact(k):
    S=320;p=k/7
    life=[.30,.58,.94,1.,.84,.61,.34,.10][k]
    c=(155+5*math.sin(k*.5),155)
    cur=[]
    # Three spreading, asymmetrical meridian fractures; physically one
    # LOCAL mark-application cue, not three invented gameplay hits.
    for j in range(5):
        angle=[-.92,-.38,.22,.69,1.11][j]
        dist=(23+115*p**.83)*(1+.15*math.sin(j*.93+k*.21))
        dest=(c[0]+math.cos(angle)*dist,c[1]+math.sin(angle)*dist*.66)
        a=curve((c[0]-10,c[1]+3*math.sin(j)),(c[0]+28,c[1]-18+j*9),
                (dest[0]-12,dest[1]+14*math.sin(j+ k*.5)),dest,36)
        cur.append((a,3.5+7*(1-p)+j%2*2))
    img=paint_masks(S,cur,k*.42,life,270+k)
    # Controlled blast: elliptical soft light not a hard circular UI ring.
    buff=Image.new('L',(S,S));ImageDraw.Draw(buff).ellipse((c[0]-31,c[1]-23,c[0]+32,c[1]+23),fill=round(150*life))
    buff=buff.filter(ImageFilter.GaussianBlur(17+5*p))
    ly=Image.new('RGBA',(S,S),(255,115,147,0));ly.putalpha(buff)
    img.alpha_composite(ly)
    splinters(img,k,c,scale=.55+2*p,count=12,brightness=life)
    return img


def mark(k):
    S=192;phase=k*math.tau/8
    c=(96,102)
    cur=[]
    # Small living cracked-vein mark that breathes at target's upper chest.
    for j in range(3):
        s=(-1 if j==0 else 1)
        start=(c[0]+(j-1)*2,c[1]-19-4*math.sin(phase+j))
        a=(c[0]-16+j*15,c[1]-11+7*math.sin(phase+j*2))
        b=(c[0]-11+j*18,c[1]+7+7*math.cos(phase+j*.9))
        end=(c[0]-21+j*21,c[1]+25+3*math.sin(phase+j*1.4))
        cur.append((curve(start,a,b,end,32),2.5+(j%2)*1.4))
    img=paint_masks(S,cur,phase,.50+.17*math.sin(phase),500+k)
    splinters(img,k,c,scale=.25,count=4,brightness=.31)
    return img


def atlas(poses,cell,name):
    assert all(x.size==(cell,cell) for x in poses)
    rows=(len(poses)+3)//4
    page=Image.new('RGBA',(4*cell,rows*cell))
    for i,x in enumerate(poses):page.alpha_composite(x,((i%4)*cell,(i//4)*cell))
    assert page.getchannel('A').getextrema()[0]==0
    page.save(OUT/name,optimize=True)
    return page

chunks=[
  atlas([charge(i) for i in range(8)],256,'f12_charge.png'),
  atlas([wave(i) for i in range(12)],320,'f12_meridian_waves.png'),
  atlas([contact(i) for i in range(8)],320,'f12_contact.png'),
  atlas([mark(i) for i in range(8)],192,'f12_six_second_mark.png')
]
# A separate original transparent painterly hero master for source audit.
master=Image.new('RGBA',(768,768))
master.alpha_composite(wave(6).resize((652,652),Image.Resampling.LANCZOS),(58,58))
master.save(OUT/'f12_original_energy_master.png',optimize=True)
raw=sum(x.width*x.height*4 for x in chunks)
assert raw==11468800,raw
print('FIST12_BAKE_PASS pages=4 poses=36 rgba_bytes=11468800 no_gif=true no_rig=true energy_first=true')
print('FIST12_PROVENANCE=FIRST_PARTY_SOURCE_GRAIN_ONLY no_fist_icon=true source_paint=FIST03_IMPACT no_external_pixels=true')