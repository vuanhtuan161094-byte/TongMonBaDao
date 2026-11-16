#!/usr/bin/env python3
"""HF04 Chu Tước Hồi Hoàn: independent first-party phoenix-flame flipbook.
One circular cast pulse only; the orbiting fire-bird is pure view-only VFX.
Not rigged and does not import a promotional poster into the game's background.
All opaque/material pixels originate in the existing project-owned illuminated
Hỏa Phù scroll, Hỏa Long and 320x91 first-party painted flame masters; the
phoenix is an independent manually composed wing/body/tail form made from
those material strokes, not a resized HF02 effect or simple vector HUD ring.
"""
from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np, base64, io, math, hashlib
from hf02_r5_source_painted import source_flame  # audited bright-source alpha unmatting

ROOT=Path(__file__).resolve().parents[2]
LAB=ROOT/"godot/labs/combat_lab/talisman09"
OUT=LAB/"assets"
PAPER=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64"
DRAGON=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_dragon_master_png.b64"
FIRE=ROOT/"godot/labs/combat_lab/talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64"
PHOENIX_SOURCE=LAB/"art_sources/hf04_chu_tuoc_original_rgb.webp.b64"

def source(path,expected):
    raw=base64.b64decode(path.read_text().strip(),validate=True)
    im=Image.open(io.BytesIO(raw)).convert("RGBA")
    assert im.size==expected,(str(path),im.size,expected)
    print("HF04_MASTER_SHA",path.name,hashlib.sha256(raw).hexdigest())
    return im

def reshape(im,i,size,angle=0,alpha=1.0):
    # Primary visible material is the original real image, not a line drawn
    # from code. Organic painterly deformation offsets are secondary only.
    img=im.resize(size,Image.Resampling.LANCZOS)
    v=np.asarray(img).copy()
    h,w=v.shape[:2];yy,xx=np.indices((h,w),dtype=np.float32)
    xs=np.clip(xx+3.2*np.sin(yy*.10+i*.45)+2.4*np.sin(xx*.047-i*.26),0,w-1).astype(int)
    ys=np.clip(yy+1.9*np.sin(xx*.066+i*.39),0,h-1).astype(int)
    z=v[ys,xs].copy()
    # Never amplify dark presentation mattes as opaque blocks.
    edge=np.minimum.reduce([np.clip(xx/9,0,1),np.clip((w-1-xx)/9,0,1),
        np.clip(yy/6,0,1),np.clip((h-1-yy)/6,0,1)])
    z[:,:,3]=np.uint8(z[:,:,3].astype(float)*edge*max(0,min(1,alpha)))
    img=Image.fromarray(z,"RGBA")
    if angle:img=img.rotate(angle,Image.Resampling.BICUBIC,expand=True)
    return img

def splash(dst,img,x,y,glow=.27):
    px=int(x-img.width/2);py=int(y-img.height/2)
    layer=Image.new("RGBA",dst.size)
    layer.alpha_composite(img,(px,py))
    halo=layer.filter(ImageFilter.GaussianBlur(10))
    halo.putalpha(halo.getchannel("A").point(lambda a:int(a*glow)))
    dst.alpha_composite(halo);dst.alpha_composite(layer)

def load_original_phoenix():
    """Original first-party AI-painted Chu Tước material, never a screenshot.
    Source was independently illustrated for TMB; a 304x112 RGB artwork crop.
    Extract hot flame photons with a feathered alpha, rejecting dark background.
    """
    raw=base64.b64decode(PHOENIX_SOURCE.read_text().strip(),validate=True)
    rgb=np.asarray(Image.open(io.BytesIO(raw)).convert("RGB"),dtype=np.float32)
    assert rgb.shape==(112,304,3),rgb.shape
    r,g,b=np.moveaxis(rgb,2,0)
    luminance=.65*r+.35*g
    a=np.clip((luminance-69)/148,0,1)*np.clip((r-1.28*b-25)/125,0,1)
    a=np.clip(a,0,1)**.72
    yy,xx=np.indices(a.shape,dtype=np.float32)
    edge=np.minimum.reduce([np.clip(xx/13,0,1),np.clip((303-xx)/14,0,1),
        np.clip(yy/10,0,1),np.clip((111-yy)/13,0,1)])
    a=a*edge
    rgba=np.stack([np.clip(r*1.08,0,255),np.clip(g*1.13,0,255),
                   np.clip(b*.82,0,255),np.clip(a*255,0,255)],axis=-1).astype(np.uint8)
    image=Image.fromarray(rgba,"RGBA")
    assert image.getchannel("A").getextrema()[0]==0
    print("HF04_ORIGINAL_PHOENIX_ART_SHA",hashlib.sha256(raw).hexdigest())
    return image

