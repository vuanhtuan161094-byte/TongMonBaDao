#!/usr/bin/env python3
"""POI18 Phụ Cốt Cổ · Tiên A (Liên Tâm) — original first-party RGBA sources.

R2 owner-requested beautiful spirit-silk: NO beetle/claws/creepy anatomy.
Original luminous double wings, contact petals and linked jade-leaf mark.
LAB only; no gameplay damage/status receipts. No GIF, rig or skeletal motion.
"""
from pathlib import Path
from math import ceil,pi
import numpy as np
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison18_phu_cot_co_tien_a/r2/assets"
SS=2
PARTS=(("gather",8,(256,256)),("gu",16,(320,256)),
       ("burst",12,(320,320)),("seal",12,(256,256)))
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
        # Floating small two-wing light spirit; visually closer to luminous
        # silk butterfly/lotus than an anatomically rendered beetle.
        # No legs, claws, mandibles, eyes, segmented shell or hard outline.
        flap=np.sin(2*pi*(2.2*t+.13))
        sway=3*np.sin(2*pi*t)
        ink("jade",gauss(x,y,-13+sway,0,74,50)*.10)
        for side in (-1.0,1.0):
            ang=side*(.50+.25*flap)
            cy=side*(27+10*flap)
            wing=silk(-38+sway,cy,71,19+3*flap,ang)
            inner=silk(-26+sway,side*(24+6*flap),46,10,side*(.44+.16*flap))
            ink("shadow",wing*.13)
            ink("jade",wing*.46*noise)
            ink("mint",inner*.29)
            ink("ivory",silk(-23+sway,side*(25+4*flap),34,4.3,side*.45)*.23)
            # Real feather veins: varying length, soft connected strokes.
            wingpath=[(12+sway,side*1),(-18+sway,side*17),
                      (-60+sway,side*(34+14*flap)),
                      (-98+sway,side*(62+18*flap))]
            ink("gold",filament(x,y,wingpath,2.2)*.36)
            ink("ivory",filament(x,y,wingpath,.95)*.47)
            flank=[(1+sway,side*5),(-40+sway,side*(18+4*flap)),
                   (-73+sway,side*(19+11*flap))]
            ink("mint",filament(x,y,flank,2.9)*.23)
            ink("gold",filament(x,y,flank,1.0)*.24)
            # Two tiny curved ribbon tips are wing ornament, not anatomy.
            ribbon=[(-87+sway,side*(52+12*flap)),
                    (-113+sway,side*(61+17*flap)),
                    (-127+sway,side*(55+17*flap))]
            ink("jade",filament(x,y,ribbon,3.1)*.20)
            ink("ivory",gauss(x,y,-98+sway,side*(62+18*flap),6.0,5.1)*.31)
        # Center is pure rounded light, not a bug torso.
        ink("jade",gauss(x,y,8+sway,1,26,19)*.22)
        ink("mint",gauss(x,y,15+sway,-1,15,12)*.60)
        ink("gold",gauss(x,y,19+sway,-1,10,9)*.66)
        ink("ivory",gauss(x,y,24+sway,-2,6,5.5)*.94)
        # Wake tapers to transparent; no copied circle trail.
        for k in range(5):
            px=-90-14*k+6*t; py=9*np.sin(k*1.17+7*t)
            ink("mint",gauss(x,y,px,py,2.4,3.4)*(.24-.035*k))
    elif name=="burst":
        # Soft local nectar bloom and three unequal silk petals at TARGET ONLY.
        q=np.sin(pi*min(1,t+.07))
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
    print("POI18_PHU_COT_CO_TIENA_R2_SOURCE_PASS poses=48 atlases=4 no_gif_no_rig=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
