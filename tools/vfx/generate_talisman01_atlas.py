#!/usr/bin/env python3
"""Original hand-authored/procedural painted 12-pose xianxia thunder talisman atlas.
No extracted commercial assets. Deterministic design; Pillow >=9; alpha transparent.
Source size 300x360, sheet 3x4. Each pose bends paper and changes illuminated ink.
"""
from PIL import Image, ImageDraw, ImageFilter
from math import sin, cos, pi
from pathlib import Path
import random, sys
S=3
W,H=300,360
N=12
rng=random.Random(740915)

def P(x,y):return (round(x*S),round(y*S))
def poly(d,points,fill,outline=None,width=1):
    d.polygon([P(x,y) for x,y in points],fill=fill)
    if outline:d.line([P(x,y) for x,y in points+[points[0]]], fill=outline,width=width*S,joint='curve')
def line(d, pts, col, wd=1, joint='curve'):
    d.line([P(x,y) for x,y in pts],fill=col,width=max(1,round(wd*S)),joint=joint)

def wave_point(x,y,f,p):
    h=(y-38.)/286.
    phase=f/12.*pi*2
    return (x+4.9*sin(h*2*pi+phase)*h+3.1*sin(h*3.2+phase*.6), y+1.7*cos(h*2.1+phase)*h)

def fpoly(d,points,frame,fill,outline=None,width=1):
    poly(d,[wave_point(x,y,frame,0) for x,y in points],fill,outline,width)

def fline(d,points,frame,col,wd=1):
    line(d,[wave_point(x,y,frame,0) for x,y in points],col,wd)

