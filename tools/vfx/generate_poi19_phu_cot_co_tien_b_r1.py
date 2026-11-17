#!/usr/bin/env python3
"""POI19 Tiên B Phệ Cổ — original first-party source art, code-painted RGBA.
Independent morphing orchid petals, polished golden jade seed, local folding
contact and one small persistent orchid mark. No insect, horror, rig or GIF.
Code-produced sprite source, not image-generation / commercial game art.
"""
from pathlib import Path
from math import pi,sin,cos,ceil
import numpy as np
from PIL import Image,ImageDraw,ImageFilter
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison19_phu_cot_co_tien_b/r1/assets"
SS=2
PARTS=(("gather",8,(256,256)),("seed",16,(320,256)),("fold",12,(320,320)),("mark",12,(256,256)))
C={"ink":(25,82,88),"jade":(45,225,176),"light":(103,255,204),
   "milk":(220,255,232),"gold":(255,217,110),"warm":(255,244,196)}
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
    dx,dy=cos(ang),sin(ang);nx,ny=-dy,dx
    tip=(x+dx*l,y+dy*l);root=(x,y)
    b1=(x+dx*l*.20+nx*w*.79,y+dy*l*.20+ny*w*.79)
    b2=(x+dx*l*.70+nx*w*1.09-bend*nx*l*.10,y+dy*l*.70+ny*w*1.09-bend*ny*l*.10)
    b3=(x+dx*l*.28-nx*w*.74,y+dy*l*.28-ny*w*.74)
    b4=(x+dx*l*.71-nx*w*.81-bend*nx*l*.10,y+dy*l*.71-ny*w*.81-bend*ny*l*.10)
    vertices=bez(root,b1,b2,tip)+bez(tip,b4,b3,root)
    mask=Image.new("L",im.size,0);d=ImageDraw.Draw(mask)
    d.polygon([P(*v) for v in vertices],fill=216)
    add(im,mask.filter(ImageFilter.GaussianBlur(4*SS)),C["jade"],.18*opacity)
    add(im,mask,C["light" if light else "jade"],.68*opacity)
    # internal painted vein, asymmetric and non-HUD detail
    spine=bez(root,(x+dx*l*.32+nx*w*.10,y+dy*l*.32+ny*w*.10),
                 (x+dx*l*.70+nx*w*.09,y+dy*l*.70+ny*w*.09),tip)
    strokes=Image.new("L",im.size,0);v=ImageDraw.Draw(strokes)
    v.line([P(*k) for k in spine],fill=171,width=max(1,SS*2),joint="curve")
    for j in (8,15,22):
        sx,sy=spine[j];v.line([P(sx,sy),P(sx+nx*w*.44,sy+ny*w*.44)],fill=96,width=SS)
    add(im,strokes,C["gold"],.59*opacity)
def twinkle(im,x,y,r,opacity):
    orb(im,x,y,r*5,r*4,C["light"],.16*opacity)
    orb(im,x,y,r,r,C["warm"],.57*opacity)
def flower(im,cx,cy,t,phase):
    for k in range(5):
        th=2*pi*k/5-pi*.48
        twist=.05*sin(2*pi*t+k*1.9)
        if phase=="gather":
            r=35*(1-t);l=39-22*t+3*sin(k+t*4);th+=pi*.90*t+twist
            x=cx+r*cos(th);y=cy+r*sin(th);w=9.5+2*t
        elif phase=="fold":
            shut=max(0,min(1,(t-.31)/.67))
            r=12+15*sin(pi*t);l=49+25*sin(pi*t)-30*shut
            x=cx+r*cos(th);y=cy+r*sin(th);th+=pi*.63*shut+twist
            w=14+3*sin(pi*t)
        else:
            r=3;x=cx+r*cos(th);y=cy+r*sin(th)
            l=29+2*sin(2*pi*t+k*.7)+1.7*t;th+=twist+.035*t;w=9.6+1.6*sin(2*pi*t+k)+.4*t
        l*=1+.075*sin(k*2.1+1.3) # organic unequal petal silhouette
        petal(im,x,y,th,l,w,sin(k+t*4),(.67 if phase=="mark" else .83),
              light=(k%2==0))
