#!/usr/bin/env python3
"""Build source-backed Fist adapters for the shared, review-only VFX Factory."""
from __future__ import annotations

import base64
import csv
import hashlib
import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPO = ROOT.parent
BATCH = ROOT / "labs/combat_lab/fist_factory_batch1_20261125"
CONFIG = BATCH / "batch_config.json"
LEDGER = REPO / "docs/operations/vfx_school_ledgers/05_fist_183.csv"
CATALOG = ROOT / "data/combat/v63_human_combat_catalog.json"
REGISTRY = ROOT / "labs/combat_lab/vfx_factory/registry.json"
WEB_CATALOG = REPO / "docs/operations/vfx_web_catalog_v1.json"
FACTORY_SCENE = "res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def decode_embedded_assets(config: dict) -> list[dict]:
    records = []
    for row in config.get("derived_assets", []):
        source = ROOT / row["source"]
        output = ROOT / row["output"]
        if not source.is_file():
            raise SystemExit(f"FIST_SOURCE_MISSING {source}")
        text = source.read_text(encoding="ascii").strip()
        text = re.sub(r"^data:[^,]+,", "", text)
        data = base64.b64decode("".join(text.split()), validate=True)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(data)
        records.append({
            "source": row["source"], "source_sha256": sha256(source),
            "output": row["output"], "output_sha256": hashlib.sha256(data).hexdigest(),
            "bytes": len(data), "method": "BASE64_DECODE_BYTE_PRESERVING",
        })
    return records


