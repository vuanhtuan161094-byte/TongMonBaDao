#!/usr/bin/env python3
"""POI19 Tiên B Phệ Cổ — R2 first-party VIOLET/Jade painted layered native VFX.
Independent morphing orchid petals, polished golden jade seed, local folding
contact and one small persistent orchid mark. No insect, horror, rig or GIF.
Code-produced sprite source, not image-generation / commercial game art.
"""
from pathlib import Path
from math import pi,sin,cos,ceil
import numpy as np
from PIL import Image,ImageDraw,ImageFilter
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r2/assets"
SS=2
PARTS=(("gather",12,(320,320)),("seed",16,(384,256)),("fold",16,(384,384)),("mark",12,(320,320)),("ground",12,(384,256)),("veil",12,(384,320)))
C={"ink":(34,19,79),"jade":(61,235,183),"light":(152,255,221),
   "milk":(250,237,255),"gold":(255,206,113),"warm":(255,244,207),
   "violet":(157,69,248),"lilac":(213,147,255),"deep":(83,39,139)}
def P(x,y):return (int(round(x*SS)),int(round(y*SS)))
def bez(a,b,c,d,n=32):
    return [((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0],
             (1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1]) for t in np.linspace(0,1,n)]
def add(im,mask,col,a):
    if a<=0:return
    m=mask.point(lambda v:int(max(0,min(255,v*a))))
    if not m.getbbox():return
    layer=Image.new("RGBA",im.size,col+(0,));layer.putalpha(m);im.alpha_composite(layer)
def orb(im,x,y,rx,ry,col,alpha):
    yy,xx=np.ogrid[:im.height,:im.width]
    a=np.exp(-2.8*(((xx-x*SS)/(rx*SS))**2+((yy-y*SS)/(ry*SS))**2))
    mask=Image.fromarray(np.array(np.clip(a*alpha*255,0,255),np.uint8),"L")
    add(im,mask,col,1)
def petal(im,x,y,ang,l,w,bend,opacity,light=True):
    """Painted uneven silk orchid, with several independently drawn vein folds."""
    dx,dy=cos(ang),sin(ang);nx,ny=-dy,dx
    tip=(x+dx*l,y+dy*l)
    root=(x,y)
    b1=(x+dx*l*.14+nx*w*.84,y+dy*l*.14+ny*w*.84)
    b2=(x+dx*l*.60+nx*w*(1.19+bend*.16),
        y+dy*l*.60+ny*w*(1.19+bend*.16))
    b3=(x+dx*l*.23-nx*w*.63,y+dy*l*.23-ny*w*.63)
    b4=(x+dx*l*.76-nx*w*(.86+bend*.17),
        y+dy*l*.76-ny*w*(.86+bend*.17))
    vertices=bez(root,b1,b2,tip)+bez(tip,b4,b3,root)
    mask=Image.new("L",im.size,0);d=ImageDraw.Draw(mask)
    d.polygon([P(*v) for v in vertices],fill=205)
    add(im,mask.filter(ImageFilter.GaussianBlur(6*SS)),C["violet"],.23*opacity)
    add(im,mask,C["lilac" if light else "violet"],.65*opacity)
    inner=Image.new("L",im.size,0);v=ImageDraw.Draw(inner)
    spine=bez(root,(x+dx*l*.30+nx*w*.07,y+dy*l*.30+ny*w*.07),
                 (x+dx*l*.71+nx*w*.04,y+dy*l*.71+ny*w*.04),tip)
    v.line([P(*k) for k in spine],fill=205,width=SS*2,joint="curve")
    for j in (7,12,17,22):
        sx,sy=spine[j]
        for direction in (-1,1):
            q=(sx+nx*w*.50*direction+dx*l*.07,sy+ny*w*.50*direction+dy*l*.07)
            v.line([P(sx,sy),P(*q)],fill=117,width=SS)
    add(im,inner,C["gold"],.63*opacity)
    # one soft white inner fold rather than electric arcs
    bright=Image.new("L",im.size,0)
    z=ImageDraw.Draw(bright)
    z.line([P(*pt) for pt in spine[4:22]],fill=180,width=SS)
    add(im,bright.filter(ImageFilter.GaussianBlur(SS*.75)),C["milk"],.44*opacity)

