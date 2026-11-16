#!/usr/bin/env python3
"""POI10 R2 first-party ImageGen-painted 2D alpha flipbooks; NO commercial pixels or rig.

Source masters: 3 independently cropped first-party TMB image artworks (separate from R1).
Status mark: ONE common readable badge, not a six-second full-size VFX loop.
"""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageEnhance
import hashlib, math

ROOT=Path(__file__).resolve().parents[2]
ASSETS=ROOT/'godot/labs/combat_lab/poison10/r2_remake/assets'
MASTER=ASSETS/'master'
SHARED=ROOT/'godot/labs/combat_lab/shared_poison_status/assets'
ASSETS.mkdir(parents=True,exist_ok=True); SHARED.mkdir(parents=True,exist_ok=True)
COLS=4

def master(filename):
    im=Image.open(MASTER/filename).convert('RGBA')
    assert im.getchannel('A').getextrema()[0]==0,filename
    return im

def scale_center(src,cell,scale,xy=(0,0),turn=0,alpha=1):
    w,h=cell; out=Image.new('RGBA',cell)
    s=min(w/src.width,h/src.height)*scale
    target=(max(1,int(src.width*s)),max(1,int(src.height*s)))
    im=src.resize(target,Image.Resampling.LANCZOS)
    if turn:im=im.rotate(turn,resample=Image.Resampling.BICUBIC,expand=True)
    if alpha<1:im.putalpha(im.getchannel('A').point(lambda a:int(a*alpha)))
    x=(w-im.width)//2+int(xy[0]);y=(h-im.height)//2+int(xy[1]);out.alpha_composite(im,(x,y))
    return out

def fading_edges(img,margin=4):
    w,h=img.size;am=img.getchannel('A');m=Image.new('L',(w,h),255);d=ImageDraw.Draw(m)
    for i in range(margin):
        val=int(255*(i+1)/(margin+1))
        d.rectangle((i,0,i,h-1),fill=val)
        d.rectangle((w-1-i,0,w-1-i,h-1),fill=val)
        d.rectangle((0,i,w-1,i),fill=val)
        d.rectangle((0,h-1-i,w-1,h-1-i),fill=val)
    d.rectangle((0,0,w-1,0),fill=0)
    d.rectangle((0,h-1,w-1,h-1),fill=0)
    d.rectangle((0,0,0,h-1),fill=0)
    d.rectangle((w-1,0,w-1,h-1),fill=0)
    img.putalpha(ImageChops.multiply(am,m))
    return img

def layered(base,ink,opacity=1):
    if opacity<1:
        ink=ink.copy();ink.putalpha(ink.getchannel('A').point(lambda a:int(a*opacity)))
    base.alpha_composite(ink)

