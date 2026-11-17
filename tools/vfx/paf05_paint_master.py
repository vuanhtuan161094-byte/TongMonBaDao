#!/usr/bin/env python3
"""PAF05 — original physically isolated hand-directed 2D painterly Wind Seal master/flipbooks.
True alpha RGBA, first-party authored vector-matte + multiscale raster pigment and moving caustics.
NOT from a labeled concept board. No game art/actor, no rig, no commercial source pixels.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
from paf05_luminous_raster import hero as light_hero, charge as light_charge, field as light_field, contact as light_contact
import numpy as np, math, random, hashlib
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'godot/labs/combat_lab/talisman15/assets'; SRC=ROOT/'godot/labs/combat_lab/talisman15/art_sources'
S=2
rng=random.Random(90057)
TAU=math.tau

def init(w,h):return Image.new('RGBA',(w*S,h*S),(0,0,0,0))
def bez(a,b,c,d,n=60):
    return [((1-t)**3*a[0]+3*t*(1-t)**2*b[0]+3*t*t*(1-t)*c[0]+t**3*d[0],(1-t)**3*a[1]+3*t*(1-t)**2*b[1]+3*t*t*(1-t)*c[1]+t**3*d[1]) for t in [i/n for i in range(n+1)]]
def points(seq):return [(round(x*S),round(y*S)) for x,y in seq]
def line(d,p,color,width=1.5):
    if len(p)>1:d.line(points(p),fill=color,width=max(1,int(round(width*S))),joint='curve')
def ellipse(d,x,y,r,c):d.ellipse(((x-r)*S,(y-r)*S,(x+r)*S,(y+r)*S),fill=c)
def glow(dst,source,blur=10,strength=.28):
    sm=source.filter(ImageFilter.GaussianBlur(blur*S));sm.putalpha(sm.getchannel('A').point(lambda a:int(a*strength)))
    dst.alpha_composite(sm);dst.alpha_composite(source)
def output(img,w,h):return img.resize((w,h),Image.Resampling.LANCZOS)
# Organic pigment: anisotropic wavering varying-width feathered brush with microbreaks.
def braided_ribbon(dst,path,q,layer=0,width=7,opacity=160,seed=0):
    r=random.Random(551+seed)
    body=Image.new('RGBA',dst.size,(0,0,0,0));d=ImageDraw.Draw(body,'RGBA')
    n=len(path)-1;edge1=[];edge2=[];back=[]
    for j,(x,y) in enumerate(path):
        u=j/max(1,n);prev=path[max(0,j-1)];nxt=path[min(n,j+1)]
        vx=nxt[0]-prev[0];vy=nxt[1]-prev[1];norm=max(.001,math.hypot(vx,vy));nx=-vy/norm;ny=vx/norm
        breath=.65+.35*math.sin(u*math.pi)**.5
        w=width*breath*(.86+.15*math.sin(u*39-q*11+seed))
        edge1.append((x+nx*w,y+ny*w));edge2.append((x-nx*w*.67,y-ny*w*.67))
        back.append((x+nx*w*.25,y+ny*w*.25))
    d.polygon(points(edge1+edge2[::-1]),fill=(32,200,166,int(opacity*.46)))
    line(d,edge1,(52,225,190,int(opacity*.66)),max(1,width*.24))
    line(d,edge2,(74,236,205,int(opacity*.50)),max(1,width*.15))
    # The colored energy BODY is deliberately saturated while transparent.
    line(d,back,(86,245,220,int(opacity*.46)),max(1,width*.42))
    # Brushed fibrils; jagged broken highlights unlike vector single stroke.
    for b in range(5):
        p=[];u0=.03+(b*.149+seed*.017+q*.07)%0.76
        for j in range(24):
            u=min(1.,u0+j*.007);ix=min(n,int(u*n))
            x,y=path[ix];dx=.8*math.sin(j*.72+seed+b);dy=.8*math.cos(j*.43+seed)
            p.append((x+dx,y+dy))
        line(d,p,(182,255,227,int(opacity*(.35+.06*b))),.6+(.15*b))
    # Hot moving gold / pale white particles physically ADVECT through the brush.
    for b in range(4):
        u=(q*(.72+.13*(layer%3))+b*.227+seed*.11)%1.
        ix=min(n,int(u*n));x,y=path[ix]
        st=path[max(0,ix-3):min(n+1,ix+5)]
        line(d,st,(254,237,165,231) if b==0 else (247,255,234,212),1.6+(b%2)*.8)
        ellipse(d,x,y,1.4+(b%2)*.65,(255,255,224,211))
    glow(dst,body,blur=10+width*.6,strength=.37)

def calligraphy(dst,cx,cy,scale,q,visibility=1):
    # Original abstract Han-seal brush geometry: minimal interrupted GOLD strokes,
    # not a static UI rectangle and not scraped Chinese font.
    v=max(0,min(1,visibility));layer=init(dst.width//S,dst.height//S);d=ImageDraw.Draw(layer,'RGBA')
    strokes=[
     [(-.20,-.48),(.18,-.47),(.26,-.25),(.06,-.05)],
     [(-.15,-.22),(.17,-.14),(-.20,.17),(.13,.14)],
     [(-.24,.04),(.16,.22),(.29,.42),(-.21,.44)],
     [(-.27,-.40),(-.30,-.14),(-.13,.21),(-.15,.40)],
    ]
    for k,ps in enumerate(strokes):
        path=[]
        for j,(x,y) in enumerate(bez(*[(cx+xx*scale,cy+yy*scale) for xx,yy in ps],n=35)):
            u=j/35
            path.append((x+scale*.012*math.sin(u*13+q*8+k),y+scale*.008*math.cos(u*9-q*4+k)))
        n=int(36*min(1,max(0,v*1.6-k*.12)))
        if n<3:continue
        line(d,path[:n],(124,211,171,int(122*v)),3.4)
        line(d,path[:n],(252,218,120,int(198*v)),1.8)
        line(d,path[:n],(255,253,213,int(211*v)),.6)
    glow(dst,layer,blur=8,strength=.26)

def hero(i,n=20,w=480):
    q=i/max(1,n-1)
    out=init(w,w);center=(w*.51,w*.48)
    # Arched wind dragons form an OPEN asymmetric oval with broad painterly ribbons.
    strands=[
        ((89,343),(45,239),(122,100),(299,101)),
        ((303,97),(423,99),(434,270),(331,340)),
        ((120,352),(230,395),(354,304),(398,220)),
        ((93,251),(156,284),(234,241),(260,174)),
        ((362,178),(267,115),(197,170),(143,252)),
    ]
    for k,(a,b,c,e) in enumerate(strands):
        live=min(1,max(0,(q+.24-k*.065)*2.0))
        if live<.03:continue
        drift=12*math.sin(q*math.tau*.75+k*1.12)
        warp=lambda p,m:(p[0]+m*drift,p[1]+5*math.sin(q*6+k+p[0]*.013))
        p=bez(warp(a,.24),warp(b,.48),warp(c,-.46),warp(e,-.2),100)
        seg=p[:max(4,int(101*live))]
        braided_ribbon(out,seg,q,k,width=(10 if k<2 else 6.5),opacity=192 if k<2 else 155,seed=k)
    # Distinct luminous brass seal crest floating just behind the upper edge.
    calligraphy(out,w*.55,w*.38,136,q,visibility=(.1+q*.9))
    motes=init(w,w);d=ImageDraw.Draw(motes,'RGBA');rnd=random.Random(5123+i)
    for k in range(38):
        a=k*2.399+q*.42;r=104+85*((k*7)%29)/29
        x=center[0]+r*math.cos(a)+rnd.uniform(-10,10)
        y=center[1]+r*.77*math.sin(a)+rnd.uniform(-8,8)
        radius=.55+rnd.random()*2.25
        ellipse(d,x,y,radius,(241,255,229,100+rnd.randint(0,95)) if k%4 else (255,233,148,128+rnd.randint(0,75)))
    glow(out,motes,4,.21)
    return output(out,w,w)

def field(i,n=16,w=512):
    q=i/max(1,n-1)
    out=init(w,w);cx=w*.52;cy=w*.58
    # Beautiful 2.5D oblique area projection instead of a flat HUD ring.
    currents=init(w,w);d=ImageDraw.Draw(currents,'RGBA')
    for k in range(9):
        a0=-.55+k*.67+q*.08
        span=.30+.29*math.sin(k*1.74)**2
        pts=[]
        for j in range(66):
            a=a0+j/65*span
            rad=(170+10*math.sin(a*7-q*4+k))*(.85+.15*q)
            x=cx+rad*math.cos(a);y=cy+rad*.38*math.sin(a)
            pts.append((x,y))
        line(d,pts,(40,220,184,142 if k%2 else 98),5.0)
        line(d,pts,(225,255,220,142 if k%3==0 else 77),1.2)
    glow(out,currents,9,.28)
    # 3 hand-inked wind swirls, ephemeral and not mark receipts.
    for j,(a,r) in enumerate([(.5,122),(2.8,126),(4.9,132)]):
        px=cx+math.cos(a+q*.12)*r;py=cy+math.sin(a+q*.12)*r*.40
        calligraphy(out,px,py,46,q,visibility=min(1,(q+.3)*1.2))
    return output(out,w,w)

def charge(i,n=12,w=320):
    q=i/max(1,n-1);out=init(w,w)
    flow=[((44,251),(78,186),(125,129),(170,160)),((267,247),(218,203),(213,137),(164,155)),((175,64),(223,99),(199,140),(165,159))]
    for k,(a,b,c,e) in enumerate(flow):
        curve=bez((a[0]+q*12,a[1]),b,c,e,90)
        braided_ribbon(out,curve[:max(4,int(91*(.20+.8*q)))],q,k,width=6,opacity=205,seed=12+k)
    calligraphy(out,165,157,86,q,visibility=q)
    return output(out,w,w)

def contact(i,n=12,w=256):
    q=i/max(1,n-1);out=init(w,w)
    for k in range(6):
        a=-2.75+k*1.13
        grow=math.sin(math.pi*q*.95)
        end=(128+(38+77*grow)*math.cos(a),128+(40+69*grow)*math.sin(a))
        path=bez((127,138),(130+16*math.cos(a),99),(end[0]-12,end[1]-15),end,48)
        braided_ribbon(out,path,q,k,width=4.0,opacity=164,seed=30+k)
    calligraphy(out,128,120,72,q,visibility=1-.28*q)
    return output(out,w,w)

def residue(i,n=8,w=256):
    q=i/max(1,n-1);out=init(w,w);d=ImageDraw.Draw(out,'RGBA');random.seed(100+i)
    for k in range(26):
        x=128+random.uniform(-108,108);y=129+random.uniform(-90,90)-15*q
        r=random.uniform(.8,2.8)*(1-.44*q)
        ellipse(d,x,y,r,(123,250,211,round((145+50*random.random())*(1-q*.82))) if k%3 else (253,232,163,round(170*(1-q*.67))))
    return output(out,w,w)

def badge(i,n=8,w=128):
    q=i/max(1,n-1);out=init(w,w)
    calligraphy(out,64,60,95,q,visibility=.82+.18*math.sin(q*math.tau))
    d=ImageDraw.Draw(out,'RGBA')
    pts=bez((44,97),(26,67),(52,26),(87,48),40)
    line(d,pts,(75,244,204,126),2.0)
    return output(out,w,w)

def atlas(frames,w):
    img=Image.new('RGBA',(4*w,w*math.ceil(len(frames)/4)))
    for i,f in enumerate(frames):img.alpha_composite(f,((i%4)*w,(i//4)*w))
    return img

def hybrid(base,emission):
    # First-party photonic density-field white core OVER independently authored
    # semi-transparent colored material; phase changes in BOTH layer sources.
    base.alpha_composite(emission)
    return base

def painted(name,i,n,w,fn):
    phase=i/max(1,n-1)
    original=fn(i,n,w)
    if name=='charge':return hybrid(original,light_charge(phase,w))
    if name=='hero':return hybrid(original,light_hero(phase,w))
    if name=='ward':return hybrid(original,light_field(phase,w))
    if name=='contact':return hybrid(original,light_contact(phase,w))
    return original

def main():
    SRC.mkdir(parents=True,exist_ok=True);OUT.mkdir(parents=True,exist_ok=True)
    painted('hero',12,20,480,hero).resize((960,960),Image.Resampling.LANCZOS).save(SRC/'paf05_wind_crest_hero_master.png')
    painted('contact',5,12,256,contact).resize((768,768),Image.Resampling.LANCZOS).save(SRC/'paf05_animated_mark_master.png')
    data=[('charge',12,320,charge),('ward',16,512,field),('hero',20,480,hero),('contact',12,256,contact),('residue',8,256,residue),('badge',8,128,badge)]
    for name,n,w,fn in data:
        sheet=atlas([painted(name,i,n,w,fn) for i in range(n)],w)
        path=OUT/f'paf05_{name}.webp';sheet.save(path,'WEBP',quality=95,method=5,exact=True)
        al=np.array(sheet.getchannel('A'))
        print('PAF05_ATLAS',path.name,'frames',n,'dimensions',sheet.size,'max_alpha',int(al.max()),'p50_positive_alpha',int(np.median(al[al>8])) if np.any(al>8) else 0,'sha256',hashlib.sha256(path.read_bytes()).hexdigest())
    print('PAF05_SOURCE_BAKE_PASS')
if __name__=='__main__':main()
