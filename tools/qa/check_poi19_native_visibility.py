#!/usr/bin/env python3
"""POI19 1× Godot visibility gate (NOT automatic art approval).

Measures scene-specific jade energy in charge / seed flight / contact ROIs
relative to genuine Godot baseline t=0.05s, and verifies no false effect
appears over an independent decoy. These are visibility minima, not beauty.
"""
from __future__ import annotations
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image
REGIONS={
    "charge":(306,403,391,498),
    "peak":(572,362,754,460),
    "contact":(821,374,972,535),
    "decoy":(1030,375,1167,543)
}
FILES={"charge":"v4-charge.png","peak":"v4-peak.png","contact":"v4-contact.png"}
MIN_DELTA={"charge":70,"peak":200,"contact":200}
def jade_count(im,box):
    x,y,X,Y=box
    a=np.asarray(im.crop((x,y,X,Y)).convert("RGB")).astype(np.float32)
    R,G,B=a[:,:,0],a[:,:,1],a[:,:,2]
    return int(((G>130)&(G>R*1.16)&(B>R*1.03)).sum())
def main():
    p=argparse.ArgumentParser();p.add_argument("--out",required=True);args=p.parse_args()
    root=Path(args.out); idle=Image.open(root/"check-0.05.png").convert("RGB")
    assert idle.size==(1280,720),"baseline not actual 1280x720"
    report={"policy":"POI19_SPECIFIC_G36_VISIBILITY_NOT_ART","source":"genuine Godot 4.7.2 native movie frames","phases":{},"owner_art":"PENDING"}
    for stage,f in FILES.items():
        im=Image.open(root/f).convert("RGB")
        assert im.size==(1280,720),(stage,"wrong native dimensions")
        roi=REGIONS[stage]
        base=jade_count(idle,roi);active=jade_count(im,roi)
        delta=active-base
        report["phases"][stage]={"roi":roi,"baseline_jade_pixels":base,"stage_jade_pixels":active,"delta":delta,"required_minimum":MIN_DELTA[stage],"meets_minimum":delta>=MIN_DELTA[stage]}
        assert delta>=MIN_DELTA[stage],f"{stage} effect too small/dim at 1x: delta={delta}"
    im=Image.open(root/FILES["contact"]).convert("RGB")
    d0=jade_count(idle,REGIONS["decoy"]);d1=jade_count(im,REGIONS["decoy"])
    report["decoy"]={"baseline":d0,"contact":d1,"delta":d1-d0,"false_jade_spread":d1-d0>50}
    assert d1-d0<=50,"mark appeared on unrelated decoy"
    (root/"G36_VISIBILITY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print("POI19_NATIVE_G36_VISIBILITY_PASS_NOT_ART_APPROVAL",json.dumps({k:v["delta"] for k,v in report["phases"].items()}))
if __name__=="__main__":main()
