#!/usr/bin/env python3
"""Fail-closed acceptance gate for the owner-approved TMB V4 female poison sprite.

This tool distinguishes static/structural checks from artist-reviewed motion and
official Godot runtime evidence. It never upgrades a generated warp to gameplay
animation simply because it has 240 frames.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import sys
import zipfile
from pathlib import Path

APPROVED_SHA256 = "435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118"
DIRECTIONS = ("front", "left", "right", "back")
ACTIONS = ("idle", "walk", "cast", "attack", "hit", "death")
REQUIRED_AUTHORED_PARTS = {
    "head", "neck", "torso", "left_upper_arm", "left_forearm",
    "right_upper_arm", "right_forearm", "left_thigh", "left_shin",
    "right_thigh", "right_shin", "hair", "robe"
}
WARP_METHODS = {
    "deterministic_nonrigid_whole_sprite_warp_not_skeletal_animation",
    "global_warp", "cutout_without_repaint", "per_frame_independent_ai"
}

def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def assess(package_path: Path, owner_master: Path | None = None) -> dict:
    errors = []
    evidence = {}
    try:
        with zipfile.ZipFile(package_path) as archive:
            names = archive.namelist()
            manifest_files = [n for n in names if n.endswith("/asset_manifest.json")]
            if len(manifest_files) != 1:
                raise ValueError("Expected exactly one /asset_manifest.json")
            manifest_path = manifest_files[0]
            base = manifest_path.rsplit("/", 1)[0] + "/"
            manifest = json.loads(archive.read(manifest_path))
            review = {}
            for name in [base + "VERIFIED_QA.json", base + "qa_visual_review.json"]:
                if name in names:
                    review = json.loads(archive.read(name))
                    break
            if manifest.get("source_sha256") != APPROVED_SHA256:
                errors.append("APPROVED_IDENTITY_SHA_MISMATCH")
            else:
                evidence["source_identity_sha"] = "MATCH"
            if owner_master is not None:
                if not owner_master.is_file() or sha256(owner_master.read_bytes()) != APPROVED_SHA256:
                    errors.append("MASTER_FILE_SHA_MISMATCH")
            if tuple(manifest.get("direction_order", [])) != DIRECTIONS:
                errors.append("FOUR_AUTHENTIC_DIRECTIONS_MISSING")
            else:
                evidence["directions"] = list(DIRECTIONS)
            frame_size = tuple(manifest.get("canvas", []))
            pivot = tuple(manifest.get("foot_pivot", []))
            if frame_size != (160, 192) or pivot != (80, 179):
                errors.append("CANVAS_OR_PIVOT_MISMATCH")
            if manifest.get("sprite_type") in WARP_METHODS:
                errors.append("NO_REAL_JOINT_MOTION_WARP_BASED")
            rig = manifest.get("rig", {})
            parts = set(rig.get("authored_parts", [])) if isinstance(rig, dict) else set()
            if not REQUIRED_AUTHORED_PARTS.issubset(parts):
                errors.append("AUTHORING_PARTS_OR_POSE_RIG_MISSING")
            atlases = manifest.get("atlases", {})
            missing = sorted(set(ACTIONS) - set(atlases))
            if missing:
                errors.append("CLIPS_MISSING:" + ",".join(missing))
            try:
                from PIL import Image
            except ImportError:
                errors.append("PILLOW_REQUIRED_FOR_PIXEL_CHECKS")
            else:
                cell_counts = {}
                for action in ACTIONS:
                    if action not in atlases:
                        continue
                    spec = atlases[action]
                    n = int(spec.get("frames_per_direction", 0))
                    file_name = spec.get("atlas")
                    if not isinstance(file_name, str) or "/" in file_name or "\\" in file_name:
                        errors.append(f"INVALID_ATLAS_PATH:{action}")
                        continue
                    if n < 1 or file_name not in [n.rsplit("/",1)[-1] for n in names]:
                        errors.append(f"MISSING_OR_EMPTY_ATLAS:{action}")
                        continue
                    zip_file = base + file_name
                    if zip_file not in names:
                        errors.append(f"ATLAS_NOT_AT_EXPECTED_PATH:{action}")
                        continue
                    raw = archive.read(zip_file)
                    if sha256(raw) != spec.get("sha256"):
                        errors.append(f"ATLAS_SHA_MISMATCH:{action}")
                        continue
                    image = Image.open(io.BytesIO(raw)).convert("RGBA")
                    if image.size != (160*n, 192*4):
                        errors.append(f"ATLAS_GRID_MISMATCH:{action}")
                        continue
                    if any(image.getpixel((x, y))[3] != 0 for x,y in [(0,0),(image.width-1,0),(0,image.height-1),(image.width-1,image.height-1)]):
                        errors.append(f"ATLAS_CORNER_ALPHA_INVALID:{action}")
                    cell_counts[action] = 4*n
                    for d in range(4):
                        row = []
                        for f in range(n):
                            frame = image.crop((f*160,d*192,(f+1)*160,(d+1)*192))
                            if not frame.getbbox():
                                errors.append(f"BLANK_FRAME:{action}:{d}:{f}")
                            row.append(frame.tobytes())
                        if action == "idle" and len(set(row)) != 1:
                            errors.append(f"IDLE_NOT_STATIONARY:{d}")
                evidence["frame_cells_verified"] = cell_counts
            # Negative acceptance: artist review and runtime proof must be explicit.
            if review.get("overall") != "ARTIST_VISUAL_ACCEPTED":
                errors.append("ARTIST_VISUAL_ACCEPTANCE_MISSING")
            semantic = review.get("semantic_motion", {})
            for action in ("walk", "cast", "attack", "hit", "death"):
                if semantic.get(action) != "PASS" if isinstance(semantic, dict) else True:
                    errors.append("SEMANTIC_POSE_QA_MISSING:" + action)
            runtime = manifest.get("runtime_qa", {})
            if not isinstance(runtime, dict) or runtime.get("engine") != "4.7.2.stable.official" or runtime.get("script_errors") != 0 or not runtime.get("video_sha256"):
                errors.append("GODOT_472_REAL_VIDEO_GATE_MISSING")
            if review.get("owner_final_approval") is not True:
                errors.append("OWNER_FINAL_VISUAL_APPROVAL_MISSING")
            evidence["art_method"] = manifest.get("sprite_type", "UNKNOWN")
    except (OSError, ValueError, zipfile.BadZipFile, KeyError, json.JSONDecodeError) as exc:
        errors.append("PACKAGE_READ_ERROR:" + str(exc))
    errors = sorted(set(errors))
    return {"asset":"tmb.v4.poison.female.01", "package":str(package_path),
            "decision":"REJECT_FOR_GAME" if errors else "ACCEPTABLE_FOR_SCOPED_INTEGRATION",
            "reasons":errors,"evidence":evidence}

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("package", type=Path)
    parser.add_argument("--owner-master", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = assess(args.package, args.owner_master)
    output = json.dumps(result, ensure_ascii=False, indent=2)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(output + "\n", encoding="utf-8")
    print(output)
    return 0 if result["decision"] == "ACCEPTABLE_FOR_SCOPED_INTEGRATION" else 1

if __name__ == "__main__":
    sys.exit(main())
