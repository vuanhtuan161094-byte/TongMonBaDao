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

def heartfield(x,y,cx,cy,r):
    """A filled hand-drawn fantasy heart/living seed, not a neon HUD polygon."""
    u=(x-cx)/r
    v=-(y-cy)/(r*.98)
    f=(u*u+v*v-1)**3-u*u*v*v*v
    # Distinct filled-petal body and independently bright edge.
    return 1/(1+np.exp(np.clip(f*22,-30,30))),np.exp(-((f/.14)**2))

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
        # R1B: articulated horned scarab with visibly separated membrane wings,
        # central opaque chitin, four leg pairs and curved golden antennae.
        # R1 dark-UFO oval FAILED art review; deliberately remove its umbrella.
        flutter=np.sin(t*2*pi*3.5)
        driftx=2*np.sin(t*8*pi); drifty=2*np.cos(t*9*pi)
        a=x-driftx;b=y-drifty
        ink("emerald",gauss(a,b,-8,0,67,51)*.095)
        for side in (-1.0,1.0):
            spread=40+22*flutter
            wing=oval(a,b,-51,side*spread,53,13,side*(.66+.23*flutter),2.6)
            innerwing=oval(a,b,-46,side*(28+9*flutter),39,9,side*(.48+.14*flutter),2.5)
            ink("shadow",wing*.49)
            ink("jade",wing*.55*noise)
            ink("lime",innerwing*.37)
            rib=filament(a,b,[(-19,side*8),(-44,side*37),(-90,side*(61+19*flutter))],2.6)
            ink("gold",rib*.52)
            ink("ivory",filament(a,b,[(-24,side*13),(-46,side*40),(-91,side*(63+19*flutter))],.9)*.65)
            ink("gold",filament(a,b,[(-30,side*17),(-60,side*(46+9*flutter)),(-106,side*(45+13*flutter))],1.25)*.30)
            ink("ivory",gauss(a,b,-90,side*(62+18*flutter),5,5)*.65)
        # Carapace: dark segmented armor with a visibly hot golden head,
        # not a uniformly transparent electric ellipse.
        body=oval(a,b,-6,0,62,25,-.03,2.9)
        ink("shadow",body*.98)
        ink("deep",oval(a,b,-5,0,59,22,-.03,2.8)*.95)
        ink("jade",oval(a,b,-7,-6,51,15,-.07,2.1)*.75*noise)
        ink("lime",oval(a,b,-35,-8,24,9,-.07,2)*.36)
        for k in range(4):
            px=-47+18*k
            shell=filament(a,b,[(px,-20),(px+9,-6),(px+8,9),(px,20)],2.0)
            ink("gold",shell*.66)
            ink("ivory",filament(a,b,[(px,-18),(px+8,-5)],.7)*.37)
        # A distinct head, two side eyes, curved split mandibles.
        ink("gold",oval(a,b,49,0,24,21,.03,2.5)*.82)
        ink("lime",oval(a,b,56,-3,15,15,0,2)*.70)
        ink("ivory",gauss(a,b,58,-7,7,6)*.79)
        for side in (-1.0,1.0):
            ink("ivory",gauss(a,b,49,side*11,4.3,3.5)*.82)
            for j in range(4):
                legx=-42+22*j
                bendx=legx-7+(j%2)*8+4*flutter
                leg=filament(a,b,[(legx,side*20),(bendx,side*34),(bendx-12,side*(51+6*flutter))],2.1)
                ink("gold",leg*.75)
                ink("lime",filament(a,b,[(bendx,side*34),(bendx-12,side*(51+6*flutter))],.8)*.42)
            mandible=filament(a,b,[(58,side*11),(72,side*(22+3*flutter)),
                                   (89,side*16),(95,side*7)],2.1)
            ink("gold",mandible*.82)
            ink("ivory",filament(a,b,[(73,side*(22+3*flutter)),(89,side*16),(95,side*7)],.8)*.72)
            anten=filament(a,b,[(62,side*10),(74,side*21),(78,side*36),(89,side*39)],1.4)
            ink("lime",anten*.72)
        for k in range(9):
            px=-121+k*10-6*t
            py=7*np.sin(1.6*k+8*t)
            ink("jade",gauss(a,b,px,py,2.2,3.3)*.26)
    elif name=="burst":
        # Two bloom-open organic heart-petals become one linked curse on impact.
        q=1.0-t
        opens=.45+.55*np.sin(pi*.5*t)
        ink("emerald",gauss(x,y,0,1,45+23*t,37+22*t)*.13*q)
        for side in (-1.0,1.0):
            cx=side*(14+16*t)
            filled,rim=heartfield(x,y,cx,-6,17+10*t)
            ink("shadow",filled*.72*opens)
            ink("jade",filled*.49*opens)
            ink("lime",filled*.38*opens*noise)
            ink("gold",rim*.68*opens)
            ink("ivory",rim*.40*opens)
            # Different anatomical heart veins grow outward from each lobe.
            vine=filament(x,y,[(0,22),(side*8,16),(cx,-5),(cx+side*18,-19),
                               (cx+side*(28+10*t),-30)],2.8)
            ink("deep",vine*.28*opens)
            ink("gold",filament(x,y,[(0,22),(side*8,16),(cx,-5),
                                   (cx+side*18,-19)],1.2)*.68*opens)
            ink("ivory",gauss(x,y,cx,-17,4.2,5)*.68*opens)
            for k in range(3):
                px=cx+side*(10+13*t+k*7)
                py=-18+15*k
                thorn=filament(x,y,[(px,py),(px+side*(9+9*t),py-8),
                                   (px+side*(15+9*t),py-5)],1.65)
                ink("jade",thorn*.42*opens)
                ink("ivory",filament(x,y,[(px+side*(9+9*t),py-8),
                                       (px+side*(15+9*t),py-5)],.75)*.30*opens)
        ink("gold",gauss(x,y,0,14,10+8*t,8+5*t)*.32*q)
        ink("ivory",gauss(x,y,0,12,6+6*t,5+4*t)*.66*q)
    elif name=="seal":
        # Persistent two SOLID, legible heart-seeds, linked by glowing tendons.
        # A heartbeat mark, deliberately not an open geometry shield/ring.
        beat=1+.025*np.sin(t*2*pi)+.021*t
        a=(x-3.4*t)/beat;b=(y+1.5*t)/beat
        ink("deep",gauss(a,b,0,0,64,47)*.12)
        ink("gold",filament(a,b,[(-27,-10),(-10,12),(0,23),
                                 (10,12),(27,-10)],3.8)*.33)
        for side in (-1.0,1.0):
            cx=side*27
            filled,rim=heartfield(a,b,cx,-4,23)
            ink("shadow",filled*.78)
            ink("jade",filled*.65)
            ink("lime",filled*.28)
            ink("gold",rim*.68)
            ink("ivory",rim*.52)
            vein=filament(a,b,[(cx,-23),(cx+side*7,-9),
                               (cx-side*4,4),(cx,18)],1.4)
            ink("ivory",vein*.59)
            ink("gold",filament(a,b,[(cx-side*3,-18),(cx+side*8,-14),
                                   (cx+side*11,0)],1.8)*.44)
            ink("ivory",gauss(a,b,cx-7,-16,6,4)*.70)
            # Unpaired botanical tendril identifies the Liên Tâm lineage.
            root=filament(a,b,[(cx,18),(cx+side*12,27),
                               (cx+side*27,17),(cx+side*41,8)],2.0)
            ink("emerald",root*.50)
            ink("gold",filament(a,b,[(cx,18),(cx+side*12,27),
                                    (cx+side*27,17)],.75)*.43)
        ink("ivory",gauss(a,b,2.0*t,20-3*t,7+3*t,6)*(.60+.15*t))
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
    print("POI18_PHU_COT_CO_TIENA_R1_SOURCE_PASS poses=48 atlases=4 no_gif_no_rig=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