def veilbrush(im,x,y,turn,spread,power):
    """Transparent painterly ribbons with diffuse halo, jade edge and lilac core."""
    start=(x-89,y+17*sin(turn))
    end=(x+spread,y-38*sin(turn+.4))
    pts=bez(start,(x-38,y-73+24*sin(turn)),(x+26,y+62*cos(turn)),end,48)
    layer=Image.new("L",im.size,0);d=ImageDraw.Draw(layer)
    d.line([P(*p) for p in pts],fill=195,width=SS*18,joint="curve")
    add(im,layer.filter(ImageFilter.GaussianBlur(13*SS)),C["deep"],.11*power)
    add(im,layer.filter(ImageFilter.GaussianBlur(5*SS)),C["violet"],.25*power)
    add(im,layer,C["violet"],.16*power)
    slim=Image.new("L",im.size,0);d=ImageDraw.Draw(slim)
    d.line([P(*p) for p in pts[8:44]],fill=154,width=SS*4,joint="curve")
    add(im,slim,C["jade"],.39*power)
    add(im,slim.filter(ImageFilter.GaussianBlur(2*SS)),C["gold"],.12*power)

def runic_ring(im,cx,cy,rx,ry,t,power):
    """Small single-target ceremonial foot sigil. NEVER an AoE indicator."""
    ring=Image.new("L",im.size,0);d=ImageDraw.Draw(ring)
    for ring_scale in (1,.84):
        pts=[]
        for j in range(111):
            th=2*pi*j/110
            x=cx+rx*ring_scale*cos(th)
            y=cy+ry*ring_scale*sin(th)
            pts.append(P(x,y))
        d.line(pts,fill=130 if ring_scale==1 else 74,width=SS*2,joint="curve")
    for k in range(10):
        a=2*pi*k/10+2*pi*.06*t
        px=cx+rx*.94*cos(a);py=cy+ry*.94*sin(a)
        d.line([P(px-2.5,py-4),P(px,py+4),P(px+3,py-2)],fill=150,width=SS)
    add(im,ring.filter(ImageFilter.GaussianBlur(6*SS)),C["deep"],.26*power)
    add(im,ring,C["violet"],.40*power)
    dots=Image.new("L",im.size,0);v=ImageDraw.Draw(dots)
    for k in range(12):
        phi=2*pi*k/12+2*pi*t*.06
        xx=cx+rx*cos(phi);yy=cy+ry*sin(phi)
        rr=1.1+(k%3)*.45
        v.ellipse((P(xx-rr,yy-rr),P(xx+rr,yy+rr)),fill=220)
    add(im,dots,C["gold"],.59*power)
    twinkle(im,cx+rx*.8,cy,2.7,.7*power)

def flower(im,cx,cy,t,phase):
    petals=5
    for k in range(petals):
        th=2*pi*k/petals-pi*.48
        flutter=.07*sin(2*pi*t+k*1.61)
        if phase=="gather":
            r=39*(1-t);l=39-16*t+3*sin(k+t*4);th+=pi*.49*t+flutter
            x=cx+r*cos(th);y=cy+r*sin(th);w=11.8+1.2*t
        elif phase=="fold":
            fold=max(0,min(1,(t-.22)/.78))
            r=15+31*sin(pi*t)
            l=57+26*sin(pi*t)-28*fold
            x=cx+r*cos(th);y=cy+r*sin(th);th+=pi*.48*fold+flutter
            w=14.5+3*sin(pi*t)
        else:
            x=cx+4*cos(th);y=cy+4*sin(th)
            l=31+3*sin(2*pi*t+k*.7)+1.1*t;th+=flutter
            w=9+1.7*sin(2*pi*t+k+.5)+.4*t
        l*=1+.069*sin(k*2.1+1.3)
        petal(im,x,y,th,l,w,sin(k+t*4),(.75 if phase=="mark" else .93),light=(k%2==0))
