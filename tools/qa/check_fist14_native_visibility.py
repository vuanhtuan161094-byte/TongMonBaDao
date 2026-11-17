#!/usr/bin/env python3
"""FIST14 semantic hero minimum visibility in REAL 1280x720 native Godot PNG."""
from pathlib import Path
from PIL import Image
import sys
import numpy as np
d=Path(sys.argv[1])
limits={"charge":((430,625,350,540),90),
        "peak":((475,800,340,555),260),
        "contact":((595,822,354,560),170)}
passed=True
for name,((x1,x2,y1,y2),need) in limits.items():
    p=np.array(Image.open(d/f'v4-{name}.png').convert('RGB'),dtype=np.float32)
    assert p.shape[:2]==(720,1280)
    a=p[y1:y2,x1:x2,:]
    red=(a[:,:,0]>106)&(a[:,:,0]>a[:,:,1]*1.40)&(a[:,:,0]>a[:,:,2]*1.16)
    cnt=int(red.sum())
    ok=cnt>=need
    print(f"FIST14_G36_{name.upper()} red_energy_pixels={cnt} minimum={need} {'PASS' if ok else 'FAIL'}")
    passed=passed and ok
print("FIST14_G36_MIN_VISIBILITY="+("PASS" if passed else "FAIL"))
if not passed:raise SystemExit(1)

if len(sys.argv)>2 and sys.argv[2]=='status':
    p=np.array(Image.open(d/'frame-3.6.png').convert('RGB'),dtype=np.float32)
    # Definite crimson-white scar must remain visible on torso at 1x.
    a=p[445:540,690:820,:]
    hit=(a[:,:,0]>158)&(a[:,:,0]>a[:,:,1]*1.20)&(a[:,:,0]>a[:,:,2]*1.12)
    cnt=int(hit.sum())
    ok=cnt>=65
    print(f"FIST14_G36_STATUS_3P6 red_light_pixels={cnt} minimum=65 {'PASS' if ok else 'FAIL'}")
    if not ok:raise SystemExit(1)
