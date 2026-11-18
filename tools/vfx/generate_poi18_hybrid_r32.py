#!/usr/bin/env python3
"""POI18 R3.2 - independent first-party full-cel jade gu sprite source.
16 painted key poses with explicit shapes, transparent RGBA. No rig or crops.
Godot draws only supplemental trail/particles/wrap. R2C assets immutable.
"""
from pathlib import Path
from math import sin,cos,pi
from PIL import Image,ImageDraw,ImageFilter
ROOT=Path(__file__).resolve().parents[2]/'godot/labs/combat_lab/poison18_phu_cot_co_tien_a/r32/assets'
W,H,SS=320,256,2
KEYS=[
(.18,-.12,-.16,.00,.02),(.32,-.34,-.08,.00,.14),
(.51,-.26,.02,.00,.30),(.76,-.16,.13,.00,.39),
(.99,.07,.03,.00,.52),(1.00,.27,-.10,.00,.61),
(.94,.40,-.16,.00,.36),(.97,.21,-.07,.00,.15),
(1.00,-.10,.03,.02,-.19),(.94,-.35,.13,.04,-.40),
(.90,-.22,.18,.10,-.53),(.83,.18,.08,.21,-.38),
(.78,.42,-.07,.40,-.12),(.63,.18,-.12,.57,.18),
(.51,-.18,-.03,.74,.33),(.37,-.29,.01,.91,.05)]
def bezier(a,b,c,d,n=16):
    return [((1-t)**3*a[0]+3*(1-t)**2*t*b[0]+3*(1-t)*t*t*c[0]+t**3*d[0],
             (1-t)**3*a[1]+3*(1-t)**2*t*b[1]+3*(1-t)*t*t*c[1]+t**3*d[1])
            for t in (i/n for i in range(n+1))]
