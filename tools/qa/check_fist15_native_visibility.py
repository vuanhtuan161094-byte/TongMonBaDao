#!/usr/bin/env python3
"""FIST15 Godot 1x G3.6 minimum visibility from TRUE native screenshots.
This does not approve beauty; only authentic energy pixels at game scale.
"""
from pathlib import Path
from PIL import Image
import sys,numpy as np
d=Path(sys.argv[1])
regions={
    "charge":("v4-charge.png",(449,612,361,537),45),
    "peak":("v4-peak.png",(604,1026,205,580),150),
    "contact":("v4-contact.png",(614,1051,354,575),115)}
passed=True
for name,(path,(x1,x2,y1,y2),min_count) in regions.items():
    a=np.asarray(Image.open(d/path).convert("RGB"),dtype=np.float32)
    assert a.shape[:2]==(720,1280),(name,a.shape)
    roi=a[y1:y2,x1:x2,:]
    pink=(roi[:,:,0]>150)&(roi[:,:,1]>90)&(roi[:,:,2]>100)&(roi[:,:,0]>roi[:,:,1]*1.025)
    count=int(pink.sum())
    ok=count>=min_count
    print(f"FIST15_G36_{name.upper()} rgba_hot_light_pixels={count} minimum={min_count} {'PASS' if ok else 'FAIL'}")
    passed=passed and ok
print("FIST15_G36_MIN_VISIBILITY="+("PASS" if passed else "FAIL"))
if not passed:raise SystemExit(1)
