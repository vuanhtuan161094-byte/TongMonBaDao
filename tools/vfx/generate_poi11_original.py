#!/usr/bin/env python3
"""POI11 Vạn Độc Xuyên Tâm: original first-party painted-sprite alpha flipbooks.
Masters are independently extracted first-party image-generated VFX light artwork,
NOT a UI poster, third-party pixels, a Godot capture, or a faux gameplay screenshot.
Motion transforms the painted pixels with per-pose nonrigid deformation and alpha.
Character rigging, SVG/line primary effects and shared POI10 skill textures are absent.
"""
from PIL import Image, ImageFilter, ImageEnhance, ImageChops, ImageDraw
from pathlib import Path
import hashlib, math, random
from functools import lru_cache
import numpy as np
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'godot/labs/combat_lab/poison11/r1_original/assets'
MASTER=OUT/'master'
FILES={
    'charge':'needle_crown_source.webp',
    'flight':'heart_piercer_source.webp',
    'crown':'heart_vortex_source.webp',
    'contact':'heart_rupture_source.webp',
}
@lru_cache(maxsize=3)
def source(name):
    p=MASTER/FILES[name]
    if not p.is_file():raise FileNotFoundError('original first-party master missing '+str(p))
    im=Image.open(p).convert('RGBA')
    assert im.width>=600 and im.height>=500,(name,im.size)
    # Art stop gate: remove illustrated UI-poster background, not only corner alpha.
    # Preserve actual white/jade/violet painted strokes; suppress low-chroma rectangles.
    pix=np.asarray(im).copy()
    rgb=pix[:,:,:3].astype(np.float32)
    original=pix[:,:,3].astype(np.float32)
    signal=np.maximum.reduce([rgb[:,:,0]*.98,rgb[:,:,1]*1.48,rgb[:,:,2]*.77])
    pigment=np.clip((signal-(105.0 if name=='charge' else 76.0))*(3.9 if name=='charge' else 3.25),0,255)
    hh,ww=original.shape
    ys,xs=np.mgrid[:hh,:ww]
    edge=np.minimum.reduce([xs,ww-1-xs,ys,hh-1-ys]); edgegain=np.clip(edge/16.0,0,1)
    # Clean art *envelope* around unique charge master; no massive rectangular alpha.
    if name=='charge':
        dx=(xs-ww*.50)/(ww*.42);dy=(ys-hh*.51)/(hh*.48)
        d=np.sqrt(dx*dx+dy*dy)
        envelope=np.clip((1.06-d)/.22,0,1)
        edgegain*=envelope
    if name=='crown':
        # Concept image contains painted ground at its lower edge. Remove the
        # straight cropped-floor alpha line; keep only airborne emissive vortex.
        edgegain*=np.clip((hh*.91-ys)/(hh*.22),0,1)
    alpha=np.clip(original*(pigment/255.0)*edgegain*1.14,0,255)
    # Colored pixels brighten a little, but alpha always carries shape/material.
    pure=np.clip(rgb*1.13+np.where(alpha[:,:,None]>60,5,0),0,255)
    pix[:,:,:3]=pure.astype(np.uint8)
    pix[:,:,3]=alpha.astype(np.uint8)
    pix[pix[:,:,3]<3,:3]=0
    return Image.fromarray(pix,'RGBA')

def row_warp(im,t,amplitude=4.0,frequency=3):
    # Move actual brushstrokes in local bands, with neighboring strokes changing
    # differently instead of a whole static frame merely rotated and tinted.
    w,h=im.size
    rows=[]
    arr=np.asarray(im).copy()
    yy=np.arange(h,dtype=np.float32)
    shifts=np.rint(amplitude*np.sin((yy/h)*math.tau*frequency+t*math.tau*1.2)+amplitude*.43*np.sin(yy/h*math.tau*5.1-t*math.tau*.6)).astype(np.int32)
    warped=np.zeros_like(arr)
    for y,shift in enumerate(shifts):
        if shift>=0:warped[y,shift:,:]=arr[y,:w-shift,:]
        else:warped[y,:w+shift,:]=arr[y,-shift:,:]
    return Image.fromarray(warped,'RGBA')

