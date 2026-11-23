#!/usr/bin/env python3
"""First-party raster-painted preliminary Human Sword02 VFX source, not a Godot test.
12 genuinely separately-rendered poses; one sword dancing through a continuous area gyre.
"""
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance
import numpy as np, math, random, hashlib, json, os, zipfile
from pathlib import Path

OUT=Path('/mnt/data/TMB_SWORD02_KIEM_VU_HOI_PHONG_R1')
OUT.mkdir(parents=True,exist_ok=True)
S=512; SS=2; N=S*SS; TAU=2*math.pi
PALETTE={'core':(248,254,255),'silver':(190,228,250),'blue':(30,151,244),'deep':(12,59,159)}
PHASES=['charge_01','charge_02','charge_03','release','gyre_01','gyre_02','gyre_03','gyre_04','contact','shards','fade_01','fade_02']

def rnd_for(i):return random.Random(390128+i*1709)
def scaled(pt):return (int(pt[0]*SS),int(pt[1]*SS))
def draw_on_layer(fn):
    x=Image.new('RGBA',(N,N));d=ImageDraw.Draw(x,'RGBA');fn(d);return x

def poly_fill(d,coords,c):d.polygon([scaled(p) for p in coords], fill=c)
def line(d,pts,fill,w=2,joint='curve'):
    d.line([scaled(p) for p in pts],fill=fill,width=max(1,int(w*SS)),joint=joint)

def bezier(p0,p1,p2,p3,points=120):
    arr=[]
    for k in range(points+1):
        u=k/points;v=1-u
        arr.append((v*v*v*p0[0]+3*v*v*u*p1[0]+3*v*u*u*p2[0]+u*u*u*p3[0], v*v*v*p0[1]+3*v*v*u*p1[1]+3*v*u*u*p2[1]+u*u*u*p3[1]))
    return arr

def painterly_ribbon(points, width, col, opacity, seed, taper=True):
    rnd=random.Random(seed)
    left=[];right=[]
    for i,p in enumerate(points):
        k=i/max(1,len(points)-1)
        bef=points[max(0,i-1)];aft=points[min(len(points)-1,i+1)]
        dx=aft[0]-bef[0];dy=aft[1]-bef[1];mag=max(1, math.hypot(dx,dy))
        nx=-dy/mag; ny=dx/mag
        profile=(0.1+0.9*math.sin(math.pi*k)**0.65) if taper else 0.8+0.15*math.sin(k*TAU)
        w=width*profile*(0.88+0.16*math.sin(17*k+seed)+0.09*math.sin(39*k+seed*.3))
        jitter=0.85*math.sin(k*63.0+seed)*math.sin(math.pi*k)
        left.append((p[0]+nx*(w+jitter),p[1]+ny*(w+jitter)))
        right.append((p[0]-nx*(w+jitter),p[1]-ny*(w+jitter)))
    main=draw_on_layer(lambda d:poly_fill(d,left+list(reversed(right)),col+(opacity,)))
    # painted split filaments break uniform ring geometry
    fibers=Image.new('RGBA',(N,N));d=ImageDraw.Draw(fibers,'RGBA')
    for j in range(13):
        a=rnd.random()*.8; b=min(1,a+0.08+rnd.random()*.15)
        fpts=[]
        for k in np.linspace(a,b,19):
            idx=min(len(points)-1,int(k*(len(points)-1)));x,y=points[idx]
            prev=points[max(idx-1,0)]; nxt=points[min(idx+1,len(points)-1)]
            dx=nxt[0]-prev[0];dy=nxt[1]-prev[1];m=max(1,math.hypot(dx,dy))
            shift=(rnd.random()-.5)*width*2.3
            fpts.append((x+dy/m*shift,y-dx/m*shift))
        line(d,fpts,(155+int(rnd.random()*90),220,255, 30+int(rnd.random()*70)),0.7+rnd.random()*1.2)
    return Image.alpha_composite(main,fibers)

def elliptical(t,rx=143,ry=82, center=(255,259),angle=-.17):
    x=rx*math.cos(t); y=ry*math.sin(t)
    a=angle;return (center[0]+x*math.cos(a)-y*math.sin(a),center[1]+x*math.sin(a)+y*math.cos(a))

