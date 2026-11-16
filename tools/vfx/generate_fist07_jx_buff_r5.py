#!/usr/bin/env python3
"""FIST07 R5 illustrated JX-style LONG GUARD: burst-once, quiet sustained buff,
reactive block, fade. Bakes first-party ImageGen guardian master; never copies JX.
No hand-coded shield geometry, no unlicensed sprites, no skeletal rig.
"""
from pathlib import Path
import base64,io,math,random
import numpy as np
from PIL import Image,ImageFilter,ImageEnhance,ImageDraw
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'godot/labs/combat_lab/fist07/assets/source/kim_cang_guardian_master_r5.webp.b64'
OUT=ROOT/'godot/labs/combat_lab/fist07/assets/generated'
SEED=161107

def load_master():
    buf=base64.b64decode(''.join(SRC.read_text(encoding='ascii').split()),validate=True)
    with Image.open(io.BytesIO(buf)) as x: im=x.convert('RGBA')
    assert im.width>=600 and im.height>=600
    # ImageGen's black near-zero alpha background is intentional transparency.
    a=np.asarray(im.getchannel('A'),dtype=np.float32)
    rgba=np.array(im,dtype=np.uint8)
    rgba[:,:,3]=np.where(a<5,0,a).astype(np.uint8)
    return Image.fromarray(rgba,'RGBA')

def alpha_scale(img,factor):
    rgba=img.copy(); rgba.putalpha(rgba.getchannel('A').point(lambda p:int(p*factor)))
    return rgba

def scaled(img,size):
    return img.resize(size,Image.Resampling.LANCZOS)

def with_soft_edge(src):
    a=np.asarray(src.getchannel('A'),dtype=np.uint8)
    # Suppress near-black fringe pixels from matte, not luminous gold.
    rgba=np.array(src,dtype=np.uint8)
    rgb=rgba[:,:,:3].astype(np.int16)
    vivid=(rgb[:,:,0]>55) & (rgb[:,:,0]>rgb[:,:,2]+7)
    rgba[:,:,3]=np.where(vivid,a, np.round(a*.15)).astype('uint8')
    return Image.fromarray(rgba,'RGBA')

def warp(im, phase, amplitude=1.5):
    # Authored source content has living heat: small row-wise displacements,
    # not whole-screen scale-only animation or any skeletal movement.
    rgba=np.asarray(im,dtype=np.uint8)
    yy=np.arange(im.height)[:,None]
    xx=np.arange(im.width)[None,:]
    shift=np.round(amplitude*np.sin(yy*.038+phase)+.55*np.sin(yy*.091-phase)).astype('int32')
    idx=np.clip(np.broadcast_to(xx+shift,rgba.shape[:2]),0,im.width-1)
    out=rgba[np.broadcast_to(yy,rgba.shape[:2]),idx]
    return Image.fromarray(out.copy(),'RGBA')

def region(src,xywh,scale):
    x,y,w,h=xywh
    return scaled(src.crop((x,y,x+w,y+h)),scale)

def gold_matte(im, strength=.9, feather=True):
    arr=np.asarray(im.convert('RGBA'),dtype=np.uint8).copy()
    rgb=arr[:,:,:3].astype(float); a=arr[:,:,3].astype(float)
    light=np.max(rgb,axis=2)
    # Keep only real gold/white paint; eliminate dark black poster holes.
    chroma=np.clip((rgb[:,:,0]-rgb[:,:,2]-12.)/56.,0,1)
    a*=np.clip((light-110.)/135.,0,1)*np.maximum(.2,chroma)
    if feather:
        h,w=a.shape
        x=np.sin(np.pi*(np.arange(w)+.5)/w)**.75
        y=np.sin(np.pi*(np.arange(h)+.5)/h)**.75
        a*=y[:,None]*x[None,:]
    arr[:,:,3]=np.clip(a*strength,0,255).astype('uint8')
    return Image.fromarray(arr,'RGBA')

def make_cast(src,k):
    """8 visually distinct key poses; illustrated guardian manifests and
    dome blooms, then retracts into smaller JX-style sustained-status icon.
    This CAST lasts 0.0–0.76 LAB seconds, not 4 seconds.
    """
    S=320
    out=Image.new('RGBA',(S,S),(0,0,0,0))
    src=scaled(src,(S,S))
    src=warp(src,k*.43,1.1+1.2*math.sin(k*.39)**2)
    # Actual drawing from high-res master; material and movement are baked.
    arr=np.asarray(src,dtype=np.uint8).copy()
    yy=np.arange(S)[:,None]
    # Top spirit, middle dome and lotus ring rise at distinct beats.
    top=np.clip((190-yy)/67.,0.,1.)
    dome=np.clip((yy-91.)/76.,0.,1.)*np.clip((294-yy)/80.,0.,1.)
    lotus=np.clip((yy-245.)/38.,0.,1.)
    levels=[(.03,.02,.35),(.09,.15,.65),(.27,.29,.95),(.57,.62,1.00),
            (.81,.82,1.), (1.,1.,1.), (.92,.91,.78),(.38,.34,.38)]
    g,d,l=levels[k]
    strength=np.clip(g*top+d*dome+l*lotus,.04,1.)
    # Progressive reveal of illustrated guardian eyes/hands; never rect-cut.
    if k<=4:
        reveal=np.clip((yy-(165-33*k))/60.,0,1)
        strength=np.maximum(strength*reveal, strength*.22)
    arr[:,:,3]=(arr[:,:,3].astype(float)*strength).astype('uint8')
    out=Image.fromarray(arr,'RGBA')
    if k in (3,4,5):
        soft=out.filter(ImageFilter.GaussianBlur(5));soft=alpha_scale(soft,.20)
        soft.alpha_composite(out)
        out=soft
    return out

