"""Pinned external VFX acquisition; no combat or export changes."""
import csv, hashlib, json, os, re, time, urllib.request
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path("outputs/external_vfx_acquisition")
FLARE = "https://raw.githubusercontent.com/flareteam/flare-game/c641d2ac2801617f6be3e327454de39250d489b9/"
KANA = "https://raw.githubusercontent.com/kanaworksai-hue/kanaworks-sakuga-vfx/7cfc9e6bd6ecc0239f3c141e9c5c42cbdc8bb365/"
PNGS = "arrow_stuck arrows bear_trap blast bolas caltrops channel cleave dark_mist ember fireball freeze heal icicle immunity lightning plasmaball quake runes rupture shield shield_orange spark_blue spark_green spark_orange spark_red sparkle spear spikes spit stone throw_axe throw_knife thunderstrike".split()
ANIMS = PNGS + "bear_trap_trigger freeze_2 runes_blue runes_orange spark_green_loop spark_red_loop status_freeze".split()
def get(url, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent":"TMB-VFX-Acquisition"}), timeout=45) as r:
                data=r.read(24*1024*1024+1)
            if len(data)>24*1024*1024: raise ValueError("asset exceeds limit")
            path.write_bytes(data)
            return data
        except Exception:
            if attempt==2: raise
            time.sleep(2**attempt)
def put_json(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj,ensure_ascii=False,indent=2),encoding="utf-8")
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def inspect_png(path):
    with Image.open(path) as im:
        im.load()
        rgba=im.convert("RGBA")
        lo, hi=rgba.getchannel("A").getextrema()
        return {"size":list(im.size),"mode":im.mode,"has_transparency":lo<255,"nonempty":hi>0}
def parse_flare(path):
    image=None; sections=[]; current=None
    for line in path.read_text(encoding="utf-8").splitlines():
        line=line.strip()
        if not line or line.startswith("#"): continue
        if line.startswith("[") and line.endswith("]"):
            current={"name":line[1:-1],"frames":[]}; sections.append(current);continue
        if "=" not in line: continue
        k,v=line.split("=",1)
        if k=="image": image=v
        elif current is not None:
            if k=="frame":
                nums=[int(x.strip()) for x in v.split(",")]
                if len(nums)==8:
                    current["frames"].append({"index":nums[0],"direction":nums[1],"rect":nums[2:6],"offset":nums[6:8]})
            else: current["declared_"+k]=v
    return image,sections
def sheet(records):
    items=[]
    for r in records:
        if r.get("source")!="flare" or not r.get("image"):continue
        p=ROOT/"flare"/r["image"]
        if not p.is_file():continue
        with Image.open(p) as im:
            im=im.convert("RGBA")
            frames=[f for sec in r.get("animations",[]) for f in sec["frames"] if f["direction"]==0]
            if frames:
                f=frames[len(frames)//2]; x,y,w,h=f["rect"]; im=im.crop((x,y,x+w,y+h))
            im.thumbnail((150,100))
            items.append((r["id"],im.copy()))
    if not items:return
    out=Image.new("RGB",(800,140*((len(items)+4)//5)),(32,37,45));d=ImageDraw.Draw(out)
    for i,(name,im) in enumerate(items):
        x=(i%5)*160;y=(i//5)*140
        out.paste(im,(x+(160-im.width)//2,y+5),im);d.text((x+5,y+114),name,fill="white")
    out.save(ROOT/"flare_contact_sheet.jpg",quality=90)
def main():
    ROOT.mkdir(parents=True,exist_ok=True); records=[];errors=[]; hashes={}
    for name in ["LICENSE.txt","CREDITS.txt"]:
        get(FLARE+name,ROOT/"flare"/name)
    get(KANA+"LICENSE.md",ROOT/"kana_license.md")
    catalog=json.loads(get(KANA+"catalog.json",ROOT/"kana_catalog.json"))
    for name in PNGS:
        rel="images/powers/"+name+".png";p=ROOT/"flare"/rel
        try:
            get(FLARE+"mods/fantasycore/"+rel,p);meta=inspect_png(p)
            if not meta["nonempty"]: raise ValueError("empty image")
            sha=digest(p);records.append({"id":name,"source":"flare","image":rel,"sha256":sha,"duplicate_of":hashes.get(sha),"license":"CC-BY-SA-3.0","source_url":FLARE+"mods/fantasycore/"+rel,**meta,"animations":[]})
            hashes.setdefault(sha,name)
        except Exception as e:errors.append({"file":rel,"error":str(e)})
    byimage={r["image"]:r for r in records}
    for name in ANIMS:
        rel="animations/powers/"+name+".txt";p=ROOT/"flare"/rel
        try:
            get(FLARE+"mods/fantasycore/"+rel,p); image,sections=parse_flare(p)
            if image not in byimage: raise ValueError("unresolved image: "+str(image))
            rec=byimage[image]; W,H=rec["size"]
            for sec in sections:
                for f in sec["frames"]:
                    x,y,w,h=f["rect"]
                    if x<0 or y<0 or w<=0 or h<=0 or x+w>W or y+h>H:raise ValueError("frame outside atlas")
                sec["source_animation"]=rel;rec["animations"].append(sec)
        except Exception as e:errors.append({"file":rel,"error":str(e)})
    # Conditional asset license: index only, no raw redistribution in an acquisition artifact.
    for a in catalog["assets"]:
        records.append({"id":a["id"],"source":"kana","status":"CONDITIONAL_LICENSE_INDEX_ONLY","license":catalog["license"]["assets"],"source_url":KANA+"assets/"+a["element"]+"/"+a["id"]+"/"+a["id"]+".png","metadata":a})
    hints={"poison":["dark_mist","spit","spark_green"],"talisman":["runes","lightning","thunderstrike","fireball"],"sword":["cleave","spark_blue"],"bow":["arrows","arrow_stuck"],"fist":["blast","quake","rupture"],"blade":["cleave","throw_axe"],"dual_blade":["cleave","throw_knife"],"spear":["spear","rupture"],"palm":["blast","freeze","heal","fireball"],"curse":["dark_mist","runes","channel"],"formation":["runes","spikes","caltrops"],"summon":["channel","sparkle"]}
    ledger=Path("docs/operations/vfx_progress_20261126/HUMAN_204_VFX_STATUS.csv")
    with ledger.open(encoding="utf-8-sig",newline="") as f: skills=list(csv.DictReader(f))
    available={r["id"] for r in records if r["source"]=="flare" and r["animations"]}
    queue=[{"skill_id":r["skill_id"],"school":r["school"],"name":r["name_vi"],"effect":r["effect_declared"],"shape":r["shape_declared"],"existing_lab_count":r["dedicated_human_lab_scene_count"],"suggestions":[x for x in hints.get(r["school"],[]) if x in available],"status":"CANDIDATE_ONLY_REQUIRES_SEMANTIC_AND_NATIVE_REVIEW"} for r in skills]
    put_json(ROOT/"candidate_skill_queue.json",queue)
    put_json(ROOT/"inventory.json",{"records":records,"errors":errors,"flare_png_count":len(byimage),"kana_index_count":len(catalog["assets"]),"human_queue_count":len(queue),"runtime_integration":"NOT_PERFORMED"})
    sheet(records)
    print(json.dumps({"flare":len(byimage),"kana_index":len(catalog["assets"]),"human_queue":len(queue),"errors":errors},ensure_ascii=False))
    if len(byimage)!=len(PNGS) or len(queue)!=204 or errors:raise SystemExit(1)
if __name__=="__main__":main()
