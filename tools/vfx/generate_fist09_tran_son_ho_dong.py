#!/usr/bin/env python3
"""FIST09 / Tran Son Ho Dong: first-party painterly mountain-slab ward.

This is an offline sprite painter. The primary material is original project
art from FIST05, NOT a JX/Source-VL asset. It is independently reframed into
a broad protective painted arch and two horizontal load-bearing stone shoulders; it is not an attack animation or damage.
No skeletal rig or runtime draw-line imitation of the primary image.
"""
from pathlib import Path
from PIL import Image, ImageFilter, ImageEnhance, ImageDraw
import base64, io
import math, random
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'godot/labs/combat_lab/fist05/assets/spires_master.webp'
OUT=ROOT/'godot/labs/combat_lab/fist09/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
with Image.open(SOURCE) as input_art:
    MATERIAL=input_art.convert('RGBA')
assert MATERIAL.width>=100 and MATERIAL.height>=100
# Second first-party source: original FIST07 illustrated golden energy.
# R4 uses its lower protective arch/filigree only, NOT the deity or face.
# Distinct FIST09 dedicated concept master remains a known art limitation.
PAINTED_SOURCE=ROOT/'godot/labs/combat_lab/fist07/assets/source/kim_cang_guardian_master_r5.webp.b64'
gold_bytes=base64.b64decode(''.join(PAINTED_SOURCE.read_text(encoding='ascii').split()),validate=True)
with Image.open(io.BytesIO(gold_bytes)) as source_image:
    GOLD=source_image.convert('RGBA')
assert GOLD.width>=700 and GOLD.height>=700
SEED=160911

def gold_fragment(box, size):
    """Original illustrated gold pixels; remove red edge-matte and box crop."""
    out=GOLD.crop(box).resize(size,Image.Resampling.LANCZOS)
    px=np.array(out,dtype=np.uint8)
    rgb=px[:,:,:3].astype(np.float32)
    r,g,b=rgb[:,:,0],rgb[:,:,1],rgb[:,:,2]
    keep=((r>100)&(g>72)&(g>.67*r)&(b<1.24*g)).astype(np.float32)
    light=np.maximum(r,g)
    alpha=px[:,:,3].astype(np.float32)*keep*np.clip((light-75.)/120.,0,1)
    h,w=alpha.shape
    xx=np.arange(w,dtype=float);yy=np.arange(h,dtype=float)
    # R4 Godot 1x review exposed hard rectangular matte boundaries.
    # R5 feathering happens on painted alpha, not as a runtime HUD shape.
    ex=np.clip(np.minimum(xx,w-1-xx)/max(1,w*.235),0,1)
    ey=np.clip(np.minimum(yy,h-1-yy)/max(1,h*.275),0,1)
    nx=(xx-(w-1)*.5)/max(1,w*.55)
    ny=(yy-(h-1)*.5)/max(1,h*.57)
    radial=np.sqrt(nx[None,:]**2+ny[:,None]**2)
    falloff=np.clip((1.10-radial)/.31,0,1)
    matte=np.sqrt(ex[None,:]*ey[:,None])*falloff
    px[:,:,3]=np.clip(alpha*matte,0,255).astype('uint8')
    return Image.fromarray(px,'RGBA')

ARCH=gold_fragment((52,323,720,660),(283,175))
CROWN=gold_fragment((205,571,558,702),(163,65))
FOOTSEAL=gold_fragment((19,616,748,711),(243,44))
LEFT_GOLD=gold_fragment((38,360,216,582),(51,90))
RIGHT_GOLD=gold_fragment((549,360,730,582),(51,90))
BLOCK_CURVE=gold_fragment((365,357,710,650),(145,160))
BLOCK_FLASH=gold_fragment((140,577,650,704),(178,69))


def paper(w):
    return Image.new('RGBA',(w,w),(0,0,0,0))

def scaled_alpha(src, factor):
    out=src.copy()
    out.putalpha(out.getchannel('A').point(lambda a:max(0,min(255,int(a*factor)))))
    return out

def layer_at(canvas, art, center):
    x=int(center[0]-art.width/2)
    y=int(center[1]-art.height/2)
    temp=Image.new('RGBA',canvas.size,(0,0,0,0))
    temp.paste(art,(x,y))
    canvas.alpha_composite(temp)

