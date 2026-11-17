#!/usr/bin/env python3
"""FIST15 HUYET HAI QUYEN VUC R1 – original Wudang-light-principle study.
47 independently evolving code-painted transparent VFX poses. No source
sprites/frames from commercial JX/Võ Đang, no original game overlay.
Light-source design: near-white narrow core, clear lavender/rose inner body,
soft burgundy-plum outside; 3 descending fist-energy impacts to 3 targets.
This is deterministic code-painted art, NOT image-gen / manual painting.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np, math, hashlib, json
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'godot/labs/combat_lab/fist15/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
N=512;CELL=320
def spline(a,b,c,d,steps=52):
    arr=[]
    for t in np.linspace(0,1,steps):
        u=1-t;arr.append((u**3*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t**3*d[0],
                        u**3*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t**3*d[1]))
    return arr
def brush(layer,points,width,fade_edges=True):
    dr=ImageDraw.Draw(layer,'L');n=len(points)
    for i in range(n-1):
        f=i/(n-1)
        wave=(.15+.85*math.sin(math.pi*(.065+.88*f))**.65) if fade_edges else 1
        w=max(1,int(width*wave*(1+.1*math.sin(i*.41))))
        x,y=points[i];x2,y2=points[i+1]
        dr.line((int(x),int(y),int(x2),int(y2)),fill=235,width=w,joint='curve')
        rr=w*.5;dr.ellipse((x-rr,y-rr,x+rr,y+rr),fill=235)
def ellipse(layer,box,fill=185):
    ImageDraw.Draw(layer).ellipse(box,fill=fill)
def new():return Image.new('L',(N,N),0)
def masks(kind,k,n):
    t=k/max(1,n-1);body=new();core=new();mist=new()
    if kind=='charge':
        # Several unequal pale threads compress to one caster palm, no UI ring.
        for i in range(5):
            phi=i*1.34+k*.23
            r=130*(1-.68*t)
            yy=256+math.sin(phi)*r*.65
            xx=256+math.cos(phi)*r*.75
            dest=(256+math.cos(phi+2)*19,256+math.sin(phi+2)*14)
            brush(body,spline((xx,yy),(xx+45,yy-42),(dest[0]-45,dest[1]+21),dest),14+4*i)
            if i%2==0:brush(core,spline((xx,yy),(xx+45,yy-42),(dest[0]-45,dest[1]+21),dest),3)
        ellipse(mist,(211-35*t,216-35*t,301+35*t,306+35*t),60)
        ellipse(body,(235-18*t,236-18*t,277+18*t,278+18*t),140)
        ellipse(core,(249-8*t,248-8*t,263+8*t,264+8*t),225)
    elif kind=='sea':
        # NOT flat concentric circles: irregular crescent sea tides with blank center,
        # separate asymmetrical wave paths and changing wave envelopes.
        amp=math.sin(math.pi*(.10+.80*t))
        for j in range(4):
            phase=(j*1.17+0.14*k)
            radius=90+19*j+43*amp
            pts=[]
            for i in range(80):
                th=(.13+1.62*i/79)*math.pi+phase
                rr=radius*(1+.085*math.sin(5*th+phase)+.046*math.sin(9*th-k*.25))
                pts.append((256+rr*math.cos(th),282+rr*.46*math.sin(th)))
            brush(body,pts,17+9*amp-j*2)
            if j in (0,2):brush(core,pts[12:70],3+int(amp*3))
        for j in range(5):
            x=125+j*53+27*math.sin(t*4+j)
            y=333+j%3*12
            brush(mist,spline((x-23,y+17),(x,y+2),(x+25,y-38),(x+45,y-22)),12)
        # area is atmospheric, no huge opaque disk hiding monster feet.
    elif kind=='fall':
        # Wudang-inspired vertical light choreography; a recognizable 5-knuckle
        # qi fist descends with living filaments, NOT stolen sword images.
        squeeze=math.sin(math.pi*(.08+.82*t))
        head_y=205+148*t
        for j in range(5):
            off=(j-2)*18
            head_x=253+off+7*math.sin(t*9+j)
            end=(head_x+2*math.sin(t*8+j),head_y+8*(j%2))
            start=(head_x+off*.42-22,35-14*math.sin(t*5+j))
            curve=spline(start,(head_x+32,128+35*t),(head_x-20,head_y-74),end)
            brush(body,curve,14+7*squeeze-(abs(j-2)*1.5))
            if j in (1,2,3):brush(core,curve[17:],2+int(3*squeeze))
        # Five glowing knuckles, one condensed hand-shaped front at strike.
        for j in range(4):
            x=224+j*17+2*math.sin(k*.9+j)
            ellipse(body,(x-15,head_y-10,x+15,head_y+17),195)
            ellipse(core,(x-3,head_y-5,x+6,head_y+8),200)
        brush(body,spline((233,head_y-6),(240,head_y+22),(272,head_y+26),(287,head_y+9)),23,False)
        brush(core,spline((237,head_y-1),(245,head_y+13),(270,head_y+13),(283,head_y+1)),4,False)
        for j in range(4):
            dy=j*31
            brush(mist,spline((188+j*37,40),(200+j*27,122),(220+j*24,190),(223+j*17,head_y-dy)),26)
    elif kind=='hit':
        # 3 unequal impact petals and a sharp short core at receiving foe;
        # triangular directionality, no repeated circular GUI explosion.
        energy=math.sin(math.pi*(.08+.80*t))
        ellipse(body,(212-45*energy,205-46*energy,302+45*energy,304+46*energy),150)
        ellipse(core,(244-11*energy,238-11*energy,267+11*energy,264+11*energy),230)
        for j,ang in enumerate((-.4,.42,1.15,2.37,3.52,4.38)):
            z=(.55+.45*math.sin(k*.35+j))
            x=256; y=256
            fx=x+math.cos(ang)*(65+112*energy*z)
            fy=y+math.sin(ang)*(42+86*energy*z)
            path=spline((x,y),(x+10,y+2),(fx-21,fy+10),(fx,fy))
            brush(body,path,(18+8*energy)*(1-.07*j))
            if j%2==0:brush(core,path[:max(4,len(path)-10)],3+3*energy)
        for j in range(4):
            ang=j*1.52+.3*k
            cx=256+math.cos(ang)*130
            cy=256+math.sin(ang)*90
            ellipse(mist,(cx-27,cy-17,cx+27,cy+17),110)
    return body,core,mist
def paint_layer(mask,rgb,opacity,noise_seed):
    a=np.asarray(mask,dtype=np.float32)/255
    if a.max()<.01:return Image.new('RGBA',(N,N))
    rng=np.random.default_rng(noise_seed)
    gran=(np.asarray(Image.fromarray((rng.random((47,47))*255).astype('uint8'),'L').resize((N,N),Image.Resampling.BILINEAR),dtype=np.float32)/255)
    ribbon=np.clip(.75+.43*gran,0,1)
    out=np.zeros((N,N,4),dtype=np.uint8)
    for c in range(3):out[:,:,c]=rgb[c]
    out[:,:,3]=np.uint8(np.clip(a*opacity*ribbon*255,0,255))
    out[out[:,:,3]<2,:3]=0
    return Image.fromarray(out,'RGBA')
def mix(kind,k,n):
    body,core,mist=masks(kind,k,n)
    # 3 separately composited actual textures, no full alpha background.
    base=Image.new('RGBA',(N,N))
    soft=paint_layer(mist,(106,42,119),.33,13000+k+{'charge':1,'sea':2,'fall':3,'hit':4}[kind]*47)
    # softer burgundy/purple halo painted around main stroke (additive-like in
    # source, but RGB and alpha remain inspectable in atlas).
    halo=body.filter(ImageFilter.GaussianBlur(15))
    base.alpha_composite(paint_layer(halo,(153,69,168),.30,11+k))
    base.alpha_composite(soft.filter(ImageFilter.GaussianBlur(9)))
    base.alpha_composite(paint_layer(body,(224,111,163),.93,83+k))
    base.alpha_composite(paint_layer(core,(255,248,246),.98,191+k))
    a=np.asarray(base.getchannel('A'))
    assert (a>28).sum()>90,(kind,k,'nonvisible')
    assert max(a[0,:].max(),a[-1,:].max(),a[:,0].max(),a[:,-1].max())<14,(kind,k,'border crop')
    return base
names=[('charge',10),('sea',12),('fall',17),('hit',8)]
manifest={'revision':'FIST15_R1','provenance':'ORIGINAL_FIRST_PARTY_CODE_PAINTED_RGBA_NOT_HAND_PAINTED','reference':'JX Wudang #158 timing and pure light language only; NO copied commercial pixels','atlases':{},'masters':{}}
for name,n in names:
    frames=[mix(name,k,n) for k in range(n)]
    source=OUT/f'f15_{name}_master.png'
    frames[min(n-1,int(n*.60))].save(source,optimize=True)
    manifest['masters'][name]={'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'pixels':[N,N]}
    atlas=Image.new('RGBA',(CELL*4,CELL*((n+3)//4)))
    hashes=set()
    for i,im in enumerate(frames):
        thumb=im.resize((CELL,CELL),Image.Resampling.LANCZOS)
        hashes.add(hashlib.sha256(thumb.tobytes()).hexdigest())
        atlas.alpha_composite(thumb,((i%4)*CELL,(i//4)*CELL))
    assert len(hashes)==n,(name,'duplicate poses')
    outfile=OUT/f'f15_{name}.png'
    atlas.save(outfile,optimize=True)
    manifest['atlases'][name]={'sha256':hashlib.sha256(outfile.read_bytes()).hexdigest(),
        'frames':n,'size':list(atlas.size),'cell':CELL}
(OUT/'f15_manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
print('FIST15_R1_BAKE_PASS total=47 originals=4 true_rgba=true no_gif=true no_rig=true')
