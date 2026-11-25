#!/usr/bin/env python3
"""Build an evidence-scoped inventory from the 12 canonical VFX ledgers.

Scene presence is discovered from actual LAB scenes and their bound scripts.
It does not imply technical approval, owner approval, or live PvE integration.
"""

import argparse
import csv
import re
from collections import defaultdict
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GODOT_ROOT = ROOT / "godot"
LEDGERS = ROOT / "docs/operations/vfx_school_ledgers"
SCHOOL_FILES = [
    "01_poison_183.csv",
    "02_talisman_183.csv",
    "03_sword_183.csv",
    "04_bow_183.csv",
    "05_fist_183.csv",
    "06_blade_183.csv",
    "07_dual_blade_183.csv",
    "08_spear_183.csv",
    "09_palm_183.csv",
    "10_curse_183.csv",
    "11_formation_183.csv",
    "12_summon_183.csv",
]
CONTRACT_FIELDS = (
    "effect_declared",
    "shape_declared",
    "target_limit_declared",
    "visual_work_class",
)
SWORD_PROVISIONAL_OWNER_EVIDENCE = (
    "OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL"
)
SKILL_ID_RE = re.compile(r"tmb\.skill\.[A-Za-z0-9_.-]+")
SCRIPT_PATH_RE = re.compile(r'path="res://([^" ]+\.gd)"')
GODOT_ROOT_RE = re.compile(
    r"(?m)^\s*const\s+[A-Za-z_]\w*\s*(?::[^=]+)?\s*:?=\s*"
    r"[\"']res://([^\"']+)[\"']"
)
JSON_NAME_RE = re.compile(r"[\"']([^\"']+\.json)[\"']")
INDEX_EXPRESSION_RE = re.compile(
    r"(?:\b[A-Z][A-Z0-9_]*\s*|\[\s*[\"']skills[\"']\s*\]\s*)"
    r"\[\s*([A-Za-z_]\w*)\s*\]"
)


def load_ledgers():
    records = []
    for filename in SCHOOL_FILES:
        path = LEDGERS / filename
        with path.open(encoding="utf-8-sig", newline="") as ledger_file:
            rows = list(csv.DictReader(ledger_file))
        if len(rows) != 183:
            raise ValueError(f"{filename}: expected 183 rows, found {len(rows)}")
        records.extend(rows)

    skill_ids = [row["skill_id"] for row in records]
    if len(records) != 2196 or len(set(skill_ids)) != 2196:
        raise ValueError("The source ledgers must contain 2,196 unique skill IDs")
    if len({row["family_id"] for row in records}) != 420:
        raise ValueError("The source ledgers must contain 420 skill families")

    human_rows = [row for row in records if row["tier"] == "human"]
    human_by_family = defaultdict(list)
    for row in human_rows:
        human_by_family[row["family_id"]].append(row)
    if len(human_rows) != 420 or any(len(rows) != 1 for rows in human_by_family.values()):
        raise ValueError("Each of the 420 skill families must have one Human row")
    human_cast_masters = [
        row for row in human_rows if row["visual_work_class"] == "CAST_MASTER"
    ]
    if len(human_cast_masters) != 204:
        raise ValueError("The source ledgers must contain 204 Human cast masters")

    family_rows = defaultdict(list)
    for row in records:
        family_rows[row["family_id"]].append(row)
    missing_human_families = set(family_rows) - set(human_by_family)
    if missing_human_families:
        raise ValueError(
            "Families without a Human cast master: "
            + ", ".join(sorted(missing_human_families)[:8])
        )
    return records, human_rows, human_cast_masters, human_by_family


def read_scene_script_ids(script_path, human_ids):
    """Read skill IDs from a scene's referenced script and its named manifests."""
    try:
        script_text = script_path.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return []

    ids = list(dict.fromkeys(
        skill_id
        for skill_id in SKILL_ID_RE.findall(script_text)
        if skill_id in human_ids
    ))

    manifest_paths = set()
    roots = [GODOT_ROOT / relative for relative in GODOT_ROOT_RE.findall(script_text)]
    for name in JSON_NAME_RE.findall(script_text):
        candidate = Path(name)
        if name.startswith("res://"):
            manifest_paths.add(GODOT_ROOT / name.removeprefix("res://"))
        else:
            manifest_paths.add(script_path.parent / candidate)
            manifest_paths.update(root / candidate for root in roots)

    for manifest_path in manifest_paths:
        if not manifest_path.is_file():
            continue
        try:
            manifest_text = manifest_path.read_text(encoding="utf-8")
        except (OSError, UnicodeError):
            continue
        ids.extend(
            skill_id
            for skill_id in SKILL_ID_RE.findall(manifest_text)
            if skill_id in human_ids and skill_id not in ids
        )
    return ids


