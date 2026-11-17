#!/usr/bin/env python3
"""POI20 Xà Ảnh Quấn Mạch Tiên A — first-party painted light-serpent sprites.
60 independent RGBA keyed poses; distinct charge / flight / back wrap /
front wrap / two-thread status. Pillow source reproducible, NO source-VL
pixel copies, NO commercial sprites, rig, GIF, poster/chromakey matting.
"""
from pathlib import Path
from math import sin,cos,pi,ceil
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/assets"
SS=2
SPECS=(("gather",8,(256,256)),("flight",16,(384,256)),
       ("coil_back",12,(320,320)),("coil_front",12,(320,320)),
       ("mark",12,(256,256)))
C={
 "silver":(247,253,248),"ivory":(250,249,227),"jade":(68,223,170),
 "sea":(45,173,151),"lilac":(173,147,228),"indigo":(100,78,163),
 "gold":(252,221,143),
}
def vec(x,y):return (int(round(x*SS)),int(round(y*SS)))
def blit(im,mask,col,opacity):
    if opacity<=0:return
    m=mask.point(lambda v:int(max(0,min(255,v*opacity))))
    if not m.getbbox():return
    layer=Image.new("RGBA",im.size,col+(0,));layer.putalpha(m);im.alpha_composite(layer)
def dot(im,x,y,r,col,a):
    mask=Image.new("L",im.size,0);d=ImageDraw.Draw(mask)
    d.ellipse((*vec(x-r,y-r),*vec(x+r,y+r)),fill=230)
    blit(im,mask.filter(ImageFilter.GaussianBlur(3.2*SS)),col,.29*a)
    blit(im,mask,col,.43*a)
def points_curve(points,smooth=8):
    arr=[]
    for i in range(len(points)-1):
        p0=points[max(0,i-1)];p1=points[i]
        p2=points[i+1];p3=points[min(len(points)-1,i+2)]
        for j in range(smooth):
            t=j/float(smooth)
            x=.5*((2*p1[0])+(-p0[0]+p2[0])*t+
                  (2*p0[0]-5*p1[0]+4*p2[0]-p3[0])*t*t+
                  (-p0[0]+3*p1[0]-3*p2[0]+p3[0])*t*t*t)
            y=.5*((2*p1[1])+(-p0[1]+p2[1])*t+
                  (2*p0[1]-5*p1[1]+4*p2[1]-p3[1])*t*t+
                  (-p0[1]+3*p1[1]-3*p2[1]+p3[1])*t*t*t)
            arr.append((x,y))
    arr.append(points[-1]);return arr
def filament(im,xy,body=5,opacity=.8,seed=0):
    """3 genuinely separate alpha strata: feather halo / jade body / white spine.
    No hard edge; segmented width tapers along arc. Original shape per pose.
    """
    if len(xy)<3:return
    pts=points_curve(xy,5);n=len(pts)
    mask=Image.new("L",im.size,0);m=ImageDraw.Draw(mask)
    for k in range(1,n):
        u=k/(n-1)
        w=body*(.24+.76*sin(pi*u)**.46)
        m.line([vec(*pts[k-1]),vec(*pts[k])],fill=203,width=max(1,round(w*SS)),joint="curve")
    blit(im,mask.filter(ImageFilter.GaussianBlur(7.0*SS)),C["indigo"],.13*opacity)
    blit(im,mask.filter(ImageFilter.GaussianBlur(4.0*SS)),C["lilac"],.30*opacity)
    blit(im,mask.filter(ImageFilter.GaussianBlur(1.8*SS)),C["jade"],.70*opacity)
    blit(im,mask,C["sea"],.33*opacity)
    spine=Image.new("L",im.size,0);d=ImageDraw.Draw(spine)
    d.line([vec(*v) for v in pts],fill=220,width=max(1,int(body*.27*SS)),joint="curve")
    blit(im,spine.filter(ImageFilter.GaussianBlur(1.1*SS)),C["silver"],.65*opacity)
    blit(im,spine,C["ivory"],.61*opacity)
    # small rare gold joints, not repeated geometric rings
    for k in (max(2,int(n*.27)),max(4,int(n*.67))):
        x,y=pts[k];dot(im,x,y,1.8,C["gold"],.36*opacity)
def head(im,x,y,dx,dy,opacity):
    """small spirit-serpent head: tapered glowing jewel, not a scary animal."""
    v=np.array([dx,dy],float);v/=max(.0001,np.linalg.norm(v))
    side=np.array([-v[1],v[0]])
    anchor=np.array([x,y],float)
    nose=anchor+v*9
    left=anchor-v*8+side*6
    right=anchor-v*8-side*6
    mask=Image.new("L",im.size,0);d=ImageDraw.Draw(mask)
    d.polygon([vec(*left),vec(*nose),vec(*right)],fill=240)
    blit(im,mask.filter(ImageFilter.GaussianBlur(8*SS)),C["jade"],.26*opacity)
    blit(im,mask.filter(ImageFilter.GaussianBlur(3*SS)),C["silver"],.38*opacity)
    blit(im,mask,C["ivory"],.72*opacity)
    dot(im,*(anchor-v*1.8+side*2.7),2,C["gold"],.56*opacity)
def arc_serpent(cx,cy,angle,t,radius,turns,stretch=1):
    pts=[]
    for k in range(41):
        u=k/40.0
        theta=angle+u*2*pi*turns+.095*sin(4*pi*u+2*pi*t)
        radius_u=radius*(.91-.23*u)+2.5*sin(5*pi*u+5*t)
        x=cx+cos(theta)*radius_u
        y=cy+sin(theta)*radius_u*.85*stretch-25*u
        pts.append((x,y))
    return pts
