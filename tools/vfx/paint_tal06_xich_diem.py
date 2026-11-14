#!/usr/bin/env python3
"""HF01 Xich Diem Khai Van: deterministic original painted RGBA fire atlases.
No copied game artwork, no rig; Pillow+NumPy, user may regenerate master deliberately.
"""
from pathlib import Path
from sys import argv
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,math,os,hashlib,base64
ROOT=Path(argv[1]) if len(argv)>1 else Path('.')
OUT=ROOT/'godot/labs/combat_lab/talisman06/assets'
OUT.mkdir(parents=True,exist_ok=True)
def noise(w,h,seed):
    rng=np.random.default_rng(seed);a=np.zeros((h,w),dtype=np.float32)
    for ww,hh,weight in [(7,5,.28),(23,13,.27),(61,37,.25),(135,83,.2)]:
        tile=np.uint8(rng.random((hh,ww))*255)
        s=np.asarray(Image.fromarray(tile,'L').resize((w,h),Image.Resampling.BICUBIC),dtype=np.float32)/255.
        a+=(s-.5)*weight*2
    return np.clip(.5+a,0,1)
def rgba(a,red,green,blue):
    out=np.zeros((*a.shape,4),dtype=np.uint8)
    for k,channel in enumerate((red,green,blue,a)):
        out[:,:,k]=np.uint8(np.clip(channel,0,255))
    return Image.fromarray(out,'RGBA')
def comet(i):
    w,h=384,224
    x=np.arange(w,dtype=np.float32)[None,:]
    y=np.arange(h,dtype=np.float32)[:,None]
    n=noise(w,h,10400+41*i)
    q=i/11.
    tip=292+7*math.sin(i*.75)
    tail=np.clip((tip-x)/280,0,1)
    center=112+14*np.sin(x/25+i*.55)*tail+8*np.sin(x/53-i*.28)
    d=np.abs(y-center)
    width=9+60*tail*(.5+.83*n)
    body=np.exp(-(d/width)**1.65)*np.clip((x-2)/30,0,1)*np.clip((tip-x+25)/34,0,1)
    core=np.exp(-((x-tip)/21)**2-((y-center)/17)**2)
    smoke=np.exp(-(d/(width*2+4))**1.6)*tail*n
    power=(body*.84+core*.9)*(.58+.48*n)
    alpha=np.clip(190*power+52*smoke,0,255)
    im=rgba(alpha,161+89*power+38*n,43+168*power+52*n,11+41*n)
    strokes=Image.new('RGBA',(w,h));b=ImageDraw.Draw(strokes,'RGBA')
    rng=np.random.default_rng(2100+i)
    for j in range(24):
        xx=rng.uniform(26,tip-11);fade=(tip-xx)/280
        cy=112+14*math.sin(xx/25+i*.55)*fade+8*math.sin(xx/53-i*.28)
        off=rng.choice([-1,1])*rng.uniform(11,63)*fade
        length=rng.uniform(17,55)*(.5+fade)
        b.line([(xx-length,cy+off),(xx+length*.20,cy+off*.57),(xx+length*.7,cy)],
               fill=(245,int(105+95*rng.random()),37,int(rng.uniform(45,145))),
               width=int(rng.uniform(2,6)),joint='curve')
    im.alpha_composite(strokes.filter(ImageFilter.GaussianBlur(5)))
    im.alpha_composite(strokes)
    emb=Image.new('RGBA',(w,h));bb=ImageDraw.Draw(emb,'RGBA')
    for j in range(38):
        xx=rng.uniform(10,tip);yy=112+rng.normal(0,40);radius=rng.choice([1,1,2,3])
        bb.ellipse((xx-radius,yy-radius,xx+radius,yy+radius),fill=(255,208,123,int(rng.uniform(50,160))))
    im.alpha_composite(emb)
    return im
def seal(i):
    w=h=256;rng=np.random.default_rng(420+i)
    im=Image.new('RGBA',(w,h));paint=Image.new('RGBA',(w,h));p=ImageDraw.Draw(paint,'RGBA')
    vertices=[(-43,-87),(-26,-97),(-6,-92),(13,-97),(37,-86),(46,-45),(40,9),(48,55),(30,92),
              (7,86),(-26,92),(-45,61),(-40,14),(-49,-48)]
    pts=[(128+x+rng.uniform(-2,2),128+y+rng.uniform(-2,2)) for x,y in vertices]
    p.polygon(pts,fill=(100,30,17,235))
    p.line(pts+[pts[0]],fill=(249,140,41,169),width=4,joint='curve')
    p.polygon([(128+x*.84,128+y*.84) for x,y in vertices],fill=(185,90,34,232))
    p.polygon([(128+x*.73,128+y*.73) for x,y in vertices],fill=(239,177,87,222))
    for j in range(148):
        xx=rng.uniform(89,166);yy=rng.uniform(51,206);rad=rng.choice([1,1,2,3])
        p.ellipse((xx-rad,yy-rad,xx+rad,yy+rad),fill=(86,34,20,int(rng.uniform(12,93))))
    im.alpha_composite(paint.filter(ImageFilter.GaussianBlur(6)))
    im.alpha_composite(paint)
    glyph=Image.new('RGBA',(w,h));b=ImageDraw.Draw(glyph,'RGBA')
    strokes=[[(109,74),(147,75),(128,100),(152,106)],
             [(117,116),(147,126),(115,144)],
             [(146,145),(115,166),(148,177)],
             [(117,185),(148,187)]]
    reveal=(i+1)/12.
    for j,pts in enumerate(strokes):
        if reveal<j/4:continue
        n=max(2,min(len(pts),int((reveal-j/4)*17)))
        path=pts[:n]
        if len(path)>1:
            b.line(path,fill=(117,27,18,208),width=9,joint='curve')
            b.line(path,fill=(255,230,138,224),width=3,joint='curve')
    im.alpha_composite(glyph.filter(ImageFilter.GaussianBlur(3)))
    im.alpha_composite(glyph)
    fire=Image.new('RGBA',(w,h));ff=ImageDraw.Draw(fire,'RGBA')
    for j in range(13):
        a=j*2*math.pi/13+i*.18
        x=128+math.cos(a)*rng.uniform(42,68);y=129+math.sin(a)*rng.uniform(69,97)
        ff.line([(x,y),(x+math.cos(a)*rng.uniform(7,22),y+math.sin(a)*rng.uniform(8,23))],
                fill=(255,int(120+rng.random()*77),43,int(rng.uniform(56,135))),width=rng.choice([2,3,4]))
    im.alpha_composite(fire.filter(ImageFilter.GaussianBlur(3)))
    return im
