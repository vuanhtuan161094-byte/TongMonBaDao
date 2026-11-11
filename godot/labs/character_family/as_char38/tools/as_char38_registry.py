#!/usr/bin/env python3
"""AS-CHAR-38 registry validation and deterministic, read-only identity resolution."""
from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path
from typing import Any

RELATIVE_ROOT = Path("godot/labs/character_family/as_char38")
REGISTRY_RELATIVE = RELATIVE_ROOT / "as_char38_registry.json"
ASSET_MANIFEST_RELATIVE = RELATIVE_ROOT / "assets/g1_asset_manifest.json"
V63_REGISTRY_RELATIVE = Path("godot/data/combat/v63_content_registry.json")
DIRECTIONS = ("front", "right", "back", "left")
CLIPS = ("idle", "walk", "cast", "attack", "hit", "death")
SEXES = ("male", "female")
NOVICE_GROUPS = {
    "male": "tmb.as_char38.novice.male",
    "female": "tmb.as_char38.novice.female",
}


def load_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"expected JSON object: {path}")
    return value


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def png_metadata(path: Path) -> tuple[int, int, int, int]:
    with path.open("rb") as stream:
        header = stream.read(26)
    if len(header) < 26 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        raise ValueError(f"invalid PNG header: {path}")
    width, height = struct.unpack(">II", header[16:24])
    return width, height, header[24], header[25]


def stable_appearance_seed(snapshot: dict[str, Any]) -> int:
    """Derive a render-only seed without writing to or changing disciple state."""
    payload = {
        "disciple_id": str(snapshot.get("disciple_id", snapshot.get("id", ""))),
        "sex_id": str(snapshot.get("sex_id", "")),
        "profile_seed": int(snapshot.get("profile_seed", 0)),
        "cosmetic_seed": int(snapshot.get("cosmetic_seed", 0)),
    }
    canonical = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return int.from_bytes(hashlib.sha256(canonical.encode("utf-8")).digest()[:4], "big")


def validate_registry(root: Path) -> list[str]:
    errors: list[str] = []
    try:
        registry = load_json(root / REGISTRY_RELATIVE)
        v63 = load_json(root / V63_REGISTRY_RELATIVE)
        assets = load_json(root / ASSET_MANIFEST_RELATIVE)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return [f"required catalog unavailable or invalid: {error}"]

    groups = registry.get("groups", [])
    group_ids = [str(group.get("group_id", "")) for group in groups]
    if registry.get("schema_version") != 1:
        errors.append("unsupported AS-CHAR-38 schema_version")
    if len(groups) != 38 or len(set(group_ids)) != 38:
        errors.append("registry must contain 38 unique design groups")
    novices = [group for group in groups if group.get("group_kind") == "novice"]
    branches = [group for group in groups if group.get("group_kind") == "branch"]
    if len(novices) != 2 or len(branches) != 36:
        errors.append("expected exactly 2 novice and 36 branch groups")
    if {group.get("sex") for group in novices} != set(SEXES):
        errors.append("novice groups must cover exactly male and female")
    branch_schools = {group.get("school_id") for group in branches}
    if len(branch_schools) != 12:
        errors.append("the 36 design groups must cover exactly 12 schools")

    candidate_paths = {path.get("id") for path in v63.get("paths", [])}
    for branch in branches:
        if branch.get("design_status") != "DESIGN_DEFINED":
            errors.append(f"{branch.get('group_id')}: missing design-defined status")
        if branch.get("art_status") != "ART_PENDING":
            errors.append(f"{branch.get('group_id')}: absent branch art must remain ART_PENDING")
        if set(branch.get("sex_variants", {})) != set(SEXES):
            errors.append(f"{branch.get('group_id')}: both sex variants must be declared")
        for sex in SEXES:
            variant = branch.get("sex_variants", {}).get(sex, {})
            if variant.get("status") != "ART_PENDING":
                errors.append(f"{branch.get('group_id')} {sex}: art status must be ART_PENDING")
            if set(variant.get("directions", {})) != set(DIRECTIONS):
                errors.append(f"{branch.get('group_id')} {sex}: direction contract incomplete")
            if set(variant.get("clips", {})) != set(CLIPS):
                errors.append(f"{branch.get('group_id')} {sex}: clip contract incomplete")
        candidate = branch.get("v63_path_candidate_id")
        if candidate and candidate not in candidate_paths:
            errors.append(f"{branch.get('group_id')}: V63 path candidate ID is not in live registry")
        if not candidate and branch.get("v63_catalog_status") != "DESIGN_ONLY_NOT_IN_V63_PATH_CATALOG":
            errors.append(f"{branch.get('group_id')}: absent V63 path must be marked design-only")
        if branch.get("godot_rendered") is not False or branch.get("visual_approved") is not False:
            errors.append(f"{branch.get('group_id')}: no Godot or visual acceptance evidence exists yet")

    manifest_families = {item.get("family_id"): item for item in assets.get("families", [])}
    for novice in novices:
        family = "novice_" + str(novice.get("sex", ""))
        record = manifest_families.get(family)
        if record is None:
            errors.append(f"{family}: asset manifest record missing")
            continue
        atlas_path = root / str(record.get("atlas_path", ""))
        source_path = root / str(record.get("source_path", ""))
        frames_path = root / str(record.get("spriteframes_path", ""))
        if not atlas_path.is_file() or not source_path.is_file() or not frames_path.is_file():
            errors.append(f"{family}: source, atlas, or SpriteFrames resource missing")
            continue
        if sha256_file(atlas_path) != record.get("atlas_sha256"):
            errors.append(f"{family}: atlas SHA-256 mismatch")
        if sha256_file(source_path) != record.get("source_sha256"):
            errors.append(f"{family}: source SHA-256 mismatch")
        try:
            width, height, bit_depth, color_type = png_metadata(atlas_path)
            if (width, height, bit_depth, color_type) != (512, 128, 8, 6):
                errors.append(f"{family}: atlas must be 512x128 RGBA8, got {(width, height, bit_depth, color_type)}")
        except (OSError, ValueError) as error:
            errors.append(f"{family}: {error}")
        text = frames_path.read_text(encoding="utf-8")
        if text.count('[sub_resource type="AtlasTexture"') != 4:
            errors.append(f"{family}: SpriteFrames must contain four real direction frames")
        if any(f'name = &"{clip}' in text for clip in ("walk", "cast", "attack", "hit", "death")):
            errors.append(f"{family}: pending motion must not be emitted as animation")

    if registry.get("group_count") != 38:
        errors.append("registry group_count field must be 38")
    if registry.get("gameplay_mutation") != "NONE":
        errors.append("AS-CHAR-38 catalog must stay presentation-only")
    return errors


