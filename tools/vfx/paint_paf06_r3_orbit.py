#!/usr/bin/env python3
"""PAF06 R3 original Võ-Lâm-style orbit BUFF. Reference mechanics only, no commercial pixels.
Hand-painted, perspective-projected alpha rings with separate near/far depth:
  • 48 DIFFERENT rear poses + 48 front poses + 48 independent sparkle poses
  • two body-orbiting, counter-rotating jade/gold light currents
  • subdued third ellipse under feet + organic moving glints
  • genuine transparent 320² sources, baked lossless WebP atlases, no GIF
R3 is a passive ALWAYS ON, never a cast/impact or status write.
"""
from PIL import Image,ImageDraw,ImageFilter
from pathlib import Path
import math, hashlib, json
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/"godot/labs/combat_lab/talisman16/r3"
ASSETS=BASE/"assets"; SOURCE=BASE/"art_sources"
ASSETS.mkdir(parents=True,exist_ok=True); SOURCE.mkdir(parents=True,exist_ok=True)
N=320; SS=3; S=N*SS; FRAMES=48; COLS=8; TAU=2*math.pi
JADE=(48,222,177); COLD=(188,255,228); GOLD=(247,207,115); HOT=(253,255,233)

def canvas():
    return Image.new("RGBA",(S,S),(0,0,0,0))
def at(r,theta,p):
    # Each ring has its own perspective slope; depth is sin(theta), NOT
    # a 2D circular HUD texture rotated around its own center.
    x,y,rx,ry,tilt=r
    return ((x+rx*math.cos(theta))*SS, (y+ry*math.sin(theta)+tilt*math.cos(theta))*SS)
def same_pass(a,b,front):
    theta=(a+b)*.5
    return (math.sin(theta)>=0.0)==front
RINGS=(
    # x, y, radius x/y, diagonal perspective; full orbit turns per source loop.
    ((160.,177.,88.,23.,-5.0), 1, JADE, 1.0),
    ((160.,142.,67.,17.,+7.0),-2, COLD, 0.78),
    ((160.,251.,72.,11.,-2.0), 1, GOLD, 0.21),
)
def angular_distance(a,b):
    return (a-b+math.pi)%TAU-math.pi
def frame(layer,index):
    p=index/FRAMES
    front=(layer=="front")
    glow=canvas(); body=canvas(); sharp=canvas()
    dg=ImageDraw.Draw(glow,"RGBA");db=ImageDraw.Draw(body,"RGBA");ds=ImageDraw.Draw(sharp,"RGBA")
    for ri,(ring,turns,pigment,weight) in enumerate(RINGS):
        # Long steady light volume + moving bright heads moving around ACTOR.
        # A physically-inspired near/far split puts rear segment behind sprite.
        step=TAU/360
        for k in range(360):
            a=k*step;b=(k+1)*step
            if not same_pass(a,b,front):
                continue
            pos1=at(ring,a,p);pos2=at(ring,b,p)
            dust=.87+.07*math.sin(a*9.0+ri*1.4)+.04*math.sin(a*17-ri*.8)
            base=.68 if front else .34
            amp=base*weight*dust
            # Slightly broken uneven pigment makes a luminous silk surface,
            # not a uniform CAD-style vector ring.
            if k%83 not in (4,5):
                dg.line((pos1,pos2),fill=(*pigment,int(84*amp)),width=int((14 if ri!=2 else 9)*SS))
                db.line((pos1,pos2),fill=(*pigment,int(190*amp)),width=int((4.5 if ri!=2 else 2.1)*SS))
                ds.line((pos1,pos2),fill=(*HOT,int(62*amp)),width=max(1,int(1.15*SS)))
            head0=(p*TAU*turns)+ri*.95
            head1=(p*TAU*turns)+ri*.95+2.55
            diff0=angular_distance(a,head0)
            diff1=angular_distance(a,head1)
            # A narrow white-hot head, transparent tail, different momentum.
            v0=math.exp(-.5*(diff0/.31)**2)
            v1=.67*math.exp(-.5*(diff1/.18)**2)
            light=max(v0,v1)
            if light>.024:
                dg.line((pos1,pos2),fill=(*pigment,int(102*weight*light)),width=int(18*SS))
                db.line((pos1,pos2),fill=(*COLD,int(206*light*weight)),width=int(5.0*SS))
                ds.line((pos1,pos2),fill=(*HOT,int(236*light*weight)),width=max(1,int(2.0*SS)))
        # Small scroll-like gold star-runes rotate around, with changing
        # perspective occlusion, rather than an icon floating above the head.
        for j in range(9 if ri<2 else 6):
            phase=(j/9*TAU)+p*TAU*turns+ri*.49
            if (math.sin(phase)>=0.0)!=front: continue
            x,y=at(ring,phase,p)
            stretch=.55+.45*max(0,math.sin(phase))
            size=(2.1+1.4*stretch)*(0.6 if ri==2 else 1.0)*SS
            tint=GOLD if (j+ri)%3==0 else COLD
            db.line([(x-size,y),(x+size,y)],fill=(*tint,int(168*weight)),width=max(1,int(1.05*SS)))
            ds.line([(x,y-size*.55),(x,y+size*.55)],fill=(*HOT,int(191*weight)),width=max(1,int(.8*SS)))
            if j%4==0:
                dg.ellipse((x-size*2.3,y-size*2.3,x+size*2.3,y+size*2.3),
                           fill=(*pigment,int(80*weight)))
    # Soft bloom is LOCAL to the painted rings, not a full-screen overlay.
    out=canvas()
    diffuse=glow.filter(ImageFilter.GaussianBlur(5*SS))
    diffuse.putalpha(diffuse.getchannel("A").point(lambda v:int(v*.52)))
    out.alpha_composite(diffuse)
    outline=body.filter(ImageFilter.GaussianBlur(1.6*SS))
    outline.putalpha(outline.getchannel("A").point(lambda v:int(v*.56)))
    out.alpha_composite(outline)
    out.alpha_composite(body); out.alpha_composite(sharp)
    return out.resize((N,N),Image.Resampling.LANCZOS)

