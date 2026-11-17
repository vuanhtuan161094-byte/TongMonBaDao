#!/usr/bin/env python3
"""PAF08 original transparent script-flow VFX, reproducible first-party raster source.
Lưu Văn Liễm Tức: flowing jade-gold INK, controlled breath and internalized
wind scripture, distinct from PAF06 halo and PAF07 hand pearl.
No rig, fake cast/strike, raster poster crops, commercial Võ Lâm sprites, GIF.
"""
from PIL import Image,ImageDraw,ImageFilter
from pathlib import Path
import math,json,hashlib
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'godot/labs/combat_lab/talisman18'
ART=BASE/'art_sources';ASSETS=BASE/'assets'
ART.mkdir(parents=True,exist_ok=True);ASSETS.mkdir(parents=True,exist_ok=True)
N=320;S=3;W=N*S;FRAMES=36;COLS=9;TAU=math.tau
JADE=(29,210,161);IVORY=(241,255,221);GOLD=(251,204,111)

def blank(): return Image.new('RGBA',(W,W),(0,0,0,0))
def points(a):return [(round(x*S),round(y*S)) for x,y in a]
def bez(a,b,c,d,steps=100):
    return [tuple((1-t)**3*a[j]+3*(1-t)**2*t*b[j]+3*(1-t)*t*t*c[j]+t**3*d[j] for j in range(2)) for t in (k/(steps-1) for k in range(steps))]
def composite(base,layer,blur=5,opacity=.3):
    glow=layer.filter(ImageFilter.GaussianBlur(blur*S))
    glow.putalpha(glow.getchannel('A').point(lambda v:int(v*opacity)))
    base.alpha_composite(glow);base.alpha_composite(layer)

def ink_body(dst,curve,thick,intensity=1,seed=0,phase=0):
    # Independent original variable-width painted brush, tapered and internally lit.
    # Each evolving key-pose lengthens/contracts its OWN ink stroke. No whole-picture wave.
    extent=.68+.32*(.5+.5*math.sin(TAU*phase+seed*.42))
    curve=curve[:max(18,int(len(curve)*extent))]
    paint=blank();draw=ImageDraw.Draw(paint,'RGBA')
    left=[];right=[]
    for i,(x,y) in enumerate(curve):
        u=i/(len(curve)-1)
        old=curve[max(0,i-1)];nxt=curve[min(len(curve)-1,i+1)]
        vx=nxt[0]-old[0];vy=nxt[1]-old[1];mag=max(0.01,math.hypot(vx,vy))
        nx=-vy/mag;ny=vx/mag
        taper=(.08+.92*math.sin(math.pi*u)**.63)*(1-.25*u)
        width=thick*taper*(.91+.07*math.sin(u*23+seed*.91))
        left.append((x+nx*width,y+ny*width))
        right.append((x-nx*width*.36,y-ny*width*.36))
    draw.polygon(points(left+right[::-1]),fill=(*JADE,int(106*intensity)))
    draw.line(points(left),fill=(*JADE,int(183*intensity)),width=max(1,int(thick*.36*S)),joint='curve')
    core=curve[1:-1]
    draw.line(points(core),fill=(*IVORY,int(192*intensity)),width=max(1,int(thick*.18*S)),joint='curve')
    for j in range(6):
        st=.10+.135*j+.025*math.sin(seed+j)
        en=min(0.94,st+.061+.035*math.sin(seed*1.2+j))
        section=curve[max(0,int(st*(len(curve)-1))):max(2,int(en*(len(curve)-1)))]
        if len(section)>2:
            draw.line(points(section),fill=(*GOLD,int(160*intensity)),width=max(1,int(.80*S)),joint='curve')
    composite(dst,paint,6,.28)
    packet=blank();d=ImageDraw.Draw(packet,'RGBA')
    for j in range(3):
        u=(phase+.31*j+.07*seed)%1
        idx=int(u*(len(curve)-1));x,y=curve[idx]
        radius=(1.4+1.5*math.sin(math.pi*u))*S
        a=int((160+65*math.sin(math.pi*u))*intensity)
        d.ellipse((x*S-radius,y*S-radius,x*S+radius,y*S+radius),fill=(*IVORY,a))
    composite(dst,packet,2.5,.38)

