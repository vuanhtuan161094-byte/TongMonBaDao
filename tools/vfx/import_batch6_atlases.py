#!/usr/bin/env python3
"""Import owner-approved atlas bytes, fail closed on exact SHA. No art generation, no PvE."""
from pathlib import Path
import hashlib,json,zipfile,struct
ROOT=Path(__file__).resolve().parents[2]
TRANSFER=ROOT/".vfx_transfer/batch6_20261124"
DST=ROOT/"godot/labs/combat_lab/sword_batch6_20261124/source"
PARTS=[TRANSFER/f"part_{i:02d}.bin" for i in range(1,5)]
EXPECTED_ZIP="a4f83d26d46bd7b1eafdd01ba91ae0a79e561e67a19b95ea3fd2c0dfe8063767"
EXPECTED_ORIGINAL="6efe7d6938dc383582b308dc0b14715564724af0f6cd7aad1661002f5effa2e9"
FILES=[
 ("03","SWORD03_TU_PHUONG_PHI_NHAN_R3/source/TPF_NHAN_R3_ATLAS_24_RGBA.png","7f88e652d84e31ce3e746a366fd564e4fcf45dbba16e228a24f66e2ce3306175"),
 ("04","SWORD04_KIEM_QUANG_HOI_CHU/source/atlas_24_rgba.png","86f07ed5789370dc5aacbb9d201fc1d39bbd9b3ceeb73307f1d6ee252b33e42d"),
 ("05","SWORD05_VAN_KIEM_QUY_TONG/source/atlas_24_rgba.png","23a5906585fdc973b35c740c4a1aa2feb339ebdb19ce871cf2d131885024ff35"),
 ("06","SWORD06_TRAM_ANH_NHAT_TUYEN/source/atlas_24_rgba.png","52cab7a39f446614eb1b297bc3a2c980905dc0c302a053214f3c424009c509f8"),
 ("07","SWORD07_PHA_VAN_TRUC_TRAM/source/atlas_24_rgba.png","5401e9a93d2b32e910f07bd4afc5b4703c408e251e756343e2a283b6b8d672bc"),
 ("08","SWORD08_DOAN_THUY_KIEM_MANG/source/atlas_24_rgba.png","61eeecd743ca07de7d866fe9316fb0237115951ca9e08b746951ed4a6f25bb4a")
]
def digest(bs):return hashlib.sha256(bs).hexdigest()
def main():
    assert all(p.is_file() for p in PARTS),"Missing transferred part"
    data=b"".join(p.read_bytes() for p in PARTS)
    assert digest(data)==EXPECTED_ZIP,"ZIP_TRANSFER_SHA_FAIL"
    from io import BytesIO
    with zipfile.ZipFile(BytesIO(data)) as z:
        assert z.read("SOURCE_ZIP_SHA.txt").decode().strip()==EXPECTED_ORIGINAL
        status=json.loads(z.read("BATCH_STATUS.json"))
        assert status["owner_approved_count"]==6 and status["pve"]=="HOLD"
        DST.mkdir(parents=True,exist_ok=True)
        manifest={"schema":"tmb.sword6.runtime_atlases.v1","transfer_zip_sha256":EXPECTED_ZIP,"owner_approved_source_zip_sha256":EXPECTED_ORIGINAL,"source_only":True,"runtime_visual_status":"NOT_YET_TESTED","pve":"HOLD","files":[]}
        for tag,old,expected in FILES:
            raw=z.read(old)
            assert digest(raw)==expected,f"ATLAS_{tag}_SHA_FAIL"
            assert raw[:8]==b"\x89PNG\r\n\x1a\n"
            width,height=struct.unpack(">II",raw[16:24]);assert (width,height)==(2048,3072),(tag,width,height)
            target=DST/f"sword_{tag}_24f.png"
            target.write_bytes(raw)
            assert digest(target.read_bytes())==expected
            skill=next(s for s in status["skills"] if s["folder"]==old.split("/")[0])
            assert skill["atlas_sha256"]==expected
            manifest["files"].append({"tag":tag,"skill_id":skill["skill_id"],"file":target.name,"sha256":expected,"frames":24,"cell_px":[512,512],"atlas_px":[2048,3072],"owner_source_approved":True})
    (DST/"batch6_atlas_manifest.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print("BATCH6_EXACT_SHA_ATLASES_PASS=6/6 originals_unchanged=true PvE=HOLD")
if __name__=="__main__":main()
