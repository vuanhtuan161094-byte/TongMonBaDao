"""Portable metadata normalization for the local JX VFX library."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from typing import Any


def sha256_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(chunk_size), b""):
            digest.update(chunk)
    return digest.hexdigest()


def json_sha256(path: Path) -> str:
    return sha256_file(path)


def _portable(value: Any) -> Any:
    """Remove machine-absolute paths recursively while preserving source metadata."""
    if isinstance(value, dict):
        return {str(k): _portable(v) for k, v in value.items()}
    if isinstance(value, list):
        return [_portable(v) for v in value]
    if isinstance(value, str):
        if re.search(r"[A-Za-z]:[\\/]", value) or value.startswith("\\\\"):
            return "[local-source-path-omitted]"
        return value
    return value


def normalize_animation(record: dict[str, Any]) -> tuple[dict[str, Any] | None, str]:
    """Return normalized geometry and an evidence-labeled catalog status."""
    meta = record.get("metadata") or {}
    width, height = (record.get("size_px") or [0, 0])[:2]

    grid_keys = ("n", "d", "w", "h", "ax", "ay")
    if all(meta.get(k) is not None for k in grid_keys):
        try:
            frames, directions, fw, fh = (int(meta[k]) for k in ("n", "d", "w", "h"))
            anchor = [int(meta["ax"]), int(meta["ay"])]
        except (TypeError, ValueError):
            return None, "METADATA_PARTIAL"
        if min(frames, directions, fw, fh) <= 0:
            return None, "METADATA_PARTIAL"
        dimension_match = width == frames * fw and height == directions * fh
        geometry = {
            "layout": "grid",
            "frames": frames,
            "directions": directions,
            "frame_size": [fw, fh],
            "anchor_px": anchor,
            "source_dimensions_match": dimension_match,
        }
        timing = meta.get("ms")
        if dimension_match and timing is not None and int(timing) > 0:
            geometry.update({"frame_ms": int(timing), "timing_unit": "ms"})
            return geometry, "ANIMATION_DATA_COMPLETE_ENGINE_PENDING"
        if not dimension_match:
            return geometry, "GRID_DIMENSION_MISMATCH"
        return geometry, "GEOMETRY_COMPLETE_TIMING_MISSING"

    raw_rects = meta.get("rects")
    if isinstance(raw_rects, list) and raw_rects:
        if len(raw_rects) % 6:
            return None, "RECT_METADATA_INVALID"
        rects: list[list[int]] = []
        for at in range(0, len(raw_rects), 6):
            try:
                x, y, w, h, ax, ay = (int(v) for v in raw_rects[at:at + 6])
            except (TypeError, ValueError):
                return None, "RECT_METADATA_INVALID"
            if min(x, y, w, h) < 0 or x + w > width or y + h > height:
                return None, "RECT_BOUNDS_INVALID"
            rects.append([x, y, w, h, ax, ay])
        frames = int(meta.get("frames") or len(rects))
        directions = int(meta.get("dirs") or 1)
        geometry = {"layout": "rects", "frames": frames, "directions": directions, "rects": rects}
        timing = meta.get("frameMs")
        if timing is not None and int(timing) > 0:
            geometry.update({"frame_ms": int(timing), "timing_unit": "ms"})
            return geometry, "ANIMATION_DATA_COMPLETE_ENGINE_PENDING"
        if meta.get("interval") is not None:
            geometry.update({"source_interval": meta.get("interval"), "timing_unit": "UNVERIFIED"})
            return geometry, "GEOMETRY_COMPLETE_TIMING_UNVERIFIED"
        return geometry, "GEOMETRY_COMPLETE_TIMING_MISSING"

    if not record.get("metadata"):
        return None, "NO_METADATA_STATIC_TEXTURE"
    return None, "METADATA_PARTIAL"


def portable_record(record: dict[str, Any]) -> dict[str, Any]:
    animation, status = normalize_animation(record)
    path = f"textures/{record['sha256']}.webp"
    return {
        "record_id": record["record_id"],
        "source_id": record["source_id"],
        "source_relative_path": f"{record['source_id']}/{Path(record['filename']).name}",
        "filename": Path(record["filename"]).name,
        "sha256": record["sha256"],
        "bytes": int(record["bytes"]),
        "format": record.get("format", "WEBP"),
        "size_px": record.get("size_px"),
        "mode": record.get("mode"),
        "webp_internal_frames": record.get("webp_internal_frames", 1),
        "texture_path": path,
        "metadata": _portable(record.get("metadata")),
        "metadata_status": record.get("metadata_status", "UNKNOWN"),
        "animation": animation,
        "catalog_status": status,
        "skill_refs": _portable(record.get("skill_refs", [])),
        "source_authority": record.get("source_authority"),
    }


def dump_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

