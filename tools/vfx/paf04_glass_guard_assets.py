#!/usr/bin/env python3
"""PAF04 Hộ Mệnh Lưu Văn: FIRST-PARTY translucent GLASS-energy GUARD.
Original supersampled RGBA crystal petals, caustic reflections, pearlescent silk.
One moving SELF target, not a projectile, attack or status writer. NO rig, NO GIF.
All source layers and frames reproducible at exact Git SHA.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import math,random,hashlib
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'godot/labs/combat_lab/talisman14'
ASSET=BASE/'assets';SOURCE=BASE/'art_sources'
S=2
def pt(p):return [(round(x*S),round(y*S)) for x,y in p]
def b3(a,b,c,d,n=42):
    pts=[]
    for k in range(n+1):
        t=k/n;u=1-t
        pts.append((u**3*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t**3*d[0],
                    u**3*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t**3*d[1]))
    return pts
def new(w,h):return Image.new('RGBA',(w*S,h*S))
def L(d,pts,c,w=1):
    d.line(pt(pts),fill=c,width=max(1,round(S*w)),joint='curve')
def glow(dst,layer,blur=7,power=.2):
    b=layer.filter(ImageFilter.GaussianBlur(S*blur))
    b.putalpha(b.getchannel('A').point(lambda a:int(a*power)))
    dst.alpha_composite(b);dst.alpha_composite(layer)
def final(image,w,h):return image.resize((w,h),Image.Resampling.LANCZOS)
def shard(d,outline,shade=0,detail=0,front=False):
    # Thin cyan body is deliberately transmissive; bright gold only on facets.
    d.polygon(pt(outline),fill=(39+int(shade*9),214,190,36 if front else 51))
    L(d,outline+[outline[0]],(108,249,233,111 if front else 139),1.5)
    d.line(pt([outline[0],outline[1]]),fill=(255,237,170,185),width=S*2)
    d.line(pt([outline[1],outline[2]]),fill=(245,252,235,123),width=S)
    a,b,c,e=outline[:4]
    L(d,[a,((a[0]+c[0])/2+detail,(a[1]+c[1])/2),c],(241,255,238,69),.9)
    L(d,[b,((b[0]+e[0])/2-detail,(b[1]+e[1])/2),e],(77,242,212,91),1.0)
def charge(i,n=12):
    q=i/max(n-1,1);out=new(320,320)
    threads=new(320,320);d=ImageDraw.Draw(threads,'RGBA')
    # Inward-folding crystal silk with an irregular organic crest, not HUD geometry.
    for k in range(5):
        t=k-2
        curl=14*math.sin(4.2*q+t*.7)
        p=b3((159+13*t,233),(80+18*k,201+curl),
             (226-21*k,110-31*q),(150+15*t,82-23*q))
        L(d,p,(47,240,208,73+k*14),4.7 if k==2 else 2.3)
        L(d,p,(255,244,192,102 if k==2 else 64),.8)
    glow(out,threads,10,.21)
    shards=new(320,320);d=ImageDraw.Draw(shards,'RGBA')
    for k in range(7):
        a=-math.pi*.52+k*.52+q*.24
        r=(18+64*q)*(.72+.18*math.sin(k+q*3))
        cx=160+math.cos(a)*r;cy=162+math.sin(a)*r
        wd=8+9*q
        poly=[(cx-5,cy-2),(cx+wd,cy-16-q*8),
              (cx+wd*.64,cy+wd*.8),(cx-7,cy+12)]
        shard(d,poly,shade=q,detail=k)
    glow(out,shards,8,.19)
    d=ImageDraw.Draw(out,'RGBA')
    for k in range(18):
        theta=k*2.39996+q*3
        r=20+58*(k/17)
        xx=160+r*math.cos(theta);yy=157+r*.69*math.sin(theta)
        rad=.5+1.2*math.sin(k*2.4)**2
        d.ellipse(pt([(xx-rad,yy-rad),(xx+rad,yy+rad)]),
                  fill=(249,255,218,150 if k%3==0 else 70))
    return final(out,320,320)
def shell(i,n=16,front=False):
    """Organic liquid-crystal protection: transparent flowing ribbons, not rings/UI."""
    q=i/max(1,n-1)
    out=new(352,448)
    # Very low-opacity refractive surface: performer is visible through every layer.
    m=Image.new('L',(352*S,448*S),0)
    ImageDraw.Draw(m).ellipse(pt([(73,109),(288,369)]),fill=25 if not front else 9)
    body=Image.new('RGBA',m.size,(42,225,201,0))
    body.putalpha(m.filter(ImageFilter.GaussianBlur(19*S)))
    out.alpha_composite(body)
    # Seven differently authored silk-glass ribbons wrap around the self character.
    paths=[
        ((151,125),(97,129),(63,198),(98,311),25),
        ((196,119),(250,150),(301,200),(254,314),30),
        ((103,166),(130,95),(213,100),(242,162),22),
        ((92,293),(117,355),(160,372),(194,342),24),
        ((256,284),(252,347),(198,367),(174,341),23),
        ((111,216),(147,179),(202,182),(247,230),12),
        ((243,246),(199,267),(150,265),(108,252),10),
    ]
    paint=new(352,448);d=ImageDraw.Draw(paint,'RGBA')
    for k,(a,b,c,e,width) in enumerate(paths):
        if front and k in (2,5,6):continue
        if not front and k in (3,4):continue
        sway=7*math.sin(q*5+k*.9)
        a=(a[0]+sway*.2,a[1])
        b=(b[0]+sway*.55,b[1]+4*math.sin(q*5+k))
        c=(c[0]-sway*.4,c[1]-4*math.cos(q*4+k))
        e=(e[0]-sway*.2,e[1])
        arc=b3(a,b,c,e,44)
        left=[];right=[]
        for j,(x,y) in enumerate(arc):
            z=j/max(1,len(arc)-1)
            prev=arc[max(0,j-1)];nxt=arc[min(len(arc)-1,j+1)]
            vx=nxt[0]-prev[0];vy=nxt[1]-prev[1]
            length=max(.01,math.hypot(vx,vy))
            thick=width*(.12+.88*math.sin(z*math.pi)**.75)
            thick*=1+.12*math.sin(z*13+q*6+k)
            dx=-vy/length*thick;dy=vx/length*thick
            left.append((x+dx,y+dy))
            right.append((x-dx*.54,y-dy*.54))
        d.polygon(pt(left+right[::-1]),fill=(49,224,201,39 if front else 61))
        L(d,left,(181,255,234,170 if not front else 133),2.1)
        L(d,right,(71,239,215,93),1.0)
        L(d,arc,(253,234,169,114 if k%3==0 else 67),1.1)
        for j in (12,29):
            xx,yy=arc[j]
            d.ellipse(pt([(xx-1.7,yy-1.7),(xx+1.7,yy+1.7)]),
                      fill=(251,251,222,164))
    glow(out,paint,11,.27)
    dust=new(352,448);d=ImageDraw.Draw(dust,'RGBA')
    rng=random.Random(7819+i)
    for k in range(47):
        x=rng.uniform(92,264);y=rng.uniform(129,347)
        dis=((x-176)/105)**2+((y-238)/125)**2
        if dis<.38:continue
        length=rng.uniform(2,8)
        L(d,[(x-length*.6,y+3),(x,y-3),(x+length,y-6)],
          (221,255,224,rng.randint(54,134)),.85)
        if k%9==0:d.ellipse(pt([(x-1,y-1),(x+1,y+1)]),
                           fill=(255,232,166,178))
    glow(out,dust,5,.17)
    return final(out,352,448)
def impact(i,n=14):
    q=i/max(n-1,1);out=new(320,320)
    # A shield *locking*, not an attack impact. Uneven crystal leaf petals
    # pivot upward around a warm energy core, with no screen-space HUD circle.
    skin=new(320,320);d=ImageDraw.Draw(skin,'RGBA')
    for j in range(9):
        a=-math.pi/2+(j-4)*.41
        rad=(25+110*math.sin(min(1,q*1.22)*math.pi*.74))*(.73+.20*math.sin(j*2.1))
        cx=160+rad*math.cos(a);cy=169+rad*.84*math.sin(a)
        dx=math.cos(a);dy=math.sin(a)
        tip=(cx,cy)
        start=(160+8*dx,169+8*dy)
        p=b3(start,(153+rad*.7*dx,164-24+rad*.3*dy),
             (tip[0]-dx*12,tip[1]-dy*13),tip,24)
        p+=b3(tip,(tip[0]+12,tip[1]+15),
              (148+rad*.2*dx,174+rad*.5*dy),start,20)
        d.polygon(pt(p),fill=(57,227,205,55+int(16*math.sin(q*math.pi))))
        L(d,p,(135,251,234,122),1.6)
        L(d,b3(start,(148+rad*.4*dx,145+rad*.3*dy),
               (tip[0]-9,tip[1]+7),tip),(247,247,215,138),.9)
    glow(out,skin,15,.21)
    rays=new(320,320);d=ImageDraw.Draw(rays,'RGBA')
    for k in range(14):
        ang=k*2.399963+q*.72
        r=(18+95*q)*(.52+.45*math.sin(k*3.1)**2)
        cx=160+r*math.cos(ang);cy=166+r*.7*math.sin(ang)
        length=6+11*math.sin(k*.91)**2
        L(d,[(cx-length*.7,cy+5),(cx,cy-4),
              (cx+length,cy-11)],(255,239,178,125),1.4)
    d.ellipse(pt([(153,157),(169,174)]),fill=(246,255,235,170))
    glow(out,rays,10,.16)
    return final(out,320,320)
def glint(i,n=8):
    q=i/max(n-1,1);out=new(256,256);d=ImageDraw.Draw(out,'RGBA')
    for j in range(25):
        a=j*2.4+q*1.9;r=(31+77*j/25)+22*q
        cx=128+r*math.cos(a);cy=143+r*.7*math.sin(a)-31*q
        length=4+9*math.sin(j*1.6)**2
        coords=[(cx-length*.8,cy+4),(cx,cy-3),(cx+length,cy-6)]
        L(d,coords,(133,253,225,round(155*(1-q*.6))),1.4)
        L(d,[(cx,cy-3),(cx+length*.4,cy-6)],
          (249,240,185,round(120*(1-q*.5))),.7)
    return final(out,256,256)
def badge(i,n=8):
    q=i/max(n-1,1);out=new(128,128)
    d=ImageDraw.Draw(out,'RGBA')
    # Compact persistent status motif; NOT a four-second animated cast.
    coords=[(62,21),(86,30),(102,59),(84,94),(62,111),(37,91),(24,57),(40,29)]
    # A compact independent 8-pose shimmer, not eight duplicate static GIF frames.
    pulse=.72+.28*math.sin(2*math.pi*q+.3)
    shift=3.5*math.sin(2*math.pi*q)
    coords=[(x+shift,y+1.7*math.sin(2*math.pi*q+y*.05)) for x,y in coords]
    d.polygon(pt(coords),fill=(42,178,154,round(45*pulse)))
    L(d,coords+[coords[0]],(104,246,224,round(142*pulse)),1.8)
    L(d,[(61+shift,30),(77+shift*.5,52),(64,83),(51-shift*.4,65),(61+shift,30)],
      (252,237,171,round(203*pulse)),1.8)
    return final(out,128,128)
def atlas(frames,w,h):
    im=Image.new('RGBA',(4*w,h*((len(frames)+3)//4)))
    for k,f in enumerate(frames): im.alpha_composite(f,((k%4)*w,(k//4)*h))
    return im

# R4: A physically *advected 2D energy field*, not rigid sprite motion.
# Multiple independently moving luminous packets travel along six nonuniform
# light paths. Painted true-RGBA layers are source-preserved; no skeletal rig.
def r4_ribbon(d,points,q,k,front=False):
    e1=[];e2=[]
    for j,(x,y) in enumerate(points):
        u=j/max(1,len(points)-1)
        before=points[max(0,j-1)];after=points[min(len(points)-1,j+1)]
        vx=after[0]-before[0];vy=after[1]-before[1]
        norm=max(.001,math.hypot(vx,vy));nx=-vy/norm;ny=vx/norm
        wave=math.sin(9.5*u-6.5*q+k*.80)
        span=(3.0+5.0*math.sin(math.pi*u)**.65)*(1+.22*wave)
        if front:span*=.60
        e1.append((x+nx*span,y+ny*span))
        e2.append((x-nx*span*.65,y-ny*span*.65))
    d.polygon(pt(e1+e2[::-1]),fill=(27,224,206,20 if front else 30))
    L(d,e1,(184,255,238,153 if front else 182),2.55)
    L(d,e2,(52,242,220,90 if front else 112),1.35)
    # The luminous energy MOVES INSIDE the shape every authored frame.
    for m in range(5):
        u=(m*.175+.17*q+k*.137)%1
        width=.038+.026*(m%3)
        a=max(0,int((u-width)*(len(points)-1)))
        b=min(len(points)-1,int((u+width)*(len(points)-1)))
        if b>a:
            col=(255,239,172,205 if not front else 162) if m%2==0 else (243,255,242,231 if not front else 178)
            L(d,points[a:b+1],col,3.25 if m%3==0 else 2.0)
            x,y=points[b]
            d.ellipse(pt([(x-1.7,y-1.7),(x+1.7,y+1.7)]),
                      fill=(255,247,214,232 if not front else 190))

def r4_shell(i,n=16,front=False):
    q=i/max(1,n-1)
    out=new(352,448)
    # Optical field is very thin. No opaque disc, rigid leaf or perfect ring.
    field=new(352,448);d=ImageDraw.Draw(field,'RGBA')
    d.ellipse(pt([(91,130),(265,353)]),fill=(61,224,203,7 if front else 11))
    glow(out,field,24,.25)
    lanes=[
      ((137,330),(93,289),(95,218),(137,187)),
      ((221,329),(274,284),(264,226),(219,188)),
      ((123,223),(105,150),(176,118),(223,151)),
      ((116,322),(142,347),(198,359),(239,318)),
      ((103,261),(125,244),(137,222),(147,205)),
      ((237,267),(221,244),(209,222),(199,203)),
    ]
    light=new(352,448);d=ImageDraw.Draw(light,'RGBA')
    for k,(a,b,c,e) in enumerate(lanes):
        if front and k in (2,4,5):continue
        if not front and k==3:continue
        energy=math.sin(q*math.tau*(.83+.09*(k%3))+.5*k)
        drift=5.0*energy
        shift=lambda z,v:(z[0]+v,z[1]+3*math.sin(q*math.tau*.8+k*.9))
        raw=b3(shift(a,drift*.5),shift(b,drift*.8),
               shift(c,-drift*.8),shift(e,-drift*.4),76)
        pts=[(x+3.8*math.sin(j*.16-q*math.tau*1.85+k*1.23)*math.sin(j/76*math.pi),
              y+2.6*math.cos(j*.14-q*math.tau*1.53+k*.72)*math.sin(j/76*math.pi))
             for j,(x,y) in enumerate(raw)]
        # A STREAM materializes as a travelling front. The whole shield
        # NEVER appears or fades as one static circular texture.
        lead=max(0.,min(1.,.13+q*1.85-k*.12))
        length=.22+.22*(.5+.5*math.sin(q*5+k*.87))
        tail=max(0.,lead-length)
        begin=max(0,int(tail*(len(pts)-1)))
        last=min(len(pts)-1,int(lead*(len(pts)-1)))
        if last>begin+3:
            r4_ribbon(d,pts[begin:last+1],q,k,front)
    glow(out,light,14,.42)
    # Irregularly timed moving particles follow the filaments, not overall scale.
    small=new(352,448);d=ImageDraw.Draw(small,'RGBA')
    rng=random.Random(9412)
    for j in range(45):
        k=j%len(lanes)
        a,b,c,e=lanes[k]
        u=(rng.random()+q*(.63+(j%6)*.094))%1
        curve=b3(a,b,c,e,60)
        x,y=curve[min(60,int(u*61))]
        x+=5*math.sin(j*.9+q*9);y+=6*math.cos(j*.43-q*11)
        r=.45+1.05*(j%4)/3
        color=(238,255,216,110+j%3*21) if j%4 else (255,229,152,170)
        d.ellipse(pt([(x-r,y-r),(x+r,y+r)]),fill=color)
        if j%11==0:L(d,[(x-5,y+3),(x+4,y-4)],(223,255,234,123),.7)
    glow(out,small,7,.32)
    return final(out,352,448)

def r4_charge(i,n=12,size=320):
    """Energy condenses at the caster's palms, not a symmetric tentacle crown."""
    q=i/max(1,n-1)
    out=new(320,320);paths=new(320,320);d=ImageDraw.Draw(paths,'RGBA')
    lanes=[
      ((73,237),(79,185),(119,165),(163,168)),
      ((96,283),(101,227),(115,183),(163,168)),
      ((239,254),(218,200),(210,152),(163,168)),
      ((233,117),(197,98),(174,132),(163,168)),
      ((121,100),(109,131),(150,150),(163,168)),
    ]
    for k,(a,b,c,e) in enumerate(lanes):
        drift=16*math.sin(q*6+k*1.23)
        curve=b3((a[0]+drift,a[1]),(b[0]+drift*.50,b[1]-5*math.sin(q*5+k)),
                 (c[0]-drift*.3,c[1]),e,72)
        # Spiraling internal light rushes inward with its own velocity.
        L(d,curve,(35,226,198,105),4.0)
        L(d,curve,(124,255,226,129),1.4)
        for z in range(2):
            u=(q*.72+k*.19+z*.31)%1
            x,y=curve[int(u*(len(curve)-1))]
            rr=1.3+2.0*(1-q*.4)
            d.ellipse(pt([(x-rr,y-rr),(x+rr,y+rr)]),
                      fill=(253,252,214,206))
            idx=int(u*72)
            L(d,curve[max(0,idx-3):min(73,idx+4)],
              (251,245,213,197),2.5)
    glow(out,paths,13,.39)
    return final(out,size,size)

