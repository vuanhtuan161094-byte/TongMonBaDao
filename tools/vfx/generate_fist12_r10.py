#!/usr/bin/env python3
"""FIST12 R10, artist-reviewed branch candidate: source-preserved painterly fist VFX.
The independent first-party true-alpha source masters are the six R9 original
image-generated sprite pages, not copyrighted VL/JX pixels or promo posters.
R10 re-authors direction, opacity and posing rather than merely recoloring R9:
jab rightwards, ascending hooked strike and dense axial finisher; one local
contact and a small broken vein mark. No skeleton rig / GIF / gameplay.
SOURCE IS A DERIVATIVE of owner-rejected R9 master art, not a brand-new painting.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageEnhance
import numpy as np, io, base64, hashlib, math, json
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'godot/labs/combat_lab/fist12/assets/r9_sources'
OUT=ROOT/'godot/labs/combat_lab/fist12/assets/r10_generated'
OUT.mkdir(parents=True,exist_ok=True)
CELL=320; SC=224
NAMES=('charge','punch1','punch2','punch3','contact','mark')
def source(name):
    raw=base64.b64decode(''.join((SRC/f'f12_r9_{name}_master.webp.b64').read_text().split()),validate=True)
    im=Image.open(io.BytesIO(raw)).convert('RGBA')
    assert im.size==(896,448),(name,im.size)
    keys=[]
    for i in range(8):
        src=im.crop((i%4*SC,i//4*SC,((i%4)+1)*SC,((i//4)+1)*SC))
        keys.append(src)
    return keys,hashlib.sha256(raw).hexdigest()
MASTER={};SRC_HASHES={}
for name in NAMES:
    MASTER[name],SRC_HASHES[name]=source(name)
def pigment(src,power=1.0,hot=.0):
    z=np.asarray(src.convert('RGBA'),dtype=np.float32).copy()
    rgb=z[:,:,:3].copy()
    y=(.45*rgb[:,:,0]+.40*rgb[:,:,1]+.15*rgb[:,:,2])/255.0
    k=np.clip((y-.54)/.43,0,1)**1.6
    # Genuine brushwork retained, white-gold knuckle foci; moderate saturation.
    z[:,:,0]=np.clip(rgb[:,:,0]*1.06+18*k+10*hot,0,255)
    z[:,:,1]=np.clip(rgb[:,:,1]*1.02+64*k+32*hot*k,0,255)
    z[:,:,2]=np.clip(rgb[:,:,2]*1.03+43*k+23*hot*k,0,255)
    z[:,:,3]=np.clip(z[:,:,3]*power,0,255)
    z[z[:,:,3]<4,:3]=0
    return Image.fromarray(z.astype(np.uint8),'RGBA')
def feather(img):
    a=np.asarray(img.getchannel('A'),dtype=np.float32)
    hh,ww=a.shape
    yy,xx=np.mgrid[:hh,:ww]
    f=np.minimum.reduce([xx,(ww-1-xx),yy,(hh-1-yy)])
    f=np.clip(f/14.0,0,1)
    out=img.copy()
    out.putalpha(Image.fromarray(np.uint8(a*f),'L'))
    return out
def overlay(dst,img,xy,gain=1.0,halo=.0):
    if gain<=0:return
    x=int(round(xy[0]));y=int(round(xy[1]))
    src=img.copy()
    src.putalpha(src.getchannel('A').point(lambda p:int(min(255,p*gain))))
    layer=Image.new('RGBA',dst.size)
    layer.alpha_composite(src,(x,y))
    if halo:
        blur=layer.filter(ImageFilter.GaussianBlur(6))
        blur.putalpha(blur.getchannel('A').point(lambda p:int(p*halo)))
        dst.alpha_composite(blur)
    dst.alpha_composite(layer)
def centered(dst,src,x,y,w,h,rotation=0,gain=1.0,halo=.0):
    p=src.resize((max(4,round(w)),max(4,round(h))),Image.Resampling.LANCZOS)
    if rotation:p=p.rotate(rotation,Image.Resampling.BICUBIC,expand=True)
    overlay(dst,p,(x-p.width*.5,y-p.height*.5),gain,halo)
def charge(i):
    t=i/7.0
    out=Image.new('RGBA',(CELL,CELL))
    q=MASTER['charge'][i]
    p=pigment(feather(q),power=.70+.23*t,hot=.14)
    # Compressed hand qi: not a round spell circle; cropped curls move toward fist.
    centered(out,p,154,167,94+72*t,89+65*t,rotation=-12+5*math.sin(t*math.pi),gain=.94,halo=.20)
    return out
def pressure(beat,i):
    t=i/7.0
    out=Image.new('RGBA',(CELL,CELL))
    name=('punch1','punch2','punch3')[beat]
    keys=MASTER[name]
    # Source keys evolve independently; phase poses retain source growth/fall.
    src=pigment(feather(keys[i]),power=.90 if beat<2 else .97,hot=.06 if beat<2 else .18)
    if beat==0:
        # Piercing short lead jab, lower left to upper right; narrow directional tip.
        w,h=244,110
        cx,cy=159,164
        rotation=-12
    elif beat==1:
        # Hook/uppercut distinct angular direction, up-right rather than same horizontal disc.
        w,h=202,151
        cx,cy=169,151
        rotation=40
    else:
        # Heavy straight ending: very thick bright fist head and shorter dense trail.
        w,h=280,185
        cx,cy=165,161
        rotation=-4
    centered(out,src,cx,cy,w*(.92+.09*math.sin(t*math.pi)),h,
             rotation,gain=.99,halo=.13 if beat<2 else .22)
    if beat==2 and 2<=i<=6:
        # Real painted local collision pigment only at heaviest final punch.
        contact=pigment(feather(MASTER['contact'][i]),power=.62,hot=.6)
        centered(out,contact,231,154,81+19*math.sin(t*math.pi),88+11*math.sin(t*math.pi),
                 rotation=9,gain=.77,halo=.23)
    return out
def contact(i):
    t=i/7.0
    out=Image.new('RGBA',(CELL,CELL))
    src=pigment(feather(MASTER['contact'][i]),power=.76+.17*(1-t),hot=.30)
    # Short intense contact, taper after center peak.
    scale=1+.09*math.sin(t*math.pi)
    centered(out,src,160,161,238*scale,236*scale,gain=.91,halo=.20)
    return out
def mark(i):
    t=i/8.0
    out=Image.new('RGBA',(CELL,CELL))
    src=pigment(feather(MASTER['mark'][i]),power=.81+.10*math.sin(t*math.tau),hot=.1)
    # Recompose ORIGINAL painted energy into compact interrupted MERIDIAN imprint.
    # It remains tiny at game scale, not another full-screen burn or huge sigil.
    centered(out,src,159,158,142,66,rotation=76,gain=.86,halo=.13)
    opp=pigment(feather(MASTER['mark'][(i+3)%8]),power=.58)
    centered(out,opp,157,157,95,41,rotation=14,gain=.53)
    return out
pages={
    'r10_charge.png':([charge(i) for i in range(8)],8),
    'r10_punches.png':([pressure(b,i) for b in range(3) for i in range(8)],24),
    'r10_contact.png':([contact(i) for i in range(8)],8),
    'r10_mark.png':([mark(i) for i in range(8)],8),
}
report={'art_source_class':'FIRST_PARTY_R9_INDEPENDENT_PAINTED_SOURCE_DERIVATIVE','source_sha256':SRC_HASHES,'revision':'R10',
        'rejected_previous_owner_version':'R9','new_master_created':False,'atlas':{}}
for f,(frames,count) in pages.items():
    atlas=Image.new('RGBA',(1280,320*((count+3)//4)))
    sig=set()
    for i,im in enumerate(frames):
        a=np.asarray(im.getchannel('A'),dtype=np.uint8)
        # The first windup pose may be intentionally tiny, never falsely QA-fail it.
        # Every active impact/fist pose still must carry visible opaque pixels.
        visible=int((a>35).sum())
        min_pixels=5 if f=='r10_charge.png' and i<2 else 100
        assert visible>min_pixels,(f,i,'near invisible',visible)
        assert int((a[0,:]>35).sum()+(a[-1,:]>35).sum()+(a[:,0]>35).sum()+(a[:,-1]>35).sum())<30,(f,i,'hard crop edge')
        sig.add(hashlib.sha256(im.tobytes()).hexdigest())
        atlas.alpha_composite(im,((i%4)*CELL,(i//4)*CELL))
    assert len(sig)==count,(f,'duplicate')
    p=OUT/f;atlas.save(p,optimize=True)
    report['atlas'][f]={'frame_count':count,'size_px':list(atlas.size),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
(OUT/'r10_source_manifest.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
print('FIST12_R10_BAKE_PASS poses=48 masters=R9_INDEPENDENT_SOURCE_DERIVATIVE no_gif=true no_rig=true')
