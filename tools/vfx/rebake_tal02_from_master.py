#!/usr/bin/env python3
"""Rebake a wide painted TAL02 primary lightning atlas from committed WEBP master.
Requires Pillow, NumPy, OpenCV; offline, deterministic, no downloaded assets.
Usage: python tools/vfx/rebake_tal02_from_master.py [repo_root]
"""
from pathlib import Path
from sys import argv
import numpy as np, cv2
from PIL import Image
root=Path(argv[1]) if len(argv)>1 else Path('/mnt/data')
assets=root/'godot/labs/combat_lab/talisman02/assets' if (root/'godot').exists() else root/'tal02_tal03_painted_assets'
source=Image.open(assets/'tal02_thunder_master.webp').convert('RGBA')
a=source.getchannel('A').point(lambda x:255 if x>=12 else 0)
bbox=a.getbbox()
assert bbox is not None
box=(max(0,bbox[0]-12),max(0,bbox[1]-9),min(source.width,bbox[2]+12),min(source.height,bbox[3]+9))
active=source.crop(box)
# Deliberate horizontal stretch turns the illustrated thunder brush into one continuous
# long line that reaches from the caster palm to the final demo target. No clip/UI box.
active=active.resize((952,196),Image.Resampling.LANCZOS)
beam=Image.new('RGBA',(1024,256),(0,0,0,0))
beam.alpha_composite(active,(36,28))
atlas=Image.new('RGBA',(4096,768),(0,0,0,0))
H,W=256,1024
for idx in range(10):
   ar=np.asarray(beam).copy()
   X,Y=np.meshgrid(np.arange(W,dtype=np.float32),np.arange(H,dtype=np.float32))
   e=np.sin(np.pi*X/(W-1))
   mapx=X+(2.1+idx*.18)*np.sin(Y/30+idx*.55)*e
   mapy=Y+(3.5+idx*.28)*np.sin(X/44+idx*.55)*e+(1.7+idx*.12)*np.sin(X/17-idx*.48)*e
   moved=cv2.remap(ar,mapx,mapy,cv2.INTER_LINEAR,borderMode=cv2.BORDER_CONSTANT,borderValue=(0,0,0,0)).astype(np.float32)
   progress=.11+.89*(idx+1)/10
   edge=np.clip((progress*W-X)/72+.5+np.sin(Y*.13+idx*.67)*.035,0,1)
   moved[:,:,3]*=edge*(.61+.39*np.sin(np.pi*(idx+1)/12))
   frame=Image.fromarray(np.clip(moved,0,255).astype(np.uint8),'RGBA')
   atlas.alpha_composite(frame,((idx%4)*1024,(idx//4)*256))
out=assets/'tal02_thunder_flipbook.webp'
atlas.save(out,quality=89,method=3)
print(f'BAKED_TAL02_PAINTED_PASS {out} 4x3 1024x256 bbox={bbox} bytes={out.stat().st_size}')