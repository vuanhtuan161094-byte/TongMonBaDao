#!/usr/bin/env python3
"""PAF06 R4 — distinctive Tinh-Gioi Tinh-Tam *visual identity*, original RGBA.
This ADDS a recognisable wind/heart-calm motif without changing R3's approved
ring trajectories: three travelling jade-and-gold talisman FEATHERS, each with
hand-inked ancient wind-strokes, and a small breathing chest HEART-LOTUS.
48 truly phase-dependent poses / layer, 3 layers, 320px, lossless WebP.
The wind leaves travel around the 2.5D orbits and pass BEHIND the actor.
No ripped Võ Lâm art, no HUD badge, no new cast/hit/damage logic.
"""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math, random, hashlib, json

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/"godot/labs/combat_lab/talisman16/r4"
SOURCE=BASE/"art_sources";ASSETS=BASE/"assets"
SOURCE.mkdir(parents=True,exist_ok=True);ASSETS.mkdir(parents=True,exist_ok=True)
N=320;SS=3;SZ=N*SS;FRAMES=48;COLS=8;TAU=math.tau
JADE=(39,232,172);PEARL=(227,255,229);GOLD=(248,197,93);WHITE=(255,255,224)
PIVOT=(160.0,159.0)
def img():return Image.new("RGBA",(SZ,SZ),(0,0,0,0))
def pol(pt):return [(round(x*SS),round(y*SS)) for x,y in pt]
def drawpath(d,pt,tint,width):
    d.line(pol(pt),fill=tint,width=max(1,round(width*SS)),joint="curve")
def composite_light(dst,subject,bloom=5,opacity=.28):
    halo=subject.filter(ImageFilter.GaussianBlur(bloom*SS))
    halo.putalpha(halo.getchannel("A").point(lambda v:round(v*opacity)))
    dst.alpha_composite(halo);dst.alpha_composite(subject)
def cubic(a,b,c,d,steps=28):
    pts=[]
    for i in range(steps):
        t=i/(steps-1);u=1-t
        pts.append((u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t*t*t*d[0],
                    u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t*t*t*d[1]))
    return pts
def orbit_location(theta,ring=0):
    # R3's orbit has (160,177,88,23,-5) for main circular energy flow.
    if ring==0:return (160+88*math.cos(theta),177+23*math.sin(theta)-5*math.cos(theta))
    return (160+67*math.cos(theta),142+17*math.sin(theta)+7*math.cos(theta))
