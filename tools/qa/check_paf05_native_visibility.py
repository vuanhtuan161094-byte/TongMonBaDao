#!/usr/bin/env python3
"""G3.6 minimum native screen-space visibility. NOT an aesthetic approval.
One baseline Godot frame & three phase screenshots, cropped in native 1280x720.
Checks moving luminous material differential rather than empty alpha atlas hashes.
"""
import argparse,sys,json
from PIL import Image
import numpy as np
ROI={
 'charge':(264,250,540,510),
 'peak':(570,178,1080,555),
 'contact':(610,280,1060,565),
}
def sample(path,box):
 a=np.asarray(Image.open(path).convert('RGB'),dtype=np.float32)
 assert a.shape==(720,1280,3),(path,a.shape)
 x1,y1,x2,y2=box
 return a[y1:y2,x1:x2]
def mask(a):
 r,g,b=a[...,0],a[...,1],a[...,2]
 jade=(g>135)&(g>r*1.11)&(b>105)&((g+b)/2>157)
 gold=(r>171)&(g>131)&(r>1.08*b)&(r>g*.99)
 white=(np.max(a,axis=2)>232)&(np.min(a,axis=2)>174)
 return jade|gold|white
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--dir',required=True);args=ap.parse_args()
 from pathlib import Path
 d=Path(args.dir);out={}
 for k,region in ROI.items():
  live=sample(d/f'v4-{k}.png',region)
  idle=sample(d/'v4-idle.png',region)
  A=mask(live);B=mask(idle)
  bright_live=int(np.count_nonzero(A));bright_idle=int(np.count_nonzero(B))
  # Robust raw bright count in a native screenshot, cannot be fooled by 1px asset.
  difference=bright_live-bright_idle
  contrast=float(np.quantile(np.max(live,axis=2),.95)-np.quantile(np.max(idle,axis=2),.95))
  visible=bright_live>=150 and difference>=40
  out[k]={'live_bright_colored_pixels':bright_live,'baseline_bright_colored_pixels':bright_idle,'excess_pixels':difference,'q95_luma_difference':round(contrast,2),'visibility_minimum_pass':visible}
 print('PAF05_NATIVE_VISIBILITY',json.dumps(out,ensure_ascii=False))
 if all(x['visibility_minimum_pass'] for x in out.values()):print('PAF05_G3_6_NATIVE_VISIBILITY_PASS')
 else:
  print('PAF05_G3_6_NATIVE_VISIBILITY_FAIL',file=sys.stderr);sys.exit(1)
