#!/usr/bin/env python3
"""Verify REAL committed AS48 Front-only sprite and V9.3 grips. No rig/approval."""
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ACTOR = ROOT / "godot/labs/character_family/aschar_v9_batch1"
LAB = ROOT / "godot/labs/visual_bridge_v1"


def digest(p):
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 256), b""):
            h.update(chunk)
    return h.hexdigest()


def dimensions(p):
    with p.open("rb") as f:
        head = f.read(26)
    assert head[:8] == b"\x89PNG\r\n\x1a\n", f"bad png: {p}"
    return struct.unpack(">II", head[16:24]), head[25]


def verify():
    contract = json.loads((ACTOR / "meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json").read_text())
    manifest = json.loads((LAB / "as48_sword_vfx_binding_lab.json").read_text())
    assert manifest["skill_id"] == "tmb.skill.sword.ngu_kiem.active_01.human"
    assert manifest["source_status"] == "SOURCE_PENDING"
    assert contract["direction"] == "Front" and contract["clip"] == "Attack_Front"
    assert contract["body_canvas_px"] == [400, 440]
    rows = contract["body_frames"]
    assert len(rows) == 4
    atlas = ACTOR / "assets/atlases/AS48_attack_front_consistency_v2_atlas.png"
    assert dimensions(atlas) == ((1600, 440), 6), "atlas not RGBA 4×400×440"
    poses = []
    for i, row in enumerate(rows):
        assert row["index"] == i
        f = ACTOR / f"assets/frames/AS48/attack_front_consistency_v2/attack_front_0{i}.png"
        assert f.is_file() and digest(f) == row["sha256"], f"source changed {i}"
        assert dimensions(f) == ((400, 440), 6), f"RGBA cel mismatch {i}"
        pt = row["grip_sockets"]["main_hand"]["body_grip_px"]
        assert 0 <= pt[0] < 400 and 0 <= pt[1] < 440
        poses.append(row["pose"])
    assert poses == ["WINDUP", "GUARD_RISE", "RELEASE", "RECOVERY"]
    weapon = contract["weapon_assets"]["jian_silver_candidate"]
    wpath = ACTOR / "assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png"
    assert wpath.is_file() and digest(wpath) == weapon["sha256"]
    assert dimensions(wpath) == (tuple(weapon["canvas_px"]), 6)
    assert (ROOT / "godot/assets/actors/v5_sa_monster_1113031_1/animations.tres").is_file()
    assert (ROOT / "godot/labs/combat_lab/combat_lab_v16_impact_glow.gdshader").is_file()
    print("AS48_REAL_SOURCE_PASS front_poses=4 grip=4 independent_sword=true real_monster=true")
    print("AS48_HOLDS other_directions=NOT_COMMITTED G3=SOURCE_PENDING OWNER_ART=PENDING PVE=HOLD")


if __name__ == "__main__":
    verify()
