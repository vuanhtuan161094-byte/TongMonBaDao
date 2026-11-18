#!/usr/bin/env python3
"""PAF05 R5F-only original ink-silk wind-seal charge poses (code-painted first-party art).

Isolated transparent layers, independent moving wind trails and growing calligraphy.
Does not alter the R5/R5E painter source, atlas or 7-second status treatment.
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops
import hashlib
import math
import random

SIDE = 320
SCALE = 3
N = 12
TAU = math.tau
ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'godot/labs/combat_lab/talisman15/r5f/assets'
SOURCE = ROOT / 'godot/labs/combat_lab/talisman15/r5f/art_sources'

def cubic(a, b, c, d, steps=96):
    return [((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0],
             (1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1])
            for t in (j / steps for j in range(steps+1))]

def pt(seq):
    return [(round(x*SCALE), round(y*SCALE)) for x,y in seq]

def ribbon(img, pts, width, tint, strength, seed, t, start=0.0, end=1.0):
    if len(pts)<3 or end<=start: return
    rng = random.Random(seed)
    a = max(0, int(start*(len(pts)-1)))
    b = min(len(pts)-1, max(a+2, int(end*(len(pts)-1))))
    sub = pts[a:b+1]
    p1=[];p2=[];p3=[]
    for j, (x,y) in enumerate(sub):
        z=j/max(1,len(sub)-1)
        prv=sub[max(0,j-1)]; nxt=sub[min(len(sub)-1,j+1)]
        dx=nxt[0]-prv[0];dy=nxt[1]-prv[1]; rr=max(.01,math.hypot(dx,dy))
        nx=-dy/rr;ny=dx/rr
        # Broad hairlike silk: wide shoulder, tapered ends, local fiber corrugation.
        w=width*(.12+.88*math.sin(math.pi*z)**.67)*(.93+.07*math.sin(z*29+seed))
        wob=math.sin(z*19 + t*2.7 + seed)*.85
        p1.append((x+nx*w+wob,y+ny*w))
        p2.append((x-nx*w*.53,y-ny*w*.53-wob))
        p3.append((x+nx*w*.13,y+ny*w*.13))
    color=Image.new('RGBA',img.size)
    d=ImageDraw.Draw(color)
    gold=tint[0]>140
    edge=(255,215,125) if gold else (106,239,197)
    shadow=(167,105,56) if gold else (26,162,147)
    core=(255,251,210) if gold else (224,255,222)
    d.polygon(pt(p1+p2[::-1]), fill=(*tint,round(205*strength if gold else 170*strength)))
    d.line(pt(p1),fill=(*edge,round(220*strength if gold else 160*strength)),width=3*SCALE,joint='curve')
    d.line(pt(p2),fill=(*shadow,round(160*strength if gold else 105*strength)),width=2*SCALE,joint='curve')
    d.line(pt(p3),fill=(*core,round(250*strength if gold else 185*strength)),width=2*SCALE,joint='curve')
    # Long painted microfibers, with irregular gaps; avoid straight neon bars.
    for f in range(6):
        shift=.10+f*.12
        span=.18+.065*(f%3)
        lo=int(shift*(len(sub)-1)); hi=min(len(sub),int((shift+span)*(len(sub)-1)))
        d.line(pt([(x+rng.uniform(-1.0,1.0),y+rng.uniform(-1.0,1.0)) for x,y in sub[lo:hi+1]]),
               fill=(*( (255,235,182) if gold else (246,255,227)),round((96+f*9)*strength)),width=(1+f%2)*SCALE)
    # A drifting luma packet follows the trajectory rather than rotating the whole sprite.
    h=(.23 + t*(.39+.055*(seed%3)) + seed*.07)%1
    idx=max(0,min(len(sub)-1,int(h*(len(sub)-1))))
    x,y=sub[idx]
    d.ellipse(((x-2.8)*SCALE,(y-2.8)*SCALE,(x+2.8)*SCALE,(y+2.8)*SCALE),fill=(255,240,171,round(230*strength)))
    aura=color.filter(ImageFilter.GaussianBlur(10*SCALE))
    aura.putalpha(aura.getchannel('A').point(lambda v:round(v*.45)))
    img.alpha_composite(aura)
    img.alpha_composite(color)

def sigil(img, t):
    """Readable traditional 風 at 1x: original layered gilding over OFL Noto CJK glyph.

    Noto Serif CJK Bold is a freely-licensed typography stencil (SIL OFL), not
    extracted JX/VL game artwork. The growing amber-gold, bloom and wind-silk
    material are rendered in our own isolated transparent frames.
    """
    font_path = Path('/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc')
    if not font_path.is_file():
        raise RuntimeError('PAF05 R5F source requires fonts-noto-cjk (OFL NotoSerifCJK-Bold.ttc)')
    font = ImageFont.truetype(str(font_path), 150 * SCALE)
    ink = Image.new('L', img.size, 0)
    d = ImageDraw.Draw(ink)
    # Real Traditional Chinese 風. A broad ~95px on-screen glyph at 216/320.
    d.text((159 * SCALE, 153 * SCALE), '風', font=font, anchor='mm', fill=255)
    assert ink.getbbox(), 'Missing the actual U+98A8 glyph'

    # Stroke formation: independent key-pose reveal, not a pasted paper card
    # or a spinning vector badge. By mid-charge the whole 風 is recognizable.
    progress = max(0.0, min(1.0, (t - .045) / .31))
    if progress <= 0.0:
        return
    reveal = Image.new('L', img.size, 0)
    sweep = ImageDraw.Draw(reveal)
    front = (91.0 + 166.0 * progress) * SCALE
    sweep.polygon([(0, 0), (img.width, 0),
                   (img.width, round(front - 5 * SCALE)),
                   (round(200 * SCALE), round(front + 3 * SCALE)),
                   (0, round(front - 2 * SCALE))], fill=255)
    ink = ImageChops.multiply(ink, reveal)

    def composite(rgb, alpha):
        layer = Image.new('RGBA', img.size, (*rgb, 0))
        layer.putalpha(alpha)
        img.alpha_composite(layer)

    # Dark bronze edge gives contrast on pale terrain; gold halo stays soft
    # and localized rather than turning the entire charge into a UI icon.
    halo = ink.filter(ImageFilter.GaussianBlur(13 * SCALE))
    composite((236, 150, 54), halo.point(lambda a: round(a * .46)))
    rim = ink.filter(ImageFilter.MaxFilter(11))
    composite((89, 46, 19), rim.point(lambda a: round(a * .65)))

    gild = Image.new('RGBA', img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(gild)
    for yy in range(72 * SCALE, 245 * SCALE):
        u = min(1.0, max(0.0, (yy / SCALE - 72) / 173))
        gd.line((0, yy, img.width, yy),
                fill=(255, round(219 - 48 * u + 13 * math.sin(u * math.pi)),
                      round(121 - 72 * u), 255))
    gild.putalpha(ink)
    img.alpha_composite(gild)
    core = ink.filter(ImageFilter.MinFilter(7))
    composite((255, 248, 175), core.point(lambda a: round(a * .34)))
    # Small live specular packet moves over the ink; the character remains
    # correctly legible, unlike a rotating/computer-UI glyph.
    sheen = Image.new('L', img.size, 0)
    shd = ImageDraw.Draw(sheen)
    sx = (83 + 132 * t) * SCALE
    shd.line((round(sx), 97 * SCALE, round(sx + 50 * SCALE),
              241 * SCALE), fill=196, width=12 * SCALE)
    sheen = ImageChops.multiply(ink, sheen.filter(ImageFilter.GaussianBlur(4 * SCALE)))
    composite((255, 247, 187), sheen.point(lambda a: round(a * .78)))



def pose(i):
    t=i/(N-1)
    im=Image.new('RGBA',(SIDE*SCALE,SIDE*SCALE))
    # Asymmetric wind-silk folds frame the wind command; not three lightning forks.
    paths=[
        ((31,223),(27,142),(120,51),(276,119)),
        ((284,234),(227,266),(169,268),(107,230)),
        ((282,151),(251,99),(200,111),(170,130)),
        ((48,263),(90,258),(113,247),(142,237)),
    ]
    for k,(a,b,c,d) in enumerate(paths):
        curve=cubic(a,b,c,d)
        shifted=[]
        for j,(x,y) in enumerate(curve):
            u=j/(len(curve)-1)
            envelope=math.sin(u*math.pi)
            shifted.append((x + envelope*(3.1*math.sin(t*3.8+k+u*5.2)),
                            y + envelope*(3.0*math.cos(t*4.3-k+u*3.7))))
        if k==0:
            start=max(0,.10 - .10*t); end=.47+.53*min(1,t*1.7)
        elif k==1:
            start=max(0,.16-.16*t);end=.36+.64*min(1,(t+.03)*1.55)
        elif k==2:
            start=0;end=max(.04,min(1,(t-.16)*1.7))
        else:
            start=0;end=max(.04,min(1,(t-.28)*1.8))
        ribbon(im,shifted,[13.3,7.8,4.2,3.4][k],
               [(34,185,151),(43,198,172),(90,226,186),(72,203,172)][k],
               [1,.96,.78,.65][k],k+7,t,start,end)
    # Three sparse, unequal warm light fibers thread the jade silk into the
    # 風 brush strokes. They grow toward the glyph; never a rotating ring.
    for k, controls in enumerate((
        ((49, 236), (89, 203), (105, 165), (128, 162)),
        ((271, 103), (248, 102), (220, 116), (194, 136)),
        ((230, 256), (218, 231), (204, 207), (185, 193)),
    )):
        strand = cubic(*controls, steps=76)
        ribbon(im, strand, (2.4, 2.0, 1.6)[k], (237, 172, 71),
               (.75, .71, .56)[k], 240 + k, t,
               0.0, max(.04, min(1.0, (t - .035) * (1.85 - .18 * k))))
    sigil(im,t)
    motes=Image.new('RGBA',im.size)
    d=ImageDraw.Draw(motes)
    rr=random.Random(5010+i)
    for k in range(22):
        angle=k*2.399+t*.85
        rad=43+35*((k*7)%17)/17
        x=158+rad*math.cos(angle);y=160+rad*.77*math.sin(angle)
        r=.55+rr.random()*1.0
        d.ellipse(((x-r)*SCALE,(y-r)*SCALE,(x+r)*SCALE,(y+r)*SCALE),
                  fill=(255,228,154,round((70+rr.random()*95)*min(1,.45+t))))
    im.alpha_composite(motes.filter(ImageFilter.GaussianBlur(2*SCALE)))
    im.alpha_composite(motes)
    return im.resize((SIDE,SIDE),Image.Resampling.LANCZOS)

def main():
    SOURCE.mkdir(parents=True,exist_ok=True)
    DEST.mkdir(parents=True,exist_ok=True)
    frames=[pose(i) for i in range(N)]
    sheet=Image.new('RGBA',(SIDE*4,SIDE*3))
    for i,frm in enumerate(frames): sheet.alpha_composite(frm,((i%4)*SIDE,(i//4)*SIDE))
    master=pose(8).resize((960,960),Image.Resampling.LANCZOS)
    mp=SOURCE/'paf05_r5f_wind_silk_master.png'
    sp=DEST/'paf05_r5f_charge.webp'
    master.save(mp)
    sheet.save(sp,'WEBP',quality=96,method=5,exact=True)
    for name,p in [('master',mp),('atlas',sp)]:
        print('PAF05_R5F_'+name.upper()+'_SHA256='+hashlib.sha256(p.read_bytes()).hexdigest())
    assert sheet.getextrema()[3][0]==0 and sheet.getextrema()[3][1]>=200
    print('PAF05_R5F_WIND_SILK_SOURCE_PASS frames=12 alpha=RGBA scene=R5F_ONLY no_rig=true')
if __name__=='__main__': main()
