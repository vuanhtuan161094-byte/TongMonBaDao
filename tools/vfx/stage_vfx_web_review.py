#!/usr/bin/env python3
"""Stage a TINY export-only Godot Web project with real existing AS48/VFX sources.

The output is ephemeral CI build material, NOT a second game or a source fork.
Character art is never changed; only read and copied byte-for-byte to staging.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

SOURCE_FILES = (
    "labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd",
    "labs/visual_bridge_v1/as48_sword_anchor_lab.gd",
    "labs/visual_bridge_v1/as48_sword_anchor_lab.tscn",
    "labs/visual_bridge_v1/as48_sword_vfx_binding_lab.json",
    "labs/visual_bridge_v1/vfx_web_review_hub.gd",
    "labs/visual_bridge_v1/vfx_web_review_hub.tscn",
    "labs/combat_lab/vfx_factory/vfx_factory_review.gd",
    "labs/combat_lab/vfx_factory/vfx_factory_review.tscn",
    "labs/combat_lab/vfx_factory/registry.json",
    "labs/combat_lab/combat_lab_v16_impact_glow.gdshader",
    # Shared factory runtime. These are presentation/resource readers only;
    # the canonical skill JSON is staged per catalog entry below.
    "src/presentation/p3/pve_aschar_frame_renderer_v1.gd",
    "src/presentation/p3/sect_aschar_candidate_bridge_v1.gd",
    "src/presentation/p3/sect_aschar_candidate_sprite_v1.gd",
    "src/presentation/p3/combat_v5_source_a_atlas.gd",
    "src/presentation/p3/combat_v4_sprite_atlas.gd",
    "assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json",
    "assets/combat_v5_source_a/visual_manifest.json",
    "labs/character_family/aschar_v9_batch1/assets/atlases/AS48_attack_front_consistency_v2_atlas.png",
    "labs/character_family/aschar_v9_batch1/assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png",
    "labs/character_family/aschar_v9_batch1/meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json",
    "assets/actors/v5_sa_monster_1113031_1/animations.tres",
    "assets/actors/v5_sa_monster_1113031_1/atlas_000.webp",
    "assets/actors/v5_sa_monster_1113031_1/atlas_001.webp",
    "assets/actors/v5_sa_monster_1113031_1/atlas_002.webp",
)

ASCHAR_FACTORY_ACTOR_IDS = (52, 54, 56, 60, 64, 66, 68)  # Existing shared Factory actor sources.
ASCHAR_BRIDGE = "src/presentation/p3/sect_aschar_candidate_bridge_v1.gd"
SOURCE_A_MANIFEST = "assets/combat_v5_source_a/visual_manifest.json"
FACTORY_MONSTER_KEY = "monster_1113031_1"
RES_PATH_RE = re.compile(r'path="res://([^"\s]+)"')
FACTORY_RUNTIME_FILES = (
    "labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd",
    "src/presentation/p3/pve_aschar_frame_renderer_v1.gd",
    ASCHAR_BRIDGE,
    "src/presentation/p3/sect_aschar_candidate_sprite_v1.gd",
    "src/presentation/p3/combat_v5_source_a_atlas.gd",
    "src/presentation/p3/combat_v4_sprite_atlas.gd",
    "assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json",
    SOURCE_A_MANIFEST,
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

def _require_source(root: Path, relative: str, context: str) -> Path:
    path = Path(relative)
    if path.is_absolute() or ".." in path.parts or "\\" in relative:
        raise SystemExit(f"Unsafe {context} path: {relative}")
    source = root / path
    if not source.is_file():
        raise SystemExit(f"Missing {context}: {source}")
    return source

def _collect_tres_resources(root: Path, relative: str, files: set[str], context: str) -> None:
    source = _require_source(root, relative, context)
    files.add(relative)
    for raw in RES_PATH_RE.findall(source.read_text(encoding="utf-8")):
        _require_source(root, raw, f"{context} dependency")
        files.add(raw)

def _res_paths(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from _res_paths(child)
    elif isinstance(value, list):
        for child in value:
            yield from _res_paths(child)
    elif isinstance(value, str) and value.startswith("res://"):
        yield value.removeprefix("res://")

def factory_runtime_dependencies(root: Path) -> set[str]:
    """Resolve only factory-selected ASCHAR actors and the moving Source A monster."""
    files = set(SOURCE_FILES)
    for relative in FACTORY_RUNTIME_FILES:
        _require_source(root, relative, "factory runtime source")
        files.add(relative)

    bridge_path = _require_source(root, ASCHAR_BRIDGE, "ASCHAR bridge")
    bridge_text = bridge_path.read_text(encoding="utf-8")
    socket_match = re.search(r'const SOCKET_ROOT := "res://([^"\s]+)"', bridge_text)
    if not socket_match:
        raise SystemExit("ASCHAR bridge has no readable SOCKET_ROOT")
    socket_root = socket_match.group(1).rstrip("/")

    for actor_id in ASCHAR_FACTORY_ACTOR_IDS:
        source_match = re.search(
            rf'(?m)^\s*{actor_id}:"res://([^"\s]+)"', bridge_text)
        if not source_match:
            raise SystemExit(f"ASCHAR bridge has no SOURCE_PATHS entry for AS{actor_id}")
        tres_path = source_match.group(1)
        _collect_tres_resources(root, tres_path, files, f"AS{actor_id} SpriteFrames")

        socket_path = f"{socket_root}/AS{actor_id}_weapon_sockets_v9_3_candidate.json"
        socket_file = _require_source(root, socket_path, f"AS{actor_id} socket manifest")
        files.add(socket_path)
        socket_data = json.loads(socket_file.read_text(encoding="utf-8"))
        for dependency in _res_paths(socket_data):
            _require_source(root, dependency, f"AS{actor_id} socket resource")
            files.add(dependency)

    source_a_file = _require_source(root, SOURCE_A_MANIFEST, "Source A visual manifest")
    source_a = json.loads(source_a_file.read_text(encoding="utf-8"))
    monster = source_a.get("actors", {}).get(FACTORY_MONSTER_KEY)
    if not isinstance(monster, dict):
        raise SystemExit(f"Source A manifest has no moving factory target {FACTORY_MONSTER_KEY}")
    for key in ("base_asset", "combat_asset"):
        asset_id = str(monster.get(key, ""))
        if not asset_id or "/" in asset_id or "\\" in asset_id or ".." in asset_id:
            raise SystemExit(f"Invalid Source A {key} for {FACTORY_MONSTER_KEY}")
        asset_root = f"assets/actors/{asset_id}"
        _require_source(root, f"{asset_root}/asset.json", f"Source A {key} metadata")
        files.add(f"{asset_root}/asset.json")
        _collect_tres_resources(root, f"{asset_root}/animations.tres", files,
                                f"Source A {key} SpriteFrames")
    return files

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
    files = factory_runtime_dependencies(root)
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
    # Reproducible candidates, generated only inside disposable staging; no source-tree mutations.
    if any(str(e.get("preview_key","")) in {f"s{i:02d}" for i in range(9,18)} for e in entries):
        generated = dest / "labs/combat_lab/sword_batch9_20261124/generated"
        subprocess.run([sys.executable,str(root.parent / "tools/vfx/build_sword_batch9.py"),"--godot",str(root),"--output",str(generated)],check=True)
        for p in sorted(generated.iterdir()):
            if p.is_file():
                manifest[str(p.relative_to(dest))] = {"sha256":digest(p),"bytes":p.stat().st_size,"derived":True}
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