def gyre_trail(end_angle, length, seed, strength=1):
    out=Image.new('RGBA',(N,N));
    variants=[(0,53,(39,139,225),105),(0,29,(27,169,249),139),(0,10,(117,230,255),212),(0,2.7,(240,255,255),225)]
    for layer,(offset,width,rgb,alpha) in enumerate(variants):
        points=[elliptical(end_angle-length+(length*k/155)+offset*0.0003,
                           146+2.4*math.sin(k*.26+seed),82+3*math.sin(k*.11+seed*.1)) for k in range(156)]
        energy=painterly_ribbon(points,width*strength,rgb,int(alpha*strength),seed+layer*37)
        if layer in (0,1):energy=energy.filter(ImageFilter.GaussianBlur(11*SS if layer==0 else 3*SS))
        out=Image.alpha_composite(out,energy)
    return out

def energy_flame(center, angle, scale, seed, strength=1):
    # layered turbulent flame feathers follows actual motion, no generic neon curves
    rnd=random.Random(seed)
    out=Image.new('RGBA',(N,N))
    for j in range(9):
        length=rnd.uniform(55,140)*scale
        bend=rnd.uniform(-45,40)*scale
        rear=(center[0]-math.cos(angle)*length,center[1]-math.sin(angle)*length)
        side=(-math.sin(angle),math.cos(angle))
        start=(center[0]+side[0]*rnd.uniform(-10,10)*scale,center[1]+side[1]*rnd.uniform(-10,10)*scale)
        path=bezier(start,(rear[0]+side[0]*bend,rear[1]+side[1]*bend),
                  (rear[0]+side[0]*bend*.8,rear[1]+side[1]*bend*.8),rear,65)
        w=rnd.uniform(2,15)*scale
        rgb=rnd.choice([(15,91,205),(31,164,231),(107,217,255),(214,252,255)])
        a=int(rnd.randint(40,90)*strength)
        if a<=0:continue
        energy=painterly_ribbon(path,w,rgb,a,seed*40+j)
        if j<3:energy=energy.filter(ImageFilter.GaussianBlur(2.8*SS))
        out=Image.alpha_composite(out,energy)
    return out

def sword_art(angle,center,scale,seed,bright=1.0):
    rnd=random.Random(seed)
    # Master silver metal blade with authored engraved facets, crossguard, hilt, bevels
    w=h=384;cx=190;cy=195
    plane=Image.new('RGBA',(w*SS,h*SS));d=ImageDraw.Draw(plane,'RGBA')
    def coords(points):return [scaled(p) for p in points]
    def p(points,col):d.polygon(coords(points),fill=col)
    def l(points,col,width=1):d.line(coords(points),fill=col,width=max(1,int(width*SS)),joint='curve')
    # blade points from left base to right narrow tip
    length=170*scale; start=122; tip=start+length
    blade_hw=11*scale
    # offset local shape around 195
    shaft=[(start,cy-blade_hw),(tip-30*scale,cy-6*scale),(tip,cy),
           (tip-30*scale,cy+5.7*scale),(start,cy+blade_hw)]
    # glow shadow only, irregular aura confined to blade
    m=draw_on_layer(lambda dd:dd.polygon(coords(shaft),fill=(33,160,246,int(155*bright))))
    glow=m.filter(ImageFilter.GaussianBlur(11*SS))
    plane.alpha_composite(glow)
    d=ImageDraw.Draw(plane,'RGBA')
    p(shaft,(69,168,220,int(242*bright)))
    p([(start,cy-blade_hw+1),(tip-35*scale,cy-4*scale),(tip,cy),(start,cy)],(211,243,254,int(242*bright)))
    p([(start,cy),(tip,cy),(tip-36*scale,cy+4*scale),(start,cy+blade_hw-1)],(26,111,197,int(247*bright)))
    p([(start+8,cy-3),(tip-23*scale,cy-.8),(tip,cy),(start+10,cy+.6)],(248,255,255,int(245*bright)))
    l([(start+7,cy+7),(tip-27*scale,cy+2)],(85,225,255,int(200*bright)),.85)
    # etched vein along blade has authored zigzag + silver highlights
    for k in range(6):
        xx=start+18+k*19*scale
        l([(xx,cy+3),(xx+11*scale,cy+3+2.5*math.sin(k+.6)),(xx+16*scale,cy+5)],(3,61,129,165),1)
    # fuller near hilt
    p([(start+2,cy-4),(start+39*scale,cy-2),(start+53*scale,cy-.7),(start+7,cy)],(5,72,140,125))
    # metal guard arched upper and lower quillons, detailed silver edge
    G=start-5
    p([(G-8,cy-25*scale),(G+1,cy-19*scale),(G+4,cy-2),(G-8,cy+2),
       (G-13,cy-4)],(24,86,139,250))
    p([(G-8,cy+25*scale),(G+1,cy+19*scale),(G+4,cy+2),(G-8,cy-2),
       (G-13,cy+4)],(29,103,154,250))
    l([(G-6,cy-23*scale),(G-5,cy-9*scale),(G,cy)],(199,245,255,220),2)
    l([(G-6,cy+23*scale),(G-5,cy+9*scale),(G,cy)],(194,235,255,200),2)
    # hilt grip wrapped with blue-white leather
    p([(G-13,cy-6),(G-70*scale,cy-7*scale),(G-76*scale,cy),(G-69*scale,cy+7*scale),(G-13,cy+5)],(22,75,137,245))
    for k in range(5):
        x=G-24*scale-k*8.5*scale
        l([(x,cy-6*scale),(x-3.2*scale,cy+6*scale)],(175,221,242,230),1.8*scale)
    # ornate pommel
    p([(G-73*scale,cy-8*scale),(G-89*scale,cy-6*scale),(G-97*scale,cy),
       (G-88*scale,cy+7*scale),(G-73*scale,cy+8*scale)],(98,187,225,245))
    p([(G-83*scale,cy-6*scale),(G-91*scale,cy),(G-83*scale,cy+5*scale)],(223,254,255,245))
    # sword glow and small rising wind filaments are composited separately at location
    rotated=plane.rotate(-math.degrees(angle),resample=Image.Resampling.BICUBIC,expand=False,center=(cx*SS,cy*SS))
    # sword pivot at (cx,cy); composite center
    result=Image.new('RGBA',(N,N))
    loc=(int((center[0]-cx)*SS),int((center[1]-cy)*SS))
    result.alpha_composite(rotated,loc)
    return result

