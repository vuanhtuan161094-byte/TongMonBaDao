#!/usr/bin/env python3
"""HF02 R5: first-party source-painted luminous fire, NOT R4's seven candles.

Source: owner-supplied TMB Hỏa Phù concept illustration, manually cropped
to a discrete 320x91 fire explosion (without text/character/background).
Compact WebP source is UTF8/base64 committed next to this recipe.
The original crop had one dark artifact at its hot core: repair at source,
NOT with a giant in-engine white HUD circle. The primary silhouette uses
the real painted fire pixels; mathematical warp is subordinate to those pixels.
No JX/Source VL commercial art; no rig; no gameplay writes.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import math, io, base64, hashlib

ROOT=Path(__file__).resolve().parents[2]
LAB=ROOT/"godot/labs/combat_lab/talisman07"
OUT=LAB/"assets"
SOURCE=LAB/"art_sources/hf02_r5_owner_fire_blast.webp.b64"
SIGIL=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64"

def source_flame():
    raw=base64.b64decode(SOURCE.read_text().strip(),validate=True)
    rgb=np.asarray(Image.open(io.BytesIO(raw)).convert("RGB"),dtype=np.float32)
    assert rgb.shape==(91,320,3),rgb.shape
    r,g,b=np.moveaxis(rgb,2,0)
    mask=np.clip((r-b*.82-8)/126,0,1)**.67
    light=np.maximum(r,g*1.12)
    alpha=np.clip((light-10)*1.43,0,255)*mask
    # Remove the BLACK PRESENTATION MATTE. R5 first native movie exposed
    # an unacceptable rectangular dark plate at 1.49s on the purple backdrop.
    # Remove low-luminance poster pixels BEFORE unmatting and feather all edges.
    alpha=np.where((r>64)&(r>g*.93)&(r>b*1.30),alpha,0)
    alpha=np.clip((alpha-82)*1.53,0,255)
    hh,ww=alpha.shape
    yy,xx=np.indices((hh,ww),dtype=np.float32)
    feather=np.minimum.reduce([np.clip(xx/17,0,1),
        np.clip((ww-1-xx)/17,0,1),np.clip(yy/12,0,1),
        np.clip((hh-1-yy)/12,0,1)])
    alpha*=feather
    z=np.maximum(alpha/255,.1)
    img=Image.fromarray(np.stack([np.uint8(np.clip(r/z*1.05,0,255)),
        np.uint8(np.clip(g/z*1.11,0,255)),
        np.uint8(np.clip(b/z*1.16,0,255)),
        np.uint8(alpha)],axis=-1),"RGBA")
    repair=Image.new("RGBA",img.size)
    d=ImageDraw.Draw(repair,"RGBA")
    # Source-level inpainting of a black rectangular occlusion, not UI rays.
    d.polygon([(172,56),(177,49),(187,47),(195,50),(200,55),
               (199,64),(192,70),(180,69),(172,63)],
              fill=(255,242,176,255))
    d.polygon([(175,56),(183,51),(193,54),(196,60),(190,65),(178,64)],
              fill=(255,252,224,255))
    img.alpha_composite(repair.filter(ImageFilter.GaussianBlur(3.8)))
    img.alpha_composite(repair)
    print("HF02_R5_SOURCE_SHA256",hashlib.sha256(raw).hexdigest())
    return img

def deform(im,i,sx=1.,sy=1.):
    z=np.asarray(im.convert("RGBA"))
    h,w=z.shape[:2];yy,xx=np.indices((h,w),dtype=np.float32);t=i*.47
    xs=np.clip(xx+4.5*np.sin(yy*.073+t)+3*np.sin(xx*.037-t*.7),0,w-1).astype("int32")
    ys=np.clip(yy+3*np.sin(xx*.047-t*.7)+1.9*np.sin(yy*.13+t),0,h-1).astype("int32")
    image=Image.fromarray(z[ys,xs],"RGBA")
    return image.resize((max(2,round(w*sx)),max(2,round(h*sy))),Image.Resampling.LANCZOS)

def layered(dst,img,pos,glow=.46,gain=1.):
    halo=img.filter(ImageFilter.GaussianBlur(9))
    halo.putalpha(halo.getchannel("A").point(lambda x:round(x*glow)))
    dst.alpha_composite(halo,pos)
    fg=img.copy()
    fg.putalpha(fg.getchannel("A").point(lambda x:round(x*gain)))
    dst.alpha_composite(fg,pos)

def lotus(i,img):
    out=Image.new("RGBA",(512,384))
    if i<3:
        scale=.54+i*.135;gain=.42+i*.19;y=263
    elif i<7:
        scale=.90+(i-3)*.04;gain=1.;y=265-(i-3)*8
    elif i<10:
        scale=1.07+(i-7)*.015;gain=1.;y=224-(i-7)*5
    else:
        scale=1.13;gain=.72-(i-10)*.17;y=214
    flame=deform(img,i,sx=scale*1.49,sy=scale*1.60)
    layered(out,flame,((512-flame.width)//2,int(y-flame.height*.55)),
            glow=.46*gain,gain=gain)
    return out

def feather_crop(im,margin):
    z=np.asarray(im.convert("RGBA")).copy()
    h,w=z.shape[:2];yy,xx=np.indices((h,w),dtype=np.float32)
    f=np.minimum.reduce([np.clip(xx/margin,0,1),
        np.clip((w-1-xx)/margin,0,1),np.clip(yy/margin,0,1),
        np.clip((h-1-yy)/margin,0,1)])
    z[:,:,3]=np.uint8(z[:,:,3]*f)
    return Image.fromarray(z,"RGBA")

def impact(i,img):
    q=i/7.;dst=Image.new("RGBA",(256,256))
    src=feather_crop(img.crop((83,7,249,90)),9)
    effect=deform(src,i+23,sx=1.30+q*.10,sy=2.26+q*.22)
    # R5 native 1.49/1.62s review: source-backed contact has tiny dark
    # rectangular plates near actor feet. Isolate only the incandescent bite.
    pix=np.asarray(effect.convert("RGBA")).copy()
    hh,ww=pix.shape[:2]
    yy,xx=np.indices((hh,ww),dtype=np.float32)
    elliptical=((xx-ww*.51)/(ww*.52))**2+((yy-hh*.52)/(hh*.53))**2
    soft=np.clip((1.02-elliptical)/.46,0,1)**1.30
    pix[:,:,3]=np.uint8(np.clip((pix[:,:,3].astype(np.float32)-62)*1.26*soft,0,255))
    effect=Image.fromarray(pix,"RGBA")
    a=.07+.93*(1-q)**.7  # sparse glowing ash in final pose
    layered(dst,effect,((256-effect.width)//2,(256-effect.height)//2),
            glow=.43*a,gain=.95*a)
    return dst

def seal(i,master):
    # The previous already-original illuminated gold-red 火 family talisman.
    # Three independently rotating flame sigils signal the circle cast.
    out=Image.new("RGBA",(256,256))
    for j in range(3):
        q=(i+1)/12.
        angle=-.29+(j-1)*.35+i*.028
        w=66+5*j+int(4*math.sin(i*.34+j))
        h=round(w*132/96)
        sprite=master.resize((w,h),Image.Resampling.LANCZOS).rotate(
            math.degrees(angle),Image.Resampling.BICUBIC,expand=True)
        a=clamp(q*.95,0,1)
        sprite.putalpha(sprite.getchannel("A").point(lambda v:round(v*a)))
        x=128+(j-1)*47-sprite.width//2
        y=130-int(7*math.sin(i*.4+j))-sprite.height//2
        layered(out,sprite,(x,y),glow=.20*a,gain=1)
    return out

def clamp(v,lo,hi):return max(lo,min(hi,v))

def atlas(frames,w,h):
    result=Image.new("RGBA",(w*4,h*math.ceil(len(frames)/4)))
    for i,frame in enumerate(frames):
        result.alpha_composite(frame,((i%4)*w,(i//4)*h))
    return result

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    img=source_flame()
    raw=base64.b64decode(SIGIL.read_text().strip(),validate=True)
    sigil=Image.open(io.BytesIO(raw)).convert("RGBA")
    assert sigil.size==(96,132)
    assets={
      "tal07_r5_lotus_atlas.webp":(atlas([lotus(i,img) for i in range(12)],512,384),512,384,12),
      "tal07_r5_seal_atlas.webp":(atlas([seal(i,sigil) for i in range(12)],256,256),256,256,12),
      "tal07_r5_contact_atlas.webp":(atlas([impact(i,img) for i in range(8)],256,256),256,256,8)}
    for name,(im,w,h,count) in assets.items():
        assert im.getchannel("A").getextrema()[0]==0,name
        signatures={hashlib.sha256(im.crop(((i%4)*w,(i//4)*h,
                    (i%4+1)*w,(i//4+1)*h)).tobytes()).hexdigest() for i in range(count)}
        assert len(signatures)==count,(name,len(signatures))
        target=OUT/name
        im.save(target,"WEBP",quality=92,method=6,exact=True)
        print("HF02_R5_POSE",name,count,im.size,hashlib.sha256(target.read_bytes()).hexdigest())
    print("HF02_R5_PAINTED_REBUILD_PASS")

if __name__=="__main__":main()