def resolve_identity(snapshot: dict[str, Any], registry: dict[str, Any]) -> dict[str, Any]:
    """Resolve read-only identity to an authored group or a clearly marked novice fallback."""
    disciple_id = str(snapshot.get("disciple_id", snapshot.get("id", ""))).strip()
    sex_id = str(snapshot.get("sex_id", "")).strip().lower()
    if sex_id not in SEXES:
        return {"status": "INVALID_OR_MISSING_SEX", "disciple_id": disciple_id, "render_group_id": None}
    if not disciple_id:
        return {"status": "MISSING_DISCIPLE_ID", "sex_id": sex_id, "render_group_id": None}

    requested = str(snapshot.get("v63_combat_branch_id", "")).strip()
    selected = None
    for group in registry.get("groups", []):
        if group.get("group_kind") != "branch":
            continue
        if requested in {
            str(group.get("group_id", "")),
            str(group.get("design_group_id", "")),
            str(group.get("v63_path_candidate_id", "")),
        } and requested:
            selected = group
            break
        if (
            str(snapshot.get("school_id", "")) == str(group.get("school_id", ""))
            and str(snapshot.get("branch_id", "")) == str(group.get("branch_design_slug", ""))
        ):
            selected = group
            break

    fallback_id = NOVICE_GROUPS[sex_id]
    seed = stable_appearance_seed(snapshot)
    if selected is None and not requested and not snapshot.get("branch_id"):
        return {
            "status": "NOVICE_BASE_STATIC_IDLE_CANDIDATE",
            "disciple_id": disciple_id,
            "sex_id": sex_id,
            "requested_branch_id": "",
            "selected_group_id": fallback_id,
            "render_group_id": fallback_id,
            "appearance_seed": seed,
            "simulation_mutated": False,
        }
    if selected is None:
        return {
            "status": "UNKNOWN_BRANCH_FALLBACK_NOVICE",
            "disciple_id": disciple_id,
            "sex_id": sex_id,
            "requested_branch_id": requested,
            "selected_group_id": None,
            "render_group_id": fallback_id,
            "appearance_seed": seed,
            "simulation_mutated": False,
        }
    return {
        "status": "ART_PENDING_FALLBACK_NOVICE",
        "disciple_id": disciple_id,
        "sex_id": sex_id,
        "requested_branch_id": requested or str(selected.get("design_group_id", "")),
        "selected_group_id": selected.get("group_id"),
        "render_group_id": fallback_id,
        "branch_art_status": selected.get("art_status", "ART_PENDING"),
        "appearance_seed": seed,
        "simulation_mutated": False,
    }


def main() -> int:
    root = Path(__file__).resolve().parents[5]
    errors = validate_registry(root)
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        print(f"AS_CHAR38_VALIDATION=FAIL errors={len(errors)}")
        return 1
    registry = load_json(root / REGISTRY_RELATIVE)
    branches = [group for group in registry["groups"] if group["group_kind"] == "branch"]
    candidates = sum(1 for group in branches if group.get("v63_path_candidate_id"))
    print("AS_CHAR38_VALIDATION=PASS groups=38 novice=2 branches=36 schools=12")
    print(f"V63_PATH_CANDIDATES={candidates} DESIGN_ONLY={len(branches) - candidates}")
    print("NOVICE_ATLASES=2x(4-direction static idle frame); motion=ART_PENDING")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
