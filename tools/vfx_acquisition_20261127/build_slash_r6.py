"""Pin CC0 slash archive, build 24 true-alpha cels into four runtime atlases.
No fabricated frames, no game authority edits, no standalone hero approval."""
import hashlib,io,json,urllib.request,zipfile
from pathlib import Path
from PIL import Image,ImageDraw
URL="https://opengameart.org/sites/default/files/Everything_0.zip"
PIN="163eb4e4d41385f3b888e7176c6da077d0e7fa7c101da96bbaa4645a2ec9d673"
ROOT=Path("godot/assets/p3/vfx/external_slash_r6")
OUT=Path("outputs/external_slash_r6")
PLAN=Path("tools/vfx_acquisition_20261127/r6_exact_skill_queue.json")
INDEX=Path("godot/data/presentation/pve_external_slash_r6.json")
CLIPS={"purple_2":("Alternative 1","Alternative_1",2),"blue_3":("Alternative 2","Alternative_2",3),"blue_5":("Alternative 2","Alternative_2",5),"fire_1":("Alternative 3","Alternative_3",1)}
def hash_bytes(b):return hashlib.sha256(b).hexdigest()
def main():
    ROOT.mkdir(parents=True,exist_ok=True);OUT.mkdir(parents=True,exist_ok=True)
    with urllib.request.urlopen(URL,timeout=90) as resp: data=resp.read(4*1024*1024+1)
    if hash_bytes(data)!=PIN:raise ValueError("source sha mismatch")
    z=zipfile.ZipFile(io.BytesIO(data)); manifest={}
    for key,(folder,prefix,group) in CLIPS.items():
        atlas=Image.new("RGBA",(6*128,152));paths=[];hashes=[]
        for i in range(6):
            frame=(group-1)*6+i+1
            member=f"{folder}/{group}/{prefix}_{frame:02d}.png"
            b=z.read(member)
            with Image.open(io.BytesIO(b)) as im:
                if im.mode!="RGBA" or im.width>128 or im.height>150 or im.getchannel("A").getbbox() is None:raise ValueError("invalid alpha source "+member)
                if im.getchannel("A").getextrema()[0]==255:raise ValueError("opaque source "+member)
                # Align source canvas without scaling or moving each visible envelope independently.
                atlas.paste(im,(128*i+(128-im.width)//2,1))
            paths.append(member);hashes.append(hash_bytes(b))
        if len(set(hashes))<6:raise ValueError("duplicate cels")
        dest=ROOT/(key+".png");atlas.save(dest,optimize=True)
        manifest[key]={"source_members":paths,"frame_sha256":hashes,"atlas_sha256":hash_bytes(dest.read_bytes()),"rects":[[128*i,0,128,152] for i in range(6)],"fps":18,"pivot":[64,76],"license":"CC0","source":URL,"author":"Cethiel"}
    plan=json.loads(PLAN.read_text());bindings={}
    for x in plan["slash_candidates"]:
        clip=x["clip"];m=manifest[clip]
        frames=[{"path":"res://assets/p3/vfx/external_slash_r6/"+clip+".png","region":b} for b in m["rects"]]
        bindings[x["skill_id"]]={"school":x["school"],"effect":x["effect"],"shape":x["shape"],"limit":x["limit"],"mechanic":"line" if x["shape"]=="line" else "melee","external_auxiliary":True,"source_id":clip,"source_credit":"Cethiel / CC0","source_url":URL,"source_sha256":m["atlas_sha256"],"phases":{"contact":{"frames":frames,"fps":18,"loop":False,"width":110,"angle_offset":0.785398 if clip=="blue_5" else 0}},"receipts":{"v63_skill_hit":"contact"},"status":"CONTACT_ACCENT_ONLY_OWNER_ART_PENDING"}
    assert len(bindings)==16
    INDEX.write_text(json.dumps({"schema":"tmb.external_slash_r6.v1","scope":"exact positive hit receipt contact accent only; default preview off; does not replace skill choreography","bindings":bindings},indent=2),encoding="utf-8")
    (ROOT/"PROVENANCE.json").write_text(json.dumps({"archive_sha256":PIN,"source_page":"https://opengameart.org/content/weapon-slash-effect","clips":manifest},indent=2))
    (OUT/"build_receipt.json").write_text(json.dumps({"clip_count":len(manifest),"frame_count":24,"bindings":len(bindings),"source":URL},indent=2))
    print("R6_SLASH_READY",len(bindings),24)
if __name__=="__main__":main()