def glints(index):
    p=index/FRAMES
    d=canvas();dr=ImageDraw.Draw(d,'RGBA')
    for k in range(21):
        # Ascending stars and thin tail filaments, fixed world-space anchors.
        u=(p+k*.618034)%1
        angle=k*2.39996+p*TAU*.23
        x=160+math.cos(angle)*(40+32*math.sin(k*.73))*.7
        y=234-107*u+8*math.sin(angle)
        opa=math.sin(math.pi*u)
        if opa<=0:continue
        size=(.43+1.4*opa)*SS
        a=int(120*opa)
        if k%5==0:
            dr.line(((x*SS,y*SS+5*SS*opa),(x*SS,y*SS-4*SS*opa)),
                    fill=(*GOLD,int(160*opa)),width=SS)
        dr.ellipse((x*SS-size,y*SS-size,x*SS+size,y*SS+size),
                   fill=(*(HOT if k%3 else GOLD),a))
    halo=d.filter(ImageFilter.GaussianBlur(2.1*SS))
    halo.putalpha(halo.getchannel("A").point(lambda v:int(v*.35)))
    halo.alpha_composite(d)
    return halo.resize((N,N),Image.Resampling.LANCZOS)

def atlas(frames):
    result=Image.new("RGBA",(N*COLS,N*math.ceil(len(frames)/COLS)))
    for i,im in enumerate(frames):
        result.alpha_composite(im,((i%COLS)*N,(i//COLS)*N))
    return result

def save(folder,name,im):
    fp=folder/name
    if fp.suffix==".webp": im.save(fp,format="WEBP",lossless=True,method=5)
    else: im.save(fp)
    return {"path":str(fp.relative_to(ROOT)),"sha256":hashlib.sha256(fp.read_bytes()).hexdigest(),
            "size_px":[im.width,im.height]}

if __name__=="__main__":
    evidence={"schema":"TMB_PAF06_R3_ORIGINAL_25D_ROTATING_BUFF_SOURCE","skill_id":"tmb.skill.talisman.phong_an_phu.passive_01.human",
              "rights":"FIRST_PARTY_CODE_PAINTED; VLTK SCREENSHOTS REFERENCE ONLY; NO THIRD_PARTY_ASSET_PIXELS",
              "canonical":"PASSIVE_ALWAYS_ON; NO CAST/HIT/BUFF_APPLICATION_WRITES",
              "grid":[COLS,6],"cell_px":[N,N],"frames_per_layer":FRAMES,
              "depth_rule":"back sin(orbit_theta)<0, front sin(orbit_theta)>=0",
              "loop_seconds":3.0,
              "layers":{}}
    for name in ("rear","front","spark"):
        items=[glints(i) if name=="spark" else frame("front" if name=="front" else "rear",i)
               for i in range(FRAMES)]
        av=atlas(items)
        al=av.getchannel("A").getextrema()
        # Sparse motes must stay transparent; a high alpha gate is for body rings only.
        required=115 if name=='spark' else 170
        assert al[0]==0 and al[1]>=required,(name,al,required)
        evidence["layers"][name]={"atlas":save(ASSETS,"paf06_r3_"+name+".webp",av),
                                 "master":save(SOURCE,"paf06_r3_"+name+"_master.png",items[12])}
        if name=="front":
            review=Image.new("RGBA",(N*6,N*2))
            for pos,idx in enumerate((0,4,8,12,16,20,24,28,32,36,40,44)):
                review.alpha_composite(items[idx],((pos%6)*N,(pos//6)*N))
            evidence["front_keypose_contact_sheet"]=save(SOURCE,"paf06_r3_front_keyposes.png",review)
    (SOURCE/"PAF06_R3_RGBA_MANIFEST.json").write_text(json.dumps(evidence,indent=2,ensure_ascii=False)+"\n",encoding="utf8")
    print("PAF06_R3_ORIGINAL_RGBA_PASS layered_25d=true frames=144 no_commercial_asset=true")
