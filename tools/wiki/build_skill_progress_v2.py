#!/usr/bin/env python3
"""Build the V2 per-skill progress and evidence projection (read-only source sync)."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from source_inputs import V2_FIXED_SOURCE_PATHS, latest_commit  # noqa: E402

LEDGER_DIR = Path("docs/operations/vfx_school_ledgers")
PACKET_DIR = Path("docs/operations/vfx_packets")
TEST_DIRS = (Path("godot/tests"),)
ANIMATION_MANIFEST = "godot/labs/combat_lab/assets/nu_doc_tu_grok_01/manifest.json"
POISON_VFX_MANIFEST = "godot/labs/combat_lab/assets/poison_vfx/poison_vfx_manifest.json"
ANIMATION_EVIDENCE = (
    "docs/animation/TMB_DISCIPLE_ANIMATION_COVERAGE_20261111.md",
    "docs/animation/AS_CHAR49_V10_23OF24_CANDIDATE_20261116.md",
    "docs/animation/AS_CHAR49_V8_OWNER_APPROVED_ATTACK_4DIR_EXPORT_20261116.md",
    "docs/animation/AS_CHAR49_V9_CAST_HIT_FOUR_DIRECTION_EXPORT_20261116.md",
    "docs/animation/TMB_DISCIPLE_MASTER_BATCH_ORDER_20261117.md",
    "docs/animation/TMB_DISCIPLE_WEAPON_LANGUAGE_GUIDE_20261117.md",
    "docs/animation/TMB_DISCIPLE_SCHOOL_IDENTITY_BIBLE_20261117.md",
    "docs/handoffs/AS_CHAR49_V9_DEATH_SOURCE_NEXT_CHAT_HANDOFF_20261116.md",
)
AGGREGATE_QA = (
    "godot/tests/simulation/skill_all_catalogue_integrity_test.gd",
    "godot/tests/simulation/v63_d1_content_registry_test.gd",
    "godot/tests/presentation/v63_skill_presentation_s0_test.gd",
)
RUNTIME_EVIDENCE = (
    "godot/src/simulation/combat/v63_feature_gates.gd",
    "godot/data/combat/v63_content_registry.json",
)
GITHUB_EVIDENCE = Path("docs/wiki/TMB_WIKI_V2_GITHUB_EVIDENCE_20261117.json")
OUT_JSON = Path("wiki/data/skill_progress_v2.json")
OUT_REPORT = Path("wiki/data/skill_progress_v2_coverage.md")
OWNER_APPROVED_PREFIX = "OWNER_VISUAL_APPROVED"
PROVISIONAL_MARKERS = ("PROVISIONAL", "PROVISIONALLY", "OWNER_SELECTED")
BASELINE_GAP_IDS = {
    "GAP-SCHOOL-REGISTRY-COVERAGE", "GAP-V63-OFF", "GAP-PRESENTATION-LINK",
    "GAP-FORMULA-TRACE", "GAP-DUPLICATE-SKILL-ID", "GAP-SUSPECTED-DUPLICATE-PAIRS",
    "GAP-VFX-ART", "GAP-ART-ANIMATION", "GAP-EQUIPMENT-AUTHORITY", "GAP-REALM-QA",
}


def normalized_bytes(path: Path) -> bytes:
    raw = path.read_bytes()
    if path.suffix.lower() in {".md", ".csv", ".gd", ".py", ".json", ".tscn", ".tres", ".txt", ".cfg", ".gdshader", ".gdextension", ".import", ".yml", ".yaml"}:
        text = raw.decode("utf-8-sig").replace("\r\n", "\n").replace("\r", "\n")
        return text.encode("utf-8")
    return raw

def sha256_file(root: Path, relative: str) -> str:
    path = root / relative
    return hashlib.sha256(normalized_bytes(path)).hexdigest() if path.is_file() else ""

def read_json(path: Path, default: Any = None) -> Any:
    if not path.is_file():
        return default
    return json.loads(path.read_text(encoding="utf-8-sig"))

def v2_source_paths(root: Path) -> list[str]:
    catalog = read_json(root / "wiki/data/catalog.json", {})
    paths = set(V2_FIXED_SOURCE_PATHS)
    paths.update(ANIMATION_EVIDENCE)
    paths.update(AGGREGATE_QA)
    paths.update(RUNTIME_EVIDENCE)
    paths.update((
        "wiki/data/catalog.json",
        GITHUB_EVIDENCE.as_posix(),
        ANIMATION_MANIFEST,
        POISON_VFX_MANIFEST,
        str(catalog.get("presentationManifest", {}).get("sourcePath", "")),
    ))
    for item in catalog.get("skills", []):
        source_path = item.get("sourcePath")
        if source_path:
            paths.add(project_path(source_path))
    for directory in (LEDGER_DIR, PACKET_DIR):
        base = root / directory
        if not base.is_dir():
            continue
        suffix = ".csv" if directory == LEDGER_DIR else ".json"
        for path in base.rglob(f"*{suffix}"):
            paths.add(path.relative_to(root).as_posix())
    # Include packet dependencies only when they are text inputs whose SHA can be
    # recomputed cross-platform. Binary files remain explicitly manifest-declared.
    text_suffixes = {".gd", ".tscn", ".json", ".md", ".csv", ".py", ".txt", ".tres", ".cfg", ".gdshader", ".gdextension", ".import", ".yml", ".yaml"}
    packet_base = root / PACKET_DIR
    if packet_base.is_dir():
        for path in sorted(packet_base.rglob("*.json")):
            try:
                packet = json.loads(path.read_text(encoding="utf-8-sig"))
            except (OSError, json.JSONDecodeError):
                continue
            for ref in field_refs(packet, root):
                relative = ref.get("projectPath", "")
                if ref.get("exists") and Path(relative).suffix.lower() in text_suffixes:
                    paths.add(relative)
    # Test links are restricted to focused V6.3/VFX contract suites and aggregate
    # catalogue contracts. A source match is still NOT_EXECUTED evidence.
    skill_ids = {str(item.get("id", "")) for item in catalog.get("skills", [])}
    pattern = re.compile(r"tmb\.skill\.[A-Za-z0-9_.-]+")
    tests_root = root / "godot/tests"
    if tests_root.is_dir() and skill_ids:
        for path in tests_root.rglob("*.gd"):
            if not re.search(r"v63|vfx_.*contract", path.name, re.I):
                continue
            try:
                matches = skill_ids.intersection(pattern.findall(path.read_text(encoding="utf-8-sig")))
            except OSError:
                continue
            if matches:
                paths.add(path.relative_to(root).as_posix())
    return sorted(path for path in paths if path and (root / path).is_file())

def project_path(value: str) -> str:
    path = str(value or "")
    if path.startswith("res://"):
        return "godot/" + path[6:]
    return path

def make_ref(root: Path, path: str, kind: str) -> dict[str, Any]:
    relative = project_path(path)
    exists = (root / relative).is_file()
    text_source = Path(relative).suffix.lower() in {".gd", ".tscn", ".json", ".md", ".csv", ".py", ".txt", ".tres", ".cfg", ".gdshader", ".gdextension", ".import", ".yml", ".yaml"}
    return {
        "kind": kind, "path": path, "projectPath": relative, "exists": exists,
        "sourceSha256": sha256_file(root, relative) if exists and text_source else "",
        "shaStatus": "SOURCE_SHA256_COMPUTED" if exists and text_source else ("BINARY_HASH_REQUIRES_MANIFEST_OR_BYTE_READ" if exists else "MISSING"),
    }

def field_refs(packet: dict[str, Any], root: Path) -> list[dict[str, Any]]:
    candidates = [
        ("scene_path", "scene"), ("lab_script", "lab_script"),
        ("focused_test", "focused_test"), ("catalogue_path", "catalogue"),
        ("runtime_script", "runtime_consumer"),
    ]
    result = []
    for key, kind in candidates:
        value = packet.get(key)
        if isinstance(value, str) and value:
            result.append(make_ref(root, value, kind))
    for key in ("master_files", "atlas_files", "asset_files", "source_files", "png_files", "atlases"):
        value = packet.get(key)
        if isinstance(value, list):
            for item in value:
                path = item if isinstance(item, str) else item.get("path", "") if isinstance(item, dict) else ""
                if path:
                    result.append(make_ref(root, path, "asset"))
    provenance = packet.get("provenance", {})
    if isinstance(provenance, dict):
        for key in ("source_master", "atlas", "asset_path", "master_files"):
            value = provenance.get(key)
            values = value if isinstance(value, list) else [value]
            for item in values:
                path = item if isinstance(item, str) else item.get("path", "") if isinstance(item, dict) else ""
                if path:
                    result.append(make_ref(root, path, "asset"))
    unique = {(r["kind"], r["path"]): r for r in result}
    return [unique[k] for k in sorted(unique)]

def collect_packets(root: Path) -> tuple[dict[str, list[dict[str, Any]]], list[dict[str, Any]]]:
    by_skill: dict[str, list[dict[str, Any]]] = defaultdict(list)
    packet_index = []
    base = root / PACKET_DIR
    if not base.is_dir():
        return by_skill, packet_index
    for path in sorted(base.rglob("*.json")):
        try:
            packet = json.loads(path.read_text(encoding="utf-8-sig"))
        except (OSError, json.JSONDecodeError):
            continue
        skill_id = str(packet.get("skill_id", "")).strip()
        row = {
            "packetId": str(packet.get("packet_id", path.stem)),
            "path": path.relative_to(root).as_posix(),
            "sourceSha256": sha256_file(root, path.relative_to(root).as_posix()),
            "revision": str(packet.get("revision", "")),
            "refs": field_refs(packet, root),
            "gateStatus": packet.get("gate_status", packet.get("status", packet.get("gate", "UNKNOWN"))),
        }
        packet_index.append({"path": row["path"], "skillId": skill_id, "packetId": row["packetId"]})
        if skill_id:
            by_skill[skill_id].append(row)
    return by_skill, packet_index

def collect_test_id_links(root: Path, skill_ids: set[str]) -> dict[str, list[dict[str, str]]]:
    links: dict[str, list[dict[str, str]]] = defaultdict(list)
    pattern = re.compile(r"tmb\.skill\.[A-Za-z0-9_.-]+")
    for base_rel in TEST_DIRS:
        base = root / base_rel
        if not base.is_dir():
            continue
        for path in sorted(base.rglob("*.gd")):
            if not re.search(r"v63|vfx_.*contract", path.name, re.I):
                continue
            try:
                text = path.read_text(encoding="utf-8-sig")
            except OSError:
                continue
            matches = skill_ids.intersection(pattern.findall(text))
            if not matches:
                continue
            relative = path.relative_to(root).as_posix()
            source_sha = sha256_file(root, relative)
            for skill_id in matches:
                links[skill_id].append({"path": relative, "sourceSha256": source_sha, "status": "SOURCE_ID_MATCH_NOT_EXECUTED"})
    return links

def load_ledgers(root: Path) -> tuple[dict[str, dict[str, str]], list[dict[str, Any]]]:
    rows: dict[str, dict[str, str]] = {}
    sources = []
    base = root / LEDGER_DIR
    if not base.is_dir():
        return rows, sources
    for path in sorted(base.glob("*.csv")):
        relative = path.relative_to(root).as_posix()
        file_hash = sha256_file(root, relative)
        sources.append({"sourcePath": relative, "sourceSha256": file_hash, "kind": "vfx_skill_ledger"})
        with path.open(encoding="utf-8-sig", newline="") as handle:
            for row in csv.DictReader(handle):
                skill_id = row.get("skill_id", "").strip()
                if skill_id:
                    if skill_id in rows:
                        raise ValueError(f"duplicate skill_id in VFX ledgers: {skill_id}")
                    row["_sourcePath"] = relative
                    row["_sourceSha256"] = file_hash
                    rows[skill_id] = row
    return rows, sources

def owner_art_state(raw: str) -> str:
    value = (raw or "").upper()
    if value.startswith(OWNER_APPROVED_PREFIX):
        return "OWNER_APPROVED_RECORDED"
    if any(marker in value for marker in PROVISIONAL_MARKERS):
        return "PROVISIONAL_NOT_FINAL"
    return "OWNER_PENDING_OR_UNKNOWN"

def tech_state(raw: str) -> str:
    value = (raw or "").upper()
    if "TECH_FAIL" in value or value in {"FAIL", "GODOT_FAIL"}:
        return "TECH_FAIL_REPORTED"
    if "TECH_PASS" in value:
        return "TECH_PASS_REPORTED"
    return "TECH_STATUS_NOT_VERIFIED"

def load_asset_manifest(root: Path, relative: str, kind: str) -> dict[str, Any]:
    raw = read_json(root / relative, {})
    assets = []
    if kind == "actor_animation":
        for clip_name, clip in sorted(raw.get("animations", {}).items()):
            path = str(clip.get("sheet", ""))
            ref = make_ref(root, path, "animation_atlas")
            declared = str(clip.get("sheet_sha256", "")).lower()
            actual = ref["sourceSha256"].lower()
            ref.update({
                "clip": clip_name, "declaredSha256": declared,
                "hashStatus": "DECLARED_HASH_NOT_RECOMPUTED" if ref["exists"] and declared else ("MISSING" if not ref["exists"] else "DECLARED_HASH_ABSENT"),
                "frames": clip.get("frames"), "columns": clip.get("columns"),
                "rows": clip.get("rows"), "playbackFps": clip.get("playback_fps"),
                "loop": clip.get("loop"), "footAnchor": clip.get("foot_anchor"),
            })
            assets.append(ref)
    else:
        for asset in raw.get("assets", []):
            path = str(asset.get("path", ""))
            ref = make_ref(root, path, "vfx_master")
            declared = str(asset.get("sha256", "")).lower()
            actual = ref["sourceSha256"].lower()
            ref.update({
                "assetId": asset.get("id", ""), "branches": asset.get("branches", []),
                "uses": asset.get("uses", []), "declaredSha256": declared,
                "hashStatus": "DECLARED_HASH_NOT_RECOMPUTED" if ref["exists"] and declared else ("MISSING" if not ref["exists"] else "DECLARED_HASH_ABSENT"),
            })
            assets.append(ref)
        for asset in raw.get("preserved_source_actor_atlases", []):
            path = str(asset.get("path", ""))
            ref = make_ref(root, path, "actor_atlas")
            declared = str(asset.get("sha256", "")).lower()
            actual = ref["sourceSha256"].lower()
            ref.update({
                "branches": ["poison"], "declaredSha256": declared,
                "hashStatus": "DECLARED_HASH_NOT_RECOMPUTED" if ref["exists"] and declared else ("MISSING" if not ref["exists"] else "DECLARED_HASH_ABSENT"),
            })
            assets.append(ref)
    return {
        "sourcePath": relative,
        "sourceSha256": sha256_file(root, relative),
        "schemaVersion": raw.get("schema_version", raw.get("schemaVersion", "UNKNOWN")),
        "manifestStatus": raw.get("asset_status", raw.get("status", "UNKNOWN")),
        "assets": assets,
    }

def load_github_evidence(root: Path) -> tuple[dict[str, list[dict[str, Any]]], dict[str, Any]]:
    data = read_json(root / GITHUB_EVIDENCE, {"schemaVersion": 1, "runs": []})
    result: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for run in data.get("runs", []):
        conclusion = str(run.get("conclusion", "")).lower()
        run_status = str(run.get("runStatus", "")).lower()
        if not run.get("skillId"):
            continue
        if conclusion in {"success", "failure"}:
            action_status = "ACTION_SUCCESS_AT_RECORDED_SHA" if conclusion == "success" else "ACTION_FAILURE_AT_RECORDED_SHA"
        elif run_status in {"queued", "in_progress", "pending"}:
            action_status = "ACTION_IN_PROGRESS_AT_RECORDED_SHA"
        else:
            continue
        result[run["skillId"]].append({
            "runId": run.get("runId"),
            "name": run.get("name", ""),
            "url": run.get("url", ""),
            "headSha": run.get("headSha", ""),
            "conclusion": conclusion,
            "createdAt": run.get("createdAt", ""),
            "status": action_status,
            "runStatus": run_status or ("completed" if conclusion in {"success", "failure"} else "unknown"),
            "scope": run.get("evidenceScope", ""),
        })
    for runs in result.values():
        runs.sort(key=lambda item: (str(item.get("createdAt", "")), int(item.get("runId") or 0)))
    return result, data

def build_progress(root: Path = ROOT, strict: bool = True) -> dict[str, Any]:
    catalog = read_json(root / "wiki/data/catalog.json")
    if not isinstance(catalog, dict):
        raise ValueError("missing or invalid V1 wiki/data/catalog.json")
    source_skills = catalog.get("skills", [])
    catalog_by_id = {str(item.get("id", "")): item for item in source_skills}
    if "" in catalog_by_id or len(catalog_by_id) != len(source_skills):
        raise ValueError("V1 catalog has empty or duplicate skill IDs")
    ledger_by_id, ledger_sources = load_ledgers(root)
    if strict:
        expected = set(catalog_by_id)
        actual = set(ledger_by_id)
        if len(ledger_sources) != 12:
            raise ValueError(f"expected 12 VFX ledgers, found {len(ledger_sources)}")
        if expected != actual:
            raise ValueError(f"V1/ledger skill ID mismatch: catalog={len(expected)} ledger={len(actual)}")
        if catalog.get("counts", {}).get("branches") != 36 or len(catalog.get("schools", [])) != 12:
            raise ValueError("expected 12 designed schools and 36 branches")
        if len(expected) != 2196:
            raise ValueError(f"expected 2196 candidate IDs, found {len(expected)}")
    packet_by_skill, packet_index = collect_packets(root)
    test_links = collect_test_id_links(root, set(catalog_by_id))
    actor_manifest = load_asset_manifest(root, ANIMATION_MANIFEST, "actor_animation")
    poison_manifest = load_asset_manifest(root, POISON_VFX_MANIFEST, "poison")
    school_assets = [*poison_manifest["assets"]]
    action_by_skill, github_evidence = load_github_evidence(root)
    animation_sources = [
        {"sourcePath": path, "sourceSha256": sha256_file(root, path), "status": "ACTOR_LEVEL_ONLY_NO_SKILL_ID_MAPPING"}
        for path in ANIMATION_EVIDENCE if (root / path).is_file()
    ]
    runtime_sources = [
        {"sourcePath": path, "sourceSha256": sha256_file(root, path), "status": "GATE_OR_REGISTRY_SOURCE_ONLY"}
        for path in RUNTIME_EVIDENCE if (root / path).is_file()
    ]
    aggregate_qa_sources = [
        {"sourcePath": path, "sourceSha256": sha256_file(root, path), "status": "TEST_SOURCE_PRESENT_NOT_EXECUTED_AT_WIKI_SHA"}
        for path in AGGREGATE_QA if (root / path).is_file()
    ]
    feature_path = "godot/src/simulation/combat/v63_feature_gates.gd"
    registry = read_json(root / "godot/data/combat/v63_content_registry.json", {})
    all_disabled = bool(registry) and registry.get("enabled") is False
    branch_names = {str(row.get("id", "")): str(row.get("name", "")) for row in catalog.get("branches", [])}
    rows = []
    for skill_id in sorted(catalog_by_id):
        item = catalog_by_id[skill_id]
        ledger = ledger_by_id.get(skill_id, {})
        direct_packets = packet_by_skill.get(skill_id, [])
        tests = test_links.get(skill_id, [])
        runs = action_by_skill.get(skill_id, [])
        branch_slug = ledger.get("branch", "")
        branch_id = f"tmb.branch.{item.get('schoolId', ledger.get('school',''))}.{branch_slug}" if branch_slug and branch_slug != "shared" else ""
        runtime_status = str(item.get("runtimeStatus", "UNKNOWN"))
        if all_disabled and runtime_status in {"GATED_OFF", "DESIGN_ONLY", "REGISTRY_DISABLED"}:
            runtime_status = "GATED_OFF"
        qa_status = runs[-1]["status"] if runs else (
            "TEST_SOURCE_ID_MATCH_NOT_EXECUTED" if tests else "NO_SKILL_ID_QA_LINK"
        )
        owner_raw = ledger.get("owner_gate", "UNKNOWN")
        vfx_raw = ledger.get("lab_visual_status", "UNKNOWN")
        rows.append({
            "id": skill_id,
            "familyId": item.get("familyId", ledger.get("family_id", "")),
            "name": item.get("name", ledger.get("name_vi", skill_id)),
            "schoolId": item.get("schoolId", ledger.get("school", "")),
            "schoolName": item.get("schoolName", ""),
            "branchId": branch_id,
            "branch": branch_slug,
            "branchName": "Dùng chung" if branch_slug == "shared" else branch_names.get(branch_id, ""),
            "generation": item.get("generation", ledger.get("tier", "")),
            "slot": item.get("slot", ledger.get("slot", "")),
            "design": {
                "status": "V63_CANDIDATE_METADATA",
                "sourcePath": item.get("sourcePath", ""),
                "sourceSha256": item.get("sourceSha", ""),
                "version": item.get("version", ""),
                "vfxDeclaration": {
                    "key": ledger.get("vfx_key_declared", item.get("vfxKey", "")),
                    "effect": ledger.get("effect_declared", item.get("effect", "")),
                    "shape": ledger.get("shape_declared", item.get("shape", "")),
                    "targetLimit": ledger.get("target_limit_declared", item.get("targetLimit")),
                },
            },
            "runtime": {
                "status": runtime_status,
                "active": False,
                "sourcePaths": runtime_sources,
                "note": "V6.3 remains OFF; candidate metadata is not active gameplay.",
            },
            "vfx": {
                "declaredKey": ledger.get("vfx_key_declared", item.get("vfxKey", "")),
                "ledgerStatus": vfx_raw,
                "technicalStatus": tech_state(vfx_raw),
                "ownerGateRaw": owner_raw,
                "ownerStatus": owner_art_state(owner_raw),
                "liveIntegration": ledger.get("live_integration", "UNKNOWN"),
                "presentationMetadataStatus": item.get("presentationStatus", "UNKNOWN"),
                "presentationId": item.get("presentationId", ""),
                "ledgerPath": ledger.get("_sourcePath", ""),
                "ledgerSha256": ledger.get("_sourceSha256", ""),
                "packets": direct_packets,
                "relatedSchoolAssets": [asset for asset in school_assets if row_school_poison(item) and (not asset.get("branches") or branch_slug in asset.get("branches", []) or "poison" in asset.get("branches", []))],
            },
            "animation": {
                "key": item.get("animationKey", ""),
                "status": "UNKNOWN_NO_SKILL_ID_MAPPING",
                "evidence": animation_sources,
                "note": "Animation docs report actor/clip coverage; no evidence maps this skill ID to a verified clip.",
                "relatedSchoolAssets": [asset for asset in actor_manifest["assets"] if row_school_poison(item)],
            },
            "qa": {
                "status": qa_status,
                "tests": tests,
                "githubRuns": runs,
            },
            "traceability": {
                "sourcePath": item.get("sourcePath", ""),
                "sourceSha256": item.get("sourceSha", ""),
                "catalogVersion": item.get("version", ""),
                "runtimeEvidence": runtime_sources,
                "vfxLedgerPath": ledger.get("_sourcePath", ""),
                "vfxLedgerSha256": ledger.get("_sourceSha256", ""),
                "packetPaths": [packet["path"] for packet in direct_packets],
                "testPaths": [test["path"] for test in tests],
                "actionRunIds": [run["runId"] for run in runs],
            },
        })
    skill_counts = Counter(row["schoolId"] for row in rows)
    school_progress = []
    for school in catalog.get("schools", []):
        subset = [row for row in rows if row["schoolId"] == school.get("id")]
        school_progress.append(aggregate(school, subset, "school"))
    branch_progress = []
    for branch in catalog.get("branches", []):
        subset = [row for row in rows if row["branchId"] == branch.get("id")]
        branch_progress.append(aggregate(branch, subset, "branch"))
    owner_counts = Counter(row["vfx"]["ownerStatus"] for row in rows)
    tech_counts = Counter(row["vfx"]["technicalStatus"] for row in rows)
    qa_counts = Counter(row["qa"]["status"] for row in rows)
    summary = {
        "schools": len(catalog.get("schools", [])),
        "branches": len(catalog.get("branches", [])),
        "skillCandidates": len(rows),
        "sharedSkillCandidates": sum(1 for row in rows if row["branch"] == "shared"),
        "runtimeActive": sum(1 for row in rows if row["runtime"]["active"]),
        "runtimeGatedOff": sum(1 for row in rows if row["runtime"]["status"] == "GATED_OFF"),
        "directVfxPackets": sum(1 for row in rows if row["vfx"]["packets"]),
        "skillIdTestSourceLinks": sum(1 for row in rows if row["qa"]["tests"]),
        "exactShaActionEvidenceSkills": sum(1 for row in rows if row["qa"]["githubRuns"]),
        "exactShaSuccessfulActionSkills": sum(1 for row in rows if row["qa"]["status"] == "ACTION_SUCCESS_AT_RECORDED_SHA"),
        "exactShaFailedActionSkills": sum(1 for row in rows if row["qa"]["status"] == "ACTION_FAILURE_AT_RECORDED_SHA"),
        "exactShaInProgressActionSkills": sum(1 for row in rows if row["qa"]["status"] == "ACTION_IN_PROGRESS_AT_RECORDED_SHA"),
        "animationSkillMappingsVerified": sum(1 for row in rows if row["animation"]["status"] == "VERIFIED"),
        "ownerApprovedRecorded": owner_counts.get("OWNER_APPROVED_RECORDED", 0),
        "ownerProvisionalNotFinal": owner_counts.get("PROVISIONAL_NOT_FINAL", 0),
        "ownerPendingOrUnknown": owner_counts.get("OWNER_PENDING_OR_UNKNOWN", 0),
        "technicalStatusCounts": dict(sorted(tech_counts.items())),
        "qaStatusCounts": dict(sorted(qa_counts.items())),
        "vfxLedgerRows": len(ledger_by_id),
        "vfxLedgerFiles": len(ledger_sources),
    }
    inputs = []
    for relative in v2_source_paths(root):
        inputs.append({"sourcePath": relative, "sourceSha256": sha256_file(root, relative)})
    result = {
        "schemaVersion": 2,
        "visibility": "LOCAL_ONLY_PRIVATE_BY_DEFAULT",
        "sourceCommitSha": latest_commit(root, [path for path in v2_source_paths(root) if path not in {"wiki/data/catalog.json", GITHUB_EVIDENCE.as_posix()}]),
        "v1SourceCommitSha": str(catalog.get("sourceCommitSha", "UNKNOWN")),
        "syncDirection": "GAME_SOURCE_TO_WIKI_ONLY",
        "runtimeAuthority": "V6.3_OFF",
        "summary": summary,
        "schools": school_progress,
        "branches": branch_progress,
        "skills": rows,
        "packetIndex": packet_index,
        "ledgers": ledger_sources,
        "animationEvidence": animation_sources,
        "actorAnimationManifest": actor_manifest,
        "poisonVfxManifest": poison_manifest,
        "presentationManifest": catalog.get("presentationManifest", {}),
        "runtimeEvidence": runtime_sources,
        "aggregateQaSources": aggregate_qa_sources,
        "githubEvidence": github_evidence,
        "inputs": inputs,
        "gapRegister": catalog.get("gaps", []),
    }
    if strict:
        validate_gap_register(result["gapRegister"])
    return result

def validate_gap_register(gaps: list[dict[str, Any]]) -> None:
    actual = {str(gap.get("id", "")) for gap in gaps}
    if actual != BASELINE_GAP_IDS or len(gaps) != 10:
        raise ValueError(f"baseline gap register changed: expected {sorted(BASELINE_GAP_IDS)}, found {sorted(actual)}")

def row_school_poison(item: dict[str, Any]) -> bool:
    return str(item.get("schoolId", "")) == "poison"

def aggregate(entity: dict[str, Any], rows: list[dict[str, Any]], level: str) -> dict[str, Any]:
    return {
        "id": entity.get("id", ""),
        "name": entity.get("name", entity.get("schoolName", "")),
        "level": level,
        "designedCandidates": len(rows),
        "runtimeActive": sum(1 for row in rows if row["runtime"]["active"]),
        "runtimeGatedOff": sum(1 for row in rows if row["runtime"]["status"] == "GATED_OFF"),
        "vfxLedgerLinked": sum(1 for row in rows if row["vfx"]["ledgerPath"]),
        "vfxTechPassReported": sum(1 for row in rows if row["vfx"]["technicalStatus"] == "TECH_PASS_REPORTED"),
        "ownerArtApprovedRecorded": sum(1 for row in rows if row["vfx"]["ownerStatus"] == "OWNER_APPROVED_RECORDED"),
        "ownerProvisional": sum(1 for row in rows if row["vfx"]["ownerStatus"] == "PROVISIONAL_NOT_FINAL"),
        "animationUnknown": sum(1 for row in rows if row["animation"]["status"] == "UNKNOWN_NO_SKILL_ID_MAPPING"),
        "qaExactIdLinks": sum(1 for row in rows if row["qa"]["tests"]),
    }

def report_markdown(data: dict[str, Any]) -> str:
    s = data["summary"]
    lines = [
        "# Wiki V2 — coverage theo bằng chứng",
        "",
        f"- Source commit: `{data['sourceCommitSha']}`",
        f"- Wiki V1 baseline source commit: `{data['v1SourceCommitSha']}`",
        f"- Taxonomy: {s['schools']} môn phái, {s['branches']} nhánh.",
        f"- {s['skillCandidates']:,} skill V6.3 candidate IDs; runtime active: {s['runtimeActive']}; GATED_OFF: {s['runtimeGatedOff']}. V6.3 remains OFF.",
        f"- Exact per-skill VFX packet: {s['directVfxPackets']}; VFX ledger rows/files: {s['vfxLedgerRows']}/{s['vfxLedgerFiles']}.",
        f"- Exact skill-ID test source links: {s['skillIdTestSourceLinks']} (source link only, not execution).",
        f"- Exact-SHA Action evidence mapped: {s['exactShaActionEvidenceSkills']} skill(s); latest recorded SUCCESS: {s['exactShaSuccessfulActionSkills']}, FAILURE: {s['exactShaFailedActionSkills']}, IN_PROGRESS: {s['exactShaInProgressActionSkills']}.",
        f"- Owner art approval recorded: {s['ownerApprovedRecorded']}; provisional only: {s['ownerProvisionalNotFinal']}; pending/unknown: {s['ownerPendingOrUnknown']}.",
        f"- Per-skill animation mappings verified: {s['animationSkillMappingsVerified']}; remaining: UNKNOWN until a skill-ID-to-clip mapping is evidenced.",
        "",
        "## Phân biệt trạng thái",
        "",
        "- Candidate/spec/metadata không được tính là runtime hoạt động.",
        "- TECH_PASS_REPORTED không phải ART_APPROVED; owner provisional không phải duyệt cuối.",
        "- Có source ID trong test chỉ là liên kết mã nguồn; phải có exact-SHA run mới tính bằng chứng đã chạy.",
        "- Animation coverage hiện là bằng chứng cấp actor/clip, chưa ánh xạ từng skill ID.",
        "- Các link asset/scene trong packet phản ánh khai báo hiện có; hash nhị phân chỉ được xác minh khi có bằng chứng riêng.",
        "",
        "## Gap register",
        "",
        "Danh sách 10 gap được chép nguyên từ Wiki V1; chênh lệch Equipment 3 slot runtime / 10 slot thiết kế vẫn chờ Owner quyết định.",
        "",
        "| ID | Gap | Trạng thái | Nguồn |",
        "|---|---|---|---|",
    ]
    for gap in data["gapRegister"]:
        title = gap.get("title") or gap.get("summary") or "Chưa có mô tả"
        lines.append(f"| {gap.get('id','')} | {title} | {gap.get('status','')} | {gap.get('sourcePath','')} |")
    lines.extend(["", ""])
    return "\n".join(lines)

def write_outputs(root: Path, data: dict[str, Any]) -> None:
    out = root / OUT_JSON
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(data, ensure_ascii=False, indent=2, sort_keys=False) + "\n", encoding="utf-8", newline="\n")
    report = root / OUT_REPORT
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(report_markdown(data), encoding="utf-8", newline="\n")

def main() -> int:
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        data = build_progress(ROOT, strict=True)
        if args.write:
            write_outputs(ROOT, data)
            print(f"WIKI_PROGRESS_V2_WRITE_PASS skills={len(data['skills'])} source={data['sourceCommitSha']}")
            return 0
        expected = json.dumps(data, ensure_ascii=False, indent=2, sort_keys=False) + "\n"
        current_json = (ROOT / OUT_JSON).read_text(encoding="utf-8") if (ROOT / OUT_JSON).is_file() else ""
        current_report = (ROOT / OUT_REPORT).read_text(encoding="utf-8") if (ROOT / OUT_REPORT).is_file() else ""
        report_expected = report_markdown(data)
        if current_json != expected or current_report != report_expected:
            print("WIKI_PROGRESS_V2_STALE")
            return 1
        print(f"WIKI_PROGRESS_V2_CHECK_PASS skills={len(data['skills'])} source={data['sourceCommitSha']}")
        return 0
    except Exception as error:
        print(f"WIKI_PROGRESS_V2_ERROR {type(error).__name__}: {error}")
        return 2

if __name__ == "__main__":
    raise SystemExit(main())