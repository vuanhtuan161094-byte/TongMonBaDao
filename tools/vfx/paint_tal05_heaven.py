#!/usr/bin/env python3
"""First-party TAL05 R3 painted 10-pose heavenly storm and principal lightning atlases.
Pillow/NumPy-generated RGBA painted source, NOT commercial Source VL/JX pixels.
Usage: /usr/bin/python3 tools/vfx/paint_tal05_heaven.py .
"""
from pathlib import Path
from sys import argv
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,hashlib,base64,os
ROOT=Path(argv[1]) if len(argv)>1 else Path('.')
OUT=ROOT/'godot/labs/combat_lab/talisman05/assets'
OUT.mkdir(parents=True,exist_ok=True)

def noise(w,h,seed):
    g=np.random.default_rng(seed);a=np.zeros((h,w),dtype=np.float32)
    for ww,hh,weight in [(7,7,.29),(18,18,.27),(42,42,.21),(100,100,.14),(200,200,.09)]:
        tile=np.uint8(g.random((hh,ww))*255)
        s=np.asarray(Image.fromarray(tile,'L').resize((w,h),Image.Resampling.BICUBIC),dtype=np.float32)/255.
        a+=(s-.5)*weight*2
    return np.clip(.52+a,0,1)

def sky(i):
    W=H=512
    x=np.arange(W,dtype=np.float32)[None,:]-255.5
    y=np.arange(H,dtype=np.float32)[:,None]-255.5
    theta=np.arctan2(y,x);r=np.sqrt(x*x+y*y)
    n=noise(W,H,9234+i*7)
    outer=171+17*np.sin(theta*5+i*.13)+10*np.cos(theta*9-i*.19)
    storm=(np.exp(-((r-outer)/55)**2)*(.4+.65*n)+np.exp(-((r-100)/80)**2)*(.3+.5*n))
    fade=np.clip((252-r)/50,0,1)*np.clip(r/45,0,1)
    a=np.clip(storm*210*fade*(.62+.38*(i+1)/10),0,255)
    pixels=np.zeros((H,W,4),dtype=np.uint8)
    pixels[:,:,0]=np.uint8(np.clip(75+100*n,0,255))
    pixels[:,:,1]=np.uint8(np.clip(35+65*n,0,255))
    pixels[:,:,2]=np.uint8(np.clip(133+97*n,0,255))
    pixels[:,:,3]=a.astype(np.uint8)
    image=Image.fromarray(pixels,'RGBA')
    ink=Image.new('RGBA',(W,H));brush=ImageDraw.Draw(ink,'RGBA')
    rng=np.random.default_rng(4422+i)
    for j in range(17):
        phi=(j*2.399+i*.053)%(2*np.pi);rr=rng.uniform(98,184)
        px=256+rr*np.cos(phi);py=256+rr*np.sin(phi)
        length=rng.uniform(12,35);width=rng.uniform(2,8)
        tangent=np.array([-np.sin(phi),np.cos(phi)])
        normal=np.array([np.cos(phi),np.sin(phi)])
        center=np.array([px,py])
        p=[center+tangent*length/2+normal*width/2,center-tangent*length/2+normal*width/2,
           center-tangent*length/2-normal*width/2,center+tangent*length/2-normal*width/2]
        brush.polygon([tuple(q) for q in p],fill=(238,182,105,int(rng.uniform(65,175))))
        if j%2==0:brush.line([tuple(center),tuple(center+normal*12)],fill=(255,223,155,120),width=2)
    for j in range(13):
        phi=j*2*np.pi/13+i*.07
        rr=169+14*np.sin(j*2.1+i*.3)
        pos=(256+rr*np.cos(phi),256+rr*np.sin(phi))
        end=(pos[0]+rng.uniform(-23,23),pos[1]+rng.uniform(-23,23))
        brush.line([pos,end],fill=(176,119,245,140),width=int(rng.choice([2,3,4])))
    image.alpha_composite(ink.filter(ImageFilter.GaussianBlur(4)))
    image.alpha_composite(ink)
    return image