def scene_slot(scene_text, script_text):
    indexed_variables = INDEX_EXPRESSION_RE.findall(script_text)
    for variable in indexed_variables:
        scene_value = re.search(
            rf"(?m)^\s*{re.escape(variable)}\s*=\s*(-?\d+)\s*$", scene_text
        )
        if scene_value:
            return int(scene_value.group(1))
        script_default = re.search(
            rf"(?m)^\s*var\s+{re.escape(variable)}\s*:\s*int\s*=\s*(-?\d+)",
            script_text,
        )
        if script_default:
            return int(script_default.group(1))
    return None


def discover_human_lab_scenes(human_by_family):
    human_id_to_family = {
        rows[0]["skill_id"]: family_id
        for family_id, rows in human_by_family.items()
    }
    human_ids = set(human_id_to_family)
    family_scenes = defaultdict(set)

    lab_roots = [
        GODOT_ROOT / "labs/combat_lab",
        GODOT_ROOT / "labs/visual_bridge_v1",
    ]
    for lab_root in lab_roots:
        if not lab_root.is_dir():
            continue
        for scene_path in sorted(lab_root.rglob("*.tscn")):
            relative_scene = scene_path.relative_to(ROOT)
            if lab_root.name == "combat_lab" and scene_path.parent == lab_root:
                continue
            if lab_root.name == "visual_bridge_v1" and not scene_path.name.endswith("_lab.tscn"):
                continue
            if scene_path.name == "vfx_web_review_hub.tscn":
                continue
            try:
                scene_text = scene_path.read_text(encoding="utf-8")
            except (OSError, UnicodeError):
                continue

            scene_ids = [
                skill_id
                for skill_id in SKILL_ID_RE.findall(scene_text)
                if skill_id in human_ids
            ]
            bound_ids = list(dict.fromkeys(scene_ids))

            for relative_script in SCRIPT_PATH_RE.findall(scene_text):
                script_path = GODOT_ROOT / relative_script.removeprefix("res://")
                if not script_path.is_file():
                    continue
                try:
                    script_text = script_path.read_text(encoding="utf-8")
                except (OSError, UnicodeError):
                    continue
                script_ids = read_scene_script_ids(script_path, human_ids)
                if not script_ids:
                    continue

                if len(script_ids) == 1:
                    selected_ids = script_ids
                else:
                    families = {human_id_to_family[skill_id] for skill_id in script_ids}
                    if len(families) == 1:
                        selected_ids = script_ids
                    else:
                        slot = scene_slot(scene_text, script_text)
                        selected_ids = (
                            [script_ids[slot]] if slot is not None and 0 <= slot < len(script_ids) else []
                        )
                for skill_id in selected_ids:
                    if skill_id not in bound_ids:
                        bound_ids.append(skill_id)

            for skill_id in bound_ids:
                family_scenes[human_id_to_family[skill_id]].add(relative_scene.as_posix())

    return family_scenes


def owner_status(owner_gate):
    status = owner_gate.strip().upper()
    if "PROVISIONAL" in status:
        return "OWNER_PROVISIONAL"
    if "PENDING" in status:
        return "OWNER_VISUAL_PENDING"
    if "APPROVED" in status:
        return "OWNER_VISUAL_APPROVED"
    return "OWNER_GATE_UNCLASSIFIED"


def annotate_records(records, human_by_family, family_scenes):
    annotated = []
    for source_row in records:
        row = dict(source_row)
        family_id = row["family_id"]
        human = human_by_family[family_id][0]
        scenes = sorted(family_scenes.get(family_id, set()))
        mismatches = [
            field
            for field in CONTRACT_FIELDS
            if row[field].strip() != human[field].strip()
        ]

        row["source_owner_gate"] = row["owner_gate"]
        row["owner_status_derived"] = owner_status(row["owner_gate"])
        row["owner_status_effective"] = row["owner_status_derived"]
        row["owner_decision_evidence"] = "LEDGER_OWNER_GATE"
        if (
            row["school"] == "sword"
            and row["tier"] == "human"
            and row["visual_work_class"] == "CAST_MASTER"
        ):
            row["owner_status_effective"] = "OWNER_PROVISIONAL"
            row["owner_decision_evidence"] = SWORD_PROVISIONAL_OWNER_EVIDENCE
        row["human_reference_skill_id"] = human["skill_id"]
        row["human_fallback_mismatch_fields"] = ";".join(mismatches)
        row["dedicated_human_lab_scene_count"] = str(len(scenes))
        row["dedicated_human_lab_scenes"] = ";".join(scenes)

        if row["tier"] == "human":
            row["human_fallback_compatibility"] = "HUMAN_CANONICAL"
        elif mismatches:
            row["human_fallback_compatibility"] = "FALLBACK_INCOMPATIBLE"
        else:
            row["human_fallback_compatibility"] = (
                "CONTRACT_COMPATIBLE_HUMAN_FALLBACK_PENDING"
            )

        if row["visual_work_class"] != "CAST_MASTER":
            row["vfx_inventory_status"] = "PASSIVE_EVENT_RECEIPT_GATED"
        elif row["tier"] == "human":
            row["vfx_inventory_status"] = row["owner_status_effective"]
        else:
            row["vfx_inventory_status"] = row["human_fallback_compatibility"]

        annotated.append(row)
    return annotated


