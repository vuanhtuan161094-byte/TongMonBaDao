#!/usr/bin/env python3
"""POI09 · Bách Độc Tán Châm: independently authored first-party sprite-source pixels.
Reads FOUR isolated RGBA painted masters, creates distinct multi-frame alpha atlases.
No Source A/JX/Võ Lâm pixels, no character rig, and no actual combat status writes.
"""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw,ImageFilter
from math import sin,pi,cos
from hashlib import sha256
BASE=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/poison09/r1_painted/assets'
MASTER=BASE/'master'
BASE.mkdir(parents=True,exist_ok=True)

def load(n):
 im=Image.open(MASTER/n).convert('RGBA')
 assert im.getchannel('A').getbbox(),n
 return im

def wave(src,i,drift):
 w,h=src.size;out=Image.new('RGBA',src.size,(0,0,0,0))
 # Pixel wave warps the actual painted material, never a vector line substitute.
 for y in range(h):
  v=int(drift*sin(y/21+i*.58)*sin(pi*y/max(1,h)))
  row=src.crop((0,y,w,y+1));out.alpha_composite(row,(v,y))
 return out

def fit(image,cell,size,offset):
 w,h=cell
 out=Image.new('RGBA',cell,(0,0,0,0))
 img=image.resize(size,Image.Resampling.LANCZOS)
 out.alpha_composite(img,offset)
 a=out.getchannel('A');m=Image.new('L',cell,255);d=ImageDraw.Draw(m)
 d.rectangle((0,0,w-1,2),fill=0);d.rectangle((0,h-3,w-1,h-1),fill=0)
 d.rectangle((0,0,2,h-1),fill=0);d.rectangle((w-3,0,w-1,h-1),fill=0)
 out.putalpha(ImageChops.multiply(a,m))
 return out

def fade(src,v):
 out=src.copy();out.putalpha(src.getchannel('A').point(lambda x:int(x*v)))
 return out
charge=load('fanlotus_charge_master.webp')
needle=load('poison_needle_master.webp')
impact=load('burst_contact_master.webp')
mark=load('sixsecond_toxin_master.webp')

def charge_frame(i):
 t=(i+.6)/12
 src=wave(charge,i,2.3+2*sin(i*.63))
 size=(int(156*(.68+.31*t)),int(104*(.68+.31*t)))
 out=fit(fade(src,.3+.7*t),(224,160),size,((224-size[0])//2,(160-size[1])//2+3))
 return out

def needle_frame(i):
 t=i/11
 src=wave(needle,i,3.1)
 size=(int(193+10*sin(i*.7)),int(74+4*sin(i*.65)))
 out=fit(fade(src,.87+.13*sin(i*.6+1)),(256,96),size,(42,10))
 return out

def impact_frame(i):
 t=i/9
 level=[.31,.77,1.,.94,.83,.69,.52,.38,.24,.06][i]
 src=wave(impact,i,3.9)
 size=(int(165*(1+.08*t)),int(97*(1+.05*t)))
 out=fit(fade(src,level),(192,160),size,((192-size[0])//2,38))
 return out

def status_frame(i):
 t=i/12
 src=wave(mark,i,2.5)
 size=(int(166+7*sin(i*pi/6)),int(94+5*cos(i*pi/6)))
 out=fit(fade(src,.70+.14*sin(i*pi/6+.3)),(192,160),size,((192-size[0])//2,42))
 return out

def atlas(name,frames,cell):
 w,h=cell;out=Image.new('RGBA',(w*4,h*((len(frames)+3)//4)),(0,0,0,0));uniq=set()
 for i,frame in enumerate(frames):
  assert frame.size==cell
  a=frame.getchannel('A');assert a.getbbox(),(name,i,'EMPTY')
  for e in [(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)]:
   assert a.crop(e).getextrema()[1]==0,(name,i,'BORDER')
  uniq.add(sha256(frame.tobytes()).hexdigest())
  out.alpha_composite(frame,((i%4)*w,(i//4)*h))
 assert len(uniq)==len(frames),(name,'DUPLICATE')
 dest=BASE/name;out.save(dest,optimize=True,compress_level=9)
 print('POI09_ALPHA_UNIQUE_PASS',name,len(frames),out.size,dest.stat().st_size)
 return out

if __name__=='__main__':
 packs=[atlas('poison_fan_charge_r1_12.png',[charge_frame(i) for i in range(12)],(224,160)),
        atlas('poison_fan_needle_r1_12.png',[needle_frame(i) for i in range(12)],(256,96)),
        atlas('poison_fan_contact_r1_10.png',[impact_frame(i) for i in range(10)],(192,160)),
        atlas('poison_fan_mark_r1_12.png',[status_frame(i) for i in range(12)],(192,160))]
 total=sum(im.width*im.height*4 for im in packs)
 assert total<8*1048576,total
 print('POI09_RAW_RGBA8_BYTES',total,'MiB',round(total/1048576,3))