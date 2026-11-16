#!/usr/bin/env python3
"""POI12 first-party CODE-PAINTED RASTER FX source: botanical toxic elixir.
Authored raster geometry and brushwork, NOT ImageGen painting or external pixels.
Sprite-first, 3 masters + 8 charge/12 liquid flight/10 contact nonrigged poses.
Every non-UI output has clean transparent borders; no atlas as painterly proof.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random, hashlib
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "godot/labs/combat_lab/poison12/assets"
MASTER = OUT / "master"
S = 2

def pt(x,y): return (int(x*S),int(y*S))
def fade_ellipse(layer, box, rgb, blur=8, opacity=170):
    work=Image.new("RGBA",layer.size)
    a=ImageDraw.Draw(work,"RGBA")
    a.ellipse(tuple(int(v*S) for v in box), fill=tuple(rgb)+(opacity,))
    halo=work.filter(ImageFilter.GaussianBlur(blur*S))
    layer.alpha_composite(halo)

def curved(canvas, points, color, width=2, glow=0):
    seq=[]
    for a,b in zip(points[:-1],points[1:]):
        for j in range(12):
            t=j/12
            seq.append(pt(a[0]*(1-t)+b[0]*t,a[1]*(1-t)+b[1]*t))
    seq.append(pt(*points[-1]))
    if glow:
        g=Image.new("RGBA",canvas.size)
        ImageDraw.Draw(g,"RGBA").line(seq,fill=color[:3]+(min(90,color[3]),),width=max(2,int(glow*S)),joint="curve")
        canvas.alpha_composite(g.filter(ImageFilter.GaussianBlur(4*S)))
    ImageDraw.Draw(canvas,"RGBA").line(seq,fill=color,width=max(1,int(width*S)),joint="curve")

def leaf(canvas, cx,cy,length,angle,thickness,white=False):
    ux=math.cos(angle); uy=math.sin(angle); vx=-uy;vy=ux
    tip=(cx+ux*length,cy+uy*length)
    base=(cx-ux*length*.22,cy-uy*length*.22)
    a=(cx+vx*thickness,cy+vy*thickness)
    b=(cx-vx*thickness*.55,cy-vy*thickness*.55)
    col=(196,255,202,220) if white else (32,207,125,185)
    ImageDraw.Draw(canvas,"RGBA").polygon([pt(*base),pt(*a),pt(*tip),pt(*b)],fill=col)
    curved(canvas,[base,(cx+ux*length*.34,cy+uy*length*.34),tip],(237,255,201,220) if white else (122,255,155,200),1.6)
    for side in (-1,1):
        for k in (0.30,0.52,0.72):
            x=cx+ux*length*k; y=cy+uy*length*k
            curved(canvas,[(x,y),(x+vx*thickness*side*.5,y+vy*thickness*side*.5),
                           (x+vx*thickness*side*.77+ux*length*.10,y+vy*thickness*side*.77+uy*length*.10)],
                    (202,255,177,145),.8)

def scene(kind,phase,size=(640,640)):
    rng=random.Random(4812+int(phase*130)+{"charge":1,"flight":2,"contact":3}[kind])
    work=Image.new("RGBA",(size[0]*S,size[1]*S),(0,0,0,0))
    x0,y0=size[0]*.5,size[1]*.5
    if kind=="charge":
        # Two living botanical rivulets fold into one hot medicinal core.
        q=phase
        for j in range(3):
            angle=2.15*j+q*2.4
            cx=x0+math.cos(angle)*(80-56*q)
            cy=y0+math.sin(angle)*(65-45*q)
            fade_ellipse(work,(cx-44,cy-54,cx+44,cy+54),(55,236,139),6,160)
            leaf(work,cx,cy,62-22*q,angle+1.3,13+6*q,j==1)
        for j in range(7):
            a=j*math.tau/7+q*.7
            end=(x0+math.cos(a)*(36+12*(1-q)),y0+math.sin(a)*(38+12*(1-q)))
            curved(work,[(x0+math.cos(a+1.2)*118,y0+math.sin(a+1.2)*95),
                (x0+math.cos(a+.5)*76,y0+math.sin(a+.5)*65),end],
                (77,255,148,165),2.7,8)
        fade_ellipse(work,(x0-35-16*q,y0-36-16*q,x0+35+16*q,y0+36+16*q),(245,255,209),13,205)
        leaf(work,x0,y0,48+30*q,-.75+q*.35,15,True)
    elif kind=="flight":
        # One intelligent-looking elixir droplet and changing split botanical tails.
        q=phase
        tail=170+40*math.sin(math.pi*q)
        for j in range(5):
            dy=(j-2)*25
            bend=math.sin(j*1.9+q*math.tau*1.4)*28
            curved(work,[(x0-tail,y0+dy+bend),(x0-102,y0+dy*.55),
                         (x0-44,y0+dy*.15),(x0+34,y0)],(52,227+min(j*4,28),135,100+20*j),2+j*.35,7)
        for j in range(3):
            a=-1.2+j*1.35+q*.28
            leaf(work,x0-60-j*32,y0+(j-1)*21,50+12*math.sin(q*5+j),
                 a+math.pi*.7,10,False)
        # Irregular translucent amber-glass liquid body, pointed toward the monster.
        body=[(x0-90,y0-18),(x0-65,y0-62),(x0+26,y0-57),(x0+87,y0-23),
              (x0+139,y0+1),(x0+67,y0+42),(x0-10,y0+63),(x0-68,y0+29)]
        ImageDraw.Draw(work,"RGBA").polygon([pt(*p) for p in body],fill=(25,170,106,177))
        curved(work,[(x0-70,y0-23),(x0-13,y0-43),(x0+90,y0-8),(x0+132,y0+1)],
               (231,255,179,238),3.9,10)
        for j in range(4):
            x=x0-47+j*35
            leaf(work,x,y0+math.sin(j+q*3)*12,18+j*5,-.25+q*.23,7,j==2)
        fade_ellipse(work,(x0+73,y0-17,x0+142,y0+17),(243,255,207),6,242)
    else:
        # Compact organic puncture, NOT an endlessly sustained poison aura.
        q=phase
        radius=(35+103*math.sin(math.pi*min(1,q*.84+.10))) * (1-.52*max(0,q-.58)/.42)
        fade_ellipse(work,(x0-radius*.55,y0-radius*.55,x0+radius*.55,y0+radius*.55),
                    (68,245,155),14,135)
        for j in range(9):
            a=j*math.tau/9+.2*math.sin(j*.87+q*3)
            length=radius*(.72+.32*math.sin(j*1.8+q*3))
            offset=(x0+math.cos(a)*length*.24,y0+math.sin(a)*length*.24)
            tip=(x0+math.cos(a)*length,y0+math.sin(a)*length)
            leaf(work,offset[0],offset[1],length*.63,a,11+3*math.sin(j),j%5==0)
            curved(work,[(x0,y0),(x0+math.cos(a+.1)*length*.49,y0+math.sin(a+.1)*length*.49),tip],
                   (224,255,190,max(35,int(245*(1-q*.85)))),2.8,10)
        fade_ellipse(work,(x0-22,y0-25,x0+22,y0+25),(255,255,229),5,int(235*(1-q*.5)))
    # Transparent original art with color falloff; canvas edges are always alpha=0.
    rgb=np.asarray(work).copy()
    hh,ww=rgb.shape[:2]
    yy,xx=np.mgrid[:hh,:ww]
    ox=(xx-ww*.50)/(ww*.48); oy=(yy-hh*.5)/(hh*.47)
    rr=np.sqrt(ox*ox+oy*oy)
    feather=np.clip((1-rr)/.20,0,1)
    rgb[:,:,3]=(rgb[:,:,3].astype(np.float32)*feather).astype(np.uint8)
    img=Image.fromarray(rgb,"RGBA")
    return img.resize(size,Image.Resampling.LANCZOS)

def frame(kind,i,n,cell):
    t=i/max(1,n-1)
    master=scene(kind,t)
    # Distinct authored silhouette progression is created above, not frame-only tint.
    a=master.getchannel("A")
    bbox=a.getbbox()
    if not bbox:raise RuntimeError("empty "+kind+str(i))
    im=master.resize(cell,Image.Resampling.LANCZOS)
    return im

def atlas(filename,kind,count,cell):
    w,h=cell; cols=4; rows=(count+cols-1)//cols
    sheet=Image.new("RGBA",(w*cols,h*rows))
    hashes=set()
    for i in range(count):
        p=frame(kind,i,count,cell)
        assert p.getchannel("A").getbbox()
        assert p.getpixel((0,0))[3]==0 and p.getpixel((w-1,h-1))[3]==0
        hashes.add(hashlib.sha256(p.tobytes()).digest())
        sheet.alpha_composite(p,((i%cols)*w,(i//cols)*h))
    assert len(hashes)==count,(filename,"duplicate")
    path=OUT/filename;sheet.save(path,optimize=True)
    print("POI12_ATLAS",path.name, sheet.size,"poses",count,"bytes",path.stat().st_size)
    return sheet

def main():
    MASTER.mkdir(parents=True,exist_ok=True)
    for kind in ("charge","flight","contact"):
        im=scene(kind,.52)
        path=MASTER/("poi12_"+kind+"_master_640.png")
        im.save(path,optimize=True)
        print("POI12_FIRST_PARTY_CODE_ART_MASTER",path.name,im.size)
    sheets=[atlas("poi12_charge_08.png","charge",8,(192,192)),
        atlas("poi12_flight_12.png","flight",12,(288,160)),
        atlas("poi12_contact_10.png","contact",10,(256,256))]
    raw=sum(im.width*im.height*4 for im in sheets)
    print("POI12_RGBA8_RAW_BYTES",raw)
    assert raw<9*1024*1024
if __name__=="__main__":main()
