#!/usr/bin/env python3
"""PAF04 R7: a first-party painterly 2D flowing glass-energy guard.
Keeps ALL R6 timing, catalogue, status and target contracts. The new art has:
- stronger jade silk BODY, broken warm gold caustics and separate ivory CORE;
- actual dynamic progressive shape/pigment and non-uniform light packets;
- independent back/front translucency, moving character remains legible.
No skeletal rig, 3D mesh, commercial borrowed sprites or automatic GIF.
"""
from PIL import Image, ImageDraw, ImageFilter
import math, random

S=3
TAU=math.tau
def pt(points):
    return [(round(x*S),round(y*S)) for x,y in points]
def b(a,c,d,e,n=76):
    pts=[]
    for j in range(n+1):
        t=j/n;u=1-t
        pts.append((u*u*u*a[0]+3*u*u*t*c[0]+3*u*t*t*d[0]+t*t*t*e[0],
                    u*u*u*a[1]+3*u*u*t*c[1]+3*u*t*t*d[1]+t*t*t*e[1]))
    return pts
def paint(w,h):
    return Image.new('RGBA',(w*S,h*S))
def stroke(draw,points,color,width):
    if len(points)>1:
        draw.line(pt(points),fill=color,width=max(1,round(width*S)),joint='curve')
def comp(dst,art,radius=8,gain=.25):
    haze=art.filter(ImageFilter.GaussianBlur(radius*S))
    haze.putalpha(haze.getchannel('A').point(lambda z:int(z*gain)))
    dst.alpha_composite(haze)
    dst.alpha_composite(art)
def shrink(src,w,h):
    return src.resize((w,h),Image.Resampling.LANCZOS)
def flow_shade(draw,points,phase,k,front=False):
    # Pigment flows through a ribbon with genuinely varying width, not a
    # fixed PNG being transformed by Godot.  Progressive leading/trailing edges.
    lead=min(1.,.48+phase*1.35-.11*k)
    if lead<=.015:return
    tail=max(0.,lead-(.65+.09*math.sin(k+phase*5)))
    lo=int(tail*(len(points)-1));hi=int(lead*(len(points)-1))
    if hi-lo<7:return
    pts=points[lo:hi+1]
    lft=[];rgt=[]
    for j,(x,y) in enumerate(pts):
        t=j/max(1,len(pts)-1)
        prv=pts[max(0,j-1)];nxt=pts[min(len(pts)-1,j+1)]
        vx=nxt[0]-prv[0];vy=nxt[1]-prv[1]
        z=max(.001,math.hypot(vx,vy));nx=-vy/z;ny=vx/z
        thick=(7.8+3.8*(k%3))*(.14+.86*math.sin(math.pi*t)**.76)
        thick*=1+.15*math.sin(t*14.7-phase*7.5+k)
        if front:thick*=.68
        lft.append((x+nx*thick,y+ny*thick))
        rgt.append((x-nx*thick*.62,y-ny*thick*.62))
    body_alpha=38 if front else 60
    draw.polygon(pt(lft+rgt[::-1]),fill=(32,218,191,body_alpha))
    # Three wavelengths of energy, with an attractive, cohesive main silhouette.
    stroke(draw,lft,(130,255,228,130 if front else 185),2.8 if not front else 2.0)
    stroke(draw,rgt,(58,245,215,91),1.3)
    # The core runs inward along each long organic glass surface.
    stroke(draw,pts,(123,255,230,54 if front else 73),2.7)
    for j in range(5):
        u=(phase*(1.03+.15*(k%3))+j*.245+k*.117)%1
        width=.055+(j%3)*.017
        a=int(max(0.,u-width)*(len(pts)-1))
        z=int(min(1.,u+width)*(len(pts)-1))
        if z<=a+1:continue
        white=(255,255,235,230 if not front else 183)
        gold=(255,227,145,196 if not front else 144)
        stroke(draw,pts[a:z+1],white if j%2 else gold,3.5 if j%3==0 else 2.1)
        x,y=pts[z]
        draw.ellipse(pt([(x-1.8,y-1.8),(x+1.8,y+1.8)]),
                     fill=(255,255,225,215 if not front else 162))