def phoenix(i,original,fire):
    c=Image.new("RGBA",(512,320))
    t=i/15.
    flutter=math.sin(t*math.pi*3.6)
    # Main silhouette remains a PAINTED recognizable living flame-bird.
    # Variable wing width/height, irregular flutter and twist yield distinct
    # flipbook poses but do NOT assert 16 independently handpainted masters.
    wingspan=456+int(13*flutter)
    wingheight=192+int(15*math.sin(t*math.pi*2.4))
    body=reshape(original,i+17,(wingspan,wingheight),
        2.7*math.sin(t*math.pi*2.9),.96)
    splash(c,body,258,129,.34)
    # Three long trailing radiant feathers behind body, subdued; never
    # reconstruct a phoenix with six symmetric geometric stick wings.
    for k in range(3):
        plum=reshape(fire,i*2+47+k*11,(153-k*16,50+k*4),
            -27+13*k+7*math.sin(i*.49+k),.38-k*.08)
        splash(c,plum,294+12*k,227+7*k,.11)
    return c

def orbit(i,fire,paper):
    c=Image.new("RGBA",(640,340))
    q=i/11.
    # Only three asymmetric narrow painted flame trails, no huge X-shaped
    # rune/UI circle overwhelming the three moving monsters.
    for j in range(3):
        a=i*.205+j*2*math.pi/3
        x=320+199*math.cos(a)
        y=176+63*math.sin(a)
        paint=reshape(fire,i+j*9,(185+int(15*math.sin(a)**2),62),
            -math.degrees(a)-75,.28+.12*math.sin(i*.35+j)**2)
        splash(c,paint,x,y,.11)
    for j in range(2):
        a=i*.18+j*math.pi
        seal=reshape(paper,i+j*15,(45,67),-25+math.degrees(a)*.26,.44+.23*q)
        splash(c,seal,320+180*math.cos(a),166+56*math.sin(a),.12)
    return c

def charge(i,fire,paper):
    c=Image.new("RGBA",(320,320))
    q=i/11.
    for j in range(3):
        a=i*.24+j*2*math.pi/3
        f=reshape(fire,i+j*11,(162+int(11*q),65),-25+j*64+12*math.sin(i*.3+j),.45+.33*q)
        splash(c,f,160+40*math.cos(a),164+33*math.sin(a),.27)
    p=reshape(paper,i+13,(70+int(16*q),97+int(16*q)),math.sin(i*.38)*10,.62+.38*q)
    splash(c,p,160,154,.30)
    # A flickering colored source-painted core takes priority, never a fake
    # radial HUD vector; the center brightens without white clipping.
    center=reshape(fire,i+57,(113+int(19*q),48+int(9*q)),84+6*math.sin(i*.43),.24+.60*q)
    splash(c,center,160,157,.46)
    return c

def hit(i,fire,dragon):
    c=Image.new("RGBA",(256,256))
    q=i/9.;fade=max(.06,(1-q)**.83)
    f=reshape(fire,i+80,(226+int(10*q),94+int(14*q)),
              21+9*math.sin(i*.62),fade)
    splash(c,f,128,148,.42*fade)
    coil=reshape(dragon,i+117,(113,78),84+16*math.sin(i*.7),.74*fade)
    splash(c,coil,129,130,.28*fade)
    return c

def atlas(frames,w,h):
    out=Image.new("RGBA",(4*w,math.ceil(len(frames)/4)*h))
    for i,frame in enumerate(frames):out.alpha_composite(frame,((i%4)*w,(i//4)*h))
    return out

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    paper=source(PAPER,(96,132));dragon=source(DRAGON,(160,94))
    fire=source_flame()  # never composite the opaque dark poster matte
    original_phoenix=load_original_phoenix()
    items={
      "tal09_r1_charge.webp":(atlas([charge(i,fire,paper) for i in range(12)],320,320),320,320,12),
      "tal09_r1_phoenix.webp":(atlas([phoenix(i,original_phoenix,fire) for i in range(16)],512,320),512,320,16),
      "tal09_r1_orbit.webp":(atlas([orbit(i,fire,paper) for i in range(12)],640,340),640,340,12),
      "tal09_r1_contact.webp":(atlas([hit(i,fire,dragon) for i in range(10)],256,256),256,256,10),
    }
    for name,(img,w,h,n) in items.items():
        assert img.getchannel("A").getextrema()[0]==0,name
        allhash=set()
        for i in range(n):
            q=img.crop((i%4*w,i//4*h,(i%4+1)*w,(i//4+1)*h))
            assert q.getchannel("A").getextrema()[1]>24,(name,i)
            allhash.add(hashlib.sha256(q.tobytes()).hexdigest())
        assert len(allhash)==n,(name,len(allhash))
        p=OUT/name;img.save(p,"WEBP",quality=92,method=6,exact=True)
        print("HF04_ORIGINAL_PAINTED_ATLAS_PASS",name,img.size,"frames",n,"sha256",hashlib.sha256(p.read_bytes()).hexdigest())
    print("HF04_R1_SOURCE_ART_BAKE_PASS")

if __name__=="__main__": main()
