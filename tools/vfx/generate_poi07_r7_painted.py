#!/usr/bin/env python3
"""POI07 R7: authored first-party image-backed sprites from isolated painted masters.
Sources were produced in TMB conversation, not copied from JX/Source A/Võ Lâm.
Exactly 34 pose-specific RGBA frames, retaining original painted pixels. Pillow-only.
"""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
from math import sin
from hashlib import sha256

BASE=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/poison07/r7_painted/assets'
MASTER=BASE/'master'

def source(name):
    path=MASTER/name
    assert path.is_file(),f'PAINTED_MASTER_MISSING: {path}'
    im=Image.open(path).convert('RGBA')
    assert im.getchannel('A').getbbox(),name
    return im

def ripple(image,index,amp=3.0):
    """Animate original RGBA source pixels through a nonrigid rowwise paint warp."""
    w,h=image.size
    out=Image.new('RGBA',(w+int(amp*2+4),h),(0,0,0,0))
    for y in range(h):
        q=sin(y*.061+index*.45)*sin(y*3.14159265/h)**2
        offset=round(amp+q*amp)
        out.paste(image.crop((0,y,w,y+1)),(offset,y))
    return out

def fit(image,cell,size,pos=None):
    out=Image.new('RGBA',cell,(0,0,0,0))
    tex=image.resize(size,Image.Resampling.LANCZOS)
    pos=pos or ((cell[0]-size[0])//2,(cell[1]-size[1])//2)
    out.alpha_composite(tex,pos)
    a=out.getchannel('A')
    gutter=Image.new('L',cell,255);d=ImageDraw.Draw(gutter)
    w,h=cell
    d.rectangle((0,0,w-1,1),fill=0)
    d.rectangle((0,h-2,w-1,h-1),fill=0)
    d.rectangle((0,0,1,h-1),fill=0)
    d.rectangle((w-2,0,w-1,h-1),fill=0)
    out.putalpha(ImageChops.multiply(a,gutter))
    return out

def fade(image,amount):
    out=image.copy();out.putalpha(image.getchannel('A').point(lambda v:round(v*amount)))
    return out

hero=source('needle_painted_source.webp')
charge=source('palm_painted_source.webp')

def needle_frame(i):
    art=ripple(hero,i,3.2+1.6*sin(i*.62))
    return fit(fade(art,.86+.14*sin(i*.75+1)),(384,128),(356,83),(12,19))

def charge_frame(i):
    q=(i+.5)/10
    art=ripple(charge,i,2.3)
    scale=.68+.31*q
    dims=(int(151*scale),int(190*scale))
    return fit(fade(art,.42+.58*q),(224,224),dims,(112-dims[0]//2,112-dims[1]//2))

blade=hero.crop((170,14,min(hero.width,486),min(hero.height,105)))

def puncture_frame(i):
    a=[.20,.70,1.0,.94,.83,.71,.57,.43,.32,.22,.11,.035][i]
    composite=Image.new('RGBA',(220,220),(0,0,0,0))
    for k,(angle,length,delta) in enumerate([(-34,105,(-13,-5)),(13,141,(0,0)),(47,83,(9,5)),(-64,58,(-5,-11))]):
        cut=ripple(blade,i*2+k,1.9)
        cut=cut.resize((length,26+round(4*a)),Image.Resampling.LANCZOS)
        cut=cut.rotate(angle+sin(i*.47+k)*2.2,resample=Image.Resampling.BICUBIC,expand=True)
        cut=fade(cut,a*(.92 if k==1 else .48))
        p=(110+delta[0]-cut.width//2,110+delta[1]-cut.height//2)
        composite.alpha_composite(cut,p)
    core=blade.crop((max(0,blade.width-75),18,blade.width-4,min(blade.height,65)))
    core=ripple(core,i,1.1).resize((63,27),Image.Resampling.LANCZOS)
    composite.alpha_composite(fade(core,a*.95),(79,97))
    return fit(composite,(224,224),(220,220),(2,2))

def pack(name,frames,cell):
    w,h=cell
    atlas=Image.new('RGBA',(w*4,h*((len(frames)+3)//4)),(0,0,0,0))
    digest=set()
    for i,f in enumerate(frames):
        assert f.size==cell
        a=f.getchannel('A')
        assert a.getbbox(),(name,i,'empty')
        for region in [(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)]:
            assert a.crop(region).getextrema()[1]==0,(name,i,'edge_alpha')
        digest.add(sha256(f.tobytes()).hexdigest())
        atlas.alpha_composite(f,((i%4)*w,(i//4)*h))
    assert len(digest)==len(frames),(name,'duplicate_pose')
    output=BASE/name
    atlas.save(output,optimize=True,compress_level=9)
    print('POI07_R7_BAKED',name,atlas.size,len(frames),'distinct',len(digest),'bytes',output.stat().st_size)
    return atlas

if __name__=='__main__':
    a=pack('painted_needle_r7_12.png',[needle_frame(i) for i in range(12)],(384,128))
    b=pack('painted_charge_r7_10.png',[charge_frame(i) for i in range(10)],(224,224))
    c=pack('painted_puncture_r7_12.png',[puncture_frame(i) for i in range(12)],(224,224))
    raw=sum(im.width*im.height*4 for im in (a,b,c))
    print('POI07_R7_RAW_RGBA8_BYTES',raw,'MIB',round(raw/1048576,3))
    assert raw < 8*1048576,('RGBA8_BUDGET',raw)