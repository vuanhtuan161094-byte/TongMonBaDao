#!/usr/bin/env python3
"""TMB source-to-ledger VFX planning audit. Stdlib only; never changes gameplay."""
import csv
import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "godot/data/combat"
LEAD = ROOT / "docs/operations/vfx_school_ledgers"
CATALOGS = [
    "human", "immortal", "divine", "sword", "talisman", "blade",
    "dual_blade", "spear", "palm", "curse", "formation", "summon",
]
SCHOOLS = [
    "poison", "talisman", "sword", "bow", "fist", "blade",
    "dual_blade", "spear", "palm", "curse", "formation", "summon",
]
EXPECTED_TIER_COUNTS = {"human": 35, "immortal": 68, "divine": 80}
REQUIRED_COLUMNS = [
    "skill_id", "family_id", "school", "branch", "slot", "tier", "name_vi",
    "vfx_key_declared", "visual_work_class", "lab_visual_status",
    "owner_gate", "live_integration",
]

def require(ok, message):
    if not ok:
        raise ValueError(message)

def audit():
    canonical = {}
    release_disabled = 0
    for name in CATALOGS:
        path = SRC / f"v63_{name}_combat_catalog.json"
        require(path.is_file(), f"missing canonical source: {path}")
        data = json.loads(path.read_text(encoding="utf-8-sig"))
        release_disabled += data.get("enabled") is False
        require(isinstance(data.get("skills"), list), f"{path}: missing skills[]")
        for skill in data["skills"]:
            identifier = skill.get("id") or skill.get("node_id")
            require(identifier, f"{path}: unnamed skill")
            require(identifier not in canonical, f"duplicate canonical ID: {identifier}")
            canonical[identifier] = skill

    records = {}
    report = []
    for number, school in enumerate(SCHOOLS, 1):
        path = LEAD / f"{number:02d}_{school}_183.csv"
        require(path.is_file(), f"missing VFX ledger: {path}")
        with path.open(encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f)
            require(set(REQUIRED_COLUMNS).issubset(reader.fieldnames or []),
                    f"{path}: missing ledger columns")
            rows = list(reader)
        require(len(rows) == 183, f"{school}: expected 183, found {len(rows)}")
        require(all(row["school"] == school for row in rows), f"{school}: misfiled school")
        family_ids = {row["family_id"] for row in rows}
        casts = {row["family_id"] for row in rows if row["visual_work_class"] == "CAST_MASTER"}
        event_families = family_ids - casts
        branches = {row["branch"] for row in rows if row["branch"] != "shared"}
        tiers = Counter(row["tier"] for row in rows)
        require(len(family_ids) == 35, f"{school}: expected 35 families")
        require(len(casts) == 17 and len(event_families) == 18,
                f"{school}: cast/event families must equal 17/18")
        require(len(branches) == 3, f"{school}: expected three paths")
        require(dict(tiers) == EXPECTED_TIER_COUNTS,
                f"{school}: unexpected Human/Immortal/Divine split: {dict(tiers)}")
        for row in rows:
            identifier = row["skill_id"]
            require(identifier not in records, f"duplicate ledger ID: {identifier}")
            require(identifier in canonical, f"not in canonical catalogue: {identifier}")
            skill = canonical[identifier]
            for key in ("school", "slot", "tier", "family_id"):
                require(row[key] == str(skill.get(key, "")),
                        f"{identifier}: mismatched {key}")
            source_branch = skill.get("branch") or "shared"
            require(row["branch"] == source_branch, f"{identifier}: mismatched branch")
            require(bool(row["name_vi"].strip()), f"{identifier}: missing Vietnamese name")
            require(row["live_integration"], f"{identifier}: missing live-gate label")
            records[identifier] = row
        statuses = Counter(row["owner_gate"] for row in rows)
        text_pending = sum("text_pending" in row["vfx_key_declared"].lower() for row in rows)
        report.append({"school": school, "ids": 183, "families": 35, "casts": 17,
                       "event_only": 18, "owner_gates": dict(statuses),
                       "text_pending": text_pending})

    require(set(records) == set(canonical), "source/catalogue ID set mismatch")
    require(len(records) == 2196 and len(canonical) == 2196,
            f"expected 2196 unique IDs; ledger={len(records)} source={len(canonical)}")
    require(len({r["family_id"] for r in records.values()}) == 420,
            "expected 420 unique skill families")
    require(release_disabled == 12,
            f"expected 12 gated/disabled source catalogues, found {release_disabled}")
    require(next(r for r in report if r["school"] == "curse")["text_pending"] == 183,
            "Chú Tu unresolved VFX text keys must be flagged, not silently accepted")
    result = {"result": "PASS", "canonical_ids": len(canonical), "ledger_ids": len(records),
              "school_count": len(report), "specialization_paths": 36,
              "family_count": 420, "cast_master_families": 204,
              "passive_innate_event_families": 216,
              "disabled_catalogues": release_disabled, "schools": report}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return result

if __name__ == "__main__":
    try:
        audit()
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print("VFX_SCHOOL_CATALOG_AUDIT=FAIL", str(exc), file=sys.stderr)
        sys.exit(1)
    print("VFX_SCHOOL_CATALOG_AUDIT=PASS")
