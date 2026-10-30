from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from catalog_core import dump_json, sha256_file  # noqa: E402


def _is_portable(value: Any) -> bool:
    if isinstance(value, dict):
        return all(_is_portable(k) and _is_portable(v) for k, v in value.items())
    if isinstance(value, list):
        return all(_is_portable(v) for v in value)
    if isinstance(value, str):
        return not re.search(r"(?:[A-Za-z]:\\|[A-Za-z]:/|\\\\[^\\])", value)
    return True


def validate(root: Path, verify_hashes: bool = True) -> dict[str, Any]:
    errors: list[str] = []
    catalog_path = root / "catalog" / "library_index.json"
    if not catalog_path.is_file():
        return {"status": "FAIL", "errors": ["missing catalog/library_index.json"]}
    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    records = catalog.get("records", [])
    ids = [r.get("record_id") for r in records]
    hashes = {r.get("sha256") for r in records}
    if len(ids) != len(set(ids)):
        errors.append("duplicate record_id values")
    if not _is_portable(catalog):
        errors.append("catalog contains an absolute local path")
    if any("source_a" in str(row.get("source_id", "")).lower() for row in catalog.get("sources", [])):
        errors.append("out-of-scope Source A inventory metadata is present")
    if len(records) != catalog.get("statistics", {}).get("source_occurrences"):
        errors.append("source occurrence count does not match catalog length")

    referenced: set[str] = set()
    for rec in records:
        sha = rec.get("sha256", "")
        if not re.fullmatch(r"[a-f0-9]{64}", sha):
            errors.append(f"invalid SHA-256 for {rec.get('record_id')}")
            continue
        rel = Path(str(rec.get("texture_path", "")))
        if rel.is_absolute() or ".." in rel.parts or rel.as_posix() != f"textures/{sha}.webp":
            errors.append(f"unsafe or mismatched texture_path for {rec.get('record_id')}")
            continue
        texture = root / rel
        referenced.add(sha)
        if not texture.is_file():
            errors.append(f"missing texture payload {sha}")
        elif int(rec.get("bytes", -1)) != texture.stat().st_size:
            errors.append(f"byte size mismatch for {sha}")
        elif verify_hashes and sha256_file(texture) != sha:
            errors.append(f"SHA-256 mismatch for {sha}")
        size = rec.get("size_px") or []
        if len(size) != 2 or min(int(size[0]), int(size[1])) <= 0:
            errors.append(f"invalid dimensions for {rec.get('record_id')}")
        anim = rec.get("animation")
        if anim and anim.get("layout") == "rects":
            width, height = size
            for rect in anim.get("rects", []):
                if len(rect) != 6 or min(rect[:4]) < 0 or rect[0] + rect[2] > width or rect[1] + rect[3] > height:
                    errors.append(f"invalid frame bounds for {rec.get('record_id')}")
                    break
    actual_payloads = {p.stem for p in (root / "textures").glob("*.webp")} if (root / "textures").is_dir() else set()
    if referenced != actual_payloads:
        errors.append(f"payload pool mismatch: catalog {len(referenced)} unique, directory {len(actual_payloads)}")
    if not (root / "project.godot").is_file():
        errors.append("missing Godot project.godot")
    if not (root / "godot" / "scripts" / "jx_vfx_player.gd").is_file():
        errors.append("missing shared Godot player script")
    if not (root / "index.html").is_file():
        errors.append("missing offline HTML gallery")

    report = {
        "status": "STATIC_PASS_PENDING_ENGINE" if not errors else "FAIL",
        "source_occurrences": len(records),
        "unique_sha256_textures": len(hashes),
        "payloads_verified": len(referenced) if verify_hashes and not errors else None,
        "engine_status": "PENDING_ENGINE",
        "visual_status": "PENDING_VISUAL",
        "errors": errors,
        "checked_utc": __import__("datetime").datetime.now(__import__("datetime").timezone.utc).isoformat(),
    }
    dump_json(root / "QA_STATIC_REPORT.json", report)
    return report


def main() -> None:
    parser = argparse.ArgumentParser(description="Run bounded static QA on a built local library.")
    parser.add_argument("root", type=Path)
    parser.add_argument("--no-hash", action="store_true", help="skip hashing the local payload pool")
    args = parser.parse_args()
    result = validate(args.root, verify_hashes=not args.no_hash)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if result["status"] == "FAIL":
        raise SystemExit(1)


if __name__ == "__main__":
    main()

