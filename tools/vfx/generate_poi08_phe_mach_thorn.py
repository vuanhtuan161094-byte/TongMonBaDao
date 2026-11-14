#!/usr/bin/env python3
"""POI08 original Human Doc Cham braided thorn / vein imprint sprite flipbooks.
First-party deterministic Pillow raster painting: no commercial Source A / JX / VL pixels.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import random,math
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison08/assets"
def blank(w,h):return Image.new("RGBA",(w,h))
def glaze(dst,im,r,a):
    if r: im=im.filter(ImageFilter.GaussianBlur(r))
    if a!=1: im.putalpha(im.getchannel("A").point(lambda x:int(x*a)))
    return Image.alpha_composite(dst,im)
def ribbon(draw,pts,width,col):
    for n,(x,y) in enumerate(pts):
        t=n/max(1,len(pts)-1)
        rad=max(.45,width*(1-t*.64))
        draw.ellipse((x-rad,y-rad,x+rad,y+rad),fill=col[:3]+(round(col[3]*(1-.2*t)),))
def thorn(i):
    W,H=384,192;out=blank(W,H)
    shadow=blank(W,H);sd=ImageDraw.Draw(shadow,"RGBA")
    body=blank(W,H);bd=ImageDraw.Draw(body,"RGBA")
    shine=blank(W,H);hd=ImageDraw.Draw(shine,"RGBA")
    rng=random.Random(18082+i*77);stage=i/11
    left=52+45*(1-stage);tip=337-4*math.sin(i*.65);axis=93
    for lane in (-1,1):
        pts=[];phase=i*.34+lane*.37
        for j in range(76):
            t=j/75
            x=left+(tip-left)*t
            wave=(1-t)*11*math.sin(t*math.pi*5.5+phase+.48*math.sin(t*math.pi*3.7+i*.39))
            y=axis+lane*(7+6*(1-t))*math.sin(t*math.pi*3.5+phase)+wave*.41
            pts.append((x,y))
        ribbon(sd,pts,12.6,(28,16,62,225))
        ribbon(bd,pts,7.7,(35,113,83,227) if lane<0 else (121,48,164,222))
        ribbon(hd,pts,1.7,(207,255,201,211) if lane<0 else (228,185,251,204))
        for j in range(5):
            t=(j+.5)/6;x=left+(tip-left)*t
            y=axis+lane*14*math.sin(t*math.pi*3.5+phase)
            a=-1 if j%2 else 1
            bd.polygon([(x-7,y),(x+9,y+lane*9*a),(x+4,y+lane*3*a)],fill=(30,40,80,154))
    bd.polygon([(tip-48,axis-8),(tip-12,axis-13),(tip+4,axis),(tip-19,axis+13),(tip-54,axis+7)],fill=(34,24,81,250))
    bd.polygon([(tip-30,axis-4),(tip+4,axis),(tip-31,axis+3)],fill=(220,252,204,251))
    hd.line([(tip-49,axis),(tip+1,axis)],fill=(233,255,217,220),width=2)
    for k in range(52):
        x=rng.uniform(38,tip+7);y=axis+rng.gauss(0,18);s=rng.uniform(.7,2.0)
        bd.polygon([(x,y-s*1.5),(x+s,y),(x,y+s*.5),(x-s,y)],fill=(107,239,174,100) if k%2 else (166,82,217,117))
    for im,r,a in [(shadow,11,.43),(shadow,2,.65),(body,5,.55),(body,0,1),(shine,3,.50),(shine,0,.84)]:
        out=glaze(out,im,r,a)
    return out
def bud(i):
    W=H=256;out=blank(W,H)
    sm=blank(W,H);sd=ImageDraw.Draw(sm,"RGBA")
    fine=blank(W,H);fd=ImageDraw.Draw(fine,"RGBA")
    rng=random.Random(8831+i*23);u=(i+.5)/8;cx,cy=132,122
    for branch in range(5):
        angle=[-2.68,-1.75,-.45,.8,2.1][branch]+.14*math.sin(i*.71+branch)
        radius=(72-50*u)*[1.2,.86,1.3,.65,1.04][branch]
        sx=cx+math.cos(angle)*radius;sy=cy+math.sin(angle)*radius*.83
        pts=[]
        for j in range(35):
            t=j/34
            x=sx+(cx-sx)*t+7*math.sin(t*math.pi)*math.sin(branch*.8+i*.55)
            y=sy+(cy-sy)*t+8*math.sin(t*math.pi)*math.cos(branch*2.3+i*.49)
            pts.append((x,y))
        ribbon(sd,pts,6.9,(45,24,90,168))
        ribbon(fd,pts,2.4,(120,226,163,169) if branch%2 else (161,89,229,193))
    for n in range(23):
        angle=rng.random()*math.tau;rr=rng.uniform(7,75)*(1-.5*u)
        x=cx+rr*math.cos(angle);y=cy+rr*math.sin(angle)*.65;s=rng.uniform(.5,2.7)
        fd.polygon([(x,y-s),(x+s,y),(x,y+s*.8),(x-s,y)],fill=(193,245,200,157))
    r=5+9*u
    fd.polygon([(cx-r*1.7,cy-2),(cx-2,cy-r),(cx+r*.9,cy-2),(cx+r*1.5,cy),(cx+r*.6,cy+r*.8),(cx-3,cy+r*.75)],fill=(36,20,82,249))
    fd.polygon([(cx-3,cy-r*.49),(cx+r*1.5,cy),(cx-3,cy+1)],fill=(209,247,200,232))
    for im,r,a in [(sm,8,.4),(sm,0,.62),(fine,4,.62),(fine,0,1)]:
        out=glaze(out,im,r,a)
    return out
def vein(i):
    W=H=320;out=blank(W,H)
    dark=blank(W,H);dd=ImageDraw.Draw(dark,"RGBA")
    ink=blank(W,H);pd=ImageDraw.Draw(ink,"RGBA")
    hot=blank(W,H);hd=ImageDraw.Draw(hot,"RGBA")
    rng=random.Random(11189+i*31);q=i/11
    energy=[.48,1.0,.96,.78,.61,.52,.53,.59,.63,.56,.45,.32][i]
    cx,cy=160,161
    for k in range(7):
        a=[-2.76,-1.84,-.86,.12,.79,1.84,2.81][k]+.18*math.sin(q*6.5+k*.5)
        extent=[59,38,66,35,58,42,52][k]*(.8+.2*math.sin(i*.65+k))
        start=(cx,cy);tip=(cx+math.cos(a)*extent,cy+math.sin(a)*extent*.65)
        mid=(cx+math.cos(a+.6)*extent*.65,cy+math.sin(a+.55)*extent*.48)
        pts=[]
        for j in range(33):
            t=j/32
            x=(1-t)**2*start[0]+2*(1-t)*t*mid[0]+t*t*tip[0]
            y=(1-t)**2*start[1]+2*(1-t)*t*mid[1]+t*t*tip[1]
            pts.append((x,y))
        ribbon(dd,pts,8,(26,17,67,int(166*energy)))
        ribbon(pd,pts,4.5,(65,120,105,int(194*energy)) if k%2 else (112,39,153,int(198*energy)))
        ribbon(hd,pts,1.5,(172,255,198,int(199*energy)) if k%2 else (204,159,253,int(179*energy)))
        for b in range(2):
            j=11+b*6;x,y=pts[j];ang=a+(.8 if b==0 else -.7)
            z=(x+math.cos(ang)*17,y+math.sin(ang)*12)
            pd.line([(x,y),z],fill=(84,166,122,int(129*energy)),width=2)
    for k in range(20):
        a=rng.random()*math.tau;r=rng.uniform(10,69)
        x=cx+r*math.cos(a);y=cy+r*math.sin(a)*.7;s=rng.uniform(.7,2.0)
        hd.polygon([(x,y-s),(x+s,y),(x,y+s),(x-s,y)],fill=(173,238,171,int(114*energy)))
    pd.polygon([(cx-11,cy-3),(cx+6,cy-9),(cx+15,cy),(cx+4,cy+9),(cx-11,cy+5)],fill=(35,22,79,int(225*energy)))
    hd.polygon([(cx-6,cy-3),(cx+14,cy),(cx-4,cy+1)],fill=(235,254,210,int(240*energy)))
    for im,r,a in [(dark,9,.44),(dark,0,.64),(ink,5,.57),(ink,0,.83),(hot,3,.56),(hot,0,.91)]:
        out=glaze(out,im,r,a)
    return out
def pack(frames,cell,name):
    W,H=cell;atlas=blank(4*W,math.ceil(len(frames)/4)*H)
    for i,frame in enumerate(frames):
        alpha=frame.getchannel("A")
        assert alpha.getbbox(),(name,i,"empty")
        assert all(alpha.crop(b).getextrema()[1]==0 for b in [(0,0,W,1),(0,H-1,W,H),(0,0,1,H),(W-1,0,W,H)]),(name,i,"alpha bleed")
        atlas.alpha_composite(frame,(i%4*W,i//4*H))
    OUT.mkdir(parents=True,exist_ok=True);path=OUT/name
    atlas.save(path,optimize=True,compress_level=9);print(name,atlas.size,path.stat().st_size)
if __name__=="__main__":
    pack([thorn(i) for i in range(12)],(384,192),"phe_mach_thorn_12.png")
    pack([bud(i) for i in range(8)],(256,256),"phe_mach_charge_08.png")
    pack([vein(i) for i in range(12)],(320,320),"phe_mach_vein_12.png")
