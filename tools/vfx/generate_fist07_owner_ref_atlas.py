#!/usr/bin/env python3
"""Kim Cang Ho The — reference-pixel sprite pipeline, NOT geometric code art.

The actual golden guardian, engraved banners, glass ward and impact artwork are
extracted from the owner-provided concept, made transparent, and baked offline into
pose-specific RGBA atlases. Godot only plays and layers authored sprites.
This source intentionally DOES NOT redraw the reference with curves/circles.
"""
from pathlib import Path
import base64, math, random
from PIL import Image, ImageEnhance, ImageFilter
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / 'godot/labs/combat_lab/fist07/assets/generated'
SOURCE = ROOT / 'godot/labs/combat_lab/fist07/assets/source'
CELL = 320


def source_art(name):
    encoded = (SOURCE / (name + '.webp.b64')).read_text(encoding='ascii')
    return Image.open(__import__('io').BytesIO(base64.b64decode(''.join(encoded.split())))).convert('RGB')


def keyed(im: Image.Image, gain: float=1.):
    """Soft hue/value chroma matte: retain original gold painting/brush detail,
    discard dark brown poster background/actor ink and UI paper.
    """
    im=im.convert('RGB')
    arr=np.asarray(im, dtype=np.float32)
    hsv=np.asarray(im.convert('HSV'),dtype=np.float32)
    h,s,v = hsv[:,:,0],hsv[:,:,1],hsv[:,:,2]
    hue=np.minimum(1., np.maximum(0., (h-7)/13.)) * np.minimum(1.,np.maximum(0.,(73-h)/19.))
    yellow=np.maximum(0.,np.minimum(1.,(arr[:,:,0]-arr[:,:,2]-16.)/66.))
    saturation=np.minimum(1.,np.maximum(.29,(s-44.)/135.))
    luminance=np.clip((v-106.)/114.,0.,1.)
    alpha=np.clip(gain*255.*hue*yellow*saturation*luminance,0,255)
    # Highlight very white / yellow filament cores that are weakly saturated.
    white=(np.minimum(arr[:,:,0],arr[:,:,1]) > 212) & (arr[:,:,0] > arr[:,:,2]+21) & (h>20)&(h<63)
    alpha=np.maximum(alpha,np.where(white, np.clip((v-165)*2.1,0,245),0))
    # Preserve actual reference stroke/luminance variations while lifting the
    # poster's brown shadows toward the requested clean white-gold spectrum.
    # This grades existing source pixels; it does NOT draw substitute motifs.
    grade=np.empty_like(arr)
    grade[:,:,0]=np.clip(165.+.36*arr[:,:,0],0,255)
    grade[:,:,1]=np.clip(78.+.65*arr[:,:,1],0,255)
    grade[:,:,2]=np.clip(9.+.86*arr[:,:,2],0,255)
    out=np.concatenate([grade,np.expand_dims(alpha,2)],axis=2).astype(np.uint8)
    rgba=Image.fromarray(out,'RGBA')
    rgba.putalpha(rgba.getchannel('A').filter(ImageFilter.GaussianBlur(.60)))
    return rgba


def keyed_impact(im):
    """Opaque white-hot centre + gold rays from the original star artwork.
    Unlike the dome chroma matte, the protective HIT must retain near-white
    low-saturation pixels; otherwise the flash looks like a black-centred ring.
    """
    arr=np.asarray(im.convert('RGB'),dtype=np.float32)
    value=np.max(arr,axis=2)
    intensity=np.clip((value-58.)/145.,0,1)
    intensity=intensity*intensity*(3.0-2.0*intensity)
    alpha=np.clip(intensity*252.,0,255)
    rgb=arr.copy()
    rgb[:,:,0]=np.clip(105+arr[:,:,0]*.59,0,255)
    rgb[:,:,1]=np.clip(55+arr[:,:,1]*.79,0,255)
    rgb[:,:,2]=np.clip(18+arr[:,:,2]*.91,0,255)
    out=np.concatenate([rgb,alpha[:,:,None]],axis=2).astype(np.uint8)
    image=Image.fromarray(out,'RGBA')
    image.putalpha(image.getchannel('A').filter(ImageFilter.GaussianBlur(.36)))
    return image


