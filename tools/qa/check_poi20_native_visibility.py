#!/usr/bin/env python3
"""POI20 actual native 1280×720 visibility/expiry QA. NEVER auto-art approval.
Measures bright jade + almost-white emission in Godot rendered screenshots
relative to a genuine baseline and the independently moving single target.
"""
import argparse,json,math
from pathlib import Path
import numpy as np
from PIL import Image
ROIS={"charge":(308,377,418,497),"peak":(439,332,808,490),"contact":(824,328,982,562)}
SOURCE={"charge":"v4-charge.png","peak":"v4-peak.png","contact":"v4-contact.png"}
MIN={"charge":180,"peak":600,"contact":700}
def count(image,box):
    a=np.asarray(image.crop(box).convert("RGB"),dtype=np.float32)
    r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
    jade=(g>128)&(g>r*1.12)&(b>r*.92)
    ivory=(r>175)&(g>185)&(b>175)
    return int(np.logical_or(jade,ivory).sum())
def box(t):
    footx=895+31*math.sin(2*t+.2)
    footy=548+8.5*math.cos(1.3*t)
    marky=footy-167
    return tuple(round(q) for q in (footx-63,marky-58,footx+63,marky+67))
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--out",required=True)
    args=parser.parse_args()
    root=Path(args.out)
    idle=Image.open(root/"check-0.05.png").convert("RGB")
    assert idle.size==(1280,720)
    result={"gate":"POI20_G3_6_NATIVE_1X_VISIBILITY_NOT_ART_APPROVAL","phase":{},"status":{}}
    for key,src in SOURCE.items():
        shot=Image.open(root/src).convert("RGB")
        assert shot.size==(1280,720)
        lo=count(idle,ROIS[key]);hi=count(shot,ROIS[key]);delta=hi-lo
        result["phase"][key]={"baseline":lo,"visible":hi,"delta":delta,"min":MIN[key]}
        assert delta>=MIN[key],f"{key} too dim at true 1×: {delta} / {MIN[key]}"
    for key,t in (("active",2.30),("mid",5.10),("expiring",9.75),("fade",10.04),("clear",10.27)):
        f=root/("status-"+key+".png")
        assert f.is_file(),f
        shot=Image.open(f).convert("RGB")
        assert shot.size==(1280,720)
        result["status"][key]={"count":count(shot,box(t)),"rect":box(t)}
    status=result["status"]
    assert status["active"]["count"]>=90,status
    assert status["mid"]["count"]>=90,status
    assert status["clear"]["count"]<max(75,status["active"]["count"]*.65),status
    (root/"POI20_G36_NATIVE_VISIBILITY.json").write_text(json.dumps(result,indent=2,ensure_ascii=False)+"\n")
    print("POI20_G36_NATIVE_VISIBILITY_PASS_NOT_ART",json.dumps({"delta":{k:v["delta"] for k,v in result["phase"].items()},"status":{k:v["count"] for k,v in status.items()}}))
if __name__=="__main__":main()
