#!/usr/bin/env python3
"""PAF06 R3 exact source + actual Godot 1x ON/OFF visual verification.
No fake cast/contact for passive-always-on. Technical PASS never means owner art PASS.
"""
from pathlib import Path
from PIL import Image,ImageChops
import argparse,hashlib,json,sys
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/"godot/labs/combat_lab/talisman16/r3"
ID="tmb.skill.talisman.phong_an_phu.passive_01.human"
def ck(ok,msg):
    if not ok: raise ValueError("PAF06_R3_QA_FAILED "+msg)
def image_file(path):
    ck(path.is_file() and path.stat().st_size>0,"file missing "+str(path))
    return Image.open(path).convert("RGBA")
def catalogue():
    c=json.loads((ROOT/"godot/data/combat/v63_talisman_combat_catalog.json").read_text())
    found=[x for x in c["skills"] if x.get("id")==ID]
    ck(len(found)==1,"canonical record once")
    record=found[0]
    for key,value in {"effect":"passive","element":"wind","ai_profile":"passive_always_on","target_limit":1,
                      "cast_time":0,"cooldown":0,"duration":0,"projectile_speed":0,"damage_ratio":0,"range":0}.items():
        ck(record[key]==value,"canonical no-fake-event "+key)
    ck(record["passive_modifiers"]["cooldown_recovery_factor"]==.015,"metadata")
def assets():
    catalogue()
    manifest=json.loads((BASE/"art_sources/PAF06_R3_RGBA_MANIFEST.json").read_text())
    ck(manifest["skill_id"]==ID and manifest["frames_per_layer"]==48,"original source declared")
    ck(manifest["rights"].startswith("FIRST_PARTY"),"original origin only")
    for name in ("rear","front","spark"):
        s=manifest["layers"][name]
        p=ROOT/s["atlas"]["path"];im=image_file(p)
        ck(im.size==(2560,1920),"atlas 8x6")
        ck(hashlib.sha256(p.read_bytes()).hexdigest()==s["atlas"]["sha256"],"atlas provenance SHA")
        ck(im.getchannel("A").getextrema()[0]==0,"transparent alpha")
        signatures=[];nonempty=0
        for k in range(48):
            f=im.crop((k%8*320,k//8*320,k%8*320+320,k//8*320+320))
            if f.getchannel("A").getextrema()[1]>=35:nonempty+=1
            signatures.append(hashlib.sha256(f.tobytes()).hexdigest())
        ck(nonempty==48,"all 48 source poses visible "+name)
        ck(len(set(signatures))>=40,"not enough actual changed key poses "+name)
        master=ROOT/s["master"]["path"]
        ck(hashlib.sha256(master.read_bytes()).hexdigest()==s["master"]["sha256"],"master source hash")
    print("PAF06_R3_SOURCE_PASS original_rgba=true layered_rear_front=true morph=48x3 no_unlicensed_pixels=true")
def evidence(d):
    for name in ["paf06-r3-native.mp4","paf06-r3-off.png","paf06-r3-peak.png","paf06-r3-turn.png","paf06-r3-front.png","paf06-r3-logs.txt","paf06-r3-focused.txt","exact-sha.txt"]:
        ck((d/name).is_file() and (d/name).stat().st_size>0,"native evidence "+name)
    on=image_file(d/"paf06-r3-peak.png").convert("RGB")
    off=image_file(d/"paf06-r3-off.png").convert("RGB")
    ck(on.size==off.size==(1280,720),"Godot native 1280x720")
    # Identical actor + enemy+game clock, only the passive graphic differs.
    box=(475,323,795,610)
    delta=ImageChops.difference(on.crop(box),off.crop(box))
    active=sum(1 for r,g,b in delta.getdata() if max(r,g,b)>24)
    ck(active>=850,"buff must be visibly present at 1x; changed pixels "+str(active))
    # Separately monitor head visibility; unlike a shield, buff must not blank face.
    head_delta=ImageChops.difference(on.crop((608,407,665,449)),off.crop((608,407,665,449)))
    overlap=sum(1 for c in head_delta.getdata() if max(c)>90)
    ck(overlap<780,"face overly occluded by buff; pixels "+str(overlap))
    info={"schema":"PAF06_R3_GODOT_NATIVE_TECH_EVIDENCE","sha":(d/"exact-sha.txt").read_text().strip(),
         "native_resolution":[1280,720],"source":"ORIGINAL_RGBA_NEAR_FAR_48POSES",
         "visible_delta_px_gt24":active,"head_strong_delta_px_gt90":overlap,
         "clocks":{"combat":"PASSIVE_ALWAYS_ON_NO_CAST","visual":"3S_ORBIT_LOOP","demo":"4.2S_NATIVE"},
         "technical":"PASS","owner_visual":"PENDING","pve":"HOLD","g3_5_cast_contact":"NOT_APPLICABLE_PASSIVE"}
    (d/"PAF06_R3_EXACT_SHA_RESULT.json").write_text(json.dumps(info,indent=2)+"\n")
    print("PAF06_R3_NATIVE_VISIBILITY_PASS changed_pixels="+str(active)+" head_occlusion="+str(overlap)+" technical_only=true")
if __name__=="__main__":
    a=argparse.ArgumentParser();a.add_argument("--stage",choices=["source","evidence"],required=True)
    a.add_argument("--dir")
    q=a.parse_args()
    try:
        assets()
        if q.stage=="evidence":
            ck(bool(q.dir),"native --dir required")
            evidence(Path(q.dir))
    except Exception as e:
        print(str(e),file=sys.stderr);sys.exit(1)
