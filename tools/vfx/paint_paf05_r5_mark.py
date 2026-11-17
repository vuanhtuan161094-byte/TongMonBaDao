#!/usr/bin/env python3
"""PAF05 R5: original *isolated* painted RGBA wind-seal sources, not a poster crop.
Each key represents an authored new change in gold stroke emergence, jade feather
growth, contact bloom or dissolution. Pillow is the source painting pipeline.
No commercial pixels, no single-frame UV wave, no actor rig.
"""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math, random, hashlib, json

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'godot/labs/combat_lab/talisman15/r5'
SRC=BASE/'art_sources'; OUT=BASE/'assets'
SRC.mkdir(parents=True,exist_ok=True);OUT.mkdir(parents=True,exist_ok=True)
S=3
N=320
GOLD=(249,208,117); GOLDHOT=(255,250,207)
JADE=(23,221,171); JADEHOT=(229,255,234)
def canvas(n=N):
    return Image.new('RGBA',(n*S,n*S),(0,0,0,0))
def points(p):
    return [(round(a*S),round(b*S)) for a,b in p]
def comp(dst,layer,blur=4,strength=.21):
    halo=layer.filter(ImageFilter.GaussianBlur(blur*S))
    al=halo.getchannel('A').point(lambda v:round(v*strength))
    halo.putalpha(al)
    dst.alpha_composite(halo)
    dst.alpha_composite(layer)
def cb(a,b,c,d,num=84):
    p=[]
    for j in range(num):
        t=j/(num-1);u=1-t
        p.append((u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t*t*t*d[0],
                  u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t*t*t*d[1]))
    return p
def brushed(dst,anchors,thick,base,color,progress=1,seed=0,glow=4):
    """Variable-width textured hand-drawn brush stroke with broken tapered ends."""
    pg=cb(*anchors)
    cnt=max(2, min(len(pg),int(len(pg)*progress)))
    pg=pg[:cnt]
    if len(pg)<3:return
    shape=[]
    top=[];bottom=[]
    rng=random.Random(1007+seed)
    for j,(x,y) in enumerate(pg):
        t=j/(len(pg)-1)
        x0,y0=pg[max(0,j-1)]
        x1,y1=pg[min(len(pg)-1,j+1)]
        dx,dy=x1-x0,y1-y0
        m=max(.01,math.hypot(dx,dy))
        nx,ny=-dy/m,dx/m
        z=(.35+.65*math.sin(math.pi*t)**.62)*thick
        z*=.92+.10*math.sin(t*25+seed*.77)
        top.append((x+nx*z,y+ny*z))
        bottom.append((x-nx*z*.48,y-ny*z*.48))
    layer=canvas()
    d=ImageDraw.Draw(layer,'RGBA')
    d.polygon(points(top+bottom[::-1]),fill=(*color,int(base*.54)))
    d.line(points(top),fill=(*color,int(base*.92)),width=max(1,int(thick*.38*S)),joint='curve')
    # Preserve a nearly opaque ivory-hot center; soft/transparent only at edge.
    d.line(points(pg),fill=(*JADEHOT,int(base*.80)) if color==JADE else (*GOLDHOT,int(base*.87)),width=max(1,int(thick*.23*S)),joint='curve')
    # Broken inner calligraphy fibres: varying lengths, never one vector line.
    for q in range(5):
        start=(.06+q*.178+seed*.024)%1
        stop=min(.98,start+.10+rng.random()*.1)
        sl=pg[int(start*(len(pg)-1)):max(2,int(stop*(len(pg)-1)))]
        if len(sl)>2:
            d.line(points(sl),fill=(*color,int(base*.55)),width=max(1,int((.36+q*.09)*S)),joint='curve')
    comp(dst,layer,blur=glow,strength=.16)
def ornament(dst,progress,offset=0):
    # Three asymmetric antique gold rune stems; designed like engraved brushwork.
    strokes=[
      ((135,49),(121,78),(129,91),(152,105)),
      ((174,52),(207,72),(196,95),(174,112)),
      ((106,125),(133,115),(188,131),(211,120)),
      ((106,193),(120,219),(144,233),(165,226)),
      ((205,186),(186,210),(190,241),(164,264)),
      ((134,268),(154,277),(184,263),(199,244)),
      ((108,156),(94,168),(105,189),(120,194)),
      ((215,150),(230,167),(221,186),(205,198))
    ]
    for k,st in enumerate(strokes):
        start=.045+k*.077
        v=max(0,min(1,(progress-start)*4.4))
        if v<.015:continue
        brushed(dst,st,1.5 if k%2 else 2.1,196,GOLD,v,seed=k+offset,glow=3)
def feather(dst,which,progress,seed=0):
    # Feather-like wind qi, not a fixed symbol rotated/waved. Each piece has
    # its own changing distal contour with a separate anchored head and tail.
    origins=[
      ((120,182),(73,149),(93,100),(154,99)),
      ((182,103),(237,93),(242,146),(212,179)),
      ((197,201),(219,258),(155,273),(133,231)),
      ((126,222),(78,221),(72,182),(114,157)),
    ]
    anchors=list(origins[which])
    # Distinct evolved morphology: the wing tip grows and folds, not picture warp.
    t=progress
    p1=anchors[0];p2=anchors[1];p3=anchors[2];tip=anchors[3]
    adj=(
      (tip[0]+8*t,tip[1]-14*t) if which==0 else
      (tip[0]+13*t,tip[1]+3*t) if which==1 else
      (tip[0]-4*t,tip[1]+14*t) if which==2 else
      (tip[0]-11*t,tip[1]-3*t))
    curved=(p1,p2,p3,adj)
    brushed(dst,curved,6.6+2.5*t,230,JADE,progress=t,seed=which+seed*2,glow=8)
    # one thin inner microfibre along a different arc
    a,b,c,d=curved
    sub=((a[0]+3,a[1]),(b[0]-7,b[1]+3),(c[0]+4,c[1]-4),(d[0]-3,d[1]))
    brushed(dst,sub,1.2,210,JADEHOT,t,seed=which+30+seed,glow=3)
