#!/usr/bin/env python3
"""FIST13 R6 — distinct Huyet Quyen material, first-party FIST03 painted fist
and contact texture re-composed into animated punch-imprint / recoil current.
NOT a Poison Tu whirlpool, talisman, SVG, poster crop, still video, rig or GIF.
Source is an explicitly credited project-owned DERIVATIVE, not a new ImageGen.
"""
from pathlib import Path
from PIL import Image, ImageFilter, ImageDraw
import numpy as np, math, hashlib, json
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/"godot/labs/combat_lab/fist03/assets"
OUT=ROOT/"godot/labs/combat_lab/fist13/assets/generated"
OUT.mkdir(parents=True,exist_ok=True)
FIST=Image.open(SRC/"godfist_master.webp").convert("RGBA")
INK=Image.open(SRC/"impact_master.webp").convert("RGBA")
assert FIST.width>=128 and FIST.height>=128 and INK.width>=128 and INK.height>=128
CELL=320
def material(src,t,opacity=1.0,kind=0):
    a=np.asarray(src.convert("RGBA"),dtype=np.float32).copy()
    h,w=a.shape[:2]; yy,xx=np.mgrid[:h,:w]
    # Actual painted pixels warped non-rigidly between poses: restrained movement.
    j=t*.58
    xs=np.clip(xx+3.0*np.sin(yy*.068+j+kind)+1.8*np.sin(xx*.043-j*.7),0,w-1).astype(np.int32)
    ys=np.clip(yy+2.6*np.sin(xx*.051-j*.76)+1.2*np.sin(yy*.11+j),0,h-1).astype(np.int32)
    a=a[ys,xs]
    rgb=a[:,:,:3]
    light=np.clip(.37*rgb[:,:,0]+.48*rgb[:,:,1]+.15*rgb[:,:,2],0,255)
    hot=np.clip((light-132.0)/95.0,0,1)**1.3
    plasma=np.clip((light-20.0)/165.0,0,1)
    r=np.clip(61+204*plasma+18*hot,0,255)
    g=np.clip(12+45*plasma+169*hot,0,255)
    b=np.clip(27+57*plasma+150*hot,0,255)
    source_alpha=a[:,:,3]/255.0
    # Alpha from true source painting, not fake black matte.
    a[:,:,0]=r; a[:,:,1]=g; a[:,:,2]=b
    a[:,:,3]=np.clip(source_alpha**.86*255*opacity,0,255)
    # Organic fuzzy edges: no rectangle, preserve bright white-hot knuckles.
    rad=np.sqrt(((xx-w*.50)/(w*.53))**2+((yy-h*.50)/(h*.53))**2)
    fall=np.clip((1.10-rad)/.20,0,1)
    edge=np.minimum.reduce([xx,w-1-xx,yy,h-1-yy])
    a[:,:,3]*=fall*np.clip(edge/7.0,0,1)
    a[a[:,:,3]<4,:3]=0
    return Image.fromarray(a.astype(np.uint8),"RGBA")
def composite(canvas,img,x,y,alpha=1.0,bloom=.22):
    x=int(round(x));y=int(round(y))
    mat=img.copy()
    mat.putalpha(mat.getchannel("A").point(lambda v: min(255,int(v*alpha))))
    layer=Image.new("RGBA",canvas.size)
    layer.alpha_composite(mat,(x,y))
    soft=layer.filter(ImageFilter.GaussianBlur(7))
    soft.putalpha(soft.getchannel("A").point(lambda v: int(v*bloom)))
    canvas.alpha_composite(soft)
    canvas.alpha_composite(layer)