def paint(name,t,size):
    w,h=size;im=Image.new("RGBA",(w*SS,h*SS),(0,0,0,0))
    cx,cy=w*.5,h*.5
    if name=="gather":
        orb(im,cx,cy,49,43,C["ink"],.13)
        flower(im,cx,cy,t,"gather")
        orb(im,cx,cy,20+5*t,20+5*t,C["jade"],.26)
        orb(im,cx,cy,11+4*t,11+4*t,C["gold"],.61)
        orb(im,cx,cy,5+2*t,6+2*t,C["milk"],.89)
        for k in range(5):
            ang=k*2.39+t*3.8;radius=47-24*t+6*sin(k)
            twinkle(im,cx+radius*cos(ang),cy+radius*sin(ang),1.5,.38*(1-t*.5))
    elif name=="seed":
        bob=4.3*sin(t*7*pi)
        orb(im,cx+8,cy+bob,58,38,C["jade"],.13)
        # four soft petals curl BEHIND polished central jade seed
        for k in range(4):
            side=(-1 if k%2 else 1)
            ang=pi+side*(.26+.09*sin(t*2*pi+k))
            yy=side*(4+5*(k//2))
            petal(im,cx-12,cy+bob+yy,ang,38+6*sin(2*pi*t+k*.41),
                  9+1.6*sin(2*pi*t+k),side*.3,.62,k%2==0)
        petal(im,cx-20,cy+bob,pi,49+3*sin(2*pi*t),7,.18,.38)
        orb(im,cx+18,cy+bob,34,26,C["jade"],.38)
        orb(im,cx+20,cy+bob,18,15,C["light"],.56)
        orb(im,cx+23,cy+bob,11,10,C["gold"],.73)
        orb(im,cx+27,cy+bob-2,6,7,C["milk"],.94)
        for k in range(7):
            x=cx-50-k*10+8*t;y=cy+bob+10*sin(k*1.23+6*t)
            twinkle(im,x,y,1.9-.12*k,max(.03,.33-.038*k))
    elif name=="fold":
        orb(im,cx,cy,72,57,C["ink"],.16)
        flower(im,cx,cy,t,"fold")
        shut=max(0,min(1,(t-.31)/.69))
        orb(im,cx,cy,22-10*shut,22-10*shut,C["jade"],.34)
        orb(im,cx,cy,12-4*shut,12-4*shut,C["gold"],.57)
        orb(im,cx,cy,7-2*shut,7-2*shut,C["milk"],.90*(1-.38*t))
        for k in range(5):
            phi=2*pi*k/5+2.4*t;r=63-31*shut
            twinkle(im,cx+r*cos(phi),cy+r*sin(phi),2.2,.30*(1-.55*t))
    else:
        # one small mark remains on moving target for exactly six-and-half LAB secs
        orb(im,cx,cy,45,43,C["ink"],.13)
        flower(im,cx,cy,t,"mark")
        orb(im,cx,cy,13.5,14,C["jade"],.39)
        orb(im,cx,cy,8.3,8.3,C["gold"],.69)
        orb(im,cx,cy,5,5,C["milk"],.90)
        for k in range(3):
            phi=2*pi*k/3+5*t;r=34+3*sin(2*pi*t+k)
            twinkle(im,cx+r*cos(phi),cy+r*sin(phi),1.8,.24+.08*sin(t*6+k))
    # explicit true RGBA edges, original source-preserved master, no matte
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
        print("POI19_ORIGINAL_RGBA",name,n,atlas.size)
    print("POI19_ORIGINAL_RGB_ALPHA_SOURCE_PASS poses=48 atlas=4 code-painted no-rig-no-gif")
if __name__=="__main__":main()
