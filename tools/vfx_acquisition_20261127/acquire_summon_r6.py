"""Acquire FLARE's eight-direction wyvern actor sprites, not a rig."""
import hashlib,json,urllib.request
from pathlib import Path
from PIL import Image
ROOT=Path("outputs/external_summon_r6")
BASE="https://raw.githubusercontent.com/flareteam/flare-game/c641d2ac2801617f6be3e327454de39250d489b9/"
ACTIONS=["stance","run","swing","cast","dash_attack","hit","die"]
def get(rel,dest):
    dest.parent.mkdir(parents=True,exist_ok=True)
    with urllib.request.urlopen(BASE+rel,timeout=60) as r: b=r.read(12*1024*1024+1)
    if len(b)>12*1024*1024:raise ValueError("source limit")
    dest.write_bytes(b)
    return hashlib.sha256(b).hexdigest()
def main():
    ROOT.mkdir(parents=True,exist_ok=True)
    for name in ["LICENSE.txt","CREDITS.txt"]:get(name,ROOT/name)
    index={"source":BASE,"license":"CC BY-SA 3.0","status":"SOURCE_CANDIDATE_ONLY","candidate_role":"covenant_beast","not_for":["blade_spirit","guardian_construct"],"actions":{}}
    for action in ACTIONS:
        name=f"wyvern_air_{action}.png";p=ROOT/name
        sha=get("mods/fantasycore/images/enemies/wyvern_air/"+name,p)
        with Image.open(p) as im:
            im.load();assert im.convert("RGBA").getchannel("A").getextrema()[0]<255
            index["actions"][action]={"file":name,"sha256":sha,"size":list(im.size),"frames":[]}
    meta=ROOT/"wyvern_air.txt";get("mods/fantasycore/animations/enemies/wyvern_air.txt",meta)
    for line in meta.read_text().splitlines():
        if not line.startswith("frame="):continue
        a=line[6:].split(",")
        if len(a)!=9 or a[-1] not in index["actions"]:raise ValueError("invalid frame record")
        f,di,x,y,w,h,ox,oy=map(int,a[:8]);row=index["actions"][a[-1]]
        assert x>=0 and y>=0 and w>0 and h>0 and x+w<=row["size"][0] and y+h<=row["size"][1]
        row["frames"].append({"frame":f,"direction":di,"rect":[x,y,w,h],"offset":[ox,oy]})
    assert all({x["direction"] for x in r["frames"]}==set(range(8)) for r in index["actions"].values())
    (ROOT/"manifest.json").write_text(json.dumps(index,indent=2))
    print("SUMMON_R6_SOURCE_READY",len(index["actions"]),sum(len(x["frames"]) for x in index["actions"].values()))
if __name__=="__main__":main()