def pose_charge(k):
    t=k/7
    dst=Image.new("RGBA",(CELL,CELL))
    main=material(FIST,k,opacity=.28+.69*t)
    scale=.30+.25*t
    w=int(300*scale);h=w
    main=main.resize((w,h),Image.Resampling.LANCZOS)
    composite(dst,main,160-w//2,161-h//2,.80,.28)
    for j in range(2):
        dust=material(INK,k+j*2,opacity=.28+.30*t,kind=3+j)
        sw=int(120+32*t);sh=int(83+20*t)
        dust=dust.resize((sw,sh),Image.Resampling.LANCZOS)
        rot=dust.rotate((-23 if j==0 else 25)+int(8*math.sin(k*.55+j)),Image.Resampling.BICUBIC,expand=True)
        px=160+(-44 if j==0 else 41)*(1-.52*t)-rot.width/2
        py=160+(-34 if j==0 else 28)*(1-.58*t)-rot.height/2
        composite(dst,rot,px,py,.55,.23)
    return dst
def pose_contact(k):
    t=k/11.0
    dst=Image.new("RGBA",(CELL,CELL))
    # Three actual phases within a SINGLE visual contact: windup, compressed fist,
    # and fraying recoil. No repeated hit receipts.
    swelling=math.sin(min(1,t*1.04)*math.pi*.88)
    fx=88+int(20*t)
    fy=88+int(15*math.sin(t*math.pi))
    tex=material(FIST,k*1.24,opacity=.66+.34*swelling)
    w=int(182+39*swelling);h=w
    tex=tex.resize((w,h),Image.Resampling.LANCZOS)
    ang=-12+7*math.sin(t*math.pi)
    tex=tex.rotate(ang,Image.Resampling.BICUBIC,expand=True)
    composite(dst,tex,196-tex.width/2,160-tex.height/2,.97,.28)
    # Painterly impact pigment trails behind the fist. Source is real paint,
    # no path made from equal-width neon vector curves.
    ink=material(INK,k*1.33,opacity=.75-.23*t,kind=2)
    size=(int(213+12*swelling),int(104+28*swelling))
    ink=ink.resize(size,Image.Resampling.LANCZOS)
    ink=ink.rotate(-8+6*math.sin(t*math.pi),Image.Resampling.BICUBIC,expand=True)
    composite(dst,ink,123-ink.width/2,156-ink.height/2,.70*(1-.28*t),.17)
    # Compact painted pressure peak: one local focal point, no fake explosion.
    if k>=6:
        core=material(INK,k+.42,opacity=(.82-.42*t),kind=4)
        d=int(94+27*math.sin(t*math.pi))
        core=core.resize((d,d),Image.Resampling.LANCZOS)
        composite(dst,core,187-d/2,158-d/2,.65,.25)
    return dst
def pose_mark(k):
    t=k/8
    dst=Image.new("RGBA",(CELL,CELL))
    # ONE compact painterly spirit-fist imprint. Never a POISON haze, UI ring
    # or a huge cloud covering the receiving actor's body.
    main=material(FIST,k*.67,opacity=.83+.14*math.sin(t*math.tau),kind=6)
    w=116+int(7*math.sin(t*math.tau))
    main=main.resize((w,w),Image.Resampling.LANCZOS)
    composite(dst,main,160-w//2,162-w//2,.98,.29)
    # Tiny broken-meridian accents from original strike pigment, secondary only.
    ink=material(INK,k*.77,opacity=.38,kind=7)
    ink=ink.resize((110,74),Image.Resampling.LANCZOS)
    composite(dst,ink,160-55,158-37,.33,.11)
    d=ImageDraw.Draw(dst,"RGBA")
    q=math.sin(t*math.tau)
    scar=[(156,141),(169+int(2*q),151),(154-int(2*q),161),(171,177)]
    d.line(scar,fill=(139,10,39,130),width=8,joint="curve")
    d.line(scar,fill=(255,158,167,192),width=4,joint="curve")
    d.line(scar,fill=(255,241,210,215),width=2,joint="curve")
    return dst

manifest={}
for name,n,fn in (("charge",8,pose_charge),("contact",12,pose_contact),("mark",8,pose_mark)):
    atlas=Image.new("RGBA",(CELL*4,CELL*((n+3)//4)))
    hashes=set()
    for i in range(n):
        tile=fn(i); alpha=np.asarray(tile.getchannel("A"))
        assert int((alpha>45).sum())>=300,(name,i,"tiny/empty")
        assert alpha[0,:].max()<5 and alpha[-1,:].max()<5 and alpha[:,0].max()<5 and alpha[:,-1].max()<5,(name,i,"clipped")
        hashes.add(hashlib.sha256(tile.tobytes()).hexdigest())
        atlas.alpha_composite(tile,((i%4)*CELL,(i//4)*CELL))
    assert len(hashes)==n
    p=OUT/f"f13_{name}.png";atlas.save(p,optimize=True)
    manifest[name]={"frames":n,"dimensions":list(atlas.size),"sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
pose_contact(8).save(OUT/"f13_original_code_painted_hero.png",optimize=True)
(OUT/"f13_art_source_manifest.json").write_text(json.dumps({
"revision":"R7","source_class":"FIRST_PARTY_FIST03_PAINTED_MATERIAL_DERIVATIVE",
"rights":"Project-owned original painted FIST03 godfist_master.webp and impact_master.webp",
"not_new_illustration":True,"no_poison_master":True,"no_rig":True,"no_gif":True,
"original_sources":[str(SRC/"godfist_master.webp"),str(SRC/"impact_master.webp")],
"atlases":manifest},ensure_ascii=False,indent=2),encoding="utf-8")
print("FIST13_R7_FIST_SOURCE_BAKE_PASS frames=28 pages=3 alpha=true no_gif=true no_rig=true")
