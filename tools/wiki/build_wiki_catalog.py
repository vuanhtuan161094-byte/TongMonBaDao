#!/usr/bin/env python3
"""Build a deterministic, read-only Wiki projection from TMB source files.

This tool only writes wiki/data/catalog.json and docs/wiki/TMB_WIKI_SOURCE_AUDIT.md.
Owner notes and design proposals live in the browser profile (localStorage), never here.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import re
import subprocess
import sys
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
SCHOOL_IDS = {
    "Cung Tu": "bow", "Quyền Tu": "fist", "Độc Tu": "poison",
    "Kiếm Tu": "sword", "Đao Tu": "blade", "Song Đao": "dual_blade",
    "Thương Tu": "spear", "Chưởng Tu": "palm", "Trận Tu": "formation",
    "Triệu Hồi": "summon", "Chú Tu": "curse", "Phù Tu": "talisman",
}
SCHOOL_NAMES = {
    "bow": "Cung Tu", "fist": "Quyền Tu", "poison": "Độc Tu",
    "sword": "Kiếm Tu", "blade": "Đao Tu", "dual_blade": "Song Đao",
    "spear": "Thương Tu", "palm": "Chưởng Tu", "formation": "Trận Tu",
    "summon": "Triệu Hồi", "curse": "Chú Tu", "talisman": "Phù Tu",
}
FAMILY_NAMES = {"heal": "Hồi Nguyên Đan", "tuvi": "Tụ Linh Đan", "body": "Luyện Thể Đan", "break": "Đột Phá Đan"}
TRACK_NAMES_RE = re.compile(r"const\s+(CULTIVATION_REALM_NAMES|BODY_REALM_NAMES)\s*:=\s*\[(.*?)\]", re.S)
STRING_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source(root: Path, relative: str, version: Any = None) -> dict[str, Any]:
    path = root / relative
    return {
        "sourcePath": relative.replace("\\", "/"),
        "sourceSha": sha256(path) if path.is_file() else "",
        "version": version,
        "exists": path.is_file(),
    }


def read_json(root: Path, relative: str) -> tuple[dict[str, Any], dict[str, Any]]:
    path = root / relative
    if not path.is_file():
        return {}, source(root, relative)
    value = json.loads(path.read_text(encoding="utf-8-sig"))
    version = value.get("schema_version", value.get("schema")) if isinstance(value, dict) else None
    return value, source(root, relative, version)


def normalize_id(text: str) -> str:
    text = text.replace("Đ", "D").replace("đ", "d")
    text = unicodedata.normalize("NFD", text)
    text = "".join(char for char in text if unicodedata.category(char) != "Mn")
    return re.sub(r"[^a-zA-Z0-9]+", "_", text).strip("_").lower()


def commit_sha(root: Path) -> str:
    override = os.environ.get("TMB_WIKI_SOURCE_SHA", "").strip()
    if re.fullmatch(r"[0-9a-fA-F]{40}", override):
        return override.lower()
    try:
        # Wiki-only commits must not stale their own generated snapshot.
        return subprocess.check_output(
            ["git", "log", "-1", "--format=%H", "--", ".", ":!wiki", ":!docs/wiki", ":!tools/wiki", ":!.github/workflows/wiki-source-validation.yml"],
            cwd=root, text=True, stderr=subprocess.DEVNULL
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return "UNKNOWN"


def parse_motifs(root: Path) -> tuple[list[dict[str, Any]], dict[str, dict[str, Any]]]:
    relative = "docs/animation/TMB_DISCIPLE_SCHOOL_VISUAL_MOTIFS_20261111.md"
    path = root / relative
    src = source(root, relative, "2026-11-11 / design table")
    branches: list[dict[str, Any]] = []
    if not path.is_file():
        return branches, src
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        if not line.startswith("|") or "|---" in line or "Môn phái" in line:
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 5 or cells[0] not in SCHOOL_IDS:
            continue
        school_id = SCHOOL_IDS[cells[0]]
        branch_id = normalize_id(cells[2])
        branches.append({
            "id": f"tmb.branch.{school_id}.{branch_id}",
            "schoolId": school_id,
            "schoolName": SCHOOL_NAMES[school_id],
            "name": cells[2],
            "silhouette": cells[1],
            "motionSignature": cells[3],
            "artStatus": cells[4],
            **src,
            "runtimeStatus": "DESIGN_ONLY",
            "qaEvidence": {"status": "NOT_LINKED", "sourcePath": "", "sourceSha": ""},
        })
    return branches, src


def load_skills(root: Path) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[str], int]:
    catalog_files = sorted((root / "godot/data/combat").glob("v63*_combat_catalog.json"))
    records: dict[str, dict[str, Any]] = {}
    catalog_meta: list[dict[str, Any]] = []
    duplicates: list[str] = []
    input_count = 0
    for path in catalog_files:
        relative = path.relative_to(root).as_posix()
        data, src = read_json(root, relative)
        items = data.get("skills", []) if isinstance(data, dict) else []
        if not items:
            continue
        enabled = bool(data.get("enabled", False))
        input_count += len(items)
        for item in items:
            skill_id = str(item.get("id", ""))
            if not skill_id:
                duplicates.append("<MISSING_ID>")
                continue
            if skill_id in records:
                duplicates.append(skill_id)
                continue
            school_id = str(item.get("school", ""))
            records[skill_id] = {
                "id": skill_id,
                "familyId": str(item.get("family_id", "")),
                "nodeId": str(item.get("node_id", "")),
                "name": item.get("name", ""),
                "schoolId": school_id,
                "schoolName": SCHOOL_NAMES.get(school_id, school_id),
                "branchId": str(item.get("branch", "")),
                "generation": str(item.get("generation", item.get("tier", "unknown"))),
                "slot": str(item.get("slot", "")),
                "element": str(item.get("element", "")),
                "effect": str(item.get("effect", "")),
                "damageRatio": item.get("damage_ratio"),
                "range": item.get("range"),
                "castTime": item.get("cast_time"),
                "cooldown": item.get("cooldown"),
                "shape": str(item.get("shape", "")),
                "radius": item.get("radius"),
                "targetLimit": item.get("target_limit"),
                "power": item.get("power"),
                "duration": item.get("duration"),
                "poisonStacks": item.get("poison_stacks"),
                "animationKey": str(item.get("animation_key", "")),
                "vfxKey": str(item.get("vfx_key", "")),
                "sourceCodexId": str(item.get("source_codex_id", "")),
                "candidateStatus": str(item.get("candidate_status", data.get("candidate_status", ""))),
                "balanceStatus": str(item.get("balance_status", data.get("balance_status", ""))),
                "description": str(item.get("long_description_vi", item.get("detail_vi", item.get("short_description_vi", "")))),
                **src,
                "runtimeStatus": "GATED_OFF" if not enabled else "SOURCE_ENABLED_RUNTIME_UNVERIFIED",
                "formulaStatus": "CATALOGUE_VALUE_NOT_RUNTIME_AUTHORITY",
                "presentationStatus": "PENDING_MANIFEST_LINK",
                "qaEvidence": {"status": "NOT_LINKED_TO_SKILL_ID", "sourcePath": "", "sourceSha": ""},
            }
        catalog_meta.append({
            "id": path.stem,
            "records": len(items),
            "enabled": enabled,
            "releaseStatus": str(data.get("release_status", data.get("release_gate", ""))),
            "balanceStatus": str(data.get("balance_status", "")),
            **src,
            "runtimeStatus": "GATED_OFF" if not enabled else "UNVERIFIED",
            "qaEvidence": {"status": "CATALOG_LEVEL_ONLY", "sourcePath": "", "sourceSha": ""},
        })
    return list(records.values()), catalog_meta, duplicates, input_count


def add_presentation_links(root: Path, skills: list[dict[str, Any]]) -> dict[str, Any]:
    relative = "godot/data/presentation/v63_skill_presentation_manifest_v1.json"
    manifest, src = read_json(root, relative)
    entries = manifest.get("entries", {}) if manifest else {}
    for record in skills:
        entry = entries.get(record["id"])
        record["presentationStatus"] = "ENTRY_EXISTS_METADATA_ONLY" if entry else "NO_PRESENTATION_ENTRY"
        record["presentationId"] = record["id"] if entry else ""
        if entry:
            record["presentationSummary"] = {
                "displayName": entry.get("display_name_vi", ""),
                "roles": entry.get("role_tags", []),
                "releaseGate": str(manifest.get("release_gate", "")),
            }
    return {"entryCount": len(entries), "targetCoverage": manifest.get("target_coverage", {}),
            "releaseGate": manifest.get("release_gate", "UNKNOWN"), "completionStatus": manifest.get("completion_status", "UNKNOWN"),
            **src, "runtimeStatus": "GATED_OFF" if manifest.get("release_gate") == "OFF" else "UNVERIFIED",
            "visualAssetStatus": "NO_DEDICATED_SKILL_ASSETS" if not manifest.get("vfx_runtime_truth", {}).get("dedicated_skill_assets") else "ASSET_REFERENCES_PRESENT",
            "renderCaptureStatus": manifest.get("vfx_runtime_truth", {}).get("render_capture_status", "UNKNOWN"),
            "guiAcceptanceStatus": manifest.get("vfx_runtime_truth", {}).get("gui_acceptance_status", "UNKNOWN"),
            "qaEvidence": {"status": "MANIFEST_NOT_A_GUI_PASS", "sourcePath": relative, "sourceSha": src["sourceSha"]}}


def parse_gd_named_blocks(text: str, container_name: str) -> list[tuple[str, str]]:
    marker = re.search(rf"const\s+{re.escape(container_name)}\s*:=\s*\{{", text)
    if not marker:
        return []
    start = marker.end()
    results: list[tuple[str, str]] = []
    pos = start
    while pos < len(text):
        match = re.search(r'^ {4}"([^"\n]+)"\s*:\s*\{', text[pos:], re.M)
        if not match:
            break
        key = match.group(1)
        block_start = pos + match.end() - 1
        depth, in_string, escape = 0, False, False
        end = block_start
        for end in range(block_start, len(text)):
            char = text[end]
            if in_string:
                if escape:
                    escape = False
                elif char == "\\":
                    escape = True
                elif char == '"':
                    in_string = False
                continue
            if char == '"':
                in_string = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    end += 1
                    break
        results.append((key, text[block_start:end]))
        pos = end
    return results


def parse_realm_names(root: Path) -> tuple[list[str], list[str], dict[str, Any]]:
    relative = "godot/src/simulation/cultivation/disciple_realm_progress_v2.gd"
    text = (root / relative).read_text(encoding="utf-8")
    src = source(root, relative, 1)
    values: dict[str, list[str]] = {}
    for match in TRACK_NAMES_RE.finditer(text):
        values[match.group(1)] = STRING_RE.findall(match.group(2))
    return values.get("CULTIVATION_REALM_NAMES", []), values.get("BODY_REALM_NAMES", []), src


def make_medicines(root: Path) -> tuple[list[dict[str, Any]], list[dict[str, Any]], dict[str, Any]]:
    rel = "godot/src/simulation/building/medicine_catalogue_v2.gd"
    text = (root / rel).read_text(encoding="utf-8")
    src = source(root, rel, 4)
    realm_match = re.search(r"const\s+REALMS\s*:=\s*\[(.*?)\]", text, re.S)
    quality_match = re.search(r"const\s+QUALITIES\s*:=\s*\[(.*?)\]", text, re.S)
    realms = STRING_RE.findall(realm_match.group(1)) if realm_match else []
    qualities = STRING_RE.findall(quality_match.group(1)) if quality_match else []
    recipe_rows = {name: [int(v) for v in re.findall(r"\d+", match.group(1))]
    for name in ("AUTHORED_RECIPE_REALMS", "AUTHORED_BODY_REALMS", "AUTHORED_BREAK_REALMS")
                   if (match := re.search(rf"const\s+{name}\s*:=\s*\[(.*?)\]", text, re.S))}
    medicines: list[dict[str, Any]] = []
    recipes: list[dict[str, Any]] = []
    for realm_index, realm_name in enumerate(realms, start=1):
        for family in ("heal", "tuvi", "body", "break"):
            if family == "break" and realm_index == len(realms):
                continue
            can_make = realm_index in recipe_rows.get("AUTHORED_RECIPE_REALMS", []) if family in ("heal", "tuvi") else realm_index in recipe_rows.get("AUTHORED_BODY_REALMS" if family == "body" else "AUTHORED_BREAK_REALMS", [])
            for quality_index, quality_name in enumerate(qualities, start=1):
                item_id = f"sx02_{family}_r{realm_index:02d}_q{quality_index}"
                medicines.append({
                    "id": item_id,
                    "name": f"{FAMILY_NAMES[family]} · {realm_name} · {quality_name}",
                    "family": family, "realm": realm_index, "quality": quality_index,
                    "catalogStatus": "IDENTITY_GENERATED_BY_RUNTIME_CATALOGUE",
                    **src, "runtimeStatus": "CATALOGUE_CODE_PRESENT",
                    "craftability": "AUTHORED_RECIPE_FAMILY_REALM" if can_make else "IDENTITY_ONLY_NO_AUTHORED_RECIPE",
                    "qaEvidence": {"status": "TEST_SOURCE_NOT_EXECUTED_AT_WIKI_SHA", "sourcePath": "godot/tests/simulation/sx02_medicine_catalogue_test.gd", "sourceSha": ""},
                })
            if can_make:
                recipes.append({
                    "id": f"sx02_recipe_{family}_r{realm_index:02d}",
                    "name": f"{FAMILY_NAMES[family]} · {realm_name}",
                    "family": family, "realm": realm_index,
                    "craftability": "AUTHORED_RECIPE_DEFINITION",
                    **src, "runtimeStatus": "RECIPE_CODE_PRESENT_NOT_RELEASE_QA",
                    "qaEvidence": {"status": "TEST_SOURCE_NOT_EXECUTED_AT_WIKI_SHA", "sourcePath": "godot/tests/simulation/sx02_medicine_catalogue_test.gd", "sourceSha": ""},
                })
    qa_rel = "godot/tests/simulation/sx02_medicine_catalogue_test.gd"
    if (root / qa_rel).exists():
        qsha = sha256(root / qa_rel)
        for item in medicines + recipes:
            item["qaEvidence"]["sourceSha"] = qsha
    return medicines, recipes, src


def make_legacy_medicine_recipes(root: Path) -> list[dict[str, Any]]:
    rel = "godot/src/simulation/building/alchemy_recipe_registry.gd"
    text = (root / rel).read_text(encoding="utf-8")
    src = source(root, rel, 1)
    rows = []
    for key, block in parse_gd_named_blocks(text, "DEFINITIONS"):
        name = re.search(r'"name"\s*:\s*"([^"]+)"', block)
        rows.append({"id": key, "name": name.group(1) if name else key,
                     "family": "legacy", "craftability": "LEGACY_RECIPE_DEFINITION",
                     **src, "runtimeStatus": "LEGACY_RECIPE_CODE_PRESENT",
                     "qaEvidence": {"status": "TEST_SOURCE_NOT_EXECUTED_AT_WIKI_SHA", "sourcePath": "godot/tests/simulation/sx02_medicine_catalogue_test.gd", "sourceSha": ""}})
    test = root / "godot/tests/simulation/sx02_medicine_catalogue_test.gd"
    if test.exists():
        for row in rows:
            row["qaEvidence"]["sourceSha"] = sha256(test)
    return rows


def make_equipment(root: Path) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    rel = "godot/src/simulation/equipment/equipment_system.gd"
    text = (root / rel).read_text(encoding="utf-8")
    src = source(root, rel, 1)
    rows = []
    for key, block in parse_gd_named_blocks(text, "RECIPES"):
        name = re.search(r'"name"\s*:\s*"([^"]+)"', block)
        slot = re.search(r'"slot"\s*:\s*"([^"]+)"', block)
        path = re.search(r'"path"\s*:\s*"([^"]+)"', block)
        rows.append({"id": key, "name": name.group(1) if name else key,
                     "slot": slot.group(1) if slot else "UNKNOWN", "path": path.group(1) if path else "UNKNOWN",
                     **src, "runtimeStatus": "SYSTEM_RECIPE_CODE_PRESENT", "qaEvidence": {"status": "NOT_LINKED_AT_ITEM_ID", "sourcePath": "", "sourceSha": ""}})
    return rows, src


def make_resources(root: Path) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    rel = "godot/src/simulation/resource/resource_registry.gd"
    text = (root / rel).read_text(encoding="utf-8")
    src = source(root, rel, 1)
    rows = []
    for key, block in parse_gd_named_blocks(text, "DEFINITIONS"):
        name = re.search(r'"name"\s*:\s*"([^"]+)"', block)
        family = re.search(r'"family"\s*:\s*"([^"]+)"', block)
        rank = re.search(r'"realm_rank"\s*:\s*(\d+)', block)
        rows.append({"id": key, "name": name.group(1) if name else key,
                     "family": family.group(1) if family else "UNKNOWN",
                     "realmRank": int(rank.group(1)) if rank else None,
                     **src, "runtimeStatus": "REGISTRY_CODE_PRESENT",
                     "qaEvidence": {"status": "NOT_LINKED_AT_ITEM_ID", "sourcePath": "", "sourceSha": ""}})
    return rows, src


def build_catalog(root: Path = ROOT) -> dict[str, Any]:
    branch_records, motifs_src = parse_motifs(root)
    skill_records, skill_catalogs, duplicate_skill_ids, skill_input_count = load_skills(root)
    all_skill_sources = [{"sourcePath": row["sourcePath"], "sourceSha": row["sourceSha"]} for row in skill_catalogs]
    representative_skill_source = next((row for row in skill_catalogs if row["records"]), {})
    presentation = add_presentation_links(root, skill_records)
    registry_rel = "godot/data/combat/v63_content_registry.json"
    registry, registry_src = read_json(root, registry_rel)
    registry_school_ids = {str(row.get("id", "")) for row in registry.get("schools", [])}
    registry_branch_ids = set()
    for path_row in registry.get("paths", []):
        path_id = str(path_row.get("id", ""))
        registry_branch_ids.add(path_id.rsplit(".", 1)[-1])
    branch_ids_in_skills = defaultdict(set)
    skill_ids_by_school = Counter()
    skill_ids_by_branch = Counter()
    for item in skill_records:
        skill_ids_by_school[item["schoolId"]] += 1
        if item["branchId"]:
            branch_ids_in_skills[item["schoolId"]].add(item["branchId"])
            skill_ids_by_branch[(item["schoolId"], item["branchId"])] += 1
    school_records = []
    for school_id, school_name in SCHOOL_NAMES.items():
        school_records.append({
            "id": school_id, "name": school_name,
            "skillCount": skill_ids_by_school[school_id],
            "branchCountDesigned": sum(1 for row in branch_records if row["schoolId"] == school_id),
            "branchCountInSkills": len(branch_ids_in_skills[school_id]),
            "inD1Registry": school_id in registry_school_ids,
            "runtimeStatus": "REGISTRY_DISABLED" if school_id in registry_school_ids and not registry.get("enabled", False) else ("NOT_IN_D1_REGISTRY" if school_id not in registry_school_ids else "REGISTRY_ENABLED_UNVERIFIED"),
            **motifs_src,
            "qaEvidence": {"status": "NOT_LINKED", "sourcePath": "", "sourceSha": ""},
        })
    for row in branch_records:
        row["skillCount"] = skill_ids_by_branch[(row["schoolId"], normalize_id(row["name"]))]
        row["inD1Registry"] = bool(row["schoolId"] in registry_school_ids and normalize_id(row["name"]) in registry_branch_ids)
        if not row["inD1Registry"]:
            row["runtimeStatus"] = "DESIGN_ONLY_OR_CANDIDATE_NOT_IN_D1_REGISTRY"

    learning_rel = "godot/data/combat/v63_learning_catalog.json"
    learning, learning_src = read_json(root, learning_rel)
    techniques = []
    for item in learning.get("techniques", []):
        school_id = str(item.get("school", ""))
        techniques.append({
            "id": str(item.get("id", "")), "name": str(item.get("name", "")),
            "schoolId": school_id, "schoolName": SCHOOL_NAMES.get(school_id, school_id),
            "branchId": str(item.get("branch", "")), "generation": str(item.get("generation", "")),
            "sourceCodexId": str(item.get("source_codex_id", "")),
            "combatEffectsEnabled": bool(item.get("combat_effects_enabled", False)),
            **learning_src,
            "runtimeStatus": "GATED_OFF" if not learning.get("enabled", False) else "UNVERIFIED",
            "qaEvidence": {"status": "TEST_SOURCE_NOT_EXECUTED_AT_WIKI_SHA", "sourcePath": "godot/tests/simulation/v63_d4b_archive_learning_test.gd", "sourceSha": ""},
        })
    technique_test = root / "godot/tests/simulation/v63_d4b_archive_learning_test.gd"
    if technique_test.exists():
        for item in techniques:
            item["qaEvidence"]["sourceSha"] = sha256(technique_test)

    cultivation_names, body_names, realm_src = parse_realm_names(root)
    realm_design_rel = "godot/data/economy/v55d_30_realm_reference.json"
    realm_design, realm_design_src = read_json(root, realm_design_rel)
    realms = []
    for index in range(max(len(cultivation_names), len(body_names))):
        realms.append({
            "id": f"tmb.realm.{index+1:02d}", "rank": index + 1,
            "cultivationName": cultivation_names[index] if index < len(cultivation_names) else "",
            "bodyName": body_names[index] if index < len(body_names) else "",
            "realmReference": realm_design.get("realms", [])[index] if index < len(realm_design.get("realms", [])) else {},
            **realm_src,
            "additionalSourcePath": realm_design_src["sourcePath"],
            "additionalSourceSha": realm_design_src["sourceSha"],
            "runtimeStatus": "CODE_PRESENT_CHECKPOINT_QA_OPEN",
            "qaEvidence": {"status": "TEST_SOURCE_PRESENT_NOT_RUN_AT_WIKI_SHA", "sourcePath": "godot/tests/simulation/dv2_03_realm_body_progress_test.gd", "sourceSha": sha256(root / "godot/tests/simulation/dv2_03_realm_body_progress_test.gd") if (root / "godot/tests/simulation/dv2_03_realm_body_progress_test.gd").exists() else ""},
        })

    medicine_items, medicine_recipes, medicine_src = make_medicines(root)
    legacy_medicine_recipes = make_legacy_medicine_recipes(root)
    equipment_rows, equipment_src = make_equipment(root)
    resource_rows, resource_src = make_resources(root)

    disciple_rel = "godot/src/simulation/state/disciple_state.gd"
    disciple_src = source(root, disciple_rel, 1)
    disciple_schema_rel = "docs/DISCIPLE_MASTER_SCHEMA.md"
    disciple_schema_src = source(root, disciple_schema_rel, "CANONICAL MASTER CONTRACT")
    disciples = [{"id": "tmb.disciple.model.v2", "name": "Mô hình đệ tử (schema/runtime)",
                  "foundationAttributes": ["Tư Chất", "Căn Cốt", "Cơ Duyên", "Thông Tuệ", "Mị Lực", "Tiềm Lực"],
                  **disciple_src, "additionalSourcePath": disciple_schema_src["sourcePath"],
                  "additionalSourceSha": disciple_schema_src["sourceSha"],
                  "runtimeStatus": "FIELDS_PRESENT_NOT_FULLY_RELEASE_ACCEPTED",
                  "qaEvidence": {"status": "TEST_SOURCE_NOT_RUN_AT_WIKI_SHA", "sourcePath": "godot/tests/simulation/dv2_01_birth_envelope_test.gd", "sourceSha": sha256(root / "godot/tests/simulation/dv2_01_birth_envelope_test.gd") if (root / "godot/tests/simulation/dv2_01_birth_envelope_test.gd").exists() else ""}}]

    root_spec_rel = "docs/SPIRITUAL_ROOT_V2_SPEC.md"
    root_spec_src = source(root, root_spec_rel, "FULL DESIGN LOCKED — NOT IMPLEMENTED")
    root_code_rel = "godot/src/simulation/cultivation/spiritual_root_system.gd"
    root_code_src = source(root, root_code_rel, 2)
    roots = [{"id": "tmb.spiritual_root.v2", "name": "Linh Căn V2", **root_spec_src,
              "additionalSourcePath": root_code_src["sourcePath"], "additionalSourceSha": root_code_src["sourceSha"],
              "runtimeStatus": "FEATURE_GATED_OFF", "qaEvidence": {"status": "TEST_SOURCE_NOT_RUN_AT_WIKI_SHA", "sourcePath": "godot/tests/simulation/v63_root_v2_runtime_test.gd", "sourceSha": sha256(root / "godot/tests/simulation/v63_root_v2_runtime_test.gd") if (root / "godot/tests/simulation/v63_root_v2_runtime_test.gd").exists() else ""}}]

    equipment_spec_rel = "docs/WEAPON_EQUIPMENT_V2_SPEC.md"
    equipment_spec_src = source(root, equipment_spec_rel, "DESIGN SPEC")
    equipment_contract_rel = "godot/src/simulation/equipment/equipment_system.gd"
    equipment_contract_src = source(root, equipment_contract_rel, 1)
    vfx_manifest_rel = "godot/data/presentation/v63_combat_vfx_manifest.json"
    vfx_manifest, vfx_src = read_json(root, vfx_manifest_rel)
    vfx_rows = [{"id": "tmb.v63.vfx.manifest", "name": "V6.3 Combat VFX manifest",
                 "eventCount": len(vfx_manifest.get("event_cues", {})),
                 "assetFileCount": len(vfx_manifest.get("asset_files", [])),
                 **vfx_src, "runtimeStatus": "EVENT_RENDERER_PRESENT_ASSET_LIST_EMPTY",
                 "qaEvidence": {"status": "RENDER_CAPTURE_STATUS_FROM_SKILL_MANIFEST", "sourcePath": presentation["sourcePath"], "sourceSha": presentation["sourceSha"]}}]

    feature_gates_rel = "godot/src/simulation/combat/v63_feature_gates.gd"
    gates_text = (root / feature_gates_rel).read_text(encoding="utf-8") if (root / feature_gates_rel).exists() else ""
    gate_keys = re.findall(r'"([a-z0-9_]+)"\s*:\s*false', gates_text)
    gate_source = source(root, feature_gates_rel, 1)
    qa_paths = [
        "godot/tests/simulation/v63_d1_content_registry_test.gd",
        "godot/tests/simulation/v63_d4a_human_combat_test.gd",
        "godot/tests/simulation/v63_doc_full_combat_matrix_test.gd",
        "godot/tests/simulation/v63_skill_presentation_s0_test.gd",
    ]
    qa_files = [{"sourcePath": rel, "sourceSha": sha256(root / rel), "status": "TEST_SOURCE_PRESENT_RESULT_NOT_RECHECKED_AT_WIKI_SHA"}
                for rel in qa_paths if (root / rel).exists()]
    presentation_missing = sum(1 for item in skill_records if item["presentationStatus"] == "NO_PRESENTATION_ENTRY")
    duplicate_signatures: dict[tuple[str, str, str, str], list[str]] = defaultdict(list)
    for item in skill_records:
        signature = (normalize_id(str(item.get("name", ""))), item["schoolId"], item["branchId"], item["generation"])
        if signature[0]:
            duplicate_signatures[signature].append(item["id"])
    suspected_duplicate_pairs = [
        {"signature": list(signature), "ids": ids, "status": "REVIEW_CANDIDATE_NOT_CONFIRMED"}
        for signature, ids in duplicate_signatures.items() if len(ids) > 1
    ]
    school_design_count = len(school_records)
    branch_design_count = len(branch_records)
    v63_enabled_count = 0 if not registry.get("enabled", False) else len(registry_school_ids)
    gaps = [
        {"id": "GAP-SCHOOL-REGISTRY-COVERAGE", "title": "Thiết kế 12 phái chưa nằm hết trong registry D1", "severity": "OWNER_REVIEW", "category": "school_registry",
         "summary": f"Nguồn art/design có {school_design_count} môn phái và {branch_design_count} nhánh; registry runtime hiện khai báo {len(registry_school_ids)} phái/{len(registry.get('paths', []))} path và enabled={str(registry.get('enabled', False)).lower()}.",
         "count": school_design_count-len(registry_school_ids), "status": "SOURCE_CONFIRMED_SCOPE_GAP",
         "sourcePath": registry_rel, "sourceSha": registry_src["sourceSha"], "relatedSourcePath": motifs_src["sourcePath"], "relatedSourceSha": motifs_src["sourceSha"],
         "runtimeStatus": "REGISTRY_DISABLED", "qaEvidence": {"status": "TEST_SOURCE_PRESENT_RESULT_NOT_RECHECKED", "sourcePath": "godot/tests/simulation/v63_d1_content_registry_test.gd", "sourceSha": sha256(root / "godot/tests/simulation/v63_d1_content_registry_test.gd") if (root / "godot/tests/simulation/v63_d1_content_registry_test.gd").exists() else ""}},
        {"id": "GAP-V63-OFF", "title": "Trạng thái: feature gate V6.3 đang OFF", "severity": "STATUS_ONLY", "category": "release_gate",
         "summary": f"Có {len(skill_records)} skill ID ứng viên trong catalog V6.3; 18 consumer gate mặc định đều false. Đây là trạng thái hiện hành, không phải lỗi bắt buộc sửa; chỉ xem xét bật khi Owner mở packet phát hành riêng.",
         "count": len(skill_records), "status": "EXPECTED_GATED_OFF_NO_FIX_REQUESTED", "sourcePath": gate_source["sourcePath"], "sourceSha": gate_source["sourceSha"],
         "relatedSourcePath": "godot/data/combat", "relatedSourceSha": "", "runtimeStatus": "GATED_OFF", "qaEvidence": {"status": "TEST_SOURCE_PRESENT_RESULT_NOT_RECHECKED", "sourcePath": "godot/tests/simulation/v63_doc_full_combat_matrix_test.gd", "sourceSha": sha256(root / "godot/tests/simulation/v63_doc_full_combat_matrix_test.gd") if (root / "godot/tests/simulation/v63_doc_full_combat_matrix_test.gd").exists() else ""}},
        {"id": "GAP-PRESENTATION-LINK", "title": "Skills chưa có presentation entry trong manifest", "severity": "DESIGN_QA", "category": "vfx_presentation",
         "summary": f"Manifest có {presentation['entryCount']} entry metadata trên {len(skill_records)} skill; còn {presentation_missing} skill không được liên kết entry. Entry metadata không đồng nghĩa sprite/VFX asset hay GUI approval.",
         "count": presentation_missing, "status": "MANIFEST_LINK_MISSING", "sourcePath": presentation["sourcePath"], "sourceSha": presentation["sourceSha"],
         "relatedSourcePath": "godot/data/combat", "relatedSourceSha": "", "runtimeStatus": "MANIFEST_GATE_OFF", "qaEvidence": {"status": "GUI_PENDING", "sourcePath": presentation["sourcePath"], "sourceSha": presentation["sourceSha"]}},
        {"id": "GAP-FORMULA-TRACE", "title": "Giá trị catalog chưa được trace tới công thức consumer cho từng skill", "severity": "RUNTIME_TRACE_PENDING", "category": "formula_traceability",
         "summary": "Các damage_ratio/power/duration trong candidate catalog là dữ liệu; không được coi là runtime formula. V6.3 gate đang OFF và catalog chưa lưu consumer function/test ID cho từng node.",
         "count": len(skill_records), "status": "FORMULA_CONSUMER_LINK_UNKNOWN", "sourcePath": gate_source["sourcePath"], "sourceSha": gate_source["sourceSha"],
         "relatedSourcePath": "godot/data/combat", "relatedSourceSha": "", "runtimeStatus": "GATED_OFF", "qaEvidence": {"status": "NOT_LINKED_BY_SKILL_ID", "sourcePath": "", "sourceSha": ""}},
        {"id": "GAP-DUPLICATE-SKILL-ID", "title": "Kiểm tra trùng/mất skill ID ở nguồn", "severity": "DATA_INTEGRITY", "category": "catalog_ids",
         "summary": "Validator so sánh ID thô qua tất cả catalog đầu vào trước khi khử trùng. Duplicate ID phải sửa nguồn; không gộp âm thầm.",
         "count": len(duplicate_skill_ids), "status": "DUPLICATE_ID_FOUND" if duplicate_skill_ids else "CLEAN_NO_DUPLICATE_ID",
         "sourcePath": representative_skill_source.get("sourcePath", registry_rel), "sourceSha": representative_skill_source.get("sourceSha", registry_src["sourceSha"]),
         "relatedSourcePath": registry_rel, "relatedSourceSha": registry_src["sourceSha"], "sourceRefs": all_skill_sources, "runtimeStatus": "STATIC_CHECKED",
         "qaEvidence": {"status": "WIKI_SOURCE_VALIDATOR", "sourcePath": "tools/wiki/build_wiki_catalog.py", "sourceSha": sha256(root / "tools/wiki/build_wiki_catalog.py")}},
        {"id": "GAP-SUSPECTED-DUPLICATE-PAIRS", "title": "Cặp skill trùng ngữ nghĩa cần rà soát", "severity": "REVIEW_CANDIDATE", "category": "skill_duplicates",
         "summary": "Đối chiếu tên chuẩn hóa + school + branch + generation. Đây chỉ là heuristic để review; cùng family/slot qua nhiều node không tự động là lỗi.",
         "count": len(suspected_duplicate_pairs), "status": "REVIEW_CANDIDATE_NOT_CONFIRMED" if suspected_duplicate_pairs else "NO_EXACT_NAME_COLLISION",
         "sourcePath": representative_skill_source.get("sourcePath", registry_rel), "sourceSha": representative_skill_source.get("sourceSha", registry_src["sourceSha"]),
         "relatedSourcePath": registry_rel, "relatedSourceSha": registry_src["sourceSha"], "sourceRefs": all_skill_sources, "runtimeStatus": "HEURISTIC_NOT_DECISION",
         "qaEvidence": {"status": "STATIC_HEURISTIC", "sourcePath": "tools/wiki/build_wiki_catalog.py", "sourceSha": sha256(root / "tools/wiki/build_wiki_catalog.py")}},
        {"id": "GAP-VFX-ART", "title": "VFX manifest chưa liệt kê dedicated skill assets", "severity": "ART_PENDING", "category": "vfx_assets",
         "summary": f"VFX manifest có {len(vfx_manifest.get('asset_files', []))} asset_files; presentation manifest ghi capture {presentation['renderCaptureStatus']} và GUI {presentation['guiAcceptanceStatus']}.",
         "count": len(vfx_manifest.get("asset_files", [])), "status": "ART_OR_RENDER_NOT_PROVEN", "sourcePath": vfx_manifest_rel, "sourceSha": vfx_src["sourceSha"],
         "relatedSourcePath": presentation["sourcePath"], "relatedSourceSha": presentation["sourceSha"], "runtimeStatus": "UNKNOWN_PENDING_CAPTURE", "qaEvidence": {"status": "CAPTURE_NOT_COMPLETED", "sourcePath": presentation["sourcePath"], "sourceSha": presentation["sourceSha"]}},
        {"id": "GAP-ART-ANIMATION", "title": "36 nhóm nhân vật chưa có animation riêng được xác minh", "severity": "ART_PENDING", "category": "character_animation",
         "summary": "Art guide xác nhận chuyển động theo từng nhánh chỉ là storyboard direction; không có rig/animation VERIFIED trong bảng coverage. Độc Tu V4 chỉ là candidate theo từng hướng dẫn mỹ thuật.",
         "count": branch_design_count, "status": "NO_VERIFIED_BRANCH_ANIMATION", "sourcePath": motifs_src["sourcePath"], "sourceSha": motifs_src["sourceSha"],
         "relatedSourcePath": "docs/animation/TMB_DISCIPLE_SCHOOL_IDENTITY_BIBLE_20261117.md", "relatedSourceSha": source(root, "docs/animation/TMB_DISCIPLE_SCHOOL_IDENTITY_BIBLE_20261117.md")["sourceSha"],
         "runtimeStatus": "NO_VERIFIED_BRANCH_ANIMATION", "qaEvidence": {"status": "NO_GODOT_ART_QA_LINKED", "sourcePath": "", "sourceSha": ""}},
        {"id": "GAP-EQUIPMENT-AUTHORITY", "title": "Số slot trong spec khác authority EquipmentSystem hiện hành", "severity": "OWNER_REVIEW", "category": "equipment_model",
         "summary": "EquipmentSystem source khai báo 3 slot hợp lệ (weapon/armor/talisman); Weapon Equipment V2 spec mô tả 10 ordinary slots cộng loadout riêng. Giữ hai nguồn cạnh nhau, không tự hợp nhất thành gameplay authority.",
         "count": len(equipment_rows), "status": "SOURCE_CONFLICT_REQUIRES_RECONCILIATION", "sourcePath": equipment_contract_src["sourcePath"], "sourceSha": equipment_contract_src["sourceSha"],
         "relatedSourcePath": equipment_spec_src["sourcePath"], "relatedSourceSha": equipment_spec_src["sourceSha"], "runtimeStatus": "CODE_AND_SPEC_DIVERGE", "qaEvidence": {"status": "SOURCE_COMPARISON_ONLY", "sourcePath": "", "sourceSha": ""}},
        {"id": "GAP-REALM-QA", "title": "Tiến trình 30×10 có code, gói DV2-03 vẫn QA mở", "severity": "QA_PENDING", "category": "realm_progression",
         "summary": "Mã DiscipleRealmProgressV2 có cả hai track 30 realm; checkpoint/handoff là authority trạng thái chấp nhận. Wiki chỉ liên kết test source, không suy diễn PASS từ file test.",
         "count": len(realms), "status": "CODE_PRESENT_QA_OPEN", "sourcePath": realm_src["sourcePath"], "sourceSha": realm_src["sourceSha"],
         "relatedSourcePath": "CURRENT_CHECKPOINT.md", "relatedSourceSha": source(root, "CURRENT_CHECKPOINT.md")["sourceSha"], "runtimeStatus": "QA_OPEN", "qaEvidence": {"status": "TEST_SOURCE_NOT_RUN_HERE", "sourcePath": "godot/tests/simulation/dv2_03_realm_body_progress_test.gd", "sourceSha": realms[0]["qaEvidence"]["sourceSha"] if realms else ""}},
    ]
    counts = {
        "schools": school_design_count, "branches": branch_design_count,
        "skills": len(skill_records), "skillIdsUnique": len({item["id"] for item in skill_records}),
        "skillInputRecords": skill_input_count, "duplicateSkillIds": len(duplicate_skill_ids),
        "suspectedDuplicatePairs": len(suspected_duplicate_pairs),
        "skillFamilies": len({str(item.get("family_id", "")) for item in []}),
        "skillCatalogFiles": len(skill_catalogs), "v63Enabled": v63_enabled_count,
        "presentationEntries": presentation["entryCount"], "presentationMissing": presentation_missing,
        "techniques": len(techniques), "realms": len(realms), "medicineIdentities": len(medicine_items),
        "authoredMedicineRecipes": len(medicine_recipes), "legacyMedicineRecipes": len(legacy_medicine_recipes),
        "medicineRuntimeRecipeDefinitions": len(medicine_recipes) + len(legacy_medicine_recipes), "equipmentRecipes": len(equipment_rows),
        "resources": len(resource_rows), "qaSourcesLinked": len(qa_files),
        "approvedFromExplicitSource": 0,
    }
    # `family_id` is intentionally computed from catalog source records, not a second authority.
    family_ids = {str(item.get("family_id", "")) for path in sorted((root / "godot/data/combat").glob("v63*_combat_catalog.json"))
                  for item in (json.loads(path.read_text(encoding="utf-8-sig")).get("skills", []))}
    counts["skillFamilies"] = len(family_ids - {""})
    feature_gate_record = {"id": "v63_feature_gates", "falseFlagCount": len(gate_keys), "falseFlags": sorted(gate_keys),
                           **gate_source, "runtimeStatus": "ALL_LISTED_DEFAULT_FLAGS_FALSE",
                           "qaEvidence": {"status": "SOURCE_INSPECTED_NOT_EXECUTED", "sourcePath": "", "sourceSha": ""}}
    catalog = {
        "schemaVersion": 1,
        "project": "Tông Môn Bá Đạo — Tàng Kinh Các (owner-only)",
        "visibility": "LOCAL_ONLY_PRIVATE_BY_DEFAULT",
        "sourceCommitSha": commit_sha(root),
        "sourceSyncPolicy": "ONE_WAY_GAME_SOURCE_TO_WIKI; browser proposals are not part of this generated file",
        "counts": counts,
        "schools": school_records,
        "branches": branch_records,
        "skills": skill_records,
        "skillCatalogs": skill_catalogs,
        "presentationManifest": presentation,
        "techniques": techniques,
        "realms": realms,
        "disciples": disciples,
        "spiritualRoots": roots,
        "medicine": medicine_items,
        "medicineRecipes": medicine_recipes + legacy_medicine_recipes,
        "equipmentRecipes": equipment_rows,
        "equipmentAuthority": {"id": "equipment_authority", "runtimeSlots": ["weapon", "armor", "talisman"],
                               "specOrdinarySlotsClaim": 10, **equipment_src,
                               "additionalSourcePath": equipment_spec_src["sourcePath"], "additionalSourceSha": equipment_spec_src["sourceSha"],
                               "runtimeStatus": "SOURCE_CONFLICT_REQUIRES_RECONCILIATION",
                               "qaEvidence": {"status": "SOURCE_COMPARISON_ONLY", "sourcePath": "", "sourceSha": ""}},
        "resources": resource_rows,
        "vfx": vfx_rows,
        "featureGates": [feature_gate_record],
        "qaSources": qa_files,
        "gaps": gaps,
        "dataQuality": {"skillInputRecords": skill_input_count, "skillIdUniqueRecords": len(skill_records),
                        "duplicateSkillIds": duplicate_skill_ids, "suspectedDuplicatePairs": suspected_duplicate_pairs},
        "systems": [
            {"id": "cultivation", "name": "Tu Vi / Luyện Thể", "designed": 30, "implemented": 60, "tested": "PENDING", "approved": "UNKNOWN", "missing": "PENDING", "sourcePath": realm_src["sourcePath"], "sourceSha": realm_src["sourceSha"], "runtimeStatus": "CODE_PRESENT_QA_OPEN"},
            {"id": "combat_v63", "name": "Combat V6.3", "designed": len(skill_records), "implemented": 0, "tested": "PENDING", "approved": "UNKNOWN", "missing": "NOT_IN_RELEASE_SCOPE_WHILE_GATE_OFF", "sourcePath": registry_rel, "sourceSha": registry_src["sourceSha"], "runtimeStatus": "GATED_OFF"},
            {"id": "schools", "name": "12 môn phái / 36 nhánh", "designed": school_design_count + branch_design_count, "implemented": len(registry_school_ids) + len(registry.get("paths", [])), "tested": "PENDING", "approved": "UNKNOWN", "missing": school_design_count-len(registry_school_ids), "sourcePath": motifs_src["sourcePath"], "sourceSha": motifs_src["sourceSha"], "runtimeStatus": "DESIGN_AND_PARTIAL_REGISTRY"},
            {"id": "medicine", "name": "Đan dược / luyện đan", "designed": len(medicine_items), "implemented": len(medicine_recipes) + len(legacy_medicine_recipes), "tested": "PENDING", "approved": "UNKNOWN", "missing": max(0, 119-len(medicine_recipes)), "sourcePath": medicine_src["sourcePath"], "sourceSha": medicine_src["sourceSha"], "runtimeStatus": "PARTIAL_RECIPE_SET"},
            {"id": "equipment", "name": "Trang bị", "designed": 10, "implemented": 3, "tested": "PENDING", "approved": "UNKNOWN", "missing": "AUTHORITY_DIVERGENCE", "sourcePath": equipment_src["sourcePath"], "sourceSha": equipment_src["sourceSha"], "runtimeStatus": "CODE_AND_SPEC_DIVERGE"},
            {"id": "character_art", "name": "Animation đệ tử", "designed": branch_design_count, "implemented": 0, "tested": 0, "approved": 0, "missing": branch_design_count, "sourcePath": motifs_src["sourcePath"], "sourceSha": motifs_src["sourceSha"], "runtimeStatus": "NO_VERIFIED_BRANCH_ANIMATION"},
        ],
    }
    return catalog


def validate_catalog(catalog: dict[str, Any], root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    if catalog.get("schemaVersion") != 1:
        errors.append("schemaVersion must equal 1")
    for collection in ("schools", "branches", "skills", "techniques", "realms", "medicine", "medicineRecipes", "equipmentRecipes", "resources"):
        seen: set[str] = set()
        for row in catalog.get(collection, []):
            item_id = str(row.get("id", ""))
            if not item_id:
                errors.append(f"{collection}: missing id")
            elif item_id in seen:
                errors.append(f"{collection}: duplicate id {item_id}")
            seen.add(item_id)
            rel = str(row.get("sourcePath", ""))
            if not rel:
                errors.append(f"{collection}/{item_id}: missing sourcePath")
            elif not (root / rel).is_file():
                errors.append(f"{collection}/{item_id}: source path missing: {rel}")
            elif row.get("sourceSha") != sha256(root / rel):
                errors.append(f"{collection}/{item_id}: source SHA mismatch: {rel}")
    if len(catalog.get("schools", [])) != 12:
        errors.append("design school count must be exactly 12")
    if len(catalog.get("branches", [])) != 36:
        errors.append("design branch count must be exactly 36")
    if len({row.get("id") for row in catalog.get("skills", [])}) != len(catalog.get("skills", [])):
        errors.append("skill IDs are not unique")
    return errors


def make_audit(catalog: dict[str, Any]) -> str:
    c = catalog["counts"]
    lines = [
        "# TMB Wiki — kiểm kê nguồn và coverage",
        "",
        f"- Snapshot source HEAD: `{catalog['sourceCommitSha']}`",
        f"- Schema: `{catalog['schemaVersion']}` · chế độ: `{catalog['visibility']}` · đồng bộ: một chiều game → Wiki.",
        "- Generated projection chỉ chứa nguồn repo; ghi chú và đề xuất owner nằm trong localStorage của trình duyệt, không được ghi vào repo.",
        "- SHA trong bảng là SHA-256 của từng file nguồn tại snapshot này.",
        "",
        "## Coverage đã trích xuất",
        "",
        "| Nhóm | Số lượng | Diễn giải trạng thái |",
        "|---|---:|---|",
        f"| Môn phái | {c['schools']} | Design taxonomy |",
        f"| Nhánh | {c['branches']} | Art guide, chưa xác nhận animation runtime |",
        f"| Skill V6.3 | {c['skills']} | ID duy nhất {c['skillIdsUnique']}; catalog ứng viên, gate OFF |",
        f"| Skill family | {c['skillFamilies']} | ID `family_id` duy nhất trong catalog |",
        f"| Presentation entry | {c['presentationEntries']} | Metadata manifest, không phải asset art/GUI approval |",
        f"| Thiếu presentation entry | {c['presentationMissing']} | Tính bằng ID chéo manifest / catalog |",
        f"| Công pháp | {c['techniques']} | Candidate; learning gate OFF |",
        f"| Cảnh giới | {c['realms']} | Hai track từ code; DV2-03 QA open |",
        f"| Định danh đan dược | {c['medicineIdentities']} | Sinh theo catalog; không đồng nghĩa recipe có thể chế |",
        f"| Recipe đan authored | {c['authoredMedicineRecipes']} | Recipe definition trong MedicineCatalogueV2 |",
        f"| Recipe đan legacy | {c['legacyMedicineRecipes']} | Giữ riêng; không trộn ID legacy vào tập 119 định danh V2 |",
        f"| Recipe trang bị | {c['equipmentRecipes']} | Từ EquipmentSystem; có gap so với spec 10 slot |",
        f"| Resource | {c['resources']} | Từ ResourceRegistry |",
        f"| QA source liên kết | {c['qaSourcesLinked']} | File test hiện hữu; kết quả chưa được chạy/đối chiếu lại tại snapshot này |",
        "",
        "## Gap register",
        "",
        "| ID | Mức | Tình trạng | Mô tả | Nguồn | SHA-256 |",
        "|---|---|---|---|---|---|",
    ]
    for gap in catalog["gaps"]:
        lines.append(f"| {gap['id']} | {gap['severity']} | {gap['status']} | {gap['summary']} | `{gap['sourcePath']}` | `{gap['sourceSha']}` |")
    lines.extend(["", "## Giới hạn đọc dữ liệu", "", "- `PENDING`/`UNKNOWN` nghĩa là nguồn hiện tại chưa cho phép kết luận; Wiki không đoán PASS.",
                  "- `SPEC_ONLY` không được đổi thành `LIVE_VERIFIED`; `TECH_PASS` không được đổi thành `ART_APPROVED`.",
                  "- Dashboard phân biệt dữ liệu thiết kế, mã/registry, feature gate, test source, kết quả test và phê duyệt owner.",
                  "- Không có file save cá nhân hoặc dữ liệu người chơi được đưa vào catalog.", ""])
    return "\n".join(lines)


def write_projection(catalog: dict[str, Any], root: Path = ROOT, output_override: Path | None = None) -> tuple[Path, Path]:
    data_path = output_override or (root / "wiki/data/catalog.json")
    audit_path = root / "docs/wiki/TMB_WIKI_SOURCE_AUDIT.md"
    data_path.parent.mkdir(parents=True, exist_ok=True)
    audit_path.parent.mkdir(parents=True, exist_ok=True)
    data_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    audit_path.write_text(make_audit(catalog), encoding="utf-8")
    return data_path, audit_path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="compare generated projection with checked-in catalog")
    parser.add_argument("--write", action="store_true", help="write the one-way source projection")
    args = parser.parse_args()
    catalog = build_catalog(ROOT)
    errors = validate_catalog(catalog, ROOT)
    if errors:
        print("WIKI VALIDATION FAIL")
        print("\n".join(f"- {err}" for err in errors))
        return 1
    if args.check:
        expected = json.dumps(catalog, ensure_ascii=False, indent=2) + "\n"
        checked = ROOT / "wiki/data/catalog.json"
        if not checked.exists() or checked.read_text(encoding="utf-8") != expected:
            print("WIKI SOURCE SYNC STALE")
            return 2
        print("WIKI SOURCE SYNC PASS")
    elif args.write:
        data_path, audit_path = write_projection(catalog, ROOT)
        print(f"WROTE {data_path.relative_to(ROOT).as_posix()}")
        print(f"WROTE {audit_path.relative_to(ROOT).as_posix()}")
    else:
        print(json.dumps(catalog["counts"], ensure_ascii=False, sort_keys=True))
    print(f"PASS source records={sum(catalog['counts'][k] for k in ('schools','branches','skills','techniques','realms','medicineIdentities','medicineRuntimeRecipeDefinitions','equipmentRecipes','resources'))}; gaps={len(catalog['gaps'])}; HEAD={catalog['sourceCommitSha']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