def frame_img(k):
    rng=random.Random(1020)
    im=Image.new('RGBA',(W*S,H*S),(0,0,0,0))
    edge=Image.new('RGBA',im.size,(0,0,0,0)); ed=ImageDraw.Draw(edge,'RGBA')
    # Intentionally irregular silhouette, irregular cut fibers; no simple rectangle.
    contour=[(93,30),(113,26),(151,23),(181,26),(206,32),(211,41),(208,85),(212,135),(207,181),(211,229),(205,274),(200,298),(183,313),(162,302),(148,315),(132,301),(116,319),(106,305),(91,299),(94,266),(87,219),(91,175),(88,132),(94,90)]
    contour=[(x+rng.uniform(-1.4,1.4),y+rng.uniform(-1.7,1.7)) for x,y in contour]
    fpoly(ed,[(x+2,y+3) for x,y in contour],k,(11,17,35,63))
    fpoly(ed,contour,k,(207,174,111,254),(79,47,33,225),2)
    # parchment inner feather-edge colored strata
    fpoly(ed,[(101,40),(151,35),(198,39),(198,262),(188,296),(163,291),(149,302),(132,290),(112,304),(103,291)],k,(226,198,133,239))
    fpoly(ed,[(109,46),(149,40),(192,47),(191,269),(178,292),(159,288),(147,296),(131,288),(113,294),(110,272)],k,(236,207,147,247))
    im.alpha_composite(edge)
    d=ImageDraw.Draw(im,'RGBA')
    # Layered hand-painted paper fibers; bounded inside x 109..191 and y 50..289.
    for j in range(2000):
        x=rng.uniform(110,191); y=rng.uniform(49,288)
        if y>283 and (x<118 or x>183):continue
        xx,yy=wave_point(x,y,k,0)
        length=rng.uniform(.3,3.4)
        line(d,[(xx,yy),(xx+.3*length,yy+length)],(90,57,45,rng.randint(6,23)),rng.choice([.22,.38,.50]))
    # Torn edges & umber stitched marginal hairlines
    for j in range(44):
        y=48+j*5.55
        for x in (105.2,196.2):
            xx,yy=wave_point(x+1.3*sin(j*1.7),y,k,0)
            line(d,[(xx,yy),(xx+2.3*sin(j+1),yy+2)],(85,46,35,56),.42)
    # Foil ornaments: eight discrete tiny stylized cloud motifs
    for x in (117,183):
        for y in (64,112,171,233):
            turn=-1 if x>150 else 1
            fline(d,[(x,y-8),(x+turn*5,y-3),(x+turn*3,y+2),(x+turn*7,y+6)],k,(118,71,40,164),.85)
            fline(d,[(x+turn*3,y-4),(x+turn*9,y-6),(x+turn*11,y-2)],k,(244,208,120,160),.65)
    # Original unrelated-to-real-world magical glyph geometry, brush-ink thick strokes
    sig=[[(150,55),(148,73),(161,82),(138,95)],[(133,101),(166,103),(172,112),(150,126),(129,119)],
         [(151,126),(151,146),(168,158),(145,171),(128,165)],[(144,171),(147,196),(131,207),(169,215)],
         [(165,217),(155,231),(139,235),(151,254)],[(127,254),(154,262),(174,252)],
         [(132,75),(143,84)],[(166,72),(163,87)],[(123,136),(137,138)],[(170,183),(159,195)]]
    for j,seg in enumerate(sig):
        # ink underpainting and worn gold edge
        fline(d,seg,k,(68,40,49,230),3.8 if j<6 else 2.35)
        fline(d,[(x+.55,y-.5) for x,y in seg],k,(104,57,63,210),1.45)
    # Ruby talisman seal at bottom, translucent, not recognizable commercial magic glyph
    fline(d,[(129,271),(134,281),(149,285),(164,281),(170,272),(161,266),(145,270),(129,271)],k,(137,45,47,170),2.2)
    fline(d,[(142,274),(157,278),(147,282)],k,(226,103,67,170),1.5)
    # Animated electricity spreads along brush geometry; 12 independent illuminated poses.
    charge=max(0,min(1,(k-1)/6.))
    decay=max(0,min(1,(12-k)/3.))
    energy=charge*decay
    glowing=Image.new('RGBA',im.size,(0,0,0,0)); light=ImageDraw.Draw(glowing,'RGBA')
    paths=[[(149,49),(150,76),(138,91),(163,106),(150,124),(169,154),(145,173),(166,215),(151,234),(151,261)],
           [(134,105),(121,122),(133,139),(117,160)],[(151,145),(172,140),(177,155),(166,173)],
           [(142,193),(131,222),(121,232)],[(159,234),(174,249),(169,263)]]
    reveal=max(0.0,min(1.,(k-0.8)/7.3))
    for j,points in enumerate(paths):
        reveal_j=max(0.,min(1.,reveal*(1.3 if j==0 else 1.3-(j*.08))-.07*j))
        allpoints=[wave_point(x,y,k,0) for x,y in points]
        segments=len(points)-1
        for ii in range(segments):
            if reveal_j*segments<ii:break
            q=min(1.,reveal_j*segments-ii)
            a=allpoints[ii]; b=allpoints[ii+1]
            end=(a[0]+(b[0]-a[0])*q,a[1]+(b[1]-a[1])*q)
            alpha=int(185*energy*(1 if j==0 else .55))
            line(light,[a,end],(89,75,205,alpha),7.3 if j==0 else 4.0)
            line(light,[a,end],(190,169,249,int(213*energy)),2.7 if j==0 else 1.5)
            line(light,[a,end],(252,248,255,int(245*energy)),.85)
    glow=glowing.filter(ImageFilter.GaussianBlur(6*S)); glow.putalpha(glow.getchannel('A').point(lambda x:int(x*.65)))
    im.alpha_composite(glow)
    im.alpha_composite(glowing)
    d=ImageDraw.Draw(im,'RGBA')
    # Etched aperture at top, animated fine ink gold glint; flicker only on release.
    amp=max(0,min(1,(k-3)/4)) *max(0,min(1,(12-k)/3))
    for n in range(7):
        a=n*2*pi/7+k*.06
        x=151+33*cos(a);y=151+31*sin(a)
        x,y=wave_point(x,y,k,0)
        r=0.8+amp*(1.8 if n%2==0 else .8)
        d.ellipse((*P(x-r,y-r),*P(x+r,y+r)),fill=(216,201,255,int(amp*(145 if n%2 else 205))))
    # Clean minor edge glimmer, no green/neon flat fill
    fline(d,[(103,46),(99,93),(99,145)],k,(247,217,147,60),.7)
    return im.resize((W,H),Image.Resampling.LANCZOS)

def main(out):
    sheet=Image.new('RGBA',(W*3,H*4),(0,0,0,0))
    for k in range(N):sheet.alpha_composite(frame_img(k),((k%3)*W,(k//3)*H))
    dest=Path(out);dest.parent.mkdir(parents=True,exist_ok=True)
    sheet.save(dest,optimize=True)
    print(f'TALISMAN_MASTER_ATLAS_READY {dest} {sheet.size} frames={N} frame_size={W}x{H}')
if __name__=='__main__':main(sys.argv[1] if len(sys.argv)>1 else 'godot/labs/combat_lab/talisman01/assets/thunder_talisman_atlas.png')