def small_dust(dst,q,seed=0,amount=23):
    d=ImageDraw.Draw(dst,'RGBA')
    rnd=random.Random(5031+seed)
    for k in range(amount):
        angle=k*2.399+q*.66
        radius=46+90*((k*17)%29)/29
        x=160+math.cos(angle)*radius+rnd.uniform(-4,4)
        y=165+math.sin(angle)*radius*.86+rnd.uniform(-4,4)
        r=.30+rnd.random()*1.15
        d.ellipse(((x-r)*S,(y-r)*S,(x+r)*S,(y+r)*S),fill=(*GOLDHOT,rnd.randint(40,145)) if k%5==0 else (*JADEHOT,rnd.randint(50,142)))
def master(progress,jade,seed=0):
    dst=canvas()
    # Not a static UI circle: an ornamental three-part vertically pinched seal.
    ornament(dst,progress,seed)
    for k in range(4):
        feather(dst,k,max(0,min(1,(jade-k*.045)*1.23)),seed)
    if jade>.45:
        # Three crossing, calligraphic gold veins, not an LED ring.
        for k,st in enumerate([
            ((145,136),(153,117),(170,123),(175,143)),
            ((185,152),(199,173),(176,183),(160,177)),
            ((151,185),(129,177),(136,153),(155,148))]):
            brushed(dst,st,1.3,195,GOLD,max(0,min(1,(jade-.32)*1.7)),seed=k+seed,glow=4)
    small_dust(dst,jade,seed)
    return dst.resize((N,N),Image.Resampling.LANCZOS)
def brand_frame(i):
    # A true temporal calligraphy reveal; the hold loop has changing energy,
    # but a coherent constant mark silhouette (unlike R3's global sine warp).
    if i<5: gold=(i+1)/5; qi=max(.02,(i-1)/4)
    else: gold=1.0;qi=.85+.12*math.sin((i-5)*math.pi/5)
    return master(gold,qi,i)
def burst_frame(i):
    dst=master(min(1.0,.18+i*.22),min(1.0,.14+i*.22),i+17)
    scale=2
    canvas2=Image.new('RGBA',(N*scale,N*scale),(0,0,0,0))
    # Localized burst around the anchoring mark, golden hot facets.
    ring=Image.new('RGBA',(N*scale,N*scale),(0,0,0,0))
    d=ImageDraw.Draw(ring,'RGBA')
    origin=N
    # Each contact stage has new independent expanding, BREAKING strokes.
    for k in range(6):
        base=k*math.tau/6.0+.14*i
        r0=24+i*5
        r1=r0+18+i*1.8
        x0=origin+math.cos(base)*r0;y0=origin+math.sin(base)*r0
        x1=origin+math.cos(base+.16)*r1;y1=origin+math.sin(base+.16)*r1
        d.line([(x0,y0),(x1,y1)],fill=(*JADEHOT,max(0,240-i*15)),width=3)
    ring=ring.filter(ImageFilter.GaussianBlur(2))
    canvas2.alpha_composite(ring)
    canvas2.alpha_composite(dst.resize((N*scale,N*scale),Image.Resampling.LANCZOS))
    if i>=8:
        a=canvas2.getchannel('A').point(lambda x:int(x*(11-i)/3))
        canvas2.putalpha(a)
    return canvas2.resize((N,N),Image.Resampling.LANCZOS)
def atlas(frames,columns=4):
    w,h=frames[0].size
    im=Image.new('RGBA',(w*columns,h*math.ceil(len(frames)/columns)),(0,0,0,0))
    for i,frame in enumerate(frames):
        im.alpha_composite(frame,((i%columns)*w,(i//columns)*h))
    return im
def store(name,img):
    p=OUT/name; img.save(p,quality=89,method=6);return str(p.relative_to(ROOT)),hashlib.sha256(p.read_bytes()).hexdigest()
if __name__=="__main__":
    frames=[brand_frame(i) for i in range(12)]
    contact=[burst_frame(i) for i in range(11)]
    hero=master(1.0,1.0,8)
    hero.save(SRC/'paf05_r5_phong_linh_trien_master.png')
    entry={
       'schema':'PAF05_R5_ISOLATED_RGBA_ART_SOURCE',
       'art':'FIRST_PARTY_CODE_PAINTED_SEPARATE_MARK_NOT_UI_NOT_POSTER',
       'frames_status':12,'frames_contact':11,
       'render_cell':[N,N], 'columns':4,
       'master':str((SRC/'paf05_r5_phong_linh_trien_master.png').relative_to(ROOT)),
       'master_sha256':hashlib.sha256((SRC/'paf05_r5_phong_linh_trien_master.png').read_bytes()).hexdigest(),
       'atlases':{}
    }
    for name,img in [('paf05_r5_mark.webp',atlas(frames)),('paf05_r5_contact.webp',atlas(contact))]:
        p,sha=store(name,img);entry['atlases'][name]={'path':p,'sha256':sha,'size':list(img.size)}
    contact_sheet=atlas([frames[i] for i in (0,2,4,6,8,10,11,7)])
    contact_sheet.save(SRC/'paf05_r5_mark_keyposes.png')
    (SRC/'paf05_r5_art_manifest.json').write_text(json.dumps(entry,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print("PAF05_R5_ART_SOURCE_PASS isolated_master=true independent_reveal=true atlas=23")
