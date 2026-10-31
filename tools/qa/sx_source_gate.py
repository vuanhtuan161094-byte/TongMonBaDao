#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""SX-GATE-01: read-only, zero-dependency production content risk gate.

This checks *static definitions*, not live economy balance or Godot gameplay.
Run from any checkout: python tools/qa/sx_source_gate.py --root .
Use --strict to return exit 2 while P0 blockers exist (useful as a CI gate).
No files or player saves are modified unless --json-out is explicitly given.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

MILESTONES_DEFAULT = (10, 20, 30, 50, 75, 100)
REPORT_VERSION = "sx-gate-01.v1"


def braced(text: str, begin: int) -> str:
    """Return a full {...} block; ignore braces inside strings and comments."""
    pos = text.find("{", begin)
    if pos < 0:
        raise ValueError("opening brace not found")
    start = pos
    depth, quoted, escaped, comment = 0, False, False, False
    for i in range(pos, len(text)):
        c = text[i]
        if comment:
            if c == "\n":
                comment = False
            continue
        if quoted:
            if escaped:
                escaped = False
            elif c == "\\":
                escaped = True
            elif c == '"':
                quoted = False
            continue
        if c == '#':
            comment = True
        elif c == '"':
            quoted = True
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return text[start:i + 1]
    raise ValueError("unterminated dictionary")


def const_map(text: str, name: str) -> str:
    found = re.search(r"(?m)^const\s+" + re.escape(name) + r"\s*:=\s*\{", text)
    if not found:
        raise ValueError("missing const dictionary " + name)
    return braced(text, found.start())


def key_map(parent: str, name: str) -> str:
    found = re.search(r'(?m)^\s{4}"' + re.escape(name) + r'"\s*:\s*\{', parent)
    if not found:
        raise ValueError("missing key " + name)
    return braced(parent, found.start())


def value_int(blob: str, key: str, default: int = 0) -> int:
    match = re.search(r'"' + re.escape(key) + r'"\s*:\s*(\d+)', blob)
    return int(match.group(1)) if match else default


def value_bool(blob: str, key: str, default: bool = True) -> bool:
    match = re.search(r'"' + re.escape(key) + r'"\s*:\s*(true|false)', blob)
    return match.group(1) == "true" if match else default


def literal_constant(text: str, key: str) -> str:
    match = re.search(r'(?m)^const\s+' + re.escape(key) + r'\s*:=\s*&?"([^"]+)"', text)
    return match.group(1) if match else ""


def line_number(text: str, snippet: str) -> int:
    where = text.find(snippet)
    return text.count("\n", 0, where) + 1 if where >= 0 else 0


def read_file(root: Path, relative: str, required: bool = True) -> str:
    path = root / "godot" / "src" / "simulation" / relative
    if not path.is_file():
        if required:
            raise FileNotFoundError(str(path))
        return ""
    return path.read_text(encoding="utf-8-sig")


def potential_sources(root: Path, building_code: str) -> dict[str, list[str]]:
    """Static source candidates. NOT evidence of playable/accessible output."""
    from collections import defaultdict

    sources: dict[str, list[str]] = defaultdict(list)

    def mark(item: str, description: str) -> None:
        if item and description not in sources[item]:
            sources[item].append(description)

    definitions = const_map(building_code, "DEFINITIONS")
    for building_id in ("mine", "linh_forest"):
        item_blob = key_map(definitions, building_id)
        match = re.search(r'"resource_id"\s*:\s*(MATERIAL_\w+|&?"[^"]+")', item_blob)
        if match:
            value = match.group(1)
            item = literal_constant(building_code, value) if value.startswith("MATERIAL_") else value.strip('&"')
            mark(item, "BuildingSystem " + building_id + " [coded producer; not GUI verified]")

    crops = read_file(root, "building/spirit_crop_registry.gd")
    for item in re.findall(r'"output_resource_id"\s*:\s*"([^"]+)"', crops):
        mark(item, "SpiritCropRegistry field [crop level and costs apply]")

    alchemy = read_file(root, "building/alchemy_recipe_registry.gd")
    for item in re.findall(r'"output_resource_id"\s*:\s*"([^"]+)"', alchemy):
        mark(item, "AlchemyRecipeRegistry recipe [inputs and job needed]")

    hunting = read_file(root, "combat/hunting_map_v2.gd", required=False)
    if hunting:
        for item in re.findall(r'"resources"\s*:\s*\{([^}]+)\}', hunting):
            for key in re.findall(r'"([^"]+)"\s*:\s*\d+', item):
                mark(key, "HuntingMapV2 reward preview [settlement NOT verified]")
        for rare in re.findall(r'"rare"\s*:\s*"([^"]+)"', hunting):
            mark(rare, "HuntingMapV2 rare candidate [roll and payout needed]")
    economy = read_file(root, "economy/economy_system.gd", required=False)
    if economy:
        match = re.search(r'const\s+V2_MARKET_CATALOG\s*:=\s*\[([^]]*)\]', economy)
        if match:
            for item in re.findall(r'"([^"]+)"', match.group(1)):
                mark(item, "Economy-A market [money, stock and caps apply]")
    equipment = read_file(root, "equipment/equipment_system.gd", required=False)
    if equipment:
        for item in re.findall(r'loot\["([^"]+)"\]\s*\+?=', equipment):
            mark(item, "EquipmentSystem legacy monster loot [world route not verified]")
    if "convert_linh_tuyen_fragments" in building_code:
        item = literal_constant(building_code, "MATERIAL_LINH_TUYEN_HEART")
        mark(item, "BuildingSystem 100-fragment conversion [probabilistic supplier]")
    return dict(sources)


