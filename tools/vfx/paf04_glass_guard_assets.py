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
    q=i/max(n-1,1)
    out=new(352,448)
    # Low-alpha pearlescent lens: a TRANSPARENT field, never an opaque card.
    lens=new(352,448)
    mask=Image.new('L',lens.size,0)
    md=ImageDraw.Draw(mask)
    center=(176,243)
    md.ellipse(pt([(center[0]-112,center[1]-133),
                   (center[0]+115,center[1]+135)]),fill=37 if not front else 13)
    mask=mask.filter(ImageFilter.GaussianBlur(22*S))
    body=Image.new('RGBA',lens.size,(54,224,209,0))
    body.putalpha(mask)
    out.alpha_composite(body)
    # Rotating translucent, CURVED crescent feathers: no rigid glass rectangles.
    paint=new(352,448)
    d=ImageDraw.Draw(paint,'RGBA')
    N=13
    for k in range(N):
        a=2*math.pi*k/N-q*.055-.18
        radial=(math.cos(a),math.sin(a))
        tangent=(-math.sin(a),math.cos(a))
        x=176+111*radial[0]+7*math.sin(q*6+k*1.31)
        y=242+120*radial[1]+5*math.sin(q*8+k*.97)
        # Only narrow peripheral / low glass is FRONT: center actor remains visible.
        if front and not (abs(radial[0])>.64 or radial[1]>.81):continue
        if not front and (abs(radial[0])>.86 and radial[1]>.26):continue
        length=30+12*math.sin(k*1.71)**2
        width=14+12*math.sin(k*.87)**2
        begin=(x-radial[0]*length*.86,y-radial[1]*length*.86)
        tip=(x+radial[0]*length,y+radial[1]*length)
        c1=(begin[0]+tangent[0]*width*1.5-radial[0]*5,
            begin[1]+tangent[1]*width*1.5-radial[1]*5)
        c2=(tip[0]+tangent[0]*width*.78,
            tip[1]+tangent[1]*width*.78)
        c3=(tip[0]-tangent[0]*width*1.1,
            tip[1]-tangent[1]*width*1.1)
        c4=(begin[0]-tangent[0]*width*.98,
            begin[1]-tangent[1]*width*.98)
        edge1=b3(begin,c1,c2,tip,22)
        edge2=b3(tip,c3,c4,begin,22)
        leaf=edge1+edge2
        d.polygon(pt(leaf),fill=(49+5*(k%3),223,195,31 if front else 53))
        L(d,edge1,(190,255,239,164 if not front else 124),1.75)
        L(d,edge2,(92,240,215,88 if not front else 74),1.25)
        L(d,b3(begin,(x+tangent[0]*5,y+tangent[1]*5),
               (tip[0]-radial[0]*6,tip[1]-radial[1]*6),tip),
          (252,232,157,144 if k%3==0 else 85),.85)
        # Tiny lifted pearlescent reflection at the tip.
        d.ellipse(pt([(tip[0]-1.6,tip[1]-1.6),(tip[0]+1.6,tip[1]+1.6)]),
                  fill=(255,250,209,192))
    glow(out,paint,11,.20)
    # Loose liquid refraction streaks follow an irregular guard surface.
    caustics=new(352,448)
    d=ImageDraw.Draw(caustics,'RGBA')
    for k in range(9):
        a=-2.65+(k/8)*5.30+q*.13
        r1=100+13*math.sin(k*1.4+q*2)
        r2=124+11*math.sin(k*.7+q*5)
        p0=(176+r1*math.cos(a),241+r1*1.06*math.sin(a))
        p3=(176+r2*math.cos(a+.35),241+r2*1.06*math.sin(a+.35))
        v=(-math.sin(a),math.cos(a))
        p=b3(p0,(p0[0]+v[0]*33,p0[1]+v[1]*33),
             (p3[0]-v[0]*29,p3[1]-v[1]*29),p3)
        L(d,p,(82,248,221,113 if k%3==0 else 67),1.6 if k%3==0 else 1.0)
        if k%3==0:L(d,p,(252,245,209,87),.6)
    glow(out,caustics,11,.18)
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
