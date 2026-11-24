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
    v2dir=SOURCE.parent/'v2_source'
    v2=json.loads((v2dir/'R1E_V2_SOURCE_MANIFEST.json').read_text())
    assert (v2['original_art_frames'],v2['derived_transition_frames'],v2['total_preview_samples'])==(12,12,24)
    assert v2['no_poster_extraction'] and v2['pve']=='HOLD'
    assert len(v2['original_sha256'])==12
    assert v2['original_sha256']==[digest(f) for f in files]
    v2atlas=Image.open(v2dir/'R1E_V2_24_atlas_4x6_RGBA.png')
    assert v2atlas.mode=='RGBA' and v2atlas.size==(2048,3072)
    assert digest(v2dir/'R1E_V2_24_atlas_4x6_RGBA.png')==v2['atlas_sha256']
    for i,f in enumerate(v2['frames']):
        frame=v2dir/f['file']
        assert digest(frame)==f['sha256']
        im=Image.open(frame)
        assert f['border_clear_8px'] and im.mode=='RGBA' and im.size==(512,512)
        assert im.tobytes()==v2atlas.crop(((i%4)*512,(i//4)*512,(i%4+1)*512,(i//4+1)*512)).tobytes()
        if i%2==0:
            assert im.tobytes()==Image.open(files[i//2]).convert('RGBA').tobytes()
    print('R1E_V2_SOURCE_EXACT_PASS 24_frames original12 unchanged derived12 atlas=2048x3072')
    print('R1E_SOURCE_EXACT_PASS archive=bede0519 12_rgba=PASS 512x512=PASS 2048x1536=PASS no_pve=true')

if __name__=='__main__':main()