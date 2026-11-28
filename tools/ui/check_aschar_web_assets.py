#!/usr/bin/env python3
"""Validate the canonical 24 actor source catalogue before exporting Web.
Do not mutate art, invent animations or treat archived showcase scenes as runtime.
"""
from pathlib import Path
import json
import re
import sys

root = Path(sys.argv[1])
registry = root / "src/presentation/p3/aschar_visual_identity_v1.gd"
text = registry.read_text(encoding="utf-8")
entries = dict((int(i), p) for i, p in re.findall(r'(\d+):"(res://[^"]+\.tres)"', text))
errors = []
if set(entries) != set(range(48, 72)):
    errors.append("expected exactly AS48 through AS71 in SOURCE_PATHS")
socket_root = root / "assets/p3/baked_candidates/weapon_library_v1/candidate/actor_sockets"
def check_path(value, label):
    if not value.startswith("res://"):
        errors.append(f"{label}: not a res:// path: {value}")
        return
    path = root / value[6:]
    if not path.is_file():
        errors.append(f"{label}: missing {value}")
    if "/labs/" in value or "/source_recreated/" in value or "_SOURCE_933_SNAPSHOT." in value or "/candidate/review/" in value:
        errors.append(f"{label}: depends on excluded review/source asset: {value}")

for actor, path in sorted(entries.items()):
    check_path(path, f"AS{actor}")
    source = root / path[6:]
    if not source.is_file():
        continue
    resource = source.read_text(encoding="utf-8")
    refs = re.findall(r'path="(res://[^"]+)"', resource)
    for ref in refs:
        check_path(ref, f"AS{actor} SpriteFrames")
    names = set(re.findall(r'"name"\s*:\s*&?"([^"]+)"', resource))
    required = {f"{action}_front" for action in ("idle", "walk", "attack", "cast", "hit", "downed")}
    if required - names:
        errors.append(f"AS{actor}: missing front clips {sorted(required - names)}")
    manifest = socket_root / f"AS{actor}_weapon_sockets_v9_3_candidate.json"
    if not manifest.is_file():
        errors.append(f"AS{actor}: missing socket manifest")
        continue
    data = json.loads(manifest.read_text(encoding="utf-8-sig"))
    for row in data.get("body_frames", []):
        if isinstance(row, dict) and row.get("path"):
            check_path(str(row["path"]), f"AS{actor} body frame")
    for direction, atlas in data.get("directional_atlases", {}).items():
        if isinstance(atlas, dict) and atlas.get("path"):
            check_path(str(atlas["path"]), f"AS{actor} {direction} atlas")
    print(f"AS{actor}: {len(names)} named clips, {len(refs)} SpriteFrames references")
# Verify that current production code does not name excluded historical snapshots/review paths.
for folder in ("src", "scenes"):
    for path in (root / folder).rglob("*"):
        if path.suffix not in (".gd", ".tscn", ".tres", ".json") or not path.is_file():
            continue
        content = path.read_text(encoding="utf-8", errors="replace")
        for ref in re.findall(r'res://[^"\s]+', content):
            if "_SOURCE_933_SNAPSHOT." in ref or "/weapon_library_v1/candidate/review/" in ref:
                errors.append(f"{path.relative_to(root)}: historical export exclusion referenced: {ref}")
if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(f"ASCHAR_WEB_ASSETS_FAIL {len(errors)}")
print(f"ASCHAR_WEB_ASSETS_PASS {len(entries)} canonical actor sources")