def bolt(i):
    W,H=384,512
    progress=[.12,.21,.31,.42,.53,.64,.75,.86,.95,1.0][i]
    im=Image.new('RGBA',(W,H))
    rng=np.random.default_rng(1520+i)
    ys=np.arange(12,int(494*progress)+1,10,dtype=np.float32)
    xs=np.array([183+17*np.sin(float(y)/49+i*.14)+9*np.sin(float(y)/18+2.3)+rng.uniform(-11,11) for y in ys])
    pts=list(zip(xs.tolist(),ys.tolist()))
    dust=Image.new('RGBA',(W,H));brush=ImageDraw.Draw(dust,'RGBA')
    for j in range(24):
        y=rng.uniform(0,490*progress);x=182+rng.normal(0,34)
        rx=rng.uniform(15,52);ry=rng.uniform(8,29)
        brush.ellipse((x-rx,y-ry,x+rx,y+ry),fill=(124,74,198,int(rng.uniform(26,74))))
    im.alpha_composite(dust.filter(ImageFilter.GaussianBlur(14)))
    fog=Image.new('RGBA',(W,H));hot=Image.new('RGBA',(W,H))
    h,c=ImageDraw.Draw(fog,'RGBA'),ImageDraw.Draw(hot,'RGBA')
    if len(pts)>1:
        h.line(pts,fill=(122,71,226,150),width=46,joint='curve')
        h.line(pts,fill=(181,118,254,165),width=22,joint='curve')
        c.line(pts,fill=(215,180,255,205),width=8,joint='curve')
        c.line(pts,fill=(254,244,255,242),width=3,joint='curve')
        c.line(pts,fill=(255,255,255,248),width=1,joint='curve')
    for j,(frac,direction) in enumerate([(.36,-1),(.70,1)]):
        k=int(len(pts)*frac)
        if k<2 or k>=len(pts):continue
        x,y=pts[k]
        p1=(x+direction*rng.uniform(20,39),y+rng.uniform(20,38))
        p2=(p1[0]+direction*rng.uniform(18,33),p1[1]+rng.uniform(25,42))
        h.line([(x,y),p1,p2],fill=(151,96,241,115),width=13,joint='curve')
        c.line([(x,y),p1,p2],fill=(254,230,255,203),width=2,joint='curve')
    im.alpha_composite(fog.filter(ImageFilter.GaussianBlur(12)))
    im.alpha_composite(fog.filter(ImageFilter.GaussianBlur(4)))
    im.alpha_composite(hot)
    sparks=Image.new('RGBA',(W,H));s=ImageDraw.Draw(sparks,'RGBA')
    for j in range(24):
        y=rng.uniform(10,489*progress);x=183+rng.normal(0,48)
        rr=int(rng.choice([1,1,2,3]))
        s.ellipse((x-rr,y-rr,x+rr,y+rr),fill=(250,202,139,int(rng.uniform(55,170))))
    im.alpha_composite(sparks)
    return im

def impact():
    W=320;im=Image.new('RGBA',(W,W));rng=np.random.default_rng(881)
    dust=Image.new('RGBA',(W,W));b=ImageDraw.Draw(dust,'RGBA')
    for j in range(27):
        x=160+rng.normal(0,46);y=186+rng.normal(0,26)
        rx=rng.uniform(6,34);ry=rng.uniform(4,22)
        b.ellipse((x-rx,y-ry,x+rx,y+ry),fill=(127,72,198,int(rng.uniform(28,95))))
    im.alpha_composite(dust.filter(ImageFilter.GaussianBlur(9)))
    burst=Image.new('RGBA',(W,W));c=ImageDraw.Draw(burst,'RGBA')
    for j in range(11):
        a=2*np.pi*j/11+rng.uniform(-.14,.14);pts=[(160,186)]
        for radius in [16,32,51,73,111]:
            phi=a+rng.uniform(-.13,.13)
            pts.append((160+radius*np.cos(phi),186+radius*.46*np.sin(phi)))
        c.line(pts,fill=(165,112,241,122),width=7,joint='curve')
        c.line(pts,fill=(255,227,247,210),width=2,joint='curve')
    im.alpha_composite(burst.filter(ImageFilter.GaussianBlur(4)))
    im.alpha_composite(burst)
    return im

sky_atlas=Image.new('RGBA',(2048,1536))
bolt_atlas=Image.new('RGBA',(1536,1536))
for i in range(10):
    sky_atlas.alpha_composite(sky(i),((i%4)*512,(i//4)*512))
    bolt_atlas.alpha_composite(bolt(i),((i%4)*384,(i//4)*512))
outputs={'tal05_r3_sky_master.webp':sky(9),
         'tal05_r3_sky_flipbook.webp':sky_atlas,
         'tal05_r3_bolt_master.webp':bolt(9),
         'tal05_r3_bolt_flipbook.webp':bolt_atlas,
         'tal05_r3_impact.webp':impact()}
for name,im in outputs.items():
    dest=OUT/name
    im.save(dest,quality=88,method=5,exact=True)
    print('TAL05_PAINTED_OUTPUT',name,im.size,hashlib.sha256(dest.read_bytes()).hexdigest(),dest.stat().st_size)
    if os.getenv('TMB_ART_LOG_EXPORT')=='1':
        print('TMB_ASSET_BEGIN:'+name)
        payload=base64.b64encode(dest.read_bytes()).decode('ascii')
        for n in range(0,len(payload),180):print('TMB_ASSET_LINE:'+payload[n:n+180])
        print('TMB_ASSET_END:'+name)
