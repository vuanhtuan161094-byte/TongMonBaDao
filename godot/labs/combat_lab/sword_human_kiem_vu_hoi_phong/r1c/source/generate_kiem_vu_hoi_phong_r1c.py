#!/usr/bin/env python3
"""Kiếm Vũ Hồi Phong / Nhân R1C. Standalone source-art study, never gameplay.
Generates 12 independently painted RGBA cels + atlas + 1x light/dark preflight.
Art-First G3 remains a separate human visual gate.
"""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path
import math, random, json, hashlib

OUT=Path(__file__).resolve().parent; OUT.mkdir(parents=True,exist_ok=True)
S=512; TAU=2*math.pi
PHASE=['charge_01','charge_02','charge_03','release','gyre_01','gyre_02','gyre_03','gyre_04','contact','shock','fade_01','fade_02']
C={'white':(242,253,255),'ice':(178,239,255),'cyan':(57,204,251),'blue':(29,122,222),'deep':(16,63,144),'shadow':(5,30,79)}

def blank():return Image.new('RGBA',(S,S))
def pt(xy):return tuple(round(v) for v in xy)
def path(p0,p1,p2,p3,n=100):
    arr=[]
    for j in range(n+1):
        t=j/n;q=1-t
        arr.append((q**3*p0[0]+3*q*q*t*p1[0]+3*q*t*t*p2[0]+t**3*p3[0],q**3*p0[1]+3*q*q*t*p1[1]+3*q*t*t*p2[1]+t**3*p3[1]))
    return arr

def ribbon(layer, coords, width, rgba, seed=0, blur=0, wobble=1.7):
    """A tapered, split-tip kinetic paint brush; not constant-width Bézier lines."""
    r=random.Random(seed); left=[];right=[]
    for j, (x,y) in enumerate(coords):
        t=j/max(1,len(coords)-1)
        xa,ya=coords[max(0,j-1)]; xb,yb=coords[min(j+1,len(coords)-1)]
        dx=xb-xa; dy=yb-ya; d=max(math.hypot(dx,dy),.001); nx=-dy/d;ny=dx/d
        amp=width*(.03+.97*math.sin(math.pi*t)**.63)*(1+.10*math.sin(t*37+seed*3)+.065*math.sin(t*81+seed))
        amp+=wobble*math.sin(t*57+seed*2)*math.sin(math.pi*t)
        left.append(pt((x+nx*amp,y+ny*amp)));right.append(pt((x-nx*amp,y-ny*amp)))
    ink=blank();ImageDraw.Draw(ink).polygon(left+right[::-1],fill=rgba)
    if blur:ink=ink.filter(ImageFilter.GaussianBlur(blur))
    layer.alpha_composite(ink)

def glow_ellipse(layer, xy, radii, color, peak=170):
    x,y=xy;rx,ry=radii
    for mul,al,blur in [(1.65,.25,13),(1.25,.4,7),(1,.6,3),(.65,1,0)]:
        ink=blank();d=ImageDraw.Draw(ink)
        d.ellipse((x-rx*mul,y-ry*mul,x+rx*mul,y+ry*mul),fill=color+(int(peak*al),))
        layer.alpha_composite(ink.filter(ImageFilter.GaussianBlur(blur)) if blur else ink)

def ring_pos(a,rx=145,ry=85,cy=264):
    # The oblique elliptical orbit is clearly an AoE gyre, NOT 3 homing projectiles.
    return (256+rx*math.cos(a),cy+ry*math.sin(a)-.065*rx*math.cos(a))

def swirl_path(end, span, rx=145,ry=85,n=125):
    return [ring_pos(end-span+span*j/n,rx+4*math.sin(j*.14+end),ry+3*math.sin(j*.10+end)) for j in range(n+1)]

