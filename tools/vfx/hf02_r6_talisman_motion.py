#!/usr/bin/env python3
"""HF02 R6: ORIGINAL painted-fire & gold talisman charge / cosmetic fly atlases.

Preserves the owner's temporarily liked R5 explosion verbatim.
The animation is purely visual: catalogue projectile_speed=0, no hit or damage.
Source masters are preserved in the same repository, including the TMB
gold-red 火 sigil (96x132 RGBA) and first-party R5 fire ribbon (320x91).
Uses independently changing artwork/frame poses, not rig or code UI circles.
"""
from pathlib import Path
from PIL import Image, ImageFilter, ImageEnhance
import numpy as np
import hashlib, base64, io, math
from hf02_r5_source_painted import source_flame

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/talisman07/assets"
SOURCE=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64"

def load_sigil():
    raw=base64.b64decode(SOURCE.read_text().strip(),validate=True)
    im=Image.open(io.BytesIO(raw)).convert("RGBA")
    assert im.size==(96,132),im.size
    print("HF02_R6_SIGIL_SOURCE_SHA256",hashlib.sha256(raw).hexdigest())
    return im

def brightness(im,gain):
    im=im.convert("RGBA")
    z=np.asarray(im,dtype=np.float32).copy()
    z[:,:,:3]=np.clip(z[:,:,:3]*gain+z[:,:,3:4]*.035,0,255)
    return Image.fromarray(np.uint8(z),"RGBA")

def bloom(dst,im,xy,scale=.30):
    layer=Image.new("RGBA",dst.size)
    layer.alpha_composite(im,xy)
    blurred=layer.filter(ImageFilter.GaussianBlur(11))
    blurred.putalpha(blurred.getchannel("A").point(lambda a:round(a*scale)))
    dst.alpha_composite(blurred)
    dst.alpha_composite(layer)

def colored_flame(src,i,size,opacity=.8):
    # Original painted hot plasma pixels with nuanced warp and directional head.
    pic=src.resize(size,Image.Resampling.LANCZOS)
    z=np.asarray(pic,dtype=np.float32).copy()
    h,w=z.shape[:2]
    yy,xx=np.indices((h,w),dtype=np.float32)
    warp=np.clip(xx+4.2*np.sin(yy*.115+i*.52)+2.1*np.sin(xx*.044-i*.37),0,w-1).astype(int)
    wav=np.clip(yy+3.7*np.sin(xx*.047-i*.44),0,h-1).astype(int)
    z=z[wav,warp]
    # No dark matte: explicitly threshold and retain only original emitted color.
    z[:,:,3]=np.clip(z[:,:,3]*opacity,0,252)
    z[:,:,0]=np.clip(z[:,:,0]*1.08,0,255)
    z[:,:,1]=np.clip(z[:,:,1]*1.14,0,255)
    return Image.fromarray(np.uint8(z),"RGBA")

def charge(i,sigil,flame):
    dst=Image.new("RGBA",(320,320))
    progress=i/11
    # Hand-centered channeling: surrounding fire pigments spiral inward.
    for k in range(3):
        a=i*.13+k*2.09
        # Bright energy streams are REAL PAINTED fire, not code-drawn arcs.
        sheet=colored_flame(flame,i+k*5,(175,68),opacity=(.37+.19*progress))
        sheet=sheet.rotate(math.degrees(a)*.63+k*61,
            Image.Resampling.BICUBIC,expand=True)
        x=160+int(math.cos(a)*(57-26*progress))-sheet.width//2
        y=155+int(math.sin(a)*(43-18*progress))-sheet.height//2
        bloom(dst,sheet,(x,y),.22)
    for k in range(4):
        # 4 prominent owner-style golden talismans circle, then tighten.
        a=i*.19+k*math.pi*.5
        radius=(86-35*progress)+8*math.sin(i*.35+k)
        x=160+int(math.cos(a)*radius)
        y=155+int(math.sin(a)*radius*.64)
        w=45+(i//4)*3+(k%2)*2
        h=round(w*132/96)
        seal=brightness(sigil.resize((w,h),Image.Resampling.LANCZOS),
                       1.06+.18*progress)
        seal=seal.rotate(-math.degrees(a)*.21+math.sin(i*.32+k)*12,
            Image.Resampling.BICUBIC,expand=True)
        seal.putalpha(seal.getchannel("A").point(lambda v:round(v*(.55+.45*progress))))
        bloom(dst,seal,(x-seal.width//2,y-seal.height//2),.36)
    return dst

def flying(i,sigil,flame):
    dst=Image.new("RGBA",(320,192))
    t=i/11
    tail=colored_flame(flame,i+17,(252,97),opacity=(.45+.32*math.sin(t*math.pi)**2))
    # Body points right; increasingly compressed flame trail before impact.
    pix=np.asarray(tail.convert("RGBA")).copy()
    yy,xx=np.indices(pix.shape[:2],dtype=np.float32)
    rag=(.77+.23*np.sin(xx*.11+i*.47+yy*.071))
    tip=np.clip((236-xx)/35,0,1)
    pix[:,:,3]=np.uint8(np.clip(pix[:,:,3].astype(np.float32)*rag*tip,0,253))
    tail=Image.fromarray(pix,"RGBA")
    bloom(dst,tail,(9,48+int(4*math.sin(i*.8))),.34)
    # The central readable projectile is explicitly a GOLD/RED PAPER TALISMAN,
    # rotated along its flight tangent (visual only, no Combat V2 projectile).
    w=52+int(4*math.sin(i*.46))
    h=round(w*132/96)
    scroll=brightness(sigil.resize((w,h),Image.Resampling.LANCZOS),1.12)
    scroll=scroll.rotate(-64+6*math.sin(i*.54),
        Image.Resampling.BICUBIC,expand=True)
    bloom(dst,scroll,(229-scroll.width//2,97-scroll.height//2),.47)
    return dst

def atlas(images,w,h):
    out=Image.new("RGBA",(w*4,h*((len(images)+3)//4)))
    for i,img in enumerate(images):
        out.alpha_composite(img,((i%4)*w,(i//4)*h))
    return out

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    s=load_sigil();f=source_flame()
    sources={
      "tal07_r6_charge_atlas.webp":(atlas([charge(i,s,f) for i in range(12)],320,320),320,320,12),
      "tal07_r6_flying_atlas.webp":(atlas([flying(i,s,f) for i in range(12)],320,192),320,192,12)}
    for name,(im,w,h,n) in sources.items():
        assert im.getchannel("A").getextrema()[0]==0,name
        hashes=set()
        for i in range(n):
            q=im.crop((i%4*w,i//4*h,(i%4+1)*w,(i//4+1)*h))
            assert q.getchannel("A").getextrema()[1]>=90,(name,i)
            hashes.add(hashlib.sha256(q.tobytes()).hexdigest())
        assert len(hashes)==n,(name,len(hashes))
        p=OUT/name
        im.save(p,"WEBP",quality=94,method=6,exact=True)
        print("HF02_R6_ATLAS",name,im.size,"poses",n,"sha256",
              hashlib.sha256(p.read_bytes()).hexdigest())
    print("HF02_R6_ART_ATLAS_GATE_PASS")

if __name__=="__main__":main()
