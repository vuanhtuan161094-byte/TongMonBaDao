#!/usr/bin/env python3
"""PAF07 Dưỡng Phù Quy Nguyên – first-party transparent sprite keys.
Always-on hand-held jade essence condensing into a golden pearl/fulu knot.
24 independently authored brush/light key-poses; no cast, hit, glyph billboard,
three spinning papers or whole-image UV/sine-wave displacement.
"""
from PIL import Image,ImageDraw,ImageFilter
from pathlib import Path
import math,hashlib,json
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/"godot/labs/combat_lab/talisman17"
ASSETS=BASE/"assets";SOURCE=BASE/"art_sources"
ASSETS.mkdir(parents=True,exist_ok=True);SOURCE.mkdir(parents=True,exist_ok=True)
N=256;S=3;Z=N*S;TOTAL=24;COLS=6;TAU=math.tau
JADE=(37,214,167);GOLD=(247,200,108);HOT=(239,255,229)
def blank():return Image.new("RGBA",(Z,Z),(0,0,0,0))
def pts(a):return [(round(x*S),round(y*S)) for x,y in a]
def bez(a,b,c,d,count=48):
    return [((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0],
             (1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1])
            for t in [j/(count-1) for j in range(count)]]
def layer_line(layer,curve,tint,width):
    d=ImageDraw.Draw(layer,"RGBA")
    d.line(pts(curve),fill=tint,width=max(1,round(width*S)),joint="curve")
def compose(base,layer,r=4,strength=.22):
    h=layer.filter(ImageFilter.GaussianBlur(r*S))
    h.putalpha(h.getchannel("A").point(lambda a:int(a*strength)))
    base.alpha_composite(h);base.alpha_composite(layer)
def frame(index):
    t=index/TOTAL
    out=blank();shell=blank()
    d=ImageDraw.Draw(shell,"RGBA")
    # A contained upward-pointing pearl/bud silhouette, not a card or flat UI circle.
    center=(128.,135.);pulse=.5-.5*math.cos(TAU*t)
    size=1.0+.045*pulse
    L=(128-19*size,126);R=(128+18*size,127);tip=(128,94-3*pulse)
    low=(128,163+2*pulse)
    left=bez(low,(105,159),(101,115),tip)
    right=bez(tip,(154,113),(153,159),low)
    d.polygon(pts(left+right),fill=(*JADE,87+23*round(pulse)))
    layer_line(shell,left,(*GOLD,161),2.0)
    layer_line(shell,right,(*GOLD,144),1.7)
    layer_line(shell,bez(low,(127,142),(119,114),tip),(*HOT,190),1.9)
    # Three gold ritual knotlets give the skill its own recognisable silhouette.
    for k,(x,y) in enumerate([(116,109),(143,115),(128,162)]):
        m=3.6+(1.1 if k==int(t*3)%3 else 0)
        d.line(pts([(x-m,y),(x+m,y)]),fill=(*GOLD,145),width=2*S)
        d.line(pts([(x,y-m*.7),(x,y+m*.7)]),fill=(*HOT,215),width=1*S)
    # Carved pearl shows a soft white core within the little green bud.
    d.ellipse(((124-3*pulse)*S,(127-3*pulse)*S,(132+3*pulse)*S,(135+3*pulse)*S),
              fill=(*HOT,215))
    compose(out,shell,r=5,strength=.26)
    # Two energetic stream heads advance TO the central rune. Their trajectory
    # is coherent and directional. No warping of a complete pasted image.
    for arm in range(2):
        path=blank()
        for segment in range(24):
            q=(segment+.5)/24
            u=(q+(t*1.6)+arm*.48)%1.0
            theta=(arm+.2)*math.pi+u*math.pi*1.8
            radius=83*(1-u)+20*u
            x=center[0]+math.cos(theta)*radius
            y=center[1]+math.sin(theta)*radius*.62
            tangent=theta+.12
            width=3.8*(1-u)+.65
            opacity=round(190*math.sin(math.pi*q)**.7)
            ImageDraw.Draw(path,"RGBA").ellipse(((x-width)*S,(y-width)*S,(x+width)*S,(y+width)*S),
                           fill=(*(JADE if arm==0 else GOLD),opacity))
        compose(out,path,r=4,strength=.18)
    # Several particles move up from a narrow beam; no circular shield.
    sparks=blank();sd=ImageDraw.Draw(sparks,"RGBA")
    for k in range(9):
        u=(t+k*.287)%1
        x=128+math.sin(k*2.3+u*5)*24
        y=165-97*u
        r=.45+1.5*math.sin(math.pi*u)
        a=round(168*math.sin(math.pi*u))
        sd.ellipse(((x-r)*S,(y-r)*S,(x+r)*S,(y+r)*S),
                   fill=(*(HOT if k%3 else GOLD),a))
    compose(out,sparks,r=2,strength=.25)
    return out.resize((N,N),Image.Resampling.LANCZOS)
def save(path,im):
    path.parent.mkdir(parents=True,exist_ok=True)
    if path.suffix==".webp":im.save(path,format="WEBP",lossless=True,method=5)
    else:im.save(path)
    return {"path":str(path.relative_to(ROOT)),"sha256":hashlib.sha256(path.read_bytes()).hexdigest(),"dimensions":[im.width,im.height]}
if __name__=="__main__":
    frames=[frame(i) for i in range(TOTAL)]
    atlas=Image.new("RGBA",(N*COLS,N*4))
    for i,f in enumerate(frames):atlas.alpha_composite(f,((i%COLS)*N,(i//COLS)*N))
    man={"schema":"PAF07_R1_FIRST_PARTY_SPIRIT_NOURISH_SPRITE","skill_id":"tmb.skill.talisman.phong_an_phu.passive_02.human",
         "passive":"ALWAYS_ON_NO_CAST_OR_HIT","frames":TOTAL,"columns":COLS,"cell":N,
         "master":save(SOURCE/"paf07_quy_nguyen_master.png",frames[0]),
         "atlas":save(ASSETS/"paf07_quy_nguyen_24.webp",atlas)}
    (SOURCE/"PAF07_R1_MANIFEST.json").write_text(json.dumps(man,indent=2,ensure_ascii=False)+"\n",encoding="utf8")
    print("PAF07_R1_ORIGINAL_RGBA_PASS poses=24 first_party=true passive_always_on=true")
