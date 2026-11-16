#!/usr/bin/env python3
"""PAF01 R5: richer first-party parchment/pigment finish; R3 wind & mark untouched."""
from PIL import Image,ImageDraw,ImageFilter
import math,random
from paf01_r4_paper import make_talisman

S=3
def C(x):return round(x*S)
def P(p):return [(C(x),C(y)) for x,y in p]
def shade(out,layer,blur=8,gain=.5):
    glow=layer.filter(ImageFilter.GaussianBlur(C(blur)))
    glow.putalpha(glow.getchannel("A").point(lambda a:int(a*gain)))
    out.alpha_composite(glow)
    out.alpha_composite(layer)
def curve(d,a,b,end,col,width=2):
    p=[]
    for j in range(52):
        t=j/51
        p.append(((1-t)**2*a[0]+2*(1-t)*t*b[0]+t*t*end[0],
                  (1-t)**2*a[1]+2*(1-t)*t*b[1]+t*t*end[1]))
    d.line(P(p),fill=col,width=max(1,C(width)),joint="curve")
def make_talisman_r5(phase=0):
    base=make_talisman(phase).resize((1440,1680),Image.Resampling.LANCZOS)
    paint=Image.new("RGBA",base.size)
    d=ImageDraw.Draw(paint,"RGBA")
    rng=random.Random(4901)
    # Actual material fibers, not generic UI checkerboard.
    for i in range(440):
        x=rng.uniform(162,314);y=rng.uniform(128,451)
        length=rng.uniform(1.3,14)
        alpha=rng.randint(15,65)
        color=(98,92,54,alpha) if i%3==0 else (70,127,112,alpha)
        d.line(P([(x,y),(x+length*.2,y+length)]),fill=color,width=max(1,C(.3)))
    # Hand-inked auspicious cloud feathers and sage brush accents.
    for j in range(7):
        sx=178+14*j;dy=158+(j%2)*14
        curve(d,(sx,dy),(sx+5,dy-18),(sx+21,dy-9),(202,161,92,130),1.4)
        curve(d,(sx,dy+7),(sx+8,dy+19),(sx+28,dy+13),(41,171,140,104),1.1)
    for j in range(6):
        sx=179+j*23;dy=410+(j%3)*7
        curve(d,(sx,dy),(sx+13,dy+21),(sx+37,dy+3),(197,135,60,140),1.6)
        curve(d,(sx,dy-6),(sx+7,dy-19),(sx+15,dy-10),(40,165,140,97),1.2)
    for side in (-1,1):
        x=235+side*64
        curve(d,(x,200),(x+side*19,264),(x+side*2,357),(190,123,55,180),2.8)
        curve(d,(x-side*1,210),(x+side*10,263),(x+side*4,359),(251,223,140,186),1.0)
        for j in range(7):
            y=210+j*20;xx=x+side*(j%3*3)
            curve(d,(xx,y),(xx-side*15,y-12),(xx-side*25,y-9),(56,163,136,140),1.9)
    leaf=Image.new("RGBA",base.size);ld=ImageDraw.Draw(leaf,"RGBA")
    ld.line(P([(205,229),(211,214),(231,210),(243,220),(260,216),(270,239)]),
            fill=(255,233,145,220),width=C(2.3),joint="curve")
    for j in range(23):
        q=j/22
        xx=191+94*q+5*math.sin(j*.9+phase*.3)
        yy=250+24*math.sin(q*3.6+phase*.1)
        radius=1.2+1.5*math.sin(q*math.pi)
        ld.ellipse((C(xx-radius),C(yy-radius),C(xx+radius),C(yy+radius)),
                   fill=(255,236,176,int(195*math.sin(q*math.pi))))
    shade(base,leaf,13,.44)
    base.alpha_composite(paint)
    # Off-center gilded ornaments read at 1x as seal-making marks.
    fx=Image.new("RGBA",base.size);fd=ImageDraw.Draw(fx,"RGBA")
    for x,y,r in ((237,125,12),(240,443,11),(190,185,7),(289,384,9)):
        fd.ellipse((C(x-r),C(y-r),C(x+r),C(y+r)),
                   outline=(255,231,147,166),width=C(1.5))
        fd.ellipse((C(x-2),C(y-2),C(x+2),C(y+2)),fill=(248,246,203,213))
        for side in (-1,1):
            curve(fd,(x+side*r,y),(x+side*1.4*r,y+9),
                  (x+side*r*.5,y+14),(184,135,60,140),1.3)
    shade(base,fx,8,.24)
    return base.resize((480,560),Image.Resampling.LANCZOS)
