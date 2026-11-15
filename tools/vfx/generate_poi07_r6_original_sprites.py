#!/usr/bin/env python3
"""POI07 R6 ORIGINAL sprite art. Hand-authored bone/glass poison needle; no poster/UI/third-party art.
Produces true transparent, individually drawn poses rather than recoloring legacy R5.
Pillow >=9; standalone deterministic source with SHA manifest at QA time.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
from math import sin, cos, pi, exp
import random

OUT = Path(__file__).resolve().parents[2] / "godot/labs/combat_lab/poison07/r6_original/assets"
OUT.mkdir(parents=True, exist_ok=True)
S = 2  # supersampled raster brush; final asset is normal-resolution sprite
INK=(31,15,53); PURPLE=(111,39,160); PLUM=(178,91,204)
JADE=(74,217,151); PALE=(228,254,213); BONE=(191,170,194)

def canvas(w,h): return Image.new("RGBA",(w*S,h*S),(0,0,0,0))
def poly(d,pts,c): d.polygon([(int(x*S),int(y*S)) for x,y in pts], fill=c)
def line(d,pts,c,wd=1): d.line([(int(x*S),int(y*S)) for x,y in pts],fill=c,width=max(1,int(wd*S)),joint="curve")
def ellipse(d,x,y,r,c): d.ellipse((int((x-r)*S),int((y-r)*S),int((x+r)*S),int((y+r)*S)),fill=c)
def blend(a,b,blur=0,mul=1):
    if blur:b=b.filter(ImageFilter.GaussianBlur(blur*S))
    if mul!=1:b.putalpha(b.getchannel("A").point(lambda x:min(255,int(x*mul))))
    return Image.alpha_composite(a,b)
def finish(im,w,h):
    # Preserve feathery RGB/alpha, with antialiasing at native scale.
    result=im.resize((w,h), Image.Resampling.LANCZOS)
    assert result.mode=="RGBA"
    return result

def drifting_smoke(w,h,seed,origin,strength,extent,direction,number):
    """Ink-cloud paint: layered elliptical feathered lobes, non-uniform edge and opacity."""
    rng=random.Random(seed)
    lo=canvas(w,h); d=ImageDraw.Draw(lo,"RGBA")
    ox,oy=origin
    for i in range(number):
        t=rng.random()
        ax=ox-direction*t*extent+rng.uniform(-9,9)
        ay=oy+sin(t*9+seed)*8*rng.uniform(.25,1)
        rr=rng.uniform(1.5,8.7)*(1-.61*t)*strength
        cc=[(63,22,110,95),(94,36,149,105),(40,102,87,77),(122,58,170,73)][i%4]
        ellipse(d,ax,ay,rr,cc)
    return lo

def hero(i):
    """Twelve genuinely re-drawn asymmetrical forged acupuncture-needle poses."""
    W,H=256,160; im=canvas(W,H)
    r=random.Random(6205+i*197)
    d=ImageDraw.Draw(im,"RGBA")
    birth=(i+.5)/12
    body_len=148+11*sin(i*.76)  # pose variation at source pixel level
    bx=68+5*sin(i*.51); tip=bx+body_len
    cy=80+3*sin(i*.93); peak=13+4*sin(i*.71)
    cloud=drifting_smoke(W,H,1520+i,(bx+22,cy),.83,86,1,45)
    im=blend(im,cloud,4,.51);im=blend(im,cloud,0,.35)
    d=ImageDraw.Draw(im,"RGBA")
    # Core bony violet-black shaft, deliberately thicker than a pure glowing line.
    upper=[(bx-13,cy-3),(bx+21,cy-8),(bx+49,cy-peak),(bx+94,cy-10),
           (tip-17,cy-5),(tip+2,cy),(tip-17,cy+7),(bx+88,cy+11),
           (bx+51,cy+peak-1),(bx+19,cy+7),(bx-11,cy+5)]
    poly(d,upper,(27,17,51,250))
    poly(d,[(bx-8,cy-1),(bx+22,cy-7),(bx+52,cy-peak+2),(bx+92,cy-7),
            (tip-17,cy-3),(tip,cy),(bx+86,cy),(bx+40,cy+3)],(110,44,158,228))
    poly(d,[(bx+2,cy+2),(bx+48,cy+7),(bx+85,cy+9),(tip-26,cy+4),
            (tip,cy),(tip-34,cy+1),(bx+46,cy-1)],(49,111,102,229))
    # Sculpted hooked poison barbs with tipward orientation; vary frame pose.
    for k in range(5):
        xx=bx+25+k*24+(2.3*sin(i*.74+k))
        width=9-k*.8
        sign=1 if k%2 else -1
        dy=sign*(12+5*sin(i*.5+k*1.3))
        poly(d,[(xx-6,cy+sign*4),(xx+5,cy+dy),(xx+width+7,cy+sign*5),
                (xx+4,cy+sign*2)],(32,24,65,224))
        line(d,[(xx-1,cy+sign*4),(xx+5,cy+dy)],(147,77,189,195),1.2)
    # Upper enamel bevel; counter-edge painted jade and white pinpoint tip.
    poly(d,[(bx+10,cy-4),(bx+51,cy-peak+5),(bx+98,cy-4),(tip-8,cy-1),
            (tip,cy),(bx+93,cy-2)],(214,165,225,204))
    poly(d,[(bx+17,cy+2),(bx+65,cy+8),(bx+103,cy+4),(tip,cy),
            (bx+82,cy+3)],(85,237,177,229))
    line(d,[(bx+38,cy-2),(tip-2,cy)],(247,255,232,240),1.25)
    # Uneven internal toxic veins: translucent etched engraving, not vector tubes.
    for k in range(7):
        x0=bx+17+k*17
        x1=x0+12
        yy=cy+4*sin(k*1.8+i*.27)
        line(d,[(x0,yy),(x0+6,yy-2.7),(x1,yy-1)],(117,249,194,182),1)
    # Loose bramble dust generated for each unique pose.
    dust=canvas(W,H);dd=ImageDraw.Draw(dust,"RGBA")
    for k in range(58):
        x=r.uniform(max(11,bx-72),tip+3)
        y=cy+r.gauss(0,17)
        sz=r.uniform(.45,1.9)*(1-.55*(x/max(1,tip)))
        col=[(173,91,218,124),(85,246,173,169),(241,255,218,112),(46,22,73,163)][k%4]
        poly(dd,[(x-sz,y),(x,y-2*sz),(x+sz,y),(x,y+sz*.65)],col)
    im=blend(im,dust,0,1)
    # Feathery light spill is created from painted needle's own pixels, not a uniform ring.
    glow=im.filter(ImageFilter.GaussianBlur(7*S))
    glow.putalpha(glow.getchannel("A").point(lambda a:int(a*.31)))
    im=Image.alpha_composite(glow,im)
    return finish(im,W,H)

def charge(i):
    """Charge: 10 unique irregular bone needle splinters drawn while condensing."""
    W=H=192;r=random.Random(7714+i*53)
    q=(i+.75)/10
    im=canvas(W,H);behind=canvas(W,H);bd=ImageDraw.Draw(behind,"RGBA")
    cx,cy=103,96
    # Tiny poison spirit shards converge from behind palm into a single sharp spear.
    for k in range(11):
        angle=(k*2.399)+.22*sin(i*.72+k)
        rad=(77*(1-q)+11*q)*(0.7+.6*r.random())
        x=cx+rad*cos(angle)-15*(1-q)
        y=cy+rad*sin(angle)*.82
        leng=(12+7*r.random())*(.8+.35*q)
        tip=(x+leng*(.64+.36*q),y-1)
        poly(bd,[(x-4,y+5),(x+leng*.4,y-5),(tip[0],tip[1]),
                 (x+leng*.27,y+3)],(34,20,70,round(196*q)))
        line(bd,[(x,y),(tip[0],tip[1])],(130,248,167,round(212*q)),1)
    im=blend(im,behind,5,.59);im=blend(im,behind,0,1)
    ink=canvas(W,H);d=ImageDraw.Draw(ink,"RGBA")
    # Form an unmistakable dangerous point in the center before release.
    blade=8+38*q;h=3+8*q
    poly(d,[(cx-blade*.65,cy-2),(cx,cy-h),(cx+blade,cy),
            (cx,cy+h),(cx-blade*.7,cy+3)],(29,19,69,round(247*q)))
    poly(d,[(cx-blade*.52,cy-1),(cx+blade*.9,cy),
             (cx,cy+1.5)],(223,255,219,round(242*q)))
    for k in range(18):
        dx=r.uniform(-54,49)*(1-q)
        dy=r.uniform(-43,43)*(1-q)
        size=r.uniform(.5,2.1)
        ellipse(d,cx+dx,cy+dy,size,(91,239,175,round(175*q)))
    im=blend(im,ink,7,.52);im=blend(im,ink,0,1)
    return finish(im,W,H)

def impact(i):
    """Twelve stage genuinely changing micro-puncture shapes, no radial AoE ring or fake poison."""
    W=H=256; im=canvas(W,H);r=random.Random(2871+i*113)
    cx,cy=125,128
    # 0-2 flash, 3-5 glancing splinters, 6-9 bruised local fracture, 10-11 dissolve.
    times=[.33,.81,1.,.96,.89,.76,.59,.45,.34,.22,.13,.035]
    fade=times[i]
    ink=canvas(W,H);idraw=ImageDraw.Draw(ink,"RGBA")
    cool=canvas(W,H);cdraw=ImageDraw.Draw(cool,"RGBA")
    flame=canvas(W,H);fdraw=ImageDraw.Draw(flame,"RGBA")
    # Needle penetrates left->right: deep dark slash flanked by 2 uneven tears.
    length=45+42*fade
    poly(idraw,[(cx-length*.75,cy-3),(cx-7,cy-13*fade),
                 (cx+length*.68,cy-7),(cx+length,cy),
                 (cx+length*.47,cy+10*fade),(cx-8,cy+13*fade)],(23,16,50,round(218*fade)))
    poly(cdraw,[(cx-length*.45,cy-2),(cx+length*.77,cy-2),
                (cx+length,cy),(cx+length*.67,cy+1.3)],(138,67,177,round(232*fade)))
    line(fdraw,[(cx-length*.51,cy-1),(cx+length*.87,cy)],(252,254,230,round(247*fade)),2.2)
    # Fracture splinters travel a *short* distance from puncture; no explosion covering face.
    for j in range(8):
        a=(-2.13+j*.47)+.12*sin(i*.75+j)
        rr=(11+j%3*6+17*fade)*(1-.5*(i/11))
        x=cx+cos(a)*rr; y=cy+sin(a)*rr*.72
        w=2+r.random()*3
        poly(idraw,[(cx-8,cy),(x-w,y-3),(x+3,y),(x,y+w)],
             (42,24,84,round(104*fade)))
        line(cdraw,[(cx-6,cy),(x,y)],(94,220,156,round(170*fade)),1.6)
    for j in range(27):
        a=r.uniform(-pi,pi); rr=r.uniform(9,52)*(.55+.45*fade)
        x=cx+cos(a)*rr;y=cy+sin(a)*rr*.72
        size=r.uniform(.5,2.1)
        poly(fdraw,[(x-size,y),(x,y-size*2),(x+size,y),(x,y+size)],
             (134,249,177,round(115*fade)))
    for layer,blur,alpha in [(ink,7,.55),(ink,0,.94),(cool,4,.55),
                             (cool,0,1),(flame,5,.40),(flame,0,1)]:
        im=blend(im,layer,blur,alpha)
    return finish(im,W,H)

def export(name,frames,cell,ncol=4):
    w,h=cell
    atlas=Image.new("RGBA",(w*ncol,h*((len(frames)+ncol-1)//ncol)),(0,0,0,0))
    distinct=set()
    for i,f in enumerate(frames):
        assert f.size==cell
        a=f.getchannel("A")
        assert a.getbbox(),(name,i,"empty")
        for rc in [(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)]:
            assert a.crop(rc).getextrema()[1]==0,(name,i,"alpha seam")
        import hashlib
        distinct.add(hashlib.sha256(f.tobytes()).hexdigest())
        atlas.alpha_composite(f,((i%ncol)*w,(i//ncol)*h))
    assert len(distinct)==len(frames),(name,"duplicate frames")
    dest=OUT/name
    atlas.save(dest,compress_level=9,optimize=True)
    print("POI07_R6_SPRITE",name,"cells",len(frames),"distinct",len(distinct),"size",atlas.size,"bytes",dest.stat().st_size)
    return atlas.size
if __name__=="__main__":
    dims=[
        export("bone_needle_r6_12.png",[hero(i) for i in range(12)],(256,160)),
        export("bone_charge_r6_10.png",[charge(i) for i in range(10)],(192,192)),
        export("bone_puncture_r6_12.png",[impact(i) for i in range(12)],(256,256)),
    ]
    raw=sum(x*y*4 for x,y in dims)
    print("POI07_R6_RAW_TEXTURE_BYTES",raw,"MIB",round(raw/1048576,3))
    assert raw < 8*1048576,"texture cap exceeded"
