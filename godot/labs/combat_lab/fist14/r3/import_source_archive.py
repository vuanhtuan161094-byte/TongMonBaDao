#!/usr/bin/env python3
"""Fail-closed import of exact FIST14 R3 Library ZIP into FIST14-only r3.
Never touches existing R2 or other schools; hash integrity != owner approval.
"""
from __future__ import annotations
import argparse, hashlib, struct, zipfile
from pathlib import Path
ZIP_SHA="6762348b570cad988247e522403c00008c6a898a9df56caacfdafb3cc37a6edd"
SOURCE_SHA="e0006ceb6208cb7cb037d2909f2ca9d27e10f63b7d71871f53b6b55f4903b7b5"
PREFIX="FIST14_R3_WORK/"
SPECS={
"source/fist14_r3_original_imagegen_rgba_1774x887.png":(SOURCE_SHA,(1774,887)),
"assets/atlases/f14_r3_charge.png":("d988493f4050fe00fea81fcb85b1b04eb0077d46817a12a24eeb58bb39e43bab",(1280,640)),
"assets/atlases/f14_r3_flight.png":("e66aa4a90584e56236e3986cbf2ca0c94e01ef6a3db04d20bd1ad16198c98f45",(1280,960)),
"assets/atlases/f14_r3_contact.png":("d34b39c8432464fd918db4581190e104ad924672d239fb2f2d2622a00cd63dca",(1280,640)),
"assets/atlases/f14_r3_mark.png":("113babdf9fcd15bbe67330b526fc0e700c837b5f0e99f2eb4f9fb83735cc92cc",(1280,640)),
}
def sha(data: bytes)->str:return hashlib.sha256(data).hexdigest()
def check_png(data:bytes,dimensions:tuple[int,int])->None:
    if data[:8]!=b"\x89PNG\r\n\x1a\n" or data[12:16]!=b"IHDR":
        raise ValueError("source is not a PNG")
    w,h=struct.unpack(">II",data[16:24]);depth,colour=data[24],data[25]
    if (w,h)!=dimensions or depth!=8 or colour!=6:
        raise ValueError(f"unexpected PNG geometry/format {w}x{h} bitdepth={depth} colour={colour}")
def main():
    p=argparse.ArgumentParser()
    p.add_argument("--archive",type=Path,required=True)
    p.add_argument("--dest",type=Path,default=Path(__file__).resolve().parent)
    a=p.parse_args()
    if not a.archive.is_file():raise SystemExit("SOURCE_TRANSFER_BLOCKED: Library ZIP not materialized")
    if sha(a.archive.read_bytes())!=ZIP_SHA:raise SystemExit("FAIL: incorrect ZIP sha256")
    planned={}
    with zipfile.ZipFile(a.archive,"r") as z:
        wanted=set(SPECS)
        for name in z.namelist():
            if not name.startswith(PREFIX):continue
            rel=name[len(PREFIX):]
            if rel.startswith("assets/frames/") and rel.endswith(".png"):wanted.add(rel)
            if rel.startswith("assets/masters/") and rel.endswith(".png"):wanted.add(rel)
        frames=[x for x in wanted if x.startswith("assets/frames/")]
        if len(frames)!=36:raise SystemExit(f"FAIL: expected 36 keys, got {len(frames)}")
        for name in sorted(wanted):
            data=z.read(PREFIX+name)
            if name in SPECS:
                expected,dims=SPECS[name]
                if sha(data)!=expected:raise SystemExit(f"FAIL: sha mismatch for {name}")
                check_png(data,dims)
            elif not data.startswith(b"\x89PNG\r\n\x1a\n"):
                raise SystemExit(f"FAIL: corrupt PNG key {name}")
            dest=a.dest/name
            if dest.exists() and sha(dest.read_bytes())!=sha(data):
                raise SystemExit(f"FAIL: refusing to overwrite existing different source {dest}")
            planned[dest]=data
    for dest,data in planned.items():
        dest.parent.mkdir(parents=True,exist_ok=True)
        if not dest.exists():dest.write_bytes(data)
    print("FIST14_R3_SOURCE_IMPORT_PASS master_sha="+SOURCE_SHA+" candidates=36")
    print("This proves byte identity only. G3.5/G3.6/G3.7 and owner remain pending.")
if __name__=="__main__":main()