def atlas(filename,frames,cell):
    w,h=cell;full=Image.new('RGBA',(4*w,math.ceil(len(frames)/4)*h))
    signatures=set()
    for i,im in enumerate(frames):
        assert im.size==cell,(filename,i,im.size)
        a=im.getchannel('A')
        assert a.getbbox(),(filename,i,'EMPTY')
        for b in [(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)]:
            assert a.crop(b).getextrema()[1]==0,(filename,i,'ALPHA_BLEED')
        sig=hashlib.sha256(im.tobytes()).hexdigest()
        assert sig not in signatures,(filename,i,'DUPLICATE')
        signatures.add(sig)
        full.alpha_composite(im,(i%4*w,i//4*h))
    path=ASSETS/filename
    full.save(path,optimize=True,compress_level=9)
    print('VFX_POI10_R2_ATLAS',filename,full.size,'frames',len(frames),'bytes',path.stat().st_size)
    return full

src_charge=master('poi10_charge_master.webp')
src_bloom=master('poi10_bloom_master.webp')
src_contact=master('poi10_contact_master.webp')

# CASTER CHARGE: painted flowing petals converge around a small hot heart, not HUD rings.
charge=[]
for i in range(10):
    p=i/9
    cell=(192,192)
    im=Image.new('RGBA',cell)
    # two independent expressive source-pixel wisps, approaching the same focal point
    left=src_charge.crop((15,66,305,510))
    right=src_charge.crop((127,80,480,545))
    layered(im,scale_center(left,cell,.40+.29*p,(-23+19*p,11-8*p),8-13*p,.45+.38*p))
    layered(im,scale_center(right,cell,.42+.28*p,(20-15*p,-10+8*p),-9+13*p,.35+.45*p))
    # tapered, luminous central seed is source painted pixels, not procedural circles
    seed=src_charge.crop((115,275,290,470))
    layered(im,scale_center(seed,cell,.11+.19*p,(4,7),0,.28+.70*p))
    charge.append(fading_edges(im))

# ONE MAIN BLOOM: living unfurling painted toxin flower. Independent source sections shift
# relative to centre, producing real multi-part pose evolution rather than 12 identical scales.
bloom=[]
for i in range(12):
    p=i/11
    # acceleration/hold/fade: 0-3 compact opening; 4-6 bright dominant; 7-11 ribbons dissipate
    envelope=[.25,.40,.56,.78,.95,1.00,1.08,1.10,1.04,1.06,1.12,1.14][i]
    opacity=[.40,.57,.75,.90,1,1,1,.86,.69,.49,.28,.11][i]
    cell=(384,256)
    im=Image.new('RGBA',cell)
    # broad 3-axis painterly ribbons from actual central painted master
    upper=src_bloom.crop((100,0,1020,390))
    lower=src_bloom.crop((80,300,1060,724))
    layered(im,scale_center(lower,cell,envelope*.89,(0,int(9+9*p)),turn=-3+6*math.sin(p*3),alpha=opacity*.72))
    layered(im,scale_center(upper,cell,envelope*.94,(0,int(-8-4*p)),turn=3-5*math.sin(p*4.2),alpha=opacity*.83))
    # Radial *organic* depth: a source-painted petal cluster tilts into the top/bottom, not a perfect geometric ring.
    layered(im,scale_center(src_bloom,cell,envelope*.65,(0,-1),turn=48+5*math.sin(p*8),alpha=opacity*.38))
    layered(im,scale_center(src_bloom,cell,envelope*.82,(0,0),turn=2.0*math.sin(p*9),alpha=opacity*.78))
    bloom.append(fading_edges(im))

# CONTACT: a single slash-like burst against a moving target's chest, small and high-contrast.
contact=[]
for i in range(8):
    p=i/7;cell=(192,160)
    im=Image.new('RGBA',cell)
    power=[.60,.91,1.,.92,.77,.56,.36,.15][i]
    extent=[.44,.66,.80,.91,.98,1.0,1.08,1.12][i]
    layered(im,scale_center(src_contact,cell,extent,(0,0),turn=-4+10*p,alpha=power))
    # Never paste a rectangular crop of the glowing center; it leaves a visible hard dark box.
    contact.append(fading_edges(im))

out=[atlas('poison10_r2_charge_10.png',charge,(192,192)),
     atlas('poison10_r2_bloom_12.png',bloom,(384,256)),
     atlas('poison10_r2_contact_08.png',contact,(192,160))]

# The shared poisoned badge is a simple stable UI/overhead MARK: not a second attack VFX.
# A single icon is reused for POI08/POI09/POI10 whenever *authoritative* poisoned state exists.
icon=Image.new('RGBA',(64,64))
paint=ImageDraw.Draw(icon,'RGBA')
paint.ellipse((5,7,59,61),fill=(32,13,62,210),outline=(108,220,151,255),width=3)
paint.polygon([(32,12),(17,35),(20,47),(32,55),(45,43),(47,34)],fill=(73,219,149,243))
paint.polygon([(32,16),(26,33),(32,29),(39,35)],fill=(237,255,216,246))
paint.ellipse((41,16,46,21),fill=(232,255,230,220))
icon=fading_edges(icon,3)
icon.save(SHARED/'poisoned_badge_64.png',optimize=True)
raw=sum(im.width*im.height*4 for im in out)+64*64*4
print('VFX_POI10_R2_RAW_RGBA8_BYTES',raw,'MiB',round(raw/1048576,3))
assert raw < 8*1048576,('POI10_R2_TEXTURE_BUDGET_FAIL',raw)