def path_frames(definition: dict) -> tuple[dict, set[str]]:
    row = {key: value for key, value in definition.items()
           if key not in {"source", "frames_glob", "grid", "indices"}}
    source_paths: set[str] = set()
    if "frames_glob" in definition:
        pattern = definition["frames_glob"]
        import glob
        files = sorted(Path(value) for value in glob.glob(str(ROOT / pattern)))
        if not files:
            raise SystemExit(f"FIST_FRAME_GLOB_EMPTY {pattern}")
        frames = []
        for path in files:
            relative = path.relative_to(ROOT).as_posix()
            frames.append({"path": "res://" + relative})
            source_paths.add(relative)
        row["path"] = frames[0]["path"]
        row["frames"] = frames
        return row, source_paths

    relative = str(definition["source"])
    path = ROOT / relative
    if not path.is_file():
        raise SystemExit(f"FIST_PHASE_SOURCE_MISSING {path}")
    source_paths.add(relative)
    resource = "res://" + relative
    if "grid" in definition:
        from PIL import Image
        with Image.open(path) as image_file:
            width, height = image_file.size
        columns, rows = (int(x) for x in definition["grid"])
        if columns <= 0 or rows <= 0 or width % columns or height % rows:
            raise SystemExit(f"FIST_ATLAS_GRID_INVALID {relative} {width}x{height} grid={columns}x{rows}")
        cell_w, cell_h = width // columns, height // rows
        frames = []
        for index in definition.get("indices", list(range(columns * rows))):
            index = int(index)
            if index < 0 or index >= columns * rows:
                raise SystemExit(f"FIST_ATLAS_FRAME_OUT_OF_RANGE {relative} frame={index}")
            x, y = (index % columns) * cell_w, (index // columns) * cell_h
            frames.append({"path": resource, "region": [x, y, cell_w, cell_h]})
        row["path"] = resource
        row["frames"] = frames
    else:
        row["path"] = resource
        row["frames"] = [{"path": resource}]
    return row, source_paths


def mechanic_tags(definition: dict) -> tuple[str, list[str]]:
    effect = str(definition.get("effect", ""))
    shape = str(definition.get("shape", ""))
    speed = float(definition.get("projectile_speed", 0.0))
    if effect == "guard":
        return "shield", ["shield", "buff", "status"]
    if effect == "mark":
        return "status", ["melee", "debuff", "status"]
    if effect == "consume_poison":
        return "circle_aoe", ["circle_aoe", "multi_target", "status"]
    if shape == "circle":
        return "circle_aoe", ["circle_aoe", "multi_target"]
    if speed > 0.0:
        return "projectile", ["projectile"]
    return "melee", ["melee"]


def bindings_for(effect: str) -> list[dict]:
    bindings = [
        {"event_type": "skill_cast", "visual_phase": "charge", "actor_clip": "cast", "caster_slot": "body_center", "target_slot": "foot"},
        {"event_type": "skill_release", "visual_phase": "release", "actor_clip": "cast", "caster_slot": "body_center", "target_slot": "foot"},
    ]
    if effect == "guard":
        bindings.append({"event_type": "status_applied", "visual_phase": "start", "actor_clip": "cast", "caster_slot": "body_center", "target_slot": "chest"})
    else:
        bindings.append({"event_type": "v63_skill_hit", "visual_phase": "contact", "actor_clip": "cast", "caster_slot": "body_center", "target_slot": "chest"})
        if effect == "mark":
            bindings.append({"event_type": "status_applied", "visual_phase": "start", "actor_clip": "cast", "caster_slot": "body_center", "target_slot": "chest"})
    return bindings


def main() -> None:
    config = load_json(CONFIG)
    decoded = decode_embedded_assets(config)
    canonical = {row["id"]: row for row in load_json(CATALOG)["skills"]}
    with LEDGER.open(encoding="utf-8-sig", newline="") as file:
        ledger = {row["skill_id"]: row for row in csv.DictReader(file)}
    registry = load_json(REGISTRY)
    web = load_json(WEB_CATALOG)
    registry_by_id = {row["skill_id"]: row for row in registry.get("entries", [])}
    web_by_id = {row["id"]: row for row in web.get("entries", [])}
    built = []
    frames_by_effect: Counter[str] = Counter()

    for source_row in config["entries"]:
        skill_id = source_row["skill_id"]
        if skill_id not in canonical or skill_id not in ledger:
            raise SystemExit(f"FIST_SKILL_CATALOGUE_OR_LEDGER_MISSING {skill_id}")
        if skill_id in registry_by_id or skill_id in web_by_id:
            raise SystemExit(f"FIST_FACTORY_ENTRY_ALREADY_EXISTS {skill_id}")
        skill = canonical[skill_id]
        ledger_row = ledger[skill_id]
        source_paths = {
            "data/combat/v63_human_combat_catalog.json",
            source_row["lab_scene"], source_row["lab_script"],
            "labs/combat_lab/fist_factory_batch1_20261125/batch_config.json",
            "labs/combat_lab/fist_factory_batch1_20261125/README.md",
        }
        source_paths.update(source_row.get("provenance_paths", []))
        phase_sources = {}
        for phase, raw_definition in source_row["phase_sources"].items():
            phase_definition, phase_files = path_frames(raw_definition)
            phase_sources[phase] = phase_definition
            source_paths.update(phase_files)
        source_paths.update(row["source"] for row in config.get("derived_assets", [])
                            if row["output"] in {path.removeprefix("res://") for phase in phase_sources.values()
                                                  for frame in phase.get("frames", [])
                                                  for path in [frame.get("path", "")]})
        effect = str(skill["effect"])
        mechanic, mechanics = mechanic_tags(skill)
        cast_time = float(skill.get("cast_time", 0.0))
        duration = float(skill.get("duration", 0.0))
        projectile_speed = float(skill.get("projectile_speed", 0.0))
        travel_time = float(skill.get("range", 0.0)) / projectile_speed if projectile_speed > 0.0 else 0.0
        timeline = {
            "release_at": cast_time,
            "flight_at": cast_time,
            "contact_at": cast_time + max(0.18, travel_time),
            "fade_at": cast_time + max(0.18, travel_time) + 0.24,
            "loop_seconds": max(1.8, cast_time + travel_time + max(duration, 0.0) + 0.58),
            "charge_window_seconds": max(0.08, cast_time),
            "release_window_seconds": 0.18,
            "contact_window_seconds": 0.18,
            "fade_window_seconds": 0.24,
            "start_window_seconds": 0.18,
            "end_window_seconds": 0.24,
        }
        target_actor_id = skill_id.replace("tmb.skill.fist.", "fist_factory_target_").replace(".", "_")
        preview_targets = []
        preview_outside = {}
        if source_row.get("circle_targets"):
            preview_targets = [
                {"id": target_actor_id + "_01", "label": "TARGET 01 · IN RADIUS", "screen_position": [690, 482], "fixture_position": [5.0, 3.0], "fixture_motion_delta": [0.10, 0.02]},
                {"id": target_actor_id + "_02", "label": "TARGET 02 · IN RADIUS", "screen_position": [768, 492], "fixture_position": [5.6, 3.0], "fixture_motion_delta": [-0.06, 0.02]},
                {"id": target_actor_id + "_03", "label": "TARGET 03 · IN RADIUS", "screen_position": [734, 530], "fixture_position": [5.4, 3.6], "fixture_motion_delta": [0.03, -0.08]},
            ]
            target_actor_id = preview_targets[0]["id"]
            preview_outside = {"id": target_actor_id.replace("_01", "_outside"), "label": "OUTSIDE EFFECT RADIUS · UNCHANGED", "screen_position": [1120, 594], "fixture_position": [8.8, 5.4]}
            source_paths.add("data/combat/v63_human_combat_catalog.json")
        manifest = {"schema": "tmb.vfx_bindings.v1", "skill_id": skill_id,
                    "bindings": bindings_for(effect)}
        frame_total = sum(len(value.get("frames", [])) for value in phase_sources.values())
        phase_count = len(phase_sources)
        source_g3 = "SOURCE_GATE_INHERITED_FROM_EXISTING_LEDGER; FACTORY_CANDIDATE_ONLY"
        motion_status = ("SOURCE_FRAME_SEQUENCE_IN_SHARED_RENDERER; NATIVE_MOTION_REVIEW_PENDING"
                         if frame_total > phase_count else "DISTINCT_SOURCE_PHASE_MASTERS; FRAME_BY_FRAME_SEQUENCE_PENDING")
        notes = ("Factory candidate reuses the existing Fist14 R5 package with its owner rework status preserved; the R7 and R8 G3-failed lanes remain excluded. "
                 if skill_id == "tmb.skill.fist.huyet_quyen.active_04.human" else
                 "Factory candidate reuses the existing Human Fist LAB source without changing the source gate. ")
        entry = {
            "skill_id": skill_id, "school": "fist", "branch": str(skill.get("branch", "")),
            "name_vi": str(skill.get("name_vi", skill.get("name", ""))), "catalog_path": "res://data/combat/v63_human_combat_catalog.json",
            "effect": effect, "shape": str(skill.get("shape", "")), "target_limit": int(skill.get("target_limit", 1)),
            "mechanic_template": mechanic, "mechanic_templates": mechanics,
            "target_mode": str(skill.get("shape", "single_target")), "preview_target_kind": "monster",
            "target_actor_id": target_actor_id, "outside_actor_id": str(preview_outside.get("id", "fist_factory_outside")),
            "preview_targets": preview_targets, "preview_outside": preview_outside,
            "actor_sex": "male", "actor_action": "cast", "facing_vector": [1.0, 0.0],
            "preview_attachment_override": {"suppress_attachments": True}, "source_anchor": "body_center",
            "phase_anchors": {"charge": "body_center", "release": "body_center", "flight": "body_center",
                              "contact": "target_chest", "fade": "target_chest", "start": "target_chest",
                              "sustain": "target_chest", "end": "target_chest"},
            "phase_layers": source_row.get("phase_layers", {}), "draw_layer": "FRONT",
            "phase_sources": phase_sources, "review_timeline": timeline,
            "delivery_phase": "flight" if projectile_speed > 0.0 else "release",
            "receipt_manifest": manifest, "native_batch": "fist", "native_capture_mode": "REAL_MAPBATTLE_EXACT_SKILL_EVENTS",
            "source_revision": source_row["source_revision"], "source_lab_scene": "res://" + source_row["lab_scene"],
            "source_lab_script": "res://" + source_row["lab_script"],
            "source_lab_visual_status": str(ledger_row["lab_visual_status"]),
            "source_owner_gate": str(ledger_row["owner_gate"]), "source_g3": source_g3,
            "native_status": "NATIVE_PENDING", "native_ready": False,
            "owner_status": "OWNER_VISUAL_PENDING", "motion_status": motion_status,
            "review_note": notes + "Exact skill and receipt contract come from the Human catalogue. Only MapBattle receipts trigger contact or persistent state. No synthetic damage or status. Native capture pending; owner approval pending; PvE HOLD.",
            "source_paths": sorted(source_paths),
        }
        registry["entries"].append(entry)
        registry_by_id[skill_id] = entry
        web_row = {
            "id": skill_id, "scene": FACTORY_SCENE,
            "preview_key": "fist_batch1_" + skill_id.removeprefix("tmb.skill.fist.").removesuffix(".human").replace(".", "_"),
            "directions": ["front"], "vfx_status": "TECH_CUE_ONLY", "family_id": str(skill.get("family_id", "")),
            "school": "fist", "branch": str(skill.get("branch", "")), "name_vi": str(skill.get("name_vi", skill.get("name", ""))),
            "source_paths": sorted(source_paths),
            "review_note": notes + "Source gate is preserved and owner approval remains pending. Factory contact/state is receipt-bound; native capture pending; PvE HOLD.",
        }
        web["entries"].append(web_row)
        web_by_id[skill_id] = web_row
        source_paths.update(source_row.get("provenance_paths", []))
        frames_by_effect[effect] += frame_total
        built.append({"skill_id": skill_id, "name_vi": entry["name_vi"], "source_revision": entry["source_revision"],
                      "lab_scene": source_row["lab_scene"], "effect": effect, "shape": entry["shape"],
                      "target_limit": entry["target_limit"], "source_paths": entry["source_paths"],
                      "phase_count": phase_count, "configured_frames": frame_total,
                      "native_status": "NATIVE_PENDING", "owner_status": "OWNER_VISUAL_PENDING", "pve": "HOLD"})

    registry.setdefault("native_batches", {})["fist"] = {
        "expected_count": len(built), "technical_status": "NATIVE_PENDING",
        "receipt_status": "REAL_MAPBATTLE_V2_EXACT_SKILL_FIXTURES; CAPTURE_PENDING",
        "owner_approval": "PENDING", "pve": "HOLD",
    }
    registry.setdefault("batch_status", {})[config["batch"]] = {
        "source_status": "SOURCE_BACKED_11_HUMAN_CAST_MASTERS; EXISTING_LAB_ASSETS_REUSED",
        "native_import_capture": "NATIVE_PENDING; SHARED_RUNNER; OWNER=PENDING; PVE=HOLD",
        "owner_status": "OWNER_VISUAL_PENDING", "pve": "HOLD",
    }
    manifest = {
        "schema": "tmb.vfx_factory_batch_manifest.v1", "batch": config["batch"], "school": "fist",
        "human_cast_masters": len(built), "status": "CANDIDATE; NATIVE_PENDING; OWNER_PENDING; PVE_HOLD",
        "source_gate_ledger": "docs/operations/vfx_school_ledgers/05_fist_183.csv",
        "source_policy": "Reuse existing source masters byte-for-byte; embedded .b64 masters are base64-decoded without pixel edits.",
        "derived_assets": decoded,
        "skills": built, "blocked_skills": config.get("blocked_skills", []),
        "mechanic_frame_counts": dict(sorted(frames_by_effect.items())),
        "owner_approval": "PENDING", "pve": "HOLD",
    }
    REGISTRY.write_text(json.dumps(registry, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    WEB_CATALOG.write_text(json.dumps(web, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (BATCH / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"VFX_FACTORY_FIST_SOURCE_BATCH_PASS skills={len(built)} derived={len(decoded)} configured_frames={sum(r['configured_frames'] for r in built)} owner=PENDING pve=HOLD")
    print("VFX_FACTORY_FIST_BLOCKED=" + ",".join(row["skill_id"] for row in config.get("blocked_skills", [])))


if __name__ == "__main__":
    main()
