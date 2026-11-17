#!/usr/bin/env python3
"""FIST13 R3 true-alpha painted-material composite, adapted from approved first-party
HF02/POI11 *production technique*. Material sources are ORIGINAL project-owned POI11
R9 alpha-painted atlas and original contact; NOT a novel independently painted hero.
Dramatically different small single-target blood-meridian geometry, no poison
gameplay, no paper talisman, no third-party art, rig or GIF.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import hashlib, math, random, json
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/fist13/assets/generated"
BASE=ROOT/"godot/labs/combat_lab/poison11/r1_original/assets"
OUT.mkdir(parents=True,exist_ok=True)
CROWN=Image.open(BASE/"poison11_crown_10_r9.png").convert("RGBA")
CONTACT=Image.open(BASE/"poison11_contact_08.png").convert("RGBA")
assert CROWN.size==(1280,576) and CONTACT.size==(768,320)
CELL=320
def crop(sheet,kind,index):
    w,h=(320,192) if kind=="crown" else (192,160)
    return sheet.crop(((index%4)*w,(index//4)*h,((index%4)+1)*w,((index//4)+1)*h))
def ruby(source,level=1.0,phase=0.0):
    # Palette hierarchy from original *painted pixels*, no monochrome flat fill.
    p=np.asarray(source.convert("RGBA"),dtype=np.float32).copy()
    r,g,b=np.moveaxis(p[:,:,:3],2,0)
    light=np.maximum.reduce([r,g,b])
    hot=np.clip((light-194)/61,0,1)**1.7
    warm=np.clip(.36*r+.57*g+.07*b,0,255)
    p[:,:,0]=np.clip(.55*light+.28*warm+66,0,255)
    p[:,:,1]=np.clip(.27*light+.11*warm+16 + 97*hot,0,255)
    p[:,:,2]=np.clip(.40*light+.16*warm+40 + 102*hot,0,255)
    p[:,:,:3]=np.clip(p[:,:,:3]*(.95+.09*np.sin(phase))+hot[:,:,None]*30,0,255)
    p[:,:,3]=np.clip(p[:,:,3]*level,0,255)
    p[p[:,:,3]<3,:3]=0
    return Image.fromarray(p.astype("uint8"),"RGBA")
def warp(src,frame,phase,dx=5.4):
    # Multi-frequency spatial displacement by rows/columns, unlike global rotation.
    p=np.asarray(src,dtype=np.uint8)
    h,w=p.shape[:2]
    yy,xx=np.indices((h,w),dtype=np.float32)
    tt=float(frame)
    x=(xx+dx*np.sin(yy*.078+tt*.41+phase)+2.8*np.sin(xx*.034-tt*.61)).clip(0,w-1).astype(int)
    y=(yy+3.2*np.sin(xx*.054-tt*.48)+1.9*np.sin(yy*.13+tt*.26)).clip(0,h-1).astype(int)
    return Image.fromarray(p[y,x],"RGBA")
def feather(im,depth=.23):
    x=np.asarray(im,dtype=np.uint8).copy()
    h,w=x.shape[:2]
    yy,xx=np.indices((h,w),dtype=np.float32)
    nx=(xx-.5*w)/(.49*w);ny=(yy-.5*h)/(.49*h)
    theta=np.arctan2(ny,nx)
    r=np.sqrt(nx*nx+ny*ny)
    edge=1+.08*np.sin(5*theta)+.035*np.sin(11*theta+1.5)
    f=np.clip((edge-r)/depth,0,1)
    f=f*f*(3-2*f)
    # No axis-aligned matte artifacts.
    s=np.minimum.reduce([xx/w,(w-1-xx)/w,yy/h,(h-1-yy)/h])
    edge2=np.clip(s/.038,0,1)
    x[:,:,3]=np.uint8(x[:,:,3].astype(np.float32)*f*edge2)
    x[x[:,:,3]<4,:3]=0
    return Image.fromarray(x,"RGBA")
def over(dst,src,pos,glow=.20,intensity=1):
    if intensity<=0:return
    fg=src.copy()
    fg.putalpha(fg.getchannel("A").point(lambda a:min(255,round(a*intensity))))
    layer=Image.new("RGBA",dst.size)
    layer.alpha_composite(fg,(round(pos[0]),round(pos[1])))
    bloom=layer.filter(ImageFilter.GaussianBlur(7))
    bloom.putalpha(bloom.getchannel("A").point(lambda a:round(a*glow)))
    dst.alpha_composite(bloom)
    dst.alpha_composite(layer)
def focus_ink(im,phase):
    # Compact *broken meridian* symbol, handwritten split with irregular taper.
    d=ImageDraw.Draw(im,"RGBA")
    q=1+.035*math.sin(phase*math.tau)
    pts=[(154,147),(165,157),(151,168),(172,181)]
    pts=[(int(160+(x-160)*q),int(162+(y-162)*q)) for x,y in pts]
    d.line(pts,fill=(150,8,44,190),width=10,joint="curve")
    d.line(pts,fill=(251,92,132,235),width=5,joint="curve")
    d.line(pts,fill=(255,233,220,242),width=2,joint="curve")
def charge(i):
    t=i/7
    dst=Image.new("RGBA",(CELL,CELL))
    for j in range(3):
        raw=crop(CROWN,"crown",(i+j*3)%10)
        mat=feather(ruby(warp(raw,i+j,1.3+j),.62+.2*t,phase=i*.27))
        scale=.42+.18*t
        sz=(round(230*scale),round(145*scale))
        m=mat.resize(sz,Image.Resampling.LANCZOS)
        ang=j*2*math.pi/3+i*.19
        rad=35-23*t
        x=160+rad*math.cos(ang)-sz[0]/2
        y=159+rad*.72*math.sin(ang)-sz[1]/2
        over(dst,m,(x,y),glow=.3,intensity=.66+.24*t)
    inner=crop(CONTACT,"contact",(i*2)%8)
    inner=feather(ruby(warp(inner,i,2.7),.6+.30*t,i*.15),depth=.25)
    m=inner.resize((76+round(17*t),66+round(16*t)),Image.Resampling.LANCZOS)
    over(dst,m,(160-m.width/2,160-m.height/2),glow=.46,intensity=.75)
    return dst
def contact(i):
    t=i/11
    dst=Image.new("RGBA",(CELL,CELL))
    # One dense inward whirlpool of genuine painterly pixels, not three strokes/claws.
    src=crop(CROWN,"crown",min(9,int((.25+.70*t)*9)))
    src=feather(ruby(warp(src,i*1.32,.8),.82+.13*math.sin(t*math.pi),i*.09),depth=.34)
    scale=1.09-.42*t+.04*math.sin(t*math.pi)
    cw,ch=(round(280*scale),round(184*scale))
    m=src.resize((cw,ch),Image.Resampling.LANCZOS)
    # Asymmetrical compressed qi whorl, single target chest.
    m=m.rotate(-9+17*math.sin(t*math.pi),Image.Resampling.BICUBIC,expand=True)
    over(dst,m,((320-m.width)/2,(320-m.height)/2),glow=.32,intensity=.89)
    # Localized chest collapse: source-painted contact overtakes ambient at 70% progress.
    core=crop(CONTACT,"contact",min(7,int(t*7.99)))
    core=feather(ruby(warp(core,i,2.1),(.15+.76*max(0,t-.3)/.7),t),depth=.38)
    cs=round(70+78*math.sin(t*math.pi*.94))
    core=core.resize((cs,round(cs*.83)),Image.Resampling.LANCZOS)
    over(dst,core,(160-cs/2,159-core.height/2),glow=.32,intensity=.70)
    if t>.46:focus_ink(dst,t)
    return dst
def mark(i):
    t=i/8
    dst=Image.new("RGBA",(CELL,CELL))
    # Pulse artifact at torso, no 3 separate claws, no explosion repeated each tick.
    core=crop(CONTACT,"contact",(i+1)%8)
    core=feather(ruby(warp(core,i*.7,3.2),.66+.16*math.sin(t*math.tau),t),depth=.38)
    w=114+round(5*math.sin(t*math.tau));h=round(w*.85)
    tiny=core.resize((w,h),Image.Resampling.LANCZOS)
    over(dst,tiny,((CELL-w)/2,(CELL-h)/2),glow=.34,intensity=.78)
    focus_ink(dst,t)
    return dst
stats={}
for kind,count in (("charge",8),("contact",12),("mark",8)):
    atlas=Image.new("RGBA",(CELL*4,CELL*((count+3)//4)))
    sig=set()
    for i in range(count):
        im={"charge":charge,"contact":contact,"mark":mark}[kind](i)
        a=np.asarray(im.getchannel("A"))
        assert np.count_nonzero(a>45)>200,(kind,i)
        assert a[0,:].max()<5 and a[-1,:].max()<5 and a[:,0].max()<5 and a[:,-1].max()<5,(kind,i,"hard crop")
        sig.add(hashlib.sha256(im.tobytes()).hexdigest())
        atlas.alpha_composite(im,((i%4)*CELL,(i//4)*CELL))
    assert len(sig)==count,(kind,"duplicate")
    f=OUT/("f13_"+kind+".png")
    atlas.save(f,optimize=True)
    stats[kind]={"frames":count,"atlas_px":list(atlas.size),"file_sha256":hashlib.sha256(f.read_bytes()).hexdigest()}
hero=contact(8)
hero.save(OUT/"f13_original_code_painted_hero.png",optimize=True)
(OUT/"f13_art_source_manifest.json").write_text(json.dumps({
    "revision":"R3","art_source":"first-party project-owned previously painted pigment, newly recomposed/warped",
    "actual_masters":["godot/labs/combat_lab/poison11/r1_original/assets/poison11_crown_10_r9.png",
                      "godot/labs/combat_lab/poison11/r1_original/assets/poison11_contact_08.png"],
    "derivative_not_novel_painted_original":True,
    "generated_source_png":"f13_original_code_painted_hero.png",
    "no_gif":True,"no_rig":True,"views_only":True,"atlases":stats},indent=2),encoding="utf-8")
print("FIST13_R3_PAINTED_MATERIAL_BAKE_PASS poses=28 atlas=3 no_gif=true no_rig=true")