def make_sustain(src,k):
    """Small quiet status loop: open shoulder fragments + tiny ground-glow.
    Avoids a giant dome persistent for 4 seconds. The true state icon in
    the future HUD must be bound to Combat V2 receipts (LAB uses demo only).
    """
    S=192;im=Image.new('RGBA',(S,S),(0,0,0,0))
    phase=2*math.pi*k/8.
    master=src.resize((768,768),Image.Resampling.LANCZOS)
    # source LOWER LOTUS only. Small ellipse-like painted art is cropped,
    # not reconstructed as a programmatic neon ring.
    foot=region(master,(18,613,732,128),(178,34))
    foot=alpha_scale(foot,.71+.14*math.cos(phase*.94))
    im.alpha_composite(foot,(7,153+round(1.4*math.sin(phase))))
    # Tiny live brush arcs at shoulder/neck, only cut from original gold art.
    left=gold_matte(region(master,(11,289,242,290),(39,86)),1.0)
    right=gold_matte(region(master,(512,293,246,290),(39,86)),1.0)
    left=warp(left,phase*.4,1.1); right=warp(right,-phase*.4,1.1)
    im.alpha_composite(alpha_scale(left,.24+.06*math.cos(phase)),(23+round(2*math.sin(phase)),38))
    im.alpha_composite(alpha_scale(right,.23+.065*math.sin(phase)),(132+round(2*math.cos(phase)),39))
    # one subtle floating point near chest, from genuine guardian eye highlight.
    eye=region(master,(340,220,90,83),(20,22))
    im.alpha_composite(alpha_scale(eye,.27+.06*math.sin(phase)),(84,90+round(2*math.sin(phase))))
    return im

def make_block(src,k):
    """Fast white-hot painted barrier fracture, 0.24sec. Cut only GOLD
    strokes from the original illustration, keep background fully transparent.
    No geometric GDScript sparks or fake damage.
    """
    S=256;im=Image.new('RGBA',(S,S),(0,0,0,0))
    q=k/7.
    m=scaled(src,(768,768))
    # These are the brightest hand and base streaks, avoiding the dome's
    # transparent middle altogether. All material remains authored pixels.
    strips=[
        (gold_matte(m.crop((78,616,693,706)),1.1),(196+round(24*q),46),-25+9*q,(111,125)),
        (gold_matte(m.crop((100,354,316,530)),1.0),(84+round(22*q),103),25-7*q,(152,123)),
        (gold_matte(m.crop((449,354,674,531)),1.0),(85+round(24*q),100),-22+8*q,(153,122)),
    ]
    for art,(w,h),rot,(cx,cy) in strips:
        part=scaled(art,(w,h)).rotate(rot,Image.Resampling.BICUBIC,expand=True)
        # clip without painting a rectangular border or colored fill
        temp=Image.new('RGBA',(S,S),(0,0,0,0));temp.paste(part,(cx-part.width//2,cy-part.height//2),part)
        im.alpha_composite(alpha_scale(temp,(1-q)**.88*.98))
    halo=im.filter(ImageFilter.GaussianBlur(6))
    halo=alpha_scale(halo,(1-q)*.42)
    halo.alpha_composite(im)
    return halo

def atlas(frames,cols,name):
    size=frames[0].size[0]
    rows=(len(frames)+cols-1)//cols
    out=Image.new('RGBA',(cols*size,rows*size),(0,0,0,0))
    for i,x in enumerate(frames):out.alpha_composite(x,((i%cols)*size,(i//cols)*size))
    OUT.mkdir(parents=True,exist_ok=True)
    dest=OUT/name;out.save(dest,optimize=True)
    assert out.getchannel('A').getextrema()[0]==0
    print('FIST07_R5_ATLAS',name,out.size,'frames',len(frames))
    return out

def main():
    original=with_soft_edge(load_master())
    cast=atlas([make_cast(original,i) for i in range(8)],4,'r5_cast_guardian.png')
    sustain=atlas([make_sustain(original,i) for i in range(8)],4,'r5_quiet_status.png')
    contact=atlas([make_block(original,i) for i in range(8)],4,'r5_guard_contact.png')
    # Small original icon only in the isolated LAB for QA; not the real buff UI.
    icon=scaled(original.crop((287,123,477,330)),(64,64))
    icon.save(OUT/'r5_demo_buff_icon.png',optimize=True)
    raw=sum(im.width*im.height*4 for im in [cast,sustain,contact])
    assert raw==6553600,raw
    print('FIST07_R5_BAKE_PASS atlases=3 poses=24 rgba_bytes=6553600 source=original_illustrated_no_rig')

if __name__=='__main__':main()
