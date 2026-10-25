from __future__ import annotations
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ACTORS = ("1113028_1", "body_1110201", "body_1120402", "113104_5")
errors: list[str] = []
rows: list[dict] = []

for actor_id in ACTORS:
    folder = ROOT / "assets" / "actors" / actor_id
    manifest_path = folder / "asset.json"
    scene_path = folder / "actor.tscn"
    animation_path = folder / "animations.tres"
    if not manifest_path.is_file() or not scene_path.is_file() or not animation_path.is_file():
        errors.append(f"{actor_id}: missing actor.tscn, animations.tres, or asset.json")
        continue
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    file_hashes = data.get("file_sha256", {})
    for relative, expected in file_hashes.items():
        path = folder / relative
        if not path.is_file():
            errors.append(f"{actor_id}: missing packaged file {relative}")
            continue
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != expected:
            errors.append(f"{actor_id}: SHA mismatch for {relative}")
    clips = {clip.get("name"): clip for clip in data.get("clips", [])}
    for clip_name in ("stand", "walk"):
        if clip_name not in clips or int(clips[clip_name].get("frames", 0)) < 1:
            errors.append(f"{actor_id}: missing baked {clip_name} frames")
    for source in data.get("source", []):
        digest = str(source.get("sha256", ""))
        if not re.fullmatch(r"[0-9a-f]{64}", digest):
            errors.append(f"{actor_id}: invalid source hash in asset.json")
    rows.append({
        "id": actor_id,
        "canvas": data.get("canvas"),
        "foot_anchor": data.get("foot_anchor"),
        "fps": data.get("fps"),
        "clips": {name: clips[name].get("frames") for name in ("stand", "walk") if name in clips},
        "pack_files_hashed": len(file_hashes),
    })

lab_path = ROOT / "tools" / "disciple_asset_pilot_a1" / "lab.gd"
scene_path = ROOT / "tools" / "disciple_asset_pilot_a1" / "lab.tscn"
project_path = ROOT / "project.godot"
for path in (lab_path, scene_path, project_path, ROOT / "assets" / "background" / "stone_courtyard.png", ROOT / "assets" / "background" / "stone_variant.png"):
    if not path.is_file():
        errors.append(f"missing lab/project/background file: {path.relative_to(ROOT)}")
if lab_path.is_file():
    lab_text = lab_path.read_text(encoding="utf-8")
    for actor_id in ACTORS:
        if actor_id not in lab_text:
            errors.append(f"lab scene does not reference {actor_id}")
    for control in ("stand", "walk", "ZOOM_STEPS", "native source view only"):
        if control not in lab_text:
            errors.append(f"lab scene missing expected behavior marker: {control}")

report = {
    "result": "PASS_STATIC_PACK_AUDIT" if not errors else "FAIL_STATIC_PACK_AUDIT",
    "scope": "Copied pack files, metadata hashes, stand/walk clip declarations, and lab source references only; no Godot runtime execution.",
    "godot_runtime": "PENDING",
    "actors": rows,
    "errors": errors,
}
out = ROOT.parent.parent / "qa" / "static_preflight.json"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(report, ensure_ascii=False, indent=2))
sys.exit(1 if errors else 0)
