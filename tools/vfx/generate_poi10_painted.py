#!/usr/bin/env python3
"""POI10 - Độc Khí Phệ Tâm. First-party painted-light alpha source, no commercial pixels.
Produces distinct sprite flipbooks: converge, radial devour, chest crack, persistent toxin.
No skeletal rig; scene is view-only and never applies damage/status.
"""
from pathlib import Path
from PIL import Image, ImageFilter, ImageChops, ImageDraw, ImageEnhance
from math import pi,sin,cos
from hashlib import sha256
import random
ROOT=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/poison10/r1_painted/assets'
MASTER=ROOT/'master'
ROOT.mkdir(parents=True,exist_ok=True)
COLS=4

def load(name):
    im=Image.open(MASTER/(name+'.webp')).convert('RGBA')
    assert im.getchannel('A').getbbox(),name
    # retain actual author-painted color, increase the clean light intensities
    im=ImageEnhance.Brightness(ImageEnhance.Color(im).enhance(1.40)).enhance(1.65)
    return im

def image(w,h):return Image.new('RGBA',(w,h),(0,0,0,0))

def opacity(src,value):
    im=src.copy();im.putalpha(im.getchannel('A').point(lambda a:int(a*max(0,min(1,value)))))
    return im

def light_blend(dst,im,pos,blur,alpha):
    # Multi-pass glow from the actual luminous painted pixels, not drawn geometry.
    if blur:
        gl=im.filter(ImageFilter.GaussianBlur(blur))
        gl=opacity(gl,alpha)
        dst.alpha_composite(gl,pos)
    else:dst.alpha_composite(opacity(im,alpha),pos)

def scaled(src,w,h):return src.resize((int(w),int(h)),Image.Resampling.LANCZOS)

def variation(src,i,amp=3):
    # Frame-specific nonrigid horizontal displacement; source pixels remain painted.
    w,h=src.size;out=image(w,h)
    for y in range(h):
        shift=round(amp*sin(y/17+i*.61)*sin(pi*y/max(1,h-1)))
        row=src.crop((0,y,w,y+1))
        out.alpha_composite(row,(shift,y))
    return out

def finish(im):
    w,h=im.size;a=im.getchannel('A');mask=Image.new('L',(w,h),255);d=ImageDraw.Draw(mask)
    d.rectangle((0,0,w-1,2),fill=0);d.rectangle((0,h-3,w-1,h-1),fill=0)
    d.rectangle((0,0,2,h-1),fill=0);d.rectangle((w-3,0,w-1,h-1),fill=0)
    im.putalpha(ImageChops.multiply(a,mask));return im

CORE=load('venom_core');WAVE=load('venom_tendrils');HIT=load('heart_puncture');MARK=load('heart_corona'); HOT=load('heart_hotspot')