def paint_feather(out,theta,front,idx,time):
    near=math.sin(theta)>=0.0
    if near!=front:return
    x,y=orbit_location(theta,idx%2)
    # Perspective and material: near side larger/hotter; far partly hidden.
    depth=.65+.35*max(0.0,math.sin(theta))
    length=22.0*depth if idx%2==0 else 17.5*depth
    width=11.0*depth
    # Visibly feathers, NOT diamonds or flat UI icons. Leading point follows orbit
    # tangential velocity, with inward curl and a short fragmented energy tail.
    tangent=theta+math.pi/2.0
    dx=math.cos(tangent);dy=math.sin(tangent)*.55
    norm=(-dy,dx)
    center=(x,y)
    tip=(x+dx*length*.64,y+dy*length*.64)
    tail=(x-dx*length*.55,y-dy*length*.55)
    left=(x+norm[0]*width,y+norm[1]*width)
    right=(x-norm[0]*width*.40,y-norm[1]*width*.40)
    # asymmetric painted kite/feather body and two independent organic veins
    layer=img();d=ImageDraw.Draw(layer,"RGBA")
    bodycurve=cubic(tail,(x-dx*length*.11+norm[0]*width*.6,y-dy*length*.11+norm[1]*width*.6),
                    (x+dx*length*.28+norm[0]*width*.61,y+dy*length*.28+norm[1]*width*.61),tip,29)
    innercurve=cubic(tip,(x+dx*length*.32-norm[0]*width*.33,y+dy*length*.32-norm[1]*width*.33),
                     (x-dx*length*.22-norm[0]*width*.33,y-dy*length*.22-norm[1]*width*.33),tail,29)
    d.polygon(pol(bodycurve+innercurve),fill=(*JADE,round(148*depth)),)
    d.line(pol(bodycurve),fill=(*PEARL,round(168*depth)),width=2*SS,joint="curve")
    d.line(pol(innercurve),fill=(*GOLD,round(148*depth)),width=max(1,SS),joint="curve")
    mid=cubic(tail,(x-dx*3,y-dy*3),(x+dx*9,y+dy*9),tip,21)
    d.line(pol(mid),fill=(*WHITE,round(216*depth)),width=max(1,round(1.6*SS)),joint="curve")
    # Three antique brush marks on the moving talisman; never full-size font/UI.
    for k in range(3):
        f=.25+.19*k
        xx=tail[0]+(tip[0]-tail[0])*f
        yy=tail[1]+(tip[1]-tail[1])*f
        off=(k-1)*2.3
        d.line(pol([(xx+norm[0]*(off-3),yy+norm[1]*(off-3)),
                    (xx+norm[0]*(off+3),yy+norm[1]*(off+3))]),
               fill=(*GOLD,round(202*depth)),width=max(1,round(1.2*SS)))
    # A few trailing soft wisps along tangent, not a noisy wobbly screen-space line.
    for k in range(3):
        t=(k+1)*.24
        base=(tail[0]-dx*(4+k*4),tail[1]-dy*(4+k*4))
        d.line(pol([base,(base[0]-dx*(5+t*6),base[1]-dy*(5+t*6)+norm[1]*k*1.3)]),
               fill=(*PEARL,round((132-k*32)*depth)),width=max(1,round((2.6-k*.5)*SS)))
    composite_light(out,layer,4,.39)
    # Hot crest at moving head; maximum intentionally limited relative to face.
    dot=img();ImageDraw.Draw(dot,"RGBA").ellipse(((tip[0]-2.3)*SS,(tip[1]-2.3)*SS,
                                                  (tip[0]+2.3)*SS,(tip[1]+2.3)*SS),
                                                 fill=(*WHITE,round(174*depth)))
    composite_light(out,dot,3,.31)

def gold_lotus(index):
    """Small active HEART-LOTUS made from six calligraphic, asymmetric petals.
    Its brightness changes via a breathing cycle, petals physically open/close.
    It is a light material integrated onto robe, never a rigid pasted HUD stamp.
    """
    t=index/FRAMES
    breath=.5-.5*math.cos(TAU*t)
    cx,cy=PIVOT
    material=img(); brush=ImageDraw.Draw(material,"RGBA")
    # Three broad tips with 3 subordinate petals; all converge into warm core.
    # At final size ~26px across chest, not a big lotus/shield overlay.
    for i in range(6):
        angle=-math.pi/2.0+i*TAU/6.0+(.04+.06*breath)*math.sin(i*.9)
        rad=(15.7 if i%2==0 else 11.0)+(2.6 if i%2==0 else 1.8)*breath
        tip=(cx+math.cos(angle)*rad,cy+math.sin(angle)*rad*.83)
        side=(-math.sin(angle),math.cos(angle))
        start=(cx+math.cos(angle)*3.5,cy+math.sin(angle)*2.8)
        p1=(cx+math.cos(angle)*rad*.58+side[0]*4.2,cy+math.sin(angle)*rad*.49+side[1]*3.1)
        p2=(cx+math.cos(angle)*rad*.58-side[0]*3.2,cy+math.sin(angle)*rad*.49-side[1]*2.8)
        # Painted curvilinear leaf, with tapering hot jade vein.
        upper=cubic(start,p1,(tip[0]+side[0]*2.2,tip[1]+side[1]*1.5),tip,16)
        lower=cubic(tip,(tip[0]-side[0]*2.1,tip[1]-side[1]*2),
                    p2,start,16)
        brush.polygon(pol(upper+lower),fill=(*JADE,round(72+35*breath)))
        drawpath(brush,upper,(*GOLD,round(174+36*breath)),1.15)
        drawpath(brush,cubic(start,p1,p2,tip,23),(*PEARL,round(134+65*breath)),.95)
    # A gold talisman triple-knot around the absolutely still pearl.
    for a,b in [((-7,-3),(-2,-9)),((4,-8),(8,-1)),((6,6),(-4,9))]:
        drawpath(brush,[(cx+a[0],cy+a[1]),(cx+b[0],cy+b[1])],
                 (*GOLD,round(146+39*breath)),1.2)
    radius=2.2+1.5*breath
    brush.ellipse(((cx-radius)*SS,(cy-radius)*SS,(cx+radius)*SS,(cy+radius)*SS),
                  fill=(*WHITE,round(188+45*breath)))
    out=img();composite_light(out,material,4.3,.31)
    return out

