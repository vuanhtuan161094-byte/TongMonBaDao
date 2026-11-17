#!/usr/bin/env python3
"""POI16 Vạn Linh Giải Ách (Human Dược Độc ultimate): independent painterly
luminous soft RGBA source art, no GIF, no rig, no imported commercial pixels.

Canonical HEAL circle 2.5 world, MAX 3 ally targets, cast1.2s, cooldown46s,
zero projectile speed and status duration0; no actual Combat V2 receipts.

Four DISTINCT visual roles:
  charge 8: jade-white alchemical pearl and fine aurora around caster palm;
  bloom 12: broad translucent 3-fold nectar lotus-of-light (NO icon outline);
  blessing 10: silver/ivory liquid streams gently illuminating 3 moving allies;
  fade 8: suspended floating light-motes as illumination disperses.
"""
from pathlib import Path
import numpy as np
import math
from PIL import Image

OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison16_van_linh_giai_ach/r1/assets"
SCALE=2
PARTS=(("charge",8,(192,192)),("bloom",12,(384,320)),
       ("blessing",10,(192,192)),("fade",8,(256,224)))
C={
 "jade":(25,237,158),"aqua":(37,230,214),"emerald":(26,193,118),
 "pearl":(232,255,238),"ivory":(254,255,209),"gold":(249,225,145),
 "sky":(91,206,247),"mist":(103,251,210)
}