def school_summaries(records, family_scenes):
    summaries = []
    for filename in SCHOOL_FILES:
        school = filename.split("_", 1)[1].removesuffix("_183.csv")
        school_rows = [row for row in records if row["school"] == school]
        school_human_rows = [row for row in school_rows if row["tier"] == "human"]
        school_humans = [
            row for row in school_human_rows if row["visual_work_class"] == "CAST_MASTER"
        ]
        all_human_families = {row["family_id"] for row in school_human_rows}
        cast_families = {row["family_id"] for row in school_humans}
        scene_families = all_human_families.intersection(family_scenes)
        cast_scene_families = cast_families.intersection(family_scenes)
        cast_scenes = {
            scene
            for family_id in cast_families
            for scene in family_scenes.get(family_id, set())
        }
        all_scenes = {
            scene
            for family_id in all_human_families
            for scene in family_scenes.get(family_id, set())
        }
        fallback_rows = [
            row
            for row in school_rows
            if row["tier"] in {"immortal", "divine"}
            and row["visual_work_class"] == "CAST_MASTER"
        ]
        summaries.append(
            {
                "school": school,
                "skill_id_count": len(school_rows),
                "family_count": len({row["family_id"] for row in school_rows}),
                "human_cast_master_count": len(school_humans),
                "human_families_with_lab_scene": len(scene_families),
                "human_family_lab_scene_revision_count": len(all_scenes),
                "human_cast_families_with_lab_scene": len(cast_scene_families),
                "human_cast_lab_scene_revision_count": len(cast_scenes),
                "human_owner_approved_count": sum(
                    row["owner_status_effective"] == "OWNER_VISUAL_APPROVED"
                    for row in school_humans
                ),
                "human_provisional_count": sum(
                    row["owner_status_effective"] == "OWNER_PROVISIONAL"
                    for row in school_humans
                ),
                "human_pending_count": sum(
                    row["owner_status_effective"] == "OWNER_VISUAL_PENDING"
                    for row in school_humans
                ),
                "human_ledger_effective_status_conflicts": sum(
                    row["owner_status_effective"] != row["owner_status_derived"]
                    for row in school_humans
                ),
                "tier_fallback_pending_rows": sum(
                    not row["human_fallback_mismatch_fields"] for row in fallback_rows
                ),
                "tier_fallback_incompatible_rows": sum(
                    bool(row["human_fallback_mismatch_fields"]) for row in fallback_rows
                ),
                "passive_event_receipt_gated_rows": sum(
                    row["visual_work_class"] != "CAST_MASTER" for row in school_rows
                ),
            }
        )
    return summaries