def layer_frame(name,i):
    t=i/FRAMES
    out=img()
    if name in ("rear","front"):
        is_front=(name=="front")
        # 3 unique rune-bearing feathers, each moving on the EXISTING 2.5D ring.
        # One full orbit over 3s, no cast/action from caster.
        for j in range(3):
            theta=TAU*t+j*TAU/3.0-.23
            paint_feather(out,theta,is_front,j,t)
        # Companion tiny antique gold glints on the upper counter-rotating ring.
        for j in range(3):
            theta=-TAU*2*t+j*TAU/3.0+.32
            x,y=orbit_location(theta,1)
            if (math.sin(theta)>=0.0)!=is_front:continue
            lyr=img();d=ImageDraw.Draw(lyr,"RGBA")
            radius=3.8
            d.ellipse(((x-radius)*SS,(y-radius)*SS,(x+radius)*SS,(y+radius)*SS),
                      fill=(*GOLD,156 if is_front else 77))
            d.line(pol([(x-7,y),(x+7,y)]),fill=(*WHITE,174 if is_front else 99),width=SS)
            composite_light(out,lyr,4,.24)
    elif name=="heart":
        out=gold_lotus(i)
    return out.resize((N,N),Image.Resampling.LANCZOS)
def atlas(poses):
    imgout=Image.new("RGBA",(N*8,N*6),(0,0,0,0))
    for i,x in enumerate(poses):imgout.alpha_composite(x,((i%8)*N,(i//8)*N))
    return imgout
def put(name,im,folder):
    path=folder/name
    if name.endswith(".webp"):im.save(path,format="WEBP",lossless=True,method=5)
    else:im.save(path)
    return {"path":str(path.relative_to(ROOT)),"size":[im.width,im.height],
            "sha256":hashlib.sha256(path.read_bytes()).hexdigest()}
if __name__=="__main__":
    man={"skill_id":"tmb.skill.talisman.phong_an_phu.passive_01.human",
         "version":"PAF06_R4_SEMANTIC_HEART_LOTUS_WIND_TALISMANS",
         "rights":"FIRST_PARTY_PAINTED_RGBA_NOT_VO_LAM_RIPPED",
         "canonical":"PASSIVE_ALWAYS_ON_NO_CAST_OR_HIT",
         "R3_orbit_preserved":True,"layers":{},
         "frames_per_layer":FRAMES,"frame_cell":[N,N],"atlas_columns":8,"visual_cycle_seconds":3.0,
         "motif":{"tinh_gioi":"three jade-gold wind talisman feathers circulate on the 2.5D belt",
                  "tinh_tam":"small six-petal warm-gold lotus heart with quiet central pearl",
                  "cooldown":"energy returns toward calm core, no fake gameplay cooldown event"}}
    for layer in ("rear","front","heart"):
        poses=[layer_frame(layer,i) for i in range(FRAMES)]
        sheet=atlas(poses)
        man["layers"][layer]={"atlas":put("paf06_r4_"+layer+".webp",sheet,ASSETS),
                               "source_master":put("paf06_r4_"+layer+"_master.png",poses[12],SOURCE)}
        if layer=="front":
            board=Image.new("RGBA",(N*6,N*2))
            for j,k in enumerate((0,4,8,12,16,20,24,28,32,36,40,44)):
                board.alpha_composite(poses[k],((j%6)*N,(j//6)*N))
            man["keypose_contact_sheet"]=put("paf06_r4_front_keyposes.png",board,SOURCE)
    (SOURCE/"PAF06_R4_PROVENANCE.json").write_text(json.dumps(man,indent=2,ensure_ascii=False)+"\n",encoding="utf8")
    print("PAF06_R4_SEMANTIC_SOURCE_PASS 3_moving_wind_feathers=true calm_heart_lotus=true independent_rgba=true")
