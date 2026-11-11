#!/usr/bin/env python3
"""Focused, dependency-free validation for the isolated AS-CHAR asset catalog."""
from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path
from typing import Any

REPO_RELATIVE_CATALOG = Path("godot/labs/character_family/catalog.json")
POISON_CLIP_IDS = ("idle", "walk", "cast", "attack", "hit", "defeated")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_metadata(path: Path) -> tuple[int, int, int, int]:
    with path.open("rb") as stream:
        header = stream.read(26)
    if len(header) < 26 or header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        raise ValueError(f"not a valid PNG header: {path}")
    width, height = struct.unpack(">II", header[16:24])
    return width, height, header[24], header[25]


def _repo_path(root: Path, relative: str) -> Path:
    normalized = Path(relative.replace("\\", "/"))
    if normalized.is_absolute() or ".." in normalized.parts:
        raise ValueError(f"unsafe asset path: {relative}")
    return root / normalized


def validate_catalog(root: Path, catalog_path: Path | None = None) -> list[str]:
    catalog_file = catalog_path or (root / REPO_RELATIVE_CATALOG)
    errors: list[str] = []
    try:
        catalog = json.loads(catalog_file.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        return [f"catalog read failed: {error}"]

    if catalog.get("schema_version") != 1:
        errors.append("schema_version must equal 1")
    if catalog.get("production_import") != "NONE":
        errors.append("isolated candidates must not be production-imported")

    poison = catalog.get("approved_poison_identity", {})
    if poison.get("status") == "BLOCKED_SOURCE_ART":
        if poison.get("actual_source_path") is not None:
            errors.append("blocked source must not have an actual source path")
    elif poison.get("status") != "APPROVED_SOURCE":
        errors.append("locked poison identity has an invalid status")

    manifest_relative = catalog.get("existing_grok_clips", {}).get("manifest", "")
    try:
        manifest_file = _repo_path(root, manifest_relative)
        manifest_bytes = manifest_file.read_bytes()
        manifest = json.loads(manifest_bytes.decode("utf-8"))
        if hashlib.sha256(manifest_bytes).hexdigest() != poison.get("existing_atlas_manifest_sha256"):
            errors.append("existing Nữ atlas manifest SHA-256 mismatch")
    except (OSError, ValueError, json.JSONDecodeError) as error:
        errors.append(f"existing Nữ atlas manifest unavailable: {error}")
        manifest = {}

    if manifest:
        animation_map: Any = manifest.get("animations", {})
        for clip_id in POISON_CLIP_IDS:
            clip = animation_map.get(clip_id) if isinstance(animation_map, dict) else None
            if not isinstance(clip, dict):
                errors.append(f"existing Nữ atlas clip missing from manifest: {clip_id}")
                continue
            sheet_path = clip.get("sheet", "")
            if not sheet_path.startswith("res://"):
                errors.append(f"invalid clip resource path: {clip_id}")
                continue
            local_path = root / "godot" / sheet_path[len("res://"):]
            if not local_path.is_file():
                errors.append(f"clip sheet file missing: {clip_id}")
                continue
            if sha256_file(local_path) != clip.get("sheet_sha256"):
                errors.append(f"clip sheet SHA-256 mismatch: {clip_id}")
            if int(clip.get("frames", 0)) < 1:
                errors.append(f"clip has no real frames: {clip_id}")

    candidates = catalog.get("candidates", [])
    if not isinstance(candidates, list) or len(candidates) < 2:
        errors.append("at least two isolated candidates are required")
        return errors

    seen_ids: set[str] = set()
    for candidate in candidates:
        if not isinstance(candidate, dict):
            errors.append("candidate record must be an object")
            continue
        asset_id = candidate.get("asset_id", "")
        if not asset_id or asset_id in seen_ids:
            errors.append(f"empty or duplicate candidate id: {asset_id}")
        seen_ids.add(asset_id)
        if candidate.get("status") != "CANDIDATE_NOT_APPROVED":
            errors.append(f"candidate was improperly promoted: {asset_id}")
        if candidate.get("runtime_import") != "NONE":
            errors.append(f"candidate has a runtime import: {asset_id}")
        if candidate.get("authored_views") != ["front", "right", "back", "left"]:
            errors.append(f"candidate directions are incomplete or reordered: {asset_id}")
        clips: Any = candidate.get("clips", {})
        if not isinstance(clips, dict) or any(status != "NOT_AUTHORED" for status in clips.values()):
            errors.append(f"static candidate claims an authored clip: {asset_id}")

        try:
            image_path = _repo_path(root, candidate.get("source_path", ""))
            if not image_path.is_file():
                errors.append(f"candidate PNG missing: {asset_id}")
                continue
            width, height, bit_depth, color_type = png_metadata(image_path)
            if [width, height] != candidate.get("dimensions"):
                errors.append(f"PNG dimensions mismatch: {asset_id}")
            if bit_depth != 8 or color_type != 6:
                errors.append(f"candidate must be 8-bit RGBA: {asset_id}")
            if sha256_file(image_path) != candidate.get("sha256"):
                errors.append(f"candidate SHA-256 mismatch: {asset_id}")
        except (OSError, ValueError) as error:
            errors.append(f"candidate PNG check failed ({asset_id}): {error}")

    return errors


def main() -> int:
    root = Path(__file__).resolve().parents[4]
    issues = validate_catalog(root)
    if issues:
        print("AS-CHAR CATALOG FAIL")
        for issue in issues:
            print(f"- {issue}")
        return 1
    print("AS-CHAR CATALOG PASS: catalog, six existing sheets, candidate hash/dimensions/status")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

