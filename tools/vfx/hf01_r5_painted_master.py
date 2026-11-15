#!/usr/bin/env python3
"""HF01 R5: first-party painted fire-dragon master -> 12/8 original RGBA poses.

Source: independent ImageGen illustration commissioned for this project,
cropped, manually isolated to transparent alpha and palette-cleaned. This
source is NOT a Godot screenshot; only the derived sprites are LAB assets.
Never modifies target selection, hit receipts, damage, DoT or any gameplay.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import math, io, base64, hashlib

ROOT=Path(__file__).resolve().parents[2]
ASSETS=ROOT/'godot/labs/combat_lab/talisman06/assets'
SOURCE=ROOT/'godot/labs/combat_lab/talisman06/art_sources/hf01_r5_dragon_master_png.b64'

def master():
    raw=base64.b64decode(SOURCE.read_text().strip(),validate=True)
    img=Image.open(io.BytesIO(raw)).convert('RGBA')
    assert img.size==(160,94),img.size
    assert img.getchannel('A').getextrema()[0]==0
    print('HF01_R5_MASTER_SHA256',hashlib.sha256(raw).hexdigest())
    return img.transpose(Image.Transpose.FLIP_LEFT_RIGHT)

def deform(source,t,dims,amp=4):
    """Image-space deformation of painted pixels, never procedural hero geometry."""
    src=np.asarray(source.convert('RGBA'))
    h,w=src.shape[:2]
    y,x=np.mgrid[0:h,0:w]
    sx=np.clip(x+amp*np.sin(y*.074+t*.82)+1.6*np.sin(x*.034-t*.58),0,w-1)
    sy=np.clip(y+amp*.72*np.sin(x*.067-t*.69)+1.9*np.cos(y*.041+t*.44),0,h-1)
    x0=sx.astype('int32');y0=sy.astype('int32')
    x1=np.minimum(w-1,x0+1);y1=np.minimum(h-1,y0+1)
    ax=(sx-x0)[...,None];ay=(sy-y0)[...,None]
    a=src[y0,x0]*(1-ax)+src[y0,x1]*ax
    b=src[y1,x0]*(1-ax)+src[y1,x1]*ax
    mixed=np.uint8(np.clip(a*(1-ay)+b*ay,0,255))
    return Image.fromarray(mixed,'RGBA').resize(dims,Image.Resampling.LANCZOS)

def composite_glow(dst,paint,center,opacity=.28):
    glow=paint.filter(ImageFilter.GaussianBlur(9))
    ar=glow.getchannel('A').point(lambda a:int(a*opacity))
    glow.putalpha(ar)
    dst.alpha_composite(glow,center)
    dst.alpha_composite(paint,center)

def comet(master_img,i):
    frame=Image.new('RGBA',(384,224))
    w=265+int(12*math.sin(i*.62));h=round(w*94/160)
    hero=deform(master_img,i,(w,h),amp=3.2+1.4*math.sin(i*.52)**2)
    x=108+int(5*math.sin(i*.53));y=(224-h)//2+int(3*math.sin(i*.77))
    composite_glow(frame,hero,(x,y),opacity=.38)
    rng=np.random.default_rng(5500+i*181)
    ember=Image.new('RGBA',frame.size)
    d=ImageDraw.Draw(ember,'RGBA')
    for k in range(23):
        px=int(rng.uniform(12,176));py=int(rng.normal(112,43))
        if px<2 or px>380 or py<2 or py>220:continue
        r=int(rng.choice([1,1,2,2]))
        d.ellipse((px-r,py-r,px+r,py+r),
            fill=(255,int(rng.uniform(145,229)),55,int(rng.uniform(45,140))))
    frame.alpha_composite(ember)
    return frame

def impact(master_img,i):
    q=i/7.0
    # One painted flame-bite, never geometric HUD spokes or a second hit.
    frame=Image.new('RGBA',(288,224))
    strength=max(0.,1.-q)
    w=int(268-10*q);h=int(165+8*q)
    hero=deform(master_img,7+i,(w,h),amp=3.2+4.0*q)
    src=np.asarray(hero.convert('RGBA')).astype('float32').copy()
    yy,xx=np.indices((h,w),dtype='float32')
    # White-hot contact stays WITHIN the existing original painted silhouette.
    # Retain brush texture, no filled code polygons or fake impact circles.
    mask=src[:,:,3]/255.
    hotspot=np.exp(-(((xx-w*.73)/(w*.17))**2+((yy-h*.54)/(h*.28))**2))
    hot=np.clip(hotspot*mask*.86,0,1)
    src[:,:,0]=np.clip(src[:,:,0]+(255-src[:,:,0])*(.15+.38*hot),0,255)
    src[:,:,1]=np.clip(src[:,:,1]+(250-src[:,:,1])*(.08+.44*hot),0,255)
    src[:,:,2]=np.clip(src[:,:,2]+(200-src[:,:,2])*(.08+.29*hot),0,255)
    src[:,:,3]=np.clip(src[:,:,3]*(1.35-.33*q)*strength,0,254)
    hero=Image.fromarray(np.uint8(src),'RGBA')
    px=(288-w)//2;py=(224-h)//2-int(7*q)
    composite_glow(frame,hero,(px,py),opacity=.66*strength)
    rng=np.random.default_rng(1400+23*i)
    emb=Image.new('RGBA',(288,224));d=ImageDraw.Draw(emb,'RGBA')
    for j in range(35):
        x=int(rng.normal(144,54+20*q));y=int(rng.normal(146,31+16*q))
        if not (4<x<284 and 4<y<220):continue
        r=int(rng.choice([1,1,2,2]))
        d.ellipse((x-r,y-r,x+r,y+r),
            fill=(255,int(rng.uniform(145,230)),54,int(rng.uniform(35,115)*strength)))
    frame.alpha_composite(emb)
    return frame

def atlas(frames,w,h):
    a=Image.new('RGBA',(w*4,h*((len(frames)+3)//4)))
    for i,frame in enumerate(frames):a.alpha_composite(frame,(i%4*w,i//4*h))
    return a

def main():
    ASSETS.mkdir(parents=True,exist_ok=True)
    img=master()
    items={
        'tal06_r5_comet_atlas.webp':(atlas([comet(img,i) for i in range(12)],384,224),384,224,12),
        'tal06_r5_impact_atlas.webp':(atlas([impact(img,i) for i in range(8)],288,224),288,224,8)
    }
    for name,(a,w,h,count) in items.items():
        hashes=set()
        for i in range(count):
            cell=a.crop((i%4*w,i//4*h,(i%4+1)*w,(i//4+1)*h))
            hashes.add(hashlib.sha256(cell.tobytes()).hexdigest())
        assert len(hashes)==count,(name,len(hashes))
        assert a.getchannel('A').getextrema()[0]==0,(name,'alpha')
        path=ASSETS/name
        a.save(path,'WEBP',quality=96,method=6,exact=True)
        print('HF01_R5_POSE_GATE',name,'poses',count,'size',a.size,
            'sha256',hashlib.sha256(path.read_bytes()).hexdigest())
    print('HF01_R5_ORIGINAL_PAINTED_SPRITES_PASS')

if __name__=='__main__':main()
