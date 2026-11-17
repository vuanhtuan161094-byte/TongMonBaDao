#!/usr/bin/env python3
"""Native 1x PAF06 R5 sprite visibility and semantic distinction from R3."""
import argparse,json,hashlib,sys
from pathlib import Path
from PIL import Image,ImageChops
ROOT=Path(__file__).resolve().parents[2]
ID="tmb.skill.talisman.phong_an_phu.passive_01.human"
P=ROOT/"godot/labs/combat_lab/talisman16/r5/assets/paf06_r5_original_energy_sprites.png"
def ensure(ok,msg):
    if not ok:raise ValueError("PAF06_R5_FAIL "+msg)
def source():
    ensure(P.is_file(),"raster source")
    rgba=Image.open(P).convert("RGBA")
    ensure(rgba.size==(288,96),"3x96 sprite atlas")
    for i in range(3):
        channel=rgba.crop((i*96,0,(i+1)*96,96)).getchannel("A")
        ensure(channel.getextrema()[0]==0 and channel.getextrema()[1]>220,"transparent emissive master "+str(i))
    print("PAF06_R5_ORIGINAL_SPRITE_PASS three_independent_RBGA=true no_paper_card=true")
def check(out):
    d=Path(out)
    for p in ("r5-peak.png","r5-off.png","r5-r3-baseline.png","paf06-r5-native.mp4","r5-native.log"):
        ensure((d/p).is_file() and (d/p).stat().st_size>0,"evidence "+p)
    def diff(a,b,rect,threshold=20):
        aa=Image.open(d/a).convert("RGB").crop(rect)
        bb=Image.open(d/b).convert("RGB").crop(rect)
        return sum(max(pixel)>threshold for pixel in ImageChops.difference(aa,bb).getdata())
    visible=diff("r5-peak.png","r5-off.png",(479,311,792,600),22)
    identify=diff("r5-peak.png","r5-r3-baseline.png",(510,325,770,600),18)
    emblem=diff("r5-peak.png","r5-r3-baseline.png",(582,324,686,425),20)
    ensure(visible>750,"whole buff invisible")
    ensure(identify>300,"not distinguishable from R3")
    ensure(emblem>120,"signature WIND rune missing")
    print(f"PAF06_R5_GODOT_NATIVE_VISIBILITY_PASS visible={visible} identity={identify} emblem={emblem}")
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--stage",choices=("source","evidence"),required=True);p.add_argument("--out")
    a=p.parse_args()
    try:
        source()
        if a.stage=="evidence":
            ensure(bool(a.out),"need out path");check(a.out)
    except Exception as e:
        print(str(e),file=sys.stderr);sys.exit(1)
