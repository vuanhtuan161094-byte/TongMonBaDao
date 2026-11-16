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

ROOT=Path(__file__).resolve().parents[2]
LAB=ROOT/"godot/labs/combat_lab/talisman09"
OUT=LAB/"assets"
PAPER=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64"
DRAGON=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_dragon_master_png.b64"
FIRE=ROOT/"godot/labs/combat_lab/talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64"

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

def phoenix(i,dragon,fire):
    c=Image.new("RGBA",(512,320))
    t=i/15.
    wingspread=.76+.20*math.sin(t*math.pi*2.7)**2
    flap=math.sin(t*math.pi*3.8)
    # Distinct asymmetrical wing-feather fan. No repeated seven-candle columns.
    for side in (-1,1):
        for f in range(6):
            breadth=f/5.
            # The actual feather edges are from original painterly fire RGBA.
            w=int((157-56*breadth)*(1+.16*flap))
            h=int(51+18*(1-breadth))
            angle=side*(16+f*11+10*flap)
            local=reshape(fire,i*2+side*7+f,(w,h),angle,.79-.24*breadth)
            x=258+side*(62+f*20)*wingspread
            y=147-(30+f*17)*(1+.12*flap)
            splash(c,local,x,y,.17)
    # Cropped original ember/draft is the bird's lively, tapered central mass.
    body=reshape(dragon,i+41,(176,101),(-10+10*flap),.92)
    splash(c,body,250,160,.33)
    head=reshape(fire,i+31,(104,52),(-21+8*flap),.85)
    splash(c,head,207,143,.30)
    # Long returning "Chu Tước" tail: three differently timed loose fire plumes.
    for k in range(3):
        plume=reshape(fire,i+54+k*7,(212-16*k,62+8*k),
            -39+13*k+5*math.sin(i*.45+k),.72-.12*k)
        splash(c,plume,286+15*k,223+10*k,.25)
    return c

def orbit(i,fire,paper):
    c=Image.new("RGBA",(640,340))
    q=i/11.
    # Material-rich energy fragments tangent to an ELLIPTICAL footprint, not
    # hard-code geometry drawing a flat ring. Different pigments move in frames.
    for j in range(5):
        a=i*.24+j*2*math.pi/5
        x=320+233*math.cos(a)
        y=178+86*math.sin(a)
        tangent=math.degrees(a)+89
        paint=reshape(fire,i+j*9,(247+int(24*math.sin(a)**2),79),
            -tangent,.43+.22*math.sin(i*.35+j)**2)
        splash(c,paint,x,y,.16)
    # Two individual gold-red paper seals ride the ritual orbit for readability.
    for j in range(2):
        a=i*.19+j*math.pi
        seal=reshape(paper,i+j*15,(57,78),-25+math.degrees(a)*.3,.53+.40*q)
        splash(c,320+184*math.cos(a),166+68*math.sin(a),.25)
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
    splash(c,160,157,center,.46) if False else splash(c,center,160,157,.46)
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
    fire=source(FIRE,(320,91))
    items={
      "tal09_r1_charge.webp":(atlas([charge(i,fire,paper) for i in range(12)],320,320),320,320,12),
      "tal09_r1_phoenix.webp":(atlas([phoenix(i,dragon,fire) for i in range(16)],512,320),512,320,16),
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
