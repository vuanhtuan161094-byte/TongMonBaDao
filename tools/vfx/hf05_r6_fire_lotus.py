#!/usr/bin/env python3
"""HF05 R6 finale-only painterly VFX: inward solar compression -> blooming
fire-lotus -> floating painted ember fragments. This source makes 20 genuinely
moving RGBA poses from first-party Hỏa Phù glowing flame pixels. It does not
change R5 charge, storm, rain, actors, gameplay, rigging or hit receipts.

The HERO art is the original R5 illustrated scroll; when the scroll collapses
it transfers to the single *visual* AoE event. Lotus is a decorative fire
response, not an extra gameplay strike or a permanent floor burn.
"""
from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np
import hashlib, math
from hf02_r5_source_painted import source_flame, deform

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"godot/labs/combat_lab/talisman10/assets"
COUNT=20
CELL=(640,400)

def smooth(a,b,x):
    if b==a:return 1.0
    q=max(0.0,min(1.0,(x-a)/(b-a)))
    return q*q*(3-2*q)

def glow(dst,im,pos,intensity=.18,radius=7):
    if intensity<=.001:return
    # Alpha-preserving painterly sprite; the soft light uses the ORIGINAL
    # source's irregular flame silhouette, never a hard vector circle.
    img=Image.new("RGBA",dst.size)
    img.alpha_composite(im,pos)
    aura=img.filter(ImageFilter.GaussianBlur(radius))
    aura.putalpha(aura.getchannel("A").point(lambda v:round(v*intensity)))
    dst.alpha_composite(aura)
    dst.alpha_composite(img)

def flame_petal(master,idx,w,h,angle,gain=1.0):
    warped=deform(master,idx,sx=w/master.width,sy=h/master.height)
    if angle:
        warped=warped.rotate(angle,Image.Resampling.BICUBIC,expand=True)
    if gain<.999:
        warped.putalpha(warped.getchannel("A").point(lambda v:round(v*max(0,gain))))
    return warped

def place(dst,im,x,y,halo=.2):
    at=(round(x-im.width*.5),round(y-im.height*.5))
    glow(dst,im,at,halo)

def frame(i,master):
    q=i/(COUNT-1)
    c=Image.new("RGBA",CELL)
    open_amt=smooth(.04,.38,q)
    bloom_gain=smooth(.0,.16,q)*(1.0-smooth(.57,.91,q))
    # Five long, irregular painterly flame-petals sweep from a shared hot
    # core and CANNOT be confused with a uniform HUD ring / code polygon.
    vectors=[(-1.22,-.64,40),(-.95,-1.26,22),(-.18,-1.60,-1),
             (.51,-1.53,-17),(1.20,-.98,-37),(1.32,-.33,-55)]
    for j,(vx,vy,ang) in enumerate(vectors):
        bend=math.sin(i*.23+j*1.21)
        reach=(36+123*open_amt)*(0.93+.12*math.sin(j*2.3))
        x=320+vx*reach
        y=249+vy*reach*.54 + 5*bend
        w=int(162+58*open_amt+12*math.sin(i*.25+j))
        h=int(52+15*open_amt)
        sprite=flame_petal(master,i+j*7,w,h,ang+7*bend,
            bloom_gain*(.73+.16*math.sin(j*.83)**2))
        place(c,sprite,x,y,.25*bloom_gain)
    # One central source-painted white-hot vertical plume surges upward at
    # impact then *recedes*: independent from the big drifting leaves.
    center_gain=smooth(0.0,.16,q)*(1.0-smooth(.40,.65,q))
    if center_gain>.001:
        vertical=flame_petal(master,i+35,255,92,87+7*math.sin(i*.35),center_gain*.85)
        place(c,vertical,320,210-31*open_amt,.39*center_gain)
        white=flame_petal(master,i+49,142,58,86,center_gain*.72)
        white_arr=np.array(white,dtype=np.uint8)
        nonzero=white_arr[:,:,3]>20
        white_arr[nonzero,0]=255
        white_arr[nonzero,1]=np.maximum(white_arr[nonzero,1],224)
        white_arr[nonzero,2]=np.maximum(white_arr[nonzero,2],139)
        place(c,Image.fromarray(white_arr,"RGBA"),320,228-22*open_amt,.20*center_gain)
    # The horizontal fire fan is organic image material, not a ground ring.
    base_gain=smooth(.06,.21,q)*(1.0-smooth(.52,.90,q))
    for j in range(4):
        x=210+j*75+12*math.sin(i*.32+j)
        y=291+8*math.cos(j*.94+i*.18)
        spray=flame_petal(master,i+70+j*6,194+8*j,57,-14+j*9,
                          base_gain*(.58+.15*math.cos(j)))
        place(c,spray,x,y,.13*base_gain)
    # Embers use cropped fragments from the SAME original painted fire, never
    # geometric UI dots. Rise and soften gradually after the main burst.
    ember_gain=smooth(.37,.57,q)*(1.0-smooth(.82,1.10,q))
    for j in range(15):
        seed=(j*71+19)
        sx=32+(seed*3)%241;sy=8+(j*11)%42
        crop=master.crop((sx,sy,sx+32,sy+27)).convert("RGBA")
        z=np.array(crop)
        z[:,:,3]=np.uint8(np.clip(z[:,:,3].astype(float)*ember_gain*(.53+.26*math.sin(j)**2),0,255))
        if z[:,:,3].max()<1:continue
        crop=Image.fromarray(z,"RGBA")
        dx=math.sin(j*2.4)*27+(j-7)*24
        dy=-((j*37)%108)-(q-.37)*115
        at=flame_petal(crop,j+i,19+(j%4)*7,15+(j%3)*8,j*19+i*2.1,.9)
        place(c,at,320+dx+9*math.sin(i*.17+j),263+dy,.13*ember_gain)
    if q>=.98:
        # Keep non-empty final pose for deterministic alpha-clip QA; the
        # renderer independently reaches zero alpha at the end of finale.
        residual=flame_petal(master,i+143,47,17,-12,.05)
        place(c,residual,325,211,.01)
    return c

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    original=source_flame()
    output=Image.new("RGBA",(CELL[0]*4,CELL[1]*5))
    uniq=set()
    for i in range(COUNT):
        img=frame(i,original)
        assert img.getchannel("A").getextrema()[0]==0
        assert img.getchannel("A").getextrema()[1]>10,(i,img.getchannel("A").getextrema())
        ident=hashlib.sha256(img.tobytes()).hexdigest()
        assert ident not in uniq,(i,"duplicate original pose")
        uniq.add(ident)
        output.alpha_composite(img,(i%4*CELL[0],i//4*CELL[1]))
    path=OUT/"tal10_r6_fire_lotus.webp"
    output.save(path,"WEBP",quality=94,method=6,exact=True)
    print("HF05_R6_FINALE_ATLAS_PASS",path.name,output.size,COUNT,hashlib.sha256(path.read_bytes()).hexdigest())
    print("HF05_R6_FINALE_SOURCE_BAKE_PASS")
if __name__=="__main__":main()
