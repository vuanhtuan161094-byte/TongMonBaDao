#!/usr/bin/env python3
"""Quick local source-data QA; does NOT claim real Godot/Chromium QA."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
D=ROOT/'godot/labs/combat_lab/fist14/r11_owner_review'
r=json.loads((D/'source/provenance.json').read_text(encoding='utf-8'))
source=D/r['master_gif'];atlas=D/r['derived_rgba_atlas']
assert hashlib.sha256(source.read_bytes()).hexdigest() == r['master_sha256']
assert hashlib.sha256(atlas.read_bytes()).hexdigest() == r['atlas_sha256']
assert r['owner_approved_scope']=='GIF_VISUAL_ONLY'
orig=Image.open(source); assert orig.n_frames==16 and orig.size==(309,309)
im=Image.open(atlas).convert('RGBA'); assert im.size==(1236,1236)
hashes=[]
for i in range(16):
    cel=im.crop(((i%4)*309,(i//4)*309,(i%4+1)*309,(i//4+1)*309))
    hashes.append(hashlib.sha256(cel.tobytes()).hexdigest())
    assert cel.getpixel((0,0))[3]==0
    assert cel.getchannel('A').getextrema()[1]>0
assert len(set(hashes)) == 16
scene=(D/'fist14_r11_owner_review.gd').read_text()
for needle in ['PROJECTILE_SPEED := 0.0','TARGET_LIMIT := 1','MARK_DURATION := 6.0', 'CAST_DURATION := 0.45',
              'review_replay','review_set_moving','review_set_bright','review_set_map_zoom',
              'FIST14_R11_GODOT_LAB_READY','REAL_MONSTER_PATH']:
    assert needle in scene, needle
assert '.github/workflows/' not in str(D)
assert (D/'fist14_r11_owner_review.tscn').is_file()
print('FIST14_R11_SOURCE_QA_PASS: 16/16 distinct RGBA frames, preserved original, mark contract, review API')
print('GODOT_NATIVE_NOT_RUN; ACTOR_TEMP_NU_DOC_TU; MONSTER_SOURCE_FROM_EXISTING_REPO; PVE_HOLD')
