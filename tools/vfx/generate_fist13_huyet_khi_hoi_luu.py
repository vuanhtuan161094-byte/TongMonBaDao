#!/usr/bin/env python3
"""FIST13 R2 original reproducible code-painted soft RGBA energy; NOT hand/ImageGen painting."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random, hashlib, json
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/fist13/assets/generated"
OUT.mkdir(parents=True,exist_ok=True)
CELL=320; S=2; N=CELL*S
STROKES={'contact':[
 ((54,192),(130,255),(180,169),(160,160)),
 ((265,101),(206,64),(188,131),(160,160)),
 ((139,41),(71,83),(162,120),(160,160))]}
def bezier(p0,p1,p2,p3,u):
    a=(1-u)**3;b=3*u*(1-u)**2;c=3*u*u*(1-u);d=u**3
    return (p0[0]*a+p1[0]*b+p2[0]*c+p3[0]*d,p0[1]*a+p1[1]*b+p2[1]*c+p3[1]*d)
def ribbon(layers,p0,p1,p2,p3,t,seed,scale=1):
    rng=random.Random(seed)
    sway=math.sin(2.7*t+seed)*7
    p1=(p1[0]+sway,p1[1]-sway*.4);p2=(p2[0]-sway*.36,p2[1]+sway*.3)
    end=.50+.50*t
    pts=[bezier(p0,p1,p2,p3,j/38*end) for j in range(39)]
    for layer,color,mult in layers:
        d=ImageDraw.Draw(layer,'RGBA')
        for j in range(38):
            u=j/38
            width=scale*mult*(2.5+14.5*(math.sin(u*math.pi)**.7))*(.7+.3*math.sin((u+.15)*math.pi))
            if t<.08:width*=.8
            xy=[(int(q[0]*S),int(q[1]*S)) for q in pts[j:j+2]]
            d.line(xy,fill=color,width=max(1,int(width*S)),joint='curve')
            if j in (6,13,19,25,32):
                x,y=pts[j];rad=width*S*.5
                d.ellipse((int(x*S-rad),int(y*S-rad),int(x*S+rad),int(y*S+rad)),fill=color)
    f=ImageDraw.Draw(layers[1][0],'RGBA')
    for j in range(37):
        u=rng.random()*.97;x,y=bezier(p0,p1,p2,p3,u)
        size=rng.uniform(.6,1.9)*S
        x+=rng.gauss(0,8);y+=rng.gauss(0,7)
        f.ellipse((int(x*S-size),int(y*S-size),int(x*S+size),int(y*S+size)),fill=(255,91,134,rng.randint(36,130)))
def frame(kind,idx,total):
    t=idx/(total-1)
    halo=Image.new('RGBA',(N,N));body=Image.new('RGBA',(N,N))
    inner=Image.new('RGBA',(N,N));hot=Image.new('RGBA',(N,N))
    if kind=='contact':
        for k,points in enumerate(STROKES['contact']):
            ribbon([(halo,(120,0,42,65),2.2),(body,(190,19,63,190),1.05),(inner,(254,75,127,190),.46),(hot,(255,232,211,180),.11)],*points,t,1231+idx*11+k*103,scale=.9)
        d=ImageDraw.Draw(inner,'RGBA');e=ImageDraw.Draw(hot,'RGBA')
        on=max(0,(t-.25)/.75)
        d.ellipse((int((160-12*on)*S),int((160-12*on)*S),int((160+12*on)*S),int((160+12*on)*S)),fill=(249,50,93,int(220*on)))
        e.ellipse((int((160-4*on)*S),int((160-4*on)*S),int((160+4*on)*S),int((160+4*on)*S)),fill=(255,247,223,int(235*on)))
    elif kind=='charge':
        for k in range(4):
            a=k*math.tau/4+.5*t;reach=62-30*t
            p0=(160+math.cos(a)*reach,160+math.sin(a)*reach*.78)
            p1=(160+math.cos(a+1.0)*reach,160+math.sin(a+1.0)*reach*.83)
            p2=(160+math.cos(a-1.1)*reach*.75,160+math.sin(a-1.1)*reach*.66)
            p3=(160,160)
            ribbon([(halo,(95,8,52,47),1.5),(body,(198,25,80,140),.8),(inner,(255,72,112,170),.33),(hot,(255,210,211,185),.08)],p0,p1,p2,p3,.47+.53*t,199+k*17+idx*37,scale=.7)
    else:
        for k in range(4):
            a=(k+.2)*math.tau/4+t*.09;dist=43+3*math.sin(t*math.tau+k)
            p0=(160+math.cos(a)*dist,160+math.sin(a)*dist*.65)
            p1=(160+math.cos(a+.7)*dist*.86,160+math.sin(a+.7)*dist*.68)
            p2=(160+math.cos(a-.65)*dist*.4,160+math.sin(a-.65)*dist*.4)
            p3=(160,160)
            ribbon([(halo,(92,0,47,39),1.5),(body,(177,17,60,124),.72),(inner,(255,62,111,142),.3),(hot,(255,180,182,160),.085)],p0,p1,p2,p3,.85,899+k*35+idx*31,scale=.60)
        d=ImageDraw.Draw(hot,'RGBA');amp=.82+.15*math.sin(t*math.tau)
        pts=[(150,148),(166,157),(153,169),(173,178)]
        d.line([(int(x*S),int(y*S)) for x,y in pts],fill=(255,202,201,int(210*amp)),width=3*S,joint='curve')
    cloud=halo.filter(ImageFilter.GaussianBlur(13*S))
    surround=body.filter(ImageFilter.GaussianBlur(4*S))
    image=Image.alpha_composite(cloud,halo)
    for layer in (surround,body,inner,hot):image=Image.alpha_composite(image,layer)
    return image.resize((CELL,CELL),Image.Resampling.LANCZOS)
stats={}
for name,total in (('charge',8),('contact',12),('mark',8)):
    sheet=Image.new('RGBA',(CELL*4,CELL*((total+3)//4)))
    keys=[]
    for i in range(total):
        tile=frame(name,i,total)
        alpha=tile.getchannel('A')
        assert alpha.getextrema()[0]==0 and alpha.getextrema()[1]>180
        assert sum(v>36 for v in alpha.getdata())>300
        sheet.alpha_composite(tile,((i%4)*CELL,(i//4)*CELL))
        keys.append(hashlib.sha256(tile.tobytes()).hexdigest())
    assert len(set(keys))==total
    path=OUT/('f13_'+name+'.png')
    sheet.save(path,optimize=True)
    stats[name]={'frames':total,'size':list(sheet.size),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
frame('contact',8,12).save(OUT/'f13_original_code_painted_hero.png',optimize=True)
(OUT/'f13_art_source_manifest.json').write_text(json.dumps({'art_source':'code','method':'first-party Pillow layered volumetric alpha energy','master':'f13_original_code_painted_hero.png','generator':'tools/vfx/generate_fist13_huyet_khi_hoi_luu.py','no_gif':True,'no_rig':True,'layers':stats},indent=2),encoding='utf-8')
print('FIST13_R2_BAKE_PASS frames=28 pages=3 code_art=true no_gif=true no_rig=true')
