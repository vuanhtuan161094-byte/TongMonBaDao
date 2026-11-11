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
POISON_V4_CLIP_IDS = ("idle", "walk", "cast", "attack", "hit", "death")


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


def gif_metadata(path: Path) -> tuple[int, int]:
    with path.open("rb") as stream:
        header = stream.read(10)
    if len(header) < 10 or header[:6] not in (b"GIF87a", b"GIF89a"):
        raise ValueError(f"not a valid GIF header: {path}")
    width, height = struct.unpack("<HH", header[6:10])
    return width, height


def _repo_path(root: Path, relative: str) -> Path:
    normalized = Path(relative.replace("\\", "/"))
    if normalized.is_absolute() or ".." in normalized.parts:
        raise ValueError(f"unsafe asset path: {relative}")
    return root / normalized


def _validate_poison_v4(root: Path, catalog: dict[str, Any], errors: list[str]) -> None:
    package = catalog.get("poison_v4_candidate", {})
    if package.get("status") != "CANDIDATE_NOT_FOR_PRODUCTION":
        errors.append("Nữ V4 package must remain CANDIDATE_NOT_FOR_PRODUCTION")
    if package.get("runtime_import") != "NONE":
        errors.append("Nữ V4 candidate must not be imported into production")
    if package.get("godot_validation") not in ("NOT_RUN", "PENDING", "FAILED", "PASS"):
        errors.append("Nữ V4 Godot validation status is invalid")

    try:
        manifest_path = _repo_path(root, str(package.get("manifest", "")))
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, ValueError, json.JSONDecodeError) as error:
        errors.append(f"Nữ V4 candidate manifest unavailable: {error}")
        return

    if manifest.get("overall_status") != "CANDIDATE_NOT_FOR_PRODUCTION":
        errors.append("Nữ V4 manifest must remain a candidate")
    expected_source = catalog.get("approved_poison_identity", {}).get("expected_source_sha256")
    if manifest.get("identity_source", {}).get("sha256") != expected_source:
        errors.append("Nữ V4 source master does not match the locked identity")
    if manifest.get("godot_import_status") not in ("NOT_RUN", "PENDING", "FAILED", "PASS"):
        errors.append("Nữ V4 Godot import status is invalid")
    clips = manifest.get("clips", {})
    for clip_id in POISON_V4_CLIP_IDS:
        if not isinstance(clips.get(clip_id), dict):
            errors.append(f"Nữ V4 clip record missing: {clip_id}")

    files = manifest.get("files", [])
    if not isinstance(files, list) or not files:
        errors.append("Nữ V4 file manifest is empty")
        return
    seen_ids: set[str] = set()
    for entry in files:
        if not isinstance(entry, dict):
            errors.append("Nữ V4 file record must be an object")
            continue
        file_id = str(entry.get("id", ""))
        if not file_id or file_id in seen_ids:
            errors.append(f"empty or duplicate Nữ V4 file id: {file_id}")
        seen_ids.add(file_id)
        try:
            local = _repo_path(root, str(entry.get("path", "")))
            if not local.is_file():
                errors.append(f"Nữ V4 file missing: {file_id}")
                continue
            if local.stat().st_size != int(entry.get("bytes", -1)):
                errors.append(f"Nữ V4 file size mismatch: {file_id}")
            if sha256_file(local) != entry.get("sha256"):
                errors.append(f"Nữ V4 file SHA-256 mismatch: {file_id}")
            if entry.get("kind") == "png":
                width, height, bit_depth, color_type = png_metadata(local)
                if [width, height] != entry.get("dimensions"):
                    errors.append(f"Nữ V4 PNG dimensions mismatch: {file_id}")
                if bit_depth != 8 or color_type != 6:
                    errors.append(f"Nữ V4 PNG must be 8-bit RGBA: {file_id}")
            elif entry.get("kind") == "gif":
                width, height = gif_metadata(local)
                if [width, height] != entry.get("dimensions"):
                    errors.append(f"Nữ V4 GIF dimensions mismatch: {file_id}")
            else:
                errors.append(f"unknown Nữ V4 file kind: {file_id}")
        except (OSError, ValueError, TypeError) as error:
            errors.append(f"Nữ V4 file check failed ({file_id}): {error}")


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
    elif poison.get("status") == "APPROVED_SOURCE":
        try:
            source_path = _repo_path(root, str(poison.get("actual_source_path", "")))
            if not source_path.is_file():
                errors.append("approved source master is missing")
            else:
                if sha256_file(source_path) != poison.get("expected_source_sha256"):
                    errors.append("approved source master SHA-256 mismatch")
                width, height, bit_depth, color_type = png_metadata(source_path)
                if [width, height] != poison.get("expected_source_dimensions"):
                    errors.append("approved source master dimensions mismatch")
                if bit_depth != 8 or color_type != 6:
                    errors.append("approved source master must be 8-bit RGBA")
        except (OSError, ValueError, TypeError) as error:
            errors.append(f"approved source master check failed: {error}")
    else:
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

    _validate_poison_v4(root, catalog, errors)

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
    print("AS-CHAR CATALOG PASS: source master, six existing sheets, V4 candidate hashes/dimensions/status, static turnarounds")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
