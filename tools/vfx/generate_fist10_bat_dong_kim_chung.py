#!/usr/bin/env python3
"""FIST10 / Bất Động Kim Chung R1, reproducible first-party illustrated Bell VFX.

Independent FIST10 composition authored with numpy/Pillow and painterly
MATERIAL extracted from first-party FIST07 golden guardian illustration.
No copied JX commercial sprite, no rig, no combat runtime manipulation.
The original dedicated FIST10 ImageGen concept in ChatGPT is a separate
design reference and IS NOT this in-engine source. Disclose derivative material.
"""
from pathlib import Path
import base64, io, math, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'godot/labs/combat_lab/fist07/assets/source/kim_cang_guardian_master_r5.webp.b64'
OUT=ROOT/'godot/labs/combat_lab/fist10/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
src_bytes=base64.b64decode(''.join(SRC.read_text(encoding='ascii').split()),validate=True)
with Image.open(io.BytesIO(src_bytes)) as source:
    GOLD=source.convert('RGBA').resize((768,768),Image.Resampling.LANCZOS)
SEED=161120

def scale_alpha(image,a):
    out=image.copy()
    out.putalpha(image.getchannel('A').point(lambda p:int(max(0,min(255,p*a)))))
    return out

def center(dst,layer,xy,a=1.):
    layer=scale_alpha(layer,a)
    x=round(xy[0]-layer.width*.5)
    y=round(xy[1]-layer.height*.5)
    l=max(0,-x);t=max(0,-y)
    r=min(layer.width,dst.width-x);b=min(layer.height,dst.height-y)
    if r<=l or b<=t:return
    dst.alpha_composite(layer.crop((l,t,r,b)),(max(0,x),max(0,y)))

def bell_master():
    """768px fully transparent original bell topology, paint derived from
    the project's own illustrated gold pixels; no stretched mini-poster."""
    S=768
    yy,xx=np.mgrid[0:S,0:S].astype('float32')
    u=np.clip((yy-141.)/498.,0,1)
    radius=45.+265.*np.sin(np.pi*u/2.)**.86+12.*np.sin(np.pi*u)**2
    d=np.abs(xx-384)
    # Brass shell follows a heavy widening bell, with an OPEN center.
    edge=np.exp(-((d-radius)/14.)**2)
    shell=np.clip((radius-d)/40.,0.,1.)*.11
    lip=np.exp(-((yy-647.)/15.)**2)*np.clip((radius+23.-d)/16.,0,1)
    crown=np.exp(-((yy-176.)/15.)**2)*np.exp(-((xx-384.)/96.)**4)
    shoulder=np.exp(-((yy-361.)/12.)**2)*np.clip((radius+12.-d)/22.,0,1)
    engraving=(.50+.50*np.sin(xx*.118+np.sin(yy*.032)*2.))
    runes=engraving*np.exp(-((yy-427.)/50.)**2)*np.clip((radius-d)/70.,0,1)
    # Irregular lustrous material from already-owned FIST07 golden painting.
    material=np.asarray(GOLD,dtype=np.uint8).astype('float32')
    lum=np.max(material[:,:,:3],axis=2)/255.
    noise=np.random.default_rng(SEED).normal(0,5,(S,S)).astype('float32')
    hot=np.clip(edge*.96+lip*.95+crown*.83+shoulder*.70,0,1)
    alpha=np.clip((edge*.83+lip*.92+crown*.89+shoulder*.62+shell*.16+runes*.09)*
                  np.clip((yy-110.)/55.,0,1)*np.clip((691.-yy)/35.,0,1),0,1)
    # Illustrated material grain lies INSIDE a physically modeled bell shell,
    # preserving empty combat-actor cavity and a translucent central membrane.
    rgba=np.zeros((S,S,4),dtype=np.uint8)
    rgba[:,:,0]=np.clip(175+58*hot+40*lum+noise,0,255).astype('uint8')
    rgba[:,:,1]=np.clip(106+96*hot+49*lum+noise*.66,0,255).astype('uint8')
    rgba[:,:,2]=np.clip(28+106*hot+63*lum+noise*.4,0,255).astype('uint8')
    rgba[:,:,3]=np.clip(alpha*255,0,255).astype('uint8')
    master=Image.fromarray(rgba,'RGBA')
    brush=Image.new('RGBA',(S,S),(0,0,0,0))
    pen=ImageDraw.Draw(brush,'RGBA')
    # Distinct upper jade peak and illustrated raised bells/brass flakes.
    pen.polygon([(384,72),(420,107),(384,146),(348,107)],
                fill=(35,142,91,228),outline=(255,239,143,236),width=6)
    pen.polygon([(384,83),(405,107),(384,132),(364,107)],
                fill=(87,244,165,192))
    for cx,cy in ((241,367),(526,367),(285,625),(480,625)):
        pen.arc((cx-23,cy-19,cx+23,cy+19),197,335,
                fill=(255,234,141,183),width=4)
    brush=brush.filter(ImageFilter.GaussianBlur(.65))
    master.alpha_composite(brush)
    master.save(OUT/'f10_original_illustrated_bell_master.png',optimize=True)
    return master

MASTER=bell_master()
BODY=MASTER.resize((384,384),Image.Resampling.LANCZOS)
BASE=MASTER.crop((75,560,693,681)).resize((267,54),Image.Resampling.LANCZOS)
CREST=MASTER.crop((283,68,485,211)).resize((97,70),Image.Resampling.LANCZOS)
FLANK=MASTER.crop((386,180,730,641)).resize((150,220),Image.Resampling.LANCZOS)

