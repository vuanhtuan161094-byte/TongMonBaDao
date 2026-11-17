#!/usr/bin/env python3
"""POI18 Phụ Cốt Cổ · Tiên A (Liên Tâm) — original first-party RGBA sources.

True isolated sprite material: living dual-wing gu, braided heart/vine mark,
distinct release/contact poses, no poster crops or borrowed commercial pixels.
LAB only; no gameplay damage/status receipts. No GIF, rig or skeletal motion.
"""
from pathlib import Path
from math import ceil,pi
import numpy as np
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison18_phu_cot_co_tien_a/r1/assets"
SS=2
PARTS=(("gather",8,(256,256)),("gu",16,(320,256)),
       ("burst",12,(320,320)),("seal",12,(256,256)))
RGB={
 "shadow":(20,57,43), "deep":(36,106,65), "jade":(53,204,134),
 "lime":(131,251,146), "gold":(241,205,95), "ivory":(253,248,202),
 "emerald":(18,167,120)
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

def render(name,t,cell):
    w,h=cell
    yy,xx=np.mgrid[:h*SS,:w*SS].astype(np.float32)
    x=(xx+.5)/SS-w*.5
    y=(yy+.5)/SS-h*.5
    p=np.zeros((h*SS,w*SS,4),np.float32)
    pulse=np.sin(pi*t)
    noise=np.clip(.93+.08*np.sin(.047*x+.085*y+7*t)*np.cos(.039*x-.056*y-4*t),.82,1)
    def ink(c,a): over(p,RGB[c],a)

    if name=="gather":
        # A single small gu-egg appears from two living, unequal spirit-vines.
        q=.12+.88*np.sin(pi*.5*t)
        for k in range(5):
            yy0=(-2.0+k)*14
            path=[(-105,yy0+19),(-68+7*k,-22+yy0*.30),(-31,-10+yy0*.20),(0,0)]
            vine=filament(x,y,path,2.0+k*.35)
            ink("deep",vine*.19*q)
            ink("jade",vine*.34*q*noise)
            ink("ivory",filament(x,y,path,0.75)*.28*q)
        egg=oval(x,y,0,2,23+7*t,37+5*t,.16)
        ink("shadow",gauss(x,y,0,0,49,58)*.21*q)
        ink("deep",egg*.76*q)
        ink("jade",oval(x,y,-2,0,19,30,.15)*.52*q)
        ink("gold",oval(x,y,8,-11,8,17,.15)*.55*q)
        ink("ivory",gauss(x,y,8,-15,5.3,8)*.75*q)
        for side in [-1,1]:
            horn=filament(x,y,[(8,0),(25,side*20),(39+9*t,side*(39+6*t))],2.2)
            ink("gold",horn*.48*q)
            ink("lime",horn*.27*q)
    elif name=="gu":
        # Living winged gu: independent opening/closing wing geometry each pose.
        wbeat=np.sin(t*2*pi*3.1)
        angle=(.16+.29*(.5+.5*wbeat))
        travel_x=2.5*np.sin(t*pi*4.0)
        travel_y=1.4*np.cos(t*pi*5.0)
        a=x-travel_x;b=y-travel_y
        ink("emerald",gauss(a,b,-27,0,81,53)*.17)
        # Wing pairs extend to different tips and angles as the pose progresses.
        for side in [-1.0,1.0]:
            wing=oval(a,b,-27,-side*(24+15*wbeat),58,23+5*wbeat,side*angle,1.8)
            ink("deep",wing*.37)
            ink("jade",wing*.25*noise)
            rib=filament(a,b,[(-20,side*2),(-38,side*29),(-85,side*(50+12*wbeat))],2.8)
            ink("gold",rib*.37)
            ink("ivory",filament(a,b,[(-13,side*3),(-38,side*29),(-85,side*(50+12*wbeat))],.9)*.38)
            wingtip=gauss(a,b,-77,side*(46+12*wbeat),12,11)
            ink("lime",wingtip*.31)
        # Abdomen: dark armored segments and hot flecks. HEAD points RIGHT.
        body=oval(a,b,0,0,57,22,-.08,2.5)
        ink("shadow",body*.83)
        ink("deep",oval(a,b,7,0,51,20,-.08)*.89)
        ink("jade",oval(a,b,4,-4,45,14,-.08)*.58*noise)
        ink("gold",oval(a,b,36,-3,16,15,.12)*.76)
        ink("ivory",gauss(a,b,46,-9,8,5)*.86)
        for k in range(4):
            segx=-41+k*19
            ink("gold",filament(a,b,[(segx,-15),(segx+5,0),(segx,16)],1.75)*.49)
        for side in [-1.0,1.0]:
            for j in range(3):
                bx=-27+j*24
                leg=filament(a,b,[(bx,side*11),(bx-13,side*(26+5*wbeat)),(bx-31,side*(39+8*wbeat))],1.9)
                ink("gold",leg*.52)
                ink("ivory",filament(a,b,[(bx-13,side*(26+5*wbeat)),(bx-31,side*(39+8*wbeat))],.65)*.30)
        for side in [-1.0,1.0]:
            anten=filament(a,b,[(43,side*4),(63,side*(15+3*wbeat)),(81,side*(25+8*wbeat))],1.5)
            ink("lime",anten*.69)
            ink("ivory",filament(a,b,[(62,side*(15+3*wbeat)),(81,side*(25+8*wbeat))],.8)*.65)
        for k in range(7):
            px=-112+k*14-8*t
            py=24*np.sin(k*2.2+t*7.0)
            ink("jade",gauss(a,b,px,py,2.6,4.0)*.28)
    elif name=="burst":
        # Local single-target bond conversion, not damage hit or circle AOE.
        q=np.sin(pi*.5*t)
        span=27+43*t
        core=gauss(x,y,0,0,18+18*t,20+22*t)
        ink("deep",gauss(x,y,0,0,65+45*t,56+36*t)*.16*(1-t))
        for side in [-1.0,1.0]:
            path=[(0,-9),(side*(15+10*t),-21),(side*(32+17*t),1),
                  (side*(18+20*t),29),(side*5,11)]
            ribbon=filament(x,y,path,6.2+3.0*t)
            ink("deep",ribbon*.34*q)
            ink("jade",filament(x,y,path,3.1+1.2*t)*.65*q)
            ink("gold",filament(x,y,path,1.35)*.64*q)
            ink("ivory",filament(x,y,path,.65)*.50*q)
            # Bone/heart thorns visibly grow out from the two hooked vines.
            for i in range(3):
                tx=side*(21+14*t+i*7)
                ty=-13+18*i
                claw=filament(x,y,[(tx,ty),(tx+side*(10+8*t),ty-11),(tx+side*(20+11*t),ty-7)],1.5)
                ink("lime",claw*.46*q)
        ink("jade",core*.21*(1-t))
        ink("ivory",gauss(x,y,0,0,8+9*t,9+9*t)*.83*(1-t))
    elif name=="seal":
        # One recognizable pair of linked heart-thorns, small and readable on chest.
        q=1.0-.19*t
        beat=1+.035*np.sin(t*2*pi)
        a=x/beat;b=y/beat
        ink("shadow",gauss(a,b,0,1,52,51)*.20*q)
        # Asymmetric living connected two-lobe heart knot, NOT a circular rune.
        for side in [-1.0,1.0]:
            stem=[(0,26),(side*23,11),(side*35,-9),(side*27,-30),
                  (side*9,-33),(0,-16)]
            ink("deep",filament(a,b,stem,7.3)*.37*q)
            ink("jade",filament(a,b,stem,4.2)*.66*q)
            ink("gold",filament(a,b,stem,1.8)*.66*q)
            ink("ivory",filament(a,b,stem,.8)*.58*q)
            thorn=filament(a,b,[(side*26,-8),(side*49,-21),(side*40,-39)],1.6)
            ink("lime",thorn*.56*q)
        ink("gold",oval(a,b,0,15,7,18,0)*.52*q)
        ink("ivory",gauss(a,b,0,12,4,7)*.71*q)
        for k in range(4):
            v=-1 if k%2 else 1
            px=v*(42+6*t)
            py=-25+k*16
            ink("lime",gauss(a,b,px,py,2.0,4.5)*.28*q)
    # Full-size original alpha master/cells with no extracted poster or matte.
    orig=p[:,:,3]
    gain={"gather":1.40,"gu":1.45,"burst":1.53,"seal":1.51}[name]
    p[:,:,3]=np.clip(np.where(orig>.03,1-(1-orig)**gain,orig*1.08),0,.965)
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
    print("POI18_PHU_COT_CO_TIENA_R1_SOURCE_PASS poses=40 atlases=4 no_gif_no_rig=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
