#!/usr/bin/env python3
"""FIST14 R3 REWORK: source-faithful layered sprite animation.

Uses the exact first-party ImageGen 1774x887 true-RGBA original and individually
composed light/impact/status frames. These are authored energy-layer changes,
not 36 separately redrawn anatomy studies. No rig and no poster cropping.
Requires genuine Godot G3.5 art review before acceptance.
"""
from pathlib import Path
import hashlib, math, json, random
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'source/fist14_original_rgba_1774x887.png'
SHA='e0006ceb6208cb7cb037d2909f2ca9d27e10f63b7d71871f53b6b55f4903b7b5'
S=640; CELL=320
BBOX={}
def digest(b):return hashlib.sha256(b).hexdigest()
def hfile(p):return digest(p.read_bytes())
def bez(p0,p1,p2,p3,n=44):
    out=[]
    for i in range(n):
        t=i/(n-1);u=1-t
        out.append((round(u**3*p0[0]+3*u*u*t*p1[0]+3*u*t*t*p2[0]+t**3*p3[0]),round(u**3*p0[1]+3*u*u*t*p1[1]+3*u*t*t*p2[1]+t**3*p3[1])))
    return out

def new():return Image.new('RGBA',(S,S),(0,0,0,0))
def paint_stroke(target,points,wide=10,alpha=155,hot=False):
    # Stage light individually authored as three superposed paints, not uniform bars.
    under=new();p=ImageDraw.Draw(under,'RGBA');p.line(points,fill=(162,7,46,alpha//2),width=wide*4,joint='curve')
    bloom=under.filter(ImageFilter.GaussianBlur(16));target.alpha_composite(bloom)
    body=new();d=ImageDraw.Draw(body,'RGBA');d.line(points,fill=(210,17,60,min(250,alpha)),width=wide,joint='curve')
    d.line(points[5:],fill=(253,104,130,min(255,int(alpha*.85))),width=max(2,wide//3),joint='curve')
    if hot:d.line(points[int(len(points)*.6):],fill=(255,240,223,min(255,alpha+45)),width=max(1,wide//6),joint='curve')
    target.alpha_composite(body)

def local_flash(target,center,phase,seed,size):
    x,y=center;rng=random.Random(seed)
    sm=new();d=ImageDraw.Draw(sm,'RGBA')
    # unequal short brush rays in one impact, not a UI sunburst
    for i in range(13):
        a=(i*math.tau/13)+.27+(.24*rng.random())
        span=size*(.46+.86*rng.random())
        start=(int(x+math.cos(a)*size*.15),int(y+math.sin(a)*size*.11))
        tip=(int(x+math.cos(a)*span),int(y+math.sin(a)*span*.8))
        bend=(int((start[0]+tip[0])*.5+3*rng.random()),int((start[1]+tip[1])*.5-4*rng.random()))
        d.line([start,bend,tip],fill=(243,30,80,round(185*phase)),width=rng.choice([2,3,5]))
        d.line([start,bend],fill=(255,218,215,round(166*phase)),width=1)
    target.alpha_composite(sm.filter(ImageFilter.GaussianBlur(11)))
    target.alpha_composite(sm)
    orb=new();o=ImageDraw.Draw(orb,'RGBA')
    o.ellipse((x-15*phase,y-10*phase,x+15*phase,y+10*phase),fill=(255,252,239,round(255*phase)))
    halo=orb.filter(ImageFilter.GaussianBlur(6))
    target.alpha_composite(halo)
    target.alpha_composite(orb)

def source_layer(im,src_rect,width,opacity=1.,center=(330,315),shear=0.,stretch=1.,soft_matte=True):
    src=im.crop(src_rect)
    # Independently controlled taper and local shear: stage-specific motion,
    # not a static cell copy or change of overall atlas opacity.
    w,h=src.size; nh=max(1,int(width*h/w*stretch)); src=src.resize((int(width),nh),Image.Resampling.LANCZOS)
    # asymmetric local warp of crimson plume, knots stay near the front.
    src_arr=np.array(src); hh,ww=src_arr.shape[:2]
    rolled=np.zeros_like(src_arr)
    for yi in range(hh):
        # content warp low amplitude, no skeletal/actor rig
        dx=int(shear*(yi-hh/2)/max(1,hh/2)+5*math.sin(yi/max(1,hh)*math.tau*.7))
        if dx>=0:rolled[yi,dx:]=src_arr[yi,:ww-dx]
        else:rolled[yi,:dx]=src_arr[yi,-dx:]
    src=Image.fromarray(rolled,'RGBA')
    arr=np.asarray(src.getchannel('A'),dtype=np.float32)
    y,x=np.mgrid[:hh,:ww]; cx=ww*.54;cy=hh*.49
    radial=np.sqrt(((x-cx)/(ww*.63))**2+((y-cy)/(hh*.68))**2)
    matte=np.clip((1.02-radial)/.32,0,1); matte=matte*matte*(3-2*matte)
    src.putalpha(Image.fromarray(np.uint8(np.clip(arr*matte*opacity,0,255)),'L'))
    return src,(int(center[0]-ww/2),int(center[1]-hh/2))

def mark(t):
    # An authored fist-imprint for a single MARK, not claw marks or a HUD ring.
    f=new();rng=random.Random(9901+int(t*100))
    pulse=.91+.08*math.sin(t*math.tau)
    vapor=new();dv=ImageDraw.Draw(vapor,'RGBA')
    for j in range(5):
        q=j/4
        control=bez((289+10*j,357),(276+3*j,321-5*math.sin(t*4+j)),(306+9*j,289),(330+12*j,275))
        dv.line(control,fill=(174,22,61,int(50*pulse*(1-.08*j))),width=8-j//2)
    f.alpha_composite(vapor.filter(ImageFilter.GaussianBlur(13)))
    layer=new();d=ImageDraw.Draw(layer,'RGBA')
    # knuckles in uneven shallow arc; these features persist while veins shift
    for j in range(4):
        x=292+j*19+(3 if j==2 else 0);y=316+(j-1)**2*2
        d.rounded_rectangle((x-8,y-11,x+8,y+4),radius=6,
             fill=(204+11*j,39,86,int(214*pulse)),outline=(255,229,203,int(245*pulse)),width=3)
        d.line(bez((x,y+6),(x+2,y+17),(327-12+j*7,347),(331,355)),fill=(253,83,125,int(192*pulse)),width=4)
    d.arc((294,317,343,367),25,145,fill=(255,234,211,int(226*pulse)),width=6)
    f.alpha_composite(layer.filter(ImageFilter.GaussianBlur(9)))
    f.alpha_composite(layer)
    return f

def frame(im,kind,i,n):
    t=i/(n-1);out=new()
    if kind=='charge':
        # Distinct convergence trajectory: streams contract and spiral into one closed fist.
        envelope=(1-t)**1.35
        for j in range(5):
            dy=(j-2)*34
            origin=(85+int(t*100),320+dy+int(13*math.sin(t*math.pi*2+j)))
            end=(330+int(12*t),318)
            cp1=(166+int(t*45),297+dy*.72)
            cp2=(268,315+dy*.32+int(20*(1-t)*math.sin(j+t*4)))
            paint_stroke(out,bez(origin,cp1,cp2,end),wide=6+j%3,alpha=int(110+120*t),hot=j==2 and i>3)
        src,pos=source_layer(im,(1010,135,1580,784),width=135+int(35*t),opacity=.18+.72*t,center=(336,318),stretch=.92+.12*t)
        out.alpha_composite(src,dest=pos)
        if i>=5:local_flash(out,(416,316),.22+.35*t,101+i,size=13+14*t)
    elif kind=='flight':
        # Three distinct hand-authored flowing blood-Qi currents, converging
        # toward ONE fist. Avoid uniform side-by-side "three-claw" rails.
        accel=t*t*(3-2*t); wave=math.sin(math.pi*t)
        flows=[
            ((112,258+20*math.sin(5*t)),(168,244-30*wave),(267,292+22*wave),(436,315)),
            ((92,359+23*math.sin(4*t+1.5)),(134,399-27*wave),(296,344-13*wave),(431,326)),
            ((128,311+34*math.sin(3.4*t+2.1)),(231,351-45*wave),(301,296+30*wave),(453,322)),
        ]
        for j,(a,b,c,d) in enumerate(flows):
            pts=bez(a,b,c,d)
            paint_stroke(out,pts,wide=[8,11,4][j],alpha=round([142,156,110][j]+50*wave),hot=j==1)
        src,pos=source_layer(im,(135,40,1725,838),width=350+int(70*wave),opacity=.76+.22*wave,center=(330+int(13*t),320),shear=11*math.sin(2*t*math.pi))
        out.alpha_composite(src,dest=pos)
        # One knuckle light stroke, not a fake additional impact/hit.
        knuckle=bez((456,301-5*wave),(473,291-6*wave),(501,306+4*wave),(506,325))
        paint_stroke(out,knuckle,wide=6,alpha=round(195+50*wave),hot=True)
        if i>6:local_flash(out,(501+int(9*t),321),.18+.25*(t-.4),201+i,24)
    elif kind=='contact':
        # The sprite dissolves into a single impact; visually distinct poses
        # including sharp contact, spread, staggered closure and mark emergence.
        strength=math.sin(math.pi*(.10+.88*t))**.8
        src,pos=source_layer(im,(840,105,1745,826),width=330+int(70*strength),opacity=(1-t)**1.12,center=(309-int(18*t),316),stretch=1+.16*t)
        out.alpha_composite(src,dest=pos)
        local_flash(out,(446+int(t*12),315),max(.30,1-t**.65),401+i,37+int(74*t))
        for j in range(4):
            # unequal shock filaments deform and break apart, no false hit receipts
            off=j*math.pi/2
            v=math.sin(math.pi*t)
            start=(447,318)
            a=off+.22*math.sin(i+j)
            control=bez(start,(447+int(55*v*math.cos(a)),310+int(60*v*math.sin(a))),
                        (450+int((58+30*t)*math.cos(a)),318+int((47+28*t)*math.sin(a))),
                        (445+int((70+46*t)*math.cos(a)),319+int((55+40*t)*math.sin(a))))
            paint_stroke(out,control,wide=max(1,int(8*(1-t))),alpha=max(20,int(148*(1-t))),hot=j==0)
        if i>=5:
            state=mark(t)
            alpha=state.getchannel('A');alpha=alpha.point(lambda a:int(a*(i-4)/4))
            state.putalpha(alpha);out.alpha_composite(state)
    elif kind=='mark':
        out=mark(t)
    else:raise ValueError(kind)
    return out

def main():
    for directory in ('assets/frames', 'assets/atlases', 'qa', 'review'):
        (ROOT/directory).mkdir(parents=True, exist_ok=True)
    if not SRC.exists() or hfile(SRC)!=SHA:raise SystemExit('FIST14_R3_FAIL_SOURCE_SHA')
    im=Image.open(SRC).convert('RGBA')
    assert im.size==(1774,887)
    report={'source_sha256':SHA,'source_path':'source/fist14_original_rgba_1774x887.png',
            'role':'R3 first-party source + independently composed VFX phase layers; fist anatomy sourced from one master',
            'master_independent_hand_pose_count':1,'G35':'NOT_EXECUTED','owner':'PENDING','pve':'HOLD',
            'frames':{},'atlases':{}}
    allkeys=[]
    for kind,n in [('charge',8),('flight',12),('contact',8),('mark',8)]:
        atlas=Image.new('RGBA',(CELL*4,CELL*((n+3)//4)),(0,0,0,0))
        frames=[];hashes=[]
        for i in range(n):
            f=frame(im,kind,i,n)
            bbox=f.getchannel('A').getbbox();assert bbox is not None,(kind,i)
            assert min(bbox[0],bbox[1],S-bbox[2],S-bbox[3])>0,(kind,i,bbox)
            path=ROOT/'assets/frames'/f'f14_{kind}_{i:02d}.png';f.save(path,optimize=True)
            hashes.append(hfile(path)); frames.append({'idx':i,'sha256':hashes[-1],'bbox':bbox})
            atlas.alpha_composite(f.resize((CELL,CELL),Image.Resampling.LANCZOS),((i%4)*CELL,(i//4)*CELL))
        assert len(set(hashes))==n,kind
        out=ROOT/'assets/atlases'/f'f14_{kind}.png';atlas.save(out,optimize=True)
        report['frames'][kind]=frames;report['atlases'][kind]={'path':str(out.relative_to(ROOT)),'sha256':hfile(out),'count':n,'size':atlas.size}
        allkeys.extend(hashes)
    (ROOT/'qa/rework_manifest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
    display=Image.new('RGBA',(1280,320*10),(0,0,0,0));y=0
    for kind in ('charge','flight','contact','mark'):
        im2=Image.open(ROOT/'assets/atlases'/f'f14_{kind}.png')
        display.alpha_composite(im2,(0,y));y+=im2.height
    display=display.crop((0,0,1280,y))
    display.save(ROOT/'review/atlas_static_not_godot.png',optimize=True)
    print('FIST14_R3B_REWORK_STATIC_OK frames=36 phases=4 original_master_sha='+SHA)
    print('G3.5_NOT_EXECUTED G3.7_NOT_APPROVED')
if __name__=='__main__':main()
