#!/usr/bin/env python3
"""Fail-closed technical motion QA for TMB V4 female Walk, side/front.
Does not certify art or Godot. Intended as a strict preflight before import.
"""
from __future__ import annotations
import argparse, hashlib, json
from pathlib import Path
import numpy as np
from PIL import Image

APPROVED_MASTER_SHA = "435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118"
W, H = 160, 192

def assess(path: Path) -> dict:
    errors = []
    im = Image.open(path).convert("RGBA")
    if im.height != H or im.width % W or im.width // W < 8:
        return {"status": "FAIL", "errors": ["INVALID_DIMENSIONS"], "path": str(path)}
    count = im.width // W
    frames = np.asarray([im.crop((i*W, 0, (i+1)*W, H)) for i in range(count)])
    alpha = frames[:, :, :, 3] > 32
    top = []
    foot_bottom = []
    foot_x = []
    for i, mask in enumerate(alpha):
        y, x = np.where(mask)
        if len(x) == 0:
            errors.append("EMPTY_FRAME:%d" % i)
            continue
        top.append(int(y.min()))
        fy, fx = np.where(mask[H-28:, :])
        if len(fx) == 0:
            errors.append("FOOT_MISSING:%d" % i)
            continue
        foot_x.append(float(np.median(fx)))
        foot_bottom.append(int(fy.max() + H - 28))
        if mask[0,0] or mask[0,-1] or mask[-1,0] or mask[-1,-1]:
            errors.append("CORNER_ALPHA_CONTAMINATION")
    if len(top) == count and max(top)-min(top) > 3:
        errors.append("HEAD_BOB_OR_SCALE_DRIFT")
    if len(foot_bottom) == count and max(foot_bottom)-min(foot_bottom) > 5:
        errors.append("FOOT_FLOAT_OR_PIVOT_DRIFT")
    foot_span = max(foot_x)-min(foot_x) if len(foot_x) == count else 0
    if foot_span < 3:
        errors.append("FOOT_STEPPING_UNREADABLE")
    phases = []
    adjacent = []
    for i in range(count):
        a = alpha[i,125:,:]
        b = alpha[(i+1) % count,125:,:]
        adjacent.append(float(np.count_nonzero(a != b) / max(1, np.count_nonzero(a | b))))
        if i < count//2:
            opposite = alpha[i+count//2,125:,:]
            phases.append(float(np.count_nonzero(a != opposite) / max(1, np.count_nonzero(a | opposite))))
    if max(phases or [0]) < 0.10:
        errors.append("OPPOSING_LEG_CONTACT_NOT_VISIBLE")
    if max(adjacent or [1]) > 0.55:
        errors.append("FRAME_TO_FRAME_SILHOUETTE_JUMP")
    if len({f.tobytes() for f in frames}) != count:
        errors.append("DUPLICATE_WALK_FRAMES")
    return {
        "status": "FAIL" if errors else "TECHNICAL_PASS_ONLY",
        "path": str(path),
        "errors": sorted(set(errors)),
        "frames": count,
        "top_y_spread": max(top)-min(top) if top else None,
        "foot_bottom_spread": max(foot_bottom)-min(foot_bottom) if foot_bottom else None,
        "foot_x_spread": round(foot_span, 2),
        "opposite_leg_silhouette_delta": round(max(phases or [0]), 3),
        "max_adjacent_silhouette_delta": round(max(adjacent or [0]), 3),
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest()
    }

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("front", type=Path)
    parser.add_argument("side", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = {
        "approved_master_sha256": APPROVED_MASTER_SHA,
        "front": assess(args.front),
        "side": assess(args.side),
        "official_godot_472": "PENDING",
        "owner_visual_approval": "PENDING"
    }
    result["decision"] = "REJECT_FOR_GAME" if (
        result["front"]["status"] != "TECHNICAL_PASS_ONLY" or
        result["side"]["status"] != "TECHNICAL_PASS_ONLY"
    ) else "TECHNICAL_ONLY_GODOT_AND_ART_QA_PENDING"
    rendered = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered, encoding="utf-8")
    print(rendered)
    return 1 if result["decision"] == "REJECT_FOR_GAME" else 0

if __name__ == "__main__":
    raise SystemExit(main())