def glass_shell(i,n=16,front=False):
    q=i/max(1,n-1)
    im=paint(352,448)
    # SIX NONSYMMETRIC, character-hugging, open silhouette strokes.
    # Crucially no underlying hard ellipse/circular panel.
    paths=[
      ((162,312),(108,287),(109,196),(167,147)),
      ((193,316),(259,281),(267,207),(195,147)),
      ((134,170),(152,114),(213,120),(236,176)),
      ((117,309),(150,341),(209,344),(251,293)),
      ((111,229),(144,193),(177,208),(219,234)),
      ((244,249),(220,226),(199,234),(177,260)),
    ]
    core=paint(352,448)
    d=ImageDraw.Draw(core,'RGBA')
    for k,(a,c,z,e) in enumerate(paths):
        if front and k not in (0,1,3,5):continue
        if not front and k in (3,5):continue
        push=6.3*math.sin(q*TAU*(.65+.1*(k%3))+k*.93)
        f=lambda p,v:(p[0]+v,p[1]+3.2*math.sin(q*TAU*.7+k))
        route=b(f(a,push*.20),f(c,push*.67),f(z,-push*.55),f(e,-push*.23),98)
        curve=[]
        for idx,(x,y) in enumerate(route):
            u=idx/98
            env=math.sin(math.pi*u)
            curve.append((x+4*env*math.sin(u*9-q*TAU*1.2+k),
                          y+2*env*math.cos(u*11-q*TAU*.9+k)))
        flow_shade(d,curve,q,k,front)
    comp(im,core,10,.37 if not front else .24)
    # Delicate free-floating hand-inked gold runes tracking curved filaments.
    # Not a static UI talisman, not a circle, and never over the eyes.
    motifs=paint(352,448);md=ImageDraw.Draw(motifs,'RGBA')
    for k in range(4):
        r=105+(k%2)*8
        a=-2.6+k*1.46+q*.13
        cx=176+r*math.cos(a)
        cy=235+r*.90*math.sin(a)
        w=6+2*(k%3)
        stem=[(cx-w,cy-4),(cx+1,cy-w),(cx+w,cy-2),(cx+2,cy+w),(cx-w*.6,cy+w*.6)]
        stroke(md,stem,(255,225,134,145 if not front else 83),1.45)
        md.ellipse(pt([(cx-1.6,cy-1.6),(cx+1.6,cy+1.6)]),fill=(255,255,222,148))
    comp(im,motifs,6,.12)
    # Fewer particles with bright highlights (not hundreds of gray specks).
    rng=random.Random(9007+i)
    dots=paint(352,448);dd=ImageDraw.Draw(dots,'RGBA')
    for j in range(33):
        ang=rng.uniform(-3.1,3.1)
        r=rng.uniform(76,119)
        x=176+r*math.cos(ang)+q*9*math.sin(j)
        y=229+r*.96*math.sin(ang)-q*8
        size=rng.uniform(.4,2.15)
        dd.ellipse(pt([(x-size,y-size),(x+size,y+size)]),
                   fill=(247,255,219,rng.randint(90,192)) if j%4 else (255,232,139,rng.randint(110,203)))
    comp(im,dots,5,.24)
    return shrink(im,352,448)
