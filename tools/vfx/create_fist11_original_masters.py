#!/usr/bin/env python3
"""Deterministic first-party dark-crimson ethereal fist artwork source, FIST11.
Three independent RGBA source paintings: charge current, spectral fist, fractured contact.
No GIF, game actor, map, UI, copyrighted game pixels or skeletal rig.
"""
from pathlib import Path
import math, random, base64
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/fist11/assets/source'
OUT.mkdir(parents=True,exist_ok=True)
S=768
RED=(235,55,100); HOT=(255,184,176); CORE=(255,239,228)
BURG=(96,9,41)

def bez(p0,p1,p2,p3,n=60):
    return [((1-t)**3*p0[0]+3*(1-t)**2*t*p1[0]+3*(1-t)*t*t*p2[0]+t**3*p3[0],
             (1-t)**3*p0[1]+3*(1-t)**2*t*p1[1]+3*(1-t)*t*t*p2[1]+t**3*p3[1]) for t in np.linspace(0,1,n)]

def source_page():
    return Image.new('RGBA',(S,S),(0,0,0,0))

def cloud(dst,center,rx,ry,rgb=(189,13,54),alpha=85,blur=24,seed=0):
    s=Image.new('RGBA',dst.size)
    d=ImageDraw.Draw(s,'RGBA')
    x,y=center
    for z in range(14):
        rng=random.Random(seed*100+z)
        xx=x+rng.uniform(-rx*.48,rx*.48)
        yy=y+rng.uniform(-ry*.46,ry*.46)
        ra=rng.uniform(.28,.85)
        d.ellipse((xx-rx*ra,yy-ry*ra,xx+rx*ra,yy+ry*ra),fill=(*rgb,int(alpha/(z*.17+1))))
    dst.alpha_composite(s.filter(ImageFilter.GaussianBlur(blur)))