def layer_alpha(src, const):
    v=src.copy()
    v.putalpha(v.getchannel('A').point(lambda x: int(x*const)))
    return v


def resize_to(src, width, height):
    return src.resize((int(width),int(height)),Image.Resampling.LANCZOS)


def composite(canvas, src, xy, alpha=1.0):
    src=layer_alpha(src,alpha)
    canvas.alpha_composite(src,(round(xy[0]),round(xy[1])))


def prepare_components(hero,impact):
    # owner crop: x=400..1050, y=0..342 from supplied exact screenshot.
    # Guardian is hand-painted *in the reference*; never code-drawn.
    guardian=keyed(hero.crop((130,0,574,119)),gain=1.18)
    # Fade guardian statue naturally before the original illustration's human
    # hair/shoulders intrude beneath the halo; no rectangular alpha seams.
    ga=np.asarray(guardian.getchannel('A'),dtype=np.float32).copy()
    gy,gx=np.indices(ga.shape)
    fade=np.clip((119-gy)/28.,0,1)
    fade=fade*fade*(3-2*fade)
    # Drop only the horizontal shadow of the concept's foreground character:
    # keep the statue's head and both luminous shoulder horns.
    center_x=np.clip((gx-70)/48.,0,1)*np.clip((374-gx)/46.,0,1)
    center_y=np.clip((gy-75)/30.,0,1)
    center_x=center_x*center_x*(3-2*center_x)
    center_y=center_y*center_y*(3-2*center_y)
    topfade=np.clip(gy/11.,0,1)
    ga*=topfade*fade*(1.0-.998*center_x*center_y)
    guardian.putalpha(Image.fromarray(ga.astype('uint8'),'L').filter(ImageFilter.GaussianBlur(2.0)))
    left=keyed(hero.crop((43,17,124,190)),gain=1.25)
    right=keyed(hero.crop((569,14,649,189)),gain=1.25)
    entire=keyed(hero.crop((79,80,576,341)),gain=1.05)
    # The original dome material includes a painted sample warrior at its
    # centre. Mask it out. The LIVE Godot sprite must remain the only actor.
    a=np.asarray(entire.getchannel('A'),dtype=np.float32).copy()
    Y,X=np.indices(a.shape)
    original_x=X+79
    original_y=Y+80
    # The dome's visible glass/rim is strongest near its outer boundary.
    r=np.sqrt(((original_x-326)/250.)**2+((original_y-337)/244.)**2)
    material=np.clip((r-.57)/.38,0,1)
    # The protective dome surrounds the reference human, but we remove that
    # human using a SOFT ELLIPTIC matte, never rectangular cut-outs. The real
    # Godot actor occupies the transparent centre of this illustrated shield.
    r_actor=np.sqrt(((original_x-326)/171.)**2+((original_y-242)/137.)**2)
    no_human=np.clip((r_actor-.79)/.38,0,1)
    no_human=no_human*no_human*(3-2*no_human)
    # A photographic crop must never reveal its square rectangle edges.
    side=np.minimum(X, 496-X)
    fade_side=np.clip(side/31.,0,1)
    fade_top=np.clip((Y+4)/7.,0,1)
    fade_bottom=np.clip((260-Y)/37.,0,1)
    envelope=fade_side*fade_top*fade_bottom
    a*=np.maximum(material*.98,.055)*no_human*envelope
    entire.putalpha(Image.fromarray(a.astype('uint8'),'L').filter(ImageFilter.GaussianBlur(1.3)))
    # Actual flattened golden footfall/lotus artwork sourced from banner.
    # Bottom 20px captures pure golden ground glare, below human clothes.
    ground=keyed(hero.crop((0,321,650,341)),gain=1.30)
    # Fade edges of the poster's rectangular bottom strip into real ground.
    ga=np.asarray(ground.getchannel('A'),dtype=np.float32).copy()
    gy,gx=np.indices(ga.shape)
    xfade=np.clip(np.sin(np.pi*gx/649.),0,1)**.57
    yfade=np.clip((gy+1)/5.,0,1)*np.clip((19-gy)/10.,0,1)
    ga*=xfade*yfade
    ground.putalpha(Image.fromarray(ga.astype('uint8'),'L').filter(ImageFilter.GaussianBlur(1.35)))
    # Contact consists of captured painted explosion from bottom asset icons.
    hit=keyed_impact(impact)
    return guardian,left,right,entire,ground,hit