def impact(i):
    w,h=288,224
    xx=np.arange(w,dtype=np.float32)[None,:]-144
    yy=np.arange(h,dtype=np.float32)[:,None]-160
    n=noise(w,h,720+i*13)
    prog=i/7.
    ground=np.exp(-((xx/(34+86*prog))**2+(yy/17)**2))*(.4+.8*n)
    plume=np.exp(-((xx/(26+44*prog))**2+((yy+46)/(60+32*prog))**2))*(.5+.6*n)
    im=rgba(np.clip(ground*156+plume*(158-52*prog),0,255),170+75*n,68+119*n,20+24*n)
    ink=Image.new('RGBA',(w,h));b=ImageDraw.Draw(ink,'RGBA');rng=np.random.default_rng(933+i)
    for j in range(10):
        a=j*2*math.pi/10+rng.uniform(-.2,.2);rad=(18+83*prog)*rng.uniform(.65,1.0)
        path=[(144,161),(144+rad*.5*math.cos(a),161+rad*.25*math.sin(a)),
              (144+rad*math.cos(a+.07),161+rad*.41*math.sin(a+.07))]
        b.line(path,fill=(255,140,52,int(85+120*(1-prog*.4))),width=rng.choice([2,3,4]))
    for j in range(14):
        x=rng.uniform(74,210);y=146+rng.normal(0,14)
        b.line([(x,y),(x+rng.normal(0,20),y-rng.uniform(15,79)*(1-prog*.4))],
               fill=(244,168,64,int(rng.uniform(38,115))),width=rng.choice([2,3,4]))
    im.alpha_composite(ink.filter(ImageFilter.GaussianBlur(4)))
    im.alpha_composite(ink)
    return im
def foot():
    im=Image.new('RGBA',(256,128));b=ImageDraw.Draw(im,'RGBA');rng=np.random.default_rng(418)
    for i in range(39):
        a=rng.uniform(0,2*math.pi);radius=rng.uniform(60,105)
        x=128+math.cos(a)*radius;y=75+math.sin(a)*radius*.35
        d=rng.uniform(4,17)
        b.line([(x,y),(x+math.cos(a+1)*d,y+math.sin(a+1)*d*.35)],
               fill=(248,int(140+rng.random()*65),76,int(rng.uniform(50,146))),width=rng.choice([1,2,3]))
    for i in range(8):
        a=i*2*math.pi/8;x=128+math.cos(a)*62;y=75+math.sin(a)*22
        b.polygon([(x-4,y),(x,y-7),(x+4,y),(x,y+7)],fill=(250,180,85,120))
    return im.filter(ImageFilter.GaussianBlur(.65))
outputs={}
def atlas(name,frames,w,h):
    out=Image.new('RGBA',(w*4,h*((len(frames)+3)//4)))
    for i,f in enumerate(frames):out.alpha_composite(f,((i%4)*w,(i//4)*h))
    outputs[name]=out
atlas('tal06_flame_seal_atlas.webp',[seal(i) for i in range(12)],256,256)
atlas('tal06_fire_comet_atlas.webp',[comet(i) for i in range(12)],384,224)
atlas('tal06_impact_atlas.webp',[impact(i) for i in range(8)],288,224)
outputs['tal06_seal_master.webp']=seal(11)
outputs['tal06_comet_master.webp']=comet(11)
outputs['tal06_foot_ember.webp']=foot()
for name,im in outputs.items():
    path=OUT/name;im.save(path,quality=90,method=5,exact=True)
    print('TAL06_ASSET',name,im.size,hashlib.sha256(path.read_bytes()).hexdigest(),path.stat().st_size)
    if os.getenv('TMB_ART_LOG_EXPORT')=='1':
        print('TMB_ASSET_BEGIN:'+name)
        encoded=base64.b64encode(path.read_bytes()).decode('ascii')
        for i in range(0,len(encoded),180):print('TMB_ASSET_LINE:'+encoded[i:i+180])
        print('TMB_ASSET_END:'+name)
