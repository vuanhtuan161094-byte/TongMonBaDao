#!/usr/bin/env python3
"""FIST09 / Tran Son Ho Dong: first-party painterly mountain-slab ward.

This is an offline sprite painter. The primary material is original project
art from FIST05, NOT a JX/Source-VL asset. It is independently reframed into
three defensive mountain-plates; it is not an attack animation or damage.
No skeletal rig or runtime draw-line imitation of the primary image.
"""
from pathlib import Path
from PIL import Image, ImageFilter, ImageEnhance, ImageDraw
import math, random
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'godot/labs/combat_lab/fist05/assets/spires_master.webp'
OUT=ROOT/'godot/labs/combat_lab/fist09/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
with Image.open(SOURCE) as input_art:
    MATERIAL=input_art.convert('RGBA')
assert MATERIAL.width>=100 and MATERIAL.height>=100
SEED=160911

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
    S=320; im=paper(S)
    growth=[.20,.36,.57,.77,1.0,.89,.61,.31][k]
    # Three authored mountain plates, unequal masses, asymmetric to prevent
    # generic symmetric circles. Real stone pixels retained in all frames.
    left=(120-15*growth,180-14*growth)
    right=(214+15*growth,179-22*growth)
    center=(166+6*math.sin(k*.9),155-25*growth)
    stone(im,left,(84+38*growth,124+67*growth),-26+6*math.sin(k*.8),growth*.86,1.35)
    stone(im,right,(82+38*growth,131+69*growth),22-4*math.cos(k*.9),growth*.84,1.55)
    stone(im,center,(90+40*growth,145+80*growth),2+7*math.sin(k*.7),growth*.64,1.65)
    ground_light(im,growth,(160,278))
    strokes(im,SEED+k*23,22,(165,174),(97,112),growth)
    # Brightly coloured "mountain crown", not circular quang-giap/runes.
    return im

def status_pose(k):
    S=192; im=paper(S)
    phase=2*math.pi*k/8.0
    breath=.72+.08*math.sin(phase)
    # Two small chipped armor markers near shoulder/waist, with empty actor.
    stone(im,(42+3*math.sin(phase),89),(41,78),-24+3*math.sin(phase),.83*breath,1.5,.51)
    stone(im,(151+2*math.cos(phase),80),(39,73),26-3*math.cos(phase),.81*breath,1.45,.48)
    ground_light(im,.42*breath,(96,168))
    strokes(im,SEED+200+k,13,(97,137),(74,36),breath*.43)
    return im

def contact_pose(k):
    S=256; im=paper(S);p=k/7.0
    impulse=[.45,.88,1.0,.94,.74,.53,.31,.13][k]
    # Paint localized stone shield compression, not an explosion hitting enemy.
    stone(im,(119+6*p,130-5*p),(106+48*p,163-26*p),-28-16*p,
          impulse*.92,1.8,.89)
    rand=random.Random(SEED+900+k*17)
    # Fractured chips shear out from protected recipient only.
    for j in range(8):
        angle=j*math.tau/8+0.2*j
        radius=(14+51*p)*(1+(j%3)*.07)
        x=122+radius*math.cos(angle)
        y=136+radius*.72*math.sin(angle)
        wh=(10+rand.randint(0,10),18+rand.randint(0,11))
        stone(im,(x,y),wh,rand.randint(-55,55),impulse*(.34+.12*(j%3)),1.55,.27)
    if k<5:
        core=Image.new('RGBA',(S,S),(0,0,0,0))
        d=ImageDraw.Draw(core,'RGBA')
        x,y=138+12*p,120-9*p
        r=11+24*p
        d.ellipse((x-r,y-r,x+r,y+r),fill=(255,240,189,int(83*impulse)))
        im.alpha_composite(core.filter(ImageFilter.GaussianBlur(9)))
    strokes(im,SEED+2400+k*9,27,(139,123),(78,83),impulse)
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
