#!/usr/bin/env python3
"""FIST05 V3: original-paint seismic VFX from first-party raster masters.
Sprite-first 24 RGBA poses (4 charge + 12 eruption + 8 contact) on two
shared sheets + one original contiguous crack-path strip, no tiled decals.
No gameplay state, actor animation, rig or copied third-party artwork.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random, hashlib, numpy as np

R=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/fist05'
A=R/'assets'; O=A/'optimized_v3'; O.mkdir(parents=True,exist_ok=True)
CELL=256
GROUND=Image.open(A/'seismic_ground_master.webp').convert('RGBA')
SPIRE=Image.open(A/'spires_master.webp').convert('RGBA')
SHARD=Image.open(A/'molten_shard_master.webp').convert('RGBA')
assert GROUND.size==SPIRE.size==SHARD.size==(384,384)
SEED=2026111503

def clean_painted_source(src,poly):
    # Mask the opaque rectangular presentation-art crop outside actual geology.
    mask=Image.new('L',src.size,0)
    ImageDraw.Draw(mask).polygon(poly,fill=255)
    mask=mask.filter(ImageFilter.GaussianBlur(2.4))
    orig=np.asarray(src).copy(); gate=np.asarray(mask).astype(np.float32)/255
    orig[:,:,3]=(orig[:,:,3].astype(np.float32)*gate).clip(0,255).astype(np.uint8)
    return Image.fromarray(orig,'RGBA')

SPIRE=clean_painted_source(SPIRE,[
    (185,24),(223,28),(242,56),(259,76),(270,118),(287,157),
    (288,202),(258,240),(273,267),(259,319),(216,361),(165,348),
    (111,326),(98,298),(110,252),(128,210),(115,177),(124,119),
    (144,72),(164,45)])
SHARD=clean_painted_source(SHARD,[
    (37,294),(46,252),(81,209),(115,171),(151,133),(194,96),
    (248,76),(292,87),(326,117),(340,155),(336,198),(303,247),
    (275,276),(222,300),(171,317),(111,323),(64,323)])


def layer():return Image.new('RGBA',(CELL,CELL),(0,0,0,0))

def stamp(dst,src,x,y,width,height,rot=0,alpha=1.0):
    tex=src.copy().rotate(rot,Image.Resampling.BICUBIC,expand=True)
    tex=tex.resize((max(1,int(width)),max(1,int(height))),Image.Resampling.LANCZOS)
    if alpha<.999:
        a=tex.getchannel('A').point(lambda n:int(n*max(0,alpha)))
        tex.putalpha(a)
    offset=(int(x-tex.width*.5),int(y-tex.height*.5))
    dst.paste(tex,offset,tex)

def small_sparks(img,seed,count,ctr=(128,193),span=(72,36),alpha=1.0):
    rng=random.Random(SEED+seed);d=ImageDraw.Draw(img,'RGBA')
    for j in range(count):
        x=rng.gauss(ctr[0],span[0]*.57);y=rng.gauss(ctr[1],span[1]*.57)
        if not (3<x<CELL-3 and 3<y<CELL-3):continue
        r=rng.uniform(.8,2.7)
        col=(rng.randint(182,252),rng.randint(117,200),rng.randint(54,108),int(rng.randint(44,144)*alpha))
        d.ellipse((x-r,y-r*.6,x+r,y+r*.6),fill=col)

def pressure(t):
    img=layer();rng=random.Random(7071+int(100*t))
    stamp(img,GROUND,128,194,100+118*t,46+32*t,alpha=.40+.50*t)
    # Subtle dark soil grit in contact with feet, not a glowing UI ring.
    d=ImageDraw.Draw(img,'RGBA')
    for i in range(int(12+24*t)):
        x=128+rng.gauss(0,24+38*t);y=207+rng.gauss(0,7+10*t)
        if not(2<x<254 and 2<y<252):continue
        w=rng.uniform(1.1,4.9)
        d.polygon([(x-w,y),(x+w*.5,y-w*.4),(x+w,y+w*.3)],fill=(101,78,68,rng.randint(40,103)))
    small_sparks(img,302+int(t*7),18+int(t*20),alpha=.42+.3*t)
    return img

def eruption(k):
    t=k/11
    growth=min(1.0,t/.31) if t>0 else 0.0
    # Fast upward impulse, brief hold, then irregular earthfall: no endless rising pillars.
    fall=1.0 if t<.59 else max(0.0,(1.0-t)/.41)
    im=layer()
    # Painted ground is only a small basal patch, not a reused 500px orange carpet.
    stamp(im,GROUND,128,206,200+13*growth,77+9*growth,alpha=.49*fall)
    if growth>.05:
        # Primary geological silhouette reads at 1x: single tall erupting cliff.
        stamp(im,SPIRE,137+3*math.sin(k*.63),183-40*growth,
              107+43*growth,116+56*growth,rot=2.5*math.sin(k*.52),alpha=fall*.97)
        # Two subordinate painted fragments, deliberately asymmetric.
        stamp(im,SHARD,70-9*growth,201-14*growth,75+18*growth,66+16*growth,
              rot=-18+2*math.sin(k),alpha=fall*.77)
        stamp(im,SHARD,198+8*growth,204-7*growth,56+15*growth,56+10*growth,
              rot=22+3*math.cos(k*.66),alpha=fall*.67)
    rng=random.Random(7023+k); d=ImageDraw.Draw(im,'RGBA')
    # Debris fragments share the same atlas frame; no extra texture/draw call.
    for j in range(42):
        ang=rng.uniform(-math.pi,math.pi);radius=rng.uniform(10,78)*(.4+growth*.9)
        x=133+math.cos(ang)*radius;y=199+math.sin(ang)*radius*.54-25*growth*rng.random()
        if x<8 or x>248 or y<6 or y>252:continue
        p=rng.uniform(1,3.1)*(.8-.37*t)
        d.polygon([(x-p,y+.6*p),(x+.5*p,y-p),(x+p,y+.3*p)],fill=(163,101,63,int(fall*rng.randint(27,131))))
    small_sparks(im,650+k,26,ctr=(127,194-growth*28),span=(125,105),alpha=fall*.65)
    return im

def contact(k):
    t=k/7
    fall=max(0.0,(1-t)**.62)
    im=layer();d=ImageDraw.Draw(im,'RGBA');rng=random.Random(9050+k)
    # Distinct directional impact: stone and hot sparks burst from target's torso.
    if t<.73:
        stamp(im,SHARD,138+20*t,151-22*t,94+36*t,64+22*t,rot=-17+31*t,alpha=fall*.65)
    for j in range(42):
        ang=rng.uniform(-math.pi,math.pi)
        r=rng.uniform(13,53+50*t)
        x=130+math.cos(ang)*r;y=154+math.sin(ang)*r*.72
        if not(5<x<251 and 5<y<251):continue
        s=rng.uniform(1,3.5)*(1-.44*t)
        color=(rng.randint(191,255),rng.randint(130,215),rng.randint(63,110),int(fall*rng.randint(75,198)))
        d.polygon([(x-2*s,y),(x+s,y-s*.7),(x+2*s,y+s*.1)],fill=color)
    return im

def crack_strip():
    W,H=1024,256
    im=Image.new('RGBA',(W,H),(0,0,0,0));seed=random.Random(SEED+9933)
    path=[(28,139)]
    for x in range(50,1002,17):
        y=139+8*math.sin(x*.025)+5*math.sin(x*.087)+seed.uniform(-7.0,7.0)
        path.append((x,y))
    # This is one continuous fractured earth seam, painted in layered umber and magma.
    halo=Image.new('RGBA',(W,H),(0,0,0,0));d=ImageDraw.Draw(halo,'RGBA')
    d.line(path,fill=(231,111,41,83),width=21,joint='curve')
    halo=halo.filter(ImageFilter.GaussianBlur(11))
    im.alpha_composite(halo)
    d=ImageDraw.Draw(im,'RGBA')
    d.line(path,fill=(52,30,29,188),width=14,joint='curve')
    d.line(path,fill=(137,63,42,186),width=8,joint='curve')
    d.line(path,fill=(241,119,49,200),width=4,joint='curve')
    d.line(path,fill=(255,202,106,184),width=2,joint='curve')
    for j in range(19):
        at=seed.randrange(3,len(path)-3)
        x,y=path[at]
        side=1 if seed.random()>.5 else -1
        length=seed.uniform(27,84)
        branch=[(x,y),(x+seed.uniform(10,22),y+side*seed.uniform(9,18)),(x+length,y+side*seed.uniform(19,45))]
        d.line(branch,fill=(64,35,32,135),width=7,joint='curve')
        d.line(branch,fill=(216,101,53,141),width=3,joint='curve')
        if j%3==0:d.line(branch[1:],fill=(255,209,121,146),width=1)
    # A few original paint fragments scattered along the crack: texture, not repeated rock tiles.
    for j in range(110):
        x=seed.uniform(20,W-30)
        yy=139+8*math.sin(x*.025)+5*math.sin(x*.087)
        y=yy+seed.uniform(-26,31)
        r=seed.uniform(.6,3.1)
        d.polygon([(x-r,y),(x+r,y-r*.3),(x+r*.6,y+r*.7)],fill=(125,83,57,seed.randrange(20,125)))
    return im

def atlas(items,cols,name):
    w=cols*CELL; h=((len(items)+cols-1)//cols)*CELL
    out=Image.new('RGBA',(w,h),(0,0,0,0))
    for i,frame in enumerate(items):out.alpha_composite(frame,(CELL*(i%cols),CELL*(i//cols)))
    target=O/name;out.save(target,optimize=True)
    print('FIST05_V3_TEXTURE',name,'px',out.size,'frames',len(items),'sha',hashlib.sha256(target.read_bytes()).hexdigest())

if __name__=='__main__':
    atlas([pressure(i/3) for i in range(4)]+[eruption(i) for i in range(12)],4,'seismic_main.png')
    atlas([contact(i) for i in range(8)],4,'seismic_hit.png')
    strip=crack_strip();strip.save(O/'seismic_path.png',optimize=True)
    for fn in ['seismic_main.png','seismic_hit.png','seismic_path.png']:
        im=Image.open(O/fn)
        assert im.mode=='RGBA' and im.getpixel((0,0))[3]==0
    memory=sum(Image.open(O/fn).width*Image.open(O/fn).height*4 for fn in ['seismic_main.png','seismic_hit.png','seismic_path.png'])
    assert memory==7340032, memory
    print('FIST05_OPTIMIZED_V3_PASS atlas_frames=24 textures=3 raw_rgba_bytes=%d no_rig=true'%memory)
