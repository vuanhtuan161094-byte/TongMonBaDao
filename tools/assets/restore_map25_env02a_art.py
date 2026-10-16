#!/usr/bin/env python3
"""Restore original ENV-02A Source A PNGs into MAP25 after exact SHA-256 proof.

Verification is the default and NEVER writes. --import commits only a complete,
prevalidated 32/32 pack; unavailable, mismatching, or conflicting input fails
closed. No external downloads, extra dependencies, Source A reconstructions or
modifications to gameplay/save authority.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[2]
BASELINE = ROOT / "labs/env02a/ENV02A_BASELINE_ASSET_SHA256.json"
INDEX = ROOT / "godot/data/presentation/map25_source_a_verified.json"
ART_ROOT = ROOT / "godot/art/source_a_env02a"
MAX_IMAGE_BYTES = 16 * 1024 * 1024


def read_whitelist(index_path: Path = INDEX, baseline_path: Path = BASELINE) -> dict[str, str]:
    index = json.loads(index_path.read_text(encoding="utf-8"))
    reference = json.loads(baseline_path.read_text(encoding="utf-8"))
    if index.get("schema_version") != 1 or index.get("source_binary_in_repo") is not False:
        raise ValueError("Unexpected MAP25 art whitelist contract")
    rows = index.get("files")
    if not isinstance(rows, dict) or len(rows) != 32:
        raise ValueError("MAP25 requires exactly 32 curated images")
    original = reference.get("files", {})
    resolved: dict[str, str] = {}
    for relative, detail in rows.items():
        rel = Path(relative)
        if (not relative.endswith(".png") or rel.is_absolute() or
                any(part in ("", ".", "..") for part in rel.parts)):
            raise ValueError("Invalid whitelist relative path: " + relative)
        sha = str(detail.get("sha256", "")).lower()
        required_path = "res://art/source_a_env02a/" + relative
        if (original.get(relative) != sha or detail.get("path") != required_path or
                len(sha) != 64 or any(c not in "0123456789abcdef" for c in sha)):
            raise ValueError("ENV02A manifest mismatch: " + relative)
        resolved[relative] = sha
    return resolved


def inspect_archive(archive: Path, approved: dict[str, str]) -> dict[str, bytes]:
    # Compare ORIGINAL decompressed bytes; never infer authenticity from name,
    # CRC, artwork similarity, or Git blob SHA-1.
    wanted: dict[str, list[str]] = {}
    for path, sha in approved.items():
        wanted.setdefault(sha, []).append(path)
    found: dict[str, bytes] = {}
    with zipfile.ZipFile(archive, "r") as reader:
        for member in reader.infolist():
            if member.is_dir() or not member.filename.lower().endswith(".png"):
                continue
            if member.file_size <= 0 or member.file_size > MAX_IMAGE_BYTES:
                continue
            with reader.open(member, "r") as file:
                blob = file.read(MAX_IMAGE_BYTES + 1)
            if len(blob) != member.file_size:
                continue
            digest = hashlib.sha256(blob).hexdigest()
            for match in wanted.get(digest, ()):
                if match not in found:
                    found[match] = blob
    return found


def import_proven_files(approved: dict[str, str], found: dict[str, bytes],
                        destination: Path = ART_ROOT) -> tuple[int, int]:
    # Preflight ALL targets before writing even one image.
    for rel, sha in approved.items():
        dst = destination.joinpath(*Path(rel).parts)
        if dst.exists() and (not dst.is_file() or
                             hashlib.sha256(dst.read_bytes()).hexdigest() != sha):
            raise ValueError("Refuse overwrite of unverified existing art: " + str(dst))
        if rel not in found:
            raise ValueError("Refuse partial art import: " + rel)
    # Stage verified files on the same filesystem, then move into place.
    destination.mkdir(parents=True, exist_ok=True)
    staged_count = 0
    preserved_count = 0
    with tempfile.TemporaryDirectory(prefix=".map25_sha_stage_", dir=destination) as temp:
        stage = Path(temp)
        for rel in sorted(approved):
            dst = destination.joinpath(*Path(rel).parts)
            if dst.exists():
                preserved_count += 1
                continue
            src = stage.joinpath(*Path(rel).parts)
            src.parent.mkdir(parents=True, exist_ok=True)
            src.write_bytes(found[rel])
            if hashlib.sha256(src.read_bytes()).hexdigest() != approved[rel]:
                raise ValueError("Staged PNG hash mismatch: " + rel)
            staged_count += 1
        for rel in sorted(approved):
            src = stage.joinpath(*Path(rel).parts)
            if not src.exists():
                continue
            dst = destination.joinpath(*Path(rel).parts)
            dst.parent.mkdir(parents=True, exist_ok=True)
            os.replace(src, dst)
    return staged_count, preserved_count


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--archive", type=Path, required=True,
                    help="Original owner-authorized TongMonBaDao_ENV02A_192World_Lab.zip")
    ap.add_argument("--import", dest="do_import", action="store_true",
                    help="Write original PNGs only when all 32 checksums match")
    ap.add_argument("--report", type=Path,
                    help="Optional JSON inventory report (outside game authority)")
    args = ap.parse_args(argv)
    if not args.archive.is_file():
        print("ARCHIVE_NOT_ACCESSIBLE: " + str(args.archive), file=sys.stderr)
        return 2
    try:
        approved = read_whitelist()
        found = inspect_archive(args.archive, approved)
        missing = sorted(set(approved) - set(found))
        result = {
            "archive": args.archive.name,
            "approved_count": len(approved),
            "sha_verified_count": len(found),
            "missing": missing,
            "complete": not missing,
            "import_attempted": args.do_import,
            "imported": 0,
            "already_valid": 0,
        }
        if missing:
            print("MAP25_SOURCE_A_INCOMPLETE " + json.dumps(result,ensure_ascii=False))
            if args.report:
                args.report.parent.mkdir(parents=True, exist_ok=True)
                args.report.write_text(json.dumps(result,indent=2,ensure_ascii=False),
                                       encoding="utf-8")
            return 3
        if args.do_import:
            new_count, already_valid = import_proven_files(approved, found)
            result["imported"] = new_count
            result["already_valid"] = already_valid
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(result,indent=2,ensure_ascii=False),
                                   encoding="utf-8")
        print("MAP25_SOURCE_A_SHA256_PASS " + json.dumps(result,ensure_ascii=False))
        return 0
    except (OSError, ValueError, zipfile.BadZipFile, RuntimeError) as exc:
        print("MAP25_SOURCE_A_REJECTED: " + str(exc), file=sys.stderr)
        return 4


if __name__ == "__main__":
    raise SystemExit(main())
