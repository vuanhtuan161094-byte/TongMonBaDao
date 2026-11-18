#!/usr/bin/env python3
"""POI18 Phụ Cốt Cổ · Tiên A (Liên Tâm) — original first-party RGBA sources.

R3 targeted new living spirit-silk flight only: NO beetle/claws/creepy anatomy.
New gu flight only; R2C gather, burst and mark remain immutable.
LAB only; no gameplay damage/status receipts. No GIF, rig or skeletal motion.
"""
from pathlib import Path
from math import ceil,pi
import numpy as np
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison18_phu_cot_co_tien_a/r3/assets"
SS=2
PARTS=(("gu",16,(320,256)),)
RGB={
 "shadow":(16,79,76), "deep":(16,101,83), "jade":(32,205,166),
 "lime":(173,255,199), "mint":(108,255,219), "gold":(247,211,116),
 "ivory":(245,255,237), "emerald":(47,188,162)
}

def gauss(x,y,cx,cy,sx,sy):
    return np.exp(-(((x-cx)/sx)**2+((y-cy)/sy)**2))

def gate(v,a,b,soft):
    return np.clip((v-a)/soft,0,1)*np.clip((b-v)/soft,0,1)

def over(arr,rgb,alpha):
    a=np.clip(alpha,0,1).astype(np.float32)
    o=arr[:,:,3]
    z=a+o*(1-a)
    arr[:,:,:3]=(arr[:,:,:3]*o[:,:,None]*(1-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(z[:,:,None],1e-8)
    arr[:,:,3]=z

def oval(x,y,cx,cy,rx,ry,angle=0,edge=2.4):
    ca,sa=np.cos(angle),np.sin(angle)
    dx=x-cx; dy=y-cy
    xx=(dx*ca+dy*sa)/rx
    yy=(-dx*sa+dy*ca)/ry
    return np.exp(-((xx*xx+yy*yy)**edge)*1.55)

def filament(x,y,pts,width):
    field=np.zeros_like(x)
    for (x0,y0),(x1,y1) in zip(pts[:-1],pts[1:]):
        dx=x1-x0; dy=y1-y0
        t=np.clip(((x-x0)*dx+(y-y0)*dy)/(dx*dx+dy*dy+1e-6),0,1)
        field=np.maximum(field,np.exp(-(((x-x0-t*dx)**2+(y-y0-t*dy)**2)/(width*width))))
    return field

def heartfield(x,y,cx,cy,r):
    """A filled hand-drawn fantasy heart/living seed, not a neon HUD polygon."""
    u=(x-cx)/r
    v=-(y-cy)/(r*.98)
    f=(u*u+v*v-1)**3-u*u*v*v*v
    # Distinct filled-petal body and independently bright edge.
    return 1/(1+np.exp(np.clip(f*22,-30,30))),np.exp(-((f/.14)**2))

def render(name,t,cell):
    """Hand-crafted flowing spirit petals; NO insect anatomy or spooky faces.

    Four independently posed TRUE-RGBA artistic layers: gather seed, flying
    two-wing spirit silk, local luminous flower contact, and graceful double
    jade-leaf tether.  All shapes deform across keys, not static recolors.
    """
    w,h=cell
    yy,xx=np.mgrid[:h*SS,:w*SS].astype(np.float32)
    x=(xx+.5)/SS-w*.5
    y=(yy+.5)/SS-h*.5
    p=np.zeros((h*SS,w*SS,4),np.float32)
    pulse=.5+.5*np.sin(2*pi*t)
    noise=np.clip(.96+.06*np.sin(.038*x+.075*y+5.8*t)*np.cos(.049*x-.044*y-4.5*t),.83,1.06)
    def ink(c,a):over(p,RGB[c],a)
    def silk(xc,yc,rx,ry,angle):
        # organic pointed feather, the tip is asymmetrical and breathes
        ca,sa=np.cos(angle),np.sin(angle)
        dx=x-xc;dy=y-yc
        u=(dx*ca+dy*sa)/rx
        v=(-dx*sa+dy*ca)/ry
        bend=v-.16*np.sin((u+1.0)*2.6+t*2.4)
        return np.exp(-(np.abs(u)**2.9+np.abs(bend)**2.55)*1.38)
    if name=="gather":
        q=np.clip(.20+.90*t,0,1)
        # Three individual translucent petals are drawn towards a seed.
        for k,(side,level) in enumerate([(-1.0,-1.0),(1.0,1.0),(-1.0,1.0)]):
            cx=-62+50*t+11*k
            cy=side*(32-18*t)+level*9
            pet=silk(cx,cy,28-7*t,10-1*t,side*(.45-.20*t))
            ink("shadow",pet*.10*q)
            ink("jade",pet*.38*q*noise)
            ink("mint",pet*.20*q)
            ink("ivory",gauss(x,y,cx+5,cy-2,8,5)*.10*q)
            path=[(cx-34,cy+side*10),(cx-13,cy+side*5),(cx+14,cy*.38),(0,1)]
            ink("jade",filament(x,y,path,3.7)*.15*q)
            ink("gold",filament(x,y,path,1.3)*.21*q)
        ink("jade",gauss(x,y,-2,2,37+5*t,35+5*t)*.18*q)
        ink("mint",gauss(x,y,1,0,18+2*t,18+2*t)*.46*q)
        ink("gold",gauss(x,y,3,-2,10,11)*.65*q)
        ink("ivory",gauss(x,y,3,-3,5.5,7.4)*.88*q)
        # Seed has soft upward light, not a dark egg or scary head.
        ink("ivory",gauss(x,y,0,-30+12*t,3.1,11)*.26*q)
    elif name=="gu":
        # Rework only the R2C synthetic X/chevron; preserve other R2C phases.
        # Two ASYMMETRIC independent living silk trails, no bug anatomy.
        phase=2*pi*t
        u=np.linspace(0,1,41)
        upper=[(-121+201*float(v),23-47*np.sin(pi*v)+14*np.sin(2*pi*v+phase)*np.sin(pi*v)) for v in u]
        lower=[(-118+142*float(v),71-51*float(v)+13*np.sin(2*pi*v+phase+1.3)*np.sin(pi*v)) for v in u]
        for j,pts in enumerate((upper,lower)):
            fall=np.clip((x+135)/27,0,1)
            fall*=np.clip(((101 if j==0 else 30)-x)/38,0,1)
            broad=filament(x,y,pts,17 if j==0 else 11)*fall
            mid=filament(x,y,pts,8.2 if j==0 else 5.2)*fall
            core=filament(x,y,pts,1.8 if j==0 else 1.15)*fall
            ink("shadow",broad*.17)
            ink("jade",broad*(.46 if j==0 else .31)*noise)
            ink("mint",mid*(.53 if j==0 else .36))
            ink("ivory",core*(.68 if j==0 else .33))
            for q in (7,16,27,36):
                if j==1 and q==36: continue
                sx,sy=pts[q]
                drag=-(12+7*np.sin(phase+q*.7))
                curl=7*np.sin(phase*.7+q*.3+j)
                wisp=[(sx,sy),(sx+drag*.65,sy+curl*.5),(sx+drag*1.5,sy+curl+(1 if j else -1)*7)]
                ink("jade",filament(x,y,wisp,3)*.16)
                ink("mint",filament(x,y,wisp,1.05)*.24)
        hx=79+2*np.sin(phase)
        hy=23+3*np.sin(phase)
        ink("jade",gauss(x,y,hx,hy,19,15)*.28)
        ink("mint",gauss(x,y,hx,hy,11,9)*.56)
        ink("gold",gauss(x,y,hx+2,hy-1,7,6)*.66)
        ink("ivory",gauss(x,y,hx+3,hy-1,3.5,3.3)*.88)
        for q in range(13):
            m=float(q)/13
            px=-115+160*m+4*np.sin(phase+q*1.8)
            py=30-30*np.sin(pi*m)+23*np.sin(q*2.2+phase*.6)
            ink("mint",gauss(x,y,px,py,1.35,1.4)*(.21+.07*(q%3)))
    elif name=="burst":
        # Soft local nectar bloom and three unequal silk petals at TARGET ONLY.
        q=max(.11,np.sin(pi*min(1,t+.07)))
        extent=.32+.68*np.sin(pi*.5*t)
        ink("jade",gauss(x,y,0,0,59+34*t,52+34*t)*.13*(1-t))
        for k in range(3):
            theta=(k/3.0)*2*pi+.35+1.3*t
            cx=34*np.cos(theta)*extent
            cy=31*np.sin(theta)*extent
            pet=silk(cx,cy,39+11*t,17+6*t,theta)
            ink("jade",pet*.40*q*noise)
            ink("mint",pet*.24*q)
            leafvein=[(0,0),(cx*.61,cy*.61),(cx*1.6,cy*1.6)]
            ink("gold",filament(x,y,leafvein,2.3)*.45*q)
            ink("ivory",filament(x,y,leafvein,.8)*.43*q)
        ink("mint",gauss(x,y,0,0,34+8*t,30+8*t)*.30*(1-t))
        ink("gold",gauss(x,y,0,0,17+13*t,16+13*t)*.55*(1-t))
        ink("ivory",gauss(x,y,0,0,9+9*t,10+9*t)*.83*(1-t))
        # Organic light dust is limited and never simulates extra damage.
        for k in range(8):
            phi=2.39996*k+2*t
            rad=38+42*t+(k%3)*9
            px=np.cos(phi)*rad;py=np.sin(phi)*rad
            ink("ivory",gauss(x,y,px,py,1.9+2*t,3.0+2*t)*.27*q)
    elif name=="seal":
        # Liên Tâm = paired jade leaves tethered by a fine golden silken core.
        # Intentionally avoids human hearts, bloody marks, angular UI sigils.
        q=.5+.5*np.sin(2*pi*t)
        shift=3.5*np.sin(2*pi*t)
        ink("jade",gauss(x,y,0,0,46,40)*.12)
        for k,side in enumerate((-1.0,1.0)):
            x0=side*(21+1.6*t)
            y0=-3+side*6+shift*.23
            angle=side*(-.75+.10*np.sin(2*pi*t))
            leaf=silk(x0,y0,27+2*t,12,angle)
            ink("shadow",leaf*.10)
            ink("jade",leaf*.57)
            ink("mint",leaf*.33*noise)
            ink("ivory",silk(x0-3,y0-4,16,5,angle)*.22)
            path=[(x0-side*23,y0+side*14),(x0-4,y0+3),
                  (x0+side*20,y0-side*10)]
            ink("gold",filament(x,y,path,1.6)*.46)
            ink("ivory",filament(x,y,path,.8)*.36)
        # Warm interwoven bond, not HUD geometry.
        path=[(-36,14),(-16,9),(0,-2),(18,8),(37,12)]
        ink("jade",filament(x,y,path,4.2)*.22)
        ink("gold",filament(x,y,path,2.0)*.55)
        ink("ivory",filament(x,y,path,.75)*.54)
        ink("gold",gauss(x,y,0,0,9+q*2,9+q*2)*.43)
        ink("ivory",gauss(x,y,0,-2,4.3+q,4.3+q)*.77)
    # Full-resolution independent RGBA master, no poster cropping or
    # threshold chroma key. Opaque RGB is cleared where alpha is zero.
    orig=p[:,:,3]
    p[:,:,3]=np.clip(np.where(orig>.04,1-(1-orig)**1.32,orig*1.07),0,.92)
    rgba=np.zeros_like(p,dtype=np.uint8)
    rgba[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    rgba[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    rgba[:10,:,3]=0; rgba[-10:,:,3]=0
    rgba[:,:10,3]=0; rgba[:,-10:,3]=0
    rgba[rgba[:,:,3]==0,:3]=0
    return Image.fromarray(rgba,"RGBA").resize(cell,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    raw=0
    for name,count,cell in PARTS:
        w,h=cell
        atlas=Image.new("RGBA",(4*w,ceil(count/4)*h))
        for i in range(count):
            f=render(name,i/(count-1),cell)
            assert f.getchannel("A").getbbox(),(name,i)
            atlas.alpha_composite(f,((i%4)*w,(i//4)*h))
            if i==count//2:
                (OUT/"master").mkdir(exist_ok=True)
                f.save(OUT/"master"/f"poi18_{name}_master_rgba.png",optimize=True)
        target=OUT/f"poi18_{name}_{count:02d}.png"
        atlas.save(target,optimize=True)
        raw+=atlas.width*atlas.height*4
        print("POI18_ORIGINAL_MARK_RGBA",name,count,atlas.size,target.stat().st_size)
    print("POI18_PHU_COT_CO_TIENA_R3_SOURCE_PASS poses=16 atlases=1 no_gif_no_rig=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
