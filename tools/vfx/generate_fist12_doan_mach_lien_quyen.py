#!/usr/bin/env python3
"""FIST12 R5: Doan Mach Lien Quyen - close pressure blooms and broken meridian mark.

Godot flipbook generator. Three martial qi impact echoes (no moving fist icon) inspired by
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


def qi_burst(im, center, strength, beat, seed):
    """Painted localized pressure light: soft irregular core, not an outlined
    circle, projectile arrowhead, screen-white flash or second gameplay hit."""
    size=im.width
    yy,xx=np.mgrid[0:size,0:size].astype('float32')
    cx,cy=center
    r=((xx-cx)/(17+11*strength))**2+((yy-cy)/(11+8*strength))**2
    # Two soft layers: saturated blood ambience and tiny ivory-hot core.
    for spread,color,a in [(.42,(154,0,57),.55),(.14,(255,81,136),.72),(.035,(255,226,217),.68)]:
        v=np.exp(-r/(spread+.055)) * a * strength
        alpha=Image.fromarray(np.clip(v*255,0,255).astype('uint8'),'L')
        layer=Image.new('RGBA',(size,size),color+(0,))
        layer.putalpha(alpha)
        im.alpha_composite(layer)
    # Tilted, broken slashes crossing the pressure-point for each visual beat.
    rr=random.Random(12180+beat*23+seed)
    d=ImageDraw.Draw(im,'RGBA')
    for j in range(6):
        y=cy+(j-2.5)*5.4+rr.uniform(-2.4,2.4)
        x=cx-4+j*2+rr.uniform(-4,4)
        x2=x+(13+rr.randrange(3,16))
        y2=y+(-8 if beat==0 else 8 if beat==1 else -2)+rr.uniform(-5,5)
        light=(255,205 if j%2 else 113,172 if j%2 else 139,round(170*strength))
        d.line([(x,y),(x2,y2)],fill=light,width=rr.choice([1,2,3]))

def wave(k):
    """R5: THREE compact MARTIAL PRESSURE BLOOMS rather than streaming ropes.

    Each of the 3x4 beats is an inward-compressed qi fist, then rupturing
    non-circular shock edges with a bright textured center. No flat fist sprite
    and NO declared combat hits, projectiles or actor pixels in the atlas.
    """
    S=320;beat=k//4;sub=k%4
    pulse=[.30,.74,1.0,.27][sub]
    rr=random.Random(19500+beat*117+sub*23)
    phi=[-.48,.35,-.08][beat]
    cx,cy=(174+5*math.sin(beat*1.3),160+[-15,15,-3][beat])
    curves=[]
    # Thick energy wake has an actual compression point, not a ribbon arrow.
    for j in range(3):
        sign=(j-1)
        src=(62+j*8,cy+sign*(30+4*beat))
        c1=(91,cy+sign*49+rr.uniform(-5,5))
        c2=(144,cy+sign*15+rr.uniform(-6,6))
        dst=(cx-13,cy+sign*5)
        curves.append((curve(src,c1,c2,dst,44),3.5+j*.9))
    # Irregular, separated open shockwave lobes wrapping each punch pressure.
    for j in range(9):
        a=phi + j*math.tau/9+rr.uniform(-.10,.10)
        radius=23+56*max(0.,pulse-.15)+rr.uniform(-10,10)
        start=(cx+math.cos(a)*12,cy+math.sin(a)*9)
        tip=(cx+math.cos(a)*radius,cy+math.sin(a)*radius*.81)
        mid=(cx+math.cos(a+.28)*radius*.69,cy+math.sin(a+.28)*radius*.62)
        pts=curve(start,(cx+math.cos(a-.4)*20,cy+math.sin(a-.4)*24),mid,tip,33)
        curves.append((pts,2.7+(j%3)*1.25))
    # Curl around only PART of the contact surface; arcs are broken, not a UI ring.
    for j in (0,1,2):
        cen=phi+j*1.75
        pts=[]
        for i in range(32):
            t=i/31
            a=cen+(t-.5)*1.08
            radius=(47+10*j)*(1+.10*math.sin(i*.41+beat))
            pts.append((cx+radius*math.cos(a),cy+radius*.78*math.sin(a)))
        curves.append((pts,3.6+j*.75))
    im=paint_masks(S,curves,sub*.83+beat*1.37,pulse,870+beat*20+sub)
    qi_burst(im,(cx,cy),pulse*1.32,beat,sub)
    # Four pressure-knuckle light dents at peak; luminous, NOT a fist item.
    d=ImageDraw.Draw(im,'RGBA')
    for j in range(4):
        a=phi+j*.44-.66
        x=cx+14*math.cos(a)
        y=cy+14*math.sin(a)
        rad=2.8+pulse*3.0+((j+beat)%2)*1.4
        d.ellipse((x-rad,y-rad*.67,x+rad,y+rad*.67),
                  fill=(255,225-j*21,197-j*14,round(190*pulse)))
    splinters(im,k,(cx,cy),scale=.38+.77*pulse,count=13,brightness=pulse*.92)
    return im


def contact(k):
    """The delayed meridian CUT is a single mark application (not another
    injury/hit); bright interrupted vein channels, split on the target.
    """
    S=320;f=k/7
    power=[.13,.45,.79,1.,.88,.55,.29,.075][k]
    cx,cy=160,159
    curves=[]
    for i in range(3):
        dx=(i-1)*27
        start=(cx-9+dx,cy-55-4*i)
        a=(cx+12+dx,cy-26+8*math.sin(k*.47+i))
        b=(cx-16+dx,cy+7+7*i)
        end=(cx+5+dx,cy+42+i*5)
        # Cut is discontinuous: a fluid vein *broken into pieces*.
        lines=curve(start,a,b,end,55)
        cuts=[lines[:21],lines[28:38],lines[44:]]
        for part in cuts:
            curves.append((part,2.6+1.2*(i==1)+2.0*(1-f)))
    for i in range(4):
        side=(-1 if i%2==0 else 1)
        x=cx+side*(8+i*6)
        pts=curve((x,cy-23+i*11),(x+side*15,cy-9+i*8),
                  (x+side*25,cy+7+i*8),(x+side*(29+20*f),cy+18+i*6),24)
        curves.append((pts,2.4+1.4*(1-f)))
    im=paint_masks(S,curves,k*.71,power,410+k)
    qi_burst(im,(cx,cy),power*.74,1,k)
    splinters(im,k,(cx,cy),scale=.18+.73*f,count=12,brightness=power*.48)
    return im


def mark(k):
    """Small, non-circular, breathing broken MERIDIAN SIGN on recipient chest.
    Three glowing interrupted channels rather than a decorative UI symbol.
    """
    S=192;phase=math.tau*k/8
    c=(96,104)
    lines=[]
    for i in range(3):
        dx=(i-1)*13
        start=(c[0]+dx-6,c[1]-25+math.sin(phase+i)*2)
        a=(c[0]+dx+8,c[1]-9+math.sin(phase+i)*4)
        b=(c[0]+dx-9,c[1]+5+i*2)
        end=(c[0]+dx+6,c[1]+22+math.cos(phase+i)*2)
        p=curve(start,a,b,end,45)
        for segment in [p[:18],p[25:31],p[35:]]:
            lines.append((segment,2.0 if i!=1 else 3.2))
    for j in range(4):
        x=c[0]+(-20+j*13)
        y=c[1]-9+(j%2)*15+math.sin(phase+j)*2
        lines.append(([(x-7,y-6),(x+1,y+2),(x+8,y+3)],1.7))
    power=.57+.14*math.sin(phase+.7)
    img=paint_masks(S,lines,phase,power,550+k)
    d=ImageDraw.Draw(img,'RGBA')
    for j in range(3):
        px=c[0]+(j-1)*13;py=c[1]-2+2*math.sin(phase+j*.8)
        r=2.2+(.6 if j==1 else 0)
        d.ellipse((px-r,py-r,px+r,py+r),fill=(255,215,202,round(145*power)))
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