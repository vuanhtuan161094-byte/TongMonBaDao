#!/usr/bin/env python3
"""FIST10 R3 illustrated Bất Động Kim Chung: bake independently authored
ImageGen original bell pixels into frame-by-frame RGBA atlases. No rig.
Master retained in GitHub as base64 WebP derivative, full PNG in ChatGPT Library.
Gold source NOT copied from JX/VL commercial art. LAB only; no PvE writes."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance
import numpy as np, math, random, json, hashlib, subprocess, io, base64
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'godot/labs/combat_lab/fist10/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
SRC=ROOT/'godot/labs/combat_lab/fist10/assets/source/r2_illustrated_bell_640.webp.b64'
data=base64.b64decode(''.join(SRC.read_text(encoding='ascii').split()),validate=True)
with Image.open(io.BytesIO(data)) as opened:
 source=opened.convert('RGBA').resize((1254,1254),Image.Resampling.LANCZOS)
assert source.size==(1254,1254)
source.save(OUT/'fist10_illustrated_bell_r2_source.png',optimize=True)
# Remove low-alpha poster fringe; preserve original bright/gold/jade painterly pixels.
a=np.asarray(source,dtype=np.uint8).copy()
r,g,b,alpha=[a[:,:,i].astype('float32') for i in range(4)]
red_fringe=(r>g*1.48)&(g<154)&(b<106)&(alpha<247)
a[:,:,3]=np.where(red_fringe,0,np.where(alpha<20,0,alpha)).astype('uint8')
clean=Image.fromarray(a,'RGBA')
clean.save(OUT/'fist10_clean_transparent_master.png',optimize=True)
def fade(pic,a):
 pic=pic.copy();pic.putalpha(pic.getchannel('A').point(lambda p:int(max(0,min(255,p*a)))));return pic
def place(dst,im,xy,strength=1):
 im=fade(im,strength);x=round(xy[0]-im.width/2);y=round(xy[1]-im.height/2)
 l=max(0,-x);t=max(0,-y);rr=min(im.width,dst.width-x);bb=min(im.height,dst.height-y)
 if rr>l and bb>t:dst.alpha_composite(im.crop((l,t,rr,bb)),(max(0,x),max(0,y)))
def frame_atlas(frames,cell,name):
 w=cell*4;h=cell*((len(frames)+3)//4);out=Image.new('RGBA',(w,h))
 for i,im in enumerate(frames):out.alpha_composite(im,(i%4*cell,i//4*cell))
 out.save(OUT/name,optimize=True)
 return out
large=clean.resize((359,359),Image.Resampling.LANCZOS)
seal=clean.crop((45,880,1210,1210)).resize((177,48),Image.Resampling.LANCZOS)
crest=clean.crop((385,2,890,460)).resize((77,70),Image.Resampling.LANCZOS)
left=clean.crop((15,350,500,1100)).resize((56,126),Image.Resampling.LANCZOS)
right=clean.crop((750,350,1238,1100)).resize((56,126),Image.Resampling.LANCZOS)
impact=clean.crop((684,230,1240,1110)).resize((169,236),Image.Resampling.LANCZOS)
impact_flash=clean.crop((420,260,850,610)).resize((92,73),Image.Resampling.LANCZOS)
cast=[]
for k in range(12):
 im=Image.new('RGBA',(384,384));t=k/11
 reveal=[.09,.17,.26,.38,.52,.70,.86,1.,1.,.91,.72,.38][k]
 scale=[.42,.53,.61,.73,.82,.90,.98,1.02,1.04,1.02,.95,.81][k]
 z=large.resize((round(350*scale),round(350*scale)),Image.Resampling.LANCZOS)
 # Wipe gold painting from crown to base; key poses show a real growing bell.
 arr=np.array(z,dtype=np.uint8);height=arr.shape[0];yy=np.arange(height,dtype=float)[:,None]
 wipe=np.clip((reveal*height-yy)/max(height*.17,1),0,1)
 arr[:,:,3]=(arr[:,:,3].astype(float)*wipe).astype('uint8')
 z=Image.fromarray(arr,'RGBA')
 if k<6:
  place(im,seal.resize((int(105+80*reveal),int(24+25*reveal)),Image.Resampling.LANCZOS),(192,350),min(1,reveal*1.22)*max(0,(6-k)/6))
 place(im,z,(192,184+(1-scale)*30),min(1,reveal*1.22))
 if k in (6,7,8,9):
  halo=z.filter(ImageFilter.GaussianBlur(11));place(im,halo,(192,183+(1-scale)*30),.17)
 cast.append(im)
# R3: cohesive small bell surrounds moving recipient, no split cropped rectangles.
mini_bell=clean.resize((134,134),Image.Resampling.LANCZOS)
base_seal=clean.crop((45,880,1210,1210)).resize((125,28),Image.Resampling.LANCZOS)
state=[]
for k in range(8):
 im=Image.new('RGBA',(192,192));ph=k*math.tau/8
 light=.66+.10*math.sin(ph)
 # single complete source-painted bell, small enough for four-second guard
 place(im,mini_bell,(96+1.5*math.cos(ph),101+1.5*math.sin(ph)),light*.72)
 
 state.append(im)
# Real illustrated bell resonates around ONE protected actor on a confirmed
# guard block: hot spot on incoming right flank, no fabricated damage.
contact_bell=clean.resize((210,210),Image.Resampling.LANCZOS)
# Jewel spark: alpha-filter source-painted center; no hard rectangular crop.
bright=clean.crop((450,295,800,620)).resize((74,69),Image.Resampling.LANCZOS)
arr=np.asarray(bright,dtype=np.uint8).copy();h,w=arr.shape[:2]
yy,xx=np.mgrid[0:h,0:w].astype(float)
rad=((xx-(w-1)/2)/(w*.48))**2+((yy-(h-1)/2)/(h*.47))**2
arr[:,:,3]=np.clip(arr[:,:,3]*np.clip((1-rad)/.46,0,1),0,255).astype('uint8')
bright=Image.fromarray(arr,'RGBA')
contact=[]
for k in range(8):
 im=Image.new('RGBA',(256,256))
 pulse=[.19,.55,1,.88,.64,.39,.16,.035][k]
 shake=[0,2,7,10,6,2,0,0][k]
 place(im,contact_bell,(121+shake,130),pulse*.94)
 # White-hot local collision flash is only an ACCENT. The complete
 # source-painted bell remains the hero; no cropped square overlay.
 glow=Image.new('RGBA',(256,256));pen=ImageDraw.Draw(glow,'RGBA')
 cx=197+shake;cy=117
 pen.ellipse((cx-19,cy-17,cx+19,cy+17),fill=(255,224,107,round(193*pulse)))
 pen.ellipse((cx-10,cy-9,cx+10,cy+9),fill=(255,255,226,round(218*pulse)))
 aura=glow.filter(ImageFilter.GaussianBlur(15))
 im.alpha_composite(aura)
 centerpoint=Image.new('RGBA',(256,256));p2=ImageDraw.Draw(centerpoint,'RGBA')
 p2.ellipse((cx-7,cy-6,cx+7,cy+6),fill=(255,255,234,round(215*pulse)))
 im.alpha_composite(centerpoint)
 contact.append(im)
frame_atlas(cast,384,'f10_cast_bell.png')
frame_atlas(state,192,'f10_status_seal.png')
frame_atlas(contact,256,'f10_guard_resonance.png')
raw=sum(4*x for x in (384*384*12, 192*192*8, 256*256*8))
assert raw==10354688,raw
for atlas_file,frames in (
 ('f10_cast_bell.png',12),('f10_status_seal.png',8),('f10_guard_resonance.png',8)):
 with Image.open(OUT/atlas_file) as img:
  assert img.mode=='RGBA' and img.getchannel('A').getextrema()[0]==0
print('FIST10_BAKE_PASS poses=28 pages=3 raw_rgba_bytes=10354688 no_rig=true first_party_derived_material=true')
print('FIST10_R2_ILLUSTRATED_SOURCE_GITHUB_MASTER present=true')
