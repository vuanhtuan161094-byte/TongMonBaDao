#!/usr/bin/env python3
"""Stage a TINY export-only Godot Web project with real existing AS48/VFX sources.

The output is ephemeral CI build material, NOT a second game or a source fork.
Character art is never changed; only read and copied byte-for-byte to staging.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path

SOURCE_FILES = (
    "labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd",
    "labs/visual_bridge_v1/as48_sword_anchor_lab.gd",
    "labs/visual_bridge_v1/as48_sword_anchor_lab.tscn",
    "labs/visual_bridge_v1/as48_sword_vfx_binding_lab.json",
    "labs/visual_bridge_v1/vfx_web_review_hub.gd",
    "labs/visual_bridge_v1/vfx_web_review_hub.tscn",
    "labs/combat_lab/combat_lab_v16_impact_glow.gdshader",
    "labs/character_family/aschar_v9_batch1/assets/atlases/AS48_attack_front_consistency_v2_atlas.png",
    "labs/character_family/aschar_v9_batch1/assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png",
    "labs/character_family/aschar_v9_batch1/meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json",
    "assets/actors/v5_sa_monster_1113031_1/animations.tres",
    "assets/actors/v5_sa_monster_1113031_1/atlas_000.webp",
    "assets/actors/v5_sa_monster_1113031_1/atlas_001.webp",
    "assets/actors/v5_sa_monster_1113031_1/atlas_002.webp",
)

PROJECT = '''config_version=5

[application]
config/name="Tong Mon Ba Dao — VFX Review (Lab Only)"
run/main_scene="res://labs/visual_bridge_v1/vfx_web_review_hub.tscn"
config/features=PackedStringArray("4.7")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
'''

# Raw .png and .json are intentionally present for FileAccess in the browser.
# .webp is referenced by SpriteFrames and imported as a Godot Texture2D.
EXPORT = '''[preset.0]

name="Web"
platform="Web"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter="*.json,*.png,*.webp"
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.0.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=false
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
progressive_web_app/ensure_cross_origin_isolation_headers=false
'''

def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=Path("godot"))
    parser.add_argument("--destination", type=Path, required=True)
    args = parser.parse_args()
    root, dest = args.source.resolve(), args.destination.resolve()
    if root == dest or root in dest.parents:
        raise SystemExit("Staging must be outside the source Godot project")
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    catalog_path = root.parent / "docs/operations/vfx_web_catalog_v1.json"
    if not catalog_path.is_file():
        raise SystemExit("VFX_WEB_CATALOG_MISSING")
    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    if catalog.get("schema") != "tmb.vfx_web_review_catalog.v1":
        raise SystemExit("VFX_WEB_CATALOG_BAD_SCHEMA")
    entries = catalog.get("entries")
    if not isinstance(entries, list) or not entries:
        raise SystemExit("VFX_WEB_CATALOG_NO_ACTUAL_SCENES")
    files = set(SOURCE_FILES)
    seen_ids = set()
    for entry in entries:
        if not isinstance(entry, dict):
            raise SystemExit("VFX_WEB_CATALOG_INVALID_ENTRY")
        skill_id = entry.get("id")
        scene = entry.get("scene")
        directions = entry.get("directions")
        if not isinstance(skill_id, str) or not skill_id.startswith("tmb.skill.") or skill_id in seen_ids:
            raise SystemExit("VFX_WEB_CATALOG_BAD_SKILL_ID")
        seen_ids.add(skill_id)
        if not isinstance(scene, str) or not scene.startswith("res://labs/") or not scene.endswith(".tscn"):
            raise SystemExit("VFX_WEB_CATALOG_BAD_SCENE")
        files.add(scene.removeprefix("res://"))
        if not isinstance(directions, list) or not directions or not set(directions).issubset({"front","back","left","right"}):
            raise SystemExit("VFX_WEB_CATALOG_UNVERIFIED_DIRECTION")
        if entry.get("vfx_status") not in {"TECH_CUE_ONLY","CANDIDATE_G3","OWNER_APPROVED"}:
            raise SystemExit("VFX_WEB_CATALOG_UNVERIFIED_ART_STATUS")
        sources = entry.get("source_paths", [])
        if not isinstance(sources, list):
            raise SystemExit("VFX_WEB_CATALOG_BAD_SOURCES")
        for relative in sources:
            if not isinstance(relative, str) or relative.startswith("/") or ".." in Path(relative).parts or "\\" in relative:
                raise SystemExit("VFX_WEB_CATALOG_UNSAFE_SOURCE_PATH")
            files.add(relative)
    manifest = {}
    for relative in sorted(files):
        old, new = root / relative, dest / relative
        if not old.is_file():
            raise SystemExit(f"Missing required REAL source: {old}")
        new.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(old, new)
        if old.read_bytes() != new.read_bytes():
            raise SystemExit(f"Nonidentical staging copy: {relative}")
        manifest[relative] = {"sha256": digest(old), "bytes": old.stat().st_size}
    catalog_target = dest / "labs/visual_bridge_v1/vfx_web_catalog_v1.json"
    catalog_target.parent.mkdir(parents=True, exist_ok=True)
    catalog_target.write_text(json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8")
    (dest / "project.godot").write_text(PROJECT, encoding="utf-8")
    (dest / "export_presets.cfg").write_text(EXPORT, encoding="utf-8")
    (dest / "source-manifest.json").write_text(json.dumps({
        "stage": "WEB_REVIEW_ONLY", "owner_art": "PENDING",
        "vfx_g3": "SOURCE_PENDING", "event_source": "LAB_ONLY_SYNTHETIC",
        "source_count": len(files), "scenarios": len(entries), "source_files": manifest,
    }, indent=2), encoding="utf-8")
    print(f"VFX_WEB_STAGE_PASS source_files={len(files)} scenarios={len(entries)} site=ONE_CANONICAL_SITE")
    print("VFX_WEB_HOLDS art=SOURCE_PENDING directions=FRONT_ONLY PvE=HOLD")

if __name__ == "__main__":
    main()