def pose_ward(n, parts):
    guardian,left,right,dome,ground,_ = parts
    img=Image.new('RGBA',(CELL,CELL),(0,0,0,0))
    strength=(.26+.74*(n+1)/4.) if n<4 else (.97+.03*math.sin(n*.91))
    if n>=12:strength=(16-n)/4.
    phase=n*.82
    breathe=math.sin(phase)
    # Each frame is baked from the REAL art layers, not GDScript vector drawing.
    # Gentle whole-layer transforms animate mystical light (not a rig).
    gd=resize_to(guardian,267+round(5*breathe),103+round(3*breathe))
    composite(img,gd,(27-round(2*breathe),10+round(2*breathe)),alpha=.84*strength)
    lb=resize_to(left,51,121)
    rb=resize_to(right,50,121)
    composite(img,lb,(8,12+round(4*breathe)),alpha=.66*strength)
    composite(img,rb,(262,13-round(3*breathe)),alpha=.66*strength)
    dm=resize_to(dome,281+round(7*breathe),198+round(2*breathe))
    composite(img,dm,(19-round(4*breathe),91),alpha=strength*1.0)
    gr=resize_to(ground,308,41)
    composite(img,gr,(6,264+round(2*breathe)),alpha=strength*.95)
    # Add a soft optical bloom derived solely from image-extracted painted
    # pixels, never hand-drawn shape primitives.
    glow=img.filter(ImageFilter.GaussianBlur(5))
    glow.putalpha(glow.getchannel('A').point(lambda x:int(x*.45*strength)))
    glow.alpha_composite(img)
    # Fade original artwork via alpha instead of a fake geometric shield.
    if n>=12:
        glow.putalpha(glow.getchannel('A').point(lambda x:int(x*strength)))
    return glow


def pose_hit(n,parts):
    *_,hit=parts
    img=Image.new('RGBA',(256,256),(0,0,0,0))
    q=n/7.
    scale=(.56+1.4*q)
    width=round(152*scale);height=round(128*scale)
    sp=resize_to(hit,width,height)
    sp=sp.rotate(n*4.1,Image.Resampling.BICUBIC,expand=True)
    composite(img,sp,(150-round(sp.width*.55),128-round(sp.height*.52)),alpha=(1-q)**1.12)
    return img


def atlas(frames,cols,path):
    cell=frames[0].width
    rows=(len(frames)+cols-1)//cols
    sheet=Image.new('RGBA',(cols*cell,rows*cell),(0,0,0,0))
    for i,fr in enumerate(frames):sheet.alpha_composite(fr,((i%cols)*cell,(i//cols)*cell))
    path.parent.mkdir(parents=True,exist_ok=True)
    sheet.save(path,optimize=True)
    return sheet


def main():
    hero=source_art('owner_kim_cang_reference')
    impact=source_art('owner_gold_impact')
    assert hero.size==(650,342),hero.size
    parts=prepare_components(hero,impact)
    ward=atlas([pose_ward(i,parts) for i in range(16)],4,OUTPUT/'gold_ward.png')
    hit=atlas([pose_hit(i,parts) for i in range(8)],4,OUTPUT/'guarded_hit.png')
    assert ward.size==(1280,1280) and hit.size==(1024,512)
    # This is 6.25 MiB + 2 MiB = 8.25MiB raw, not an Android VRAM measurement.
    raw=(ward.width*ward.height+hit.width*hit.height)*4
    assert raw==8650752
    print('FIST07_OWNER_REFERENCE_ATLAS_PASS=1 poses=24 pages=2 raw_rgba_bytes=8650752 source=owner_concept_no_rig')

if __name__=='__main__':main()