def render(index):
    op,bend,ang,close,twist=KEYS[index]
    im=Image.new('RGBA',(W*SS,H*SS))
    def warp(x,y):
        s=min(1.,max(0.,-x/185.))
        xx=x*(1.0-.57*close)
        yy=y*(.40+.60*op)+bend*47*sin(pi*s)+twist*16*sin(2*pi*s)
        xx,yy=xx*cos(ang)-yy*sin(ang),xx*sin(ang)+yy*cos(ang)
        return (round((240+xx)*SS),round((120+yy)*SS))
    def curve(*anchors):
        p=[]
        for j in range(0,len(anchors)-3,3):p+=bezier(*anchors[j:j+4],n=16)[:-1]
        p.append(anchors[-1]);return [warp(*xy) for xy in p]
    def paint(coords,rgba,bloom=0):
        q=Image.new('RGBA',im.size);ImageDraw.Draw(q).polygon(coords,fill=rgba)
        if bloom:
            b=q.filter(ImageFilter.GaussianBlur(bloom*SS))
            b.putalpha(b.getchannel('A').point(lambda a:int(a*.21)))
            im.alpha_composite(b)
        im.alpha_composite(q)
    def stroke(anchors,rgba,width=1.6,bloom=0):
        q=Image.new('RGBA',im.size)
        ImageDraw.Draw(q).line(curve(*anchors),fill=rgba,width=max(1,int(width*SS)),joint='curve')
        if bloom:
            b=q.filter(ImageFilter.GaussianBlur(bloom*SS))
            b.putalpha(b.getchannel('A').point(lambda a:int(a*.29)))
            im.alpha_composite(b)
        im.alpha_composite(q)
    # Large upper and smaller lower translucent flowing jade membranes
    paint(curve((-30,-12),(-58,-45),(-106,-64),(-192,-58),(-178,-34),(-118,-17),(-61,-4)),(15,144,118,120),4.7)
    paint(curve((-36,-12),(-78,-35),(-117,-50),(-178,-49),(-150,-40),(-98,-19),(-55,-7)),(49,227,174,78))
    paint(curve((-27,14),(-61,46),(-115,29),(-164,48),(-155,20),(-91,11),(-49,2)),(12,151,129,124),3.6)
    paint(curve((-37,11),(-82,28),(-126,27),(-147,37),(-122,17),(-74,9),(-36,4)),(98,245,205,79))
    # Thick central sculpted jade body, clear head-to-body physical continuity
    paint(curve((-134,-4),(-107,-20),(-72,-22),(-53,-18),(-33,-23),(-12,-16),(0,0),(-24,20),(-62,22),(-89,12),(-108,10),(-125,2),(-134,-4)),(16,112,99,190),5)
    paint(curve((-112,-10),(-79,-24),(-39,-25),(-6,-5),(-17,10),(-54,18),(-88,9),(-106,4),(-111,-1),(-112,-10)),(29,209,169,179))
    paint(curve((-90,-10),(-66,-21),(-43,-19),(-22,-13),(-28,2),(-44,12),(-70,9),(-84,4),(-89,-4),(-90,-10)),(98,248,210,113))
    # Crystal bud/head, asymmetric gold filigree, no insect anatomy or eyes
    paint(curve((-66,-15),(-49,-22),(-29,-18),(-12,-11),(-5,-7),(-1,-2),(0,0),(-9,5),(-23,15),(-38,15),(-49,11),(-60,4),(-66,-15)),(42,186,155,209),3)
    paint(curve((-60,-15),(-36,-28),(-10,-16),(0,0),(-18,-5),(-33,-6),(-48,-2),(-48,-10),(-58,-13),(-60,-15)),(170,255,223,119))
    paint([warp(*x) for x in [(-45,-8),(-36,-17),(-21,-12),(-16,-2),(-24,11),(-39,9)]],(9,89,95,238),3)
    paint([warp(*x) for x in [(-42,-8),(-34,-15),(-25,-8),(-32,3)]],(73,232,208,207))
    paint([warp(*x) for x in [(-32,3),(-25,-8),(-18,-2),(-24,8)]],(158,255,215,198))
    paint([warp(*x) for x in [(-42,-8),(-32,3),(-39,7)]],(22,156,160,220))
    stroke([(-62,-16),(-49,-27),(-24,-22),(-4,-4)],(255,219,121,216),1.9,2)
    stroke([(-55,14),(-41,17),(-17,11),(-2,0)],(255,214,120,176),1.7,1.4)
    stroke([(-105,-12),(-78,-36),(-59,-25),(-41,-17)],(238,224,152,144),1.2,1)
    stroke([(-49,-21),(-55,-39),(-31,-40),(-13,-14)],(255,226,126,168),1.6,1.1)
    stroke([(-37,14),(-34,35),(-13,25),(-9,7)],(255,207,136,132),1.5)
    stroke([(-35,-11),(-93,-35),(-137,-45),(-180,-57)],(192,255,225,137),1.25,1.2)
    stroke([(-43,5),(-87,20),(-119,25),(-156,40)],(248,220,119,116),1,1)
    stroke([(-63,-13),(-92,-22),(-119,-18),(-152,-42)],(145,255,223,90),1)
    for k in range(9):
        x=-56-12*k;y=-13+round(10*sin(k*.9+index*.27))-(15 if k%3==0 else 0)
        xx,yy=warp(x,y)
        radius=2 if k%4==0 else 1
        q=Image.new('RGBA',im.size)
        ImageDraw.Draw(q).ellipse((xx-radius*SS,yy-radius*SS,xx+radius*SS,yy+radius*SS),fill=(240,255,197,204 if k%3==0 else 117))
        im.alpha_composite(q)
    # White-hot leading point only, not a full-body oversaturated billboard
    xx,yy=warp(-6,0)
    a=Image.new('RGBA',im.size)
    ImageDraw.Draw(a).ellipse((xx-10*SS,yy-10*SS,xx+10*SS,yy+10*SS),fill=(90,244,202,93))
    im.alpha_composite(a.filter(ImageFilter.GaussianBlur(8*SS)))
    a=Image.new('RGBA',im.size)
    ImageDraw.Draw(a).ellipse((xx-4*SS,yy-4*SS,xx+4*SS,yy+4*SS),fill=(252,255,221,238))
    im.alpha_composite(a)
    return im.resize((W,H),Image.Resampling.LANCZOS)
def main():
    ROOT.mkdir(exist_ok=True,parents=True);(ROOT/'master').mkdir(exist_ok=True)
    atlas=Image.new('RGBA',(W*4,H*4))
    for i in range(16):
        p=render(i);atlas.alpha_composite(p,((i%4)*W,(i//4)*H))
        if i==7:p.save(ROOT/'master'/'poi18_gu_master_rgba.png',optimize=True)
    atlas.save(ROOT/'poi18_gu_16.png',optimize=True)
    print('POI18_HYBRID_R32_SOURCE_PASS poses=16 atlas=1280x1024 alpha=RGBA independent_shapes=true')
if __name__=='__main__':main()
