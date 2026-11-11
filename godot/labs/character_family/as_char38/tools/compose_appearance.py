#!/usr/bin/env python3
"""Compose an appearance only from verified same-canvas RGBA source layers.

The tool is intentionally strict: it never tints/recolors whole sprites, resizes art,
invent frames, or substitutes missing layers. An incomplete manifest returns ART_PENDING.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image

from as_char38_registry import stable_appearance_seed


class ArtPendingError(RuntimeError):
    pass


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _safe_asset_path(base: Path, relative: str) -> Path:
    candidate = Path(relative)
    if candidate.is_absolute() or ".." in candidate.parts:
        raise ArtPendingError(f"unsafe layer path: {relative}")
    resolved = (base / candidate).resolve()
    if base.resolve() not in resolved.parents:
        raise ArtPendingError(f"layer path escapes manifest directory: {relative}")
    return resolved


def _choose_layers(manifest: dict[str, Any], sex_id: str, seed: int) -> list[dict[str, Any]]:
    layers = manifest.get("layers", [])
    eligible = []
    for layer in layers:
        allowed = layer.get("sex_id", "both")
        if allowed not in ("both", sex_id):
            continue
        if layer.get("source_status") != "SOURCE_AVAILABLE":
            if layer.get("required", False):
                raise ArtPendingError(f"required layer is {layer.get('source_status', 'missing')}: {layer.get('layer_id')}")
            continue
        eligible.append(layer)

    fixed = [layer for layer in eligible if not layer.get("cosmetic_slot")]
    slots: dict[str, list[dict[str, Any]]] = {}
    for layer in eligible:
        slot = str(layer.get("cosmetic_slot", ""))
        if slot:
            slots.setdefault(slot, []).append(layer)
    selected = list(fixed)
    for slot in sorted(slots):
        choices = sorted(slots[slot], key=lambda item: str(item.get("variant_id", item.get("layer_id", ""))))
        selected.append(choices[seed % len(choices)])
    selected.sort(key=lambda item: (int(item.get("order", 0)), str(item.get("layer_id", ""))))
    return selected


def compose(manifest_path: Path, snapshot: dict[str, Any], output_path: Path) -> dict[str, Any]:
    manifest_path = manifest_path.resolve()
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("schema_version") != 1:
        raise ValueError("unsupported appearance-layer manifest version")
    sex_id = str(snapshot.get("sex_id", "")).strip().lower()
    if sex_id not in ("male", "female"):
        raise ValueError("sex_id must be the canonical male/female value")
    if snapshot.get("school_id") != manifest.get("school_id") or snapshot.get("branch_id") != manifest.get("branch_id"):
        raise ArtPendingError("layer pack does not match the selected school/branch identity")
    if manifest.get("sex_id") not in ("both", sex_id):
        raise ArtPendingError("layer pack does not support the selected sex")
    if manifest.get("art_status") != "SOURCE_AVAILABLE":
        raise ArtPendingError(f"appearance source status is {manifest.get('art_status', 'ART_PENDING')}")

    cell = manifest.get("cell_size")
    directions = manifest.get("direction_order")
    if cell != [128, 128] or directions != ["front", "right", "back", "left"]:
        raise ValueError("layer pack must match the current 128x128 four-direction atlas contract")
    atlas_size = [cell[0] * len(directions), cell[1]]
    seed = stable_appearance_seed(snapshot)
    selected = _choose_layers(manifest, sex_id, seed)
    if not selected or not any(layer.get("layer_role") == "body_base" for layer in selected):
        raise ArtPendingError("no source-backed body_base layer is available")

    base_dir = manifest_path.parent
    composite = Image.new("RGBA", tuple(atlas_size), (0, 0, 0, 0))
    hashes = []
    for layer in selected:
        if layer.get("atlas_size") != atlas_size:
            raise ArtPendingError(f"layer canvas mismatch: {layer.get('layer_id')}")
        path = _safe_asset_path(base_dir, str(layer.get("path", "")))
        if not path.is_file():
            raise ArtPendingError(f"layer file missing: {layer.get('layer_id')}")
        actual_hash = sha256_file(path)
        if actual_hash != layer.get("sha256"):
            raise ArtPendingError(f"layer SHA-256 mismatch: {layer.get('layer_id')}")
        with Image.open(path) as source:
            rgba = source.convert("RGBA")
            if list(rgba.size) != atlas_size:
                raise ArtPendingError(f"layer image dimensions mismatch: {layer.get('layer_id')}")
            composite.alpha_composite(rgba)
        hashes.append({"layer_id": layer["layer_id"], "sha256": actual_hash})

    output_path.parent.mkdir(parents=True, exist_ok=True)
    composite.save(output_path, optimize=True)
    return {
        "status": "COMPOSED_SOURCE_BACKED",
        "output_path": output_path.as_posix(),
        "output_sha256": sha256_file(output_path),
        "appearance_seed": seed,
        "source_layers": hashes,
        "generated_frames": 0,
        "tint_or_geometry_transform": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--disciple-id", required=True)
    parser.add_argument("--sex-id", choices=("male", "female"), required=True)
    parser.add_argument("--school-id", required=True)
    parser.add_argument("--branch-id", required=True)
    parser.add_argument("--profile-seed", type=int, default=0)
    parser.add_argument("--cosmetic-seed", type=int, default=0)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    snapshot = {
        "disciple_id": args.disciple_id,
        "sex_id": args.sex_id,
        "school_id": args.school_id,
        "branch_id": args.branch_id,
        "profile_seed": args.profile_seed,
        "cosmetic_seed": args.cosmetic_seed,
    }
    try:
        receipt = compose(args.manifest, snapshot, args.output)
    except ArtPendingError as error:
        print(f"ART_PENDING: {error}")
        return 2
    print(json.dumps(receipt, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
