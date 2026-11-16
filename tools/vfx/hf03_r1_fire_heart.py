#!/usr/bin/env python3
"""HF03 R1 Hỏa Tâm Ngưng Phù — first-party painterly single-target fire-heart.

Independent 3-part alpha flipbooks: ONE concentrated paper talisman at charge,
ONE pointed luminous fire-heart with a real scroll through flight, ONE compact
painted burn-contact on the preselected walking target. Preserve HF02 R6
approved master unchanged. Source art derives only from documented FIRST-PARTY
gold-red Hỏa Phù/ Hỏa Long RGB/transparent masters in this same repository.
New key states are genuinely re-composed, not recolored HF02 R6 atlas cells.
No rig, no Source A/JX imagery, no gameplay effect/status.
"""
from pathlib import Path
from PIL import Image, ImageFilter, ImageDraw
import numpy as np, base64, io, math, hashlib
from hf02_r5_source_painted import source_flame

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/talisman08/assets"
SEAL_SRC=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64"
DRAGON_SRC=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_dragon_master_png.b64"

def decode_master(path,size):
    raw=base64.b64decode(path.read_text().strip(),validate=True)
    im=Image.open(io.BytesIO(raw)).convert("RGBA")
    assert im.size==size,(path,im.size)
    print("HF03_FIRST_PARTY_MASTER",path.name,hashlib.sha256(raw).hexdigest())
    return im

def radiant(dst,pic,at,glow=.42,opacity=1.):
    if opacity<=0:return
    pic=pic.copy()
    pic.putalpha(pic.getchannel("A").point(lambda x:int(x*opacity)))
    layer=Image.new("RGBA",dst.size)
    layer.alpha_composite(pic,at)
    halo=layer.filter(ImageFilter.GaussianBlur(8))
    halo.putalpha(halo.getchannel("A").point(lambda x:int(x*glow)))
    dst.alpha_composite(halo)
    dst.alpha_composite(layer)

def shimmer(im,i,amp=3.4):
    z=np.asarray(im.convert("RGBA"))
    h,w=z.shape[:2];yy,xx=np.indices((h,w),dtype=np.float32)
    sx=np.clip(xx+amp*np.sin(yy*.075+i*.55)+2*np.sin(xx*.034-i*.41),0,w-1).astype("int32")
    sy=np.clip(yy+amp*.64*np.sin(xx*.052-i*.50),0,h-1).astype("int32")
    return Image.fromarray(z[sy,sx],"RGBA")

def scorched_scroll(src,i,size,angle=0):
    pic=shimmer(src,i,1.2).resize(size,Image.Resampling.LANCZOS)
    if angle:pic=pic.rotate(angle,Image.Resampling.BICUBIC,expand=True)
    return pic

def living_fire(src,i,size,fade=1.):
    pic=shimmer(src,i,5.0).resize(size,Image.Resampling.LANCZOS)
    z=np.asarray(pic.convert("RGBA"),dtype=np.float32).copy()
    # Keep the original colored flame painting as the silhouette.
    h,w=z.shape[:2];yy,xx=np.indices((h,w),dtype=np.float32)
    feather=np.minimum.reduce([np.clip(xx/12,0,1),
        np.clip((w-1-xx)/12,0,1),np.clip(yy/11,0,1),
        np.clip((h-1-yy)/11,0,1)])
    z[:,:,3]=np.clip(z[:,:,3]*fade*feather,0,255)
    z[:,:,0]=np.clip(z[:,:,0]*1.05,0,255)
    z[:,:,1]=np.clip(z[:,:,1]*1.10,0,255)
    return Image.fromarray(np.uint8(z),"RGBA")

