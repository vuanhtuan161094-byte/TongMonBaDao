#!/usr/bin/env python3
"""Static validator for the P3 presentation authority/asset registry.

No third-party dependencies. Intended to run locally and in GitHub Actions.
This validator checks documentation/registry integrity only; it never claims
Godot runtime PASS.
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

ID_RE = re.compile(r"^[a-z0-9][a-z0-9_.-]*$")

REQUIRED_MASTER_REFS = (
    "P3_ART_BIBLE.md",
    "P3_ASSET_REGISTRY.json",
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

        # Only repo-managed runtime files are statically required to exist.
        # External diagnostic packs are intentionally allowed while the current
        # Character Creator proof is transported outside GitHub.
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
            source_path = asset.get("source_path")
            if not isinstance(source_path, str) or not rel_exists(source_path):
                fail(f"{prefix} repo_source requires an existing source_path", errors)

    if not MASTER_PATH.is_file():
        fail("missing docs/P3_PRESENTATION_MASTER.md", errors)
    else:
        master_text = MASTER_PATH.read_text(encoding="utf-8")
        for ref in REQUIRED_MASTER_REFS:
            if ref not in master_text:
                fail(f"master is missing authority reference: {ref}", errors)

    if not ART_BIBLE_PATH.is_file():
        fail("missing docs/P3_ART_BIBLE.md", errors)

    if errors:
        print("P3 PRESENTATION STATIC AUDIT: FAIL")
        for error in errors:
            print(f" - {error}")
        return 1

    print("P3 PRESENTATION STATIC AUDIT: PASS")
    print(f"assets={len(assets)} unique_ids={len(seen_ids)} categories={len(categories)}")
    for category in sorted(categories):
        print(f" - {category}: {categories[category]}")
    print("NOTE: This is a docs/registry integrity check, not a Godot runtime gate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
