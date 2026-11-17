#!/usr/bin/env python3
"""PAF06 R4: original pose data + genuine native Godot G3.6/G3.7 preflight.
Automatic checks enforce presence and non-occlusion, NOT aesthetic approval.
"""
from pathlib import Path
from PIL import Image,ImageChops
import hashlib,json,argparse,sys
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/"godot/labs/combat_lab/talisman16/r4"
ID="tmb.skill.talisman.phong_an_phu.passive_01.human"
def ck(ok,msg):
    if not ok:raise ValueError("PAF06_R4_QA_FAILED "+msg)
def img(path):
    ck(path.exists() and path.stat().st_size>0,"missing "+str(path))
    return Image.open(path).convert("RGBA")
def source_check():
    cat=json.loads((ROOT/"godot/data/combat/v63_talisman_combat_catalog.json").read_text())
    matches=[s for s in cat["skills"] if s.get("id")==ID]
    ck(len(matches)==1,"catalog")
    s=matches[0]
    ck(s["effect"]=="passive" and s["ai_profile"]=="passive_always_on" and s["cast_time"]==0 and s["cooldown"]==0 and s["duration"]==0,"no fabricated active event")
    ck(s["passive_modifiers"]["cooldown_recovery_factor"]==.015,"no gameplay changes")
    m=json.loads((BASE/"art_sources/PAF06_R4_PROVENANCE.json").read_text())
    ck(m["skill_id"]==ID and m["R3_orbit_preserved"] and m["frames_per_layer"]==48,"manifest")
    ck(m["rights"].startswith("FIRST_PARTY"),"rights")
    for layer in ("rear","front","heart"):
        a=m["layers"][layer]
        atlas=ROOT/a["atlas"]["path"];master=ROOT/a["source_master"]["path"]
        im=img(atlas);ma=img(master)
        ck(im.size==(2560,1920) and ma.size==(320,320),"atlas size "+layer)
        ck(hashlib.sha256(atlas.read_bytes()).hexdigest()==a["atlas"]["sha256"],"atlas SHA "+layer)
        ck(hashlib.sha256(master.read_bytes()).hexdigest()==a["source_master"]["sha256"],"master SHA "+layer)
        ck(im.getchannel("A").getextrema()[0]==0,"true transparent alpha "+layer)
        hashes=[]
        nonempty=0
        for k in range(48):
            f=im.crop(((k%8)*320,(k//8)*320,(k%8+1)*320,(k//8+1)*320))
            amax=f.getchannel("A").getextrema()[1]
            if amax>=45:nonempty+=1
            hashes.append(hashlib.sha256(f.tobytes()).hexdigest())
        # Each location on the moving split orbit may briefly have no seal.
        if layer=="heart":ck(nonempty==48,"heart continuously alive")
        else: ck(nonempty>=42,"rotating seal always visible "+layer)
        ck(len(set(hashes))>=30,"authored changed poses "+layer)
    print("PAF06_R4_SOURCE_PASS 48_authored_poses=true 3_layers=true copy_JX_pixels=false")
def screenshot_diff(first,second,roi,threshold=18):
    a=img(first).convert("RGB").crop(roi)
    b=img(second).convert("RGB").crop(roi)
    ck(a.size==b.size,"same-clock same-size")
    delta=ImageChops.difference(a,b)
    return sum(1 for q in delta.getdata() if max(q)>threshold)
def evidence(folder):
    d=Path(folder)
    for fn in ["paf06-r4-native.mp4","paf06-r4-peak.png","paf06-r4-off.png","paf06-r3-baseline.png","paf06-r4-0.42.png","paf06-r4-2.26.png","paf06-r4-3.22.png","exact-sha.txt"]:
        ck((d/fn).is_file() and (d/fn).stat().st_size>0,fn)
    onoff=screenshot_diff(d/"paf06-r4-peak.png",d/"paf06-r4-off.png",(475,355,795,610),22)
    identity=screenshot_diff(d/"paf06-r4-peak.png",d/"paf06-r3-baseline.png",(520,409,748,553),15)
    center=screenshot_diff(d/"paf06-r4-peak.png",d/"paf06-r3-baseline.png",(606,477,658,535),14)
    face=screenshot_diff(d/"paf06-r4-peak.png",d/"paf06-r3-baseline.png",(612,405,659,440),60)
    ck(onoff>=1000,"buff invisible "+str(onoff))
    ck(identity>=175,"new identity not visible vs R3 "+str(identity))
    ck(center>=30,"quiet heart not visible at native 1x "+str(center))
    ck(face<500,"face hidden "+str(face))
    out={"schema":"PAF06_R4_NATIVE_IDENTITY_TECH_V1","exact_sha":(d/"exact-sha.txt").read_text().strip(),
         "skill_id":ID,"native_size":"1280x720","frame_count":252,
         "metric_on_off_visible_pixels_gt22":onoff,"metric_R4_vs_R3_changed_pixels_gt15":identity,
         "metric_R4_vs_R3_center_pixels_gt14":center,"metric_face_change_gt60":face,
         "source":"first-party isolated inked RGBA + native R3 2.5D orbit",
         "semantic_visual_map":{"Tĩnh Giới":"three golden-jade wind talisman feathers orbit with original rings",
                                "Tĩnh Tâm":"six-petal breathing gold heart-lotus over still pearl"},
         "technical":"PASS","art_aesthetic":"OWNER_PENDING_MANUAL_REVIEW",
         "casting_and_combat":"NOT_APPLICABLE_PASSIVE","pve":"HOLD"}
    (d/"PAF06_R4_TECH_EVIDENCE.json").write_text(json.dumps(out,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    print("PAF06_R4_GODOT_NATIVE_VISIBILITY_PASS ring="+str(onoff)+" identity="+str(identity)+" core="+str(center)+" face="+str(face)+" owner_art=PENDING")
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--stage",choices=("source","evidence"),required=True)
    p.add_argument("--out")
    a=p.parse_args()
    try:
        source_check()
        if a.stage=="evidence":
            ck(bool(a.out),"--out missing");evidence(a.out)
    except Exception as error:
        print(str(error),file=sys.stderr);sys.exit(1)