def charge(i,seal,fire):
    frame=Image.new("RGBA",(320,320))
    q=i/11.;turn=q*math.pi*.42
    # Real swirling fire artwork moves inward during cast, not a drawn HUD circle.
    for k in range(3):
        a=k*math.pi*2/3+turn
        w=184-int(44*q)+int(7*math.sin(i*.37+k))
        pic=living_fire(fire,i+k*4,(w,68),fade=.24+.26*q)
        pic=pic.rotate(21+57*k+15*math.sin(i*.39+k),Image.Resampling.BICUBIC,expand=True)
        x=int(160+math.cos(a)*(37-17*q))-pic.width//2
        y=int(156+math.sin(a)*(28-11*q))-pic.height//2
        radiant(frame,pic,(x,y),.30)
    w=62+int(17*q)
    paper=scorched_scroll(seal,i,(w,round(w*132/96)),angle=-9+11*math.sin(i*.33))
    radiant(frame,paper,(160-paper.width//2,152-paper.height//2),.34,.72+.28*q)
    # At the very end charge becomes a fiercely hot painted fire-heart focus.
    focus=living_fire(fire,i+23,(92+int(q*33),51+int(q*16)),fade=.15+.69*q)
    focus=focus.rotate(78+8*math.sin(i*.43),Image.Resampling.BICUBIC,expand=True)
    radiant(frame,focus,(160-focus.width//2,147-focus.height//2),.52)
    return frame

def arrow(i,seal,dragon,fire):
    frame=Image.new("RGBA",(320,192));q=i/15.
    # Directional dragon-like flame tail is original painterly image material.
    tail=living_fire(fire,i+19,(226+int(13*math.sin(i*.45)),91),fade=.72)
    radiant(frame,tail,(7,53+int(4*math.sin(i*.38))),.33)
    head=living_fire(dragon,i+11,(167,95),fade=.83)
    head=head.rotate(2+7*math.sin(i*.44),Image.Resampling.BICUBIC,expand=True)
    radiant(frame,head,(114,42+int(6*math.sin(i*.47))),.38)
    paper=scorched_scroll(seal,i+20,(51,69),angle=-61+5*math.sin(i*.49))
    radiant(frame,paper,(236-paper.width//2,94-paper.height//2),.48)
    # Unlike HF02's multiple circle-oriented scrolls, this is one compact
    # intensely directional head-body-tail fire seal for one locked target.
    return frame

def contact(i,dragon,fire):
    frame=Image.new("RGBA",(320,256));q=i/9.
    strength=max(.045,(1-q)**.72)
    large=living_fire(fire,i+30,(268+int(15*q),117+int(34*q)),fade=strength)
    large=large.rotate(-22+7*math.sin(i*.56),Image.Resampling.BICUBIC,expand=True)
    radiant(frame,large,((320-large.width)//2,(256-large.height)//2+10),.58*strength)
    coil=living_fire(dragon,i+43,(158+int(34*q),119+int(15*q)),fade=strength*.83)
    coil=coil.rotate(88+10*math.sin(i*.62),Image.Resampling.BICUBIC,expand=True)
    radiant(frame,coil,((320-coil.width)//2,(256-coil.height)//2),.35*strength)
    return frame

def atlas(seq,w,h):
    result=Image.new("RGBA",(w*4,h*math.ceil(len(seq)/4)))
    for i,img in enumerate(seq):result.alpha_composite(img,(i%4*w,i//4*h))
    return result

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    seal=decode_master(SEAL_SRC,(96,132))
    dragon=decode_master(DRAGON_SRC,(160,94))
    fire=source_flame()
    products={
      "tal08_r1_charge.webp":(atlas([charge(i,seal,fire) for i in range(12)],320,320),320,320,12),
      "tal08_r1_projectile.webp":(atlas([arrow(i,seal,dragon,fire) for i in range(16)],320,192),320,192,16),
      "tal08_r1_contact.webp":(atlas([contact(i,dragon,fire) for i in range(10)],320,256),320,256,10)}
    for name,(im,w,h,count) in products.items():
        assert im.getchannel("A").getextrema()[0]==0,name
        distinct=set()
        for i in range(count):
            frame=im.crop((i%4*w,i//4*h,(i%4+1)*w,(i//4+1)*h))
            assert frame.getchannel("A").getextrema()[1]>10,(name,i)
            distinct.add(hashlib.sha256(frame.tobytes()).hexdigest())
        assert len(distinct)==count,(name,len(distinct))
        p=OUT/name
        im.save(p,"WEBP",quality=94,method=6,exact=True)
        print("HF03_R1_ALPHA_POSE_PASS",name,im.size,count,hashlib.sha256(p.read_bytes()).hexdigest())
    print("HF03_R1_SOURCE_ART_BAKE_PASS")

if __name__=="__main__":main()
