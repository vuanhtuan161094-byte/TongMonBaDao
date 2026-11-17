#!/usr/bin/env python3
"""PAF06 original source: independent painted wind-energy alpha flipbooks.
PASSIVE ALWAYS ON: no strike/cast/proc/mark. First-party hand-code-paint RGBAs.
Morph individual feather HEAD/TAIL and internal light; never UV-warp a still.
"""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math,hashlib,json,random
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'godot/labs/combat_lab/talisman16'
ASSETS=BASE/'assets'; SOURCE=BASE/'art_sources'
ASSETS.mkdir(parents=True,exist_ok=True);SOURCE.mkdir(parents=True,exist_ok=True)
CELL=320; SS=3; EXT=CELL*SS; POSES=24; TAU=math.tau
def new(): return Image.new('RGBA',(EXT,EXT))
def cub(a,b,c,d,n=76):
    o=[]
    for k in range(n):
        t=k/(n-1);u=1-t
        o.append((u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t*t*t*d[0],
                  u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t*t*t*d[1]))
    return o
def paint_wind(dst,points,phase,width,seed):
    drift=math.sin(TAU*phase+seed*.47)
    a,b,c,d=points
    path=cub((a[0]+drift*1.3,a[1]),(b[0]-drift*4.1,b[1]+drift*4),
             (c[0]+drift*5,c[1]-drift*3),(d[0]+drift*6.7,d[1]-drift*6))
    growth=.77+.18*math.sin(TAU*phase+seed*.21)
    path=path[5:max(20,int(len(path)*growth))]
    upper=[];lower=[]
    for i,(x,y) in enumerate(path):
        u=i/(len(path)-1)
        x0,y0=path[max(0,i-1)];x1,y1=path[min(i+1,len(path)-1)]
        dx,dy=x1-x0,y1-y0;mag=max(.01,math.hypot(dx,dy));nx,ny=-dy/mag,dx/mag
        thick=width*(.009+.991*math.sin(math.pi*u)**.86)*(1-.55*u)
        thick*=.91+.065*math.sin(u*29+seed)
        upper.append(((x+nx*thick)*SS,(y+ny*thick)*SS))
        lower.append(((x-nx*thick*.61)*SS,(y-ny*thick*.61)*SS))
    m=Image.new('L',(EXT,EXT));p=ImageDraw.Draw(m)
    p.polygon(upper+lower[::-1],fill=255)
    halo=new();halo.paste((36,224,174,255),(0,0,EXT,EXT))
    halo.putalpha(m.filter(ImageFilter.GaussianBlur(7*SS)).point(lambda x:int(x*.18)))
    dst.alpha_composite(halo)
    pigment=new();pigment.paste((38,211,163,255),(0,0,EXT,EXT))
    pigment.putalpha(m.point(lambda x:int(x*.47)))
    dst.alpha_composite(pigment)
    veil=new();veil.paste((166,253,215,255),(0,0,EXT,EXT))
    veil.putalpha(m.filter(ImageFilter.GaussianBlur(1.3*SS)).point(lambda x:int(x*.27)))
    dst.alpha_composite(veil)
    hot=new();brush=ImageDraw.Draw(hot,'RGBA')
    core=[(int(x*SS),int(y*SS)) for x,y in path]
    brush.line(core,fill=(236,255,234,176),width=2*SS,joint='curve')
    light=hot.filter(ImageFilter.GaussianBlur(2*SS))
    light.putalpha(light.getchannel('A').point(lambda x:int(x*.48)))
    dst.alpha_composite(light);dst.alpha_composite(hot)
    # Three staggered feather filaments, subordinate to main clean silhouette.
    for idx in [int(len(path)*.38),int(len(path)*.62)]:
        x,y=path[idx];xn,yn=path[idx+1];q=max(.001,math.hypot(xn-x,yn-y))
        bx=-(yn-y)/q;by=(xn-x)/q
        draw=ImageDraw.Draw(dst,'RGBA')
        draw.line([(x*SS,y*SS),((x+bx*9)*SS,(y+by*9)*SS)],fill=(147,253,211,115),width=2*SS)
