#!/usr/bin/env python3
"""POI08 R4 painted first-party sprite atlas baker. Use only independently matted skill-specific WebP masters.
No third party pixels. No POI07 asset reuse. Source is image-generation art, not a Godot screenshot.
"""
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageChops, ImageDraw
import math, hashlib, random

BASE=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/poison08/r4_painted/assets'
SOURCE=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/poison08/r3_painted/assets/master'
BASE.mkdir(parents=True, exist_ok=True)

def load(n):
    master_path=(BASE/'master' if n=='toxin_barb' else SOURCE)/(n+'_painted.webp')
    im=Image.open(master_path).convert('RGBA')
    assert im.getchannel('A').getbbox(), n
    return im

def warp_rows(im,step,amp=2.3,velocity=.65):
    """Nonrigid, source-pixel displacement for every frame and pixel row (no rig)."""
    w,h=im.size
    dst=Image.new('RGBA',(w+16,h+12))
    for y in range(h):
        shift=int(amp*math.sin(y*.11+step*velocity)+.8*math.sin(y*.28-step*.49))
        dy=4+int(2.2*math.sin(step*.3+y*.055))
        row=im.crop((0,y,w,y+1))
        dst.alpha_composite(row,(7+shift,y+dy))
    return dst

def opacity(im,q):
    im=im.copy()
    im.putalpha(im.getchannel('A').point(lambda x: int(max(0,min(255,x*q)))))
    return im

def frame(im,cell,size,offset=None):
    w,h=cell
    out=Image.new('RGBA',cell)
    painted=im.resize(size,Image.Resampling.LANCZOS)
    px=(w-size[0])//2 if offset is None else offset[0]
    py=(h-size[1])//2 if offset is None else offset[1]
    out.alpha_composite(painted,(px,py))
    # Separate UV cells, zero-opacity gutters on all sides.
    mask=Image.new('L',cell,255);md=ImageDraw.Draw(mask)
    md.rectangle((0,0,w-1,1),fill=0)
    md.rectangle((0,h-2,w-1,h-1),fill=0)
    md.rectangle((0,0,1,h-1),fill=0)
    md.rectangle((w-2,0,w-1,h-1),fill=0)
    out.putalpha(ImageChops.multiply(out.getchannel('A'),mask))
    return out

def brighten(im,rgb_gain,alpha_gain):
    r,g,b,a=im.split()
    r=r.point(lambda v:min(255,round(v*rgb_gain)))
    g=g.point(lambda v:min(255,round(v*rgb_gain)))
    b=b.point(lambda v:min(255,round(v*rgb_gain)))
    a=a.point(lambda v:min(255,round(v*alpha_gain)))
    return Image.merge('RGBA',(r,g,b,a))

hero=load('toxin_barb')
charge=brighten(load('thorn_seed'),1.36,1.6)
vein=brighten(load('vein_grip'),1.12,1.13)

def hero_pose(i):
    # Actual painted toxic living barb, not the needle of POI07; speed-driven tail contraction.
    art=warp_rows(hero,i,2.7+.9*math.sin(i*.62))
    cx=366+int(3*math.sin(i*.82))
    cy=106+int(4*math.cos(i*.5))
    return frame(opacity(art,.88+.12*math.sin(i*.53+.4)),(384,128),(cx,cy))

def charge_pose(i):
    q=(i+.8)/10
    art=warp_rows(charge,i,2.4)
    cw=145+int(40*q);ch=92+int(28*q)
    # Materialized jewel petals condense and bloom, source pixels not a code circle.
    return frame(opacity(art,.23+.75*q),(192,192),(cw,ch))

def bite_pose(i):
    strength=[.35,.78,1,.97,.86,.73,.55,.32][i]
    art=warp_rows(vein,i,3.8)
    rgba=frame(opacity(art,strength),(192,192),(177+int(5*math.sin(i*.7)),133+int(4*math.cos(i*.6))))
    return rgba

def mark_pose(i):
    # Sustained 8-sec scar: breathing material, a visual representation only.
    # No DoT ticks or new combat receipts are invented.
    q=(i%12)/12
    art=warp_rows(vein,i,1.6)
    w=153+int(6*math.sin(q*math.tau))
    h=116+int(4*math.cos(q*math.tau))
    a=.73+.11*math.sin(q*math.tau+1)
    return frame(opacity(art,a),(192,192),(w,h))

def pack(name,frames,cell):
    w,h=cell
    atlas=Image.new('RGBA',(w*4,h*((len(frames)+3)//4)))
    hashes=set()
    for i,im in enumerate(frames):
        assert im.size==cell
        a=im.getchannel('A')
        assert a.getbbox(),(name,i,'empty')
        edges=[(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)]
        assert all(a.crop(e).getextrema()[1]==0 for e in edges),(name,i,'alpha bleed')
        hashes.add(hashlib.sha256(im.tobytes()).hexdigest())
        atlas.alpha_composite(im,((i%4)*w,(i//4)*h))
    assert len(hashes)==len(frames),(name,'repeated animation pose')
    path=BASE/name
    atlas.save(path,compress_level=9,optimize=True)
    print('POI08_R4_ATLAS_PASS',name,'frames',len(frames),'bytes',path.stat().st_size,'dimensions',atlas.size)
    return atlas
if __name__=='__main__':
    imgs=[
        pack('living_barb_r4_12.png',[hero_pose(i) for i in range(12)],(384,128)),
        pack('thorn_seed_r4_10.png',[charge_pose(i) for i in range(10)],(192,192)),
        pack('bite_contact_r4_08.png',[bite_pose(i) for i in range(8)],(192,192)),
        pack('vein_mark_r4_12.png',[mark_pose(i) for i in range(12)],(192,192)),
    ]
    raw=sum(im.width*im.height*4 for im in imgs)
    print('POI08_R4_RAW_RGBA8_BYTES',raw,'MIB',round(raw/1048576,3))
    assert raw<=8*1048576