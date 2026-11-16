#!/usr/bin/env python3
"""Fail-closed *technical* VFX Production System V4 preflight.

This never declares art beautiful or owner-approved. Stage packet validates
catalogue/timing/provenance; assets checks baked atlas integrity; evidence
requires exact-SHA native Godot screenshots and focused moving-target proof.
"""
from __future__ import annotations

import argparse
import base64
import hashlib
import io
import json
import re
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageStat


class V4Failure(Exception):
    pass


def require(ok: bool, message: str) -> None:
    if not ok:
        raise V4Failure(message)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def checked_path(root: Path, value: str) -> Path:
    require(isinstance(value, str) and bool(value), "missing repository path")
    part = Path(value)
    require(not part.is_absolute() and ".." not in part.parts, "path must stay inside repo: " + value)
    target = (root / part).resolve()
    try:
        target.relative_to(root.resolve())
    except ValueError as exc:
        raise V4Failure("path escapes repo: " + value) from exc
    require(target.is_file() and target.stat().st_size > 0, "missing or empty file: " + value)
    return target


def read_json(path: Path) -> dict:
    try:
        obj = json.loads(path.read_text(encoding="utf-8"))
    except (ValueError, UnicodeError) as exc:
        raise V4Failure("invalid JSON: " + str(path)) from exc
    require(isinstance(obj, dict), "packet/catalogue must be an object")
    return obj


def equals_number(a: object, b: object) -> bool:
    return isinstance(a, (int, float)) and not isinstance(a, bool) and isinstance(b, (int, float)) and not isinstance(b, bool) and abs(float(a) - float(b)) < 1e-8