def flecks(i,count,center,spread=(60,60),alpha=165,seed=0):
    rnd=random.Random(seed+331*i)
    layer=Image.new('RGBA',(N,N));d=ImageDraw.Draw(layer,'RGBA')
    for j in range(count):
        angle=rnd.uniform(-TAU,TAU)
        x=center[0]+math.cos(angle)*rnd.random()*spread[0]
        y=center[1]+math.sin(angle)*rnd.random()*spread[1]
        ln=rnd.uniform(2,10)
        vx=math.cos(angle)*ln;vy=math.sin(angle)*ln*.7
        line(d,[(x-vx*.3,y-vy*.3),(x+vx,y+vy)],(183+int(rnd.random()*70),230+int(rnd.random()*25),255,int(alpha*rnd.uniform(.23,.9))),rnd.uniform(.6,1.7))
        if j%7==0:
            line(d,[(x,y-2),(x,y+2)],(240,255,255,int(alpha*.57)),1)
    return layer

def impact_at(center,charge,seed):
    rnd=random.Random(seed)
    result=Image.new('RGBA',(N,N))
    # fractured spiky impact not generic star: irregular blade fragments
    for k in range(15):
        a=k*TAU/15+rnd.uniform(-.18,.18)
        length=rnd.uniform(22,74)*charge
        w=rnd.uniform(1.5,7)*charge
        px=center[0]+rnd.uniform(-9,9);py=center[1]+rnd.uniform(-9,9)
        dx=math.cos(a);dy=math.sin(a)
        coords=[(px-dy*w,py+dx*w),(px+dx*length,py+dy*length),(px+dy*w*.3,py-dx*w*.3)]
        rgb=rnd.choice([(220,251,255),(105,218,255),(15,123,244)])
        temp=draw_on_layer(lambda d:poly_fill(d,coords,rgb+(int(rnd.randint(100,221)*charge),)))
        if k%3==0:
            result=Image.alpha_composite(result,temp.filter(ImageFilter.GaussianBlur(2*SS)))
        result=Image.alpha_composite(result,temp)
    hotspot=Image.new('RGBA',(N,N));d=ImageDraw.Draw(hotspot,'RGBA')
    x,y=scaled(center)
    for rad,rgb,a in [(38,(7,110,244),110),(22,(49,195,251),160),(10,(215,252,255),230),(4,(255,255,255),250)]:
        d.ellipse((x-rad*SS,y-rad*SS,x+rad*SS,y+rad*SS),fill=rgb+(int(a*charge),))
    result=Image.alpha_composite(result,hotspot.filter(ImageFilter.GaussianBlur(5*SS)))
    return result

