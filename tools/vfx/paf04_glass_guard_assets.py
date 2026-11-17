#!/usr/bin/env python3
"""PAF04 Hộ Mệnh Lưu Văn: FIRST-PARTY translucent GLASS-energy GUARD.
Original supersampled RGBA crystal petals, caustic reflections, pearlescent silk.
One moving SELF target, not a projectile, attack or status writer. NO rig, NO GIF.
All source layers and frames reproducible at exact Git SHA.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import math,random,hashlib
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'godot/labs/combat_lab/talisman14'
ASSET=BASE/'assets';SOURCE=BASE/'art_sources'
S=2
def pt(p):return [(round(x*S),round(y*S)) for x,y in p]
def b3(a,b,c,d,n=42):
    pts=[]
    for k in range(n+1):
        t=k/n;u=1-t
        pts.append((u**3*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t**3*d[0],
                    u**3*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t**3*d[1]))
    return pts
def new(w,h):return Image.new('RGBA',(w*S,h*S))
def L(d,pts,c,w=1):
    d.line(pt(pts),fill=c,width=max(1,round(S*w)),joint='curve')
def glow(dst,layer,blur=7,power=.2):
    b=layer.filter(ImageFilter.GaussianBlur(S*blur))
    b.putalpha(b.getchannel('A').point(lambda a:int(a*power)))
    dst.alpha_composite(b);dst.alpha_composite(layer)
def final(image,w,h):return image.resize((w,h),Image.Resampling.LANCZOS)
def shard(d,outline,shade=0,detail=0,front=False):
    # Thin cyan body is deliberately transmissive; bright gold only on facets.
    d.polygon(pt(outline),fill=(39+int(shade*9),214,190,36 if front else 51))
    L(d,outline+[outline[0]],(108,249,233,111 if front else 139),1.5)
    d.line(pt([outline[0],outline[1]]),fill=(255,237,170,185),width=S*2)
    d.line(pt([outline[1],outline[2]]),fill=(245,252,235,123),width=S)
    a,b,c,e=outline[:4]
    L(d,[a,((a[0]+c[0])/2+detail,(a[1]+c[1])/2),c],(241,255,238,69),.9)
    L(d,[b,((b[0]+e[0])/2-detail,(b[1]+e[1])/2),e],(77,242,212,91),1.0)
def charge(i,n=12):
    q=i/max(n-1,1);out=new(320,320)
    threads=new(320,320);d=ImageDraw.Draw(threads,'RGBA')
    # Inward-folding crystal silk with an irregular organic crest, not HUD geometry.
    for k in range(5):
        t=k-2
        curl=14*math.sin(4.2*q+t*.7)
        p=b3((159+13*t,233),(80+18*k,201+curl),
             (226-21*k,110-31*q),(150+15*t,82-23*q))
        L(d,p,(47,240,208,73+k*14),4.7 if k==2 else 2.3)
        L(d,p,(255,244,192,102 if k==2 else 64),.8)
    glow(out,threads,10,.21)
    shards=new(320,320);d=ImageDraw.Draw(shards,'RGBA')
    for k in range(7):
        a=-math.pi*.52+k*.52+q*.24
        r=(18+64*q)*(.72+.18*math.sin(k+q*3))
        cx=160+math.cos(a)*r;cy=162+math.sin(a)*r
        wd=8+9*q
        poly=[(cx-5,cy-2),(cx+wd,cy-16-q*8),
              (cx+wd*.64,cy+wd*.8),(cx-7,cy+12)]
        shard(d,poly,shade=q,detail=k)
    glow(out,shards,8,.19)
    d=ImageDraw.Draw(out,'RGBA')
    for k in range(18):
        theta=k*2.39996+q*3
        r=20+58*(k/17)
        xx=160+r*math.cos(theta);yy=157+r*.69*math.sin(theta)
        rad=.5+1.2*math.sin(k*2.4)**2
        d.ellipse(pt([(xx-rad,yy-rad),(xx+rad,yy+rad)]),
                  fill=(249,255,218,150 if k%3==0 else 70))
    return final(out,320,320)
def shell(i,n=16,front=False):
    q=i/max(n-1,1);out=new(352,448)
    facets=new(352,448);d=ImageDraw.Draw(facets,'RGBA')
    # Wide semi-transparent asymmetric panes: an actual *glass skin* around
    # the moving actor, with light transmitted through each facet.
    center=176
    for j in range(7):
        a=-2.88+(j/6)*2.65+q*.032
        base=110+14*math.sin(j*1.7)+8*math.sin(q*6+j)
        nx=math.cos(a);ny=math.sin(a)
        lift=9*math.sin(q*math.pi*1.4+j*.8)
        cx=center+nx*base*.82
        cy=236+ny*base*1.30+lift
        w=24+12*math.sin(j*1.6)**2
        h=80+36*math.sin(j*.92)**2
        # front = outside edges only; NEVER mask the moving actor's face.
        if front and (j in (2,3,4)):
            continue
        if not front and (j in (0,6)):
            continue
        slant=19*math.sin(a+q*3)
        poly=[(cx-w*.5,cy-h*.58),(cx+w*.69+slant*.2,cy-h*.72),
              (cx+w*.37+slant,cy+h*.53),(cx-w*.74+slant*.3,cy+h*.43)]
        shard(d,poly,shade=q,detail=slant,front=front)
        d.ellipse(pt([(cx-2,cy-h*.73-2),(cx+2,cy-h*.73+2)]),
                  fill=(253,244,192,190))
    glow(out,facets,12,.23)
    # Sweeping caustic light only at periphery (not a geometric UI ring).
    sweep=new(352,448);d=ImageDraw.Draw(sweep,'RGBA')
    for j in range(5):
        side=-1 if j%2 else 1
        yy=95+j*57
        x0=center+side*(80+11*math.sin(q*7+j))
        p=b3((x0,yy+26),(x0+side*47,yy-25),
             (x0+side*38,yy+45),(x0-side*8,yy+87))
        L(d,p,(65,255,222,53 if front else 91),2.4 if j==2 else 1.2)
        L(d,p,(243,251,210,62),.65)
    glow(out,sweep,10,.24)
    return final(out,352,448)
def impact(i,n=14):
    q=i/max(n-1,1);out=new(320,320)
    # A shield *locking*, not an attack impact. Uneven crystal leaf petals
    # pivot upward around a warm energy core, with no screen-space HUD circle.
    skin=new(320,320);d=ImageDraw.Draw(skin,'RGBA')
    for j in range(9):
        a=-math.pi/2+(j-4)*.41
        rad=(25+110*math.sin(min(1,q*1.22)*math.pi*.74))*(.73+.20*math.sin(j*2.1))
        cx=160+rad*math.cos(a);cy=169+rad*.84*math.sin(a)
        dx=math.cos(a);dy=math.sin(a)
        tip=(cx,cy)
        start=(160+8*dx,169+8*dy)
        p=b3(start,(153+rad*.7*dx,164-24+rad*.3*dy),
             (tip[0]-dx*12,tip[1]-dy*13),tip,24)
        p+=b3(tip,(tip[0]+12,tip[1]+15),
              (148+rad*.2*dx,174+rad*.5*dy),start,20)
        d.polygon(pt(p),fill=(57,227,205,55+int(16*math.sin(q*math.pi))))
        L(d,p,(135,251,234,122),1.6)
        L(d,b3(start,(148+rad*.4*dx,145+rad*.3*dy),
               (tip[0]-9,tip[1]+7),tip),(247,247,215,138),.9)
    glow(out,skin,15,.21)
    rays=new(320,320);d=ImageDraw.Draw(rays,'RGBA')
    for k in range(14):
        ang=k*2.399963+q*.72
        r=(18+95*q)*(.52+.45*math.sin(k*3.1)**2)
        cx=160+r*math.cos(ang);cy=166+r*.7*math.sin(ang)
        length=6+11*math.sin(k*.91)**2
        L(d,[(cx-length*.7,cy+5),(cx,cy-4),
              (cx+length,cy-11)],(255,239,178,125),1.4)
    d.ellipse(pt([(153,157),(169,174)]),fill=(246,255,235,170))
    glow(out,rays,10,.16)
    return final(out,320,320)
def glint(i,n=8):
    q=i/max(n-1,1);out=new(256,256);d=ImageDraw.Draw(out,'RGBA')
    for j in range(25):
        a=j*2.4+q*1.9;r=(31+77*j/25)+22*q
        cx=128+r*math.cos(a);cy=143+r*.7*math.sin(a)-31*q
        length=4+9*math.sin(j*1.6)**2
        coords=[(cx-length*.8,cy+4),(cx,cy-3),(cx+length,cy-6)]
        L(d,coords,(133,253,225,round(155*(1-q*.6))),1.4)
        L(d,[(cx,cy-3),(cx+length*.4,cy-6)],
          (249,240,185,round(120*(1-q*.5))),.7)
    return final(out,256,256)
def badge(i,n=8):
    q=i/max(n-1,1);out=new(128,128)
    d=ImageDraw.Draw(out,'RGBA')
    # Compact persistent status motif; NOT a four-second animated cast.
    coords=[(62,21),(86,30),(102,59),(84,94),(62,111),(37,91),(24,57),(40,29)]
    # A compact independent 8-pose shimmer, not eight duplicate static GIF frames.
    pulse=.72+.28*math.sin(2*math.pi*q+.3)
    shift=3.5*math.sin(2*math.pi*q)
    coords=[(x+shift,y+1.7*math.sin(2*math.pi*q+y*.05)) for x,y in coords]
    d.polygon(pt(coords),fill=(42,178,154,round(45*pulse)))
    L(d,coords+[coords[0]],(104,246,224,round(142*pulse)),1.8)
    L(d,[(61+shift,30),(77+shift*.5,52),(64,83),(51-shift*.4,65),(61+shift,30)],
      (252,237,171,round(203*pulse)),1.8)
    return final(out,128,128)
def atlas(frames,w,h):
    im=Image.new('RGBA',(4*w,h*((len(frames)+3)//4)))
    for k,f in enumerate(frames): im.alpha_composite(f,((k%4)*w,(k//4)*h))
    return im
def main():
    ASSET.mkdir(parents=True,exist_ok=True); SOURCE.mkdir(parents=True,exist_ok=True)
    shell(9,front=False).resize((704,896),Image.Resampling.LANCZOS).save(SOURCE/'paf04_pearlescent_glass_shield_master.png')
    charge(7).resize((640,640),Image.Resampling.LANCZOS).save(SOURCE/'paf04_condensing_crystal_master.png')
    all={
      'paf04_charge.webp':(atlas([charge(k) for k in range(12)],320,320),12),
      'paf04_glass_back.webp':(atlas([shell(k,front=False) for k in range(16)],352,448),16),
      'paf04_glass_front.webp':(atlas([shell(k,front=True) for k in range(16)],352,448),16),
      'paf04_lock.webp':(atlas([impact(k) for k in range(14)],320,320),14),
      'paf04_shimmer.webp':(atlas([glint(k) for k in range(8)],256,256),8),
      'paf04_badge.webp':(atlas([badge(k) for k in range(8)],128,128),8),
    }
    for name,(image,frames) in all.items():
        p=ASSET/name;image.save(p,'WEBP',quality=92,method=4,exact=True)
        print('PAF04_ATLAS',name,frames,image.size,hashlib.sha256(p.read_bytes()).hexdigest())
    print('PAF04_ORIGINAL_GLASS_RGBA_BAKE_PASS')
if __name__=='__main__':main()
