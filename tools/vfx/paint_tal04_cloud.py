#!/usr/bin/env python3
"""TAL04 R3 original code-painted raster cloud master and 10-frame alpha flipbook.
Run from repo root: python3 tools/vfx/paint_tal04_cloud.py .
Pillow + NumPy only. No sampled copyrighted images and no rig.
"""
from pathlib import Path
from sys import argv
from PIL import Image,ImageDraw,ImageFilter
import hashlib,os,base64
import numpy as np

ROOT=Path(argv[1]) if len(argv)>1 else Path('.')
OUT=ROOT/'godot/labs/combat_lab/talisman04/assets'
OUT.mkdir(parents=True,exist_ok=True)
W,H=1024,256

def noise(seed):
    g=np.random.default_rng(seed);a=np.zeros((H,W),dtype=np.float32)
    for w,h,weight in [(9,5,.28),(24,9,.26),(57,17,.22),(143,34,.15),(317,72,.09)]:
        tile=np.uint8(g.random((h,w))*255)
        sampled=np.asarray(Image.fromarray(tile,'L').resize((W,H),Image.Resampling.BICUBIC),dtype=np.float32)/255
        a+=(sampled-.5)*2*weight
    return np.clip(.5+a,0,1)

n1,n2=noise(42318),noise(92310)
xx=np.arange(W,dtype=np.float32)[None,:]
yy=np.arange(H,dtype=np.float32)[:,None]
rng0=np.random.default_rng(4008)
anchors=np.arange(0,W+23,23)
notches=rng0.normal(0,10,len(anchors)).astype(np.float32)
notches[0]=notches[-1]=0
zig=np.interp(np.arange(W),anchors,notches)[None,:]
curve=123+13*np.sin(xx/155+.4)+10*np.sin(xx/46+1.5)+zig
d=yy-curve

def stroke(progress,idx):
    limb=np.exp(-((np.abs(d)-32-29*(n1-.5))/41)**2)
    shoulder=np.exp(-((np.abs(d)-66)/56)**2)*(.38+.8*n2)
    cloud=(.7*limb+.3*shoulder)*(n1**1.07)*np.exp(-((xx-516)/710)**2)
    reveal=np.clip((progress*W-xx)/54+.5,0,1)*np.clip((xx-4)/45,0,1)
    a=np.clip((cloud*158+shoulder*20)*reveal*(1+.075*np.sin(idx*1.33))*np.clip((n1-.22)*1.45,0,1),0,255)
    shape=np.zeros((H,W,4),dtype=np.uint8)
    shape[:,:,0]=np.uint8(np.clip(103+86*n1+36*n2,0,255))
    shape[:,:,1]=np.uint8(np.clip(64+61*n1+37*n2,0,255))
    shape[:,:,2]=np.uint8(np.clip(157+72*n1+15*n2,0,255))
    shape[:,:,3]=np.uint8(a)
    im=Image.fromarray(shape,'RGBA')
    rng=np.random.default_rng(4100+idx)
    wisps=Image.new('RGBA',(W,H))
    brush=ImageDraw.Draw(wisps,'RGBA')
    for j in range(32):
        x=int(rng.uniform(37,1000))
        if x>progress*W:continue
        y=float(curve[0,x])+rng.choice([-1,1])*rng.uniform(23,74)
        rx,ry=rng.uniform(13,65),rng.uniform(4,22)
        brush.ellipse((x-rx,y-ry,x+rx,y+ry),fill=(133,89,216,int(rng.uniform(12,47))))
    im.alpha_composite(wisps.filter(ImageFilter.GaussianBlur(10)))
    end=int(progress*W)
    points=[(x,float(curve[0,x])+3.8*np.sin(x/15+idx*.63)) for x in range(12,992,11) if x<=end]
    halo=Image.new('RGBA',(W,H));core=Image.new('RGBA',(W,H))
    h,c=ImageDraw.Draw(halo,'RGBA'),ImageDraw.Draw(core,'RGBA')
    if len(points)>1:
        h.line(points,fill=(120,67,247,95),width=31,joint='curve')
        c.line(points,fill=(192,154,255,186),width=5,joint='curve')
        c.line(points,fill=(255,248,255,228),width=2,joint='curve')
    rim=np.random.default_rng(1771+idx)
    for j in range(18):
        x=int(rim.uniform(31,966))
        if x>end-8:continue
        y=float(curve[0,x]);sgn=-1 if j%2 else 1
        bend=(x+rim.uniform(-13,27),y+sgn*rim.uniform(14,34))
        dest=(min(x+rim.uniform(22,77),end),y+sgn*rim.uniform(21,50))
        c.line([(x,y),bend,dest],fill=(165,115,237,int(rim.uniform(38,105))),width=int(rim.choice([1,2,3])))
    for j,(q,direction) in enumerate([(.19,-1),(.38,1),(.64,-1),(.82,1)]):
        x=int(W*q)
        if x>end:continue
        y=float(curve[0,x])
        p=[(x,y),(x-11+j*5,y+direction*(27+j*5)),(x+10-j*6,y+direction*(52+j*11))]
        h.line(p,fill=(148,96,248,92),width=15,joint='curve')
        c.line(p,fill=(230,203,255,170),width=3,joint='curve')
        c.line(p,fill=(255,250,255,190),width=1,joint='curve')
    sparks=np.random.default_rng(911+idx*13)
    for j in range(24):
        x=int(sparks.uniform(50,max(51,end-15)))
        y=int(float(curve[0,min(x,W-1)])+sparks.normal(0,42))
        rr=int(sparks.choice([1,1,2,2,3]))
        c.ellipse((x-rr,y-rr,x+rr,y+rr),fill=(247,201,138,int(sparks.uniform(70,160))))
    im.alpha_composite(halo.filter(ImageFilter.GaussianBlur(9)))
    im.alpha_composite(halo.filter(ImageFilter.GaussianBlur(3)))
    im.alpha_composite(core)
    # Protect actor silhouettes and remove the R3 rectangular atlas/cloud edge.
    feather_x=np.clip((xx-4)/35,0,1)*np.clip((W-xx-4)/62,0,1)
    feather_y=np.clip((yy-8)/48,0,1)*np.clip((H-yy-9)/48,0,1)
    feather=np.clip(feather_x*feather_y,0,1)
    alpha=np.asarray(im.getchannel('A'),dtype=np.float32)
    im.putalpha(Image.fromarray(np.uint8(np.clip(alpha*feather,0,255)),'L'))
    return im