def run(root: Path, level_target_multiplier: int = 10000) -> dict[str, Any]:
    code = read_file(root, "building/building_system.gd")
    registry = read_file(root, "resource/resource_registry.gd")
    defs = const_map(code, "DEFINITIONS")
    component_table = const_map(code, "MILESTONE_COMPONENTS")
    components = {
        "mine": key_map(component_table, "mine"),
        "spirit_field": key_map(component_table, "spirit_field"),
    }
    ids = re.findall(r'(?m)^    "([a-z0-9_]+)"\s*:\s*\{', const_map(registry, "DEFINITIONS"))
    known = set(ids)
    sources = potential_sources(root, code)
    levels = re.search(r'const\s+MILESTONE_LEVELS\s*:=\s*\[([^]]+)\]', code)
    milestones = sorted({int(x) for x in re.findall(r'\d+', levels.group(1))}) if levels else list(MILESTONES_DEFAULT)
    issues: list[dict[str, Any]] = []

    def add(severity: str, code_id: str, subject: str, message: str, evidence: str) -> None:
        issues.append({"severity": severity, "id": code_id, "subject": subject,
                       "message": message, "evidence": evidence})

    buildings = ("mine", "linh_forest", "alchemy_hall", "spirit_field",
                 "ren_than_duong", "dan_tien_dai")
    building_rows: list[dict[str, Any]] = []
    for building_id in buildings:
        data = key_map(defs, building_id)
        enabled = value_bool(data, "upgrade_enabled", True)
        requires = value_bool(data, "requires_milestone_component", True)
        base_slots = value_int(data, "base_worker_slots")
        every = value_int(data, "worker_slot_every")
        slots_100 = base_slots + (100 // every if every > 0 else 0)
        base_batch = value_int(data, "base_batch_units")
        batch_100 = base_batch + 10 if base_batch > 0 else None
        building_rows.append({"building": building_id, "upgrade_enabled": enabled,
                              "milestone_required": requires, "slots_lv1": base_slots + (1 // every if every else 0),
                              "slots_lv100": slots_100,
                              "base_batch": base_batch, "batch_lv100": batch_100})
        if not enabled:
            add("P0", "UPGRADE_DISABLED", building_id,
                "The 100-level definition explicitly disables upgrades.",
                "BuildingSystem.DEFINITIONS." + building_id + ".upgrade_enabled=false")
            continue
        if building_id == "ren_than_duong" and "body_training_upgrade_content_pending" in code:
            add("P1", "BODY_UPGRADE_CONTENT_PENDING", building_id,
                "Body Hall has explicit unimplemented upgrade content gate.",
                "BuildingSystem: body_training_upgrade_content_pending")
        if not requires:
            continue
        listed = components.get(building_id, "")
        for milestone in milestones:
            match = re.search(r'(?m)^\s+' + str(milestone) + r'\s*:\s*(MATERIAL_\w+|&?"[^"]+")', listed)
            if not match:
                add("P0", "MILESTONE_UNDEFINED", building_id + " Lv" + str(milestone),
                    "Upgrade requires a milestone component but none is defined.",
                    "BuildingSystem.MILESTONE_COMPONENTS/" + building_id)
                continue
            constant = match.group(1)
            item = literal_constant(code, constant) if constant.startswith("MATERIAL_") else constant.strip('&"')
            if item not in known:
                add("P0", "MILESTONE_UNKNOWN_RESOURCE", item,
                    "Milestone refers to an unregistered resource.",
                    "BuildingSystem.MILESTONE_COMPONENTS/" + building_id)
            elif item not in sources:
                add("P0", "MILESTONE_NO_SOURCE_FOUND", item,
                    "No non-fixture producer found in covered production/PvE/market code.",
                    "BuildingSystem.MILESTONE_COMPONENTS/" + building_id)

    forest = next(row for row in building_rows if row["building"] == "linh_forest")
    mine = next(row for row in building_rows if row["building"] == "mine")
    # One batch per worker every base 10 Economy-A ticks, speed=1. This is
    # NOT a real runtime throughput measurement.
    mine_nominal = (mine["slots_lv100"] * (mine["batch_lv100"] or 0)
                    / max(1, mine["slots_lv1"] * mine["base_batch"]))
    if mine_nominal < level_target_multiplier:
        add("P1", "LV100_YIELD_TARGET_MISMATCH", "mine",
            "Nominal full-staff output ratio %.1fx vs owner target %dx; no speed modifiers assumed."
            % (mine_nominal, level_target_multiplier),
            "BuildingSystem._resource_job_batch_units + worker_slots")
    if not forest["upgrade_enabled"]:
        pass
    drop_match = re.search(r'const\s+LINH_TUYEN_FRAGMENT_BASE_CHANCE\s*:=\s*([0-9.]+)', code)
    per_heart = re.search(r'const\s+LINH_TUYEN_FRAGMENT_PER_HEART\s*:=\s*(\d+)', code)
    if drop_match and per_heart:
        chance = float(drop_match.group(1))
        fragments = int(per_heart.group(1))
        field_milestones = [m for m in milestones if m in (10, 20, 30, 50, 75, 100)]
        hearts = sum((m + 9) // 10 for m in field_milestones)
        rolls = hearts * fragments / chance if chance > 0 else None
        add("P1", "FIELD_RNG_PROGRESS_TIME", "spirit_field",
            "Need %d hearts = %d fragments; expected %.0f harvest rolls at base p=%g (no pity, not elapsed time)."
            % (hearts, hearts * fragments, rolls or float("inf"), chance),
            "BuildingSystem: fragment chance + conversion + field milestone quantities")
    # Catalogue check is informational; it does not claim Godot import or rank reachability.
    medicine_path = root / "godot/src/simulation/building/medicine_catalogue_v2.gd"
    medicine: dict[str, Any] = {"present": False}
    if medicine_path.is_file():
        txt = medicine_path.read_text(encoding="utf-8-sig")
        match = re.search(r'const\s+AUTHORED_RECIPE_REALMS\s*:=\s*\[([^]]*)\]', txt)
        tiers = [int(x) for x in re.findall(r'\d+', match.group(1))] if match else []
        medicine = {"present": True, "registered_variants_expected": 30 * 4 * 2,
                    "authored_realms": tiers, "authored_recipe_ids_expected": len(tiers) * 2}
        if len(tiers) < 30:
            add("P1", "MEDICINE_UNAUTHORED_TIERS", "medicine",
                "%d/30 medicine realm tiers have authored recipe metadata; not proof of crafting."
                % len(tiers), "MedicineCatalogueV2.AUTHORED_RECIPE_REALMS")

    issues.sort(key=lambda x: (x["severity"], x["id"], x["subject"]))
    return {"schema": REPORT_VERSION, "root": str(root.resolve()),
            "resource_ids_baseline": len(ids), "buildings": building_rows,
            "medicine": medicine, "issues": issues,
            "counts": {"P0": sum(i["severity"] == "P0" for i in issues),
                       "P1": sum(i["severity"] == "P1" for i in issues)},
            "disclaimer": "Static candidate source graph, not playable-route or Godot QA proof"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2],
                        help="Repository root containing godot/src/simulation")
    parser.add_argument("--json-out", type=Path, help="Optional output path; no writes by default")
    parser.add_argument("--strict", action="store_true", help="Exit 2 if P0 blockers exist")
    args = parser.parse_args()
    try:
        result = run(args.root)
    except (OSError, ValueError, KeyError) as exc:
        print("SX-GATE ERROR:", exc, file=sys.stderr)
        return 3
    print("SX-GATE: %d P0, %d P1; %d base resource IDs; medicine=%s" %
          (result["counts"]["P0"], result["counts"]["P1"],
           result["resource_ids_baseline"], result["medicine"]["present"]))
    for issue in result["issues"]:
        print("[%s] %s %s: %s" % (issue["severity"], issue["id"],
                                  issue["subject"], issue["message"]))
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                                 encoding="utf-8")
    return 2 if args.strict and result["counts"]["P0"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