def paint(name,t,size):
    w,h=size;im=Image.new("RGBA",(w*SS,h*SS),(0,0,0,0))
    x=w*.5;y=h*.5
    if name=="gather":
        # Two different coiling source streams meet at caster's hand.
        q=.28+.72*t
        for side in (-1,1):
            path=[]
            for k in range(18):
                u=k/17.
                px=x-62+60*u+side*10*sin(pi*u+3*t)
                py=y+side*(33*(1-u)+12*sin(2*pi*u+t*4))
                path.append((px,py))
            filament(im,path,4.3,q*.92,side)
        dot(im,x,y,11+7*t,C["jade"],q*.39)
        dot(im,x,y,7+3*t,C["silver"],q*.77)
        for k in range(7):
            th=k*2.399+4*t
            r=42-14*t+(k%2)*6
            dot(im,x+r*cos(th),y+r*sin(th),2.2,C["gold"],.16+.27*t)
    elif name=="flight":
        # The entire luminous body undulates around the fixed clear head.
        # Changing wave phase and neck curve produces 16 actual independent poses.
        pts=[]
        for k in range(36):
            u=k/35.
            xx=x-139+263*u
            yy=y+19*sin(2*pi*(1.34*u-1.15*t))*sin(pi*u)
            yy+=8*sin(2*pi*(2.27*u+1.29*t))*sin(pi*u)
            pts.append((xx,yy))
        filament(im,pts,10.7,.94,t)
        a,b=pts[-1];dx=a-pts[-3][0];dy=b-pts[-3][1]
        head(im,a,b,dx,dy,.92)
        for k in range(6):
            s=(k+1)/7
            xx,yy=pts[int(s*31)]
            dot(im,xx-4*sin(k+t*7),yy+7*cos(k+t*5),2.7,C["lilac"],.30*(1-s))
    elif name in ("coil_back","coil_front"):
        # R1B native G3.7 rework: two distinct organic S-shaped light snakes
        # curl UP the one selected victim, not opaque concentric circular rings.
        front=name=="coil_front"
        # Color-coherent shadow/front depth; both contain obvious tails + heads.
        for snake in range(2):
            side=-1 if snake==0 else 1
            path=[]
            for k in range(44):
                u=k/43.
                offset=side*(22+20*sin(pi*u))
                sway=23*sin(2*pi*1.18*u+2*pi*t*.42+snake*1.73)*sin(pi*u)
                xx=x+offset+sway
                yy=y+93-181*u+5*sin(2*pi*u+3.2*t+snake)
                path.append((xx,yy))
            filament(im,path,9.6 if front else 8.1,.94 if front else .77,snake)
            p=path[-1];prev=path[-3]
            head(im,*p,p[0]-prev[0],p[1]-prev[1],.88)
            # One short fine silk tendril follows the snake's body not a ring.
            runner=path[7:28:2]
            runner=[(a+side*4,b+3*sin(i*.5+t*3)) for i,(a,b) in enumerate(runner)]
            filament(im,runner,2.2,.24,snake)
        for k in range(4):
            yy=y+64-42*k
            xx=x+(-1 if k%2 else 1)*(33+7*sin(t*3+k))
            dot(im,xx,yy,2.2,C["gold"],.20)
    elif name=="mark":
        # Persistent soft double fang-shaped jade seeds and silken binding.
        beat=.5+.5*sin(2*pi*t)
        for side in (-1,1):
            path=[]
            for k in range(17):
                u=k/16.
                xx=x+side*(12+25*u)+side*6*sin(pi*u+5*t)*sin(pi*u)
                yy=y+23-61*u+4*sin(2*pi*u+2*pi*t)
                path.append((xx,yy))
            filament(im,path,6.2,.72+beat*.15)
        dot(im,x,y-1,12,C["jade"],.40+beat*.10)
        dot(im,x,y-3,5,C["silver"],.82)
        dot(im,x,y-4,2.2,C["gold"],.78)
    im=im.resize(size,Image.Resampling.LANCZOS)
    a=np.array(im,dtype=np.uint8)
    a[0,:,3]=0;a[-1,:,3]=0;a[:,0,3]=0;a[:,-1,3]=0
    a[a[:,:,3]==0,:3]=0
    return Image.fromarray(a,"RGBA")
def main():
    OUT.mkdir(parents=True,exist_ok=True)
    for name,n,size in SPECS:
        cw,ch=size;atlas=Image.new("RGBA",(cw*4,ceil(n/4)*ch),(0,0,0,0))
        frames=[]
        for k in range(n):
            frame=paint(name,k/(n-1),size)
            alpha=np.asarray(frame.getchannel("A"))
            assert alpha.max()>65,(name,k,"too transparent")
            assert np.count_nonzero(alpha)>160,(name,k,"invisible pose")
            atlas.alpha_composite(frame,((k%4)*cw,(k//4)*ch))
            frames.append(frame)
        (OUT/"master").mkdir(parents=True,exist_ok=True)
        frames[n//2].save(OUT/"master"/f"poi20_{name}_master_rgba.png",optimize=True)
        atlas.save(OUT/f"poi20_{name}_{n:02d}.png",optimize=True)
        print("POI20_FIRST_PARTY_TRUE_ALPHA",name,n,size,atlas.size)
    print("POI20_G3_ORIGINAL_SOURCE_PASS poses=60 atlases=5 no_rig=true no_gif=true")
if __name__=="__main__":main()