def paint_wind(img,end,span,opacity,seed):
    """Multi-scale scroll of deep shadow, thin translucent vapor, turquoise/white core."""
    p=swirl_path(end,span)
    for width,rgb,al,blur in [(37,C['shadow'],105,13),(31,C['deep'],74,5),(23,C['blue'],95,2.3),(13,C['cyan'],133,1.1),(4,C['ice'],204,0),(1.6,C['white'],210,0)]:
        ribbon(img,p,width,rgb+(int(al*opacity),),seed+round(width),blur)
    rnd=random.Random(seed)
    for j in range(19):
        t=(j+rnd.uniform(-.2,.2))/19
        k=max(1,min(len(p)-2,int(t*(len(p)-1))))
        x,y=p[k];dx=p[k+1][0]-p[k-1][0];dy=p[k+1][1]-p[k-1][1];n=max(1,math.hypot(dx,dy));nx=-dy/n;ny=dx/n
        off=rnd.choice([-1,1])*rnd.uniform(5,24)
        a=(x+nx*off,y+ny*off);c=(x+dx*.15+nx*(off+12),y+dy*.15+ny*(off+12))
        ribbon(img,path(a,(a[0]+nx*19,a[1]+ny*19),(c[0]-dx*.8,c[1]-dy*.8),c,32),rnd.uniform(1,3.5),C['ice']+(round(75*opacity),),seed+j*29)

def facets(img,center,angle,scale):
    """Physical silver jian with beveled steel, fuller, blue facets, visible guard and pommel."""
    ox,oy=center;ca=math.cos(angle);sa=math.sin(angle)
    def tx(u,v):return (round(ox+scale*(u*ca-v*sa)),round(oy+scale*(u*sa+v*ca)))
    def poly(coords,color):ImageDraw.Draw(img).polygon([tx(*p) for p in coords],fill=color)
    def line(coords,color,w=1):ImageDraw.Draw(img).line([tx(*p) for p in coords],fill=color,width=max(1,round(w*scale)),joint='curve')
    # Under-weapon backlight is narrow; sword remains metal rather than an abstract streak.
    broad=blank();d=ImageDraw.Draw(broad)
    d.line([tx(-78,0),tx(136,0)],fill=(35,167,249,170),width=max(2,round(20*scale)))
    img.alpha_composite(broad.filter(ImageFilter.GaussianBlur(10)))
    poly([(-68,-6),(-56,-7),(-56,7),(-68,6)],(23,74,120,255))
    poly([(-62,-9),(-83,-9),(-95,0),(-83,9),(-62,9)],(83,174,224,255))
    poly([(-89,-6),(-95,0),(-89,6)],(229,251,255,255))
    for k in range(5):
        x=-72+k*4.5;line([(x,-7),(x+5,7)],(181,240,255,230),1.5)
    # Guard quillons shape silver, with two cyan gems.
    poly([(-53,-32),(-43,-26),(-39,-11),(-36,-4),(-36,4),(-43,26),(-53,32),(-48,8),(-50,0)],(19,86,161,255))
    line([(-53,-29),(-45,-20),(-39,-3),(-45,20),(-53,29)],(203,249,255,245),2)
    poly([(-43,-8),(-35,-4),(-35,4),(-43,8)],(233,254,255,250))
    # blade (175 source px), engraved bevels with one white cutting edge and deep outline
    poly([(-35,-12),(102,-7),(143,0),(102,7),(-35,12)],(8,48,110,240))
    poly([(-33,-10),(102,-5),(143,0),(-31,0)],(173,226,251,255))
    poly([(-31,0),(143,0),(102,6),(-33,10)],(38,145,229,252))
    poly([(-31,-8),(114,-3),(143,0),(-32,-1)],(246,254,255,250))
    line([(-20,2),(83,2),(122,0)],(201,248,255,240),2)
    line([(-25,6),(70,4),(105,2)],(23,83,155,245),2)
    for j in range(7):
        u=-5+j*15
        line([(u,3),(u+5,4.5*math.sin(j*.8)+3),(u+9,3)],(8,68,134,155),1)

def mote(img,rng,center,n,spread,al):
    d=ImageDraw.Draw(img);x0,y0=center
    for j in range(n):
        a=rng.random()*TAU; rr=math.sqrt(rng.random())
        x=x0+math.cos(a)*rr*spread[0];y=y0+math.sin(a)*rr*spread[1]
        leng=rng.uniform(2,11); w=rng.choice([1,1,2]);t=rng.random()
        rgb=C['white'] if t>.86 else C['cyan'] if t>.3 else C['deep']
        d.line([(x,y),(x+math.cos(a)*leng,y+math.sin(a)*leng)],fill=rgb+(round(al*rng.uniform(.25,.9)),),width=w)
        if j%9==0:d.ellipse((x-2,y-2,x+2,y+2),fill=C['ice']+(round(al*.75),))