def charge(i,n=12,size=320):
    q=i/max(1,n-1)
    im=paint(320,320);energy=paint(320,320);d=ImageDraw.Draw(energy,'RGBA')
    lanes=[
      ((56,247),(87,212),(117,183),(156,167)),
      ((86,270),(120,218),(136,168),(156,167)),
      ((250,242),(207,193),(194,161),(156,167)),
      ((224,120),(207,103),(175,134),(156,167)),
    ]
    for k,(a,c,z,e) in enumerate(lanes):
        wobble=9*math.sin(q*7+k*1.13)
        route=b((a[0]+wobble,a[1]),(c[0]+wobble*.5,c[1]),
                (z[0]-wobble*.4,z[1]),e,65)
        stroke(d,route,(43,233,202,90),8.2)
        stroke(d,route,(150,255,226,173),3.2)
        for j in range(3):
            u=(q*(.79+.07*k)+k*.17+j*.32)%1
            idx=int(u*65)
            x,y=route[idx]
            stroke(d,route[max(0,idx-4):min(66,idx+5)],
                   (255,235,160,221) if j==1 else (244,255,237,223),2.5)
            d.ellipse(pt([(x-2,y-2),(x+2,y+2)]),fill=(255,252,220,219))
    comp(im,energy,13,.38)
    core=paint(320,320);d=ImageDraw.Draw(core,'RGBA')
    radius=6+9*q
    d.ellipse(pt([(156-radius,167-radius),(156+radius,167+radius)]),
              fill=(255,251,208,round(110+100*q)))
    comp(im,core,11,.21)
    return shrink(im,size,size)
def lock(i,n=14,size=320):
    q=i/max(1,n-1)
    im=paint(320,320);light=paint(320,320);d=ImageDraw.Draw(light,'RGBA')
    power=.12+.88*math.sin(math.pi*min(1.,q*1.14))
    # Low elliptical grounding on the floor as open luminous broken strokes.
    # This is not a full opaque HUD ring; 5 independent elliptical arcs.
    for k in range(5):
        a0=-math.pi+(.3+k*.35)+q*.07
        arc=[]
        for j in range(42):
            t=a0+j/41*.79
            arc.append((160+115*math.cos(t),
                        246+25*math.sin(t)))
        stroke(d,arc,(43,227,187,round(113*power)),6.0)
        stroke(d,arc,(255,233,155,round(158*power)),1.8)
    # White-hot vertical protective surges sweep OUTWARD across the chest.
    for k in range(7):
        a=-2.7+k*.66
        dist=(31+82*power)*(.75+.17*math.cos(k*1.42))
        start=(159+7*math.cos(a),165+7*math.sin(a))
        tip=(160+dist*math.cos(a),160+dist*.76*math.sin(a))
        curve=b(start,(161+dist*.4*math.cos(a+.65),151),
                (tip[0]+8,tip[1]-8),tip,45)
        stroke(d,curve,(28,226,194,round(102*power)),6.2)
        stroke(d,curve,(245,255,226,round(192*power)),2.6)
        j=int((.15+q*.75+k*.08)%1*45)
        x,y=curve[j]
        d.ellipse(pt([(x-1.7,y-1.7),(x+1.7,y+1.7)]),
                  fill=(255,235,159,round(220*power)))
    comp(im,light,16,.40)
    return shrink(im,size,size)
def shimmer(i,n=8):
    q=i/max(1,n-1)
    im=paint(256,256);d=ImageDraw.Draw(im,'RGBA')
    rng=random.Random(6812)
    for j in range(25):
        a=j*2.40+q*.83
        r=28+j*2.4+17*q
        x=128+r*math.cos(a);y=137+r*.62*math.sin(a)-25*q
        length=4+6*(j%3)
        stroke(d,[(x-length*.7,y+2),(x,y-3),(x+length,y-6)],
               (180,255,224,round(160*(1-q*.62))),1.4)
        if j%4==0:
            d.ellipse(pt([(x-1.3,y-1.3),(x+1.3,y+1.3)]),
                      fill=(255,235,151,round(180*(1-q*.6))))
    return shrink(im,256,256)
if __name__=='__main__':
    charge(7).save('/tmp/paf04_r7_charge.png')
    glass_shell(8).save('/tmp/paf04_r7_guard.png')
    lock(7).save('/tmp/paf04_r7_lock.png')