def stone(canvas, center, wh, angle, opacity, light=1.0, glow=0.65):
    """Original luminous basalt texture, physically irregular outer silhouette."""
    img=MATERIAL.resize((max(2,int(wh[0])),max(2,int(wh[1]))),Image.Resampling.LANCZOS)
    arr=np.array(img,dtype=np.uint8)
    rgb=arr[:,:,:3].astype('float32')
    warmth=np.maximum(rgb[:,:,0],rgb[:,:,1]*1.20)
    # high saturation and ivory-hot vein highlights, not dull brown rocks.
    hot=np.clip((warmth-124)/115,0,1)*light
    rgb[:,:,0]=np.clip(rgb[:,:,0]*.91+38*hot+14,0,255)
    rgb[:,:,1]=np.clip(rgb[:,:,1]*.92+53*hot+16,0,255)
    rgb[:,:,2]=np.clip(rgb[:,:,2]*.83+67*hot,0,255)
    arr[:,:,:3]=rgb.astype('uint8')
    img=Image.fromarray(arr,'RGBA').rotate(angle,Image.Resampling.BICUBIC,expand=True)
    if glow>0:
        # Illuminated *mineral veins* emit light, not the whole rock silhouette.
        # R1 was bad: full-source blur produced giant flat yellow capsules.
        pixels=np.asarray(img,dtype=np.uint8)
        luminosity=np.max(pixels[:,:,:3],axis=2).astype(np.float32)
        hot_filament=np.clip((luminosity-193.)/62.,0.,1.)
        source_alpha=pixels[:,:,3].astype(np.float32)/255.
        emitting=(255.*hot_filament*source_alpha).astype('uint8')
        veil=Image.fromarray(emitting,'L').filter(ImageFilter.GaussianBlur(7))
        haze=Image.new('RGBA',img.size,(255,229,162,0))
        haze.putalpha(veil.point(lambda a:int(a*opacity*glow*.78)))
        layer_at(canvas,haze,center)
    layer_at(canvas,scaled_alpha(img,opacity),center)

def strokes(canvas,seed,count,anchor,span,fade):
    """Supporting bright filaments only; painted stone is ALWAYS the hero art."""
    rand=random.Random(seed)
    pencil=Image.new('RGBA',canvas.size,(0,0,0,0))
    d=ImageDraw.Draw(pencil,'RGBA')
    for i in range(count):
        x=anchor[0]+rand.uniform(-span[0],span[0])
        y=anchor[1]+rand.uniform(-span[1],span[1])
        length=rand.uniform(4,14)
        d.line([(x-length*.5,y+length*.2),(x+length*.4,y-length*.45)],
               fill=(255,239,171,int(fade*rand.randint(38,135))),width=rand.randint(1,2))
    canvas.alpha_composite(pencil)

def ground_light(im,alpha,pivot):
    """No full HUD circle; only a broken compressed dust-line on the floor."""
    fx=Image.new('RGBA',im.size,(0,0,0,0))
    d=ImageDraw.Draw(fx,'RGBA')
    for a,b in ((-58,-10),(12,54)):
        y=pivot[1]
        d.arc((pivot[0]+a,y-7,pivot[0]+b,y+8),195,344,
              fill=(255,220,144,int(115*alpha)),width=2)
    im.alpha_composite(fx.filter(ImageFilter.GaussianBlur(.8)))

def cast_pose(k):
    """Eight progressive protection poses: broad shoulder masonry -> painted
    arch locks across the body -> short luminous release -> retraction.
    No three upright stone spikes. Cast is separate from the 4-second buff.
    """
    S=320;im=paper(S)
    energy=[.13,.25,.45,.71,.95,1.0,.68,.30][k]
    lock=[.0,.04,.13,.35,.82,1.0,.74,.22][k]
    rising=[26,19,11,4,0,-3,6,14][k]
    # Rotate TWO long pieces horizontally: protection, not projectiles.
    stone(im,(83-7*lock,201+rising),(65,132),-72+k*.9,
          energy*.86,1.4,.30)
    stone(im,(234+7*lock,201+rising),(68,135),70-k*.8,
          energy*.87,1.4,.30)
    dome=ARCH.resize((round(246+33*lock),round(150+19*lock)),
                     Image.Resampling.LANCZOS)
    layer_at(im,scaled_alpha(dome,energy*(.63+.32*lock)),
             (160,166+rising*.33))
    layer_at(im,scaled_alpha(CROWN,energy*(.32+.50*lock)),
             (160,94+rising))
    layer_at(im,scaled_alpha(FOOTSEAL,energy*.93),(160,272))
    if k in (3,4,5):
        hot=CROWN.filter(ImageFilter.GaussianBlur(8))
        layer_at(im,scaled_alpha(hot,.20*energy),(160,94))
    return im

