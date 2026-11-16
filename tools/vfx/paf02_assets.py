#!/usr/bin/env python3
"""PAF02 Thái Huyền Khép Ấn: original jade-gold, frame-painted folding wind seals.
Never a projectile; 5.5 s mark is status-only. No rig or proprietary pixels.
One original source master plus 14/18/12/8 painted optical poses.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math, random, hashlib, argparse
from paf02_r4_vietnamese_paper import render as painted_initial_paper

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'godot/labs/combat_lab/talisman12/assets'
SRC=ROOT/'godot/labs/combat_lab/talisman12/art_sources'
FONT='/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc'
PAINT_LINE=SRC/'paf02_r2_line_paint.webp'
PAINT_IMPACT=SRC/'paf02_r2_impact_paint.webp'
S=3

def C(x):return round(x*S)
def coords(pts):return [(C(x),C(y)) for x,y in pts]
def bez(a,b,c,d,steps=36):
    return [((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0],(1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1]) for t in (i/steps for i in range(steps+1))]
def path(dst,points,ink,width=2):
    d=ImageDraw.Draw(dst,'RGBA');d.line(coords(points),fill=ink,width=max(1,C(width)),joint='curve')
def luma(img,blur=8,gain=.33):
    g=img.filter(ImageFilter.GaussianBlur(C(blur)))
    g.putalpha(g.getchannel('A').point(lambda p:round(p*gain)))
    out=Image.new('RGBA',img.size);out.alpha_composite(g);out.alpha_composite(img);return out

def glyph(img,ch,x,y,sz,ink,stroke=(196,165,77,195)):
    d=ImageDraw.Draw(img,'RGBA')
    d.text((C(x),C(y)),ch,font=ImageFont.truetype(FONT,C(sz)),fill=ink,stroke_width=C(1.4),stroke_fill=stroke)

def paint_source(file,width,height,alpha=1):
    source=Image.open(file).convert("RGBA")
    source=source.resize((C(width),C(height)),Image.Resampling.LANCZOS)
    if alpha<1:
        source.putalpha(source.getchannel("A").point(lambda v:int(v*alpha)))
    return source

def place_center(dst,src,x,y):
    dst.alpha_composite(src,(int(C(x)-src.width/2),int(C(y)-src.height/2)))

def render_hero(i=9,n=14):
    W=H=560; out=Image.new('RGBA',(C(W),C(H))); k=i/(n-1)
    rng=random.Random(74142+i)
    # Folding silk inserts: three different wind-slip leaves fold inward and unfold into one Tai-Huyen crest.
    cloth=Image.new('RGBA',out.size);d=ImageDraw.Draw(cloth,'RGBA')
    for j in range(3):
        a=(-1.18,0.38,2.15)[j]+math.sin(k*math.pi)*(0.28 if j==1 else -.19)
        extent=(42+102*k)*(1 if j!=2 else .83)
        cx,cy=278+math.cos(a)*extent*.43,273+math.sin(a)*extent*.49
        w=24+19*math.sin(math.pi*k)+7*j
        leaf=[(cx-23*w/40,cy-70*k-31),(cx+44+16*k,cy-64-15*math.sin(k*5+j)),(cx+w*1.25,cy+43+18*k),(cx-35+9*j,cy+62+12*k)]
        d.polygon(coords(leaf),fill=((27,166,144,110),(37,126,123,125),(68,199,170,101))[j])
        d.line(coords(leaf+[leaf[0]]),fill=(228,179,78,190),width=C(3),joint='curve')
        for b in range(8):
            t=b/7
            yy=cy-53+112*t
            d.line(coords([(cx-12+11*math.sin(yy*.08+j),yy),(cx+19+7*math.cos(t*10+j),yy+12)]),fill=(247,224,144,int(90*(1-abs(t-.5)))),width=C(1.3))
    out.alpha_composite(luma(cloth,9,.31))
    # Distinctive broken sinuous inner crest, not a concentric HUD circle.
    arc=Image.new('RGBA',out.size)
    for s in range(4):
        pts=[]
        for h in range(66):
            q=h/65; a=-2.6+s*.57+q*(1.50+0.24*s)+k*.20
            r=94+22*math.sin(q*math.pi)+17*math.sin(q*5.0+s)
            pts.append((278+r*math.cos(a)*1.30,270+r*math.sin(a)*.72))
        path(arc,pts,(89,240,215,200 if s==0 else 104),7 if s==0 else 3)
    out.alpha_composite(luma(arc,12,.25))
    painted=paint_source(PAINT_LINE,314+18*q,150+8*q,.56)
    painted=painted.rotate(-41+12*q,Image.Resampling.BICUBIC,expand=True)
    place_center(out,painted,278,277)
    crest=Image.new('RGBA',out.size)
    # Brush-calligraphy jade spirit 玄, crossed with two quill-like ribbons.
    glyph(crest,'玄',213,173,136,(228,252,211,232),(24,155,139,215))
    path(crest,bez((183,183),(241,123),(307,142),(347,183)),(248,211,123,185),5)
    path(crest,bez((187,357),(248,419),(348,351),(363,272)),(90,250,217,194),7)
    path(crest,bez((193,354),(255,404),(337,346),(352,274)),(250,248,197,184),2)
    # A royal jade knot instead of a rectangle/paper card.
    d=ImageDraw.Draw(crest,'RGBA')
    for xx,yy,rad in [(278,128,14),(151,292,9),(387,316,11)]:
        d.ellipse((C(xx-rad),C(yy-rad),C(xx+rad),C(yy+rad)),fill=(23,119,109,200),outline=(244,217,129,225),width=C(3))
        d.ellipse((C(xx-4),C(yy-6),C(xx+4),C(yy+2)),fill=(230,250,204,160))
    out.alpha_composite(luma(crest,13,.42))
    fibres=Image.new('RGBA',out.size);fd=ImageDraw.Draw(fibres,'RGBA')
    for j in range(70):
        a=rng.random()*math.tau;r=rng.uniform(103,224)
        x=278+math.cos(a)*r;y=268+math.sin(a)*r*.8
        alpha=rng.randint(22,128);rad=rng.uniform(.4,1.4)
        fd.ellipse((C(x-rad),C(y-rad),C(x+rad),C(y+rad)),fill=(247,223,133,alpha))
    out.alpha_composite(fibres)
    return out.resize((W,H),Image.Resampling.LANCZOS)

def wind_line(i):
    W,H=512,256;out=Image.new('RGBA',(C(W),C(H)));q=i/17
    trails=Image.new('RGBA',out.size)
    for s in range(5):
        points=[]
        for j in range(96):
            p=j/95
            x=8+492*p
            y=128+(18+13*s)*math.sin(p*6.6+s*1.1+i*.25)*(1-.33*p)
            y+=11*math.sin(p*15+i*.28+s*.6)
            points.append((x,y))
        for j in range(1,len(points)):
            p=j/95
            fade=max(0,math.sin(p*math.pi))*(.65+.35*math.sin(i*.17+s))
            width=(11 if s==0 else 3.5 if s==1 else 2.0)*fade
            ink=(83,242,211,round((170 if s==0 else 113)*fade)) if s!=1 else (244,240,182,round(210*fade))
            path(trails,[points[j-1],points[j]],ink,max(.33,width))
    out.alpha_composite(luma(trails,14,.45))
    painting=paint_source(PAINT_LINE,472,151,.92)
    place_center(out,painting,253,125)
    d=ImageDraw.Draw(out,'RGBA')
    # Natural broken golden embroidery along a single LINE, not three fake gameplay shots.
    for s in range(11):
        x=35+s*43+6*math.sin(i*.4+s)
        y=126+19*math.sin(s*.89+i*.19)
        length=3+5*math.sin((s+.5)/12*math.pi)
        d.line(coords([(x-length,y+3),(x,y-3),(x+length*2,y-5)]),fill=(253,224,139,170),width=C(1.1))
    return out.resize((W,H),Image.Resampling.LANCZOS)

def close_seal(i):
    W=H=256;out=Image.new('RGBA',(C(W),C(H)));q=i/11
    overlay=Image.new('RGBA',out.size)
    # Three origami-like jade claw petals close around chest then dissolve.
    for s in range(3):
        ang=(-2.7,-.8,1.0)[s]+q*.66*(1 if s!=1 else -1)
        pts=[]
        for j in range(30):
            p=j/29;r=70*(1-q*.50)+17*math.sin(p*math.pi)
            a=ang+p*(1.15+q*.30)
            pts.append((128+r*math.cos(a),128+r*math.sin(a)))
        path(overlay,pts,(42,199,174,round(180*(1-q*.25))),8*(1-q*.55))
        path(overlay,pts,(245,239,182,round(140*(1-q*.24))),2)
    glyph(overlay,'玄',92,71,68,(225,253,219,round(230*(1-q*.36))),(42,190,157,156))
    out.alpha_composite(luma(overlay,11,.42))
    bloom=paint_source(PAINT_IMPACT,116,150,.56*(1-.36*q))
    place_center(out,bloom,128,130)
    return out.resize((W,H),Image.Resampling.LANCZOS)

def status_badge(i):
    W=H=128;out=Image.new('RGBA',(C(W),C(H)));q=i/7
    glyph(out,'風',36,30,57,(198,255,219,215),(28,168,141,170))
    mist=Image.new('RGBA',out.size)
    path(mist,bez((11,69),(23,20+8*q),(92,105-7*q),(120,43)),(70,216,186,105),2)
    out.alpha_composite(luma(mist,5,.21))
    return out.resize((W,H),Image.Resampling.LANCZOS)

def atlas(frames,w,h):
    im=Image.new('RGBA',(w*4,h*((len(frames)+3)//4)))
    for i,frame in enumerate(frames):im.alpha_composite(frame,((i%4)*w,(i//4)*h))
    return im

def main():
    OUT.mkdir(parents=True,exist_ok=True);SRC.mkdir(parents=True,exist_ok=True)
    # R3 repair only the opening talisman, using owner-approved paper material.
    # PAF02 wind_line/contact/badge generators remain byte-for-byte identical.
    master=painted_initial_paper(7)
    master.save(SRC/'paf02_thai_huyen_original_master.png')
    files={
        'paf02_charge.webp': (atlas([painted_initial_paper(i,14).resize((320,320),Image.Resampling.LANCZOS) for i in range(14)],320,320),14),
        'paf02_line.webp': (atlas([wind_line(i) for i in range(18)],512,256),18),
        'paf02_contact.webp':(atlas([close_seal(i) for i in range(12)],256,256),12),
        'paf02_badge.webp': (atlas([status_badge(i) for i in range(8)],128,128),8)
    }
    for name,(image,n) in files.items():
        p=OUT/name;image.save(p,'WEBP',quality=88,method=3,exact=True)
        print('PAF02_ATLAS',name,'size',image.size,'frames',n,'sha',hashlib.sha256(p.read_bytes()).hexdigest())
    print('PAF02_ORIGINAL_ART_BAKE_PASS')
    print('PAF02_R3_OPENING_TALISMAN_BAKE_PASS')
if __name__=='__main__':main()