def src_frame(layer,k):
    t=k/FRAMES;out=blank()
    if layer=='rear':
        curves=[((113,225),(89,207),(100,168),(154,155),5.0),
                ((214,221),(222,201),(206,178),(188,166),3.8),
                ((117,242),(138,232),(133,210),(158,199),3.3)]
        for j,(a,b,c,d,w) in enumerate(curves):
            ink_body(out,bez(a,b,c,d),w,intensity=.67 if j else .78,seed=j+1,phase=(t+j*.21)%1)
    elif layer=='front':
        curves=[((113,218),(134,211),(142,190),(175,178),5.3),
                ((202,217),(205,185),(194,169),(182,143),3.9),
                ((135,232),(162,214),(177,209),(191,191),3.6)]
        for j,(a,b,c,d,w) in enumerate(curves):
            shift=4.0*math.sin(TAU*t+j*.8)
            head=(d[0]+shift,d[1]-shift*.33)
            mid=(c[0]+shift*.4,c[1]+shift*.7)
            ink_body(out,bez(a,b,mid,head),w,intensity=.95 if j==0 else .83,
                     seed=6+j,phase=(t*.95+j*.28)%1)
    else:
        # R2 semantic rescue: a DISTINCT vertical gold ink scripture flows
        # over the robe, with individual tapered brush heads. No giant HUD
        # glyph, no circle/three paper talismans, no generic halo repeat.
        glyph=[
          ((147,142),(160,132),(182,136),(196,147),4.1),
          ((164,143),(162,155),(158,172),(150,182),4.9),
          ((177,151),(192,163),(195,183),(182,191),3.9),
          ((148,179),(163,174),(179,173),(188,182),2.6),
          ((151,194),(166,209),(179,218),(199,206),4.4),
          ((135,160),(146,166),(151,154),(163,155),2.9),
          ((174,191),(167,205),(163,214),(155,224),3.2),
        ]
        for j,(a,b,c,d,w) in enumerate(glyph):
            line=blank();brush=ImageDraw.Draw(line,'RGBA')
            # Move the writing next to the forearm, outside gold-on-gold costume.
            # The jade ink currents still lead INTO the inscription.
            path=[(x+39.0,y-7.0) for x,y in bez(a,b,c,d,42)]
            # R1D: handwriting appears stroke-by-stroke and retreats into the jade ink.
            write=.51+.49*(.5+.5*math.sin(TAU*(t+j*.19)))
            path=path[:max(16,int(len(path)*write))]
            upper=[];lower=[]
            for idx,(x,y) in enumerate(path):
                u=idx/(len(path)-1)
                old=path[max(0,idx-1)];nxt=path[min(idx+1,len(path)-1)]
                dx=nxt[0]-old[0];dy=nxt[1]-old[1]
                mag=max(.001,math.hypot(dx,dy))
                nx,ny=-dy/mag,dx/mag
                thick=w*(.10+.90*math.sin(math.pi*u)**.65)
                upper.append((x+nx*thick,y+ny*thick))
                lower.append((x-nx*thick*.43,y-ny*thick*.43))
            brush.polygon(points(upper+lower[::-1]),fill=(*GOLD,174))
            brush.line(points(path),fill=(*IVORY,194),width=max(1,int(w*.22*S)),joint='curve')
            # Real light packets advance through the carved gold ink glyph.
            active=(t*1.36+j*.17)%1.0
            tip=path[int(active*(len(path)-1))]
            radius=(1.4+.7*math.sin(TAU*t+j)) * S
            brush.ellipse((tip[0]*S-radius,tip[1]*S-radius,
                           tip[0]*S+radius,tip[1]*S+radius),
                          fill=(*IVORY,225))
            composite(out,line,3.8,.26)
    flick=blank();dd=ImageDraw.Draw(flick,'RGBA')
    for j in range(17):
        u=(t+.6180339*j)%1
        x=153+math.sin(j*2.4+u*1.8)*53
        y=221-u*102+10*math.cos(j*2.15)
        rr=.35+1.3*math.sin(math.pi*u)
        al=round(140*math.sin(math.pi*u))
        if al>0:
            dd.ellipse(((x-rr)*S,(y-rr)*S,(x+rr)*S,(y+rr)*S),
                       fill=(*(GOLD if j%4==0 else IVORY),al))
    composite(out,flick,2.2,.24)
    return out.resize((N,N),Image.Resampling.LANCZOS)

def save(p,im):
    if p.suffix=='.webp':im.save(p,format='WEBP',lossless=True,method=5)
    else:im.save(p)
    return {'path':str(p.relative_to(ROOT)),
            'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),
            'size':[im.width,im.height]}

if __name__=='__main__':
    m={'schema':'PAF08_R1D_AUTHORED_WRITING_AND_RETRACTION',
       'skill_id':'tmb.skill.talisman.phong_an_phu.passive_03.human',
       'contract':'PASSIVE_ALWAYS_ON_OUTGOING_FACTOR_0.015_NO_HIT',
       'rights':'FIRST_PARTY_ISOLATED_RGBA_PAINTED_FROM_CODE',
       'frames_per_layer':FRAMES,'columns':COLS,'cell_px':N,
       'loop_seconds':3.0,'layers':{}}
    for name in ('rear','front','script'):
        frames=[src_frame(name,i) for i in range(FRAMES)]
        at=Image.new('RGBA',(N*COLS,N*4),(0,0,0,0))
        for i,im in enumerate(frames):
            at.alpha_composite(im,((i%COLS)*N,(i//COLS)*N))
        m['layers'][name]={'atlas':save(ASSETS/('paf08_'+name+'.webp'),at),
                           'master':save(ART/('paf08_'+name+'_master.png'),frames[9])}
        if name=='front':
            r=Image.new('RGBA',(N*6,N*2),(0,0,0,0))
            for q,k in enumerate((0,3,6,9,12,15,18,21,24,27,30,33)):
                r.alpha_composite(frames[k],((q%6)*N,(q//6)*N))
            m['review']=save(ART/'paf08_front_12_source_poses.png',r)
    (ART/'PAF08_R1_ART_MANIFEST.json').write_text(
        json.dumps(m,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
    print('PAF08_R1_SOURCE_PASS original_rgba=true 36x3_poses=true noncommercial=true')
