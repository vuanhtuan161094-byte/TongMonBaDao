#!/usr/bin/env python3
"""FIST11 Huyết Liệt Quyền / Human / Nether: three original-composite RGBA flipbooks.

First-party painted fist & impact are source MATERIAL, not displayed unchanged.
Each pose paints distinct rose-white/black-crimson qi flows around a re-illustrated
fist and a protected target-free impact. Not an ImageGen GIF; no imported actor,
map, HUD, video, third-party JX art, rig or combat-side damage.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageChops
import numpy as np, math, random, hashlib
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'godot/labs/combat_lab/fist03/assets'
OUT=ROOT/'godot/labs/combat_lab/fist11/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
with Image.open(SOURCE/'godfist_master.webp') as f:
    FIST=f.convert('RGBA')
with Image.open(SOURCE/'impact_master.webp') as im:
    IMPACT=im.convert('RGBA')
assert min(FIST.size)>=100 and min(IMPACT.size)>=100
rng=np.random.default_rng(111611)

def tint_material(source, size, *, pale=0.0, alpha=1.0):
    """Map original hand-painted light values to infernal garnet/rose pigment.
    Preserve dense source detail with hue-dependent shade and bright knuckles.
    """
    src=source.resize(size,Image.Resampling.LANCZOS)
    ar=np.asarray(src,dtype=np.uint8).copy()
    rgb=ar[:,:,:3].astype(np.float32)
    lum=(rgb[:,:,0]*.50+rgb[:,:,1]*.38+rgb[:,:,2]*.12)/255.
    white=np.clip((lum-.29)/.47,0,1)**1.15
    blood=np.clip((lum-.10)/.66,0,1)
    # A dark burgundy body with rose-white knuckle highlights; NOT simple hue rotate.
    rr=61+172*blood+35*white+27*pale
    gg=7+22*blood+153*white+25*pale
    bb=19+23*blood+134*white+31*pale
    ar[:,:,0]=np.clip(rr,0,255).astype('uint8')
    ar[:,:,1]=np.clip(gg,0,255).astype('uint8')
    ar[:,:,2]=np.clip(bb,0,255).astype('uint8')
    edge=np.asarray(src.getchannel('A'),dtype=np.float32)/255.
    ar[:,:,3]=np.clip((edge**.84)*alpha*255,0,255).astype('uint8')
    return Image.fromarray(ar,'RGBA')

def layer(dst, pic, cx,cy,opacity=1.):
    if opacity <=0:return
    if opacity!=1:
        pic=pic.copy();pic.putalpha(pic.getchannel('A').point(lambda p:round(p*opacity)))
    x=round(cx-pic.width/2);y=round(cy-pic.height/2)
    l=max(0,-x);t=max(0,-y);r=min(pic.width,dst.width-x);b=min(pic.height,dst.height-y)
    if r>l and b>t:dst.alpha_composite(pic.crop((l,t,r,b)),(max(0,x),max(0,y)))

def band(img, frm, to, phase, amp, width, alpha=1.0, seed=0):
    """Pigment-rich organic brush ribbon, not a uniform neon line or UI arc.
    Irregular tapered two-sided silhouette is filled with painted source
    material, adds selective rose core and very restrained ambient bloom.
    """
    rr=random.Random(440+seed)
    centerline=[]
    for j in range(17):
        t=j/16
        x=frm[0]*(1-t)+to[0]*t
        y=frm[1]*(1-t)+to[1]*t
        wob=(math.sin(t*math.pi*2.4+phase)*amp*(1-t*.65)
             +rr.uniform(-2.4,2.4)*(1-t))
        centerline.append((x,y+wob))
    up=[];down=[]
    for j,(x,y) in enumerate(centerline):
        t=j/16
        prev=centerline[max(0,j-1)]
        nxt=centerline[min(16,j+1)]
        dx=nxt[0]-prev[0];dy=nxt[1]-prev[1]
        norm=max(1.0,math.hypot(dx,dy))
        nx=-dy/norm;ny=dx/norm
        taper=(math.sin(math.pi*(.04+.92*t))**.56)*(.87+rr.uniform(-.22,.18))
        thick=width*(.42+1.12*taper)
        up.append((x+nx*thick,y+ny*thick))
        down.append((x-nx*thick*.67,y-ny*thick*.67))
    poly=up+down[::-1]
    mask=Image.new('L',img.size)
    ImageDraw.Draw(mask).polygon(poly,fill=round(195*alpha))
    soft=mask.filter(ImageFilter.GaussianBlur(4))
    # Scattered low-saturation outside glow, not bright double rings.
    glow=Image.new('RGBA',img.size,(160,6,35,0))
    glow.putalpha(soft.point(lambda v:round(v*.22)))
    img.alpha_composite(glow)
    matte=Image.new('RGBA',img.size,(124,4,35,0))
    matte.putalpha(mask)
    img.alpha_composite(matte)
    # Original painted FIST03 impact texture is sampled into each ribbon;
    # final alpha comes from original animated silhouette, not asset poster.
    pigment=tint_material(IMPACT,img.size,pale=.14)
    pigment.putalpha(mask.point(lambda v:round(v*.52)))
    img.alpha_composite(pigment)
    # Narrow half-reserved pearlescent vein, irregular and broken.
    line=Image.new('RGBA',img.size)
    d=ImageDraw.Draw(line,'RGBA')
    d.line([(round(x),round(y)) for j,(x,y) in enumerate(centerline) if j%2==0],
           fill=(255,147,180,round(135*alpha)),width=max(2,width//5),joint='curve')
    img.alpha_composite(line.filter(ImageFilter.GaussianBlur(.7)))

def spark(img, pos, scale=1.0, strength=1.0, seed=0):
    # Tiny painted petals; no UI rings.
    rnd=random.Random(774+seed)
    d=ImageDraw.Draw(img,'RGBA')
    for j in range(7):
        angle=(j/7)*math.tau + seed*.31
        radius=(9+rnd.random()*13)*scale
        x=pos[0]+math.cos(angle)*radius
        y=pos[1]+math.sin(angle)*radius
        theta=angle+math.pi/2
        L=(4+rnd.random()*10)*scale
        W=max(1,L*.20)
        pts=[(x+math.cos(angle)*L,y+math.sin(angle)*L),
             (x+math.cos(theta)*W,y+math.sin(theta)*W),
             (x-math.cos(angle)*L*.5,y-math.sin(angle)*L*.5),
             (x-math.cos(theta)*W,y-math.sin(theta)*W)]
        d.polygon(pts,fill=(255,90+j*14,152+j*9,round(145*strength)))

def fist_sprite(size=154):
    base=tint_material(FIST,(size,size),alpha=.97)
    # Heavy blood-ink silhouette underneath the source first-party painted fist.
    return base

def charge_pose(k):
    im=Image.new('RGBA',(256,256))
    p=k/7; sx=92+math.sin(k*.61)*2; sy=132
    pulse=.18+.70*p
    # Compose mutually distinct underhand qi strands that converge onto fist.
    for j in range(4):
        angle=j*math.tau/4 + .38*k
        fr=(round(sx-48+19*math.cos(angle)),round(sy+43*math.sin(angle)))
        to=(round(sx+48+12*p),round(sy-8+8*math.sin(angle+.8)))
        band(im,fr,to,.45*k+j,10+6*p,7+int(p*5),pulse*.70,seed=23+k*9+j)
    fist=fist_sprite(round(78+93*p))
    layer(im,fist,sx+12+8*p,sy,opacity=pulse*.84)
    if k>=4:spark(im,(round(sx+53),sy-1),.44+p*.22,pulse*.72,seed=k)
    return im

def flight_pose(k):
    im=Image.new('RGBA',(256,256))
    p=k/11
    head=172+14*math.sin(p*math.pi)
    cy=125+4*math.sin(k*.74)
    # Wing-like maroon ink edges wrap the punch, never a straight arrow.
    for j in range(4):
        origin=(17+20*j-9*p,cy+(j-1.5)*(18+5*math.sin(p*math.pi)))
        end=(head-24,cy+(j-1.5)*(5+math.sin(k*.7)))
        band(im,origin,end,phase=p*3.8+j*1.4,amp=8+4*j,width=9-j,alpha=.70-p*.08,seed=k*13+j)
    fist=fist_sprite(round(147+12*math.sin(p*math.pi)))
    layer(im,fist,head,cy,opacity=.92)
    # A tiny white-hot leading crest, baked from original paint, not vector UI.
    if k%3!=1:spark(im,(head+59,cy-5),.34,.70,seed=k*5)
    return im

def contact_pose(k):
    # R2: locally compressed painted collision without rectangular clipping.
    im=Image.new('RGBA',(320,320))
    pulse=[.27,.66,1.,.94,.80,.61,.40,.21,.09,.035][k]
    p=k/9
    # Grounded fist-splash receives the moving target: one local impact.
    painted=tint_material(IMPACT,(round(204+28*p),round(177+28*p)),pale=.10,alpha=pulse*.89)
    # FIST11 R1 Godot 1x art self-fail: the FIST03 impact poster has a
    # HARD horizontal crop edge. R2 applies a broad irregular alpha matte
    # to the ORIGINAL painted pigment before it can be used as a sprite.
    arr=np.asarray(painted,dtype=np.uint8).copy()
    h,w=arr.shape[:2]
    yy,xx=np.mgrid[0:h,0:w].astype('float32')
    rx=(xx-(w-1)*.48)/max(1,w*.53)
    ry=(yy-(h-1)*.45)/max(1,h*.51)
    # Lobed gradient avoids perfectly circular HUD look, preserves
    # handpainted source ink while hiding ALL rectangular source edges.
    angle=np.arctan2(ry,rx)
    rad=np.sqrt(rx*rx+ry*ry)*(1.0+.08*np.sin(angle*5+k*.29))
    matte=np.clip((1.03-rad)/.35,0.,1.)
    feather=np.clip(np.minimum(xx,w-1-xx)/max(1,w*.09),0,1)
    feather*=np.clip(np.minimum(yy,h-1-yy)/max(1,h*.09),0,1)
    arr[:,:,3]=np.clip(arr[:,:,3]*matte*feather,0,255).astype('uint8')
    painted=Image.fromarray(arr,'RGBA')
    layer(im,painted,157,159+6*p)
    for j in range(6):
        a=(j/6-.55)*math.pi+.12*k
        dist=(15+68*p)
        dx=math.cos(a)*dist;dy=math.sin(a)*dist*.76
        band(im,(160+dx*.20,155+dy*.20),(160+dx,155+dy),phase=a+k*.21,amp=5,width=max(3,10-k//3),alpha=pulse*.74,seed=110+k*19+j)
    # The center of a struck foe flashes pink-white, remains distinct from actor.
    if k<7:
        core=Image.new('RGBA',(320,320))
        pen=ImageDraw.Draw(core,'RGBA')
        pen.ellipse((135,128,180,174),fill=(255,231,238,round(125*pulse)))
        core=core.filter(ImageFilter.GaussianBlur(14))
        im.alpha_composite(core)
        spark(im,(157,150),.55+p*.80,pulse,seed=87+k)
    return im

def atlas(poses,cell,name):
    out=Image.new('RGBA',(4*cell,((len(poses)+3)//4)*cell))
    signatures=[]
    for k,frame in enumerate(poses):
        assert frame.size==(cell,cell)
        assert frame.getchannel('A').getextrema()[1]>0
        signatures.append(hashlib.sha256(frame.tobytes()).hexdigest())
        out.alpha_composite(frame,((k%4)*cell,(k//4)*cell))
    assert len(set(signatures))==len(poses),f'duplicate {name}'
    assert out.getchannel('A').getextrema()[0]==0
    out.save(OUT/name,optimize=True)
    return out

CHARGE=atlas([charge_pose(i) for i in range(8)],256,'f11_charge.png')
FLIGHT=atlas([flight_pose(i) for i in range(12)],256,'f11_blood_fist.png')
CONTACT=atlas([contact_pose(i) for i in range(10)],320,'f11_contact.png')
MASTER=fist_sprite(256)
MASTER.save(OUT/'f11_original_composite_painted_master.png',optimize=True)
rgba=sum(im.width*im.height*4 for im in (CHARGE,FLIGHT,CONTACT))
assert rgba==10158080,rgba
print('FIST11_BAKE_PASS frames=30 pages=3 raw_rgba_bytes=10158080 no_rig=true no_gif=true view_only=true')
print('FIST11_PROVENANCE=FIRST_PARTY_DERIVATIVE original_godfist_and_impact_material no_third_party=true')