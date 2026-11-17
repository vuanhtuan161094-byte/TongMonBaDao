#!/usr/bin/env python3
"""POI16 native-size visibility gate, measured on UNEDITED Godot 1280x720 captures.
This is NOT automatic artistic approval. It only blocks another near-invisible
R1B-style artifact from being promoted to visual review.
"""
import argparse
import json
from pathlib import Path
import numpy as np
from PIL import Image

# ROIs are *screen coordinates* in Godot native 1280x720, not crops resized.
# Each phase has separately justified minimum visible colored area in pixels.
PHASES = {
    "charge": {"file": "v4-charge.png", "roi": (235, 285, 435, 520), "min_bright": 300},
    "peak": {"file": "v4-peak.png", "roi": (637, 288, 1130, 570), "min_bright": 13000},
    "contact": {"file": "v4-contact.png", "roi": (637, 288, 1130, 570), "min_bright": 14500},
    "fade": {"file": "v4-fade.png", "roi": (637, 288, 1130, 570), "min_bright": 500},
}
def analyze(root):
    result={}
    failures=[]
    for phase,cfg in PHASES.items():
        path=root/cfg["file"]
        if not path.is_file():
            failures.append(f"missing_native_phase_{phase}")
            continue
        rgb=np.asarray(Image.open(path).convert("RGB"))
        if rgb.shape[:2]!=(720,1280):
            failures.append(f"not_native_1280x720_{phase}")
            continue
        x0,y0,x1,y1=cfg["roi"]
        roi=rgb[y0:y1,x0:x1].astype(np.int16)
        red,green,blue=(roi[:,:,k] for k in range(3))
        # Vivid jade-green/silver-teal life light, not general white UI pixels.
        hot=(green>=150)&((green-red)>=22)&((green-blue)>=-20)
        warm=(green>=168)&(blue>=145)&((green-red)>=12)
        saturated=(green>=120)&((green-red)>=24)&((green-blue)>=-28)
        result[phase]={
            "jade_bright_pixels":int(hot.sum()),
            "warm_core_pixels":int(warm.sum()),
            "green_mid_pixels":int(saturated.sum()),
            "minimum_bright_pixels":cfg["min_bright"],
            "roi":[x0,y0,x1,y1],
        }
        if int(hot.sum())<cfg["min_bright"]:
            failures.append(f"{phase}_barely_visible_{int(hot.sum())}_lt_{cfg['min_bright']}")
    expired=root/"v4-expired.png"
    if not expired.is_file():
        failures.append("missing_expired_frame")
    else:
        rgb=np.asarray(Image.open(expired).convert("RGB"))
        if rgb.shape[:2]!=(720,1280):
            failures.append("not_native_1280x720_expired")
        else:
            roi=rgb[288:570,637:1130].astype(np.int16)
            red,green,blue=(roi[:,:,k] for k in range(3))
            remaining=int(((green>=150)&((green-red)>=22)&((green-blue)>=-20)).sum())
            result["expired"]={"jade_bright_pixels":remaining,"maximum_allowed":200}
            if remaining>200:
                failures.append(f"false_persistent_healing_light_{remaining}")
    result["gate"]="PASS" if not failures else "FAIL"
    result["failures"]=failures
    (root/"poi16-native-readability.json").write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding="utf-8")
    print(json.dumps(result,ensure_ascii=False))
    if failures:
        raise SystemExit("POI16_NATIVE_READABILITY_FAIL "+",".join(failures))
    print("POI16_NATIVE_READABILITY_PASS at unscaled 1280x720; owner art gate PENDING")

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--evidence-dir",required=True,type=Path)
    args=parser.parse_args()
    analyze(args.evidence_dir)
