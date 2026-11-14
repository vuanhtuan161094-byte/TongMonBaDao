#!/usr/bin/env python3
"""Original first-party painted raster flipbooks for POI07. Pillow-only; not third-party pixels."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math, random
OUT=Path(__file__).resolve().parents[2]/"godot/labs/combat_lab/poison07/assets"
OUT.mkdir(parents=True,exist_ok=True)
def stroke(im, pts, color, width):
    layer=Image.new("RGBA",im.size)
    d=ImageDraw.Draw(layer,"RGBA")
    for j in range(len(pts)-1):
        d.line([pts[j],pts[j+1]],fill=color,width=max(1,int(width*(1-0.65*j/len(pts)))))
    return Image.alpha_composite(im,layer)
def needle(i):
    W,H=384,192
    r=random.Random(2719+i*173)
    im=Image.new("RGBA",(W,H))
    q=[.36,.50,.66,.84,1.0,.95,1.08,1.1,.96,.82,.52,.24][i]
    fade=[.62,.79,.90,1,1,1,1,1,.98,.84,.63,.30][i]
    ax=94+3*math.sin(i*.8)
    tail=50+86*(1-q)
    head=331-9*math.sin(i*.7)
    shaft=tail+18
    span=max(35,head-shaft)
    for k in range(13):
        p=[]
        x0=r.uniform(18,shaft+10)
        x1=r.uniform(shaft+40,head)
        dy=r.uniform(-30,30)
        for j in range(32):
            t=j/31
            x=x0+(x1-x0)*t
            y=ax+(1-t)*dy+7*(1-t)*math.sin(t*15+k*2.1+i*.76)+3*math.sin(t*29+k*1.4)
            p.append((int(x),int(y)))
        colors=[(34,19,70,int(120*fade)),(63,169,151,int(98*fade)),(138,71,218,int(83*fade)),(119,239,193,int(58*fade))]
        im=stroke(im,p,colors[k%4],3 if k%3 else 2)
    metal=Image.new("RGBA",(W,H))
    d=ImageDraw.Draw(metal,"RGBA")
    silhouette=[(shaft,ax-3),(shaft+span*.18,ax-8*q),(shaft+span*.43,ax-16*q),
        (shaft+span*.78,ax-8*q),(head,ax),(shaft+span*.75,ax+9*q),
        (shaft+span*.40,ax+14*q),(shaft+span*.16,ax+7*q)]
    d.polygon(silhouette,fill=(31,23,64,int(254*fade)))
    glow=metal.filter(ImageFilter.GaussianBlur(10))
    glow.putalpha(glow.getchannel("A").point(lambda v:int(v*.55)))
    im=Image.alpha_composite(im,glow)
    im=Image.alpha_composite(im,metal.filter(ImageFilter.GaussianBlur(2)))
    im=Image.alpha_composite(im,metal)
    d=ImageDraw.Draw(im,"RGBA")
    d.polygon([(shaft+6,ax-2),(shaft+span*.4,ax-11*q),
        (shaft+span*.79,ax-6*q),(head,ax),(shaft+span*.54,ax+1)],
        fill=(125,92,181,int(240*fade)))
    d.polygon([(shaft+8,ax+1),(shaft+span*.62,ax+1),(head,ax),
        (shaft+span*.7,ax+9*q),(shaft+span*.32,ax+8*q)],
        fill=(29,35,79,int(244*fade)))
    d.polygon([(shaft+span*.28,ax-2),(shaft+span*.8,ax-2),
        (head-6,ax),(shaft+span*.64,ax+1)],
        fill=(226,255,228,int(207*fade)))
    d.line([(shaft+span*.15,ax),(head-3,ax)],fill=(246,255,242,int(217*fade)),width=2)
    for k in range(46):
        x=r.uniform(max(8,shaft-43),min(370,head+9))
        y=ax+r.uniform(-29,30)
        s=r.uniform(.6,2.6)*q
        col=[(155,251,196,int(135*fade)),(85,37,140,int(165*fade)),(220,254,224,int(113*fade))][k%3]
        d.polygon([(x-s,y+s),(x,y-s*2),(x+s,y),(x,y+s*.6)],fill=col)
    return im
def contact(i):
    W=H=256
    r=random.Random(765+i*131)
    a=[.27,.54,.82,1,.91,.71,.42,.15][i]
    cx,cy=127,139
    layer=Image.new("RGBA",(W,H))
    d=ImageDraw.Draw(layer,"RGBA")
    arms=[]
    for k in range(13):
        angle=(-.63+k*1.22/12)*math.pi+r.uniform(-.09,.09)
        rad=(21+r.uniform(17,70))*a
        x=cx+math.cos(angle)*rad
        y=cy+math.sin(angle)*rad*.72
        mid=(cx+(x-cx)*.55+r.uniform(-8,8),cy+(y-cy)*.5+r.uniform(-5,5))
        pts=[(cx,cy),mid,(x,y)]
        arms.append(pts)
        d.line(pts,fill=(90,236,182,int(155*a)),width=5 if k%3 else 8)
    glow=layer.filter(ImageFilter.GaussianBlur(7))
    glow.putalpha(glow.getchannel("A").point(lambda v:int(v*.6)))
    im=Image.alpha_composite(glow,layer)
    d=ImageDraw.Draw(im,"RGBA")
    for pts in arms:
        d.line(pts,fill=(239,255,228,int(225*a)),width=2)
    for k in range(25):
        theta=r.random()*math.tau
        rad=r.uniform(5,67)*a
        x=cx+math.cos(theta)*rad
        y=cy+math.sin(theta)*rad*.7
        s=r.uniform(.9,3.8)*a
        d.polygon([(x-s,y),(x,y-s*2),(x+s,y+s)],fill=(145,250,208,int(170*a)))
    return im
def atlas(frames,size,cols,name):
    w,h=size
    out=Image.new("RGBA",(w*cols,h*((len(frames)+cols-1)//cols)))
    for i,frm in enumerate(frames):
        a=frm.getchannel("A")
        assert a.getbbox(),("empty",i)
        for rect in [(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)]:
            assert a.crop(rect).getextrema()[1]==0,("bad alpha",name,i,rect)
        out.alpha_composite(frm,((i%cols)*w,(i//cols)*h))
    path=OUT/name
    out.save(path,compress_level=9,optimize=True)
    print(name,out.size,path.stat().st_size)
if __name__=="__main__":
    atlas([needle(i) for i in range(12)],(384,192),4,"doc_cham_needle_12.png")
    atlas([contact(i) for i in range(8)],(256,256),4,"doc_cham_contact_08.png")
