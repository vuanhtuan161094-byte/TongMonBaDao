#!/usr/bin/env python3
"""Original first-party POI07 R4 12+12 pose painted alpha flipbooks; no external game pixels."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison07/assets"
SIZE=320
FRAMES=12

def layer():
    return Image.new("RGBA",(SIZE,SIZE))
def blend(base,paint,blur=0,alpha=1):
    if blur: paint=paint.filter(ImageFilter.GaussianBlur(blur))
    if alpha!=1: paint.putalpha(paint.getchannel("A").point(lambda a:round(a*alpha)))
    return Image.alpha_composite(base,paint)
def bez(a,b,c,t):
    return ((1-t)**2*a[0]+2*(1-t)*t*b[0]+t*t*c[0],(1-t)**2*a[1]+2*(1-t)*t*b[1]+t*t*c[1])
def taper(draw,points,width,rgba):
    for k,p in enumerate(points):
        q=k/max(1,len(points)-1)
        r=max(.4,width*(1-q)**.58+.08)
        col=rgba[:3]+(int(rgba[3]*(1-.26*q)),)
        draw.ellipse((p[0]-r,p[1]-r,p[0]+r,p[1]+r),fill=col)
def charge(i):
    rng=random.Random(307116+i*31)
    q=(i+.5)/FRAMES
    dst=(171,160)
    sm=layer();sd=ImageDraw.Draw(sm,"RGBA")
    ri=layer();rd=ImageDraw.Draw(ri,"RGBA")
    co=layer();cd=ImageDraw.Draw(co,"RGBA")
    sp=layer();pd=ImageDraw.Draw(sp,"RGBA")
    # Asymmetric ink streamers FLOW INTO palm, no ring geometry.
    for k in range(8):
        a=[-2.75,-2.13,-1.43,-.8,.16,.87,1.69,2.4][k]+.19*math.sin(i*.47+k*.83)
        radius=(95-49*q+12*math.sin(i*.3+k*1.77))*[1.25,.65,1.12,.83,1.38,.73,1.05,.54][k]
        start=(dst[0]-abs(math.cos(a))*radius*.92-7,dst[1]+math.sin(a)*radius*.71)
        turn=(dst[0]-17-math.cos(a+1.1)*(24+28*(1-q)),dst[1]+math.sin(a+1.38)*(23+32*(1-q)))
        end=(dst[0]+rng.uniform(-11,11)*(1-q),dst[1]+rng.uniform(-9,9)*(1-q))
        pts=[bez(start,turn,end,j/55) for j in range(56)]
        thick=4.1 if k%3 else 6.9
        ink=[(50,26,95,115),(71,39,153,145),(29,111,113,120),(71,191,142,154)][k%4]
        taper(sd,pts,thick*2.7,ink)
        taper(rd,pts,thick,(156,107,224,176) if k%3 else (95,233,170,169))
        if k%2==0:taper(cd,pts,1.45,(244,229,251,188) if k%4 else (213,255,226,206))
    for k in range(30):
        a=rng.random()*math.tau
        r=rng.uniform(16,120)*(.3+.7*(1-q))
        x=dst[0]+r*math.cos(a);y=dst[1]+r*math.sin(a)*.75
        s=rng.uniform(.7,2.8)*(.6+q*.55)
        col=[(113,239,183,176),(164,81,230,139),(237,250,228,160),(59,31,96,122)][k%4]
        pd.polygon([(x-s,y+s),(x,y-2*s),(x+s*.7,y-s*.1),(x,y+s)],fill=col)
    power=min(1.0,max(.04,q*1.2))
    r=3+10*q
    cd.polygon([(dst[0]-r*1.5,dst[1]-2),(dst[0]-3,dst[1]-r*.78),(dst[0]+r*.82,dst[1]-r*.32),(dst[0]+r*1.4,dst[1]),(dst[0]+r*.72,dst[1]+r*.4),(dst[0]-5,dst[1]+r*.89)],fill=(38,15,72,round(219*power)))
    cd.polygon([(dst[0]-r*.3,dst[1]-r*.45),(dst[0]+r*.97,dst[1]-2),(dst[0]+r*.15,dst[1]+1)],fill=(232,250,211,round(235*power)))
    out=layer()
    for im,blur,alpha in [(sm,12,.43),(sm,3,.62),(ri,3,.68),(ri,0,.8),(co,4,.7),(co,0,.93),(sp,0,.9)]:
        out=blend(out,im,blur,alpha)
    return out

def contact(i):
    rng=random.Random(14487+i*157)
    q=i/(FRAMES-1)
    energy=max(.03,min(1.,(i+1)/3.0)*(1-q)**.8)
    cx,cy=160,157
    blot=layer();bd=ImageDraw.Draw(blot,"RGBA")
    shard=layer();sd=ImageDraw.Draw(shard,"RGBA")
    hot=layer();hd=ImageDraw.Draw(hot,"RGBA")
    grain=layer();gd=ImageDraw.Draw(grain,"RGBA")
    # Localized needle impact, no giant AoE circle, poison DoT or damage number.
    for j in range(13):
        sign=-1 if j<8 else 1
        slope=rng.uniform(-.95,.95)
        length=(24+rng.uniform(19,86))*(.36+energy*.95)
        end=(cx+sign*length,cy+slope*length*.72)
        turn=(cx+sign*length*.41,cy+slope*length*.41+rng.uniform(-9,9))
        pts=[bez((cx,cy),turn,end,t/36) for t in range(37)]
        taper(bd,pts,8 if j%3==0 else 5.8,(32,14,59,int(157*energy)))
        taper(sd,pts,2.6 if j%4==0 else 1.7,(118,54,191,int(211*energy)))
        if j%3==0:taper(hd,pts,1.1,(238,238,251,int(190*energy)))
    for k,a0 in enumerate([-2.69,-1.91,-.79,.48,1.46,2.19]):
        a=a0+.12*math.sin(i*.66+k)
        length=[57,30,74,39,54,24][k]*energy
        side=[9,14,7,12,8,5][k]*energy
        ax=cx+math.cos(a)*length;ay=cy+math.sin(a)*length*.67
        nx=-math.sin(a);ny=math.cos(a)
        bd.polygon([(cx,cy),(cx+(ax-cx)*.54+nx*side,cy+(ay-cy)*.54+ny*side),(ax,ay),(cx+(ax-cx)*.37-nx*side*.7,cy+(ay-cy)*.37-ny*side*.7)],fill=(49,20,98,int(113*energy)))
        sd.line([(cx,cy),(ax,ay)],fill=(145,70,205,int(82*energy)),width=2)
    extent=42*(.46+.54*energy)
    sd.polygon([(cx-extent,cy-2.2),(cx+8,cy-5.8),(cx+20,cy),(cx+7,cy+5.3),(cx-extent*.65,cy+1.4)],fill=(35,19,79,int(237*energy)))
    hd.polygon([(cx-extent,cy-1),(cx+13,cy-1.5),(cx+20,cy),(cx+10,cy+1.1),(cx-extent*.7,cy+.4)],fill=(241,253,233,int(251*energy)))
    for k in range(44):
        angle=rng.random()*math.tau
        rr=rng.uniform(7,73)*(.35+energy*.8)
        x=cx+rr*math.cos(angle);y=cy+rr*math.sin(angle)*.74
        s=rng.uniform(.7,2.7)*(.5+energy)
        col=[(92,232,164,int(171*energy)),(181,112,239,int(146*energy)),(228,255,233,int(166*energy))][k%3]
        gd.polygon([(x-s,y+s),(x,y-2*s),(x+s,y),(x,y+s*.4)],fill=col)
    out=layer()
    for im,blur,alpha in [(blot,10,.6),(blot,3,.61),(shard,4,.85),(shard,0,.8),(hot,6,.45),(hot,0,.99),(grain,1,.9)]:
        out=blend(out,im,blur,alpha)
    return out

def pack(frames,name):
    atlas=Image.new("RGBA",(SIZE*4,SIZE*3))
    for i,img in enumerate(frames):
        alpha=img.getchannel("A")
        assert alpha.getbbox(),(name,i,"empty")
        assert all(alpha.crop(b).getextrema()[1]==0 for b in [(0,0,SIZE,1),(0,SIZE-1,SIZE,SIZE),(0,0,1,SIZE),(SIZE-1,0,SIZE,SIZE)]),(name,i,"alpha edge")
        atlas.alpha_composite(img,((i%4)*SIZE,(i//4)*SIZE))
    OUT.mkdir(parents=True,exist_ok=True)
    dest=OUT/name
    atlas.save(dest,compress_level=9,optimize=True)
    print(name,atlas.size,dest.stat().st_size)
if __name__=="__main__":
    pack([charge(i) for i in range(FRAMES)],"doc_cham_charge_r4_12.png")
    pack([contact(i) for i in range(FRAMES)],"doc_cham_contact_r4_12.png")
