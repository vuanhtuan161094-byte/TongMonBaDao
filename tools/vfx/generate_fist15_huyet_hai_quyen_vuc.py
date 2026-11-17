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
        # A turbulent veil of *flowing blood tide* rather than a HUD ellipse.
        # Several uneven soft ribbons separated in Y with rising fine foam.
        amp=math.sin(math.pi*(.08+.84*t))
        for j in range(6):
            phase=k*.31+j*1.79
            y0=223+j*21
            push=18*math.sin(phase)+15*amp
            pts=spline((82,y0+36*math.sin(phase)),
                (163,y0-63+push),(318,y0+57*math.sin(phase*.5)),
                (440,y0-16+23*math.sin(phase+1)),75)
            brush(mist,pts,38+10*amp+5*(j%2))
            brush(body,pts[8:66],15+6*amp-1.7*(j%3))
            if j in (1,4):
                brush(core,pts[20:48],5+int(3*amp))
        # Disconnected little updrafts are light mist, not radial UI arcs.
        for j in range(5):
            x=137+j*60+10*math.sin(j+t*8)
            y=316-7*(j%2)
            stream=spline((x,y+20),(x-35,y-5),(x+15,y-65),
                          (x+26+8*t,y-78),35)
            brush(mist,stream,12)
    elif kind=='fall':
        # Descending WHITE-core spiritual pressure with one visible front and
        # unequal secondary air currents. The head is a compact clenched
        # knuckle-shaped qi crest, not 5 equal vertical bar sprites.
        squeeze=math.sin(math.pi*(.07+.86*t))
        front=199+153*t
        center=255+6*math.sin(k*.44)
        main=spline((center-16,56),(center+33,107+11*t),
                    (center-22,front-73),(center,front-8),72)
        brush(mist,main,82)
        brush(body,main[8:],52+11*squeeze)
        brush(core,main[19:],17+6*squeeze)
        # Two irregular side wisps follow the same moving luminous body,
        # with different width, length and phase. Neither is full hot white.
        for j,side in enumerate((-1,1)):
            offs=66+12*j
            pts=spline((center+side*(offs+13),51+j*35),
                       (center+side*(offs+31),128+j*22),
                       (center+side*(27+6*math.sin(k*.31+j)),front-61),
                       (center+side*(34+5*j),front-8-j*21),55)
            brush(mist,pts,33-4*j)
            brush(body,pts[11:],13+6*squeeze)
            if j==0:brush(core,pts[24:43],3)
        # Image-space spiritual fists: four unequal luminous knuckles all
        # CONNECT to the one white-condensed palm, not four parallel swords.
        for j,(dx,scale) in enumerate(((-31,.91),(-11,1.16),(12,1.12),(34,.83))):
            x=center+dx
            y=front+5*math.sin(.52*k+j)
            ellipse(body,(x-15*scale,y-15*scale,x+15*scale,y+13*scale),224)
            ellipse(core,(x-7*scale,y-9*scale,x+8*scale,y+6*scale),242)
        palm=spline((center-28,front-5),(center-13,front+24),
                    (center+15,front+21),(center+29,front-4),45)
        brush(body,palm,27,False)
        brush(core,palm[9:37],11,False)
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
    base=Image.new('RGBA',(N,N))
    palettes={
       # These are COLOR-PURE physically separable luminosity zones (white
       # source, lavender mid-body, ruby atmospheric shadow), never a fully
       # opaque magenta ring or 5 uniformly colored streaks.
       'charge':((212,162,222),.91,(255,250,251),.98,(128,61,155),.33),
       'sea':((158,119,200),.44,(242,222,242),.52,(110,72,152),.33),
       'fall':((199,158,227),.90,(255,253,248),1.0,(113,78,156),.32),
       'hit':((235,172,218),.93,(255,252,238),1.0,(130,76,173),.34)}
    br,bo,cr,co,mr,mo=palettes[kind]
    soft=paint_layer(mist,mr,mo,13000+k+{'charge':1,'sea':2,'fall':3,'hit':4}[kind]*47)
    halo=body.filter(ImageFilter.GaussianBlur(14 if kind!='sea' else 24))
    base.alpha_composite(paint_layer(halo,(145,113,192),.24,11+k))
    base.alpha_composite(soft.filter(ImageFilter.GaussianBlur(12)))
    base.alpha_composite(paint_layer(body,br,bo,83+k))
    base.alpha_composite(paint_layer(core,cr,co,191+k))
    a=np.asarray(base.getchannel('A'))
    assert (a>28).sum()>90,(kind,k,'nonvisible')
    assert max(a[0,:].max(),a[-1,:].max(),a[:,0].max(),a[:,-1].max())<14,(kind,k,'border crop')
    return base

names=[('charge',10),('sea',12),('fall',17),('hit',8)]
manifest={'revision':'FIST15_R2','provenance':'ORIGINAL_FIRST_PARTY_CODE_PAINTED_RGBA_NOT_HAND_PAINTED','reference':'JX Wudang #158 timing and pure light language only; NO copied commercial pixels','atlases':{},'masters':{}}
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
print('FIST15_R2_BAKE_PASS total=47 originals=4 true_rgba=true no_gif=true no_rig=true')
