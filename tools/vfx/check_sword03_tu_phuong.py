#!/usr/bin/env python3
"""Fail-closed G0/G3 reviewer for SWORD03. Never accepts poster extraction as source.
Contract checks can PASS with SOURCE_PENDING, but that is NOT art/asset PASS.
When SOURCE_READY, independently verifies per-frame SHA-256, real alpha and atlas,
then builds a source-only 1x dark/light review GIF. No Godot/PvE action.
"""
import argparse,hashlib,json
from pathlib import Path
from PIL import Image,ImageDraw

BASE=Path(__file__).resolve().parents[2]
SKILL="tmb.skill.sword.ngu_kiem.active_03.human"
ART=BASE/"godot/labs/combat_lab/sword_human_tu_phuong_phi_nhan"
CONTRACT=ART/"ART_CONTRACT.json"
CATALOG=BASE/"godot/data/combat/v63_sword_combat_catalog.json"
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def require(condition,label):
    if not condition:raise SystemExit("SWORD03_FAIL "+label)
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--output",type=Path,default=Path("sword03-review"))
    args=ap.parse_args()
    cfg=json.loads(CONTRACT.read_text(encoding="utf8"))
    catalog=json.loads(CATALOG.read_text(encoding="utf8"))
    entry=next((x for x in catalog["skills"] if x["id"]==SKILL),None)
    require(entry is not None,"MISSING_CANON")
    require(cfg["skill_id"]==SKILL and cfg["source"]["status"] in ("SOURCE_PENDING","SOURCE_READY"),"BAD_CONTRACT")
    for key,value in cfg["canon"].items():
        require(entry.get(key)==value, "CANON_MISMATCH_"+key)
    require(cfg["vfx_design"]["projectile_blades_visual"]==4 and cfg["canon"]["target_limit"]==3,"HIT_NOT_VISUAL")
    require(cfg["gates"]["pve"]=="HOLD" and cfg["gates"]["merge"]=="NO","UNSAFE_GATE")
    print("SWORD03_G0_CANON=PASS skill="+SKILL+" line_damage_targets=3 source="+cfg["source"]["status"])
    if cfg["source"]["status"]=="SOURCE_PENDING":
        require(not (ART/"source/SOURCE_MANIFEST.json").exists(),"PENDING_BUT_HAS_SOURCE_MANIFEST")
        print("SWORD03_SOURCE=NOT_EXECUTED art_pending=true no_poster=true no_godot=true PvE=HOLD")
        return
    src=ART/"source"
    m=json.loads((src/"SOURCE_MANIFEST.json").read_text(encoding="utf8"))
    require(m.get("skill_id")==SKILL and m.get("source_type")=="DIRECT_VFX_ONLY","INVALID_PROVENANCE")
    require(m.get("poster_extraction") is False and m.get("native_rgba") is True,"POSTER_OR_FAKE_ALPHA")
    require(len(m.get("frames",[]))==24,"REQUIRE_24_FRAMES")
    originals=sum(1 for f in m["frames"] if f.get("kind")=="DIRECT_VFX_ONLY")
    require(originals>=12,"INSUFFICIENT_DIRECT_PAINTED_CELS")
    for f in m["frames"]:
        require(f["kind"] in ("DIRECT_VFX_ONLY","DISCLOSED_INBETWEEN"),"INVALID_FRAME_SOURCE")
    images=[];hashes=[]
    for i,row in enumerate(m["frames"]):
        name=f"tpf_nhan_{i+1:02d}.png"
        require(row.get("file")==name,"FRAME_ORDER")
        path=src/name
        require(path.is_file(),"FRAME_MISSING_"+name)
        h=sha(path);require(row.get("sha256")==h,"SHA_MISMATCH_"+name);hashes.append(h)
        im=Image.open(path)
        require(im.mode=="RGBA" and im.size==(512,512),"BAD_FRAME_FORMAT_"+name)
        a=im.getchannel("A")
        require(a.getbbox() is not None,"EMPTY_FRAME_"+name)
        edges=[a.crop((0,0,512,8)),a.crop((0,504,512,512)),a.crop((0,0,8,512)),a.crop((504,0,512,512))]
        require(all(z.getbbox() is None for z in edges),"FRAME_BORDER_"+name)
        # Native RGBA alone is insufficient: AI may bake a translucent rectangular
        # white/grey matte into every cel. Reject that artifact, even if a later
        # 8px-padding pass makes the outermost frame border transparent.
        # A true isolated sword-energy sprite should preserve generous empty
        # space through the frame interior, not paint a semiopaque rectangle.
        inner=a.crop((56,56,456,456))
        hist=inner.histogram()
        opaque_area=sum(hist[17:]) / float(400*400)
        require(opaque_area < 0.75,"DIRTY_TRANSLUCENT_MATTE_"+name)
        corner_boxes=[
            (48,96,96,144),(416,96,464,144),
            (48,368,96,416),(416,368,464,416),
        ]
        empty_corners=0
        for rect in corner_boxes:
            hh=a.crop(rect).histogram()
            if sum(hh[17:]) < (48*48*0.20):
                empty_corners+=1
        require(empty_corners>=2,"RECTANGULAR_ALPHA_HAZE_"+name)
        images.append(im)
    require(len(set(hashes))==24,"DUPLICATE_FRAME")
    atlas=Image.open(src/"TPF_NHAN_24_atlas_RGBA.png")
    require(atlas.mode=="RGBA" and atlas.size==(2048,3072),"BAD_ATLAS")
    for i,im in enumerate(images):
        x=(i%4)*512;y=(i//4)*512
        require(im.tobytes()==atlas.crop((x,y,x+512,y+512)).tobytes(),"ATLAS_MISMATCH")
    args.output.mkdir(exist_ok=True,parents=True)
    frames=[]
    for i,im in enumerate(images):
        s=im.resize((174,174),Image.Resampling.LANCZOS)
        canvas=Image.new("RGB",(370,192),(14,24,38))
        for j,bg in enumerate(((14,24,38),(224,228,220))):
            tile=Image.new("RGBA",(174,174),(*bg,255))
            tile.alpha_composite(s)
            canvas.paste(tile.convert("RGB"),(10+184*j,5))
        ImageDraw.Draw(canvas).text((12,181),f"VFX SOURCE 1x {i+1:02d}/24",fill=(209,232,245))
        frames.append(canvas)
    gif=args.output/"SWORD03_1x_source_only.gif"
    frames[0].save(gif,save_all=True,append_images=frames[1:],duration=40,loop=0,optimize=False)
    print("SWORD03_G3_TECH=PASS frames=24 unique=true atlas=true 1x_gif="+str(gif))
    print("SWORD03_G3_ART=OWNER_REVIEW_REQUIRED; HUMAN_SOURCE_ONLY; PvE=HOLD")
if __name__=="__main__":main()
