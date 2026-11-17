#!/usr/bin/env python3
"""Original reproducible CODE-PAINTED RGBA source for FIST13; NOT ImageGen/artist painted."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random, hashlib, json
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/fist13/assets/generated"
OUT.mkdir(parents=True,exist_ok=True)
N=640; CELL=320
def make(phase,index,count):
    t=index/(count-1)
    rng=random.Random(130013+index*101+len(phase)*999)
    under=Image.new("RGBA",(N,N))
    pigment=Image.new("RGBA",(N,N))
    core=Image.new("RGBA",(N,N))
    a=ImageDraw.Draw(under,"RGBA"); b=ImageDraw.Draw(pigment,"RGBA"); c=ImageDraw.Draw(core,"RGBA")
    reach=(28+84*t if phase=="charge" else 126-79*t if phase=="contact" else 52+3*math.sin(t*math.tau))
    count_veins=6 if phase!="contact" else 7
    for k in range(count_veins):
        theta=math.tau*k/count_veins + .20*math.sin(k*2.1+t*3)
        pts=[]
        for j,r in enumerate([reach,reach*.72,reach*.42,8]):
            twist=theta + (j-1.5)*(.17 if phase=="charge" else -.095)+.10*math.sin(t*4+k+j*2)
            pts.append((int((160+r*math.cos(twist))*2),int((160+.73*r*math.sin(twist))*2)))
        for painter,width,color in ((a,17,(91,9,40,55)),(b,8,(204,29,75,171)),(c,2,(255,208,191,225))):
            for j in range(3):
                thick=max(1,round(width*(.95-.19*j)))
                painter.line((pts[j],pts[j+1]),fill=color,width=thick,joint="curve")
        # asymmetrical vein bifurcation, not regular radial HUD rays
        if k in (0,2,5):
            p=pts[1];q=pts[2];end=pts[3]
            b.line((p,((p[0]+q[0])//2+17,(p[1]+q[1])//2-24),end),fill=(230,40,84,109),width=3)
    scale=(.42+.65*t if phase=="charge" else 1.0+.2*math.sin(t*math.pi) if phase=="contact" else .68+.05*math.sin(t*math.tau))
    scar=[(146,125),(169,143),(154,160),(178,184)]
    scar=[(int((160+(x-160)*scale)*2),int((160+(y-160)*scale)*2)) for x,y in scar]
    a.line(scar,fill=(63,4,34,154),width=24,joint="curve")
    b.line(scar,fill=(232,30,79,229),width=12,joint="curve")
    c.line(scar,fill=(255,230,215,224),width=3,joint="curve")
    for j in range(48):
        ang=rng.uniform(0,math.tau); r=rng.uniform(6,reach*.84)
        x=int((160+r*math.cos(ang))*2);y=int((160+r*.75*math.sin(ang))*2)
        rad=rng.randrange(1,4)
        b.ellipse((x-rad,y-rad,x+rad,y+rad),fill=(242,58,101,rng.randrange(25,110)))
    glow=under.filter(ImageFilter.GaussianBlur(27))
    glow.putalpha(glow.getchannel("A").point(lambda x: min(100,round(x*.65))))
    blur=pigment.filter(ImageFilter.GaussianBlur(10))
    result=Image.alpha_composite(glow,under)
    result=Image.alpha_composite(result,blur)
    result=Image.alpha_composite(result,pigment)
    result=Image.alpha_composite(result,core)
    return result.resize((CELL,CELL),Image.Resampling.LANCZOS)
stats={}
for name,total in (("charge",8),("contact",12),("mark",8)):
    sheet=Image.new("RGBA",(1280,320*((total+3)//4)))
    fingerprints=[]
    for index in range(total):
        tile=make(name,index,total)
        alpha=tile.getchannel("A")
        assert alpha.getextrema()[0]==0 and alpha.getextrema()[1]>180
        assert sum(px>36 for px in alpha.getdata())>300
        sheet.alpha_composite(tile,((index%4)*CELL,(index//4)*CELL))
        fingerprints.append(hashlib.sha256(tile.tobytes()).hexdigest())
    assert len(set(fingerprints))==total
    file=OUT/("f13_"+name+".png")
    sheet.save(file,optimize=True)
    stats[name]={"frames":total,"size":list(sheet.size),"sha256":hashlib.sha256(file.read_bytes()).hexdigest()}
make("contact",5,12).save(OUT/"f13_original_code_painted_hero.png",optimize=True)
(OUT/"f13_art_source_manifest.json").write_text(json.dumps({"art_source":"code","method":"first-party original Pillow alpha painting","frame_manifest":stats,"not_imagegen":True,"not_godot_evidence":True,"no_rig":True,"no_gif":True},indent=2),encoding="utf-8")
print("FIST13_BAKE_PASS frames=28 pages=3 code_art=true no_gif=true no_rig=true")
