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

impact_source=source('puncture_painted_source.webp')
flare_half=impact_source.crop((2,9,119,129))

def puncture_frame(i):
    # Local asymmetric painted explosion shards, strictly from original first-party
    # art pixels. No source poster's fighter, damage numbers or fake character layer.
    strength=[.18,.70,1.0,.95,.83,.69,.55,.43,.31,.22,.11,.03][i]
    q=i/11.0
    canvas=Image.new('RGBA',(220,220),(0,0,0,0))
    left=ripple(flare_half,i,2.1)
    left=left.resize((106+round(7*q),79+round(10*q)),Image.Resampling.LANCZOS)
    canvas.alpha_composite(fade(left,strength*.89),(12,67))
    right=ripple(flare_half.transpose(Image.Transpose.FLIP_LEFT_RIGHT),i+5,1.7)
    right=right.resize((78+round(5*q),60+round(7*q)),Image.Resampling.LANCZOS)
    canvas.alpha_composite(fade(right,strength*.54),(127,76))
    # Painted needle focal pinprick on chest, not a broad game-logic AOE hit.
    core=hero.crop((max(0,hero.width-110),30,hero.width-2,75))
    core=ripple(core,i,1.1).resize((71,26),Image.Resampling.LANCZOS)
    canvas.alpha_composite(fade(core,strength*.99),(85,94))
    return fit(canvas,(224,224),(220,220),(2,2))

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