def validate_packet(root: Path, packet: dict) -> dict:
    require(packet.get("schema") == "tmb-vfx-production-system-v4.1", "wrong V4 packet schema")
    require(packet.get("skill_id") == "tmb.skill.talisman.hoa_phu.active_02.human", "HF02 packet identity mismatch")
    for name in ("scene_path", "lab_script", "focused_test"):
        checked_path(root, packet.get(name, ""))
    catalogue = read_json(checked_path(root, packet.get("catalogue_path", "")))
    matching = [skill for skill in catalogue.get("skills", []) if skill.get("id") == packet["skill_id"]]
    require(len(matching) == 1, "skill ID must appear exactly once in canonical catalogue")
    canonical = matching[0]
    declared = packet.get("declared_contract", {})
    for field in ("effect", "element", "shape", "target_limit", "hit_count", "range", "radius", "cast_time", "cooldown", "projectile_speed", "duration"):
        require(field in declared and field in canonical, "missing canonical contract field: " + field)
        a, b = declared[field], canonical[field]
        require(equals_number(a, b) if isinstance(b, (int, float)) else a == b, "catalogue mismatch for " + field + ": " + str(a) + " != " + str(b))
    require(canonical.get("enabled", False) is not True, "unexpected skill-level enabling")
    require(declared["projectile_speed"] == 0 and declared["shape"] == "circle" and declared["target_limit"] == 3, "HF02 no-projectile/circle/cap3 contract changed")

    timing = packet.get("time_contract", {})
    require(timing.get("combat_clock") == "CATALOGUE_GATED_NOT_LIVE", "must label gated combat clock")
    require(timing.get("vfx_clock") == "LAB_ONLY", "LAB visual clock not identified")
    require(timing.get("runtime_receipt_timestamp") == "RUNTIME_MAPPING_PENDING", "cannot invent a Combat V2 hit receipt")
    require(equals_number(timing.get("declared_cast_end_seconds"), declared["cast_time"]), "cast-end timing inconsistent with catalogue")
    require(equals_number(timing.get("declared_status_duration_seconds"), declared["duration"]), "status duration timing inconsistent with catalogue")
    phases = timing.get("phases")
    require(isinstance(phases, list) and len(phases) == 3, "V4 requires exactly charge, peak, contact preflight phases")
    require([p.get("id") for p in phases] == ["charge", "peak", "contact"], "preflight phase order mismatch")
    times = [p.get("at_seconds") for p in phases]
    require(all(isinstance(t, (int, float)) and t >= 0 for t in times), "preflight times missing")
    require(times[0] < declared["cast_time"] < times[1] < times[2] < timing.get("demo_loop_seconds", 0), "charge/peak/contact must be ordered and inside demonstration")
    require(times[2] > timing.get("simulated_hit_seconds", 10e9), "contact frame precedes simulated hit")
    require(all(isinstance(p.get("file"), str) and re.fullmatch(r"v4-[a-z-]+[.]png", p["file"]) for p in phases), "phase PNG filenames invalid")

    movement = packet.get("moving_target", {})
    require(movement.get("actor_animation") == "walk", "moving enemy must use actual walk animation")
    require(movement.get("locked_demo_target_index") == 0, "wrong locked demo target index")
    require(equals_number(movement.get("movement_from_seconds"), times[0]), "movement source timestamp mismatch")
    require(equals_number(movement.get("movement_to_seconds"), times[2]), "movement contact timestamp mismatch")
    require(movement.get("minimum_displacement_px", 0) >= 12, "moving-target displacement threshold missing")
    require(movement.get("receipt_claim") == "SIMULATED_VISUAL_ONLY", "demo contact is not an actual hit receipt")

    provenance = packet.get("provenance", {})
    require(provenance.get("source_class") == "FIRST_PARTY_OWNER_SUPPLIED_GENERATED_CONCEPT_CROP", "unverified source rights classification")
    require(provenance.get("master_quality_status") == "MANUAL_ART_REVIEW_REQUIRED", "source quality cannot be auto-approved")
    require(isinstance(provenance.get("rights_note"), str) and len(provenance["rights_note"]) > 30, "rights provenance note required")
    masters = provenance.get("master_files", [])
    require(isinstance(masters, list) and len(masters) >= 1, "must retain original first-party art sources")
    source_hashes = {}
    for master in masters:
        original = checked_path(root, master.get("path", ""))
        require(master.get("encoding") in ("base64-webp", "base64-png"), "source encoding unknown")
        try:
            data = base64.b64decode("".join(original.read_text(encoding="ascii").split()), validate=True)
            with Image.open(io.BytesIO(data)) as im:
                require(im.width >= 32 and im.height >= 32, "source art corrupt or too small to validate")
                expected = "WEBP" if master["encoding"] == "base64-webp" else "PNG"
                require(im.format == expected, "wrong source image format")
                size = [im.width, im.height]
        except (ValueError, UnicodeError, OSError) as exc:
            raise V4Failure("invalid source art: " + master.get("path", "")) from exc
        source_hashes[master["path"]] = {"sha256_decoded": sha(data), "size_px": size}
    generators = provenance.get("generators", [])
    require(isinstance(generators, list) and len(generators) >= 1, "reproducible bake generator required")
    for gen in generators:
        checked_path(root, gen)

    statuses = packet.get("gate_status", {})
    require(statuses.get("art") == "MANUAL_ART_REVIEW_REQUIRED", "no automatic art PASS")
    require(statuses.get("owner") == "OWNER_VISUAL_PENDING", "no automatic owner approval")
    require(statuses.get("live") == "PVE_INTEGRATION_HOLD", "no live integration authorization")
    require(statuses.get("device") == "PHYSICAL_QA_PENDING", "no device FPS claim")

    atlas = packet.get("atlases", [])
    require(isinstance(atlas, list) and len(atlas) >= 3, "atlas source manifest missing")
    for item in atlas:
        require(item.get("frames", 0) > 0 and item.get("columns", 0) > 0, "invalid atlas cell geometry")
        require(item.get("width", 0) == item["cell_width"] * item["columns"], "atlas width incompatible with cells")
        rows = (item["frames"] + item["columns"] - 1) // item["columns"]
        require(item.get("height") == rows * item.get("cell_height", 0), "atlas height incompatible with frames")
    return {"canonical_skill": packet["skill_id"], "source_masters": source_hashes, "timing": timing, "no_runtime_receipt": True}


def validate_assets(root: Path, packet: dict) -> dict:
    results = {}
    for spec in packet["atlases"]:
        name = spec["path"]
        path = checked_path(root, name)
        try:
            with Image.open(path) as opened:
                im = opened.convert("RGBA")
        except (OSError, ValueError) as exc:
            raise V4Failure("atlas cannot be opened: " + name) from exc
        require(list(im.size) == [spec["width"], spec["height"]], "atlas dimensions incorrect: " + name)
        require(im.getchannel("A").getextrema()[0] == 0, "no transparent pixel in atlas: " + name)
        signatures = []
        for frame in range(spec["frames"]):
            x = frame % spec["columns"] * spec["cell_width"]
            y = frame // spec["columns"] * spec["cell_height"]
            region = im.crop((x, y, x + spec["cell_width"], y + spec["cell_height"]))
            require(region.getchannel("A").getextrema()[1] > 0, "empty pose frame " + name + " #" + str(frame))
            signatures.append(sha(region.tobytes()))
        require(len(set(signatures)) == spec["frames"], "duplicate atlas bytes: " + name)
        results[name] = {"sha256_file": sha(path.read_bytes()), "size_px": list(im.size), "frames": spec["frames"], "byte_unique_only_not_motion_approved": True}
    return results


