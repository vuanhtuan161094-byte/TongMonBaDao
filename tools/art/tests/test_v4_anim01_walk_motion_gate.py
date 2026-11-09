#!/usr/bin/env python3
"""Regression: a static 8-frame 'walk' must FAIL; true leg phases must pass technical checks."""
from __future__ import annotations
import importlib.util
import math
import tempfile
from pathlib import Path
from PIL import Image, ImageDraw

GATE = Path(__file__).resolve().parents[1] / "v4_anim01_walk_motion_gate.py"
spec = importlib.util.spec_from_file_location("walk_gate", GATE)
gate = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(gate)

def write_fixture(path: Path, moving: bool) -> None:
    atlas = Image.new("RGBA", (8*160,192))
    for index in range(8):
        im = Image.new("RGBA", (160,192))
        d = ImageDraw.Draw(im)
        d.ellipse((65,21,95,56), fill=(63,52,65,255))
        d.polygon([(61,56),(97,56),(101,124),(59,124)], fill=(55,57,52,255))
        if moving:
            phase = index * math.pi / 4
            x = round(6 * math.sin(phase))
            lift_l = round(4 * max(0,math.cos(phase)))
            lift_r = round(4 * max(0,-math.cos(phase)))
            d.line([(74,121),(74+x,165-lift_l),(70+x,178-lift_l)], fill=(88,83,56,255), width=7)
            d.line([(88,121),(88-x,165-lift_r),(92-x,178-lift_r)], fill=(92,86,61,255), width=7)
            d.line([(67+x,177-lift_l),(78+x,177-lift_l)], fill=(128,105,68,255), width=4)
            d.line([(88-x,177-lift_r),(103-x,177-lift_r)], fill=(131,105,64,255), width=4)
        else:
            d.line([(74,121),(74,178)], fill=(88,83,56,255), width=7)
            d.line([(88,121),(88,178)], fill=(92,86,61,255), width=7)
        atlas.alpha_composite(im, (160*index,0))
    atlas.save(path)

with tempfile.TemporaryDirectory() as directory:
    root=Path(directory)
    static=root/"static.png"
    moving=root/"moving.png"
    write_fixture(static,False)
    write_fixture(moving,True)
    bad=gate.assess(static)
    good=gate.assess(moving)
    assert bad["status"]=="FAIL", bad
    assert "DUPLICATE_WALK_FRAMES" in bad["errors"], bad
    assert "OPPOSING_LEG_CONTACT_NOT_VISIBLE" in bad["errors"], bad
    assert good["status"]=="TECHNICAL_PASS_ONLY", good
    assert not good["errors"], good
    assert good["foot_x_spread"]>=8,good
print("V4_WALK_GATE_REGRESSION_PASS static_rejected=1 authored_pose_fixture_tech_pass=1 checks=5")
