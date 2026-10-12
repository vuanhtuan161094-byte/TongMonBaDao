#!/usr/bin/env python3
"""FE-01A source-A candidate manifest validation. No asset import or approval writes."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "godot/data/presentation/source_a_candidate_manifest.json"
REGISTRY = ROOT / "docs/P3_ASSET_REGISTRY.json"
EXPECTED_SOURCE_COMMIT = "83cbc4ecbd83eb518a6d6f2b3894377d9d99254d"
EXPECTED_ALIASES = {
    "main_hall": "building.sect_main_hall",
    "residence": "building.disciple_quarters",
    "cultivation": "building.cultivation_platform",
    "warehouse": "building.storage",
    "forge": "building.forge",
    "medicine": "building.medicine_hall",
    "mine": "building.mining_area",
    "gate": "building.sect_gate",
}
EXPECTED_MODELS = {
    "main_hall": 510052, "residence": 510076, "cultivation": 510191,
    "ren_than_duong": 510232, "warehouse": 510102, "forge": 520081,
    "medicine": 520031, "mine": 520051, "spirit_field": 520091,
    "linh_forest": 520101, "alchemy_hall": 520031,
    "guidance": 510111, "gate": 510163,
}
ANALOGS = {"cultivation", "ren_than_duong", "medicine"}
HEX64 = re.compile(r"^[a-f0-9]{64}$")
SAFE_FILENAME = re.compile(r"^[a-zA-Z0-9_.-]+$")


def validate(manifest: dict, registry: dict) -> list[str]:
    errors: list[str] = []

    def require(ok: bool, problem: str) -> None:
        if not ok:
            errors.append(problem)

    require(manifest.get("schema_version") == 1, "schema_version must be 1")
    require(manifest.get("authority_registry") == "docs/P3_ASSET_REGISTRY.json", "registry authority path changed")
    require(manifest.get("source_catalog_repo") == "vuanhtuan161094-byte/ZQZS-Source-Knowledge", "unknown source knowledge")
    require(manifest.get("source_catalog_commit") == EXPECTED_SOURCE_COMMIT, "source commit changed without preflight")
    require(manifest.get("source_catalog_path") == "transferkit/Catalog/BUILDING_VISUAL_INDEX.csv", "source catalog path changed")
    require(manifest.get("binary_transport") == "NOT_APPROVED", "binary transport cannot be enabled by FE-01A")
    require(manifest.get("runtime_asset_import") == "NONE", "binary imports cannot be enabled by FE-01A")
    require(manifest.get("release_policy") == "INTERNAL_LAB_ONLY_UNTIL_RIGHTS_VERIFIED", "release permission not verified")
    assets = registry.get("assets", [])
    approved = {a.get("id"): a for a in assets if isinstance(a, dict) and a.get("category") == "building"}
    require(len(approved) == 8 and set(approved) == set(EXPECTED_ALIASES.values()),
            "canonical approved building inventory changed")
    for asset_id in EXPECTED_ALIASES.values():
        a = approved.get(asset_id, {})
        require(a.get("visual_status") == "approved" and a.get("source_status") == "missing"
                and a.get("source_evidence_class") == "S3" and a.get("runtime_status") == "not_integrated",
                f"historical approved S3 art changed: {asset_id}")
    candidates = manifest.get("candidates", [])
    if not isinstance(candidates, list):
        return errors + ["candidates must be an array"]
    require(len(candidates) == 13, "13 candidate records required")
    seen_ids: set[str] = set()
    seen_dest: set[str] = set()
    source_hash_to_size: dict[str, int] = {}
    for index, item in enumerate(candidates):
        if not isinstance(item, dict):
            errors.append(f"candidates[{index}] must be an object")
            continue
        dest = item.get("destination_id")
        candidate_id = item.get("candidate_id")
        p = f"candidate[{index}]:{dest}"
        require(isinstance(dest, str) and dest in EXPECTED_MODELS, f"{p} unknown destination")
        require(isinstance(candidate_id, str) and candidate_id == "candidate.source_a." + item.get("source_logical_id", ""),
                f"{p} invalid candidate identity")
        require(isinstance(candidate_id, str) and candidate_id not in seen_ids, f"{p} duplicate candidate ID")
        require(isinstance(dest, str) and dest not in seen_dest, f"{p} duplicate destination")
        if isinstance(candidate_id, str):
            seen_ids.add(candidate_id)
        if isinstance(dest, str):
            seen_dest.add(dest)
        require(item.get("source_logical_id", "").startswith("building."), f"{p} invalid source logical id")
        require(item.get("source_model_id") == EXPECTED_MODELS.get(dest), f"{p} wrong source model")
        require(item.get("source_variant") == "A_AndroidData", f"{p} unexpected source variant")
        expected_evidence = "INFERRED_VISUAL_ANALOG" if dest in ANALOGS else "VERIFIED"
        require(item.get("evidence_status") == expected_evidence, f"{p} wrong evidence status")
        require(item.get("legacy_visual_asset_id") == EXPECTED_ALIASES.get(dest, ""), f"{p} invalid S3 alias")
        require(item.get("visual_status") == "CANDIDATE_NOT_APPROVED", f"{p} candidate silently approved")
        require(item.get("binary_imported") is False, f"{p} binary import asserted")
        require(item.get("runtime_resource_path") == "", f"{p} unapproved resource path")
        require(item.get("release_rights") == "UNVERIFIED", f"{p} release rights fabricated")
        require("A_USER_AUTHORIZED_LAB" in item.get("source_rights_note", ""), f"{p} missing lab-only rights note")
        require(item.get("godot_playback_status") == "NOT_TESTED", f"{p} unverified Spine playback promoted")
        expected_render = ("STATIC_TEXTURE_RENDERED_GODOT_4_7_2" if dest == "main_hall" else "NOT_TESTED")
        require(item.get("godot_render_status") == expected_render, f"{p} unverified Godot render promoted")
        require(item.get("shared_model_group") == ("model_520031" if dest in {"medicine", "alchemy_hall"} else ""),
                f"{p} incorrect shared model provenance")
        require(item.get("shared_texture_group") == ("texture_cuizhi" if dest in {"ren_than_duong", "gate"} else ""),
                f"{p} incorrect shared texture provenance")
        fp, door = item.get("footprint"), item.get("doorway_offset")
        require(isinstance(fp, list) and len(fp) == 2 and all(type(v) is int and v > 0 for v in fp),
                f"{p} invalid footprint")
        require(isinstance(door, list) and len(door) == 2 and all(type(v) is int for v in door),
                f"{p} invalid doorway")
        deps = item.get("source_dependencies", [])
        if not isinstance(deps, list):
            errors.append(f"{p} dependencies not an array")
            continue
        require(3 <= len(deps) <= 8, f"{p} invalid dependency count")
        kinds, names = set(), set()
        for dep in deps:
            if not isinstance(dep, dict):
                errors.append(f"{p} malformed dependency")
                continue
            name, digest, size = dep.get("name"), dep.get("sha256"), dep.get("bytes")
            require(isinstance(name, str) and SAFE_FILENAME.fullmatch(name) is not None,
                    f"{p} unsafe dependency filename")
            require(isinstance(name, str) and name not in names, f"{p} duplicate dependency filename")
            if isinstance(name, str):
                names.add(name)
            require(isinstance(digest, str) and HEX64.fullmatch(digest) is not None,
                    f"{p} malformed dependency SHA-256")
            require(type(size) is int and size > 0, f"{p} missing dependency byte count")
            if isinstance(digest, str) and type(size) is int:
                if digest in source_hash_to_size and source_hash_to_size[digest] != size:
                    errors.append(f"{p} shared digest has inconsistent size")
                source_hash_to_size[digest] = size
            if isinstance(name, str):
                kinds.add(name.rsplit(".", 1)[-1])
        require({"png", "skel", "atlas"}.issubset(kinds), f"{p} incomplete selected Spine triple")
        bundles = item.get("source_bundle_sha256", [])
        require(isinstance(bundles, list) and bool(bundles)
                and all(isinstance(v, str) and HEX64.fullmatch(v) for v in bundles),
                f"{p} missing source-bundle SHA-256")
    require(seen_dest == set(EXPECTED_MODELS), "destination set is incomplete")
    require(sum(d in ANALOGS for d in seen_dest) == 3, "analog count must be 3")
    require(len(source_hash_to_size) == 43, "expected 43 unique source dependency hashes")
    return errors


def main() -> int:
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        print("FE-01A MANIFEST FAIL:", exc)
        return 1
    errors = validate(manifest, registry)
    for error in errors:
        print("FE-01A MANIFEST ERROR:", error)
    if errors:
        return 1
    print("FE-01A MANIFEST VALIDATION PASS: 13 candidates, 10 VERIFIED/3 analogs, 8 S3 approved art unchanged, 43 unique hashes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
