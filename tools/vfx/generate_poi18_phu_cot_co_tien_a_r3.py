#!/usr/bin/env python3
"""POI18 Phụ Cốt Cổ · Tiên A (Liên Tâm) — original first-party RGBA sources.

R3.1 Ngoc To Linh Co — genuinely authored phase-changing jade spirit-silk flight: NO beetle/claws/creepy anatomy.
16 gu key poses in four morphological stages; R2C gather, burst and mark immutable.
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
        # POI18 R3.1: Ngoc To Linh Co — four morphologically distinct beats.
        # A seed-sized jade spirit enclosed in non-insect jade filigree, with
        # one mother-silk and one subordinate unbalanced silk. NO skeleton,
        # no commercial pixels, NO mirror-X/water-wave static silhouettes.
        # Head stays at LOCAL (80,-8) across 16 poses for exact Godot anchoring.
        phase=2*pi*t
        unfurl=np.clip(t/.20,0,1)
        drawout=np.clip((t-.13)/.25,0,1)
        condense=np.clip((t-.64)/.22,0,1)
        entering=np.clip((t-.84)/.16,0,1)
        head_x=80.
        head_y=-8.
        # Longitudinal shape develops from a compact seed through a full
        # unequal silk-fan, then contracts into the glowing gu head.
        tail_x=-18.-113.*drawout+47.*condense+38.*entering
        length=head_x-tail_x
        q=np.clip((x-tail_x)/length,0,1)
        s=np.sin(pi*q)
        envelope=np.clip((x-tail_x+6.)/15.,0,1)*np.clip((head_x+9.-x)/15.,0,1)
        # Main body arches toward the head without the symmetrical R2 chevron.
        drift=17.*(1.-q)+27.*s*np.cos(phase*.64+.65)
        spine=head_y+drift-25.*s+9.*np.sin(2*pi*q+phase*.86)*s*s
        breadth=(4.+16.*s**.85)*(0.70+.30*unfurl)*(1.-.35*entering)
        uneven=1.+.16*np.sin(9.*q+2.4*t)+.07*np.cos(21.*q-4.6*t)
        a=np.abs((y-spine)/(breadth*uneven+1e-5))
        broad=np.exp(-a**2.15)*envelope
        mid=np.exp(-(a*1.85)**2.25)*envelope
        seam=np.exp(-((y-spine)/(1.3+1.6*s))**2)*envelope
        progress=np.clip((t-.04)/.16,0,1)
        ink("shadow",broad*.18*progress)
        ink("deep",broad*.16*progress)
        ink("jade",broad*.45*progress*noise)
        ink("emerald",broad*.22*progress)
        ink("mint",mid*.42*progress)
        ink("ivory",seam*.32*progress)
        # Side-lit silk pleats, asymmetric sparse gold threads.
        for k,(loc,width,ampl) in enumerate(((.26,13.,.26),(.54,10.,.20),(.78,8.,.24))):
            cx=tail_x+length*loc
            cy=head_y+17.*(1.-loc)-25.*np.sin(pi*loc)+27.*np.sin(pi*loc)*np.cos(phase*.64+.65)+9.*np.sin(2*pi*loc+phase*.86)*np.sin(pi*loc)**2
            fold=np.exp(-(((x-cx)/(width+4.*s))**2+((y-cy-(8. if k==1 else -5.))/(7.+3.*unfurl))**2)*1.4)
            ink("mint",fold*ampl*unfurl*(1.-entering*.35))
            ink("gold",fold*.09*unfurl)
        # The child silk is shorter and diverges from the mother: not parallel.
        side_tail=tail_x+20.
        side_end=head_x-31.+24.*entering
        q2=np.clip((x-side_tail)/max(20.,side_end-side_tail),0,1)
        s2=np.sin(pi*q2)
        secondary_y=head_y+35.*(1.-q2)+14.*s2*np.sin(phase*.82+1.35)-10.*s2**2
        second_gate=np.clip((x-side_tail+3.)/13.,0,1)*np.clip((side_end+7.-x)/12.,0,1)
        w2=(2.5+10.*s2**1.0)*(1.-.58*entering)
        b2=np.exp(-(np.abs((y-secondary_y)/(w2+1e-5))**2.25))*second_gate*drawout*(1.-entering*.34)
        ink("deep",b2*.12)
        ink("jade",b2*.36*noise)
        ink("mint",np.exp(-((y-secondary_y)/(w2*.52+1e-5))**2)*b2*.22)
        ink("gold",np.exp(-((y-secondary_y)/(1.3+1.1*s2))**2)*second_gate*.20*drawout)
        # Detached silk fraying, spaced unevenly, no identical spark rows.
        for k in range(5):
            u0=.18+k*.147
            fx=tail_x+length*u0
            fs=np.sin(pi*u0)
            fy=head_y+17.*(1.-u0)+27.*fs*np.cos(phase*.64+.65)-25.*fs+9.*np.sin(2*pi*u0+phase*.86)*fs*fs
            side=(-1 if k%3==0 else 1)
            px=fx-(10.+5.*k)*unfurl
            py=fy+side*(11.+4.*np.sin(phase+1.7*k))
            gl=gauss(x,y,px,py,7.+(k%2)*3,2.3+(.8*k))
            ink("jade",gl*(.11+.04*(k%3))*drawout*(1.-entering))
            ink("gold",gauss(x,y,px+1.5,py-.8,2.4,1.7)*.16*drawout*(1.-entering))
        # Fringed, translucent jade-petal cradle; no eyes/legs/mandibles.
        # This part is a material object and MUST not read like a neon dot.
        seed_outer=oval(x,y,68.,-10.,25.+2.*unfurl,14.5,angle=-.10,edge=1.75)
        upper_lobe=oval(x,y,63.,-19.,20.,7.7,angle=-.48,edge=1.9)
        lower_lobe=oval(x,y,63.,2.,22.,7.4,angle=.39,edge=1.9)
        ink("deep",seed_outer*.23)
        ink("jade",seed_outer*(.47+.15*condense))
        ink("mint",upper_lobe*.39)
        ink("emerald",lower_lobe*.36)
        # Curved ivory-gold carved edge, only at the actual gu head.
        curved=[(56.,-19.),(64.,-20.5),(74.,-16.),(82.,-9.),(78.,0.8),(68.,5.)]
        ink("gold",filament(x,y,curved,2.)*(.28+.15*condense))
        ink("ivory",filament(x,y,curved,0.85)*.29)
        # Pearlescent nephrite heart, compact white-hot light with
        # warm gold fleck and soft falloff. Head LOCAL (80,-8).
        seed=gauss(x,y,80.,-8.,16.8,11.)
        luminous=gauss(x,y,80.,-8.,10.1,6.5)
        ink("jade",seed*.37)
        ink("mint",luminous*.58)
        ink("gold",gauss(x,y,79.,-9.,5.5,4.5)*(.26+.24*condense))
        ink("ivory",gauss(x,y,80.,-8.,3.4+1.2*entering,3.0+entering)*(.75+.14*condense))
        ink("ivory",gauss(x,y,87.,-12.,1.6,1.8)*.45)
        # A tiny asymmetric gold/white spill on the leading side.
        ink("gold",gauss(x,y,89.,-5.,5.0,2.5)*.25)
        ink("mint",gauss(x,y,87.,-8.,23.,16.)*.07)
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
    print("POI18_PHU_COT_CO_TIENA_R31_SOURCE_PASS poses=16 atlases=1 no_gif_no_rig=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
