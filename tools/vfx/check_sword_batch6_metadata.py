#!/usr/bin/env python3
"""Batch metadata guard. Exits 0 for verified G0 metadata while explicitly reporting SOURCE NOT STAGED; never promotes art gate."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=ROOT/"godot/labs/combat_lab/production_batch_20261124/BATCH_CANDIDATES.json"
j=json.loads(p.read_text(encoding="utf-8"))
cat=json.loads((ROOT/"godot/data/combat/v63_sword_combat_catalog.json").read_text(encoding="utf-8"))
assert j["candidate_frames_total"]==144 and len(j["skills"])==6
assert j["gates"]["g3_visual"]=="OWNER_REVIEW_PENDING"
assert j["delivery"]["github_binary_source"]=="NOT_STAGED"
assert j["restrictions"]["pve"]=="HOLD" and not j["restrictions"]["merge"]
assert not j["restrictions"]["codex_cloud"] and not j["restrictions"]["rig"]
for sk in j["skills"]:
    c=next((s for s in cat["skills"] if s["id"]==sk["id"]),None)
    assert c and c["shape"]==sk["shape"] and c["target_limit"]==sk["limit"],sk["id"]
    assert len(sk["atlas_sha256"])==64 and sk["frames"]==24
    assert sk["g3_art"]=="REVIEW_PENDING" and sk["pve"]=="HOLD"
print("BATCH6_G0_METADATA_PASS skills=6 canon_match=6")
print("BATCH6_BINARY_ASSET_CI=NOT_EXECUTED (actual source PNGs are NOT in GitHub)")
print("BATCH6_G3_OWNER=REVIEW_PENDING Godot=NOT_EXECUTED PvE=HOLD merge=NO")