def paint(p,rgb,alpha):
    a=np.clip(alpha,0,1).astype(np.float32)
    old=p[:,:,3]
    new=a+old*(1-a)
    p[:,:,:3]=(p[:,:,:3]*old[:,:,None]*(1-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(new[:,:,None],1e-6)
    p[:,:,3]=new

def gauss(x,y,cx,cy,sx,sy):
    return np.exp(-((x-cx)/sx)**2-((y-cy)/sy)**2)

def gate(v,a,b,soft):
    return np.clip((v-a)/soft,0,1)*np.clip((b-v)/soft,0,1)

def src(part,t,cell):
    w,h=cell
    yy,xx=np.mgrid[0:h*SCALE,0:w*SCALE].astype(np.float32)
    x=(xx+.5)/SCALE-w/2
    y=(yy+.5)/SCALE-h/2
    r=np.hypot(x,y);ang=np.arctan2(y,x)
    p=np.zeros((h*SCALE,w*SCALE,4),np.float32)
    tex=np.clip(.83+.11*np.cos(.028*x+.062*y+3.8*t)*np.sin(.067*x-.029*y-2.9*t)
                +.055*np.sin(.121*x+.043*y+1.1*t),.61,1.0)
    def lay(name,a):paint(p,C[name],a)
    if part=="charge":
        strength=.24+.76*t
        # Fine-silk life strands spiral inward but do not snake around.
        for i in range(8):
            phi=i*math.tau/8+.17
            dist=48*(1-t)**.93+8
            cx=np.cos(phi)*dist;cy=np.sin(phi)*dist*.82
            lay("emerald",gauss(x,y,cx,cy,12,17)*.11*strength*tex)
            lay("aqua",gauss(x,y,cx,cy,5.7,8.5)*.13*strength)
            cx2=(cx+6*np.sin(phi*1.3+t))*0.74
            cy2=cy*.74
            lay("gold",gauss(x,y,cx2,cy2,2.7,5.2)*.14*strength)
        # Tall, open drifts with no outline ring.
        for i in range(4):
            offset=(i-1.5)*13
            curve=offset+4.8*np.sin(y*.023+i*1.3+t*.32)
            line=np.exp(-((x-curve)/(3.3+i%2))**2)*gate(y,-49,34,21)
            lay("mist" if i%2 else "aqua",line*.14*strength*tex)
        lay("jade",gauss(x,y,0,2,31,30)*.20*strength)
        lay("aqua",gauss(x,y,0,1,16,18)*.23*strength)
        lay("pearl",gauss(x,y,0,1,6+1.9*t,7+1.9*t)*.63*strength)
        lay("ivory",gauss(x,y,0,1,2.8,4.0)*.71*strength)
    elif part=="bloom":
        # Threefold radiant life-wave. Not a solid disk or UI/geometric sigil.
        strength=np.clip(.35+.65*np.sin(math.pi*(.10+.72*t))**.71,0,1)
        growth=.35+.76*t
        ell=np.hypot(x/1.15,y/0.84)
        orbit=1+.08*np.sin(3*ang+1.8*t)+.045*np.sin(7*ang-.5*t)
        wave_radius=144*growth
        edge=np.exp(-((ell/np.maximum(.73,orbit)-wave_radius)/(9+4*t))**2)
        lay("emerald",gauss(x,y,0,2,92*growth+25,72*growth+18)*.16*strength*tex)
        lay("jade",gauss(x,y,0,0,67*growth+15,53*growth+15)*.23*strength)
        lay("aqua",edge*.10*strength*tex)
        lay("gold",edge*.045*strength)
        # 3 luminous organic "wings", each a stream made of independent wisps.
        for i in range(3):
            phi=i*math.tau/3-.25
            longitudinal=x*np.cos(phi)+y*np.sin(phi)
            transverse=-x*np.sin(phi)+y*np.cos(phi)
            center=9*np.sin(longitudinal*.013+1.1*i+1.2*t)
            envelope=gate(longitudinal,10,126*growth,24)
            for k in range(3):
                side=center+(k-1)*11*(.36+.64*np.clip(longitudinal/145,0,1))
                width=(3.3+2.5*k+2*i%3)
                feather=np.exp(-((transverse-side)/width)**2)*envelope
                lay(["aqua","jade","gold"][(k+i)%3],feather*(.33+.075*(k%2))*strength*tex)
            # R1B independently painted bright threefold life currents, not a thin UI circle.
            fan_center=center+11*np.sin(longitudinal*.010+i*.83+t*.65)
            fan=np.exp(-((transverse-fan_center)/15.0)**2)*gate(longitudinal,15,135*growth,28)
            lay("mist",fan*.17*strength*tex)
            lay("gold",np.exp(-((transverse-fan_center)/5.2)**2)*gate(longitudinal,37,112*growth,24)*.12*strength)

            tip=gauss(x,y,108*growth*np.cos(phi),108*growth*np.sin(phi),11,13)
            lay("pearl",tip*.34*strength)
        # A drifting constellation of green-ivory sparks: 3fold, NOT a rigid lotus icon.
        for i in range(25):
            a=i*2.39996+.19
            dist=(21+13*(i%7))*growth+6
            cx=dist*np.cos(a)+7*np.sin(2.1*t+i*.85)
            cy=dist*np.sin(a)*.75-3*np.cos(t*2+i)
            dust=gauss(x,y,cx,cy,2.8+.65*(i%3),4.4+(i%4))
            lay("gold" if i%5==0 else "aqua",dust*(.28+.068*(i%4))*strength)
            lay("pearl",gauss(x,y,cx,cy,1.25,2.1)*.19*strength)
        lay("jade",gauss(x,y,0,0,36,39)*.20*strength)
        lay("pearl",gauss(x,y,0,0,9.3,11)*.88*strength)
        lay("ivory",gauss(x,y,0,0,4.1,5.0)*.92*strength)
    elif part=="blessing":
        # A slim, non-solid fountain of life around each real moving ally.
        power=.53+.47*np.sin(math.pi*(.12+.76*t))**.75
        for k in range(9):
            offset=(k-4)*8
            drift=offset+3.8*np.sin(y*.023+k*1.14+t*.78)
            length=gate(y,-74+(k%3)*5,69-(k%4)*6,22)
            main=np.exp(-((x-drift)/(3.2+1.2*(k%3)))**2)*length
            lay("jade" if k%3 else "aqua",main*(.25+.055*(k%4))*power*tex)
            lay("pearl",np.exp(-((x-drift)/1.6)**2)*length*.13*power)
        lay("emerald",gauss(x,y,-6,4,44,68)*.12*power*tex)
        lay("aqua",gauss(x,y,8,-10,28,52)*.17*power*tex)
        # Individual translucent droplets rise as life-energy.
        for i in range(11):
            phase=i*2.39996
            cx=23*np.sin(phase)+4*np.sin(i*.77+t*3)
            cy=40-67*t+23*np.cos(phase*.62)+(i%3)*3
            lay("gold" if i%4==0 else "mist",
                gauss(x,y,cx,cy,2.0+(i%3),3.9+(i%4))*(.42+.065*(i%3))*power)
            lay("pearl",gauss(x,y,cx,cy,1.1,1.9)*.19*power)
        lay("jade",gauss(x,y,0,3,18,23)*.17*power)
        lay("pearl",gauss(x,y,0,2,5,7.2)*.76*power)
        lay("ivory",gauss(x,y,0,2,2.6,3.7)*.70*power)
    elif part=="fade":
        retained=max(.08,(1-t)**1.55)
        lay("aqua",gauss(x,y,0,-10-15*t,68+19*t,59+18*t)*.077*retained*tex)
        for j in range(19):
            a=j*2.39996
            dist=18+(j%7)*9+14*t
            cx=dist*np.sin(a)+t*11*np.cos(a+.5)
            cy=18+dist*np.cos(a)*.76-t*(31+4*(j%6))
            v=gauss(x,y,cx,cy,3+(j%4),6+1.3*(j%3))
            lay("jade" if j%3 else "gold",v*(.32+.038*(j%4))*retained)
            lay("pearl",gauss(x,y,cx,cy,1.45,2.5)*.23*retained)
        for j in range(5):
            off=(j-2)*18
            body=np.exp(-((x-off-6*np.sin(y*.024+j*1.3+t))/5.0)**2)*gate(y,-73,47,21)
            lay("mist",body*.10*retained*tex)
        lay("pearl",gauss(x,y,0,-9,6+8*t,10+10*t)*.27*retained)
    else:raise ValueError(part)

    # R1C G3.5 VISIBILITY REWORK (true-energy RGBA, no flat opaque glyph).
    # Separate hot ivory nucleus, saturated jade BODY and faint transparent halo.
    if part=="charge":
        a=.22+.78*t
        for k in range(5):
            off=(k-2)*11.0
            v=off+6*np.sin(y*.026+k*1.1+t*.5)
            m=np.exp(-((x-v)/5.3)**2)*gate(y,-48,48,19)
            lay("jade" if k%2 else "aqua",m*.54*a*tex)
            lay("pearl",np.exp(-((x-v)/1.8)**2)*gate(y,-37,31,12)*.37*a)
        lay("jade",gauss(x,y,0,0,30,30)*.37*a)
        lay("gold",gauss(x,y,0,0,13,15)*.30*a)
        lay("ivory",gauss(x,y,0,0,7,8)*.90*a)
        lay("pearl",gauss(x,y,0,0,3.8,4.8)*.90*a)
    elif part=="bloom":
        a=.32+.68*np.sin(np.pi*(.1+.74*t))**.75
        g=.35+.76*t
        for k in range(3):
            phi=-.25+k*math.tau/3
            along=x*np.cos(phi)+y*np.sin(phi)
            across=-x*np.sin(phi)+y*np.cos(phi)
            center=6*np.sin(along*.015+k*.93+t*.88)
            m=gate(along,-8,142*g,24)
            body=np.exp(-((across-center)/(12+3*k))**2)*m
            core=np.exp(-((across-center)/(3.0+.5*k))**2)*m
            lay("jade" if k%2 else "aqua",body*.49*a*tex)
            lay("pearl",core*.52*a)
            tip=gauss(x,y,119*g*np.cos(phi),119*g*np.sin(phi),9+2*k,11+2*k)
            lay("gold",tip*.38*a)
        lay("jade",gauss(x,y,0,-4,39,42)*.34*a)
        lay("pearl",gauss(x,y,0,-4,11,12)*.79*a)
        lay("ivory",gauss(x,y,0,-4,5,6)*.94*a)
    elif part=="blessing":
        a=.43+.57*np.sin(np.pi*(.13+.74*t))**.78
        for k in range(6):
            off=(k-2.5)*11
            path=off+5*np.sin(y*.021+k*1.2+t*.9)
            mask=np.exp(-((x-path)/(5.8+1.2*(k%3)))**2)*gate(y,-70,72,21)
            hot=np.exp(-((x-path)/1.8)**2)*gate(y,-58,61,16)
            lay("jade" if k%2 else "aqua",mask*.54*a*tex)
            lay("pearl",hot*.31*a)
        lay("aqua",gauss(x,y,0,-5,31,40)*.30*a)
        lay("gold",gauss(x,y,0,-7,18,20)*.24*a)
        lay("ivory",gauss(x,y,0,-7,9,10)*.82*a)
        lay("pearl",gauss(x,y,0,-7,4.6,5.7)*.91*a)
    elif part=="fade":
        a=max(.08,(1-t)**1.14)
        for k in range(13):
            phi=k*2.39996
            cx=(14+8*(k%5))*np.sin(phi)+13*t*np.cos(phi)
            cy=(19+6*(k%4))*np.cos(phi)-62*t
            lay("jade",gauss(x,y,cx,cy,4,7)*.32*a)
            lay("ivory",gauss(x,y,cx,cy,1.9,2.8)*.39*a)
        lay("aqua",gauss(x,y,0,-12-16*t,59,53)*.13*a)
    # R1B median nonzero alpha = charge8 / bloom20 / blessing9 of 255:
    # recover midtone legibility without hard edges/opaque stamps.
    old_alpha=p[:,:,3]
    gain={"charge":2.05,"bloom":1.85,"blessing":2.0,"fade":1.9}[part]
    p[:,:,3]=np.clip(np.where(old_alpha>.045,1-(1-old_alpha)**gain,
                               old_alpha*1.20),0,.965)

    rgba=np.zeros_like(p,dtype=np.uint8)
    rgba[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    rgba[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    # Every transparent pixel is really alpha0; no clipart square matte.
    rgba[:14,:,3]=0;rgba[-14:,:,3]=0;rgba[:,:14,3]=0;rgba[:,-14:,3]=0
    rgba[rgba[:,:,3]==0,:3]=0
    return Image.fromarray(rgba,"RGBA").resize(cell,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    raw=0
    for kind,count,cell in PARTS:
        w,h=cell
        atlas=Image.new("RGBA",(4*w,h*math.ceil(count/4)))
        for frame_index in range(count):
            im=src(kind,frame_index/(count-1),cell)
            assert im.getchannel("A").getbbox(),(kind,frame_index)
            atlas.alpha_composite(im,((frame_index%4)*w,(frame_index//4)*h))
            if frame_index==count//2:
                (OUT/"master").mkdir(parents=True,exist_ok=True)
                im.save(OUT/"master"/f"poi16_{kind}_master_rgba.png",optimize=True)
        dest=OUT/f"poi16_{kind}_{count:02d}.png"
        atlas.save(dest,optimize=True)
        raw+=atlas.width*atlas.height*4
        print("POI16_ORIGINAL_RGBA_ATLAS",kind,count,atlas.size,"png_bytes",dest.stat().st_size)
    print("POI16_VAN_LINH_GIAI_ACH_R1C_SOURCE_PASS poses=38 atlases=4 no_gif=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
