#!/usr/bin/env python3
"""FIST05 V7: physical painted rockfall and directional contact bursts on an optimized atlas.
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
# V4 repair: crop to the actual painted silhouette before sizing; V3 was only
# scaling a 384px mostly transparent presentation canvas, making geology tiny.
GROUND=GROUND.crop(GROUND.getchannel('A').getbbox())
SPIRE=SPIRE.crop(SPIRE.getchannel('A').getbbox())
SHARD=SHARD.crop(SHARD.getchannel('A').getbbox())


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
    stamp(img,GROUND,128,194,100+118*t,24+20*t,alpha=.40+.50*t)
    # Subtle dark soil grit in contact with feet, not a glowing UI ring.
    d=ImageDraw.Draw(img,'RGBA')
    for i in range(int(12+24*t)):
        x=128+rng.gauss(0,24+38*t);y=207+rng.gauss(0,7+10*t)
        if not(2<x<254 and 2<y<252):continue
        w=rng.uniform(1.1,4.9)
        d.polygon([(x-w,y),(x+w*.5,y-w*.4),(x+w,y+w*.3)],fill=(101,78,68,rng.randint(40,103)))
    small_sparks(img,302+int(t*7),18+int(t*20),alpha=.42+.3*t)
    return img

# FIST05 V7: painted master fractures into SIX independently moving rock
# fragments during the final beats. The broken fragments are baked into the
# existing 12-pose 256px atlas; they add zero runtime textures or draw calls.
def _shattered_pillar(im, age, alpha):
    source=SPIRE.resize((180,220),Image.Resampling.LANCZOS)
    # These six irregular masks tessellate the original rock texture; detached
    # chunks therefore retain the SAME charcoal/ochre geology and luminance.
    areas=[
        [(0,0),(75,0),(91,36),(66,91),(14,103),(0,74)],
        [(75,0),(180,0),(180,82),(118,91),(91,36)],
        [(0,74),(14,103),(66,91),(103,143),(48,162),(0,140)],
        [(66,91),(118,91),(180,82),(180,151),(131,162),(103,143)],
        [(0,140),(48,162),(103,143),(117,220),(0,220)],
        [(103,143),(131,162),(180,151),(180,220),(117,220)]]
    drift=[(-40,-29, -25),(41,-48,22),(-62,-8,-31),(61,-10,35),
           (-28,10,-18),(37,8,19)]
    # Natural arc: fragment first moves outward and up, then gravity pulls it
    # toward the ground. Different direction/rotation for each fragment.
    for i,poly in enumerate(areas):
        mask=Image.new('L',source.size,0)
        ImageDraw.Draw(mask).polygon(poly,fill=255)
        mask=mask.filter(ImageFilter.GaussianBlur(.8))
        piece=source.copy()
        piece.putalpha(Image.fromarray(np.minimum(
            np.asarray(piece.getchannel('A'),dtype=np.uint8),
            np.asarray(mask,dtype=np.uint8)).astype(np.uint8),'L'))
        bbox=mask.getbbox()
        if bbox is None:continue
        piece=piece.crop(bbox)
        cx=(bbox[0]+bbox[2])*.5
        cy=(bbox[1]+bbox[3])*.5
        vx,vy,spin=drift[i]
        dx=vx*age+6*math.sin(age*5.8+i)
        dy=vy*age+61*age*age
        shrink=1.0-.11*age
        # Full pillar center at (137,141), footprint at y ~251.
        px=47+cx+dx
        py=31+cy+dy
        stamp(im,piece,px,py,piece.width*shrink,piece.height*shrink,
              rot=spin*age,alpha=alpha*(1.0-.16*age))

def _earthfall_dust(im, age, alpha, seed):
    # Dust is physically grounded, feathered and EARTH-COLORED. No circular
    # orange HUD ring or giant flat rectangular cloud covers the target.
    rng=random.Random(SEED+25000+seed)
    soft=layer()
    d=ImageDraw.Draw(soft,'RGBA')
    for i in range(18):
        x=rng.gauss(127,45+19*age)
        y=224+rng.gauss(0,5+5*age)
        rx=rng.uniform(5,14)*(0.65+age*.75)
        ry=rng.uniform(2,7)*(0.6+age*.75)
        if not 3<x<252:continue
        d.ellipse((x-rx,y-ry,x+rx,y+ry),
                  fill=(105+rng.randrange(22),80+rng.randrange(24),
                        70+rng.randrange(23),int(alpha*rng.randint(28,78))))
    im.alpha_composite(soft.filter(ImageFilter.GaussianBlur(6.0)))
    d=ImageDraw.Draw(im,'RGBA')
    for i in range(42):
        theta=rng.uniform(-math.pi,math.pi)
        x=128+rng.uniform(17,83)*math.cos(theta)*(0.65+age*.75)
        y=218-27*age+rng.uniform(0,28)*math.sin(theta)+23*age*age
        if not 4<x<251 or not 5<y<253:continue
        r=rng.uniform(.7,3.5)
        tone=rng.randint(80,155)
        d.polygon([(x-r,y),(x+r*.4,y-r),(x+r,y+r*.5)],
                  fill=(tone,round(tone*.72),round(tone*.57),
                        int(alpha*rng.randint(25,104))))

def eruption(k):
    t=k/11.0
    growth=min(1.0,t/.31) if t>0 else 0.0
    # Unlike V6: don't hold an unchanged pillar until it vanishes. After pose 6
    # it breaks into visible rotating pieces, arcs down, and becomes low dust.
    fall=1.0 if t<.55 else max(0.0,(1.0-t)/.45)**.32
    im=layer()
    stamp(im,GROUND,128,211,177+29*growth,34+17*growth,
          alpha=.44*fall)
    if growth>.05:
        if k<=6:
            stamp(im,SPIRE,137+3*math.sin(k*.63),177-36*growth,
                  145+35*growth,175+64*growth,
                  rot=2.5*math.sin(k*.52),alpha=fall*.97)
        else:
            age=(k-6.0)/5.0
            # Add low dust FIRST so the source-painted stones appear in front.
            _earthfall_dust(im,age,fall*.77,k)
            _shattered_pillar(im,age,fall)
        # Side fragments tumble and settle, they do not remain as static decals.
        decay=max(0.0,(k-6.0)/5.0)
        left_y=202-22*growth-21*decay+56*decay*decay
        right_y=201-16*growth-33*decay+59*decay*decay
        stamp(im,SHARD,72-10*growth-22*decay,left_y,
              90+22*growth,72+24*growth,rot=-18-22*decay,
              alpha=fall*.63*(1-.37*decay))
        stamp(im,SHARD,198+8*growth+23*decay,right_y,
              78+24*growth,66+19*growth,rot=22+29*decay,
              alpha=fall*.56*(1-.36*decay))
    # Ground pebbles and ember grit share this single pre-baked atlas frame.
    rng=random.Random(7023+k); d=ImageDraw.Draw(im,'RGBA')
    for j in range(35):
        ang=rng.uniform(-math.pi,math.pi)
        radius=rng.uniform(10,78)*(.4+growth*.88)
        x=133+math.cos(ang)*radius
        y=202+math.sin(ang)*radius*.43-15*growth*rng.random()
        if x<8 or x>248 or y<6 or y>252:continue
        p=rng.uniform(1,3.1)*(.8-.37*t)
        d.polygon([(x-p,y+.6*p),(x+.5*p,y-p),(x+p,y+.3*p)],
                  fill=(139,96,66,int(fall*rng.randint(27,116))))
    if k<8:
        small_sparks(im,650+k,35,ctr=(127,194-growth*28),
                     span=(123,90),alpha=fall*.69)
    return im

def contact(k):
    """Painterly directional magma absorption / impact, 8 independent frames.
    Visible at native target scale, never a generic perfect neon star.
    """
    t=k/7
    fall=max(0.0,(1-t)**.55)
    im=layer()
    rng=random.Random(SEED+9050+k)
    origin=(122.0,158.0)
    bloom=layer();db=ImageDraw.Draw(bloom,'RGBA')
    db.ellipse((origin[0]-30,origin[1]-22,origin[0]+30,origin[1]+22),fill=(255,162,66,int(137*fall)))
    halo=bloom.filter(ImageFilter.GaussianBlur(17))
    im.alpha_composite(halo)
    # Splintered blazing stone is the PRIMARY contact texture, composited with
    # directional flame wisps; not a full opaque explosion that hides the target.
    if t<.85:
        stamp(im,SHARD,135+21*t,152-20*t,118+39*t,89+26*t,
              rot=-19+31*t,alpha=fall*.83)
    # Organic torn flame wisps: curved painterly trails in the strike direction,
    # NO centered radial star or UI-style line spokes.
    glow=layer();sg=ImageDraw.Draw(glow,'RGBA')
    sharp=layer();d=ImageDraw.Draw(sharp,'RGBA')
    for j in range(7):
        x0=92+rng.uniform(-22,25)
        y0=139+rng.uniform(-27,31)
        dx=rng.uniform(39,83+32*t)
        dy=rng.uniform(-47,35)
        phase=rng.uniform(-2.4,2.4)
        pts=[]
        for h in range(15):
            q=h/14
            x=x0+dx*q + math.sin(q*7+phase)*5*q
            y=y0+dy*q + math.sin(math.pi*q)*rng.uniform(-15,15) + 3*math.sin(q*9+phase)
            pts.append((x,y))
        sg.line(pts,fill=(242,126,53,int(131*fall)),width=rng.randint(8,13),joint='curve')
        d.line(pts[2:],fill=(255,rng.randint(169,224),rng.randint(100,157),int(171*fall)),
               width=rng.randint(2,4),joint='curve')
    # Detached cinders and stone slivers make it a material impact, not a neon icon.
    for j in range(28):
        x=rng.uniform(62,203);y=rng.uniform(109,212)
        if (x-122)**2/10000+(y-153)**2/3500>1.4:continue
        radius=rng.uniform(.8,3.1)*(1-.42*t)
        d.polygon([(x-radius,y),(x+radius*.7,y-radius),(x+radius,y+radius*.2)],
            fill=(255,rng.randint(133,219),rng.randint(75,136),int(165*fall)))
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(7)))
    im.alpha_composite(sharp)
    # Brief incandescent contact core, not a constant solid white orb.
    if k<4:
        dot=layer(); ImageDraw.Draw(dot,'RGBA').ellipse((110,144,138,164),
            fill=(255,239,177,int(117*fall)))
        im.alpha_composite(dot.filter(ImageFilter.GaussianBlur(6)))
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
    print('FIST05_OPTIMIZED_V7_PASS atlas_frames=24 textures=3 raw_rgba_bytes=%d no_rig=true'%memory)
