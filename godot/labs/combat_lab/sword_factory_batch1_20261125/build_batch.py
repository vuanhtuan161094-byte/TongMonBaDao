#!/usr/bin/env python3
"""Build shared Factory adapters for the existing 17 Human Sword VFX sources."""
from __future__ import annotations

import csv
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
GODOT = ROOT / "godot"
BATCH = GODOT / "labs/combat_lab/sword_factory_batch1_20261125"
CONFIG = BATCH / "batch_config.json"
REGISTRY_PATH = GODOT / "labs/combat_lab/vfx_factory/registry.json"
WEB_PATH = ROOT / "docs/operations/vfx_web_catalog_v1.json"
CATALOG_PATH = GODOT / "data/combat/v63_sword_combat_catalog.json"
LEDGER_PATH = ROOT / "docs/operations/vfx_school_ledgers/03_sword_183.csv"
FACTORY_SCENE = "res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn"
TECH_PENDING = "NATIVE_PENDING"


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def mechanic_tags(skill: dict) -> tuple[str, list[str]]:
    effect, shape = str(skill.get("effect", "")), str(skill.get("shape", ""))
    if effect == "guard":
        return "shield", ["shield", "buff", "status"]
    if effect == "mobility":
        return "mobility", ["mobility"]
    if shape == "line":
        return "line", ["line", "multi_target"]
    if shape == "circle":
        return "circle_aoe", ["circle_aoe", "multi_target"]
    if float(skill.get("projectile_speed", 0.0)) > 0.0:
        return "projectile", ["projectile"]
    return "melee", ["melee"]


def event_bindings(effect: str) -> list[dict]:
    rows = [
        {"event_type": "skill_cast", "visual_phase": "charge", "actor_clip": "attack",
         "caster_slot": "weapon_grip", "target_slot": "foot"},
        {"event_type": "skill_release", "visual_phase": "release", "actor_clip": "attack",
         "caster_slot": "weapon_tip", "target_slot": "foot"},
    ]
    if effect == "guard":
        rows.append({"event_type": "status_applied", "visual_phase": "start", "actor_clip": "cast",
                     "caster_slot": "body_center", "target_slot": "chest"})
    elif effect == "mobility":
        rows.append({"event_type": "v63_mobility", "visual_phase": "start", "actor_clip": "attack",
                     "caster_slot": "weapon_tip", "target_slot": "ground"})
    else:
        rows.append({"event_type": "v63_skill_hit", "visual_phase": "contact", "actor_clip": "attack",
                     "caster_slot": "weapon_tip", "target_slot": "chest"})
    return rows


