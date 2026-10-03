#!/usr/bin/env python3
"""Static validator for the P3 presentation authority/asset registry.

No third-party dependencies. Intended to run locally and in GitHub Actions.
This validator checks documentation/registry/source-evidence integrity only;
it never claims Godot runtime PASS.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "docs" / "P3_ASSET_REGISTRY.json"
MASTER_PATH = ROOT / "docs" / "P3_PRESENTATION_MASTER.md"
ART_BIBLE_PATH = ROOT / "docs" / "P3_ART_BIBLE.md"
RECOVERY_PATH = ROOT / "docs" / "P3_SOURCE_RECOVERY_MANIFEST.md"

ID_RE = re.compile(r"^[a-z0-9][a-z0-9_.-]*$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
SOURCE_EVIDENCE_CLASSES = {"S0", "S1", "S2", "S3", "S4"}

REQUIRED_MASTER_REFS = (
    "P3_ART_BIBLE.md",
    "P3_ASSET_REGISTRY.json",
    "P3_SOURCE_RECOVERY_MANIFEST.md",
    "P3_ASSET_BUILDINGS.md",
    "P3_ASSET_MAP_ENVIRONMENT.md",
    "P3_UX_MAIN_MAP.md",
    "P3_UX_DISCIPLE_SCREEN.md",
    "P3_UI_SKIN_AND_ICONOGRAPHY.md",
)

REQUIRED_ASSET_KEYS = (
    "id",
    "category",
    "display_name",
    "authority_doc",
    "design_status",
    "source_status",
    "source_evidence_class",
    "visual_status",
    "runtime_status",
    "runtime_management",
    "runtime_paths",
)


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def rel_exists(path_text: str) -> bool:
    return (ROOT / path_text).is_file()


def main() -> int:
    errors: list[str] = []

    if not REGISTRY_PATH.is_file():
        print(f"FAIL: missing {REGISTRY_PATH.relative_to(ROOT)}")
        return 1

    try:
        registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    except Exception as exc:  # pragma: no cover - fatal parse path
        print(f"FAIL: cannot parse registry JSON: {exc}")
        return 1

    if registry.get("schema_version") != 1:
        fail("registry.schema_version must be 1", errors)

    recovery_ref = registry.get("source_recovery_manifest")
    if recovery_ref != "docs/P3_SOURCE_RECOVERY_MANIFEST.md":
        fail("registry.source_recovery_manifest must point to docs/P3_SOURCE_RECOVERY_MANIFEST.md", errors)

    axes = registry.get("status_axes")
    if not isinstance(axes, dict):
        fail("registry.status_axes must be an object", errors)
        axes = {}

    expected_axes = (
        "design_status",
        "source_status",
        "visual_status",
        "runtime_status",
    )
    for axis in expected_axes:
        values = axes.get(axis)
        if not isinstance(values, list) or not values:
            fail(f"status_axes.{axis} must be a non-empty list", errors)

    assets = registry.get("assets")
    if not isinstance(assets, list) or not assets:
        fail("registry.assets must be a non-empty array", errors)
        assets = []

    seen_ids: set[str] = set()
    categories: dict[str, int] = {}

    for index, asset in enumerate(assets):
        prefix = f"assets[{index}]"
        if not isinstance(asset, dict):
            fail(f"{prefix} must be an object", errors)
            continue

        for key in REQUIRED_ASSET_KEYS:
            if key not in asset:
                fail(f"{prefix} missing required key: {key}", errors)

        asset_id = asset.get("id")
        if not isinstance(asset_id, str) or not ID_RE.fullmatch(asset_id):
            fail(f"{prefix}.id must match {ID_RE.pattern!r}", errors)
        elif asset_id in seen_ids:
            fail(f"duplicate asset id: {asset_id}", errors)
        else:
            seen_ids.add(asset_id)

        category = asset.get("category")
        if isinstance(category, str) and category:
            categories[category] = categories.get(category, 0) + 1
        else:
            fail(f"{prefix}.category must be a non-empty string", errors)

        authority_doc = asset.get("authority_doc")
        if not isinstance(authority_doc, str) or not authority_doc.startswith("docs/"):
            fail(f"{prefix}.authority_doc must be a docs/ path", errors)
        elif not rel_exists(authority_doc):
            fail(f"{prefix}.authority_doc does not exist: {authority_doc}", errors)

        for axis in expected_axes:
            value = asset.get(axis)
            allowed = axes.get(axis, [])
            if value not in allowed:
                fail(
                    f"{prefix}.{axis}={value!r} is not one of {allowed!r}",
                    errors,
                )

        evidence_class = asset.get("source_evidence_class")
        if evidence_class not in SOURCE_EVIDENCE_CLASSES:
            fail(
                f"{prefix}.source_evidence_class={evidence_class!r} must be one of "
                f"{sorted(SOURCE_EVIDENCE_CLASSES)!r}",
                errors,
            )

        visual_status = asset.get("visual_status")
        if visual_status == "approved":
            if not asset.get("approved_on"):
                fail(f"{prefix} visual approved but approved_on is missing", errors)
            if not asset.get("approval_evidence"):
                fail(f"{prefix} visual approved but approval_evidence is missing", errors)

        runtime_status = asset.get("runtime_status")
        if runtime_status in {"runtime_green", "runtime_locked"}:
            if not asset.get("runtime_evidence"):
                fail(f"{prefix} runtime green/locked but runtime_evidence is missing", errors)

        runtime_management = asset.get("runtime_management")
        runtime_paths = asset.get("runtime_paths")
        if not isinstance(runtime_paths, list):
            fail(f"{prefix}.runtime_paths must be an array", errors)
            runtime_paths = []

        if runtime_management == "repo" and runtime_status in {
            "runtime_green",
            "runtime_locked",
        }:
            if not runtime_paths:
                fail(f"{prefix} repo runtime green/locked requires runtime_paths", errors)
            for runtime_path in runtime_paths:
                if not isinstance(runtime_path, str) or not rel_exists(runtime_path):
                    fail(f"{prefix} missing repo runtime path: {runtime_path!r}", errors)

        source_status = asset.get("source_status")
        if source_status == "repo_source":
            if evidence_class != "S0":
                fail(f"{prefix} repo_source must use source evidence class S0", errors)
            source_path = asset.get("source_path")
            if not isinstance(source_path, str) or not rel_exists(source_path):
                fail(f"{prefix} repo_source requires an existing source_path", errors)

        elif source_status == "external_pack":
            if evidence_class != "S1":
                fail(f"{prefix} external_pack must use source evidence class S1", errors)
            if not isinstance(asset.get("source_ref"), str) or not asset.get("source_ref"):
                fail(f"{prefix} external_pack requires source_ref", errors)
            source_size = asset.get("source_size_bytes")
            if not isinstance(source_size, int) or source_size <= 0:
                fail(f"{prefix} external_pack requires positive source_size_bytes", errors)
            source_sha = asset.get("source_sha256")
            if not isinstance(source_sha, str) or not SHA256_RE.fullmatch(source_sha):
                fail(f"{prefix} external_pack requires lowercase 64-char source_sha256", errors)

        elif source_status == "external_reference":
            if evidence_class != "S2":
                fail(f"{prefix} external_reference must use source evidence class S2", errors)
            if not isinstance(asset.get("source_ref"), str) or not asset.get("source_ref"):
                fail(f"{prefix} external_reference requires an exact persistent source_ref", errors)

        elif source_status == "missing":
            if evidence_class not in {"S3", "S4"}:
                fail(f"{prefix} missing source must use S3 or S4 evidence class", errors)
            if not isinstance(asset.get("recovery_action"), str) or not asset.get("recovery_action"):
                fail(f"{prefix} missing source requires recovery_action", errors)

    if not MASTER_PATH.is_file():
        fail("missing docs/P3_PRESENTATION_MASTER.md", errors)
    else:
        master_text = MASTER_PATH.read_text(encoding="utf-8")
        for ref in REQUIRED_MASTER_REFS:
            if ref not in master_text:
                fail(f"master is missing authority reference: {ref}", errors)

    if not ART_BIBLE_PATH.is_file():
        fail("missing docs/P3_ART_BIBLE.md", errors)

    if not RECOVERY_PATH.is_file():
        fail("missing docs/P3_SOURCE_RECOVERY_MANIFEST.md", errors)

    if errors:
        print("P3 PRESENTATION STATIC AUDIT: FAIL")
        for error in errors:
            print(f" - {error}")
        return 1

    print("P3 PRESENTATION STATIC AUDIT: PASS")
    print(f"assets={len(assets)} unique_ids={len(seen_ids)} categories={len(categories)}")
    for category in sorted(categories):
        print(f" - {category}: {categories[category]}")
    print("NOTE: This is a docs/registry/source-evidence check, not a Godot runtime gate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
