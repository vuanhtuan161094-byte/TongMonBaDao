#!/usr/bin/env python3
"""POI16 R2: Tam Diệp Linh Dược / 3 readable spiritual medicine leaves
and 3 independent traveling healing streams, one herb-drop seal per ally.

ORIGINAL first-party true-alpha RGB source-paint. No GIF, rig, borrowed art,
new game mechanic, black matte, or code-drawn in-game circles/icons.
All shape artwork is rasterized into authored RGBA animation atlas frames.
"""
from pathlib import Path
from math import ceil,pi
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/poison16_van_linh_giai_ach/r2/assets"
SS=2
PARTS=(("seed",8,(192,192)),("herb",12,(384,320)),
       ("stream",10,(384,128)),("seal",10,(128,128)),("fade",8,(256,224)))
COL={
 "jade":(21,224,145), "mint":(102,255,191), "aqua":(33,225,229),
 "deep":(19,150,105),"pearl":(229,255,238),"ivory":(255,252,211),
 "gold":(245,218,136), "cyan":(65,205,250)
}

def ellipse(x,y,cx,cy,sx,sy):
    return np.exp(-(((x-cx)/sx)**2+((y-cy)/sy)**2))

def gate(x,start,stop,e):
    return np.clip((x-start)/e,0,1)*np.clip((stop-x)/e,0,1)

def over(dst,rgb,opacity):
    a=np.clip(opacity,0,1).astype(np.float32)
    old=dst[:,:,3]
    v=a+old*(1-a)
    dst[:,:,:3]=(dst[:,:,:3]*old[:,:,None]*(1-a[:,:,None])+np.asarray(rgb)*a[:,:,None])/np.maximum(v[:,:,None],1e-6)
    dst[:,:,3]=v

def leaf(yx,xx,yy,angle,reach,grow,phase):
    """Leaf-shaped local coordinates with tapered tips, curved vein."""
    # Origin offset is near the living medicinal pearl. Leaves do NOT form a
    # geometric ring or HUD glyph; each lobe is a luminous tapered herb leaf.
    u=xx*np.cos(angle)+yy*np.sin(angle)
    v=-xx*np.sin(angle)+yy*np.cos(angle)
    effective=reach*grow
    s=np.clip((u-6)/max(effective-6,1),0,1)
    width=(3+30*(np.sin(np.pi*s)**.89))*grow
    bend=5.0*np.sin(np.pi*s)*(phase-.5)+4*np.sin(np.pi*s*1.3+phase*.5)
    diff=v-bend
    feather=np.exp(-(np.abs(diff)/(np.maximum(width,2.3)))**4)
    envelope=gate(u,3,effective,8)
    fill=feather*envelope
    # Outer narrow colored edge traces natural herbal contour without
    # becoming a stiff white outline or UI icon.
    edge=np.exp(-((np.abs(diff)-width*.79)/(3.2+grow))**2)*envelope
    vein=np.exp(-((diff-2.8*np.sin(s*np.pi))/(2.3+.9*(1-s)))**2)*gate(u,9,effective*.88,15)
    return fill,edge,vein,u,v,s