def gold_heart(dst,p):
    layer=new();dr=ImageDraw.Draw(layer,'RGBA')
    s=math.sin(TAU*p);t=math.sin(2*TAU*p)
    strokes=[([(151,143),(158,129),(168,125)],(248,206,112,160)),
             ([(179,136),(183,149),(177,164)],(255,228,158,175)),
             ([(149,174),(161,182),(172,180)],(248,212,116,120))]
    for k,(path,c) in enumerate(strokes):
        dr.line([((x+s*(k-1))*SS,(y+t*(1-k)) *SS) for x,y in path],fill=c,width=2*SS,joint='curve')
    x=(164+2*s)*SS;y=(158+2*t)*SS
    dr.ellipse((x-3*SS,y-3*SS,x+3*SS,y+3*SS),fill=(255,255,221,220))
    bloom=layer.filter(ImageFilter.GaussianBlur(3.6*SS))
    bloom.putalpha(bloom.getchannel('A').point(lambda z:int(z*.27)))
    dst.alpha_composite(bloom);dst.alpha_composite(layer)
def motes(dst,p):
    draw=ImageDraw.Draw(dst,'RGBA')
    for k in range(13):
        u=(p+k/13)%1.
        theta=k*2.399963+.30*p;rx=56+21*math.sin(k*.8);ry=40+17*math.cos(k*.61)
        x=162+rx*math.cos(theta)+11*u
        y=156+ry*math.sin(theta)-26*u
        a=int(130*(1-abs(2*u-1))*.6+35)
        r=.4+1.1*max(0,1-abs(2*u-1))
        color=(235,255,227,a) if k%4 else (255,227,143,a)
        draw.ellipse(((x-r)*SS,(y-r)*SS,(x+r)*SS,(y+r)*SS),fill=color)
def frame(layer,index):
    p=index/POSES
    im=new()
    if layer=='back':
        paint_wind(im,((97,273),(116,225),(142,202),(156,170)),p,11.4,4)
        paint_wind(im,((243,275),(210,230),(195,194),(180,171)),(p+.19)%1,9.6,13)
        paint_wind(im,((157,166),(147,150),(164,124),(177,108)),(p+.39)%1,3.1,28)
    if layer=='front':
        paint_wind(im,((134,283),(143,245),(139,209),(161,179)),(p+.33)%1,7.7,9)
        paint_wind(im,((214,270),(194,235),(199,210),(179,181)),(p+.51)%1,6.6,20)
        gold_heart(im,p)
    if layer=='heart':
        gold_heart(im,p);motes(im,p)
    return im.resize((CELL,CELL),Image.Resampling.LANCZOS)
def atlas(arr):
    atlas=Image.new('RGBA',(CELL*6,CELL*4))
    for k,im in enumerate(arr):atlas.alpha_composite(im,((k%6)*CELL,(k//6)*CELL))
    return atlas
def emit(name,im,folder):
    file=folder/name
    if file.suffix=='.png':im.save(file)
    else:im.save(file,format='WEBP',lossless=True,method=5)
    return {'file':str(file.relative_to(ROOT)),'sha256':hashlib.sha256(file.read_bytes()).hexdigest(),'size':list(im.size)}
if __name__=='__main__':
    proof={'skill':'tmb.skill.talisman.phong_an_phu.passive_01.human','contract':'PASSIVE_ALWAYS_ON_NO_CAST_NO_DAMAGE_NO_HIT','license':'FIRST_PARTY_GENERATED_CODE_ART','frames_per_layer':POSES,'cell':[CELL,CELL],'atlas_grid':[6,4]}
    for layer in ('back','front','heart'):
        samples=[frame(layer,i) for i in range(POSES)]
        sheet=atlas(samples)
        assert sheet.getextrema()[3][0]==0 and sheet.getextrema()[3][1]>=150
        proof[layer+'_atlas']=emit('paf06_'+layer+'.webp',sheet,ASSETS)
        proof[layer+'_master']=emit('paf06_'+layer+'_master.png',samples[6],SOURCE)
        if layer=='front':
            keyposes=Image.new('RGBA',(CELL*6,CELL*2))
            for j,i in enumerate((0,2,4,6,8,10,12,14,16,18,20,22)):
                keyposes.alpha_composite(samples[i],((j%6)*CELL,(j//6)*CELL))
            proof['review_sheet']=emit('paf06_front_keyposes.png',keyposes,SOURCE)
    (SOURCE/'PAF06_SOURCE_MANIFEST.json').write_text(json.dumps(proof,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
    print('PAF06_R1_RGBA_SOURCE_PASS frames=72 layers=3 source_preserved=true')
