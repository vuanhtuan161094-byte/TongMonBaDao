#!/usr/bin/env python3
"""PAF02 R4 opening paper: sharpen original, print exact Vietnamese PHONG ẤN.
FIRST-PARTY PAF01 R6 paper source and original PAF02 R3 independent fold poses.
No rig, gameplay, copied outside assets or modifications to LINE/CONTACT/BADGE.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
ORIGINAL=ROOT/'godot/labs/combat_lab/talisman11/art_sources/paf01_r6_illustrated_source.webp'
MASTER=ROOT/'godot/labs/combat_lab/talisman12/art_sources/paf02_r4_vietnamese_paper_master.png'
FONTS=[
    '/usr/share/fonts/truetype/dejavu/DejaVuSerifCondensed-BoldItalic.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSerif-BoldItalic.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
]
def font(size):
    for path in FONTS:
        if Path(path).is_file():
            return ImageFont.truetype(path,size)
    raise RuntimeError('DejaVu Vietnamese Latin Unicode font not installed')

def make_source(src=ORIGINAL,out=MASTER):
    # Work at 3× the original 230×275 reference layout, independently of
    # actual first-party image dimensions; never upscale a whole VFX poster.
    S=3;W=230;H=275
    art=Image.open(src).convert('RGBA').resize((W*S,H*S),Image.Resampling.LANCZOS)
    rgba=np.asarray(art,dtype=np.float32).copy()
    y,x=np.mgrid[0:H*S,0:W*S].astype(np.float32)
    x/=S;y/=S
    # Asymmetric soft edge follows the ink-wash paper field, NOT a rectangle.
    # Cover the existing pictographic 風, keeping all gold art and silk alpha.
    stencil=Image.new('L',art.size)
    pts=[(100,99),(128,93),(160,95),(151,120),(141,155),(119,166),(82,162),(91,130)]
    ImageDraw.Draw(stencil).polygon([(round(a*S),round(b*S)) for a,b in pts],fill=255)
    mask=np.asarray(stencil.filter(ImageFilter.GaussianBlur(S*3)),dtype=np.float32)/255.
    rng=np.random.default_rng(4197)
    noise=rng.normal(0,1,(H*S,W*S)).astype(np.float32)
    wash=np.sin(x*.112+y*.049)*3.7+np.cos(x*.052-y*.065)*2.9+noise*1.2
    jade=np.stack([30+wash*.60,99+wash*1.10,81+wash*.94],axis=-1)
    rgba[:,:,:3]=rgba[:,:,:3]*(1-mask[:,:,None])+jade*mask[:,:,None]
    painted=Image.fromarray(np.uint8(np.clip(rgba,0,255)),'RGBA')
    # Text is painted BEFORE the existing R3 paper warp (not screen-space HUD).
    # Exact accents: U+1EA4 in Ấ. Native scale still gets genuinely crisp edges.
    letters=Image.new('RGBA',art.size)
    d=ImageDraw.Draw(letters)
    for words,cy,point_size in [('PHONG',119,19),('ẤN',147,24)]:
        ft=font(point_size*S)
        bounds=d.textbbox((0,0),words,font=ft,stroke_width=0)
        width=bounds[2]-bounds[0];height=bounds[3]-bounds[1]
        xpos=round(121*S-width/2-bounds[0])
        ypos=round(cy*S-height/2-bounds[1])
        d.text((xpos+S*.6,ypos+S*.65),words,font=ft,
               fill=(19,65,55,145),stroke_width=round(1.2*S),
               stroke_fill=(10,65,55,150))
        d.text((xpos,ypos),words,font=ft,
               fill=(255,240,182,251),stroke_width=max(1,round(.35*S)),
               stroke_fill=(97,192,158,130))
    bloom=letters.filter(ImageFilter.GaussianBlur(S*3))
    bloom.putalpha(bloom.getchannel('A').point(lambda a:round(a*.21)))
    painted.alpha_composite(bloom)
    painted.alpha_composite(letters)
    sharpened=painted.filter(ImageFilter.UnsharpMask(radius=1.5*S,percent=145,threshold=3))
    sharpened.putalpha(painted.getchannel('A'))
    dest=Path(out);dest.parent.mkdir(parents=True,exist_ok=True)
    sharpened.save(dest)
    return dest

def render(i,n=14):
    from paf02_r3_initial_paper import build_hero as existing_fold_poses
    if not MASTER.is_file(): make_source()
    return existing_fold_poses(i,n,source=MASTER)

if __name__=='__main__':
    p=make_source()
    print('PAF02_R4_VIETNAMESE_SOURCE_BAKE_PASS',p)