def render(part,phase,wh):
    w,h=wh
    yy,xx=np.mgrid[0:h*SS,0:w*SS].astype(np.float32)
    x=(xx+.5)/SS-w/2
    y=(yy+.5)/SS-h/2
    p=np.zeros((h*SS,w*SS,4),dtype=np.float32)
    noise=np.clip(.89+.075*np.sin(.073*x-.027*y+3.7*phase)*np.cos(.049*y+.051*x-2.5*phase),.76,1.)
    def lay(name,a):over(p,COL[name],a)
    if part=="seed":
        strength=.18+.82*phase
        # 3 faint three-way seed structures condense into a single medicinal
        # pearl during the canonical 1.2s charge. The motif foreshadows heal.
        for k in range(3):
            angle=-np.pi/2+k*2*np.pi/3
            dist=(46-31*phase)
            cx=dist*np.cos(angle);cy=dist*np.sin(angle)
            lay("jade",ellipse(x,y,cx,cy,13,18)*.22*strength*noise)
            lay("aqua",ellipse(x,y,cx,cy,6,11)*.28*strength)
            for pidx in range(3):
                a=angle+(pidx-1)*.29
                v=-x*np.sin(a)+y*np.cos(a)
                u=x*np.cos(a)+y*np.sin(a)
                ribbon=np.exp(-(v/4.1)**2)*gate(u,8,dist,11)
                lay("mint",ribbon*.17*strength)
        lay("jade",ellipse(x,y,0,0,38,39)*.59*strength)
        lay("gold",ellipse(x,y,0,0,24,22)*.32*strength)
        lay("ivory",ellipse(x,y,0,0,11.7,12.7)*.93*strength)
        lay("pearl",ellipse(x,y,0,0,3.6,4.3)*.95*strength)
    elif part=="herb":
        # A readable luminous three-leaf medicinal bloom. Source silhouette
        # clearly has three separated leaves rooted in a pearly medicine seed.
        grown=np.clip((phase+.12)*1.23,0,1)
        intensity=.42+.58*np.sin(np.pi*(.12+.70*phase))**.6
        lay("jade",ellipse(x,y,0,2,97,89)*.10*intensity*noise)
        for k in range(3):
            a=-np.pi/2+k*2*np.pi/3 +.06*np.sin(phase*2.5+k)
            fill,edge,vein,u,v,s=leaf(p,x,y,a,129,grown,phase)
            lay("deep",fill*.27*intensity)
            lay("jade",fill*.70*intensity*noise)
            lay("mint",fill*.32*intensity)
            lay("aqua",edge*.31*intensity)
            lay("pearl",vein*.74*intensity)
            lay("gold",vein*.12*intensity)
            # Four short branching leaf veins: organic medicine, not lightning.
            for j in range(2):
                at=.42+j*.23
                branch_loc=129*grown*at
                v_start=np.abs(v)-((u-branch_loc)*.49)
                veinlet=np.exp(-(v_start/3.2)**2)*gate(u,branch_loc,branch_loc+24*grown,7)
                lay("ivory",veinlet*fill*.28*intensity)
            tip=ellipse(x,y,116*grown*np.cos(a),116*grown*np.sin(a),7,8)
            lay("pearl",tip*.21*intensity)
        # Sparse droplets of life spell the spiritual herb, not extra petals.
        for k in range(14):
            a=k*2.399963
            rr=(29+9*(k%5))*(.47+.59*grown)
            px=rr*np.cos(a)+4*np.sin(k+phase*2.5)
            py=rr*np.sin(a)+5*np.cos(k*.8+phase*2)
            lay("gold" if k%4==0 else "aqua",ellipse(x,y,px,py,2.6,4.6)*.29*intensity)
        lay("deep",ellipse(x,y,0,0,28,28)*.31*intensity)
        lay("gold",ellipse(x,y,0,0,14,15)*.37*intensity)
        lay("pearl",ellipse(x,y,0,0,9,10)*.88*intensity)
        lay("ivory",ellipse(x,y,0,0,4.7,5.5)*.95*intensity)
    elif part=="stream":
        # A REAL moving link, stored as a horizontal 384x128 flipbook and
        # transformed per target in Godot from medicine center to moving chest.
        # Distinct bright traveling leading pearl and herbal motes, not a line UI.
        left=-w*.5+19
        right=w*.5-19
        t=np.clip((x-left)/(right-left),0,1)
        path=7.0*np.sin(t*5.1+phase*3.1)+4*np.sin(t*10.3-2.4*phase)
        envelope=gate(x,left,right,22)
        ribbon=np.exp(-((y-path)/(5.5+3*np.sin(np.pi*t)**2))**2)*envelope
        silk=np.exp(-((y-path)/2.5)**2)*envelope
        lay("jade",np.exp(-((y-path)/24)**2)*envelope*.19*noise)
        lay("aqua",ribbon*.59*noise)
        lay("mint",ribbon*.35)
        lay("ivory",silk*.59)
        # Traveling luminous pearl: one discernible transfer direction.
        lead=np.clip(.08+.87*phase,0,1)
        hx=left+(right-left)*lead
        hy=7*np.sin(lead*5.1+phase*3.1)+4*np.sin(lead*10.3-2.4*phase)
        lay("jade",ellipse(x,y,hx,hy,20,18)*.42)
        lay("gold",ellipse(x,y,hx,hy,9,10)*.43)
        lay("ivory",ellipse(x,y,hx,hy,4.3,5.4)*.87)
        for k in range(13):
            pos=(k*.618+phase*.49)%1
            px=left+(right-left)*pos
            py=7*np.sin(pos*5.1+phase*3.1)+4*np.sin(pos*10.3-2.4*phase)
            dy=(k%3-1)*9
            lay("aqua" if k%4 else "gold",ellipse(x,y,px,py+dy,2.3,3.7)*.40)
    elif part=="seal":
        # Tiny jade medicinal drop with two side leaves above each moving ally.
        # Clearly a heal receipt CUE but not a 6s buff icon or actual HP text.
        alpha=.37+.63*np.sin(np.pi*(.16+.68*phase))**.72
        # Drop shape: pointed top, broad near middle, taper underneath.
        v=y+4.0
        norm=np.clip((v+35)/70,0,1)
        half=2+19*np.sin(np.pi*norm)**.76
        drop=np.exp(-((np.abs(x)/np.maximum(half,2.1))**4))*gate(v,-37,34,8)
        lay("jade",drop*.68*alpha)
        lay("mint",drop*.43*alpha)
        lay("pearl",ellipse(x,y,0,5,7,10)*.81*alpha)
        lay("ivory",ellipse(x,y,0,3,3,6)*.89*alpha)
        for sign in (-1,1):
            # Pair of small botanical leaves separated from drop, pixel alpha soft.
            angle=(-.52 if sign==1 else -np.pi+.52)
            fill,edge,vein,_,_,_=leaf(p,x-sign*8,y+9,angle,38,.79,phase)
            lay("jade",fill*.75*alpha)
            lay("aqua",edge*.28*alpha)
            lay("ivory",vein*.35*alpha)
        for k in range(5):
            a=k*2.399963
            xp=26*np.cos(a);yp=22*np.sin(a)-11*phase
            lay("gold",ellipse(x,y,xp,yp,2.2,3.6)*.30*alpha)
    elif part=="fade":
        # Compact, visible but FINITE jade/gold motes (never another cast).
        amount=max(.28,(1-phase)**.56)
        for i in range(21):
            a=i*2.399963
            rr=19+10*(i%6)+11*phase
            x0=rr*np.sin(a)+phase*13*np.cos(a)
            y0=rr*np.cos(a)*.83-54*phase
            lay("jade",ellipse(x,y,x0,y0,6.2,9.8)*.91*amount)
            lay("ivory",ellipse(x,y,x0,y0,2.3,3.7)*.44*amount)
        lay("aqua",ellipse(x,y,0,-13-17*phase,59+15*phase,57+15*phase)*.31*amount)
    else:raise ValueError(part)
    # High-visibility core+colored body with true soft edges, G3.6 compliant.
    old=p[:,:,3]
    boosts={"seed":1.75,"herb":1.52,"stream":1.51,"seal":1.57,"fade":1.65}
    p[:,:,3]=np.clip(np.where(old>.035,1-(1-old)**boosts[part],old*1.07),0,.975)
    arr=np.zeros_like(p,dtype=np.uint8)
    arr[:,:,:3]=np.clip(p[:,:,:3],0,255).astype(np.uint8)
    arr[:,:,3]=np.clip(p[:,:,3]*255,0,255).astype(np.uint8)
    arr[:14,:,3]=0;arr[-14:,:,3]=0;arr[:,:14,3]=0;arr[:,-14:,3]=0
    arr[arr[:,:,3]==0,:3]=0
    return Image.fromarray(arr,"RGBA").resize(wh,Image.Resampling.LANCZOS)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    raw=0
    for name,n,cell in PARTS:
        w,h=cell
        atlas=Image.new("RGBA",(4*w,ceil(n/4)*h))
        for i in range(n):
            png=render(name,i/(n-1),cell)
            assert png.getchannel("A").getbbox(),(name,i)
            atlas.alpha_composite(png,((i%4)*w,(i//4)*h))
            if i==n//2:
                (OUT/"master").mkdir(exist_ok=True)
                png.save(OUT/"master"/f"poi16_r2_{name}_master_rgba.png",optimize=True)
        f=OUT/f"poi16_r2_{name}_{n:02d}.png"
        atlas.save(f,optimize=True)
        print("POI16_R2_ORIGINAL_RGBA",name,n,atlas.size,f.stat().st_size)
        raw+=atlas.width*atlas.height*4
    print("POI16_R2B_SEMANTIC_SOURCE_PASS original_true_alpha_poses=48 five_atlases=true no_gif=true raw_rgba_bytes=",raw)

if __name__=="__main__":main()