def ribbon(dst,pts,width=20,opacity=.72,seed=0,bright=True):
    '''Painted tapered multi-stroke ribbon with nonuniform pigment and inner filaments.'''
    random.seed(seed)
    n=len(pts)
    blurred=Image.new('RGBA',(S,S))
    d=ImageDraw.Draw(blurred,'RGBA')
    marks=Image.new('RGBA',(S,S))
    m=ImageDraw.Draw(marks,'RGBA')
    for i in range(n-1):
        q=i/(n-1)
        # Broad at beginning, fraying into flame-like talons near tip.
        taper=(.18+.82*math.sin(math.pi*(q*.86+.09))**.75)*(1-.33*q)
        spread=(1.1+.14*math.sin(i*.67+seed))
        thick=max(1,int(width*taper*spread))
        from_pt=(round(pts[i][0]),round(pts[i][1]));to_pt=(round(pts[i+1][0]),round(pts[i+1][1]))
        d.line([from_pt,to_pt],fill=(156,15,65,round(102*opacity)),width=max(3,thick*3))
        m.line([from_pt,to_pt],fill=(225,35+int(24*q),84+int(25*q),round(220*opacity)),width=thick)
        m.line([from_pt,to_pt],fill=(255,139+int(58*q),152+int(29*q),round(170*opacity)),width=max(1,thick//3))
        if i%8==0 and bright:
            radius=1+3*(1-q)
            m.ellipse((from_pt[0]-radius,from_pt[1]-radius,from_pt[0]+radius,from_pt[1]+radius),fill=(255,238,208,round(110*opacity)))
    dst.alpha_composite(blurred.filter(ImageFilter.GaussianBlur(12)))
    dst.alpha_composite(marks)

def shards(dst,seed,origin,count=37,scale=1.0,arc=math.pi*2):
    rng=random.Random(seed)
    d=ImageDraw.Draw(dst,'RGBA')
    ox,oy=origin
    for j in range(count):
        a=rng.uniform(-arc/2,arc/2)
        dist=rng.uniform(35,275)*scale
        x=ox+math.cos(a)*dist;y=oy+math.sin(a)*dist*.78
        size=rng.uniform(2.2,15)*scale
        poly=[(x-size*.70,y),(x+size*.80,y-size*.30),(x+size*1.2,y+size*.23),(x-size*.30,y+size*.60)]
        d.polygon(poly,fill=(199+rng.randrange(0,56),28+rng.randrange(0,80),90+rng.randrange(0,85),rng.randrange(50,145)))
        if j%4==0:d.line([poly[0],poly[1]],fill=(255,208,185,110),width=1)

def volume(kind):
    """Pigmented maroon living-current volume; broken contour, not an icon ring.
    Anti-aliased alpha from organic multi-lobe distance fields and fractal grain.
    """
    yy,xx=np.mgrid[:S,:S].astype(np.float32)
    if kind=='fist':
        ellipses=[(348,396,158,74,.43),(422,388,113,91,.64),(516,307,75,29,.47),(561,356,66,27,.42),(563,405,61,28,.48),(516,454,72,31,.51),(484,501,58,40,.42)]
        taper=np.clip((xx-52)/200,0,1)
    elif kind=='charge':
        ellipses=[(389,389,78,78,.50),(400,396,40,50,.42)]
        taper=1
    else:
        ellipses=[(387,370,75,79,.45),(445,343,62,42,.37),(340,424,53,47,.34)]
        taper=1
    value=np.zeros((S,S),dtype=np.float32)
    for x,y,sx,sy,g in ellipses:
        energy=np.exp(-((xx-x)/sx)**2*1.9-((yy-y)/sy)**2*1.5)
        value=np.maximum(value,energy*g)
    rng=np.random.default_rng({'fist':374,'charge':375,'contact':376}[kind])
    texture=np.zeros((S,S),dtype=np.float32)
    for N,w in ((7,.20),(17,.16),(41,.10),(83,.06)):
        field=(rng.random((N,N))*255).astype(np.uint8)
        im=Image.fromarray(field,'L').resize((S,S),Image.Resampling.BICUBIC)
        texture+=(np.array(im).astype(np.float32)/255-.5)*w
    material=np.clip(value*(.82+2*texture),0,1)
    vein=np.clip(.5+.5*np.sin((xx+yy*.25)*.043+texture*17),0,1)
    al=np.clip(material*225*taper,0,170).astype(np.uint8)
    out=np.empty((S,S,4),dtype=np.uint8)
    out[:,:,0]=np.clip(150+105*vein+50*material,0,255)
    out[:,:,1]=np.clip(18+90*vein*material,0,255)
    out[:,:,2]=np.clip(53+81*material,0,255)
    out[:,:,3]=al
    return Image.fromarray(out,'RGBA')

def charge():
    im=volume('charge')
    cloud(im,(373,395),190,161,(172,17,62),67,30,2)
    for j in range(11):
        a=2*math.pi*j/11+.2
        R=260+23*math.sin(j*3.21)
        p0=(384+R*math.cos(a),384+R*.73*math.sin(a))
        p3=(390+21*math.cos(a+.9),388+18*math.sin(a+.9))
        p1=(384+R*.70*math.cos(a+.5),384+R*.44*math.sin(a+.5))
        p2=(384+R*.18*math.cos(a+1.1),384+R*.14*math.sin(a+1.1))
        ribbon(im,bez(p0,p1,p2,p3,80),8+5*(j%3),.42+.08*(j%2),10+j)
    cloud(im,(390,389),68,65,(245,76,105),118,18,30)
    return im

def compact_phantom_fist():
    """Asymmetric closed-fist paint silhouette with fractured glowing knuckles.
    This is painted plasma, not a glove or literal anatomical cutout.
    """
    silhouette=Image.new('L',(S,S),0)
    ink=ImageDraw.Draw(silhouette)
    # Four rounded knuckles compressed into one mass, single thumb under palm.
    polygon=[(172,411),(260,339),(345,335),(400,287),(465,261),
             (514,256),(564,265),(610,287),(641,318),(640,347),
             (651,364),(645,392),(639,412),(627,437),(599,465),
             (571,482),(530,492),(493,519),(450,521),(426,483),
             (354,472),(266,480),(182,460)]
    ink.polygon(polygon,fill=210)
    for cx,cy,rx,ry in ((525,315,46,48),(572,351,46,40),
                        (574,404,48,43),(519,447,60,45),(459,480,57,37)):
        ink.ellipse((cx-rx,cy-ry,cx+rx,cy+ry),fill=225)
    mask=np.array(silhouette.filter(ImageFilter.GaussianBlur(10)),dtype=np.float32)/255.
    yy,xx=np.mgrid[:S,:S].astype(np.float32)
    rn=np.random.default_rng(88911)
    texture=np.zeros((S,S),dtype=np.float32)
    for grid,weight in ((6,.31),(13,.23),(33,.17),(79,.12)):
        tile=Image.fromarray((rn.random((grid,grid))*255).astype('uint8'),'L')
        texture+=(np.array(tile.resize((S,S),Image.Resampling.BICUBIC),dtype=np.float32)/255.-.5)*weight
    cracks=.62+.27*np.sin(xx*.072+yy*.013+texture*8.)**2
    mineral=np.clip(.59+texture*2.4,0,1)*cracks
    # Broken line slots cut through the fill so it remains an energy entity.
    fracture=np.abs(np.sin((xx+yy*.35)*.042+texture*12))
    mineral*=np.clip(fracture*.57+.52,.3,1.)
    mask*=mineral
    radial=np.clip((xx-270)/370,0,1)
    alpha=np.clip(mask*(115+130*radial),0,195).astype('uint8')
    color=np.zeros((S,S,4),dtype='uint8')
    color[:,:,0]=np.clip(128+116*radial+30*mineral,0,255)
    color[:,:,1]=np.clip(17+70*mineral*radial+25*fracture,0,160)
    color[:,:,2]=np.clip(38+72*radial+34*mineral,0,180)
    color[:,:,3]=alpha
    im=Image.fromarray(color,'RGBA')
    d=ImageDraw.Draw(im,'RGBA')
    # Painted broken knuckle strikes in white-coral, clearly no long claws.
    for k,(x,y) in enumerate(((552,301),(598,349),(593,403),(533,449))):
        d.arc((x-38,y-23,x+28,y+27),200,355,fill=(255,215,181,135),width=4)
        d.arc((x-34,y-20,x+24,y+23),202,342,fill=(255,121,139,120),width=9)
    return im

def fist():
    im=compact_phantom_fist()
    cloud(im,(378,390),280,134,(126,9,49),98,35,5)
    # Bending forearm current from left, central hollow tendon volume.
    ribbon(im,bez((45,515),(184,584),(312,451),(455,418),126),54,.56,33)
    ribbon(im,bez((60,299),(197,209),(299,331),(466,343),126),38,.50,34)
    ribbon(im,bez((72,436),(233,416),(285,405),(469,389),126),53,.68,35)
    # Four fragmented knuckle pressure ridges (read as an ethereal fist)
    # Tuck current branches into the COMPACT palm (no extended talons).
    for k in range(4):
        y=314+k*44
        ribbon(im,bez((415,y+18),(470,y-15),(528,y-11),(576-k*6,y-5),70),12-k*2,.34,60+k)
        cloud(im,(542-k*9,y-5),24,17,(255,120,136),50,7,64+k)
    # Thumb wraps down into the hollow fist, visually NOT a glove outline.
    ribbon(im,bez((385,483),(455,545),(524,556),(556,516),90),38,.75,112)
    for j in range(5):
        a=j*.56
        ribbon(im,bez((120,350+j*26),(245,230+j*35),(331,491-j*38),(454,367+j*20),84),5+j%3,.24,145+j,False)
    shards(im,66,(425,396),32,0.75,2.1)
    return im

def impact():
    im=volume('contact')
    cloud(im,(371,372),215,183,(179,16,64),94,25,9)
    # Asymmetric ruptured splash; three main branches, no generic ring.
    for j in range(12):
        a=-1.22+j*.233
        R=245+32*math.sin(j*2.8)
        p0=(389+25*math.cos(a),376+20*math.sin(a))
        p3=(378+R*math.cos(a),369+R*math.sin(a))
        p1=(405+130*math.cos(a+.2),359+110*math.sin(a+.2))
        p2=(398+R*.86*math.cos(a-.18),370+R*.75*math.sin(a-.18))
        ribbon(im,bez(p0,p1,p2,p3,70),20-(j%3)*3,.69,201+j)
    shards(im,202,(390,370),68,.92,math.pi*2)
    cloud(im,(392,372),74,65,(252,85,108),116,18,98)
    return im

if __name__=='__main__':
    for n,fn in [('charge',charge),('fist',fist),('contact',impact)]:
        im=fn()
        bbox=im.getbbox()
        assert bbox and im.mode=='RGBA'
        path=OUT/f'f11_{n}_master.png'
        im.save(path,optimize=True)
        webp=OUT/f'f11_{n}_master.webp'
        im.save(webp,format='WEBP',lossless=True,method=6)
        data=base64.b64encode(webp.read_bytes()).decode('ascii')
        (OUT/f'f11_{n}_master.webp.b64').write_text('\n'.join(data[i:i+140] for i in range(0,len(data),140))+'\n')
        print(n,im.size,bbox,webp.stat().st_size,im.getchannel('A').getextrema())