def charge(img,i,rng):
    u=(i+1)/3
    center=(256,273);grow=.6+.45*i
    # thick, open 3D wind coil: curved origin + perpendicular mist, bright interior core
    for j in range(2+i):
        off=j*.46+i*.17
        end=2.8+off
        p=swirl_path(end,2.7+u*.8,rx=55+12*i+j*7,ry=28+9*i+j*3)
        ribbon(img,p,8*u,C['shadow']+(round(135*u),),70+i+j,6)
        ribbon(img,p,4*u,C['cyan']+(round(180*u),),77+i+j,1.5)
        ribbon(img,p,1.6,C['white']+(round(185*u),),i+j)
    for j in range(6+i*3):
        a=j*TAU/(6+i*3)+i*.21
        p=path((256+math.cos(a)*85,306+math.sin(a)*45),(248+math.sin(a)*24,300),(260+math.cos(a)*18,237),(257,240),45)
        ribbon(img,p,2+u*3,C['blue']+(round(75+75*u),),i*90+j,1)
    glow_ellipse(img,(256,253),(13+9*i,24+13*i),C['blue'],round(85+45*u))
    glow_ellipse(img,(256,258),(5+3*i,12+7*i),C['ice'],round(85+65*u))
    facets(img,(257,266-i*5),-math.pi/2+i*.065,.55+.14*i)
    mote(img,rng,center,24+i*12,(88+25*i,67+21*i),round(110+50*u))

def impact(img,rng,strong,shock=False):
    c=(326,252)
    # radial wound and rippling circular AoE, NOT three independent impact puffs
    for j in range(19 if strong else 13):
        a=j*TAU/(19 if strong else 13)+rng.uniform(-.23,.23)
        l=rng.uniform(38,113)*(strong if isinstance(strong,float) else 1)
        perp=(-math.sin(a),math.cos(a));rad=rng.uniform(2,9)
        p0=(c[0]+rng.uniform(-16,16),c[1]+rng.uniform(-16,16))
        tip=(p0[0]+math.cos(a)*l,p0[1]+math.sin(a)*l)
        ink=blank();d=ImageDraw.Draw(ink)
        d.polygon([pt((p0[0]+perp[0]*rad,p0[1]+perp[1]*rad)),pt(tip),pt((p0[0]-perp[0]*rad,p0[1]-perp[1]*rad))],fill=rng.choice([C['blue'],C['cyan'],C['ice']])+(rng.randint(125,220),))
        img.alpha_composite(ink)
    if shock:
        paint_wind(img,6.0,TAU*1.15,.45,141)
        mote(img,rng,c,84,(178,116),195)
    glow_ellipse(img,c,(29+9*shock,29+8*shock),C['blue'],200)
    glow_ellipse(img,c,(13+3*shock,17+3*shock),C['cyan'],240)
    glow_ellipse(img,c,(5,9),C['white'],240)

def render(i):
    rng=random.Random(27093+i*7717);im=blank()
    if i<=2:charge(im,i,rng)
    elif i<=7:
        k=i-3;a=2.65+k*.80
        paint_wind(im,a,1.6+k*.35,1 if k<4 else .97,610+i)
        if k>0:paint_wind(im,a-1.7,.72,.5,730+i)
        # Distinct leading blade passes around the orbit; angle is tangent, never reversed.
        px,py=ring_pos(a);an=math.atan2(85*math.cos(a)-.065*145*(-math.sin(a)),-145*math.sin(a))
        facets(im,(px,py),an,.73+.04*k)
        mote(im,rng,(256,263),28+6*k,(162,101),170)
        if k>=3:glow_ellipse(im,(256,265),(83,22),C['blue'],50)
    elif i==8:
        paint_wind(im,5.85,3.65,.92,820)
        facets(im,(325,249),-.50,.80)
        impact(im,rng,1.0)
        mote(im,rng,(313,248),53,(147,96),204)
    elif i==9:impact(im,rng,.81,True)
    elif i==10:
        paint_wind(im,6.4,2.1,.48,956)
        mote(im,rng,(303,248),43,(152,93),102)
    else:
        paint_wind(im,6.7,1.1,.22,957)
        mote(im,rng,(297,248),22,(126,79),65)
    return im