def write_csv(path, rows, fieldnames=None):
    if fieldnames is None:
        fieldnames = list(rows[0]) if rows else []
    with path.open("w", encoding="utf-8-sig", newline="") as output_file:
        writer = csv.DictWriter(output_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def write_markdown(path, records, humans, summaries, family_scenes):
    lines = [
        f"# VFX production inventory — generated {date.today().isoformat()}",
        "",
        "Source of catalog truth is the 12 school ledgers. Scene references come from current LAB scenes and their bound scripts.",
        "Scene presence, source approval, technical status, owner review, and live integration are recorded separately.",
        "",
        f"- Skill IDs: **{len(records)} unique**",
        f"- Skill families: **{len({row['family_id'] for row in records})}**",
        f"- Human cast masters: **{len(humans)}**",
        f"- Human families with at least one bound LAB scene: **{sum(row['human_families_with_lab_scene'] for row in summaries)}**",
        f"- Human cast families with at least one bound LAB scene: **{sum(row['human_cast_families_with_lab_scene'] for row in summaries)}**",
        f"- Distinct Human LAB scene revisions: **{len({scene for scenes in family_scenes.values() for scene in scenes})}**",
        "- Every ledger row retains its declared `live_integration` value. PvE status is not inferred from scenes.",
        "",
        "## Per-school coverage",
        "",
        "| School | IDs | Families | Human cast | Human families with scene | Cast families with scene | All scene revisions | Cast scene revisions | Owner approved | Provisional | Pending | Ledger/effective status conflicts | Tier fallback pending | Tier fallback incompatible | Passive/event receipt gated |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for row in summaries:
        lines.append(
            "| {school} | {skill_id_count} | {family_count} | {human_cast_master_count} | "
            "{human_families_with_lab_scene} | {human_cast_families_with_lab_scene} | "
            "{human_family_lab_scene_revision_count} | {human_cast_lab_scene_revision_count} | "
            "{human_owner_approved_count} | {human_provisional_count} | {human_pending_count} | "
            "{human_ledger_effective_status_conflicts} | "
            "{tier_fallback_pending_rows} | {tier_fallback_incompatible_rows} | "
            "{passive_event_receipt_gated_rows} |".format(**row)
        )

    lines.extend(
        [
            "",
            "## Human cast masters",
            "",
            "| School | Branch | Skill ID | Ledger owner gate | Ledger-derived owner status | Effective owner status | Decision evidence | Ledger technical/art status | Bound LAB scenes |",
            "|---|---|---|---|---|---|---|---|---|",
        ]
    )
    for row in humans:
        scenes = "; ".join(sorted(family_scenes.get(row["family_id"], set()))) or "—"
        lines.append(
            f"| {row['school']} | {row['branch']} | `{row['skill_id']}` | "
            f"{row['owner_gate']} | {row['owner_status_derived']} | "
            f"{row['owner_status_effective']} | {row['owner_decision_evidence']} | "
            f"{row['lab_visual_status']} | {scenes} |"
        )

    lines.extend(
        [
            "",
            "## Interpretation",
            "",
            "- Owner status is derived directly from each row's `owner_gate`. `lab_visual_status` remains the technical/art evidence label supplied by that ledger.",
            "- The current owner prompt states that all 17 Sword Human cast reviews are provisionally accepted. The effective Sword status is `OWNER_PROVISIONAL`; raw ledger owner fields remain intact, and this is not final art approval.",
            "- Immortal and Divine cast rows are compared with their Human family on effect, shape, target limit, and work class. A match is only `CONTRACT_COMPATIBLE_HUMAN_FALLBACK_PENDING`; a mismatch is `FALLBACK_INCOMPATIBLE`.",
            "- Passive and event rows remain `PASSIVE_EVENT_RECEIPT_GATED`. This inventory does not invent `NO_VISUAL_REQUIRED`.",
            "- Bound LAB scenes indicate discoverable scene/script references. They do not establish source-art quality, G3 completion, owner approval, or PvE integration.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default="/tmp/tmb-vfx-progress")
    args = parser.parse_args()
    output_dir = Path(args.out)
    output_dir.mkdir(parents=True, exist_ok=True)

    records, human_rows, humans, human_by_family = load_ledgers()
    if sum(
        row["school"] == "sword"
        and row["tier"] == "human"
        and row["visual_work_class"] == "CAST_MASTER"
        for row in records
    ) != 17:
        raise ValueError("The Sword owner override requires exactly 17 Human cast masters")
    family_scenes = discover_human_lab_scenes(human_by_family)
    annotated = annotate_records(records, human_by_family, family_scenes)
    annotated_humans = [
        row
        for row in annotated
        if row["tier"] == "human" and row["visual_work_class"] == "CAST_MASTER"
    ]
    summaries = school_summaries(annotated, family_scenes)

    write_csv(output_dir / "ALL_2196_VFX_STATUS.csv", annotated)
    write_csv(output_dir / "HUMAN_204_VFX_STATUS.csv", annotated_humans)
    write_csv(output_dir / "SCHOOL_SUMMARY.csv", summaries)
    write_markdown(
        output_dir / "HUMAN_204_VFX_STATUS.md",
        records,
        annotated_humans,
        summaries,
        family_scenes,
    )

    scene_count = sum(len(scenes) for scenes in family_scenes.values())
    print(
        "VFX_INVENTORY_PASS "
        f"skill_ids={len(records)} unique_ids={len({row['skill_id'] for row in records})} "
        f"families={len({row['family_id'] for row in records})} "
        f"human_cast_masters={len(humans)} "
        f"human_families_with_lab_scene={len(family_scenes)} "
        f"family_scene_bindings={scene_count}"
    )
    for summary in summaries:
        print(
            "VFX_SCHOOL "
            f"school={summary['school']} ids={summary['skill_id_count']} "
            f"families={summary['family_count']} "
            f"human_families_with_lab_scene={summary['human_families_with_lab_scene']} "
            f"human_cast_lab_families={summary['human_cast_families_with_lab_scene']} "
            f"approved={summary['human_owner_approved_count']} "
            f"provisional={summary['human_provisional_count']} "
            f"pending={summary['human_pending_count']} "
            f"owner_status_conflicts={summary['human_ledger_effective_status_conflicts']} "
            f"fallback_pending={summary['tier_fallback_pending_rows']} "
            f"fallback_incompatible={summary['tier_fallback_incompatible_rows']} "
            f"receipt_gated={summary['passive_event_receipt_gated_rows']}"
        )


if __name__ == "__main__":
    main()