def source_frames(config: dict) -> dict:
    relative = str(config["source_atlas"])
    image_path = GODOT / relative
    if not image_path.is_file():
        raise SystemExit(f"SWORD_FACTORY_SOURCE_MISSING {relative}")
    from PIL import Image

    with Image.open(image_path) as image:
        width, height = image.size
        if image.mode != "RGBA":
            raise SystemExit(f"SWORD_FACTORY_SOURCE_NOT_RGBA {relative} mode={image.mode}")
    columns, rows = (int(value) for value in config["grid"])
    if columns < 1 or rows < 1 or width % columns or height % rows:
        raise SystemExit(f"SWORD_FACTORY_GRID_INVALID {relative} {width}x{height} grid={columns}x{rows}")
    cell_w, cell_h = width // columns, height // rows
    path = "res://" + relative
    result = {}
    with Image.open(image_path) as image:
        alpha = image.getchannel("A")
        for phase, indices in config["phase_frames"].items():
            frames = []
            for raw_index in indices:
                index = int(raw_index)
                if index < 0 or index >= columns * rows:
                    raise SystemExit(f"SWORD_FACTORY_FRAME_OOB {config['tag']} {phase} {index}")
                x, y = (index % columns) * cell_w, (index // columns) * cell_h
                if alpha.crop((x, y, x + cell_w, y + cell_h)).getbbox() is None:
                    raise SystemExit(f"SWORD_FACTORY_EMPTY_SOURCE_CEL {config['tag']} {phase} {index}")
                frames.append({"path": path, "region": [x, y, cell_w, cell_h]})
            result[phase] = {
                "path": path,
                "frames": frames,
                "display_width_px": int(config["phase_display_width_px"][phase]),
                "fps": float(config["phase_fps"]),
                "loop": phase == "sustain",
                "fade_seconds": 0.24 if phase in ["fade", "end"] else 0.16,
            }
    return result


def main() -> None:
    config = read_json(CONFIG)
    catalog = read_json(CATALOG_PATH)
    registry = read_json(REGISTRY_PATH)
    web = read_json(WEB_PATH)
    canonical = {str(row["id"]): row for row in catalog.get("skills", [])}
    registry_by_id = {str(row["skill_id"]): row for row in registry.get("entries", [])}
    web_by_id = {str(row["id"]): row for row in web.get("entries", [])}
    with LEDGER_PATH.open(encoding="utf-8-sig", newline="") as handle:
        ledger = {str(row["skill_id"]): row for row in csv.DictReader(handle)}

    rows = config.get("entries", [])
    expected = {str(row["skill_id"]) for row in rows}
    if len(rows) != 17 or len(expected) != 17:
        raise SystemExit(f"SWORD_FACTORY_EXPECTED_17_UNIQUE_HUMAN_CAST_MASTERS got={len(expected)}")
    built = []
    for source_row in rows:
        skill_id = str(source_row["skill_id"])
        if skill_id not in canonical or skill_id not in ledger or skill_id not in web_by_id:
            raise SystemExit(f"SWORD_FACTORY_CANONICAL_LEDGER_WEB_JOIN_MISSING {skill_id}")
        skill, ledger_row, web_row = canonical[skill_id], ledger[skill_id], web_by_id[skill_id]
        if str(skill.get("tier", "")) != "human" or str(skill.get("effect", "")) in {"passive", "innate"}:
            raise SystemExit(f"SWORD_FACTORY_NOT_A_HUMAN_CAST_MASTER {skill_id}")
        phase_sources = source_frames(source_row)
        source_path = str(source_row["source_atlas"])
        in_project_paths = set(source_row.get("source_paths", []))
        in_project_paths.update({
            "data/combat/v63_sword_combat_catalog.json",
            "labs/combat_lab/sword_factory_batch1_20261125/batch_config.json",
            "labs/combat_lab/sword_factory_batch1_20261125/README.md",
            source_path,
            "src/presentation/p3/sect_aschar_candidate_bridge_v1.gd",
            "src/presentation/p3/pve_aschar_frame_renderer_v1.gd",
        })
        for path in sorted(in_project_paths):
            if path.startswith("docs/") or not (GODOT / path).is_file():
                raise SystemExit(f"SWORD_FACTORY_INVALID_IN_PROJECT_PATH {skill_id} {path}")

        effect, shape = str(skill["effect"]), str(skill["shape"])
        limit = int(skill.get("target_limit", 1))
        mechanic, mechanics = mechanic_tags(skill)
        preview_targets = source_row.get("preview_targets", [])
        target_id = str(preview_targets[0]["id"]) if preview_targets else f"sword_factory_target_{source_row['tag']}"
        outside_id = f"sword_factory_outside_{source_row['tag']}"
        source_range = max(0.1, float(skill.get("range", 0.0)))
        projectile_speed = float(skill.get("projectile_speed", 0.0))
        cast_time = float(skill.get("cast_time", 0.0))
        duration = float(skill.get("duration", 0.0))
        flight_time = source_range / projectile_speed if projectile_speed > 0.0 else 0.0
        timeline = {
            "release_at": cast_time,
            "flight_at": cast_time,
            "contact_at": cast_time + max(0.18, flight_time),
            "fade_at": cast_time + max(0.18, flight_time) + 0.24,
            "loop_seconds": max(1.8, cast_time + flight_time + duration + 0.58),
            "charge_window_seconds": max(0.08, cast_time),
            "release_window_seconds": 0.18,
            "contact_window_seconds": 0.18,
            "fade_window_seconds": 0.24,
            "start_window_seconds": 0.18,
            "end_window_seconds": 0.24,
            "actor_action_seconds": 0.35,
        }
        bindings = event_bindings(effect)
        entry = {
            "skill_id": skill_id,
            "school": "sword",
            "branch": str(skill.get("branch", "")),
            "name_vi": str(source_row.get("name_vi", skill.get("name", ""))),
            "catalog_path": "res://data/combat/v63_sword_combat_catalog.json",
            "effect": effect,
            "shape": shape,
            "target_limit": limit,
            "mechanic_template": mechanic,
            "mechanic_templates": mechanics,
            "target_mode": shape,
            "preview_target_kind": str(source_row["preview_target_kind"]),
            "target_actor_id": target_id,
            "outside_actor_id": outside_id,
            "preview_targets": preview_targets,
            "preview_outside": ({} if effect in ["guard", "mobility"] else {
                "id": outside_id,
                "label": "OUTSIDE CANONICAL SKILL RANGE · UNCHANGED",
                "screen_position": [1120, 594],
                "fixture_position": [round(2.0 + source_range + 1.0, 3), 3.0],
            }),
            "fixture_target_position": list(source_row["fixture_target_position"]),
            "actor_sex": "male",
            "actor_asset_id": 48,
            "actor_action": str(source_row["actor_action"]),
            "facing_vector": [0.0, 1.0],
            "preview_attachment_override": (
                source_row.get("preview_attachment_override")
                or config.get("preview_attachment_override", {})
            ),
            "source_anchor": "weapon_grip",
            "phase_anchors": source_row["phase_anchors"],
            "phase_layers": source_row["phase_layers"],
            "phase_spans": source_row.get("phase_spans", {}),
            "phase_aliases": source_row.get("phase_aliases", {}),
            "draw_layer": "FRONT",
            "showcase_moving_target": True,
            "showcase_outside_target": effect not in ["guard", "mobility"],
            "phase_sources": phase_sources,
            "review_timeline": timeline,
            "delivery_phase": str(source_row["delivery_phase"]),
            "canonical_cast_time": cast_time,
            "canonical_projectile_speed": projectile_speed,
            "canonical_range": source_range,
            "receipt_manifest": {"schema": "tmb.vfx_bindings.v1", "skill_id": skill_id, "bindings": bindings},
            "native_batch": "sword",
            "native_capture_mode": "REAL_MAPBATTLE_EXACT_SKILL_EVENTS",
            "source_revision": str(source_row["source_revision"]),
            "source_lab_scene": "res://" + str(source_row["source_lab_scene"]),
            "source_lab_visual_status": str(ledger_row.get("lab_visual_status", "")),
            "source_owner_gate": str(ledger_row.get("owner_gate", "")),
            "source_g3": str(source_row["source_g3"]),
            "native_status": TECH_PENDING,
            "native_ready": False,
            "owner_status": "OWNER_VISUAL_PENDING",
            "motion_status": f"SOURCE_FRAME_SEQUENCE_IN_SHARED_RENDERER; {source_row['source_revision']}; RUNTIME_MOTION_REVIEW_PENDING",
            "source_paths": sorted(in_project_paths),
            "external_provenance_paths": sorted(config.get("external_provenance_paths", [])),
            "weapon_family": "jian",
            "weapon_grip_socket": "main_hand",
            "weapon_tip_anchor": "weapon_tip",
            "review_note": (
                "Shared Factory adapter reuses the exact existing source revision through AS48 at real 1x game scale, "
                "with the existing Weapon Library Jian and per-frame grip/weapon_tip socket. "
                + str(source_row["source_g3"]) + " Native exact-skill capture pending; source art approval does not transfer to this runtime adapter. "
                "Owner visual review pending; PvE HOLD."
            ),
        }
        previous = registry_by_id.get(skill_id, {})
        if str(previous.get("native_status", "")).startswith("NATIVE_TECH_PASS_"):
            for key in ["native_status", "native_ready", "native_event_status", "native_index",
                        "native_contact_sheet", "native_video", "native_event_count",
                        "native_accepted_event_count", "native_synthetic_event_count"]:
                if key in previous:
                    entry[key] = previous[key]
        registry_by_id[skill_id] = entry
        frame_count = sum(len(value.get("frames", [])) for value in phase_sources.values())
        built.append({
            "skill_id": skill_id,
            "name_vi": entry["name_vi"],
            "branch": entry["branch"],
            "source_revision": entry["source_revision"],
            "source_lab_scene": source_row["source_lab_scene"],
            "source_owner_gate": entry["source_owner_gate"],
            "source_lab_visual_status": entry["source_lab_visual_status"],
            "source_g3": entry["source_g3"],
            "effect": effect,
            "shape": shape,
            "target_limit": limit,
            "source_paths": entry["source_paths"],
            "external_provenance_paths": entry["external_provenance_paths"],
            "source_atlas": source_path,
            "fixture_target_position": entry["fixture_target_position"],
            "phase_count": len(phase_sources),
            "configured_frames": frame_count,
            "native_status": entry["native_status"],
            "owner_status": entry["owner_status"],
            "pve": "HOLD",
        })

        preview_key = "sword_factory_batch1_" + str(source_row["tag"])
        web_row["scene"] = FACTORY_SCENE
        web_row["preview_key"] = preview_key
        web_row["school"] = "sword"
        web_row["branch"] = entry["branch"]
        web_row["name_vi"] = entry["name_vi"]
        web_paths = set(str(path) for path in web_row.get("source_paths", []))
        web_paths.update(path for path in entry["source_paths"] if not path.startswith("src/"))
        web_row["source_paths"] = sorted(web_paths)
        web_row["review_note"] = str(web_row.get("review_note", "")).split(" Factory adapter status:")[0]
        web_row["review_note"] += (
            " Factory adapter status: shared AS48/Weapon Library runtime candidate reuses source revision "
            + str(source_row["source_revision"]) + "; native exact-skill capture pending; owner visual approval pending; PvE HOLD."
        )

    registry["entries"] = [registry_by_id.get(str(row["skill_id"]), row) for row in registry.get("entries", [])]
    present = {str(row["skill_id"]) for row in registry.get("entries", [])}
    for source_row in rows:
        skill_id = str(source_row["skill_id"])
        if skill_id not in present:
            registry["entries"].append(registry_by_id[skill_id])
    registry.setdefault("batch_status", {})["sword_human_cast_batch1_20261125"] = {
        "source_status": "17_EXISTING_HUMAN_CAST_SOURCE_REVISIONS_REUSED; NO_ORIGINAL_LAB_SOURCE_OVERWRITTEN",
        "native_import_capture": "NATIVE_PENDING; EXPECTED=17; SHARED_MAPBATTLE_V2_RECEIPT_RUNNER; OWNER=PENDING; PVE=HOLD",
        "owner_status": "OWNER_VISUAL_PENDING",
        "pve": "HOLD",
    }
    old_native = registry.setdefault("native_batches", {}).get("sword", {})
    if not str(old_native.get("technical_status", "")).startswith("NATIVE_TECH_PASS_"):
        registry["native_batches"]["sword"] = {
            "expected_count": 17,
            "technical_status": TECH_PENDING,
            "receipt_status": "CAPTURE_PENDING; EXACT_SKILL_MAPBATTLE_V2_EVENTS; NO_SYNTHETIC_RECEIPTS",
            "owner_approval": "PENDING",
            "pve": "HOLD",
        }
    write_json(REGISTRY_PATH, registry)
    write_json(WEB_PATH, web)

    source_assets = {}
    for source_row in rows:
        path = str(source_row["source_atlas"])
        file_path = GODOT / path
        source_assets[path] = {
            "sha256": hashlib.sha256(file_path.read_bytes()).hexdigest(),
            "bytes": file_path.stat().st_size,
            "source_revision": source_row["source_revision"],
            "source_g3": source_row["source_g3"],
            "grid": source_row["grid"],
        }
    manifest = {
        "schema": "tmb.vfx_factory_batch_manifest.v1",
        "batch": "sword_human_cast_batch1_20261125",
        "school": "sword",
        "human_cast_masters": len(built),
        "status": "CANDIDATE; NATIVE_PENDING; OWNER_PENDING; PVE_HOLD",
        "source_policy": config["source_policy"],
        "external_provenance_paths": config.get("external_provenance_paths", []),
        "source_assets": source_assets,
        "skills": built,
    }
    write_json(BATCH / "manifest.json", manifest)
    print(f"SWORD_FACTORY_BUILD_PASS skills={len(built)} source_atlases={len(source_assets)} registry={len(registry['entries'])} web_rows_updated=17 owner=PENDING PvE=HOLD")


if __name__ == "__main__":
    main()