def impact():
    rng=np.random.default_rng(251);size=320
    im=Image.new('RGBA',(size,size))
    haze=Image.new('RGBA',(size,size));h=ImageDraw.Draw(haze,'RGBA')
    for j in range(19):
        x=160+rng.normal(0,43);y=167+rng.normal(0,22)
        w=rng.uniform(15,45);v=rng.uniform(6,18)
        h.ellipse((x-w,y-v,x+w,y+v),fill=(129,78,205,int(rng.uniform(28,90))))
    im.alpha_composite(haze.filter(ImageFilter.GaussianBlur(8)))
    cracks=Image.new('RGBA',(size,size));c=ImageDraw.Draw(cracks,'RGBA')
    for j in range(10):
        ang=2*np.pi*j/10+rng.uniform(-.22,.22)
        pts=[(160,167)]
        for rad in [17,35,57,84,113]:
            a=ang+rng.uniform(-.16,.16)
            pts.append((160+rad*np.cos(a),167+rad*.44*np.sin(a)))
        c.line(pts,fill=(144,86,238,120),width=8,joint='curve')
        c.line(pts,fill=(255,216,247,190),width=2,joint='curve')
    im.alpha_composite(cracks.filter(ImageFilter.GaussianBlur(4)))
    im.alpha_composite(cracks)
    return im

atlas=Image.new('RGBA',(4096,768))
for i,p in enumerate([.18,.27,.37,.48,.58,.69,.80,.89,.98,1.0]):
    atlas.alpha_composite(stroke(p,i),((i%4)*W,(i//4)*H))
outputs={
    'tal04_r3_cloud_master.webp':stroke(1,9),
    'tal04_r3_cloud_flipbook.webp':atlas,
    'tal04_r3_local_fracture.webp':impact(),
}
for name,im in outputs.items():
    dest=OUT/name
    im.save(dest,quality=88,method=5,exact=True)
    print('TAL04_PAINTED_OUTPUT',name,im.size,hashlib.sha256(dest.read_bytes()).hexdigest(),dest.stat().st_size)
    if os.getenv('TMB_ART_LOG_EXPORT')=='1':
        print('TMB_ASSET_BEGIN:'+name)
        payload=base64.b64encode(dest.read_bytes()).decode('ascii')
        for n in range(0,len(payload),180):print('TMB_ASSET_LINE:'+payload[n:n+180])
        print('TMB_ASSET_END:'+name)
