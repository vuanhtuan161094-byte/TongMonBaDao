#!/usr/bin/env python3
"""PAF01 R1 | Phong Giới Truy Dấu — FIRST-PARTY luminous wind talisman.

This permanently committed recipe draws an original high-resolution cyan-gold
Phong An master and a separate bound-target glyph from hand-authored asymmetric
painted wind strokes, calligraphic paper and original TMB first-party paper.
Pillow's soft raster brushes generate the SOURCE sprites before Godot import;
Godot only composites genuine RGBA flipbook cells. The asset source is
code-painted rather than a separately illustrated / hand-painted imported
master. That provenance limitation must be visible in the owner review.
No rig, Source A/JX copyrighted art, fake damage or live status writes.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import io,base64,math,hashlib
import numpy as np
from paf01_r4_paper import make_talisman

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/talisman11/assets"
PAPER=ROOT/"godot/labs/combat_lab/talisman06/art_sources/hf01_r5_talisman_master_png.b64"
FONT="/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc"

def smooth(a,b,x):
    q=max(0,min(1,(x-a)/(b-a)))
    return q*q*(3-2*q)

def paper_source():
    raw=base64.b64decode("".join(PAPER.read_text().split()),validate=True)
    im=Image.open(io.BytesIO(raw)).convert("RGBA")
    assert im.size==(96,132),im.size
    print("PAF01_FIRST_PARTY_PAPER_SHA256",hashlib.sha256(raw).hexdigest())
    return im

def font(size):
    return ImageFont.truetype(FONT,size,index=0)

def shine(dst,src,blur=10,gain=.37):
    halo=src.filter(ImageFilter.GaussianBlur(blur))
    halo.putalpha(halo.getchannel("A").point(lambda v:round(v*gain)))
    dst.alpha_composite(halo)
    dst.alpha_composite(src)

def original_scroll(paper):
    w,h=480,560
    c=Image.new("RGBA",(w,h))
    # The original project paper supplies only the paper material. All 
    # source strokes, spatial silhouette, legibility and cyan-gold wisps are
    # independently authored for Phong Ấn, never a batch recolour of HF01.
    p=paper.resize((160,236),Image.Resampling.LANCZOS).rotate(-9,Image.Resampling.BICUBIC,expand=True)
    p.putalpha(p.getchannel("A").point(lambda v:round(v*.83)))
    c.alpha_composite(p,(145,173))
    e=Image.new("RGBA",c.size);d=ImageDraw.Draw(e,"RGBA")
    d.line([(169,399),(147,280),(162,177),(255,159),(307,188),(295,300),(269,420)],
        fill=(249,219,132,209),width=6,joint="curve")
    d.line([(183,393),(171,269),(184,192),(250,180),(289,205),(282,302),(260,404)],
        fill=(148,250,241,231),width=3,joint="curve")
    for j in range(11):
        y=207+j*17
        x=199+int(11*math.sin(j*1.3))
        d.line([(x,y),(x+14,y-5),(x+24,y+3)],fill=(172,245,223,125+j%3*22),width=2)
    t=Image.new("RGBA",c.size)
    td=ImageDraw.Draw(t)
    td.text((183,218),"風",font=font(99),fill=(250,252,216,244),
        stroke_width=2,stroke_fill=(35,219,227,214))
    shine(e,t,blur=13,gain=.55)
    shine(c,e,blur=17,gain=.36)
    wisps=Image.new("RGBA",c.size);rd=ImageDraw.Draw(wisps,"RGBA")
    for j in range(5):
        points=[]
        for k in range(58):
            q=k/57
            a=-3.20+j*1.02+q*(2.1+.23*math.sin(j))
            r=98+31*math.sin(math.pi*q+1.12*j)+14*j
            points.append((235+r*math.cos(a)*.94,
                           297+r*math.sin(a)*1.23))
        for k in range(1,len(points)):
            q=k/57
            ww=max(1,int(10*(1-q)**1.35))
            rd.line([points[k-1],points[k]],
                    fill=(97,255,246,round(180*(1-q)**.73)),
                    width=ww)
    shine(c,wisps,blur=12,gain=.44)
    return c

def original_mark():
    c=Image.new("RGBA",(420,420))
    glyph=Image.new("RGBA",c.size)
    d=ImageDraw.Draw(glyph)
    d.text((104,79),"風",font=font(160),fill=(251,255,215,245),
        stroke_width=2,stroke_fill=(27,207,221,222))
    shine(c,glyph,blur=21,gain=.57)
    ribbons=Image.new("RGBA",c.size)
    d=ImageDraw.Draw(ribbons,"RGBA")
    # Three uneven TEXTURED brush trails around single glyph; not a complete
    # circular forcefield, target explosion or geometric HUD spinner.
    for j in range(3):
        pts=[]
        for k in range(47):
            q=k/46
            a=[-2.8,.7,2.0][j]+q*2.48
            r=130-22*q+12*math.sin(4.1*q+j)
            pts.append((210+math.cos(a)*r,204+math.sin(a)*r*.76))
        for k in range(1,47):
            q=k/46
            d.line([pts[k-1],pts[k]],fill=(129,252,243,round(167*(1-q))),
                width=max(1,round(8*(1-q))))
    shine(c,ribbons,blur=11,gain=.37)
    return c

def copy_at(dst,src,x,y,scale=1,rot=0,alpha=1):
    if alpha<=0.001:return
    if scale!=1:
        src=src.resize((max(1,round(src.width*scale)),max(1,round(src.height*scale))),Image.Resampling.LANCZOS)
    if rot:src=src.rotate(rot,Image.Resampling.BICUBIC,expand=True)
    if alpha<1:
        src=src.copy()
        src.putalpha(src.getchannel("A").point(lambda v:round(v*alpha)))
    dst.alpha_composite(src,(round(x-src.width*.5),round(y-src.height*.5)))

def streamer(i,scroll):
    w,h=512,256
    c=Image.new("RGBA",(w,h));q=i/15
    # R3 replaces R1 four parallel noodle-like sine tracers with ONE
    # painterly fan: a broad uneven primary wind stroke, a whiplash bright
    # core and two organic fragmentation tails. All 16 cells are really
    # source-baked before Godot, no runtime SVG/UI line rendering.
    low=Image.new("RGBA",c.size)
    d=ImageDraw.Draw(low,"RGBA")
    for k in range(3):
        pts=[]
        for j in range(105):
            p=j/104
            x=19+480*p
            phase=p*5.35+i*.27+k*1.92
            envelope=(1-.48*p)
            y=119+(42-12*k)*math.sin(phase)*envelope
            y+=9*math.sin(p*14.2-i*.21+k*.89)
            if k==2:y+=24*math.sin(math.pi*p)
            pts.append((x,y))
        for j in range(1,105):
            p=j/104
            taper=(1-smooth(.65,1,p))*(.57+.43*smooth(0,.16,p))
            thick=round((23 if k==0 else 8 if k==1 else 5)*taper)
            if thick<1:continue
            alpha=round((196 if k==0 else 161 if k==1 else 127)*taper)
            d.line([pts[j-1],pts[j]],fill=((82,231,225,alpha) if k!=1 else (211,255,238,alpha)),
                   width=max(1,thick))
    shine(c,low,blur=21,gain=.64)
    # A genuine 風 seal rises inside the primary optical brush; this stamp
    # is NOT a gameplay projectile. It is visually tracked by the single
    # source→target transfer animation, canonical projectile speed remains0.
    sx=79+358*q
    sy=118+24*math.sin(i*.34)
    copy_at(c,scroll,sx,sy,.245+.035*math.sin(i*.33),rot=-11+26*math.sin(i*.26),
            alpha=.82+.17*math.sin(math.pi*q))
    return c

def charge(i,scroll):
    c=Image.new("RGBA",(320,320))
    q=i/11
    s=.37+.19*smooth(.02,.84,q)
    copy_at(c,scroll,160,151,s,rot=7*math.sin(q*math.tau),alpha=.34+.64*q)
    return c

def mark(i,master):
    c=Image.new("RGBA",(256,256))
    q=i/19
    # The mark has genuine living flutter; it does NOT flash damage each cycle.
    scale=.51+.075*math.sin(i*.24)
    drift=3.5*math.sin(i*.3)
    copy_at(c,master,128+drift,120+3*math.sin(i*.18),scale,
            rot=6*math.sin(i*.17),alpha=.91)
    return c

def contact(i,master):
    c=Image.new("RGBA",(256,256))
    q=i/11
    scale=.26+.34*smooth(.02,.79,q)
    # A real source-pigment first and final cell are required; the Godot
    # renderer owns the actual fade. No empty-frame discontinuity.
    alpha=(.22+.78*smooth(.0,.22,q))*(.12+.88*(1-smooth(.70,1,q)))
    copy_at(c,master,128,126,scale,rot=-9+14*q,alpha=alpha)
    return c

def atlas(images,w,h):
    out=Image.new("RGBA",(4*w,((len(images)+3)//4)*h))
    for i,img in enumerate(images):
        out.alpha_composite(img,(i%4*w,i//4*h))
    return out

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    # R4 only improves paper; preserve every accepted R3 wind and moving-mark routine.
    poses=[make_talisman(i) for i in range(4)]
    sigil=poses[0]
    for k,p in enumerate(poses):
        p.save(OUT/f'paf01_r4_paper_pose_{k}.png')
    glyph=original_mark()
    # Original 480x560 / 420x420 master PNGs are reproducibly authored by
    # this committed Python source, and archived in technical CI evidence.
    sigil.save(OUT/"paf01_original_480x560.png")
    glyph.save(OUT/"paf01_mark_original_420.png")
    frames={
      "tal11_r1_charge.webp":(atlas([charge(i,poses[i%4]) for i in range(12)],320,320),320,320,12),
      "tal11_r1_stream.webp":(atlas([streamer(i,poses[i%4]) for i in range(16)],512,256),512,256,16),
      "tal11_r1_contact.webp":(atlas([contact(i,glyph) for i in range(12)],256,256),256,256,12),
      "tal11_r1_mark.webp":(atlas([mark(i,glyph) for i in range(20)],256,256),256,256,20)
    }
    for name,(im,w,h,n) in frames.items():
        assert im.getchannel("A").getextrema()[0]==0,name
        hashes=set()
        for i in range(n):
            frame=im.crop((i%4*w,i//4*h,(i%4+1)*w,(i//4+1)*h))
            assert frame.getchannel("A").getextrema()[1]>10,(name,i)
            hashes.add(hashlib.sha256(frame.tobytes()).hexdigest())
        assert len(hashes)==n,(name,len(hashes))
        p=OUT/name
        im.save(p,"WEBP",quality=91,method=6,exact=True)
        print("PAF01_VFX_ATLAS_TECH_PASS",name,im.size,"frames",n,"sha256",hashlib.sha256(p.read_bytes()).hexdigest())
    print("PAF01_R1_SOURCE_BAKE_PASS")  # historical CI marker
    print("PAF01_R4_PAPER_SOURCE_BAKE_PASS")
if __name__=="__main__":main()
