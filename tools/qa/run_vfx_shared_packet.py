#!/usr/bin/env python3
"""One Godot 4.7.2 VFX V4 packet -> focused test -> optional real-native G3.5 proof.

No game writes, no art approvals, no hidden generator invocation and no rig.
The original independent school packet remains the source of contract truth.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import subprocess
import sys
from pathlib import Path

from validate_vfx_v4_packet import checked_path, read_json


def run(command: list[str], root: Path, path: Path, marker: str = "") -> None:
    completed = subprocess.run(command, cwd=root, text=True, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, errors="replace", check=False)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(completed.stdout, encoding="utf-8")
    print("VFX_SHARED_STEP=" + path.name + " exit=" + str(completed.returncode), flush=True)
    if completed.returncode or (marker and marker not in completed.stdout):
        print(completed.stdout[-4500:], file=sys.stderr, flush=True)
        raise RuntimeError("failed " + path.name + " (inspect preserved log)")
    if marker:
        print("VFX_SHARED_MARKER=" + marker, flush=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--packet", required=True, help="Existing V4 JSON under docs/operations/vfx_packets")
    parser.add_argument("--mode", choices=["focused", "g35", "full"], default="g35")
    parser.add_argument("--out", required=True)
    parser.add_argument("--sha", required=True)
    parser.add_argument("--seconds", type=float, default=0.0, help="0=auto; explicit full duration includes fade/expiry")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    out = Path(args.out).resolve()
    out.mkdir(parents=True, exist_ok=True)

    try:
        if not re.fullmatch(r"[0-9a-f]{40}", args.sha):
            raise ValueError("exact 40-hex SHA required")
        packet_path = checked_path(root, args.packet)
        expected_parent = root / "docs" / "operations" / "vfx_packets"
        if packet_path.parent != expected_parent.resolve() or packet_path.suffix != ".json":
            raise ValueError("only existing school-specific V4 packet JSON is allowed")
        packet = read_json(packet_path)
        for key in ["scene_path", "lab_script", "focused_test"]:
            checked_path(root, packet[key])
        focused_marker = packet["proof_contract"]["focused_marker"]
        native_marker = packet["proof_contract"]["native_marker"]
        phases = packet["time_contract"]["phases"]
        if len(phases) < 3 or any(not isinstance(x.get("at_seconds"), (int,float)) or
                                   float(x["at_seconds"]) < 0 for x in phases):
            raise ValueError("at least three valid native phase checkpoints required")
        if not all(re.fullmatch(r"[A-Za-z0-9_.-]+[.]png", str(p["file"])) for p in phases):
            raise ValueError("unsafe/invalid checkpoint file name")
        filename = packet["proof_contract"].get("video_filename", "v4-hf02-native.mp4")
        if not re.fullmatch(r"[A-Za-z0-9_.-]+[.]mp4", filename):
            raise ValueError("unsafe native movie name")
        head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
        if head != args.sha:
            raise ValueError("exact-SHA mismatch: expected " + args.sha + " actual " + head)
        if not math.isfinite(args.seconds) or args.seconds < 0.0 or args.seconds > 30.0:
            raise ValueError("seconds must be 0 (automatic) or between 0 and 30")
        print("VFX_SHARED_SOURCE_EXACT_SHA=" + head + " mode=" + args.mode + " school=" +
              packet["school"] + " skill=" + packet["skill_id"], flush=True)
        (out/"SOURCE_EXACT_SHA.txt").write_text(
            "SOURCE_SHA=" + head + "\nSKILL=" + packet["skill_id"] +
            "\nART=MANUAL_PENDING\nOWNER=PENDING\nPVE=HOLD\nANDROID=NOT_EXECUTED\n",
            encoding="utf-8")

        validate = [sys.executable, "tools/qa/validate_vfx_v4_packet.py", "--packet", args.packet]
        run(validate + ["--stage", "packet"], root, out/"packet.log", "VFX_V4_PACKET_TECHNICAL_PASS")
        run(validate + ["--stage", "assets"], root, out/"atlas.log", "VFX_V4_ASSETS_TECHNICAL_PASS")
        strict = ["bash", "tools/qa/run_godot_strict.sh"]
        run(strict + ["--headless", "--path", "godot", "--import"], root, out/"godot-import.log", "GODOT_STRICT_PASS")
        godot_script = "res://" + str(Path(packet["lab_script"]).relative_to("godot")).replace("\\", "/")
        test_script = "res://" + str(Path(packet["focused_test"]).relative_to("godot")).replace("\\", "/")
        scene = "res://" + str(Path(packet["scene_path"]).relative_to("godot")).replace("\\", "/")
        run(strict + ["--headless", "--path", "godot", "--check-only", "--script", godot_script],
            root, out/"godot-parse.log", "GODOT_STRICT_PASS")
        run(strict + ["--headless", "--path", "godot", "-s", test_script],
            root, out/"godot-focused.log", focused_marker)
        if args.mode == "focused":
            print("VFX_SHARED_FOCUSED_PASS SOURCE_EXACT_SHA=" + head + " OWNER=PENDING PVE=HOLD")
            return 0

        last_at = max(float(p["at_seconds"]) for p in phases)
        duration = args.seconds if args.seconds > 0 else (last_at + 0.50)
        if duration <= last_at + 0.03:
            raise ValueError("movie must extend past final phase checkpoint + 0.03s")
        frames = math.ceil(duration * 60.0)
        movie_raw = out/"godot-native.avi"
        run(["xvfb-run", "-a", "-s", "-screen 0 1280x720x24"] +
            strict + ["--path", "godot", "--resolution", "1280x720", "--fixed-fps", "60",
                      "--write-movie", str(movie_raw), "--quit-after", str(frames), scene],
            root, out/"godot-preflight.log", native_marker)
        movie = out/filename
        run(["ffmpeg","-y","-hide_banner","-loglevel","error","-i",str(movie_raw),
             "-pix_fmt","yuv420p","-c:v","libx264","-crf","17","-movflags",
             "+faststart",str(movie)],root,out/"encode.log")
        if not movie.is_file() or movie.stat().st_size <= 1000:
            raise RuntimeError("native movie missing/empty")
        movie_raw.unlink(missing_ok=True)
        for phase in phases:
            run(["ffmpeg","-y","-hide_banner","-loglevel","error",
                 "-ss",str(phase["at_seconds"]),"-i",str(movie),
                 "-frames:v","1",str(out/phase["file"])],root,
                out/("ffmpeg-"+phase["id"]+".log"))
        run(validate + ["--stage", "evidence", "--out", str(out), "--sha", head],
            root, out/"v4-evidence.log", "VFX_V4_EVIDENCE_TECHNICAL_PASS")
        signatures = []
        for item in [movie,*[out/p["file"] for p in phases]]:
            signatures.append(hashlib.sha256(item.read_bytes()).hexdigest() + "  " + item.name)
        (out/"SHA256.txt").write_text("\n".join(signatures)+"\n",encoding="utf-8")
        print("VFX_SHARED_NATIVE_TECH_PASS SOURCE_EXACT_SHA=" + head +
              " frames=" + str(frames) + " stage=" + args.mode +
              " OWNER_ART=PENDING PVE=HOLD ANDROID=NOT_EXECUTED",flush=True)
        return 0
    except (RuntimeError, KeyError, ValueError, TypeError, OSError,
            subprocess.CalledProcessError) as exc:
        print("VFX_SHARED_TECH_FAIL " + str(exc), file=sys.stderr, flush=True)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