def breath_warp(img,phase,amplitude):
    arr=np.asarray(img,dtype=np.uint8)
    y=np.arange(img.height,dtype='float32')[:,None]
    x=np.arange(img.width,dtype='float32')[None,:]
    sh=np.rint(amplitude*np.sin(y*.035+phase)+.37*amplitude*np.sin(y*.083-phase)).astype('int32')
    coords=np.clip(x+sh,0,img.width-1)
    warped=arr[np.broadcast_to(y.astype('int32'),arr.shape[:2]),np.broadcast_to(coords,arr.shape[:2])]
    return Image.fromarray(warped.copy(),'RGBA')

def cast_pose(k):
    im=Image.new('RGBA',(384,384),(0,0,0,0))
    phase=[.04,.11,.23,.39,.58,.78,.96,1.,1.,.88,.63,.31][k]
    xgrow=[.19,.32,.44,.58,.74,.87,.98,1.,1.04,1.02,.91,.74][k]
    ygrow=[.16,.23,.32,.46,.63,.76,.91,1.,1.03,1.04,.97,.81][k]
    # Distinct action: base inscriptions charge first; bell grows from top
    # and drops around recipient, briefly locks, then collapses.
    base=BASE.resize((round(151+112*phase),round(26+23*phase)),Image.Resampling.LANCZOS)
    center(im,base,(192,335),min(1.,phase*1.12))
    bell=BODY.resize((round(365*xgrow),round(365*ygrow)),Image.Resampling.LANCZOS)
    bell=breath_warp(bell,k*.43,1.6+2.1*math.sin(k*.4)**2)
    # Reveal vertically, do not merely rotate one frame.
    a=np.asarray(bell.getchannel('A'),dtype=np.float32)
    h,w=a.shape
    cut=([.13,.21,.29,.40,.52,.69,.88,1.,1.,1.,.92,.78][k])*h
    from_top=np.clip((cut-np.arange(h)[:,None])/max(1,h*.18),0,1)
    bell.putalpha(Image.fromarray(np.clip(a*from_top,0,255).astype('uint8'),'L'))
    center(im,bell,(192,178+(1-yGrowFix(ygrow))*45),min(1.,phase*1.15))
    if 7<=k<=9:
        glint=CREST.filter(ImageFilter.GaussianBlur(8))
        center(im,glint,(192,81),.18*(1.-abs(k-8)/3.))
    return im

def yGrowFix(y):
    return y

def status_pose(k):
    im=Image.new('RGBA',(192,192),(0,0,0,0))
    phase=math.tau*k/8
    breathe=.82+.09*math.sin(phase)
    ground=BASE.resize((156,30),Image.Resampling.LANCZOS)
    center(im,ground,(96,169+math.sin(phase)),breathe*.76)
    # A condensed bell seal above and two resonating shoulder gold leaves.
    crest=CREST.resize((51,42),Image.Resampling.LANCZOS)
    center(im,crest,(96,56+1.2*math.sin(phase)),breathe*.84)
    side=FLANK.resize((38,85),Image.Resampling.LANCZOS)
    center(im,side,(36,101),breathe*.31)
    center(im,side.transpose(Image.Transpose.FLIP_LEFT_RIGHT),(156,101),breathe*.31)
    return im

def block_pose(k):
    im=Image.new('RGBA',(256,256),(0,0,0,0))
    phase=k/7.
    pulse=[.26,.60,1.,.94,.68,.42,.20,.045][k]
    recoil=[0,3,7,9,6,3,0,0][k]
    # A curving BELLED wall recoils from the rightward incoming enemy
    # instead of emitting any outgoing projectile or fabricated damage.
    arc=FLANK.resize((121+int(10*phase),209),Image.Resampling.LANCZOS)
    center(im,arc,(138+recoil,131),pulse*.95)
    hotspot=CREST.resize((65,51),Image.Resampling.LANCZOS)
    center(im,hotspot,(192+recoil,123),pulse*.91)
    if k in (1,2,3):
        center(im,hotspot.filter(ImageFilter.GaussianBlur(9)),
               (192+recoil,123),pulse*.28)
    rand=random.Random(SEED+k*47)
    for j in range(7):
        frag=MASTER.crop((320+j*11,362+j*7,346+j*11,411+j*7))
        frag=frag.resize((8+j%3*3,14+j%4*2),Image.Resampling.LANCZOS)
        px=195+recoil+(10+30*phase)*(1+.10*rand.random())
        py=120+(j-3)*(5+6*phase)
        center(im,frag,(px,py),pulse*(.14+.06*(j%3)))
    return im

def atlas(poses,cell,filename):
    n=len(poses);cols=4;rows=(n+3)//4
    page=Image.new('RGBA',(cols*cell,rows*cell),(0,0,0,0))
    for i,pose in enumerate(poses):
        assert pose.size==(cell,cell)
        page.alpha_composite(pose,((i%4)*cell,(i//4)*cell))
    assert page.getchannel('A').getextrema()[0]==0
    page.save(OUT/filename,optimize=True)
    return page

cast=atlas([cast_pose(i) for i in range(12)],384,'f10_cast_bell.png')
status=atlas([status_pose(i) for i in range(8)],192,'f10_status_seal.png')
block=atlas([block_pose(i) for i in range(8)],256,'f10_guard_resonance.png')
raw=sum(x.width*x.height*4 for x in (cast,status,block))
assert raw==10354688,raw
print('FIST10_BAKE_PASS poses=28 pages=3 raw_rgba_bytes=10354688 no_rig=true first_party_derived_material=true')