def frame(i):
    rnd=rnd_for(i)
    main=Image.new('RGBA',(N,N))
    # draw tailored visibly different poses rather than crop/reposition one image
    if i<3:
        u=(i+1)/3
        # curved wind silk charges at the sword-hand, not an identical donut icon
        for k in range(4+i*2):
            phase=(i*.3+k*.53)
            x0=225+rnd.uniform(-37,40); y0=322+rnd.uniform(-20,25)
            x1=243+rnd.uniform(-75,73); y1=287-rnd.uniform(20,95)*u
            path=bezier((x0,y0),(x0+49*math.sin(phase),y0-60*u),(x1-42*math.cos(phase),y1+37),(x1,y1))
            col=rnd.choice([(37,129,225),(64,185,241),(157,233,251)])
            main=Image.alpha_composite(main,painterly_ribbon(path,2.4+2.4*u,col,int(70+75*u),i*187+k))
        # short forming sword with distinct growing silhouette
        sword=sword_art(-math.pi/2+(2-i)*.05,(248+i*6,298-i*10),.40+.13*i,112+i, .68+.12*i)
        main=Image.alpha_composite(main,sword)
        main=Image.alpha_composite(main,energy_flame((252,302-i*9),math.pi/2,.55,i*31+7,.7))
        main=Image.alpha_composite(main,flecks(i,16+i*7,(248,280),(48,80),int(80+45*u),90))
    elif 3<=i<=7:
        k=i-3
        angle=2.55+k*.78
        length=1.2+k*.40
        main=Image.alpha_composite(main,gyre_trail(angle,length,100+i*3,.95+.06*k))
        p=elliptical(angle,rx=143,ry=82)
        # sword tangent is visible; curled afterimage is subordinated to a physical blade
        tangent=math.atan2(82*math.cos(angle),-143*math.sin(angle))-.17
        if k==0:p=(p[0]-18,p[1]+18)
        main=Image.alpha_composite(main,energy_flame(p,tangent, .77+0.04*k,410+i, .8))
        main=Image.alpha_composite(main,sword_art(tangent,p,.68+0.05*k,221+i,1.0))
        main=Image.alpha_composite(main,flecks(i,29+i*2, (255,260),(165,96),190,390))
        # leading-edge crystalline wind spur (not another sword/hit)
        if k>=2:
            w=bezier((p[0]-44,p[1]+35),(p[0]-67,p[1]+22),(p[0]-29,p[1]+2),(p[0]+15,p[1]-12))
            main=Image.alpha_composite(main,painterly_ribbon(w,4,(154,231,255),120,440+k))
    elif i==8:
        main=Image.alpha_composite(main,gyre_trail(5.6,2.7,512,.87))
        main=Image.alpha_composite(main,energy_flame((324,250),-.65,0.8,851))
        main=Image.alpha_composite(main,sword_art(-.65,(329,252),.67,92,1.0))
        main=Image.alpha_composite(main,impact_at((350,255),1,513))
        main=Image.alpha_composite(main,flecks(i,38,(350,255),(110,100),200,994))
    elif i==9:
        main=Image.alpha_composite(main,impact_at((347,253),.83,739))
        main=Image.alpha_composite(main,flecks(i,74,(348,260),(134,121),200,845))
        p=bezier((165,319),(244,375),(338,198),(394,210))
        main=Image.alpha_composite(main,painterly_ribbon(p,7,(31,148,241),130,998))
    elif i==10:
        main=Image.alpha_composite(main,gyre_trail(6.2,1.3,735,.48))
        main=Image.alpha_composite(main,flecks(i,36,(307,263),(132,98),100,377))
    else:
        main=Image.alpha_composite(main,flecks(i,25,(301,254),(118,79),70,818))
        for k in range(4):
            t=1.9+k*.34
            p=bezier((255,265),(218+20*k,238),(300-40*k,228),(308+28*k,208+7*k))
            main=Image.alpha_composite(main,painterly_ribbon(p,1.2,(65,169,238),30,981+k))
    # subtly granular pigment/alpha modulation to avoid flat vector appearance
    a=np.array(main,dtype=np.uint8)
    rng=np.random.default_rng(880+i*177)
    mask=a[:,:,3]>0
    noise=rng.normal(0,5.5,mask.shape)
    for ch in range(3):a[:,:,ch]=np.clip(a[:,:,ch].astype(float)+noise*.6,0,255).astype('uint8')
    # naturally eroded alpha edges (keep outlines and art core)
    a[:,:,3]=np.clip(a[:,:,3].astype(float)*(0.97+0.05*np.sin(np.linspace(0,48,N))[None,:]),0,255).astype('uint8')
    return Image.fromarray(a,'RGBA').resize((S,S),Image.Resampling.LANCZOS)

