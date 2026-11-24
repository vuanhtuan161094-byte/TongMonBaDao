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

def alpha_integrity(im,name,require_padding=True):
    """Measured alpha, not just PNG mode. Reject rectangular matte.
    Visual checks for text/actors still require manual G3 review.
    """
    require(im.mode=="RGBA","NOT_RGBA_"+name)
    a=im.getchannel("A")
    require(a.getbbox() is not None,"EMPTY_"+name)
    hist=a.histogram()
    total=im.width*im.height
    transparent=sum(hist[:16])/total
    require(transparent>=0.12,"BACKGROUND_NOT_TRANSPARENT_"+name)
    require(sum(hist[16:])/total<=0.88,"OPAQUE_ALPHA_MATTE_"+name)
    if require_padding:
        edges=[a.crop((0,0,im.width,8)),a.crop((0,im.height-8,im.width,im.height)),
               a.crop((0,0,8,im.height)),a.crop((im.width-8,0,im.width,im.height))]
        require(all(e.getbbox() is None for e in edges),"FRAME_BORDER_"+name)
    bbox=a.getbbox()
    x0,y0,x1,y1=bbox
    size=max(8,min(x1-x0,y1-y0)//6)
    corners=[(x0,y0,x0+size,y0+size),(x1-size,y0,x1,y0+size),
             (x0,y1-size,x0+size,y1),(x1-size,y1-size,x1,y1)]
    empties=sum(sum(a.crop(r).histogram()[17:])<size*size*0.2 for r in corners)
    require(empties>=2,"RECTANGULAR_INTERIOR_MATTE_"+name)
    return {"transparent_fraction":round(transparent,4),"bbox":bbox}

def selftest_alpha():
    """Positive/negative tests: a transparent isolated graphic vs fake alpha matte."""
    good=Image.new("RGBA",(512,512),(14,32,56,0))
    ImageDraw.Draw(good).ellipse((134,134,378,378),fill=(164,224,255,220))
    alpha_integrity(good,"POSITIVE_FIXTURE")
    bad=Image.new("RGBA",(512,512),(180,198,219,185))
    try:
        alpha_integrity(bad,"OPAQUE_MATTE_FIXTURE",require_padding=False)
        raise AssertionError("BAD_MATTE_WAS_ACCEPTED")
    except SystemExit as e:
        require(str(e).startswith("SWORD03_FAIL BACKGROUND_NOT_TRANSPARENT"),"WRONG_MATTE_FAIL_REASON")
    padded=Image.new("RGBA",(512,512))
    ImageDraw.Draw(padded).rectangle((12,12,499,499),fill=(180,198,219,185))
    try:
        alpha_integrity(padded,"PADDED_MATTE_FIXTURE")
        raise AssertionError("PADDED_BAD_MATTE_WAS_ACCEPTED")
    except SystemExit as e:
        require("RECTANGULAR_INTERIOR_MATTE_" in str(e),"PADDED_MATTE_NOT_CAUGHT")
    print("SWORD03_ALPHA_SELFTEST=PASS true_transparent=PASS solid_matte=REJECT padded_matte=REJECT")

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--output",type=Path,default=Path("sword03-review"))
    ap.add_argument("--selftest",action="store_true",help="Run real alpha fail-closed tests; independent of art source")
    args=ap.parse_args()
    if args.selftest:
        selftest_alpha()
        return
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
    provenance=m.get("provenance",{})
    require(provenance.get("asset_type")=="PRODUCTION_GAME_SPRITE","NOT_PRODUCTION_ASSET")
    require(provenance.get("background_mode")=="TRANSPARENT_EXPLICIT","BACKGROUND_MODE_NOT_SET")
    require(provenance.get("master_kind") in ("ONE_APPROVED_SEED_PLUS_EDITS","DIRECT_ANIMATION_STRIP"),
            "SOURCE_MASTER_KIND_INVALID")
    require(provenance.get("source_contains_labels") is False and provenance.get("source_contains_actor") is False,
            "INVALID_SOURCE_CONTENT")
    require(provenance.get("native_alpha_not_chroma_key") is True,"FAKE_ALPHA_OR_CHROMA_KEY")
    master=src/provenance.get("master_file","")
    require(master.is_file() and master.suffix.lower()==".png","SOURCE_MASTER_MISSING")
    require(sha(master)==provenance.get("master_sha256"),"SOURCE_MASTER_SHA_MISMATCH")
    alpha_integrity(Image.open(master),"MASTER",require_padding=False)
    # These are provenance declarations, not computer-vision detection of text.
    # G3 human visual inspection is mandatory after technical source QA.

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
        alpha_integrity(im,name)
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
    print("SWORD03_G3_TECH=PASS frames=24 unique=true alpha_verified=true provenance_verified=true atlas=true 1x_gif="+str(gif))
    print("SWORD03_G3_ART=OWNER_REVIEW_REQUIRED; HUMAN_SOURCE_ONLY; PvE=HOLD")
if __name__=="__main__":main()
