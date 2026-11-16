#!/usr/bin/env python3
"""PAF03 independent first-party true-RGBA cleanse sprite painter. No rig/GIF/gameplay."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
from paf03_r2_illustrated_paper import charge as r2_charge
import math,random,hashlib
R=Path(__file__).resolve().parents[2];B=R/'godot/labs/combat_lab/talisman13';OUT=B/'assets';SRC=B/'art_sources';S=2
def P(pts):return [(round(x*S),round(y*S)) for x,y in pts]
def bez(a,b,c,d,n=48):
    pts=[]
    for i in range(n+1):
        t=i/n;u=1-t
        pts.append((u**3*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t**3*d[0],
                    u**3*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t**3*d[1]))
    return pts
def L(d,pts,color,weight=1):d.line(P(pts),fill=color,width=max(1,round(weight*S)),joint='curve')
def new(w,h):return Image.new('RGBA',(w*S,h*S))
def lay(dst,source,blur=9,gain=.22):
    b=source.filter(ImageFilter.GaussianBlur(blur*S))
    b.putalpha(b.getchannel('A').point(lambda a:round(a*gain)))
    dst.alpha_composite(b);dst.alpha_composite(source)
def final(im,w,h):return im.resize((w,h),Image.Resampling.LANCZOS)
def silk(d,cx,cy,offset,scale,color):
    q=scale; x=offset
    pts=[(cx-25*q,cy-78*q),(cx+24*q,cy-84*q),
         (cx+36*q+x*.4,cy-19*q),(cx+19*q+x,cy+64*q),
         (cx-9*q+x,cy+91*q),(cx-36*q,cy+55*q)]
    d.polygon(P(pts),fill=color)
    L(d,pts+[pts[0]],(247,215,132,190),2.5)
    L(d,bez(pts[0],(cx-29*q,cy-8*q),(cx-4*q,cy+44*q),pts[4]),(245,229,170,173),1.4)
    L(d,bez(pts[1],(cx+15*q,cy-22*q),(cx+18*q,cy+39*q),pts[3]),(79,238,210,205),1.9)
    for j in range(5):
        y=cy-40*q+j*18*q
        L(d,bez((cx-13*q,y),(cx-21*q,y-9*q),
                (cx+16*q,y-19*q),(cx+17*q,y-5*q)),(241,218,140,142),1.0)
def charge(i,n=12,size=320):
    out=new(320,320);q=i/(n-1);r=random.Random(50912+i)
    wind=new(320,320);d=ImageDraw.Draw(wind,'RGBA')
    for j in range(4):
        pts=bez((109+j*13,179+j*4),(75+j*25,101+15*j+13*math.sin(q*6+j)),
                (223-j*21,268-32*j),(83+j*40+15*math.sin(q*6+j),271+j*5))
        L(d,pts,(65,230,202,88+19*j),7.5 if j==0 else 3.3)
        L(d,pts,(235,255,212,80),1.1)
    lay(out,wind,13,.17)
    paper=new(320,320);d=ImageDraw.Draw(paper,'RGBA')
    sway=20*math.sin(q*5.3);space=15+30*q
    silk(d,161-space,150+9*math.sin(q*4),-sway,.83,(18,112,102,193))
    silk(d,157+space,146-8*math.sin(q*3.8),sway,.87,(25,155,125,164))
    for j in range(3):
        xx=132+j*17
        L(d,bez((xx,101),(xx-26,154),(xx+20,207),(xx+8,247)),(61,235,204,80),1.5)
    lay(out,paper,8,.17)
    core=new(320,320);d=ImageDraw.Draw(core,'RGBA')
    for j in range(2):
        xx=151+23*math.sin(q*5+j)
        L(d,bez((xx-27,124),(xx-8,86),(xx+19,114),(xx+42,73)),
          (246,251,205,190),2)
    d.ellipse(P([(151,143),(168,161)]),fill=(246,255,214,202))
    lay(out,core,11,.20)
    d=ImageDraw.Draw(out,'RGBA')
    for j in range(28):
        x=r.uniform(80,251);y=r.uniform(80,274);rad=r.uniform(.5,1.6)
        d.ellipse(P([(x-rad,y-rad),(x+rad,y+rad)]),fill=(238,245,177,r.randint(40,132)))
    return final(out,size,size)
def transfer(i):
    q=i/15;out=new(512,256);body=new(512,256);d=ImageDraw.Draw(body,'RGBA')
    for k in range(6):
        pts=[]
        for j in range(95):
            u=j/94
            y=128+(22+k*9)*math.sin(u*5.3+q*4.9+k*.58)*(1-.40*u)
            y+=12*math.sin(u*10.2+q*3.5+k)
            pts.append((8+495*u,y))
        L(d,pts,(60,241,210,175 if k==0 else 96),15 if k==0 else 5 if k<3 else 2.5)
        if k<3:L(d,pts,(247,255,213,128),2.0)
    lay(out,body,12,.24)
    streak=new(512,256);d=ImageDraw.Draw(streak,'RGBA')
    for k in range(15):
        x=28+k*32+7*math.sin(q*7+k);y=129+19*math.sin(k*.84+q*5)
        L(d,[(x-4,y+4),(x,y-3),(x+10,y-7)],(253,228,145,158),1.2)
    lay(out,streak,3,.14)
    return final(out,512,256)
def curse(i):
    out=new(128,128);d=ImageDraw.Draw(out,'RGBA')
    for k in range(3):
        pts=[(20+85*(j/44)+8*math.sin(j*.18+k*1.8+i*.3),
              68+18*math.sin(j*.16+k*2.1+i*.17)) for j in range(45)]
        L(d,pts,(69,44,99,175-k*30),4.5-k)
    return final(out,128,128)
def cleanse(i,n=14,size=320):
    q=i/(n-1);out=new(320,320)
    petals=new(320,320);d=ImageDraw.Draw(petals,'RGBA')
    growth=37+92*math.sin(q*math.pi*.77)
    for k in range(7):
        theta=-math.pi/2+(k-3)*.45+q*.12*math.sin(k)
        r=growth*(.75+.22*math.sin(k*1.4))
        tip=(160+r*math.cos(theta),160+r*math.sin(theta))
        a=(160+4*math.cos(theta),162+4*math.sin(theta))
        mid=(160+r*.55*math.cos(theta),160+r*.55*math.sin(theta))
        p=bez(a,(mid[0]+24,mid[1]-27),tip,tip,21)
        p+=bez(tip,tip,(mid[0]-24,mid[1]+22),a,21)
        d.polygon(P(p),fill=(58+7*k,235,191,174))
        L(d,p,(253,235,157,164),1.5)
        L(d,bez(a,(mid[0],mid[1]+4),(tip[0]-7,tip[1]+2),tip),(225,255,211,117),1.6)
    lay(out,petals,14,.32)
    shadow=new(320,320);d=ImageDraw.Draw(shadow,'RGBA')
    for k in range(6):
        height=28+95*q
        pts=bez((158+12*math.sin(k),163),(162+49*math.sin(k*2.1),134-41*q),
                (160+75*math.sin(k*1.3),129-height),
                (160+124*math.sin(k*1.55),146-height-16*k))
        L(d,pts,(68,38,100,round((1-q)**1.5*182)),4.5)
    out.alpha_composite(shadow)
    core=new(320,320);d=ImageDraw.Draw(core,'RGBA')
    for k in range(8):
        a=-2.6+k*.72+q*.16;rr=33+62*math.sin(q*math.pi)
        end=(160+rr*math.cos(a),160+rr*math.sin(a))
        L(d,bez((160,160),(148+rr*.4,122),(end[0]+11,end[1]-7),end),
          (237,255,220,189 if k%3==0 else 99),2.2 if k%3==0 else 1.3)
    d.ellipse(P([(146,145),(175,175)]),fill=(240,255,225,190))
    lay(out,core,14,.31)
    return final(out,size,size)
def residue(i):
    q=i/7;out=new(256,256);d=ImageDraw.Draw(out,'RGBA')
    for k in range(24):
        a=k*2.39996+q
        rad=33+86*((k+.5)/25)+22*q
        x=128+rad*math.cos(a)*.88;y=137+rad*math.sin(a)*.61-29*q
        l=6+10*((k+.5)/25)
        poly=[(x-3,y+2),(x+l*.2,y-l*.7),(x+l,y-5),(x+2,y+5)]
        d.polygon(P(poly),fill=(99,245,195,round(140*(1-q*.76))))
        L(d,[(x,y+4),(x+l*.6,y-6)],(253,235,165,round(173*(1-q*.75))),1.2)
    return final(out,256,256)
def atlas(items,w,h):
    canvas=Image.new('RGBA',(w*4,h*((len(items)+3)//4)))
    for i,f in enumerate(items):canvas.alpha_composite(f,((i%4)*w,(i//4)*h))
    return canvas
def main():
    OUT.mkdir(parents=True,exist_ok=True);SRC.mkdir(parents=True,exist_ok=True)
    r2_charge(7,size=640).save(SRC/'paf03_cleansing_silk_master.png')
    cleanse(7,size=640).save(SRC/'paf03_cleansing_lotus_master.png')
    a={
    'paf03_charge.webp':(atlas([r2_charge(i) for i in range(12)],320,320),12),
    'paf03_transfer.webp':(atlas([transfer(i) for i in range(16)],512,256),16),
    'paf03_curse.webp':(atlas([curse(i) for i in range(8)],128,128),8),
    'paf03_cleanse.webp':(atlas([cleanse(i) for i in range(14)],320,320),14),
    'paf03_residue.webp':(atlas([residue(i) for i in range(8)],256,256),8)
    }
    for name,(art,frames) in a.items():
        p=OUT/name;art.save(p,'WEBP',quality=88,method=3,exact=True)
        print('PAF03_ATLAS',name,frames,art.size,hashlib.sha256(p.read_bytes()).hexdigest())
    print('PAF03_ORIGINAL_RGBA_BAKE_PASS')
    print('PAF03_R2_ILLUSTRATED_PAPER_BAKE_PASS')
if __name__=='__main__':main()