def feather_frame(im,w,h):
    result=im.resize((w,h),Image.Resampling.LANCZOS)
    mask=Image.new('L',(w,h),255);md=ImageDraw.Draw(mask)
    md.rectangle((0,0,w-1,1),fill=0);md.rectangle((0,h-2,w-1,h-1),fill=0)
    md.rectangle((0,0,1,h-1),fill=0);md.rectangle((w-2,0,w-1,h-1),fill=0)
    result.putalpha(ImageChops.multiply(result.getchannel('A'),mask))
    return result

def pose(name,i,total,cell):
    w,h=cell;t=i/max(1,total-1)
    im=source(name)
    im=row_warp(im,t,5.2 if name in ('crown','flight') else 3.8,4 if name=='flight' else 3)
    if name=='charge':
        # Crown point erects from a compact charge, then gathers closer to release.
        scale=.48+.44*math.sin((t*.92+.05)*math.pi/2)
        gain=.67+.33*math.sin((t*.83+.10)*math.pi/2)
        angle=-4+7*math.sin(t*math.pi*.75)
    elif name=='flight':
        # Distinct poison spear-cluster travel, no reuse of the radial vortex art.
        scale=.73+.24*math.sin((t*.95+.02)*math.pi/2)
        gain=.84+.16*math.sin((t*.78+.2)*math.pi/2)
        angle=-6+11*t+math.sin(t*math.tau)*2
    elif name=='crown':
        # First-party hand-painted high-chroma vortex is the expanding circular ultimate.
        scale=.52+.46*math.sin((t*.89+.11)*math.pi/2)
        gain=.78+.22*math.sin((t*.8+.1)*math.pi/2)
        angle=-5+8*t
    else:
        # Penetration lights reach peak in the first third then disintegrate.
        scale=.37+.62*math.sin((.10+.75*t)*math.pi/2)
        gain=(.70+.30*math.sin(min(1,.20+1.10*t)*math.pi/2))*(1-.62*max(0,(t-.52)/.48))
        angle=-3+6*math.sin(t*math.pi)
    im=im.rotate(angle,Image.Resampling.BICUBIC,expand=False)
    nw=max(1,int(w*scale));nh=max(1,int(h*scale))
    im=im.resize((nw,nh),Image.Resampling.LANCZOS)
    canvas=Image.new('RGBA',(w,h),(0,0,0,0))
    # Place painted focus on each cell center; native Godot controls layer anchoring.
    canvas.alpha_composite(im,((w-nw)//2,(h-nh)//2))
    # Small independently animated painted bloom, with no hard circles or geometry.
    glow=canvas.filter(ImageFilter.GaussianBlur(2.8))
    glow.putalpha(glow.getchannel('A').point(lambda a:round(a*.19*gain)))
    canvas=Image.alpha_composite(glow,canvas)
    canvas.putalpha(canvas.getchannel('A').point(lambda a:min(255,int(a*gain))))
    return feather_frame(canvas,w,h)

def atlas(name,kind,count,cell):
    w,h=cell;cols=4;rows=(count+cols-1)//cols
    sheet=Image.new('RGBA',(cols*w,rows*h),(0,0,0,0))
    seen=set()
    for i in range(count):
        p=pose(kind,i,count,cell)
        a=p.getchannel('A')
        assert a.getbbox(),(name,i,'empty alpha')
        assert a.crop((0,0,w,1)).getextrema()[1]==0 and a.crop((0,h-1,w,h)).getextrema()[1]==0
        seen.add(hashlib.sha256(p.tobytes()).digest())
        sheet.alpha_composite(p,((i%cols)*w,(i//cols)*h))
    assert len(seen)==count,(name,'duplicate poses')
    dst=OUT/name;sheet.save(dst,optimize=True,compress_level=9)
    print('POI11_ATLAS',name,'frames',count,'size',sheet.size,'bytes',dst.stat().st_size)
    return sheet

def main():
    names=[('poison11_charge_10.png','charge',10,(192,192)),('poison11_flight_10.png','flight',10,(224,160)),('poison11_crown_10.png','crown',10,(320,192)),('poison11_contact_08.png','contact',8,(192,160))]
    atlas_list=[atlas(*r) for r in names]
    raw=sum(im.width*im.height*4 for im in atlas_list)
    print('POI11_RAW_RGBA8_BYTES',raw,'MiB',round(raw/1048576,3))
    assert raw<8*1024*1024
if __name__=='__main__':main()