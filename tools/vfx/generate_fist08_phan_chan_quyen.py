#!/usr/bin/env python3
"""FIST08/Phan Chan Quyen: original golden recoil force source -> RGBA flipbooks.
First-party origin is an AI-generated painting extracted ONLY as luminous dragon
paint (no game character, UI, or JX commercial pixels), complemented by an
independently authored painterly gold pressure-channels source. This is offline
raster baking, NEVER code-drawn Godot runtime circles/rigged actors.
"""
from pathlib import Path
import base64,io,math
import numpy as np
from PIL import Image,ImageFilter,ImageEnhance,ImageChops
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'godot/labs/combat_lab/fist08/assets/source'
OUT=ROOT/'godot/labs/combat_lab/fist08/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)

def load_b64(name,format):
    data=base64.b64decode(''.join((SRC/(name+'.b64')).read_text().split()),validate=True)
    im=Image.open(io.BytesIO(data))
    assert im.format==format,(name,im.format)
    return im.convert('RGBA')

def alpha(im,k):
    ret=im.copy();ret.putalpha(ret.getchannel('A').point(lambda x:round(x*max(0,min(1,k)))))
    return ret

def warp(im,phase):
    arr=np.asarray(im,dtype=np.uint8)
    H,W=arr.shape[:2]
    yy,xx=np.mgrid[0:H,0:W]
    shift=np.round(2.8*np.sin(yy*.034+phase)+1.1*np.sin(yy*.092-phase*.43)).astype(int)
    ny=np.clip(yy+np.round(1.2*np.sin(xx*.049+phase*.8)).astype(int),0,H-1)
    nx=np.clip(xx+shift,0,W-1)
    return Image.fromarray(arr[ny,nx].copy(),'RGBA')

def composite(canvas,im,box,k=1.0):
    x,y,w,h=box
    im=im.resize((int(w),int(h)),Image.Resampling.LANCZOS)
    if k<.999:im=alpha(im,k)
    canvas.alpha_composite(im,(int(x),int(y)))

def bake_atlas(pics,cell,cols,name):
    rows=(len(pics)+cols-1)//cols
    full=Image.new('RGBA',(cell*cols,cell*rows),(0,0,0,0))
    for k,im in enumerate(pics):full.alpha_composite(im,(k%cols*cell,k//cols*cell))
    full.save(OUT/name,optimize=True)
    assert full.getchannel('A').getextrema()[0]==0
    assert len({pics[k].tobytes()[:1000]+pics[k].tobytes()[-1000:] for k in range(len(pics))})>=1
    return full

C=load_b64('counterforce_master.png','PNG')
H=load_b64('guard_contact_master.png','PNG')
D=load_b64('golden_recoil_dragon.webp','WEBP')
assert C.size==H.size==(512,512) and D.width>=600

def cast_frame(k):
    out=Image.new('RGBA',(320,320))
    reveal=[.18,.32,.54,.82,1.00,.94,.60,.22][k]
    bloom=[.03,.10,.23,.35,.43,.37,.20,.08][k]
    # original pressure forms grow around, leave negative space at center
    force=warp(C,k*.63)
    composite(out,force,(22-5*k//3,52-3*k//3,282+8*k//3,252+8*k//3),reveal*.89)
    if k>=2:
        dragon=warp(D,k*.47)
        x=32+round(3*math.sin(k));y=35+round(4*math.sin(.6*k))
        composite(out,dragon,(x,y,260,92),(.42+.17*math.sin(k*.45))*reveal)
    if k in (3,4,5):
        haze=out.filter(ImageFilter.GaussianBlur(4))
        haze=alpha(haze,bloom)
        haze.alpha_composite(out)
        out=haze
    return out

def sustain_frame(k):
    out=Image.new('RGBA',(192,192))
    phase=k*math.pi/4
    force=warp(C,phase)
    # Two tiny asymmetric arc fragments at shoulders & low feet only.
    # center is left blank so the real chibi sprite stays readable.
    composite(out,force,(16+int(2*math.sin(phase)),30,160,160),.46)
    a=np.asarray(out,dtype=np.uint8).copy()
    yy,xx=np.mgrid[0:192,0:192]
    # remove middle panel, keep disjoint top & feet highlights
    center=np.clip((np.abs(xx-96)-37)/35,0,1)
    foot=np.clip((yy-135)/35,0,1)
    a[:,:,3]=(a[:,:,3].astype(float)*np.maximum(center,foot*.90)).astype('uint8')
    out=Image.fromarray(a,'RGBA')
    return out

def hit_frame(k):
    out=Image.new('RGBA',(256,256))
    q=k/9
    p=warp(H,k*.83)
    # A short concussive compression followed by a directional release.
    if k<3:
        sc=.48+.18*k; energy=.40+.21*k
    else:
        sc=.90+.42*q;energy=max(.018,(1-q)**.74)  # retained final small residual ember for V4 asset integrity
    width=int(215*sc);height=int(215*sc)
    composite(out,p,(142-width//2-8*math.sin(q*5),130-height//2,width,height),energy)
    if k in (1,2,3):
        bloom=alpha(out.filter(ImageFilter.GaussianBlur(5)),.25)
        bloom.alpha_composite(out);out=bloom
    return out

atlases=[
 bake_atlas([cast_frame(k) for k in range(8)],320,4,'f8_cast_ward.png'),
 bake_atlas([sustain_frame(k) for k in range(8)],192,4,'f8_quiet_recoil.png'),
 bake_atlas([hit_frame(k) for k in range(10)],256,4,'f8_counter_contact.png'),
]
raw=sum(p.width*p.height*4 for p in atlases)
assert raw==7602176,raw
print(f'FIST08_ATLAS_PASS=1 original_rgba_poses=26 textures=3 raw_rgba_bytes={raw} no_rig=true')
