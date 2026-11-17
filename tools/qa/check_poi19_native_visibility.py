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
    # Sustain G3.6: visible orchid above selected moving target, absent on expiry.
    # Source of time-to-position is the LAB movement equation, not Combat V2.
    from math import sin,cos
    def mark_region(t):
        foot_x=895+31*sin(2*t+.2)
        foot_y=548+8.5*cos(1.3*t)
        cy=foot_y-167
        return (round(foot_x-68),round(cy-56),round(foot_x+68),round(cy+56))
    stage_counts={}
    for name,t in (("active",2.30),("mid",5.10),("expiring",7.92),("cleared",8.22)):
        f=root/("status-"+name+".png")
        assert f.is_file(), "missing actual Godot 6.5s status screenshot: "+str(f)
        shot=Image.open(f).convert("RGB")
        cnt=jade_count(shot,mark_region(t))
        stage_counts[name]=cnt
    report["sustain_status"]={"counts":stage_counts,"note":"G36 visibility only; not proof of actual combat status"}
    assert stage_counts["active"]>=70, "Phé Cổ mark too faint at active2.30"
    assert stage_counts["mid"]>=70, "Phé Cổ mark too faint at mid5.10"
    assert stage_counts["cleared"]<=max(20,stage_counts["active"]//4), "Phé Cổ mark fails to disappear at 8.22"
    (root/"G36_VISIBILITY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print("POI19_NATIVE_G36_VISIBILITY_PASS_NOT_ART_APPROVAL",json.dumps({**{k:v["delta"] for k,v in report["phases"].items()},"status":report["sustain_status"]["counts"]}))
if __name__=="__main__":main()
