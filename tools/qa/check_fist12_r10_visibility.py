#!/usr/bin/env python3
"""FIST12 R10 G3.6 gate: actual screen-space native Godot energy visibility."""
import sys
from pathlib import Path
from PIL import Image
import numpy as np
root=Path(sys.argv[1])
ROIS={
 "charge":("v4-charge.png",(448,540,400,495),110),
 "peak":("v4-peak.png",(555,755,405,535),350),
 "contact":("v4-contact.png",(555,770,405,545),450)
}
overall=True
for name,(filename,(x1,x2,y1,y2),minimum) in ROIS.items():
    pix=np.asarray(Image.open(root/filename).convert('RGB'),dtype=np.float32)
    assert pix.shape[:2]==(720,1280),(name,pix.shape)
    roi=pix[y1:y2,x1:x2,:]
    mask=(roi[:,:,0]>95)&(roi[:,:,0]>roi[:,:,1]*1.50)&(roi[:,:,0]>roi[:,:,2]*1.20)
    n=int(mask.sum())
    passed=n>=minimum
    print(f"FIST12_R10_G36 {name} red_energy_pixels={n} min={minimum} roi={x1},{y1}-{x2},{y2} status={'PASS' if passed else 'FAIL'}")
    overall=overall and passed
print("FIST12_R10_G36_MINIMUM_VISIBILITY="+("PASS" if overall else "FAIL"))
if not overall:sys.exit(1)
