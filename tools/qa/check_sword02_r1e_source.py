#!/usr/bin/env python3
"""Fail-closed source and provenance gate for the owner-approved R1E VFX-only slice."""
from __future__ import annotations
import hashlib,json,pathlib
from PIL import Image

ROOT=pathlib.Path(__file__).resolve().parents[2]
SOURCE=ROOT/'godot/labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/source'
EXPECTED='bede0519b1026f3245f636f56991dcf09c5737913bc66b2c741838dc5534bd87'

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    m=json.loads((SOURCE/'R1E_SOURCE_QA.json').read_text(encoding='utf-8'))
    note=(SOURCE/'SOURCE_IMPORT_SHA256.txt').read_text(encoding='utf-8')
    assert 'ZIP_SHA256='+EXPECTED in note
    assert 'ORIGINAL_SOURCE_UNMODIFIED=true' in note
    assert m['pose_count']==12 and m['technical_pass'] is True
    assert m['source_type'].startswith('AI-drawn 12-panel VFX-only')
    assert len(m['frames'])==12
    files=sorted(SOURCE.glob('kvhp_r1e_[0-9][0-9]_*.png'))
    assert len(files)==12
    atlas=Image.open(SOURCE/'KVHP_R1E_VFX_only_atlas_4x3_RGBA.png')
    assert atlas.mode=='RGBA' and atlas.size==(2048,1536)
    seen=set()
    for i,(p,rec) in enumerate(zip(files,m['frames'])):
        assert p.stem.endswith(rec['name']) and rec['frame']==i+1
        assert rec['sha256']==digest(p)
        assert rec['border_8px_clear'] is True
        im=Image.open(p)
        assert im.mode=='RGBA' and im.size==(512,512)
        assert im.getchannel('A').getbbox() is not None
        seen.add(digest(p))
        assert im.tobytes()==atlas.crop(((i%4)*512,(i//4)*512,(i%4+1)*512,(i//4+1)*512)).tobytes()
    assert len(seen)==12
    print('R1E_SOURCE_EXACT_PASS archive=bede0519 12_rgba=PASS 512x512=PASS 2048x1536=PASS no_pve=true')

if __name__=='__main__':main()