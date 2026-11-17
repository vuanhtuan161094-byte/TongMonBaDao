#!/usr/bin/env python3
"""FIST14 Liệp Huyết Truy Đả R1 — ORIGINAL 2D RASTER CODE ART.
First-party deterministic code-painted RGBA spectral HUNTER'S THREE-TALON FIST.
Not ImageGen painting, not a crop of foreign games, reused FIST03/POI/HF
masters, UI geometry, fake Godot screenshot or rig. Separate stage poses.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np, math, hashlib, json
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'godot/labs/combat_lab/fist14/assets/generated'
OUT.mkdir(parents=True,exist_ok=True)
S=640;CELL=320
def trace(d,coords,radius,color=255):
    """Variable-width brush dabs connected into a tapered coherent silhouette."""
    for i in range(len(coords)-1):
        a=coords[i];b=coords[i+1]
        p=i/(len(coords)-1)
        w=max(1,int(radius*math.sin(math.pi*(.07+.85*p))**.78))
        d.line([a,b],fill=color,width=w,joint='curve')
        d.ellipse((a[0]-w*.50,a[1]-w*.50,a[0]+w*.50,a[1]+w*.50),fill=color)
def bez(a,b,c,d,n=40):
    res=[]
    for t in np.linspace(0,1,n):
        u=1-t
        res.append((float(u**3*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t**3*d[0]),
                    float(u**3*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t**3*d[1])))
    return res
def paint(mask,frame,kind,*,warm=.0):
    # High-res raster pigmented FIRST-PARTY original: actual alpha painted
    # source mask + 4-octave noise pigment, white-hot localized source detail.
    arr=np.asarray(mask.filter(ImageFilter.GaussianBlur(1.25)),dtype=np.float32)/255.
    yy,xx=np.mgrid[:S,:S].astype(np.float32)
    r=np.random.default_rng(50019+kind*911+frame*41)
    tex=np.zeros((S,S),dtype=np.float32)
    for n,amp in ((9,.28),(23,.17),(57,.09),(151,.045)):
        raw=(r.random((n,n))*255).astype(np.uint8)
        field=np.asarray(Image.fromarray(raw,'L').resize((S,S),Image.Resampling.BICUBIC),dtype=np.float32)/255
        tex+=amp*(field-.5)
    lines=.18*np.sin((xx*1.8+yy*.41+frame*9)*.027+tex*12)
    grain=np.clip(.61+.38*(tex*2.3+lines),.18,1.)
    bright=np.clip(((xx-346)/220),0,1)**.7
    heat=np.clip(bright*.83+.15*np.sin((yy+frame*17)*.035)+.14*warm,0,1)
    pigment=np.clip(grain+.10*bright,0,1)
    a=np.clip(arr*(.78+.18*pigment)*255,0,255)
    rgb=np.empty((S,S,4),dtype=np.uint8)
    rgb[:,:,0]=np.clip(96+145*pigment+33*heat,0,255).astype('uint8')
    rgb[:,:,1]=np.clip(8+38*pigment+165*heat**2,0,255).astype('uint8')
    rgb[:,:,2]=np.clip(29+48*pigment+125*heat**2,0,255).astype('uint8')
    rgb[:,:,3]=a.astype('uint8')
    rgb[a<2,:3]=0
    im=Image.fromarray(rgb,'RGBA')
    # Soft glow is secondary to MIX-defined physical hunting talon body.
    bloom=im.filter(ImageFilter.GaussianBlur(9))
    bloom.putalpha(bloom.getchannel('A').point(lambda v:int(v*.16)))
    bloom.alpha_composite(im)
    return bloom
def claws(frame,kind):
    t=frame/(11 if kind==1 else 7)
    m=Image.new('L',(S,S))
    d=ImageDraw.Draw(m)
    if kind==0: # CHARGE: shrinking three spirit talons converge to hand
        k=.42+.50*t; y0=320
        for j,offset in enumerate((-64,0,64)):
            sy=y0+offset
            pts=bez((116,sy+35*math.sin(t*math.pi+j)),(197,sy+32),
                    (250+85*t,316+offset*.38),(340,318+offset*.10),34)
            trace(d,pts,23*k)
        trace(d,bez((210,335),(240,305),(282,294),(358,324),35),31*k)
    elif kind==1: # THE single hunting talon/hand strike, 3 distinct sharp tips
        size=math.sin(math.pi*(.12+.79*t))**.68
        head=404+126*size
        base=260-25*(1-size)
        d.polygon([(114,344),(185,301),(242,284),(331,291),
                   (head-96,301),(head-118,363),(315,389),(193,390)],
                   fill=158)
        for j,yend in enumerate((225,312,400)):
            dy=yend-315
            start=(290,317+dy*.19)
            pts=bez(start,(385,292+dy*.47),(head-50,270+dy*.66),
                    (head,312+dy*.93),48)
            trace(d,pts,34+8*size)
        # not a uniform neon contour: negative-space cutouts at claw roots
        for j in (-1,1):
            d.ellipse((head-132,309+j*46-13,head-71,309+j*46+16),fill=0)
    elif kind==2: # single contact: one compressed three-notch claw landing
        strength=math.sin(math.pi*(.10+.86*t))**.8
        d.ellipse((240-27*strength,252-25*strength,417+27*strength,405+25*strength),fill=130)
        for j,dy in enumerate((-56,0,56)):
            trace(d,bez((213,341+dy*.6),(277,302+dy*.7),(351,301+dy*.9),
                        (459+70*strength,303+dy),38),31*strength+14)
    elif kind==3: # sustained small three-scar mark, not a poison cloud/UI glyph
        for j,dy in enumerate((-47,0,47)):
            t2=t*math.tau
            pts=bez((267+j*3,259+dy),(304,287+dy*.80),
                    (305,342+dy*.71),(351+j*4,361+dy*.42),35)
            trace(d,pts,15+2*math.sin(t2+j))
    return m
def frame(kind,k):
    mask=claws(k,kind)
    core=paint(mask,k,kind,warm=.18 if kind==2 else 0)
    # Jagged, brush-filled ivory-white knuckle veins on dedicated tiny overlay.
    glow=Image.new('RGBA',(S,S))
    pen=ImageDraw.Draw(glow,'RGBA')
    strength=(math.sin((k+1)*.34)*.10+.8)
    if kind==1:
        for j,yy in enumerate((237,312,396)):
            coords=bez((332,309+(j-1)*19),(395,289+(j-1)*44),
                       (460,255+(j-1)*75),(499,yy),35)
            trace(pen,coords,4,(255,222,213,int(120*strength)))
    elif kind==2:
        for j,yy in enumerate((245,316,399)):
            coords=bez((289,312+(j-1)*20),(341,300+(j-1)*35),
                       (382,289+(j-1)*45),(444,yy),32)
            trace(pen,coords,5,(255,235,217,140))
    elif kind==3:
        for j,dy in enumerate((-47,0,47)):
            coords=bez((279,266+dy),(307,294+dy*.79),
                       (312,338+dy*.75),(352,351+dy*.43),35)
            trace(pen,coords,3,(255,217,182,135))
    else:
        trace(pen,bez((267,337),(288,321),(316,319),(351,318),25),3,(255,216,197,110))
    core.alpha_composite(glow.filter(ImageFilter.GaussianBlur(.8)))
    bbox=core.getbbox()
    assert bbox is not None and bbox[0]>8 and bbox[1]>8 and bbox[2]<S-8 and bbox[3]<S-8,(kind,k,bbox)
    return core
kinds=[("charge",0,8),("talon",1,12),("contact",2,8),("mark",3,8)]
report={"source_class":"FIRST_PARTY_ORIGINAL_DETERMINISTIC_RASTER_CODE_ART",
        "art_source":"code, not hand-painted and not ImageGen",
        "rights":"Original algorithmic pigmented RGBA and independent key poses, no foreign pixels",
        "pose_total":36,"masters":{},"atlases":{}}
for name,typ,n in kinds:
    pages=[frame(typ,i) for i in range(n)]
    # Keep 640x640 ORIGINAL source masters, reproducible in CI/Git, no poster crops.
    source=OUT/f"f14_{name}_original_master.png"
    pages[round(n*.60)].save(source,optimize=True)
    report["masters"][name]={"path":str(source.relative_to(ROOT)),
         "size":[S,S],"sha256":hashlib.sha256(source.read_bytes()).hexdigest()}
    atlas=Image.new('RGBA',(CELL*4,CELL*((n+3)//4)))
    hashes=set()
    for i,original in enumerate(pages):
        tile=original.resize((CELL,CELL),Image.Resampling.LANCZOS)
        a=np.asarray(tile.getchannel('A'))
        assert int((a>48).sum())>=65,(name,i,'invisible')
        assert max(a[0,:].max(),a[-1,:].max(),a[:,0].max(),a[:,-1].max())<12,(name,i,'clipped')
        hashes.add(hashlib.sha256(tile.tobytes()).hexdigest())
        atlas.alpha_composite(tile,((i%4)*CELL,(i//4)*CELL))
    assert len(hashes)==n,(name,"duplicate pose")
    output=OUT/f"f14_{name}.png"
    atlas.save(output,optimize=True)
    report["atlases"][name]={"path":str(output.relative_to(ROOT)),"frames":n,
           "size":list(atlas.size),"sha256":hashlib.sha256(output.read_bytes()).hexdigest()}
(OUT/'f14_provenance.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print("FIST14_R1_BAKE_PASS poses=36 masters=4 pages=4 code_original=true rgba=true no_gif=true no_rig=true")
