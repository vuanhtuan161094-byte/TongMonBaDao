#!/usr/bin/env python3
"""POI17 native 1x visibility and finite afterimage audit on UNALTERED Godot PNG.
G3.6 does not imply art G3.7 owner approval.
"""
import argparse,json
import numpy as np
from PIL import Image
from pathlib import Path

ROIS={
 "charge": ("v4-charge.png",(195,300,455,635),180),
 "peak": ("v4-peak.png",(240,290,930,635),500),
 "contact": ("v4-contact.png",(635,290,990,635),220),
 "fade": ("v4-fade.png",(625,300,1005,635),120),
}
def main(root:Path):
    log={};fail=[]
    def get(fn):
        f=root/fn
        if not f.is_file():raise FileNotFoundError(fn)
        im=np.asarray(Image.open(f).convert("RGB"),dtype=np.int16)
        if im.shape[:2]!=(720,1280):raise ValueError(f"NOT_NATIVE_{fn}_{im.shape}")
        return im
    for key,(fn,roi,threshold) in ROIS.items():
        try:
            img=get(fn)
        except Exception as e:
            fail.append(str(e));continue
        x0,y0,x1,y1=roi
        rgb=img[y0:y1,x0:x1]
        red,green,blue=(rgb[:,:,i] for i in range(3))
        # Saturated original jade-cyan (not merely broad dark trees).
        chromatic=(green>=130)&(blue>=110)&((green-red)>=30)
        num=int(chromatic.sum())
        log[key]={"jade_cyan_visible_pixels":num,"minimum":threshold,"roi":roi}
        if num<threshold:fail.append(f"{key}_INVISIBLE_{num}_lt_{threshold}")
    try:
        idle=get("v4-idle.png")
        expired=get("v4-expired.png")
        # Ignore the independently WALKING enemy at x>1020.
        a=idle[270:625,215:950]
        z=expired[270:625,215:950]
        diff=np.max(np.abs(a-z),axis=2)
        changed=int((diff>=15).sum())
        log["expired"]={"changed_pixels_in_caster_area":changed,"max_allowed":650}
        if changed>650:fail.append(f"persistent_ghost_or_burn_{changed}")
    except Exception as e:fail.append(str(e))
    log["gate"]="PASS" if not fail else "FAIL"
    log["failures"]=fail
    (root/"poi17-native-readability.json").write_text(json.dumps(log,ensure_ascii=False,indent=2))
    print(json.dumps(log,ensure_ascii=False))
    if fail:raise SystemExit("POI17_NATIVE_G36_READABILITY_FAIL "+",".join(fail))
    print("POI17_NATIVE_G36_READABILITY_PASS; G3.7 shadow-step meaning OWNER REVIEW ONLY")

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--evidence-dir",required=True,type=Path)
    main(p.parse_args().evidence_dir)