def r4_lock(i,n=14,size=320):
    q=i/max(1,n-1)
    out=new(320,320);energy=new(320,320);d=ImageDraw.Draw(energy,'RGBA')
    # Directed crest of white-gold light flows across self, not petals/flower.
    for k in range(8):
        a=-2.8+k*.71+.14*q
        r=18+87*math.sin(q*math.pi*.79)*(.7+.26*math.sin(k+1.2)**2)
        origin=(160+4*math.cos(a),164+4*math.sin(a))
        end=(160+r*math.cos(a),164+r*.78*math.sin(a))
        path=b3(origin,(160+r*.4*math.cos(a+1),151+r*.2*math.sin(a)),
                (end[0]+12,end[1]-13),end,48)
        L(d,path,(45,237,207,123),5.4)
        L(d,path,(248,255,229,208),2.4)
        j=int((.5+.38*math.sin(q*9+k))*48)
        x,y=path[j]
        d.ellipse(pt([(x-2,y-2),(x+2,y+2)]),fill=(255,243,183,178))
    d.ellipse(pt([(152,156),(168,172)]),fill=(250,255,231,165))
    glow(out,energy,15,.38)
    return final(out,size,size)

def main():
    ASSET.mkdir(parents=True,exist_ok=True); SOURCE.mkdir(parents=True,exist_ok=True)
    r4_shell(9,front=False).resize((704,896),Image.Resampling.LANCZOS).save(SOURCE/'paf04_pearlescent_glass_shield_master.png')
    r4_charge(7).resize((640,640),Image.Resampling.LANCZOS).save(SOURCE/'paf04_condensing_crystal_master.png')
    all={
      'paf04_charge.webp':(atlas([r4_charge(k) for k in range(12)],320,320),12),
      'paf04_glass_back.webp':(atlas([r4_shell(k,front=False) for k in range(16)],352,448),16),
      'paf04_glass_front.webp':(atlas([r4_shell(k,front=True) for k in range(16)],352,448),16),
      'paf04_lock.webp':(atlas([r4_lock(k) for k in range(14)],320,320),14),
      'paf04_shimmer.webp':(atlas([glint(k) for k in range(8)],256,256),8),
      'paf04_badge.webp':(atlas([badge(k) for k in range(8)],128,128),8),
    }
    for name,(image,frames) in all.items():
        p=ASSET/name;image.save(p,'WEBP',quality=92,method=4,exact=True)
        print('PAF04_ATLAS',name,frames,image.size,hashlib.sha256(p.read_bytes()).hexdigest())
    print('PAF04_ORIGINAL_GLASS_RGBA_BAKE_PASS')
    print('PAF04_R4_ADVECTED_LIGHT_ATLAS_PASS')
    print('PAF04_R5_FLOW_CAUSTIC_SHADER_SOURCE_PASS')
    print('PAF04_R6_PROGRESSIVE_FLOW_FORM_AND_RELEASE_PASS')
if __name__=='__main__':main()
