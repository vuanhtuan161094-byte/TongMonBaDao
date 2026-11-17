#!/usr/bin/env python3
"""POI19 R2 G3.6 1x Godot native visibility -- never grants art approval.
ROI and hue thresholds are tailored to violet/jade/orchid and the exact LAB.
Native 1280x720 screenshots MUST come from same 510-frame Godot video.
"""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image
REGIONS={
 "charge":(258,342,437,540),
 "peak":(548,317,797,481),
 "contact":(742,310,1022,573),
}
FILES={"charge":"v4-charge.png","peak":"v4-peak.png","contact":"v4-contact.png"}
MIN_DIFF={"charge":135,"peak":310,"contact":420}
def pixels(im,rect):
    x,y,X,Y=rect
    z=np.asarray(im.crop((x,y,X,Y)).convert("RGB"),dtype=np.float32)
    r,g,b=z[:,:,0],z[:,:,1],z[:,:,2]
    violet=((r>106)&(b>115)&(r>g*1.14)&(b>g*1.12))
    jade=((g>145)&(g>r*1.09)&(b>r*.90))
    return int(violet.sum()+jade.sum())
def mark_rect(t):
    from math import sin,cos
    x=895+31*sin(2*t+.2)
    y=548+8.5*cos(1.3*t)-167
    return (round(x-65),round(y-61),round(x+65),round(y+51))
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--out",required=True)
    args=parser.parse_args()
    root=Path(args.out)
    idle=Image.open(root/"check-0.05.png").convert("RGB")
    assert idle.size==(1280,720),"missing genuine 1280x720 frame"
    result={"gate":"G3.6_NATIVE_1X_MINIMUM_ONLY_NO_OWNER_ART_APPROVAL","phase":{}}
    for key,file in FILES.items():
        frame=Image.open(root/file).convert("RGB")
        assert frame.size==(1280,720),file
        count=pixels(frame,REGIONS[key]);before=pixels(idle,REGIONS[key])
        delta=count-before
        result["phase"][key]={"roi":REGIONS[key],"count":count,"idle":before,"diff":delta,"minimum":MIN_DIFF[key]}
        assert delta>=MIN_DIFF[key],f"{key} too visually faint at native 1x ({delta} < {MIN_DIFF[key]})"
    marks={}
    for name,t in (("active",2.30),("mid",5.10),("expiring",7.92),("cleared",8.22)):
        path=root/("status-"+name+".png")
        assert path.exists(),f"missing native status {name}"
        image=Image.open(path).convert("RGB")
        assert image.size==(1280,720)
        marks[name]=pixels(image,mark_rect(t))
    result["mark_counts"]=marks
    assert marks["active"]>=65 and marks["mid"]>=65,f"mark invisible when sustained {marks}"
    assert marks["cleared"] < max(30,marks["active"]*.35),f"mark fails to clear {marks}"
    # Decoy correctness is guaranteed primarily by Godot focused script and source-only targeting;
    # color differences from its WALK frame are recorded, not used as fake damage receipts.
    (root/"G36_NATIVE_VISIBILITY.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print("POI19_R2_G36_VISIBILITY_PASS_NOT_ART_APPROVAL",json.dumps({"diff":{k:v["diff"] for k,v in result["phase"].items()},"status":marks}))
if __name__=="__main__":main()