def status_pose(k):
    """Painted four-second buff stays LEGIBLE during WALK without covering
    the sprite face. Shoulders and foot seal track the SAME protected actor."""
    S=192;im=paper(S)
    phase=math.tau*k/8
    breath=.85+.10*math.sin(phase)
    stone(im,(40+2*math.sin(phase),94),(23,63),-61+3*math.sin(phase),
          breath*.65,1.30,.22)
    stone(im,(152+2*math.cos(phase),94),(23,63),63-3*math.cos(phase),
          breath*.65,1.30,.22)
    left=LEFT_GOLD.resize((34,62),Image.Resampling.LANCZOS)
    right=RIGHT_GOLD.resize((34,62),Image.Resampling.LANCZOS)
    layer_at(im,scaled_alpha(left,breath*.85),(39,92))
    layer_at(im,scaled_alpha(right,breath*.87),(153,92))
    base=FOOTSEAL.resize((151,29),Image.Resampling.LANCZOS)
    layer_at(im,scaled_alpha(base,breath*.97),(96,168+1.8*math.sin(phase)))
    crest=CROWN.resize((90,36),Image.Resampling.LANCZOS)
    layer_at(im,scaled_alpha(crest,breath*.48),(96,56))
    return im

def contact_pose(k):
    """One defended hit on the incoming RIGHT flank, no retaliation.
    Broad painted barrier compresses and throws original mineral fragments.
    """
    S=256;im=paper(S)
    intensity=[.29,.66,1.0,.92,.73,.47,.23,.06][k]
    recoil=[0,5,10,8,4,0,-2,0][k]
    progress=k/7
    stone(im,(166+recoil,132),(95,129),-23+13*progress,
          intensity*.90,1.7,.40)
    layer_at(im,scaled_alpha(BLOCK_CURVE,intensity*.92),
             (168+recoil,129))
    layer_at(im,scaled_alpha(BLOCK_FLASH,intensity*.58),
             (179+recoil,146))
    if k in (1,2,3,4):
        bloom=BLOCK_CURVE.filter(ImageFilter.GaussianBlur(7))
        layer_at(im,scaled_alpha(bloom,intensity*.28),(170+recoil,130))
    randomizer=random.Random(SEED+101*k)
    for j in range(9):
        dx=(16+j*4)*progress+randomizer.randrange(-5,6)
        dy=((j%5)-2)*(9+5*progress)
        stone(im,(167+dx,131+dy),(9+j%3*3,18+j%4*2),
              -61+randomizer.randrange(-12,13),
              intensity*(.14+(j%3)*.06),1.25,.06)
    return im

def atlas(images, cell, filename):
    cols=4
    rows=math.ceil(len(images)/cols)
    page=Image.new('RGBA',(cols*cell,rows*cell),(0,0,0,0))
    for k,im in enumerate(images):
        page.alpha_composite(im,(k%cols*cell,(k//cols)*cell))
    assert page.getchannel('A').getextrema()[0]==0
    page.save(OUT/filename,optimize=True)
    return page

cast=atlas([cast_pose(k) for k in range(8)],320,"f9_mountain_cast.png")
state=atlas([status_pose(k) for k in range(8)],192,"f9_status_slabs.png")
contact=atlas([contact_pose(k) for k in range(8)],256,"f9_guard_block.png")
size=sum(im.width*im.height*4 for im in (cast,state,contact))
assert size==6553600,size
print("FIST09_BAKE_PASS frames=24 textures=3 rgba_bytes=6553600 no_rig=true original_project_material=true")