def charge_frame(i):
    w,h=224,192;out=image(w,h);t=(i+1)/12
    # A jagged source-painted off-axis ring, with several intertwined translucent tongues.
    core=scaled(variation(CORE,i,2.8),round(75+36*t),round(78+33*t))
    px=(w-core.width)//2;py=(h-core.height)//2
    light_blend(out,core,(px,py),13,0.60*t)
    light_blend(out,core,(px,py),3,0.56*t)
    light_blend(out,core,(px,py),0,.90*t)
    if i>2:
        phase=sin(i*.67)
        v=scaled(variation(WAVE,i,1.8),round(118+26*t),round(46+12*t))
        light_blend(out,v,(int(50-6*t),int(90+phase*9)),6,.18*t)
    if i>=3:
        focal=scaled(HOT,round(24+26*t),round(25+27*t))
        at=(w//2-focal.width//2,h//2-focal.height//2)
        light_blend(out,focal,at,7,.62*t)
        light_blend(out,focal,at,0,.94*t)
    return finish(out)

def burst_frame(i):
    w=h=224;out=image(w,h);t=i/11
    # Organic light corona. 4 non-identical painted tendril arcs orbit a heart core.
    # This is a baked flipbook; no runtime vector circles/rings.
    timing=[.18,.37,.64,.91,1,1,.85,.66,.50,.32,.18,.06][i]
    radius=21+43*min(1,t*2.2)
    angs=(-2.85,-1.39,.31,1.94)
    for k,a in enumerate(angs):
        angle=a+i*.095*(1 if k%2 else -.75)
        xx=112+cos(angle)*radius;yy=112+sin(angle)*radius*.70
        v=scaled(variation(WAVE,(i+k*3)%12,3),72+(k%2)*14,37+(i%3)*3)
        v=v.rotate(((-i*13)+(k*79))%360,Image.Resampling.BICUBIC,expand=True)
        pos=(int(xx-v.width/2),int(yy-v.height/2))
        light_blend(out,v,pos,8,.42*timing)
        light_blend(out,v,pos,0,.81*timing)
    orb=scaled(variation(CORE,i,3),int(54+41*timing),int(56+42*timing))
    light_blend(out,orb,(112-orb.width//2,112-orb.height//2),9,.78*timing)
    light_blend(out,orb,(112-orb.width//2,112-orb.height//2),0,.90*timing)
    if i<10:
        focal=scaled(HOT,int(22+25*timing),int(23+25*timing))
        light_blend(out,focal,(112-focal.width//2,112-focal.height//2),7,.78*timing)
        light_blend(out,focal,(112-focal.width//2,112-focal.height//2),0,1.0*timing)
    return finish(out)

def contact_frame(i):
    w,h=192,160;out=image(w,h)
    timing=[.24,.63,.98,1,.85,.69,.48,.29,.14,.035][i]
    k=scaled(variation(HIT,i,3.3),int(112+42*timing),int(64+22*timing))
    x=(w-k.width)//2;y=(h-k.height)//2
    light_blend(out,k,(x,y),9,.71*timing)
    light_blend(out,k,(x,y),2,.58*timing)
    light_blend(out,k,(x,y),0,.95*timing)
    if timing>.18:
        flash=scaled(HOT,int(17+30*timing),int(18+30*timing))
        at=(w//2-flash.width//2,h//2-flash.height//2)
        light_blend(out,flash,at,5,.65*timing)
        light_blend(out,flash,at,0,.93*timing)
    return finish(out)

def mark_frame(i):
    w=h=160;out=image(w,h)
    # Source-painted organic green-violet devour seal on the chest, *not* periodic fake poison ticks.
    t=i/12
    pulse=.78+.14*sin(i*pi/6.0)
    ring=scaled(variation(MARK,i,1.8),int(119+8*sin(i*pi/6)),int(69+6*cos(i*pi/6)))
    x=(w-ring.width)//2;y=(h-ring.height)//2
    light_blend(out,ring,(x,y),7,pulse*.44)
    light_blend(out,ring,(x,y),0,pulse*.93)
    # central swallowed-heart light, drawn from core source pixels
    source=scaled(variation(CORE,(i*2)%12,2),40,50)
    light_blend(out,source,(w//2-20,h//2-25),4,.18*pulse)
    pulse_img=scaled(HOT,19,20)
    light_blend(out,pulse_img,(w//2-9,h//2-10),2,.18*pulse)
    return finish(out)

def pack(name,fn,count,cell):
    w,h=cell;sheet=image(w*COLS,h*((count+COLS-1)//COLS));uniq=set()
    for i in range(count):
        frame=fn(i)
        assert frame.size==cell,(name,i,'dims')
        a=frame.getchannel('A');assert a.getbbox(),(name,i,'empty')
        borders=[(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)]
        assert all(a.crop(b).getextrema()[1]==0 for b in borders),(name,i,'alpha edge')
        uniq.add(sha256(frame.tobytes()).hexdigest())
        sheet.alpha_composite(frame,(i%4*w,i//4*h))
    assert len(uniq)==count,(name,'duplicate frames',len(uniq))
    dest=ROOT/name;sheet.save(dest,optimize=True,compress_level=9)
    print('POI10_ALPHA_DISTINCT_PASS',name,count,sheet.size,dest.stat().st_size)
    return sheet

if __name__=='__main__':
    sheets=[pack('devour_charge_r1_12.png',charge_frame,12,(224,192)),
            pack('devour_corona_r1_12.png',burst_frame,12,(224,224)),
            pack('devour_contact_r1_10.png',contact_frame,10,(192,160)),
            pack('devour_mark_r1_12.png',mark_frame,12,(160,160))]
    total=sum(i.width*i.height*4 for i in sheets)
    print('POI10_RAW_RGBA8_BYTES',total,'MiB',round(total/1048576,3))
    assert total<=8*1048576,total