def paint(name,t,size):
    """Six separated, varying transparent SOURCE layers, not a rendered poster."""
    w,h=size
    im=Image.new("RGBA",(w*SS,h*SS),(0,0,0,0))
    cx,cy=w*.5,h*.5
    if name=="gather":
        # The ritual forms at caster's palm, five asymmetric orchid petals.
        q=.26+.74*t
        veilbrush(im,cx,cy-4,t*2.6,48,q*.39)
        flower(im,cx,cy,t,"gather")
        orb(im,cx,cy,36+8*t,35+8*t,C["violet"],.28*q)
        orb(im,cx,cy,17+6*t,16+6*t,C["jade"],.45*q)
        orb(im,cx+3,cy-2,10+3*t,10+3*t,C["gold"],.70*q)
        orb(im,cx+3,cy-3,5.5+2*t,6+2*t,C["milk"],.92*q)
        for k in range(8):
            a=2.39996*k+5*t
            r=65-26*t+4*sin(k)
            twinkle(im,cx+r*cos(a),cy+r*sin(a),1.5+.2*(k%3),(.26+.36*t))
    elif name=="seed":
        sway=3*sin(6*pi*t)
        veilbrush(im,cx-24,cy+sway,.35+1.9*t,65,.35)
        for k in range(5):
            ang=pi+.27*sin(2*pi*t+k*.9)+k*.085
            x=cx-29-(k%2)*8
            y=cy+sway+(k-2)*9
            petal(im,x,y,ang,50+8*sin(2*pi*t+k*.47),9+(k%3)*2,.5*sin(k+t*3),.72,(k%2==0))
        orb(im,cx+26,cy+sway,48,38,C["violet"],.29)
        orb(im,cx+29,cy+sway,27,23,C["jade"],.50)
        orb(im,cx+32,cy+sway,17,14,C["gold"],.80)
        orb(im,cx+34,cy+sway-2,8.5,9,C["milk"],.94)
        for k in range(9):
            x=cx-70-k*11+4*t
            y=cy+sway+12*sin(k*1.18+7*t)
            twinkle(im,x,y,2.0-(k%3)*.25,max(.05,.48-.036*k))
    elif name=="fold":
        q=max(.08,sin(pi*min(1,t+.07)))
        veilbrush(im,cx-17,cy+5,t*2.5,63,q*.7)
        veilbrush(im,cx+19,cy-9,3+t*3,42,q*.43)
        flower(im,cx,cy,t,"fold")
        close=max(0,min(1,(t-.30)/.70))
        orb(im,cx,cy,54-22*close,54-21*close,C["violet"],.24*q)
        orb(im,cx,cy,24-11*close,23-10*close,C["jade"],.43*q)
        orb(im,cx,cy,13-5*close,13-4*close,C["gold"],.65*q)
        orb(im,cx,cy,6.5-2*close,7-2*close,C["milk"],.88*q)
        for k in range(9):
            a=2*pi*k/9+1.4*t
            r=83-40*close+3*sin(k)
            twinkle(im,cx+r*cos(a),cy+r*sin(a),2.2,.25*q)
    elif name=="mark":
        # Small and highly legible single-target orchid, hovering above head.
        beat=.5+.5*sin(2*pi*t)
        orb(im,cx,cy,54,52,C["deep"],.13)
        flower(im,cx,cy,t,"mark")
        orb(im,cx,cy,18,17,C["violet"],.39)
        orb(im,cx,cy,12+1.2*beat,11+beat,C["jade"],.60)
        orb(im,cx,cy,7.7,8.0,C["gold"],.87)
        orb(im,cx,cy,4.5,5,C["milk"],.94)
        for k in range(4):
            a=2*pi*k/4+2*pi*t*.63
            r=43+5*sin(2*pi*t+k)
            twinkle(im,cx+r*cos(a),cy+r*sin(a),2,.30)
    elif name=="ground":
        # Small target foot locator, never the large multi-target arena ring.
        # All marks are on selected monster's floor only.
        q=.80+.15*sin(pi*t)
        runic_ring(im,cx,cy,110,28,t,q)
        orb(im,cx,cy,65,24,C["violet"],.09*q)
        for k in range(6):
            ang=2*pi*k/6+t*.33
            x=cx+86*cos(ang);y=cy+21*sin(ang)
            twinkle(im,x,y,2.3,.17*q)
    elif name=="veil":
        # Ambient silver-lilac ribbons on a local target ONLY, no AoE cloud.
        q=max(.09,sin(pi*min(.99,t+.015)))
        veilbrush(im,cx-19,cy-5,1+t*3,67,q*.68)
        veilbrush(im,cx+8,cy-8,3+t*2.4,49,q*.52)
        for k in range(5):
            ang=2*pi*k/5+2*t;r=62+19*sin(pi*t)
            twinkle(im,cx+r*cos(ang),cy+r*sin(ang),2.7,.23*q)
    # RGB=0 outside true alpha; source master remains separated 384px where needed.
    im=im.resize((w,h),Image.Resampling.LANCZOS)
    arr=np.array(im,dtype=np.uint8)
    arr[0,:,3]=0;arr[-1,:,3]=0;arr[:,0,3]=0;arr[:,-1,3]=0
    arr[arr[:,:,3]==0,:3]=0
    return Image.fromarray(arr,"RGBA")
def main():
    OUT.mkdir(parents=True,exist_ok=True)
    for name,n,cell in PARTS:
        w,h=cell;atlas=Image.new("RGBA",(4*w,ceil(n/4)*h),(0,0,0,0))
        for k in range(n):
            f=paint(name,k/(n-1),cell)
            assert f.getchannel("A").getbbox(),(name,k)
            atlas.alpha_composite(f,((k%4)*w,(k//4)*h))
            if k==n//2:
                (OUT/"master").mkdir(parents=True,exist_ok=True)
                f.save(OUT/"master"/f"poi19_{name}_master_rgba.png",optimize=True)
        atlas.save(OUT/f"poi19_{name}_{n:02d}.png",optimize=True)
        print("POI19_R2_LAYERED_RGBA",name,n,atlas.size)
    print("POI19_R2_SOURCE_PASS poses=80 atlases=6 original_alpha=true no_gif_no_rig=true")
if __name__=="__main__":main()
