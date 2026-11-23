#!/usr/bin/env python3
"""Sword02 Human R1C-A — independent source-art volume treatment.

Only a post-render RGBA painterly treatment: no engine, gameplay, sockets, or target receipts.
Deterministic layered elliptical wind mass, split crystalline fibers, and single circular shock.
"""
from PIL import Image,ImageDraw,ImageFilter
import numpy as np, math, random
S=512; TAU=math.tau
YY,XX=np.mgrid[0:S,0:S].astype(np.float32)

def field(seed):
    rng=np.random.default_rng(seed)
    def layer(w,h,blur=0):
        a=rng.integers(0,256,(h,w),dtype=np.uint8)
        im=Image.fromarray(a,'L').resize((S,S),Image.Resampling.BICUBIC)
        if blur:im=im.filter(ImageFilter.GaussianBlur(blur))
        return np.array(im,dtype=np.float32)/255
    return .45*layer(12,12,4)+.35*layer(38,38,2)+.20*layer(99,99,0)

def rgba_layer(rgb,alpha):
    alpha=np.uint8(np.clip(alpha,0,255))
    out=np.empty((S,S,4),dtype=np.uint8)
    out[:,:,:3]=rgb
    out[:,:,3]=alpha
    return Image.fromarray(out,'RGBA')

def vortex_layer(i, center,rx,ry,end,span,power=1.0,stage='gyre',seed=100):
    t=np.arctan2((YY-center[1])/(ry+1), (XX-center[0])/(rx+1))
    diff=np.mod(end-t,TAU)
    s=np.maximum(0,np.minimum(1,(span-diff)/(span+1e-6)))
    gate=((diff<span)*np.maximum(0,np.sin(np.pi*s))**.32).astype(np.float32)
    n=field(seed+i*137)
    n2=field(seed+i*137+29)
    angular=(np.sin(t*5.9+i*1.91)+.57*np.sin(t*13.5+i*.9))
    rr=np.sqrt(((XX-center[0])/rx)**2+((YY-center[1])/ry)**2)
    # Wind body displaced by irregular turbulence; layered separated outer/deep edges.
    warp=18.5*(n-.5)+4.2*angular+2.3*np.sin(t*19+i*2.1)
    dr=(rr-1.)*(rx+ry)*.53-warp
    mass=np.exp(-((dr+5)/43)**2)*gate*(.55+1.10*n)
    outer=np.exp(-((np.abs(dr)-32)/24)**2)*gate*(.43+.87*n2)
    wide=np.exp(-(dr/63)**2)*gate*(.22+.58*n)
    inner=np.exp(-((dr-1)/15)**2)*gate*(.41+.69*n2)
    fine=np.exp(-((dr+2+2.8*np.sin(t*47+i))/4.8)**2)*gate*(.43+.70*n)
    im=Image.new('RGBA',(S,S))
    for rgb,a in [((5,32,91),75*wide*power),((16,63,133),93*outer*power),
                  ((18,122,205),115*mass*power),((65,190,241),111*inner*power),
                  ((196,244,254),148*fine*power)]:
        im.alpha_composite(rgba_layer(rgb,a))
    return im

def translucent_feathers(im,i,end,center=(256,264),rx=145,ry=85,scale=1):
    rnd=random.Random(7701+i*283)
    feather=Image.new('RGBA',(S,S));d=ImageDraw.Draw(feather)
    for k in range(53):
        a=end-rnd.uniform(.1,1.7)
        x=center[0]+rx*math.cos(a);y=center[1]+ry*math.sin(a)
        ang=math.atan2(ry*math.cos(a),-rx*math.sin(a))
        ang+=rnd.choice([-1,1])*rnd.uniform(.3,1.0)
        leng=rnd.uniform(17,74)*scale;w=rnd.uniform(2.3,9.5)*scale
        dx=math.cos(ang);dy=math.sin(ang);nx=-dy;ny=dx
        pts=[(x-nx*w,y-ny*w),(x+nx*w*.48+dx*leng*.55,y+ny*w*.48+dy*leng*.55),
             (x+dx*leng,y+dy*leng),(x-nx*w*.4+dx*leng*.42,y-ny*w*.4+dy*leng*.42)]
        color=rnd.choice([(14,105,202,103),(50,178,242,120),(157,230,255,146)])
        d.polygon(pts,fill=color)
        if k%3==0:
            d.line([(x,y),(x+dx*leng*.9,y+dy*leng*.9)],fill=(229,250,255,175),width=1)
    im.alpha_composite(feather.filter(ImageFilter.GaussianBlur(.6)))