from enhance_r1c_artfirst_v4 import enhance
frames=[enhance(render(i), i) for i in range(12)]
for i,im in enumerate(frames):im.save(OUT/f'kiem_vu_hoi_phong_r1c_pose_{i+1:02}_{PHASE[i]}.png')
atlas=Image.new('RGBA',(S*4,S*3))
for i,im in enumerate(frames):atlas.alpha_composite(im,(S*(i%4),S*(i//4)))
atlas.save(OUT/'kiem_vu_hoi_phong_r1c_atlas_rgba.png')

# Standard 1x footprint exactly 174x174, same dark/light backgrounds, no false runtime claims.
TW,TH=208,194;pre=Image.new('RGB',(TW*4,TH*6+90),(24,34,49));draw=ImageDraw.Draw(pre)
for r,bg in enumerate(((24,34,49),(219,223,214))):
    yoff=45+r*TH*3
    for i,im in enumerate(frames):
        x=(i%4)*TW;y=yoff+(i//4)*TH
        tile=Image.new('RGBA',(TW-8,TH-3),bg+(255,))
        tile.alpha_composite(im.resize((174,174),Image.Resampling.LANCZOS),((TW-8-174)//2,0))
        pre.paste(tile.convert('RGB'),(x+3,y))
        draw.text((x+7,y+175),f'{i+1:02d} {PHASE[i]}',fill=(230,243,255) if r==0 else (10,31,58))
draw.text((7,17),'SOURCE-ONLY 1x PREVIEW: DARK & LIGHT / NOT GODOT / NOT G3 PASS',fill=(237,247,255))
pre.save(OUT/'G3_preflight_1x_dark_light.png')
files={p.name:{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in sorted(OUT.glob('*.png'))}
from PIL import ImageStat
checks=[]
for i,im in enumerate(frames):
    a=im.getchannel('A');bb=a.getbbox();arr=list(a.get_flattened_data() if hasattr(a,'get_flattened_data') else a.getdata());border=8
    if bb:
        safe=bb[0]>=border and bb[1]>=border and bb[2]<=S-border and bb[3]<=S-border
    else:safe=False
    checks.append({'frame':i+1,'phase':PHASE[i],'alpha_nonzero_pixels':sum(v>8 for v in arr),'bbox':bb,'safe_8px_border':safe})
sha_list=[files[f'kiem_vu_hoi_phong_r1c_pose_{i+1:02}_{PHASE[i]}.png']['sha256'] for i in range(12)]
metadata={'schema':'tmb.vfx.r1c.source.v1','revision':'R1C','canonical':{'skill_id':'tmb.skill.sword.ngu_kiem.active_02.human','element':'metal','effect':'damage','shape':'circle','radius':1.4,'target_limit':3,'cast_time':0.36,'cooldown':10,'projectile_speed':8,'damage_ratio':0.82},'source':'first-party procedural source-art R1C-A with deterministic painterly volume postprocess, NOT ImageGen master, NOT owner approved','pose_count':12,'cell_px':[512,512],'atlas_px':[2048,1536],'1x_scale_px':174,'phases':PHASE,'checks':checks,'all_pose_distinct':len(set(sha_list))==12,'files':files,'gates':{'G0':'CANONICAL_CONFIRMED','G3':'ART_VISUAL_REVIEW_PENDING','G35_G7':'NOT_EXECUTED','owner':'PENDING','pve':'HOLD'},'scope':{'no_rig':True,'no_codex_cloud':True,'no_merge':True,'no_pve':True,'no_gameplay_writes':True}}
(OUT/'R1C_SOURCE_MANIFEST.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'pose_count':12,'unique':metadata['all_pose_distinct'],'alpha':all(x['alpha_nonzero_pixels']>0 for x in checks),'border':all(x['safe_8px_border'] for x in checks),'total_kb':sum(v['bytes'] for v in files.values())//1024,'checks':checks},ensure_ascii=False))
