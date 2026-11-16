#!/usr/bin/env python3
"""PAF01 R4: original high-resolution jade/ivory/gold wind paper.
Painted deterministic raster source. NO rig, UI vector, or commercial art.
Only the paper carried in PAF01 is reauthored; R3 wind, target 風 and fade are locked.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter,ImageFont
import numpy as np
import math

W,H,S=480,560,3
FONT="/usr/share/fonts/truetype/arphic-bkai00mp/bkai00mp.ttf"
if not Path(FONT).exists():
    FONT="/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc"

def c(v):return int(round(v*S))
def pts(p):return [(c(x),c(y)) for x,y in p]
def bez(a,b,d,e,n=20):
    p=[]
    for j in range(n+1):
        t=j/n;u=1-t
        p.append((u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*d[0]+t*t*t*e[0],
                  u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*d[1]+t*t*t*e[1]))
    return p
def boundary(phase):
    sway=math.sin(phase*math.pi/2)*2.3
    p=bez((156,100),(147,177),(157+sway,289),(145,382),30)
    p+=bez((145,382),(149,415),(138,442),(155,461),12)[1:]
    p+=bez((155,461),(188,471),(211,445),(238,472),15)[1:]
    p+=bez((238,472),(278,491),(299,441),(314,453),15)[1:]
    p+=bez((314,453),(333,396),(317,332),(333+sway,275),22)[1:]
    p+=bez((333+sway,275),(334,192),(326,128),(315,100),22)[1:]
    p+=bez((315,100),(284,91),(263,108),(239,87),15)[1:]
    p+=bez((239,87),(218,107),(176,95),(156,100),15)[1:]
    return pts(p)
def stroke(d,p,ink,weight):
    d.line(pts(p),fill=ink,width=max(1,c(weight)),joint="curve")
def shine(dst,src,blur=9,gain=.25):
    halo=src.filter(ImageFilter.GaussianBlur(c(blur)))
    halo.putalpha(halo.getchannel("A").point(lambda v:int(v*gain)))
    dst.alpha_composite(halo)
    dst.alpha_composite(src)
def make_talisman(phase=0):
    width,height=c(W),c(H)
    mask=Image.new("L",(width,height),0)
    ImageDraw.Draw(mask).polygon(boundary(phase),fill=255)
    mask=mask.filter(ImageFilter.GaussianBlur(c(.5)))
    rng=np.random.default_rng(7193)
    y,x=np.mgrid[0:height,0:width].astype(np.float32);x/=S;y/=S
    fleck=rng.normal(0,1,(height,width)).astype(np.float32)
    shadow=np.sin(x*.061+y*.036)*9+np.cos(x*.039-y*.089)*7
    grain=Image.fromarray(np.uint8(np.clip(127+fleck*32,0,255)))
    grain=(np.asarray(grain.filter(ImageFilter.GaussianBlur(c(1.4))),dtype=np.float32)-127)*.25
    edge=(np.abs(x-236)/105)**1.7
    warm=8*np.sin(y*.021+x*.01)
    rr=np.clip(((x-225)/136)**2+((y-273)/253)**2,0,1)
    shade=1-.24*rr+np.sin(y*.045+x*.022)*.048+np.sin(x*.065-y*.016)*.03
    fold=np.exp(-((x-(213+15*np.sin(y*.013)))**2)/(2*12**2))*.17
    red=np.clip((219+shadow+warm-edge*19+grain)*(shade-fold)+16,0,255).astype(np.uint8)
    green=np.clip((239+shadow*.45-edge*15+grain)*(shade-fold)+4,0,255).astype(np.uint8)
    blue=np.clip((213+shadow*.33-edge*25+grain*.9)*(shade-fold*.8)-10,0,255).astype(np.uint8)
    silk=Image.fromarray(np.stack((red,green,blue,np.asarray(mask,dtype=np.uint8)),axis=-1),"RGBA")
    out=Image.new("RGBA",(width,height))
    alpha=mask.filter(ImageFilter.GaussianBlur(c(17))).point(lambda q:int(q*.12))
    aura=Image.new("RGBA",(width,height),(23,106,95,0));aura.putalpha(alpha)
    out.alpha_composite(aura)
    out.alpha_composite(silk)
    # Ragged perimeter has light gold filigree, never a regular frame/UI panel.
    etch=Image.new("RGBA",(width,height));d=ImageDraw.Draw(etch,"RGBA")
    shape=boundary(phase)
    d.line(shape+[shape[0]],fill=(103,68,32,125),width=c(6),joint="curve")
    d.line(shape+[shape[0]],fill=(193,148,73,170),width=c(3),joint="curve")
    d.line(shape+[shape[0]],fill=(249,222,138,98),width=c(.8),joint="curve")
    for xx,sgn in ((170,-1),(301,1)):
        stroke(d,[(xx,127),(xx+sgn*5,195),(xx,277),(xx-sgn*4,370),(xx,427)],(29,133,126,65),1.5)
    for j in range(13):
        yy=125+j*24
        xx=171+3*math.sin(j*.79)
        stroke(d,[(xx,yy),(xx+5,yy+5),(xx+3,yy+13)],(182,133,67,45),.8)
        xx=301+3*math.sin(j*.91)
        stroke(d,[(xx,yy+1),(xx-6,yy+6),(xx-4,yy+13)],(182,133,67,55),.8)
    for direction in (-1,1):
        cy=100 if direction==1 else 455
        def Y(v):return cy+direction*v
        for side in (-1,1):
            ox=240+side*61
            stroke(d,bez((ox,Y(8)),(ox+side*21,Y(22)),
                         (ox-side*9,Y(40)),(ox-side*20,Y(26)),15),(194,146,57,175),2)
            stroke(d,[(ox,Y(18)),(ox-side*10,Y(29)),(ox-side*1,Y(43)),
                      (ox+side*16,Y(44))],(35,136,111,142),1.8)
        stroke(d,[(218,Y(15)),(240,Y(29)),(265,Y(15))],(228,182,76,180),2)
        d.ellipse((c(235),c(Y(10)-4),c(245),c(Y(10)+6)),fill=(246,235,158,205))
    shine(out,etch,6,.09)
    # Brush-styled traditional character, dark-jade mineral ink with restrained gold bloom.
    brush=Image.new("RGBA",(width,height));bd=ImageDraw.Draw(brush,"RGBA")
    ft=ImageFont.truetype(FONT,c(140))
    bd.text((c(171),c(199)),"風",font=ft,fill=(42,126,110,255),
            stroke_width=c(1.1),stroke_fill=(162,113,45,180))
    outer=brush.copy()
    outer.putalpha(brush.getchannel("A").point(lambda v:int(v*.27)))
    shine(out,outer,11,.42)
    out.alpha_composite(brush)
    # Uneven small counterseals and ink-wash vines on real material.
    decoration=Image.new("RGBA",(width,height));dd=ImageDraw.Draw(decoration,"RGBA")
    for k in range(2):
        p=[]
        for j in range(70):
            q=j/69
            xx=(188 if k==0 else 281)+(9 if k==0 else -14)*math.sin(q*math.tau*2.1+k*.8)
            p.append((xx+5*math.sin(q*19+k),173+q*242))
        stroke(dd,p,(36,148,140,103) if k==0 else (173,130,62,91),1.6)
        for j in range(5):
            yy=183+j*52+k*15;xx=187 if k==0 else 286
            delta=15 if k==0 else -16
            stroke(dd,[(xx,yy),(xx+delta,yy-12),(xx+delta,yy-17)],(26,143,130,102),1.2)
    small=ImageFont.truetype(FONT,c(19))
    for j,ch in enumerate(("玄","封","靈")):
        dd.text((c(207+j*25),c(162+(j%2)*12)),ch,font=small,fill=(24,118,105,119))
    out.alpha_composite(decoration)
    # Flecks and two airy strands are fine material details, not a ring projectile.
    gold=Image.new("RGBA",(width,height));gd=ImageDraw.Draw(gold,"RGBA")
    rng=np.random.default_rng(2719)
    for j in range(65):
        xx=float(rng.uniform(169,315));yy=float(rng.uniform(129,436))
        if (xx-235)**2/80**2+(yy-287)**2/75**2<1:continue
        aa=int(rng.integers(45,150));r=float(rng.uniform(.35,1.1))
        gd.ellipse((c(xx-r),c(yy-r),c(xx+r),c(yy+r)),fill=(240,218,138,aa))
    out.alpha_composite(gold)
    tendrils=Image.new("RGBA",(width,height));td=ImageDraw.Draw(tendrils,"RGBA")
    for k in range(2):
        p=[]
        for j in range(80):
            q=j/79
            p.append((237+(86+k*19)*math.sin(q*6.3+phase*.17+k*1.1),
                      151+q*269+7*math.sin(q*9.1+k)))
        stroke(td,p,(81,230,206,50+14*k),1.2 if k else 1.5)
    shine(out,tendrils,7,.17)
    if phase:
        sparks=Image.new("RGBA",(width,height));sd=ImageDraw.Draw(sparks,"RGBA")
        for j in range(4):
            xx=208+j*20+4*math.sin(phase*.8+j);yy=178+phase*13+j*42
            sd.ellipse((c(xx-1.8),c(yy-1.8),c(xx+1.8),c(yy+1.8)),fill=(246,248,197,110))
        shine(out,sparks,5,.24)
    return out.resize((W,H),Image.Resampling.LANCZOS)