frames=[]
for i,phase in enumerate(PHASES):
    img=frame(i);frames.append(img)
    img.save(OUT/f'ki em vu'.replace(' ','')+'_dummy.png') if False else None
    img.save(OUT/f'kiem_vu_hoi_phong_r1_pose_{i+1:02d}_{phase}.png',optimize=True)

atlas=Image.new('RGBA',(S*4,S*3))
for i,im in enumerate(frames):atlas.alpha_composite(im,((i%4)*S,(i//4)*S))
atlas.save(OUT/'kiem_vu_hoi_phong_r1_atlas_rgba.png',optimize=True)
# Contact sheet with a clear 1x preview (art source review only)
CS_W=1420;CS_H=1500
contact=Image.new('RGB',(CS_W,CS_H),(27,35,49))
d=ImageDraw.Draw(contact)
for row,bg in enumerate([(23,32,45),(210,214,206)]):
    ybase=45+row*725
    d.text((20,ybase-28),('1× SOURCE / DARK' if row==0 else '1× SOURCE / LIGHT')+' - No Godot, no gameplay, no QA verdict',fill=(243,243,243) if row==0 else (255,255,255))
    for i,im in enumerate(frames):
        # 1x source composited at intended game size (0.32*512=164 screen pixels)
        col=i%4;sub=i//4
        x=20+col*350;y=ybase+sub*220
        tile=Image.new('RGBA',(330,198),bg+(255,))
        view=im.resize((174,174),Image.Resampling.LANCZOS)
        tile.alpha_composite(view,(78,12))
        contact.paste(tile.convert('RGB'),(x,y))
        d.text((x+7,y+181),f'{i+1:02d} {PHASES[i]}',fill=(240,244,250) if row==0 else (12,38,54))
contact.save(OUT/'G3_preflight_1x_dark_light.png')
# Include a transparent master plate of all poses, by construction also atlas.
meta={"skill":"tmb.skill.sword.ngu_kiem.active_02.human","art_revision":"R1_SOURCE_CANDIDATE","pose_count":12,"cell_px":[512,512],"atlas_px":[2048,1536],"source_technique":"first-party layered painted raster: independent per-phase alpha illustration with faceted jian, wind silk and local contact; no commercial sprite","phase_names":PHASES,"files":{}}
for p in sorted(OUT.glob('*.png')):
    data=p.read_bytes();meta['files'][p.name]={"sha256":hashlib.sha256(data).hexdigest(),"bytes":len(data)}
meta['all_pose_distinct']=len({meta['files'][p.name]['sha256'] for p in OUT.glob('kiem_vu_hoi_phong_r1_pose_*.png')})==12
(OUT/'source_manifest.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2)+'\n')
with zipfile.ZipFile('/mnt/data/TMB_SWORD02_KIEM_VU_HOI_PHONG_R1_SOURCE.zip','w',compression=zipfile.ZIP_DEFLATED) as z:
    for p in sorted(OUT.iterdir()):z.write(p,arcname=p.name)
print(json.dumps({'output':str(OUT),'atlas_sha':meta['files']['kiem_vu_hoi_phong_r1_atlas_rgba.png']['sha256'],'atlas_size':meta['files']['kiem_vu_hoi_phong_r1_atlas_rgba.png']['bytes'],'poses':len(frames),'all_distinct':meta['all_pose_distinct']},indent=2))
