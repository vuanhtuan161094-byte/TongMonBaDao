#!/usr/bin/env python3
"""First-party original PIL raster painting candidate for Sword02, NOT an art approval.
Each cel is independently painted with a changing blade/curved-wind body.
No external/copyrighted pixel source, no generated dashboard crop, no rig.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math, random, hashlib, json, os
import numpy as np

OUT=Path(os.environ.get('TMB_SWORD02_OUTPUT_DIR', str(Path(__file__).resolve().parent / 'generated_r1'))); OUT.mkdir(parents=True,exist_ok=True)
N=512; S=2; W=H=N*S
C={"white":(234,250,255),"light":(154,227,255),"bright":(64,186,255),"blue":(31,122,238),"deep":(22,66,170),"silver":(178,211,227)}

# High-res compositing and brushed nonuniform edges; never a static frame reskin.
def screen(x,y):return (int(x*S),int(y*S))
def shape(canvas, points, color):ImageDraw.Draw(canvas,'RGBA').polygon([screen(*q) for q in points],fill=color)
def lines(canvas, points, color, width=1):ImageDraw.Draw(canvas,'RGBA').line([screen(*q) for q in points],fill=color,width=int(width*S),joint='curve')
def disk(canvas, pos, rx, ry, c):
 d=ImageDraw.Draw(canvas,'RGBA');x,y=screen(*pos);d.ellipse((x-rx*S,y-ry*S,x+rx*S,y+ry*S),fill=c)

def arc_coords(cx,cy,rx,ry,a0,a1,num=75,flutter=0,phase=0):
  arr=[]
  for i in range(num):
    u=i/(num-1);a=a0+(a1-a0)*u
    radial=1+flutter*(math.sin(13*a+phase)+0.25*math.sin(27*a+phase*.73))
    arr.append((cx+rx*math.cos(a)*radial,cy+ry*math.sin(a)*radial))
  return arr

def taper_ribbon(canvas,pts,w0,w1,c,rough,seed,reverse=False):
  rng=random.Random(seed);outL=[];outR=[];l=len(pts)
  for i,p in enumerate(pts):
    u=i/max(1,l-1);q1=pts[max(0,i-1)];q2=pts[min(l-1,i+1)];dx=q2[0]-q1[0];dy=q2[1]-q1[1];ll=max(.001,math.hypot(dx,dy));nx=-dy/ll;ny=dx/ll
    envelope=(math.sin(math.pi*u)**.63)*(1.05-.35*u)
    wav=.84+.20*math.sin(i*.85+seed*.17)+rng.uniform(-rough,rough)
    thick=(w0+(w1-w0)*u)*envelope*wav
    outL.append((p[0]+nx*thick,p[1]+ny*thick))
    outR.append((p[0]-nx*thick*.55,p[1]-ny*thick*.55))
  shape(canvas,outL+list(reversed(outR)),c)

def texture_particles(layers,center,radius,quantity,seed,bright=False):
 rng=random.Random(seed)
 for i in range(quantity):
  a=rng.uniform(-math.pi,math.pi);r=radius*math.sqrt(rng.random());x=center[0]+r*math.cos(a)*1.25;y=center[1]+r*math.sin(a)*.69
  ln=rng.uniform(2,12);c=(165,227,255,int(rng.uniform(34,145))) if not bright else (236,250,255,int(rng.uniform(60,220)))
  lines(layers,[(x,y),(x+ln*math.cos(a-.4),y+ln*.3*math.sin(a))],c,width=rng.uniform(.4,1.5))
  if i%7==0:disk(layers,(x,y),rng.uniform(.5,2.0),rng.uniform(.5,2),(*C['light'],int(rng.uniform(80,160))))

def paint_jian(canvas,point,heading,scale=1,alpha=230,seed=0):
 # Actual outlined hilt and double-edged blade, ornamental metallic sections (no UI icon).
 a=heading;fw=(math.cos(a),math.sin(a));normal=(-fw[1],fw[0]);x,y=point
 def loc(u,v):return(x+scale*(fw[0]*u+normal[0]*v),y+scale*(fw[1]*u+normal[1]*v))
 # Pointed, tapered blade; hilt and guard distinctly separate.
 shape(canvas,[loc(-44,-7),loc(41,-7),loc(100,0),loc(41,7),loc(-44,7),loc(-44,-7)],(66,177,235,int(alpha*.76)))
 shape(canvas,[loc(-39,-4),loc(35,-4),loc(100,0),loc(35,0),loc(-39,0)],(208,242,253,int(alpha*.90)))
 shape(canvas,[loc(-40,1),loc(37,1),loc(85,0),loc(38,6),loc(-40,5)],(25,128,232,int(alpha*.72)))
 lines(canvas,[loc(-35,-3),loc(69,-1),loc(96,0)],(249,255,255,int(alpha*.8)),1.6)
 # full crossguard and hilt, wrap, silver-bronze node
 shape(canvas,[loc(-44,-16),loc(-36,-20),loc(-34,20),loc(-44,16),loc(-39,4),loc(-39,-4)],(171,217,238,int(alpha*.9)))
 shape(canvas,[loc(-69,-4),loc(-42,-6),loc(-42,6),loc(-69,4)],(58,114,192,int(alpha*.90)))
 for t in range(4):lines(canvas,[loc(-66+t*5,-4),loc(-63+t*5,4)],(150,231,246,int(alpha*.52)),1.7)
 shape(canvas,[loc(-72,-6),loc(-65,-6),loc(-65,6),loc(-72,6)],(232,246,253,int(alpha*.72)))
 disk(canvas,loc(-39,0),3.6,3.6,(241,255,255,int(alpha*.9)))


def paint_frame(i):
 strong=Image.new('RGBA',(W,H),(0,0,0,0));body=Image.new('RGBA',(W,H),(0,0,0,0));detail=Image.new('RGBA',(W,H),(0,0,0,0));rng=random.Random(8271+i*97)
 stage=['charge','charge','charge','release','gyre','gyre','gyre','gyre','impact','impact','fade','fade'][i]
 cx,cy=256,256
 if i<=2:
  # Asymmetric spiral CLOUD rather than a precise UI magic circle
  arc_range=1.08+i*.24
  p=arc_coords(cx,cy+16,77+i*16,37+i*13,2.7,-.3-arc_range,85,.045,i*.3)
  taper_ribbon(body,p,23+i*5,29+i*7,(48,165,246,168),.17,i+5)
  taper_ribbon(strong,p[10:-5],8+i*1.5,12,(196,238,251,175),.19,i+7)
  for j in range(4+i*2):
   a=2.5+j*.55;rad=25+j*(8+i*2);xx=cx+rad*math.cos(a);yy=cy+rad*.53*math.sin(a)
   pts=arc_coords(xx,yy,13,9,a,a+1.8,26,.12,j*1.2)
   taper_ribbon(body,pts,8,6,(26,125,230,100+i*15),.3,i*47+j)
  paint_jian(detail,(246,255-i*5),-1.5+i*.04,scale=.57+.17*i,alpha=115+i*45,seed=i)
  disk(strong,(252,260),3+i*2,5+i*2,(232,252,255,90+i*38))
  texture_particles(detail,(cx,cy),100,35+i*10,200+i,True)
 elif i in (3,4,5,6,7):
  # Broad sword-gyre across a circle region, not an alleged new gameplay hit.
  g=i-3;angles=[(-2.2,-.45),(-2.2,.55),(-1.7,1.4),(-1.4,2.3),(-.9,3.2)][g]
  path=arc_coords(cx,cy,135+5*g,69+8*g,angles[0],angles[1],104,.065,g*.83)
  # Three distinct painterly layers: irregular translucent material,
  # metal foiled core glint, and attenuated wind stream.
  taper_ribbon(body,path,38+2*g,51+2*g,(18,116,232,139),.22,197+g)
  taper_ribbon(body,path[9:-1],22,33,(71,192,253,126),.28,297+g)
  taper_ribbon(strong,path[14:-1],8.5,16,(208,245,255,184),.13,397+g)
  for j in range(4):
    q=arc_coords(cx-10+j*9,cy+7+j*3,121+j*8,57+j*7,angles[0]+.25+j*.12,angles[1]-.4,75,.07,j+g)
    taper_ribbon(body,q,9+j*1.6,12,(43+j*10,161,240,int(125-j*14)),.4,510+g*10+j)
  # A recognizable sword with hilt at the LEADING tip, not just luminous wind.
  leading=path[-8];p0=path[-18];ang=math.atan2(leading[1]-p0[1],leading[0]-p0[0]);scale=.89+.10*g
  paint_jian(detail,(leading[0]-42*math.cos(ang),leading[1]-42*math.sin(ang)),ang,scale=scale,alpha=185+g*7,seed=g)
  texture_particles(detail,(cx,cy),120,70+8*g,700+i,False)
 elif i in (8,9):
  # Single local burst for a real target contact (not 3 hits).
  burst=(265,247) if i==8 else (277,253)
  for j in range(13):
    a=(j/13)*2*math.pi+(.12 if i==8 else .31);length=rng.uniform(43,99) if i==8 else rng.uniform(28,65)
    out=(burst[0]+math.cos(a)*length,burst[1]+math.sin(a)*length*.81)
    half=(burst[0]+math.cos(a)*length*.46,burst[1]+math.sin(a)*length*.39)
    taper_ribbon(body,[burst,half,out],22 if i==8 else 16,2,(46,153,232,int(rng.uniform(65,148))),.25,1000+i*50+j)
    taper_ribbon(strong,[burst,half,out],8,1,(196,241,253,int(rng.uniform(100,200))),.10,2000+i*50+j)
  disk(strong,burst,23 if i==8 else 13,20 if i==8 else 11,(239,253,255,230 if i==8 else 145))
  disk(body,burst,67 if i==8 else 53,51 if i==8 else 41,(41,162,239,68))
  texture_particles(detail,burst,111,100 if i==8 else 65,3000+i,True)
 else:
  # Scattering fading metal fragments, no lingering debuff sign.
  q=(i-10);theta=1.7+q*.5
  for j in range(12-q*5):
    a=theta+j*.69;rad=35+j*7;pos=(258+rad*math.cos(a),258+rad*.67*math.sin(a));size=18*(1-.36*q)*(1+.3*rng.random())
    shape(body,[(pos[0],pos[1]),(pos[0]+size,pos[1]-3),(pos[0]+size*.45,pos[1]+size*.5)],(56,173,247,int(130-60*q)))
    lines(strong,[pos,(pos[0]+size*.76,pos[1]-2)],(195,242,253,int(140-50*q)),width=1.5)
  texture_particles(detail,(265,250),105,36-q*16,4000+i,False)

 # Painterly Gaussian backlight, core/mid material, fine texture; original alpha kept.
 halo=body.filter(ImageFilter.GaussianBlur(21*S));halo.putalpha(halo.getchannel('A').point(lambda v:int(v*.28)))
 second=strong.filter(ImageFilter.GaussianBlur(6*S));second.putalpha(second.getchannel('A').point(lambda v:int(v*.48)))
 base=Image.new('RGBA',(W,H),(0,0,0,0));base.alpha_composite(halo);base.alpha_composite(body);base.alpha_composite(second);base.alpha_composite(strong);base.alpha_composite(detail)
 # subtle anisotropic brush grain only IN painted alpha, no square boundary
 arr=np.asarray(base).copy(); yv,xv=np.indices((H,W));grain=np.sin(xv*.19+yv*.07+i*.97)*.06+np.sin(yv*.11-xv*.04+i*.42)*.05
 a=arr[:,:,3].astype(float);a=np.clip(a*(1+grain),0,255).astype(np.uint8);arr[:,:,3]=a
 return Image.fromarray(arr,'RGBA').resize((N,N),Image.Resampling.LANCZOS)

images=[paint_frame(i) for i in range(12)]
for i,im in enumerate(images):im.save(OUT/f'sword02_r1_cel_{i+1:02}.png',optimize=True)
atlas=Image.new('RGBA',(N*4,N*3),(0,0,0,0))
for i,im in enumerate(images):atlas.alpha_composite(im,((i%4)*N,(i//4)*N))
atlas.save(OUT/'sword02_human_r1_candidate_atlas.png',optimize=True)
# 1x preview as approx 120px motif over two actual terrain palette samples
board=Image.new('RGB',(1200,960),(22,27,39));bd=ImageDraw.Draw(board)
try:font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',16)
except:font=ImageFont.load_default()
bd.text((18,10),'SWORD02 R1 - ORIGINAL RASTER SOURCE 1x (~120px). NOT GODOT. NOT ART APPROVAL.',font=font,fill=(248,250,250))
for row,bg in enumerate([(22,32,44,255),(218,220,210,255)]):
 for i,im in enumerate(images):
  x=20+(i%6)*196;y=42+row*450+(i//6)*218
  p=Image.new('RGBA',(182,196),bg);sm=im.resize((152,152),Image.Resampling.LANCZOS)
  p.alpha_composite(sm,(15,20));board.paste(p.convert('RGB'),(x,y))
  bd.text((x+8,y+197),f'{i+1:02} '+(['charge']*3+['release']+['gyre']*4+['contact']*2+['fade']*2)[i],font=font,fill=(240,244,247))
board.save(OUT/'sword02_r1_source_1x_dark_light_preview.png')
manifest={"art_status":"G3_SOURCE_CANDIDATE_UNREVIEWED","method":"original layered Pillow raster painting, independent phase-specific silhouettes; NOT ImageGen poster crop","atlas":{"px":[2048,1536],"frame_px":[512,512],"columns":4,"rows":3},"frames":[],"g35":"NOT_EXECUTED","owner":"PENDING","pve":"HOLD"}
for i in range(12):
 b=(OUT/f'sword02_r1_cel_{i+1:02}.png').read_bytes();al=images[i].getchannel('A');manifest['frames'].append({"n":i+1,"sha256":hashlib.sha256(b).hexdigest(),"alpha_minmax":al.getextrema(),"visible_bbox":al.point(lambda x:255 if x>=24 else 0).getbbox()})
manifest['atlas']['sha256']=hashlib.sha256((OUT/'sword02_human_r1_candidate_atlas.png').read_bytes()).hexdigest()
(OUT/'source_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print('generated',OUT, 'atlas',manifest['atlas']['sha256'],'unique',len(set(f['sha256'] for f in manifest['frames'])),'size',[(p.name,p.stat().st_size) for p in OUT.glob('*.png')][-3:])