def charge_motes(im,i):
    rng=random.Random(615+i)
    d=ImageDraw.Draw(im)
    for k in range(38+10*i):
        a=rng.random()*TAU;rad=rng.uniform(36,125+10*i)
        x=256+math.cos(a)*rad;y=269+math.sin(a)*rad*.73
        leng=rng.uniform(3,14);thick=1 if k%4 else 2
        # Aspirating streams point toward the sword, not explosive rays.
        d.line([(x,y),(x-math.cos(a)*leng,y-math.sin(a)*leng)],fill=(103,209,250,rng.randint(80,180)),width=thick)

def contact_layer(i):
    im=Image.new('RGBA',(S,S))
    rnd=random.Random(9400+i)
    c=(326,252)
    # Independent opening wound, directional spray, one expanding circular-area pulse.
    a=5.6+(.35 if i==9 else 0)
    im.alpha_composite(vortex_layer(i,c,126+i*7,80+i*8,end=a,span=TAU-.04,power=.8,stage='impact',seed=500))
    under=Image.new('RGBA',(S,S));d=ImageDraw.Draw(under)
    for k in range(23):
        t=k*TAU/23+rnd.uniform(-.12,.12)
        ln=rnd.uniform(40,133)*(1.12 if i==9 else .8)
        x=c[0]+rnd.uniform(-8,8);y=c[1]+rnd.uniform(-8,8)
        nx=-math.sin(t);ny=math.cos(t)
        wd=rnd.uniform(3,10)
        tip=(x+math.cos(t)*ln,y+math.sin(t)*ln*.87)
        body=[(x+wd*nx,y+wd*ny),(x+math.cos(t)*ln*.42+nx*wd*.45,y+math.sin(t)*ln*.42+ny*wd*.45),tip,(x-nx*wd*.6,y-ny*wd*.6)]
        d.polygon(body,fill=rnd.choice([(22,80,166,128),(27,150,234,164),(101,218,253,170)]))
        if k%3==0:d.line([(x,y),tip],fill=(236,254,255,225),width=2)
    im.alpha_composite(under)
    for radius,clr,al,blur in [(35,(10,49,134),90,9),(22,(36,149,224),100,5),(12,(149,236,255),140,3),(5,(251,255,255),236,1)]:
        ink=Image.new('RGBA',(S,S));di=ImageDraw.Draw(ink)
        di.ellipse((c[0]-radius,c[1]-radius*.8,c[0]+radius,c[1]+radius*.8),fill=clr+(al,))
        im.alpha_composite(ink.filter(ImageFilter.GaussianBlur(blur)))
    return im

def enhance(base,i):
    canvas=Image.new('RGBA',(S,S))
    if i<=2:
        rx=98+16*i;ry=71+12*i
        canvas.alpha_composite(vortex_layer(i,(256,264),rx,ry,end=4.2+i*.55,span=5.05,power=1.30+i*.12,seed=330))
        canvas.alpha_composite(vortex_layer(i,(256,264),rx-11,ry-9,end=1.9+i*.7,span=2.8,power=.88+i*.13,seed=312))
        canvas.alpha_composite(base)
        charge_motes(canvas,i)
    elif 3<=i<=8:
        k=i-3;end=2.65+k*.80 if i<=7 else 5.85
        span=1.65+k*.35 if i<=7 else 3.65
        canvas.alpha_composite(vortex_layer(i,(256,264),145,85,end,span,power=1.30,seed=120))
        translucent_feathers(canvas,i,end)
        canvas.alpha_composite(base)
        # outer glints remain transparent and subordinate to physical sword
        if i>=6:
            canvas.alpha_composite(vortex_layer(i,(256,264),139,79,end-.18,span*.90,power=.27,seed=209))
        if i==8:canvas.alpha_composite(contact_layer(i))
    elif i==9:
        canvas.alpha_composite(base)
        canvas.alpha_composite(contact_layer(i))
    elif i==10:
        canvas.alpha_composite(vortex_layer(i,(256,264),141,79,6.4,2.1,power=1.06,seed=444))
        canvas.alpha_composite(base)
    else:
        canvas.alpha_composite(vortex_layer(i,(256,264),131,72,6.7,1.35,power=.73,seed=444))
        canvas.alpha_composite(base)
    # V4 hard guard: source art must never touch 8-pixel transparent gutters.
    a=np.array(canvas,dtype=np.uint8)
    edge=np.minimum(np.minimum(XX,YY),np.minimum(S-1-XX,S-1-YY))
    taper=np.clip((edge-9)/23,0,1)
    a[:,:,3]=np.uint8(np.clip(a[:,:,3].astype(np.float32)*taper,0,255))
    return Image.fromarray(a,'RGBA')