def video_probe(video: Path) -> dict:
    cmd = ["ffprobe", "-v", "error", "-select_streams", "v:0",
           "-show_entries", "stream=width,height:format=duration",
           "-of", "json", str(video)]
    try:
        data = json.loads(subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT))
    except (OSError, subprocess.CalledProcessError, ValueError) as exc:
        raise V4Failure("ffprobe failed for native Godot proof") from exc
    streams = data.get("streams", [])
    require(len(streams) == 1, "exactly one proof video stream required")
    stream = streams[0]
    require(stream.get("width") == 1280 and stream.get("height") == 720, "native video not 1280x720")
    require(float(data.get("format", {}).get("duration", 0)) >= 1.50, "native proof ends before moving contact")
    return {"width": stream["width"], "height": stream["height"], "duration": float(data["format"]["duration"])}


def validate_evidence(packet: dict, output: Path, git_sha: str) -> dict:
    require(re.fullmatch(r"[0-9a-f]{40}", git_sha) is not None, "exact source commit SHA required")
    require(output.is_dir(), "evidence directory missing")
    log = (output / "godot-focused.log")
    require(log.is_file() and "VFX_TAL07_FOCUSED_RESULT=PASS failures=0" in log.read_text(errors="replace"),
            "moving-target focused contract evidence missing or failed")
    movie_log = (output / "godot-preflight.log")
    require(movie_log.is_file() and "VFX_TAL07_READY" in movie_log.read_text(errors="replace"),
            "actual Godot LAB boot marker missing")
    video = output / "v4-hf02-native.mp4"
    require(video.is_file() and video.stat().st_size > 0, "native Godot proof video missing")
    info = video_probe(video)
    frames = []
    proofs = {}
    for phase in packet["time_contract"]["phases"]:
        path = output / phase["file"]
        require(path.is_file() and path.stat().st_size > 1000, "missing or blank proof: " + phase["file"])
        try:
            with Image.open(path) as opened:
                require(opened.format == "PNG" and opened.size == (1280, 720), "invalid native PNG: " + phase["file"])
                picture = opened.convert("RGB")
        except (OSError, ValueError) as exc:
            raise V4Failure("invalid native PNG: " + phase["file"]) from exc
        require(max(ImageStat.Stat(picture).stddev) >= 5.0, "flat-color or blank capture: " + phase["file"])
        frames.append(picture)
        proofs[phase["id"]] = {"at_seconds": phase["at_seconds"], "file": phase["file"], "sha256": sha(path.read_bytes()), "size_px": [1280, 720]}
    for i in range(1, len(frames)):
        # Structural progression only; never assert visual beauty from a pixel diff.
        require(ImageChops.difference(frames[i - 1], frames[i]).getbbox() is not None,
                "identical screenshots; stage progression unproven")
    return {"native_video": {"file": video.name, "sha256": sha(video.read_bytes()), **info},
            "frames": proofs, "focused_test": log.name, "native_log": movie_log.name,
            "motion_pixel_difference_only_not_art_approval": True,
            "actual_moving_target_checked_by_focused_Godot_contract": True,
            "human_art_review": "REQUIRED_NOT_AUTOMATED"}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", choices=["packet", "assets", "evidence"], required=True)
    ap.add_argument("--packet", required=True)
    ap.add_argument("--root", default=".")
    ap.add_argument("--out")
    ap.add_argument("--sha")
    args = ap.parse_args()
    root = Path(args.root).resolve()
    try:
        packet = read_json(checked_path(root, args.packet))
        proof = validate_packet(root, packet)
        if args.stage in ("assets", "evidence"):
            proof["atlas_integrity"] = validate_assets(root, packet)
        if args.stage == "evidence":
            require(bool(args.out) and bool(args.sha), "evidence requires --out and --sha")
            output = Path(args.out).resolve()
            proof["native_visual_evidence"] = validate_evidence(packet, output, args.sha)
            proof["source_commit_sha"] = args.sha
            proof["packet_file_sha256"] = sha(checked_path(root, args.packet).read_bytes())
            proof["status"] = {
                "v4_preflight_technical": "PASS",
                "source_fidelity": "MANUAL_ART_REVIEW_REQUIRED",
                "human_art_review": "NOT_APPROVED_BY_AUTOMATION",
                "owner_visual": "OWNER_VISUAL_PENDING",
                "runtime_hit_receipt": "RUNTIME_MAPPING_PENDING",
                "pve_integration": "HOLD",
                "physical_device": "PENDING",
            }
            output.mkdir(parents=True, exist_ok=True)
            (output / "V4_MANIFEST.json").write_text(json.dumps(proof, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
        print("VFX_V4_" + args.stage.upper() + "_TECHNICAL_PASS source=" + (args.sha or "preflight_not_rendered") + " owner=MANUAL_PENDING")
    except (V4Failure, KeyError, TypeError, IndexError) as exc:
        print("VFX_V4_" + args.stage.upper() + "_TECHNICAL_FAIL: " + str(exc), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
